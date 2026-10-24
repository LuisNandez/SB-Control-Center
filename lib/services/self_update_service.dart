// lib/services/self_update_service.dart
//
// Auto-instalación de la propia app (versión portable distribuida en un .zip).
//
// Sin scripts externos ni dependencias nuevas. Todo se hace desde la propia app:
//   1. [prepareFromZip]: extrae el zip a una carpeta temporal (con el paquete
//      `archive`) y localiza la carpeta que contiene el .exe de la app.
//   2. [install]: Windows permite RENOMBRAR archivos en uso (exe, dll) aunque no
//      permite sobrescribirlos ni borrarlos. Por cada archivo del paquete, el
//      actual se renombra a `*.sbcc_old` y el nuevo se copia en su lugar. Si algo
//      falla, se revierte todo. No se borra nada que el zip no traiga (así los
//      archivos del usuario y los futuros archivos nuevos/viejos no importan:
//      se actualiza lo que venga en el zip, sea lo que sea).
//   3. [relaunch]: abre la versión nueva con `--sbcc-wait-pid=<pid>`; el nuevo
//      proceso espera (en `main`) a que el actual termine antes de arrancar,
//      por el control de instancia única.
//   4. [cleanupLeftovers]: al arrancar, borra los `*.sbcc_old` y temporales.
//
// Recibe un zip local. La misma ruta la usará después la descarga desde Nexus.
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:path/path.dart' as p;

class SelfUpdateException implements Exception {
  final String message;
  SelfUpdateException(this.message);
  @override
  String toString() => message;
}

enum SelfUpdateStage { extracting, installing, restarting }

/// [fraction] va de 0 a 1 (null = indeterminado).
typedef SelfUpdateProgress = void Function(
  SelfUpdateStage stage,
  double? fraction,
);

/// Resultado de preparar la actualización (zip ya extraído y validado).
class SelfUpdatePlan {
  final Directory stagingRoot;
  final Directory payloadDir;
  final Directory appDir;
  final String exeName;
  final int fileCount;

  const SelfUpdatePlan({
    required this.stagingRoot,
    required this.payloadDir,
    required this.appDir,
    required this.exeName,
    required this.fileCount,
  });
}

class SelfUpdateService {
  static const String _stagingPrefix = 'sbcc_update_';
  static const String _oldSuffix = '.sbcc_old';
  static const String waitPidArg = '--sbcc-wait-pid=';

  static Directory get appDir =>
      Directory(p.dirname(Platform.resolvedExecutable));

  static String get exeName => p.basename(Platform.resolvedExecutable);

  /// Archivo de registro (en la carpeta temporal) con el detalle del último intento.
  static File get logFile =>
      File(p.join(Directory.systemTemp.path, 'sbcc_update.log'));

  static bool get isSupported => Platform.isWindows;

  /// En debug/profile (`flutter run`) el "ejecutable" es el build de desarrollo:
  /// sobrescribirlo lo dejaría roto. Allí solo se valida el paquete.
  static bool get canApply => kReleaseMode;

  static Future<void> _log(String m) async {
    try {
      await logFile.writeAsString(
        '${DateTime.now().toIso8601String()} $m\n',
        mode: FileMode.append,
      );
    } catch (_) {}
  }

  // ------------------------------------------------------------- preparar

  static Future<SelfUpdatePlan> prepareFromZip(
    String zipPath, {
    SelfUpdateProgress? onProgress,
  }) async {
    if (!isSupported) {
      throw SelfUpdateException('Self-update is only supported on Windows.');
    }
    final zip = File(zipPath);
    if (!await zip.exists()) {
      throw SelfUpdateException('The selected file does not exist.');
    }

    final app = appDir;
    await _assertWritable(app);

    final staging = Directory(p.join(
      Directory.systemTemp.path,
      '$_stagingPrefix${DateTime.now().millisecondsSinceEpoch}',
    ));
    await staging.create(recursive: true);
    await _log('Preparing update from "$zipPath" (app dir: ${app.path})');

    try {
      onProgress?.call(SelfUpdateStage.extracting, null);
      await _extractZip(zip, staging, onProgress);

      final payload = await _findPayloadDir(staging, exeName);
      if (payload == null) {
        throw SelfUpdateException(
          'The archive does not contain "$exeName". '
          'It does not look like a SB Control Center package.',
        );
      }

      var count = 0;
      await for (final e in payload.list(recursive: true, followLinks: false)) {
        if (e is File) count++;
      }
      await _log('Package OK: $count files, payload "${payload.path}"');

      return SelfUpdatePlan(
        stagingRoot: staging,
        payloadDir: payload,
        appDir: app,
        exeName: exeName,
        fileCount: count,
      );
    } catch (e) {
      await _log('Prepare failed: $e');
      await _deleteQuietly(staging);
      rethrow;
    }
  }

  static Future<void> discard(SelfUpdatePlan plan) =>
      _deleteQuietly(plan.stagingRoot);

  // ------------------------------------------------------------- instalar

  /// Reemplaza los archivos de la app por los del paquete. Si falla, revierte.
  static Future<void> install(
    SelfUpdatePlan plan, {
    SelfUpdateProgress? onProgress,
  }) async {
    if (!canApply) {
      throw SelfUpdateException(
        'Applying updates is disabled outside release builds.',
      );
    }

    final sources = <File>[];
    await for (final e
        in plan.payloadDir.list(recursive: true, followLinks: false)) {
      if (e is File) sources.add(e);
    }

    final stamp = DateTime.now().millisecondsSinceEpoch;
    // (destino, copia de seguridad del archivo anterior o null si era nuevo)
    final done = <({File dest, File? backup})>[];

    try {
      for (var i = 0; i < sources.length; i++) {
        final src = sources[i];
        final rel = p.relative(src.path, from: plan.payloadDir.path);
        final dest = File(p.join(plan.appDir.path, rel));

        await dest.parent.create(recursive: true);

        File? backup;
        if (await dest.exists()) {
          backup = File('${dest.path}.$stamp$_oldSuffix');
          await dest.rename(backup.path);
        }
        done.add((dest: dest, backup: backup));
        await src.copy(dest.path);

        onProgress?.call(
          SelfUpdateStage.installing,
          (i + 1) / sources.length,
        );
      }
      await _log('Installed ${sources.length} files');
    } catch (e) {
      await _log('Install failed: $e — rolling back');
      for (final r in done.reversed) {
        try {
          if (await r.dest.exists()) await r.dest.delete();
          if (r.backup != null && await r.backup!.exists()) {
            await r.backup!.rename(r.dest.path);
          }
        } catch (err) {
          await _log('Rollback error on ${r.dest.path}: $err');
        }
      }
      throw SelfUpdateException('Could not install the update: $e');
    }
  }

  // -------------------------------------------------------------- reiniciar

  /// Abre la app (ya actualizada) y devuelve. El llamador debe cerrar el
  /// proceso actual enseguida; el nuevo espera a que termine.
  static Future<void> relaunch(SelfUpdatePlan plan) async {
    final exe = p.join(plan.appDir.path, plan.exeName);
    await _log('Relaunching "$exe"');
    await Process.start(
      exe,
      ['$waitPidArg$pid'],
      workingDirectory: plan.appDir.path,
      mode: ProcessStartMode.detached,
    );
    await _deleteQuietly(plan.stagingRoot);
  }

  /// Llamar al principio de `main`: si la app fue abierta por una actualización,
  /// espera a que el proceso anterior termine (máx. 30 s).
  static Future<void> waitForPreviousInstance(List<String> args) async {
    if (!isSupported) return;
    int? waitPid;
    for (final a in args) {
      if (a.startsWith(waitPidArg)) {
        waitPid = int.tryParse(a.substring(waitPidArg.length));
      }
    }
    if (waitPid == null) return;

    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (DateTime.now().isBefore(deadline)) {
      try {
        final r = await Process.run(
          'tasklist',
          ['/FI', 'PID eq $waitPid', '/NH', '/FO', 'CSV'],
        );
        if (!r.stdout.toString().contains('"$waitPid"')) return;
      } catch (_) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  // ------------------------------------------------------------- limpieza

  /// Borra los `*.sbcc_old` de la carpeta de la app y temporales anteriores.
  static Future<void> cleanupLeftovers() async {
    if (!isSupported) return;
    try {
      await for (final e in appDir.list(recursive: true, followLinks: false)) {
        if (e is File && e.path.endsWith(_oldSuffix)) {
          try {
            await e.delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
    try {
      await for (final e in Directory.systemTemp.list(followLinks: false)) {
        if (e is Directory && p.basename(e.path).startsWith(_stagingPrefix)) {
          await _deleteQuietly(e);
        }
      }
    } catch (_) {}
  }

  // ------------------------------------------------------------- internos

  static Future<void> _deleteQuietly(FileSystemEntity e) async {
    try {
      if (await e.exists()) await e.delete(recursive: true);
    } catch (_) {}
  }

  static Future<void> _assertWritable(Directory dir) async {
    final probe = File(p.join(dir.path, '.sbcc_write_test'));
    try {
      await probe.writeAsString('x');
      await probe.delete();
    } catch (_) {
      throw SelfUpdateException(
        'No write permission in "${dir.path}". '
        'Move the app to a folder you own (not Program Files) and try again.',
      );
    }
  }

  static Future<void> _extractZip(
    File zip,
    Directory dest,
    SelfUpdateProgress? onProgress,
  ) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(await zip.readAsBytes());
    } catch (e) {
      throw SelfUpdateException('The file is not a valid .zip archive ($e).');
    }

    final root = p.normalize(dest.absolute.path);
    final entries = archive.files.where((f) => f.isFile).toList();
    for (var i = 0; i < entries.length; i++) {
      final f = entries[i];
      final name = f.name.replaceAll('\\', '/');
      final outPath = p.normalize(p.join(root, name));
      // Protección contra rutas maliciosas ("../")
      if (!p.isWithin(root, outPath)) continue;

      final out = File(outPath);
      await out.parent.create(recursive: true);
      await out.writeAsBytes(f.content as List<int>, flush: false);

      if (i % 10 == 0 || i == entries.length - 1) {
        onProgress?.call(
          SelfUpdateStage.extracting,
          (i + 1) / entries.length,
        );
        await Future<void>.delayed(Duration.zero); // deja respirar a la UI
      }
    }
  }

  /// Busca (hasta 3 niveles) la carpeta que contiene [exe].
  static Future<Directory?> _findPayloadDir(Directory root, String exe) async {
    final target = exe.toLowerCase();

    Future<Directory?> walk(Directory dir, int depth) async {
      final children = await dir.list(followLinks: false).toList();
      for (final c in children) {
        if (c is File && p.basename(c.path).toLowerCase() == target) {
          return dir;
        }
      }
      if (depth >= 3) return null;
      for (final c in children) {
        if (c is Directory) {
          final found = await walk(c, depth + 1);
          if (found != null) return found;
        }
      }
      return null;
    }

    return walk(root, 0);
  }
}