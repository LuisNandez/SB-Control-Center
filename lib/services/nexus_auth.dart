// lib/services/nexus_auth.dart
//
// Autenticación con Nexus Mods: OAuth 2.0 (código de autorización + PKCE S256)
// y respaldo con la API key personal.
//
// * [NexusOAuthConfig]  -> constantes del registro con Nexus (client id, puerto...).
// * [NexusAuth]         -> UNA sola fuente de cabeceras para toda petición a la API
//                          (Authorization: Bearer ó apikey + Application-Name/Version,
//                          que exige la política de uso aceptable de la API).
// * [NexusOAuthService] -> flujo de inicio de sesión (navegador + callback local),
//                          intercambio del código, refresco y cierre de sesión.
//
// Prioridad: sesión OAuth > API key personal > nada.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
//  CONFIGURACIÓN
// ---------------------------------------------------------------------------

class NexusOAuthConfig {
  NexusOAuthConfig._();

  /// Client ID que Nexus Mods emite al registrar la aplicación. Se compila con
  ///   flutter build windows --dart-define=NEXUS_CLIENT_ID=xxxxxxxx
  /// Mientras esté vacío, el botón "Iniciar sesión" queda desactivado y la app
  /// sigue funcionando con la API key personal.
  static const String _compiledClientId = String.fromEnvironment('NEXUS_CLIENT_ID');

  /// Para pruebas: la variable de entorno NEXUS_CLIENT_ID pisa la compilada.
  static String get clientId {
    final env = Platform.environment['NEXUS_CLIENT_ID'];
    if (env != null && env.trim().isNotEmpty) return env.trim();
    return _compiledClientId.trim();
  }

  static bool get isConfigured => clientId.isNotEmpty;

  /// Callback local (loopback). DEBE coincidir EXACTAMENTE con la URI de
  /// redirección que se registre en Nexus. Puerto fijo, sin puerto alternativo.
  static const String redirectHost = '127.0.0.1';
  static const int redirectPort = 28651;
  static const String redirectPath = '/callback';
  static String get redirectUri => 'http://$redirectHost:$redirectPort$redirectPath';

  /// Endpoints (descubrimiento: users.nexusmods.com/.well-known/openid-configuration).
  static const String authorizeEndpoint = 'https://users.nexusmods.com/oauth/authorize';
  static const String tokenEndpoint = 'https://users.nexusmods.com/oauth/token';
  static const String revokeEndpoint = 'https://users.nexusmods.com/oauth/revoke';
  static const String userinfoEndpoint = 'https://users.nexusmods.com/oauth/userinfo';

  /// `openid` -> nombre de la cuenta (userinfo); `public` -> API pública.
  static const String scopes = 'openid public';

  /// Tiempo máximo esperando a que el usuario apruebe en el navegador.
  static const Duration signInTimeout = Duration(minutes: 5);

  /// Se refresca el token cuando le quedan menos de esto.
  static const Duration refreshSkew = Duration(minutes: 5);

  static const String prefsKey = 'nexusOAuthSession';
}

// ---------------------------------------------------------------------------
//  SESIÓN
// ---------------------------------------------------------------------------

class NexusOAuthSession {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String? userName;

  const NexusOAuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.userName,
  });

  NexusOAuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? userName,
  }) =>
      NexusOAuthSession(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        expiresAt: expiresAt ?? this.expiresAt,
        userName: userName ?? this.userName,
      );

  bool get needsRefresh =>
      DateTime.now().isAfter(expiresAt.subtract(NexusOAuthConfig.refreshSkew));

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'userName': userName,
      };

  static NexusOAuthSession? fromJson(dynamic j) {
    if (j is! Map) return null;
    final at = j['accessToken']?.toString();
    final exp = DateTime.tryParse(j['expiresAt']?.toString() ?? '');
    if (at == null || at.isEmpty || exp == null) return null;
    final rt = j['refreshToken']?.toString();
    return NexusOAuthSession(
      accessToken: at,
      refreshToken: (rt == null || rt.isEmpty) ? null : rt,
      expiresAt: exp,
      userName: j['userName']?.toString(),
    );
  }

  /// Nunca imprime los tokens.
  @override
  String toString() => 'NexusOAuthSession(user: $userName, expiresAt: $expiresAt)';
}

enum NexusSignInResult {
  success,
  notConfigured,
  alreadyInProgress,
  cancelled,
  portBusy,
  denied,
  timeout,
  browserFailed,
  failed,
}

// ---------------------------------------------------------------------------
//  NexusAuth: cabeceras y estado de la sesión
// ---------------------------------------------------------------------------

class NexusAuth {
  NexusAuth._();

  /// Identificación de la app (política de la API: nombre estable + versión actual).
  static const String appName = 'SB Control Center';
  static String appVersion = '1.0.0';

  /// Valor "marcador" que viaja por los parámetros `apiKey` de toda la app cuando
  /// hay una sesión OAuth activa. NO es una credencial: [headers] lo ignora y
  /// usa el token. Así el resto del código sigue tratando "hay credencial" como
  /// `apiKey != null && apiKey.isNotEmpty` sin cambios.
  static const String oauthMarker = '__nexus_oauth_session__';

  static NexusOAuthSession? _session;

  /// Se notifica al iniciar/cerrar sesión (también si el refresco falla y la
  /// sesión se invalida sola).
  static final ValueNotifier<NexusOAuthSession?> sessionListenable =
      ValueNotifier<NexusOAuthSession?>(null);

  static bool get isSignedIn => _session != null;
  static String? get userName => _session?.userName;

  static bool _lostUnexpectedly = false;

  /// true UNA vez si la sesión se invalidó sola (refresh token revocado o
  /// caducado), para avisar al usuario. Un cierre de sesión manual no lo activa.
  static bool takeLostUnexpectedly() {
    final v = _lostUnexpectedly;
    _lostUnexpectedly = false;
    return v;
  }

  /// Carga la sesión guardada. Llamar una vez al arrancar.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(NexusOAuthConfig.prefsKey);
      if (raw == null || raw.isEmpty) return;
      _session = NexusOAuthSession.fromJson(json.decode(raw));
      sessionListenable.value = _session;
    } catch (e) {
      debugPrint('[NexusAuth] no se pudo leer la sesión guardada');
      _session = null;
    }
  }

  /// Credencial efectiva para los `apiKey: ...` de la app.
  static String? credential(String? personalKey) =>
      isSignedIn ? oauthMarker : personalKey;

  /// Cabeceras de toda petición a api.nexusmods.com.
  ///  * Siempre: Application-Name / Application-Version.
  ///  * Con sesión: `Authorization: Bearer` (se refresca si hace falta).
  ///  * Sin sesión: `apikey` con la clave personal.
  ///  * [forceApiKey]: usa SIEMPRE [apiKey] (para validar una clave recién escrita).
  static Future<Map<String, String>> headers(
    String? apiKey, {
    bool forceApiKey = false,
    Map<String, String>? extra,
  }) async {
    final h = <String, String>{
      'accept': 'application/json',
      'Application-Name': appName,
      'Application-Version': appVersion,
    };

    var useKey = forceApiKey;
    if (!forceApiKey && isSignedIn) {
      final token = await NexusOAuthService._validAccessToken();
      if (token != null) {
        h['Authorization'] = 'Bearer $token';
      } else {
        useKey = true; // la sesión se invalidó: cae a la clave personal
      }
    } else if (!forceApiKey) {
      useKey = true;
    }

    if (useKey && !h.containsKey('Authorization')) {
      if (apiKey != null && apiKey.isNotEmpty && apiKey != oauthMarker) {
        h['apikey'] = apiKey;
      }
    }
    if (extra != null) h.addAll(extra);
    return h;
  }

  static DateTime _lastForcedRefresh = DateTime.fromMillisecondsSinceEpoch(0);

  /// La API respondió 401 con el token: se fuerza un refresco en la próxima
  /// petición (como mucho una vez cada 30 s para no entrar en bucle).
  static void markUnauthorized() {
    final s = _session;
    if (s == null) return;
    final now = DateTime.now();
    if (now.difference(_lastForcedRefresh) < const Duration(seconds: 30)) return;
    _lastForcedRefresh = now;
    _session = s.copyWith(expiresAt: now.subtract(const Duration(seconds: 1)));
  }

  static Future<void> _setSession(NexusOAuthSession? s, {bool persist = true}) async {
    final before = _session;
    _session = s;
    if (persist) {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (s == null) {
          await prefs.remove(NexusOAuthConfig.prefsKey);
        } else {
          await prefs.setString(NexusOAuthConfig.prefsKey, json.encode(s.toJson()));
        }
      } catch (_) {}
    }
    // Se avisa solo si cambió el estado (inicio/cierre de sesión o nombre de
    // cuenta); un simple refresco del token no debe disparar recargas de perfil.
    if ((before == null) != (s == null) || before?.userName != s?.userName) {
      sessionListenable.value = s;
    }
  }
}

// ---------------------------------------------------------------------------
//  Flujo OAuth
// ---------------------------------------------------------------------------

class _CallbackResult {
  final String? code;
  final String? state;
  final String? error;
  const _CallbackResult({this.code, this.state, this.error});
}

class NexusOAuthService {
  NexusOAuthService._();

  static final Random _rng = Random.secure();

  static Completer<_CallbackResult>? _pending;
  static bool get signInInProgress => _pending != null && !_pending!.isCompleted;

  // ---- PKCE ---------------------------------------------------------------

  static String _randomUrlSafe(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return List.generate(length, (_) => chars[_rng.nextInt(chars.length)]).join();
  }

  /// code_challenge = BASE64URL(SHA256(code_verifier)) sin relleno (RFC 7636).
  static String challengeFor(String verifier) =>
      base64Url.encode(sha256.convert(ascii.encode(verifier)).bytes).replaceAll('=', '');

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var r = 0;
    for (var i = 0; i < a.length; i++) {
      r |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return r == 0;
  }

  // ---- Inicio de sesión ----------------------------------------------------

  static Future<NexusSignInResult> signIn() async {
    if (!NexusOAuthConfig.isConfigured) return NexusSignInResult.notConfigured;
    if (signInInProgress) return NexusSignInResult.alreadyInProgress;

    final verifier = _randomUrlSafe(64);
    final state = _randomUrlSafe(43);

    HttpServer server;
    try {
      server = await HttpServer.bind(
        InternetAddress(NexusOAuthConfig.redirectHost),
        NexusOAuthConfig.redirectPort,
      );
    } on SocketException {
      return NexusSignInResult.portBusy;
    }

    final completer = Completer<_CallbackResult>();
    _pending = completer;

    final sub = server.listen((req) async {
      try {
        if (req.method != 'GET' || req.uri.path != NexusOAuthConfig.redirectPath) {
          req.response.statusCode = HttpStatus.notFound;
          await req.response.close();
          return;
        }
        final q = req.uri.queryParameters;
        final result = _CallbackResult(
          code: q['code'],
          state: q['state'],
          error: q['error'],
        );
        final ok = result.error == null && (result.code ?? '').isNotEmpty;
        req.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..write(_callbackPage(ok));
        await req.response.close();
        if (!completer.isCompleted) completer.complete(result);
      } catch (_) {
        try {
          await req.response.close();
        } catch (_) {}
      }
    });

    try {
      final authorizeUri = Uri.parse(NexusOAuthConfig.authorizeEndpoint).replace(
        queryParameters: {
          'response_type': 'code',
          'client_id': NexusOAuthConfig.clientId,
          'redirect_uri': NexusOAuthConfig.redirectUri,
          'scope': NexusOAuthConfig.scopes,
          'state': state,
          'code_challenge': challengeFor(verifier),
          'code_challenge_method': 'S256',
        },
      );

      final launched = await launchUrl(authorizeUri, mode: LaunchMode.externalApplication);
      if (!launched) return NexusSignInResult.browserFailed;

      final cb = await completer.future.timeout(
        NexusOAuthConfig.signInTimeout,
        onTimeout: () => const _CallbackResult(error: '__timeout__'),
      );

      if (cb.error == '__cancelled__') return NexusSignInResult.cancelled;
      if (cb.error == '__timeout__') return NexusSignInResult.timeout;
      if (cb.error != null) {
        debugPrint('[NexusOAuth] el servidor devolvió error: ${cb.error}');
        return NexusSignInResult.denied;
      }
      if (cb.code == null ||
          cb.code!.isEmpty ||
          cb.state == null ||
          !_constantTimeEquals(cb.state!, state)) {
        debugPrint('[NexusOAuth] callback con state/código inválido');
        return NexusSignInResult.failed;
      }

      final session = await _exchangeCode(cb.code!, verifier);
      if (session == null) return NexusSignInResult.failed;

      final name = await _fetchUserName(session.accessToken);
      await NexusAuth._setSession(name == null ? session : session.copyWith(userName: name));
      return NexusSignInResult.success;
    } catch (e) {
      debugPrint('[NexusOAuth] fallo en el inicio de sesión: ${e.runtimeType}');
      return NexusSignInResult.failed;
    } finally {
      _pending = null;
      await sub.cancel();
      await server.close(force: true);
    }
  }

  /// Cancela un inicio de sesión en curso (cierra el puerto local).
  static void cancelSignIn() {
    final c = _pending;
    if (c != null && !c.isCompleted) {
      c.complete(const _CallbackResult(error: '__cancelled__'));
    }
  }

  static String _callbackPage(bool ok) {
    final es = (Platform.localeName).toLowerCase().startsWith('es');
    final title = ok
        ? (es ? 'Sesión iniciada' : 'Signed in')
        : (es ? 'No se pudo iniciar sesión' : 'Sign-in failed');
    final msg = ok
        ? (es ? 'Ya puedes cerrar esta pestaña y volver a SB Control Center.'
              : 'You can close this tab and return to SB Control Center.')
        : (es ? 'Vuelve a SB Control Center e inténtalo de nuevo.'
              : 'Return to SB Control Center and try again.');
    return '<!doctype html><html><head><meta charset="utf-8"><title>$title</title>'
        '<style>body{font-family:system-ui,sans-serif;background:#111;color:#eee;'
        'display:flex;align-items:center;justify-content:center;height:100vh;margin:0}'
        'div{text-align:center}</style></head><body><div><h2>$title</h2>'
        '<p>$msg</p></div></body></html>';
  }

  // ---- Peticiones al servidor de tokens ------------------------------------

  static Future<Map<String, dynamic>?> _postForm(
    String url,
    Map<String, String> body, {
    void Function(int status, String? error)? onHttpError,
  }) async {
    final r = await http
        .post(
          Uri.parse(url),
          headers: {
            'content-type': 'application/x-www-form-urlencoded',
            'accept': 'application/json',
            'Application-Name': NexusAuth.appName,
            'Application-Version': NexusAuth.appVersion,
          },
          body: body,
        )
        .timeout(const Duration(seconds: 20));
    Map<String, dynamic>? decoded;
    try {
      final d = json.decode(r.body);
      if (d is Map<String, dynamic>) decoded = d;
    } catch (_) {}
    if (r.statusCode != 200) {
      // Solo se conserva el CÓDIGO de error de OAuth, nunca el cuerpo completo.
      onHttpError?.call(r.statusCode, decoded?['error']?.toString());
      return null;
    }
    return decoded;
  }

  static DateTime _expiryFrom(Map<String, dynamic> tokenResponse, String accessToken) {
    final exp = int.tryParse('${tokenResponse['expires_in'] ?? ''}');
    if (exp != null && exp > 0) return DateTime.now().add(Duration(seconds: exp));
    // Respaldo: claim `exp` del JWT.
    try {
      final parts = accessToken.split('.');
      if (parts.length >= 2) {
        final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );
        final e = payload is Map ? int.tryParse('${payload['exp'] ?? ''}') : null;
        if (e != null) return DateTime.fromMillisecondsSinceEpoch(e * 1000);
      }
    } catch (_) {}
    return DateTime.now().add(const Duration(hours: 1));
  }

  static Future<NexusOAuthSession?> _exchangeCode(String code, String verifier) async {
    try {
      final body = await _postForm(NexusOAuthConfig.tokenEndpoint, {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': NexusOAuthConfig.redirectUri,
        'client_id': NexusOAuthConfig.clientId,
        'code_verifier': verifier,
      }, onHttpError: (s, e) => debugPrint('[NexusOAuth] token HTTP $s ${e ?? ''}'));
      final at = body?['access_token']?.toString();
      if (body == null || at == null || at.isEmpty) return null;
      return NexusOAuthSession(
        accessToken: at,
        refreshToken: body['refresh_token']?.toString(),
        expiresAt: _expiryFrom(body, at),
      );
    } catch (e) {
      debugPrint('[NexusOAuth] intercambio de código falló: ${e.runtimeType}');
      return null;
    }
  }

  static Future<String?> _fetchUserName(String accessToken) async {
    try {
      final r = await http.get(
        Uri.parse(NexusOAuthConfig.userinfoEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'accept': 'application/json',
          'Application-Name': NexusAuth.appName,
          'Application-Version': NexusAuth.appVersion,
        },
      ).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return null;
      final d = json.decode(r.body);
      if (d is! Map) return null;
      for (final k in const ['name', 'preferred_username', 'username']) {
        final v = d[k]?.toString().trim();
        if (v != null && v.isNotEmpty) return v;
      }
    } catch (_) {}
    return null;
  }

  // ---- Refresco ------------------------------------------------------------

  static Future<String?>? _refreshing;

  /// Token vigente (lo refresca si le queda poco). null = no hay sesión válida.
  static Future<String?> _validAccessToken() async {
    final s = NexusAuth._session;
    if (s == null) return null;
    if (!s.needsRefresh) return s.accessToken;
    if (s.refreshToken == null) {
      if (!s.isExpired) return s.accessToken;
      NexusAuth._lostUnexpectedly = true;
      await NexusAuth._setSession(null);
      return null;
    }
    _refreshing ??= _refresh(s).whenComplete(() => _refreshing = null);
    return _refreshing;
  }

  static Future<String?> _refresh(NexusOAuthSession old) async {
    var permanent = false;
    try {
      final body = await _postForm(NexusOAuthConfig.tokenEndpoint, {
        'grant_type': 'refresh_token',
        'refresh_token': old.refreshToken!,
        'client_id': NexusOAuthConfig.clientId,
      }, onHttpError: (status, err) {
        // 4xx = el refresh token ya no sirve (revocado/caducado). 5xx = transitorio.
        if (status >= 400 && status < 500 && status != 429) permanent = true;
        debugPrint('[NexusOAuth] refresh HTTP $status ${err ?? ''}');
      });
      final at = body?['access_token']?.toString();
      if (body != null && at != null && at.isNotEmpty) {
        final fresh = NexusOAuthSession(
          accessToken: at,
          refreshToken: body['refresh_token']?.toString() ?? old.refreshToken,
          expiresAt: _expiryFrom(body, at),
          userName: old.userName,
        );
        await NexusAuth._setSession(fresh);
        return at;
      }
    } catch (e) {
      debugPrint('[NexusOAuth] refresh sin red: ${e.runtimeType}');
    }
    if (permanent) {
      NexusAuth._lostUnexpectedly = true;
      await NexusAuth._setSession(null);
      return null;
    }
    // Fallo transitorio: se sigue con el token actual mientras no haya caducado.
    return old.isExpired ? null : old.accessToken;
  }

  // ---- Cierre de sesión ----------------------------------------------------

  static Future<void> signOut() async {
    final s = NexusAuth._session;
    await NexusAuth._setSession(null); // local: siempre
    if (s == null) return;
    // Revocación en el servidor: mejor esfuerzo.
    try {
      final token = s.refreshToken ?? s.accessToken;
      await _postForm(NexusOAuthConfig.revokeEndpoint, {
        'token': token,
        'token_type_hint': s.refreshToken != null ? 'refresh_token' : 'access_token',
        'client_id': NexusOAuthConfig.clientId,
      });
    } catch (_) {}
  }
}
