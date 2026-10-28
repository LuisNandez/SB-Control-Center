// lib/services/github_update_service.dart
//
// Detecta si hay una versión nueva de la app en los Releases de GitHub y
// descarga el .zip publicado. La instalación la hace SelfUpdateService.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_prefs.dart';
import '../utils/version_utils.dart';
import 'self_update_service.dart';

class AppReleaseInfo {
  final String tag;
  final String version; // sin prefijo "v"
  final String name;
  final String notes;
  final String assetName;
  final Uri downloadUrl;
  final int? size;
  final String pageUrl;

  const AppReleaseInfo({
    required this.tag,
    required this.version,
    required this.name,
    required this.notes,
    required this.assetName,
    required this.downloadUrl,
    required this.size,
    required this.pageUrl,
  });
}

/// Notas de una release publicada (para mostrar el changelog).
class ReleaseNotes {
  final String tag;
  final String version;
  final String name;
  final String notes;
  final String url;
  final DateTime? publishedAt;
  final bool prerelease;

  const ReleaseNotes({
    required this.tag,
    required this.version,
    required this.name,
    required this.notes,
    required this.url,
    required this.publishedAt,
    required this.prerelease,
  });

  Map<String, dynamic> toJson() => {
        'tag': tag,
        'version': version,
        'name': name,
        'notes': notes,
        'url': url,
        'publishedAt': publishedAt?.toIso8601String(),
        'prerelease': prerelease,
      };

  factory ReleaseNotes.fromJson(Map<String, dynamic> j) => ReleaseNotes(
        tag: (j['tag'] as String?) ?? '',
        version: (j['version'] as String?) ?? '',
        name: (j['name'] as String?) ?? '',
        notes: (j['notes'] as String?) ?? '',
        url: (j['url'] as String?) ?? '',
        publishedAt: DateTime.tryParse((j['publishedAt'] as String?) ?? ''),
        prerelease: j['prerelease'] == true,
      );
}

class GithubUpdateService {
  static const String owner = 'LuisNandez';
  static const String repo = 'SB-Control-Center';
  static const String _downloadPrefix = 'sbcc_dl_';
  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'SB-Control-Center',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  /// Acepta cualquier formato de tag: "v3.0.1", "3.0.1", "Release-v3.0.1"...
  /// Toma el primer número con puntos que encuentre (3.0.1).
  static String _versionFromTag(String tag) =>
      RegExp(r'\d+(?:\.\d+)+').firstMatch(tag)?.group(0) ?? '';

  /// Tamaño legible (p. ej. "48.2 MB").
  static String formatSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var v = bytes.toDouble();
    var u = 0;
    while (v >= 1024 && u < units.length - 1) {
      v /= 1024;
      u++;
    }
    return '${v.toStringAsFixed(u == 0 ? 0 : 1)} ${units[u]}';
  }

  /// Lista de releases publicadas (más nueva primero), con notas.
  /// Si no hay conexión usa la última lista guardada; si tampoco existe, lanza.
  static Future<List<ReleaseNotes>> fetchReleases({int limit = 30}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.https(
        'api.github.com',
        '/repos/$owner/$repo/releases',
        {'per_page': '$limit'},
      );
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw SelfUpdateException('GitHub responded ${res.statusCode}.');
      }
      final list = json.decode(utf8.decode(res.bodyBytes)) as List<dynamic>;
      final out = <ReleaseNotes>[];
      for (final r in list) {
        if (r is! Map<String, dynamic>) continue;
        if (r['draft'] == true) continue;
        final tag = (r['tag_name'] as String?) ?? '';
        final version = _versionFromTag(tag);
        if (version.isEmpty) continue;
        out.add(ReleaseNotes(
          tag: tag,
          version: version,
          name: ((r['name'] as String?) ?? '').trim(),
          notes: ((r['body'] as String?) ?? '').trim(),
          url: (r['html_url'] as String?) ??
              'https://github.com/$owner/$repo/releases',
          publishedAt:
              DateTime.tryParse((r['published_at'] as String?) ?? '')?.toLocal(),
          prerelease: r['prerelease'] == true,
        ));
      }
      await prefs.setString(
        AppPrefs.releasesCache,
        json.encode([for (final r in out) r.toJson()]),
      );
      return out;
    } catch (e) {
      final cached = prefs.getString(AppPrefs.releasesCache);
      if (cached != null) {
        try {
          return [
            for (final j in json.decode(cached) as List<dynamic>)
              ReleaseNotes.fromJson(j as Map<String, dynamic>),
          ];
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// Devuelve la release más reciente si es MÁS NUEVA que [currentVersion];
  /// null si ya estás al día (o la release no trae un .zip).
  /// Lanza excepción si no hay conexión o GitHub responde con error.
  static Future<AppReleaseInfo?> checkForUpdate(String currentVersion) async {
    final uri =
        Uri.https('api.github.com', '/repos/$owner/$repo/releases/latest');
    final res = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 404) return null; // aún no hay releases
    if (res.statusCode != 200) {
      throw SelfUpdateException('GitHub responded ${res.statusCode}.');
    }

    final data = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (data['draft'] == true || data['prerelease'] == true) return null;

    final tag = (data['tag_name'] as String?) ?? '';
    final version = _versionFromTag(tag);
    if (version.isEmpty) return null;
    if (VersionUtils.compareVersions(version, currentVersion) <= 0) return null;

    // Primer asset .zip alojado en github.com (no el "Source code").
    for (final a in (data['assets'] as List? ?? const [])) {
      final name = (a['name'] as String?) ?? '';
      final url = Uri.tryParse((a['browser_download_url'] as String?) ?? '');
      if (!name.toLowerCase().endsWith('.zip') || url == null) continue;
      if (url.scheme != 'https' || url.host != 'github.com') continue;
      return AppReleaseInfo(
        tag: tag,
        version: version,
        name: (data['name'] as String?)?.trim().isNotEmpty == true
            ? data['name'] as String
            : tag,
        notes: ((data['body'] as String?) ?? '').trim(),
        assetName: name,
        downloadUrl: url,
        size: a['size'] as int?,
        pageUrl: (data['html_url'] as String?) ??
            'https://github.com/$owner/$repo/releases',
      );
    }
    return null;
  }

  /// Descarga el .zip a la carpeta temporal. [onProgress] va de 0 a 1
  /// (null = tamaño desconocido).
  static Future<File> download(
    AppReleaseInfo release, {
    void Function(double? fraction)? onProgress,
  }) async {
    final dest = File(p.join(
      Directory.systemTemp.path,
      '$_downloadPrefix${DateTime.now().millisecondsSinceEpoch}.zip',
    ));
    final client = http.Client();
    try {
      final req = http.Request('GET', release.downloadUrl)
        ..headers['User-Agent'] = 'SB-Control-Center';
      final resp = await client.send(req).timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) {
        throw SelfUpdateException('Download failed (HTTP ${resp.statusCode}).');
      }

      final total = resp.contentLength ?? release.size;
      final sink = dest.openWrite();
      var received = 0;
      try {
        await for (final chunk in resp.stream) {
          sink.add(chunk);
          received += chunk.length;
          onProgress?.call(
            (total != null && total > 0)
                ? (received / total).clamp(0.0, 1.0)
                : null,
          );
        }
      } finally {
        await sink.close();
      }

      if (total != null && total > 0 && received != total) {
        throw SelfUpdateException('The download was incomplete.');
      }
      return dest;
    } catch (e) {
      try {
        if (await dest.exists()) await dest.delete();
      } catch (_) {}
      if (e is SelfUpdateException) rethrow;
      throw SelfUpdateException('Could not download the update: $e');
    } finally {
      client.close();
    }
  }

  /// Borra descargas que hayan quedado en temporales (p. ej. por un cierre).
  static Future<void> cleanupDownloads() async {
    try {
      await for (final e in Directory.systemTemp.list(followLinks: false)) {
        if (e is File && p.basename(e.path).startsWith(_downloadPrefix)) {
          try {
            await e.delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}