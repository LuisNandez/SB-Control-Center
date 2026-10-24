import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'nexus_api_service.dart';

/// Qué debe mostrar la sección "Endorse" de Ajustes > General.
enum SelfEndorseState {
  /// Nada (ya endorsado, sin API key, sin datos o aún sin comprobar).
  hidden,

  /// La cuenta no tiene el endorse: se muestra el botón.
  available,

  /// El usuario pulsó Endorse: se muestra el agradecimiento (aunque el endorse
  /// real esté pendiente de reintento).
  thanked,
}

/// Motivo (mostrable) por el que el endorse no se pudo enviar.
enum SelfEndorseProblem { notDownloaded, invalidKey }

/// Deja endorsar la propia app (SB Control Center en Nexus Mods) desde
/// Ajustes > General, solo si la cuenta aún no la tiene endorsada (estados
/// "Undecided" y "Abstained").
///
/// El estado se guarda por cuenta en `self_endorse.json`, junto al .exe:
///
/// ```json
/// {
///   "version": 1,
///   "modId": "1959",
///   "accounts": {
///     "NombreDeCuenta": {
///       "keyFingerprint": "…",   // huella de la API key (la key NO se guarda)
///       "status": "Endorsed",    // Endorsed | Undecided | Abstained
///       "checkedAt": "2026-10-07T20:00:00.000",
///       "retryAt": null,         // reintento silencioso pendiente
///       "retriesDone": 0
///     }
///   }
/// }
/// ```
///
/// Al entrar en Ajustes se usa lo guardado y solo se vuelve a preguntar a
/// Nexus si el dato tiene más de [checkTtl] (10 min, como con los mods); el
/// resultado actualiza el json. Un "Endorsed" guardado no se rebaja por un
/// "Undecided"/vacío de la API (Nexus a veces lo informa mal); solo "Abstained"
/// (retirada explícita) lo cambia.
///
/// Nexus exige esperar 15 min desde la descarga del mod para endorsarlo. Si el
/// intento falla por eso (o por un problema pasajero de red / límite de
/// solicitudes), se agradece igualmente y se reintenta en silencio cada 20 min,
/// hasta [maxRetries] veces; el reintento pendiente también vive en el json.
class SelfEndorseService extends ChangeNotifier {
  SelfEndorseService._();
  static final SelfEndorseService instance = SelfEndorseService._();

  static const String modId = '1959';
  static const String modName = 'SB Control Center (Mod Manager)';
  static const String modUrl =
      'https://www.nexusmods.com/stellarblade/mods/$modId';

  static const String fileName = 'self_endorse.json';
  static const Duration checkTtl = Duration(minutes: 10);
  static const Duration retryDelay = Duration(minutes: 20);
  static const int maxRetries = 3;

  SelfEndorseState _state = SelfEndorseState.hidden;
  SelfEndorseState get state => _state;

  SelfEndorseProblem? _problem;
  SelfEndorseProblem? get problem => _problem;

  bool _busy = false;
  bool get busy => _busy;

  String _apiKey = '';
  String _version = '';
  String? _account; // nombre de la cuenta = clave dentro del json
  bool _wanted = false; // alguna pantalla pidió comprobar el estado
  bool _checking = false;
  Timer? _timer;

  Map<String, dynamic> _db = _emptyDb();
  Future<void>? _loadFuture;

  static Map<String, dynamic> _emptyDb() =>
      {'version': 1, 'modId': modId, 'accounts': <String, dynamic>{}};

  Map<String, dynamic> get _accounts {
    final a = _db['accounts'];
    if (a is Map<String, dynamic>) return a;
    final fresh = <String, dynamic>{};
    _db['accounts'] = fresh;
    return fresh;
  }

  void _setState(SelfEndorseState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  /// Huella de la API key (solo sirve para reconocer la cuenta sin red; la key
  /// no se guarda).
  static String _fingerprint(String key) {
    var h = 5381;
    for (final c in key.codeUnits) {
      h = ((h * 33) ^ c) & 0x7fffffff;
    }
    return h.toRadixString(36);
  }

  // ---- Archivo json junto al .exe ---------------------------------------------

  File get _file => File(
    p.join(File(Platform.resolvedExecutable).parent.path, fileName),
  );

  Future<void> _load() async {
    try {
      final f = _file;
      if (await f.exists()) {
        final data = json.decode(await f.readAsString());
        if (data is Map<String, dynamic>) {
          if (data['accounts'] is! Map<String, dynamic>) {
            data['accounts'] = <String, dynamic>{};
          }
          _db = data;
        }
      }
    } catch (e) {
      debugPrint('[SelfEndorse] no se pudo leer $fileName: $e');
      _db = _emptyDb();
    }
  }

  Future<void> _save() async {
    try {
      final f = _file;
      final tmp = File('${f.path}.tmp');
      await tmp.writeAsString(
        const JsonEncoder.withIndent('  ').convert(_db),
        flush: true,
      );
      await tmp.rename(f.path);
    } catch (e) {
      // Carpeta sin permiso de escritura, etc.: se sigue con lo que hay en memoria.
      debugPrint('[SelfEndorse] no se pudo guardar $fileName: $e');
    }
  }

  Map<String, dynamic>? get _record {
    final acc = _account;
    if (acc == null) return null;
    final r = _accounts[acc];
    return r is Map<String, dynamic> ? r : null;
  }

  /// Aplica un cambio al registro de la cuenta actual y guarda el json.
  Future<void> _update(void Function(Map<String, dynamic> rec) change) async {
    final acc = _account;
    if (acc == null) return;
    final rec = _accounts.putIfAbsent(acc, () => <String, dynamic>{})
        as Map<String, dynamic>;
    rec['keyFingerprint'] = _fingerprint(_apiKey);
    change(rec);
    await _save();
  }

  /// Averigua el nombre de la cuenta de la API key actual: primero por la huella
  /// guardada (sin red) y, si no hay registro, preguntando a Nexus.
  Future<bool> _resolveAccount({required bool allowNetwork}) async {
    if (_account != null) return true;
    if (_apiKey.isEmpty) return false;
    final key = _apiKey;
    final fp = _fingerprint(key);

    for (final entry in _accounts.entries) {
      final rec = entry.value;
      if (rec is Map && rec['keyFingerprint'] == fp) {
        _account = entry.key;
        return true;
      }
    }
    if (!allowNetwork) return false;

    final profile = await NexusApiService.validateAndGetProfile(key);
    if (key != _apiKey) return false; // la key cambió mientras tanto
    final name = profile != null && profile['isValid'] == true
        ? profile['name']?.toString().trim()
        : null;
    if (name == null || name.isEmpty) return false;
    _account = name;
    return true;
  }

  // ---- Configuración -------------------------------------------------------------

  /// Se llama al arrancar y cada vez que cambia la API key.
  void configure({required String? apiKey, String? version}) {
    final newKey = (apiKey ?? '').trim();
    final keyChanged = newKey != _apiKey;
    _apiKey = newKey;
    if (version != null && version.isNotEmpty) _version = version;

    if (keyChanged) {
      // Otra cuenta (o ninguna): cada una tiene su propio registro en el json.
      _timer?.cancel();
      _timer = null;
      _account = null;
      _problem = null;
      _setState(SelfEndorseState.hidden);
    }

    _loadFuture ??= _load();
    _loadFuture!.then((_) async {
      if (newKey != _apiKey || newKey.isEmpty) return;
      // Sin red: solo reanuda un reintento pendiente de esta cuenta.
      if (await _resolveAccount(allowNetwork: false)) {
        _resumePending();
      }
      if (keyChanged && _wanted) unawaited(ensureChecked());
    });
  }

  void _resumePending() {
    final retryAt = DateTime.tryParse('${_record?['retryAt'] ?? ''}');
    if (retryAt == null) return;
    if (_state == SelfEndorseState.hidden) _setState(SelfEndorseState.thanked);
    _scheduleTimerIfPossible();
  }

  // ---- Comprobación del estado ----------------------------------------------------

  static bool _isFresh(Object? checkedAt) {
    final at = DateTime.tryParse('${checkedAt ?? ''}');
    if (at == null) return false;
    final age = DateTime.now().difference(at);
    return !age.isNegative && age < checkTtl;
  }

  /// Un "Endorsed" guardado no se rebaja por "Undecided" (la API lo informa mal
  /// a veces); "Abstained" sí es una retirada explícita.
  static String _merge(String? stored, String fetched) {
    if (stored == 'Endorsed' && fetched == 'Undecided') return 'Endorsed';
    return fetched;
  }

  void _applyStatus(String? status) {
    if (status == null) return;
    if (status == 'Endorsed') {
      if (_state == SelfEndorseState.available) {
        _setState(SelfEndorseState.hidden);
      }
    } else if (_state == SelfEndorseState.hidden) {
      _setState(SelfEndorseState.available);
    }
  }

  /// Usa el estado guardado de la cuenta y, si tiene más de [checkTtl], lo
  /// actualiza con Nexus (y con el json). Se llama al entrar en Ajustes.
  Future<void> ensureChecked() async {
    _wanted = true;
    await (_loadFuture ??= _load());
    if (_apiKey.isEmpty || _checking || _busy) return;

    _checking = true;
    try {
      final key = _apiKey;
      if (!await _resolveAccount(allowNetwork: true)) return;
      if (key != _apiKey) return;

      // Reintento pendiente: el usuario ya endorsó; no hace falta preguntar.
      if (DateTime.tryParse('${_record?['retryAt'] ?? ''}') != null) {
        _resumePending();
        return;
      }

      final stored = _record?['status']?.toString();
      var status = stored;
      if (!_isFresh(_record?['checkedAt'])) {
        final fetched =
            await NexusApiService.fetchEndorseStatusOrUndecided(modId, key);
        debugPrint('[SelfEndorse] estado en Nexus: $fetched (guardado: $stored)');
        if (key != _apiKey) return;
        if (fetched != null) {
          status = _merge(stored, fetched);
          await _update((rec) {
            rec['status'] = status;
            rec['checkedAt'] = DateTime.now().toIso8601String();
          });
        }
        // fetched == null (sin red...): se conserva lo guardado.
      }
      _applyStatus(status);
    } finally {
      _checking = false;
    }
  }

  // ---- Acción del botón ---------------------------------------------------------------

  Future<void> endorse() async {
    if (_busy || _state != SelfEndorseState.available) return;
    if (_apiKey.isEmpty) return;

    _busy = true;
    _problem = null;
    notifyListeners();

    final key = _apiKey;
    await _resolveAccount(allowNetwork: true);
    final res = await NexusApiService.setEndorsement(
      nexusId: modId,
      apiKey: key,
      endorse: true,
      version: _version,
    );
    _busy = false;
    debugPrint('[SelfEndorse] endorse -> ok=${res.ok} fallo=${res.failure}');

    if (res.ok || res.failure == EndorseFailure.ownMod) {
      // Éxito (o el autor probando su propia app: no hay nada que pedir).
      await _markEndorsed();
      _setState(res.ok ? SelfEndorseState.thanked : SelfEndorseState.hidden);
      notifyListeners();
      return;
    }

    if (_isTransient(res.failure)) {
      // Casi seguro los 15 min de espera: se agradece igual y se reintenta.
      _setState(SelfEndorseState.thanked);
      await _update((rec) {
        rec['retryAt'] = DateTime.now().add(retryDelay).toIso8601String();
        rec['retriesDone'] = 0;
      });
      _scheduleTimerIfPossible();
      return;
    }

    if (res.failure == EndorseFailure.notDownloaded) {
      _problem = SelfEndorseProblem.notDownloaded;
    } else if (res.failure == EndorseFailure.invalidKey) {
      _problem = SelfEndorseProblem.invalidKey;
    } else {
      _setState(SelfEndorseState.hidden); // noApiKey / notFound
    }
    notifyListeners();
  }

  static bool _isTransient(EndorseFailure? f) =>
      f == EndorseFailure.tooSoon ||
      f == EndorseFailure.network ||
      f == EndorseFailure.rateLimited ||
      f == EndorseFailure.unknown;

  Future<void> _markEndorsed() async {
    _timer?.cancel();
    _timer = null;
    await _update((rec) {
      rec['status'] = 'Endorsed';
      rec['checkedAt'] = DateTime.now().toIso8601String();
      rec['retryAt'] = null;
      rec['retriesDone'] = 0;
    });
  }

  // ---- Reintentos silenciosos --------------------------------------------------------

  void _scheduleTimerIfPossible() {
    if (_timer != null || _apiKey.isEmpty || _account == null) return;
    final retryAt = DateTime.tryParse('${_record?['retryAt'] ?? ''}');
    if (retryAt == null) return;
    var delay = retryAt.difference(DateTime.now());
    // Si se venció con la app cerrada, no compite con el arranque.
    if (delay < const Duration(seconds: 10)) {
      delay = const Duration(seconds: 10);
    }
    _timer = Timer(delay, _attemptRetry);
  }

  Future<void> _attemptRetry() async {
    _timer = null;
    if (_apiKey.isEmpty || _account == null) return;
    final key = _apiKey;

    final res = await NexusApiService.setEndorsement(
      nexusId: modId,
      apiKey: key,
      endorse: true,
      version: _version,
    );
    if (key != _apiKey) return; // cambió de cuenta: ese reintento ya no aplica
    final done = ((_record?['retriesDone'] as num?)?.toInt() ?? 0) + 1;
    debugPrint(
      '[SelfEndorse] reintento $done/$maxRetries -> ok=${res.ok} fallo=${res.failure}',
    );

    if (res.ok || res.failure == EndorseFailure.ownMod) {
      await _markEndorsed();
      return;
    }
    if (_isTransient(res.failure) && done < maxRetries) {
      await _update((rec) {
        rec['retriesDone'] = done;
        rec['retryAt'] = DateTime.now().add(retryDelay).toIso8601String();
      });
      _scheduleTimerIfPossible();
      return;
    }
    // Se agotaron los reintentos (o el error ya no es pasajero): en silencio.
    // En otra sesión se volverá a consultar a Nexus y, si sigue sin el
    // endorse, se ofrecerá de nuevo.
    await _update((rec) {
      rec['retryAt'] = null;
      rec['retriesDone'] = 0;
    });
  }
}