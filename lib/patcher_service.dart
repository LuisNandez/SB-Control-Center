// Reparación de conflictos entre mods (archivos .utoc/.ucas de IoStore).
//
// Qué hace:
//  1. Detecta mods con el mismo Container ID (el motor solo monta uno; el
//     otro no aparece en la interfaz de CNS).
//  2. Los repara cambiando el ID de forma CONSISTENTE: encabezado del .utoc,
//     tabla de chunks del .utoc y ContainerHeader dentro del .ucas.
//  3. Si no es seguro parchear (cifrado, comprimido, formato raro) NO toca
//     nada y lo reporta. Un parche a medias hace crashear el juego.
//  4. Informa de los Package IDs compartidos (mods que sobrescriben los
//     mismos assets) sin modificar nada.
//
// Garantías de seguridad:
//  - Todo se valida antes de escribir; se escribe en archivos temporales y
//    se verifica el resultado antes de reemplazar los originales.
//  - Los originales se conservan como *.cnsbak (ver [restoreOriginals]).
//  - Nunca se carga un .ucas completo en memoria (pueden pesar GBs).

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'l10n/app_localizations.dart';
import 'services/iostore_toc.dart';

enum LogEntryType { normal, success, error, info }

class LogEntry {
  final String text;
  final LogEntryType type;
  LogEntry(this.text, [this.type = LogEntryType.normal]);
}

/// Un conflicto de Container ID que NO se pudo reparar de forma segura.
class UnresolvedContainerConflict {
  final String mod;
  final String conflictsWith;
  final String reason;
  const UnresolvedContainerConflict(this.mod, this.conflictsWith, this.reason);
}

class PatcherResult {
  /// Log completo para depuración.
  final List<LogEntry> logEntries;

  /// Cuántos mods tuvieron su Container ID reparado.
  final int containerIdsFixed;

  /// Package ID -> mods que lo comparten (solo los que tienen 2 o más).
  final Map<int, List<String>> packageIdConflicts;

  /// Conflictos de Container ID que se dejaron intactos por seguridad.
  final List<UnresolvedContainerConflict> unresolvedContainerConflicts;

  PatcherResult({
    required this.logEntries,
    required this.containerIdsFixed,
    required this.packageIdConflicts,
    this.unresolvedContainerConflicts = const [],
  });
}

class _Patch {
  final int offset;
  final Uint8List bytes;
  const _Patch(this.offset, this.bytes);
}

class _Swap {
  final File target;
  final File temp;
  const _Swap(this.target, this.temp);
}

class PatcherService {
  static const String _backupExt = '.cnsbak';
  static const String _tempExt = '.cnspatch';
  static const int _copyBufferSize = 4 * 1024 * 1024;

  final AppLocalizations l10n;
  final List<LogEntry> _log = [];

  PatcherService(this.l10n);

  void _add(String text, [LogEntryType type = LogEntryType.normal]) =>
      _log.add(LogEntry(text, type));

  /// Punto de entrada.
  ///
  /// [reservedDirectories]: carpetas cuyos .utoc se consideran "ya ocupados"
  /// (juego base `Paks/` y `LogicMods/`, donde vive el núcleo de CNS). Se
  /// escanean SIN recursión y nunca se modifican: si un mod choca con ellos,
  /// el que se repara es el mod.
  Future<PatcherResult> patchConflictsInDirectory(
    String modsDirectoryPath, {
    List<String> reservedDirectories = const [],
  }) async {
    _log.clear();
    try {
      return await _run(modsDirectoryPath, reservedDirectories);
    } catch (e, s) {
      _add(l10n.fatalErrorTitle, LogEntryType.error);
      _add(e.toString(), LogEntryType.error);
      _add(s.toString(), LogEntryType.error);
      print(l10n.patcherServiceError(e.toString()));
      return PatcherResult(
        logEntries: _log,
        containerIdsFixed: 0,
        packageIdConflicts: {},
      );
    }
  }

  Future<PatcherResult> _run(
      String modsDirectoryPath, List<String> reservedDirectories) async {
    _add(l10n.patcherStarted);
    _add(l10n.workingDirectory(modsDirectoryPath));

    final root = Directory(modsDirectoryPath);
    if (!await root.exists()) {
      throw Exception(l10n.modsDirNotFound(modsDirectoryPath));
    }

    final utocFiles = await _findUtocFiles(root, recursive: true);
    _add(l10n.foundUtocFiles(utocFiles.length));
    if (utocFiles.isEmpty) {
      _add(l10n.noModsFound2);
      return PatcherResult(
          logEntries: _log, containerIdsFixed: 0, packageIdConflicts: {});
    }

    // IDs ya ocupados -> quién los tiene. El primero en reclamarlo se queda
    // con él; los reservados (juego/LogicMods) siempre van primero.
    final Map<int, String> claimed = {};
    await _registerReserved(reservedDirectories, claimed);

    final Map<int, List<String>> packageOwners = {};
    final unresolved = <UnresolvedContainerConflict>[];
    var fixed = 0;

    // Orden determinista (por ruta) => el mismo resultado en cada ejecución.
    for (final utoc in utocFiles) {
      final rel = p.relative(utoc.path, from: modsDirectoryPath);
      _add(l10n.analyzingFile(rel));

      try {
        final toc = IoStoreToc.parse(await utoc.readAsBytes());

        for (final id in toc.packageIds()) {
          (packageOwners[id] ??= <String>[]).add(rel);
        }

        final owner = claimed[toc.containerId];
        if (owner == null) {
          claimed[toc.containerId] = rel;
          _add(l10n.idRegisteredNoConflict(toc.containerId),
              LogEntryType.success);
          continue;
        }

        _add(l10n.patcherSharedWith(owner), LogEntryType.error);
        final oldId = toc.containerId;
        final newId = _pickNewId(rel, claimed);

        try {
          await _patchContainer(utoc, toc, newId);
          claimed[newId] = rel;
          fixed++;
          _add(l10n.patcherIdChange(_hex(oldId), _hex(newId)),
              LogEntryType.info);
          _add(l10n.patcherBackupSaved, LogEntryType.info);
          _add(l10n.patchComplete, LogEntryType.success);
        } on IoStoreException catch (e) {
          // No es seguro parchear: dejamos el mod EXACTAMENTE como estaba.
          unresolved.add(UnresolvedContainerConflict(rel, owner, e.message));
          _add(l10n.patcherLeftUntouched(e.message), LogEntryType.error);
        }
      } on IoStoreException catch (e) {
        _add(l10n.errorProcessingFile(rel, e.message), LogEntryType.error);
      } catch (e, s) {
        _add(l10n.errorProcessingFile(rel, e.toString()), LogEntryType.error);
        _add(s.toString(), LogEntryType.error);
      }
    }

    final packageConflicts = <int, List<String>>{
      for (final e in packageOwners.entries)
        if (e.value.length > 1) e.key: e.value,
    };

    _add(l10n.patcherSummaryTitle);
    _add(l10n.processedMods(utocFiles.length));
    _add(l10n.fixedContainerIdConflicts(fixed));
    _add(l10n.foundPackageIdConflicts(packageConflicts.length));

    return PatcherResult(
      logEntries: _log,
      containerIdsFixed: fixed,
      packageIdConflicts: packageConflicts,
      unresolvedContainerConflicts: unresolved,
    );
  }

  // ------------------------------------------------------------- utilidades

  Future<List<File>> _findUtocFiles(Directory root,
      {required bool recursive}) async {
    final result = <File>[];
    final pending = <Directory>[root];
    while (pending.isNotEmpty) {
      final dir = pending.removeLast();
      try {
        await for (final e in dir.list(followLinks: false)) {
          if (e is File && e.path.toLowerCase().endsWith('.utoc')) {
            result.add(e);
          } else if (recursive && e is Directory) {
            pending.add(e);
          }
        }
      } catch (e) {
        _add(l10n.warnCannotScanFolder(dir.path), LogEntryType.error);
        _add(l10n.errorDetails(e.toString()), LogEntryType.error);
      }
    }
    result.sort(
        (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    return result;
  }

  Future<void> _registerReserved(
      List<String> dirs, Map<int, String> claimed) async {
    for (final path in dirs) {
      final dir = Directory(path);
      if (!await dir.exists()) continue;
      for (final f in await _findUtocFiles(dir, recursive: false)) {
        try {
          final head = await _readRange(f, 0, IoStoreToc.minHeaderSize);
          claimed.putIfAbsent(
              IoStoreToc.peekContainerId(head), () => p.basename(f.path));
        } catch (_) {
          // Un .utoc ilegible del juego no debe impedir la reparación.
        }
      }
    }
  }

  /// ID nuevo DETERMINISTA (hash FNV-1a 64 de la ruta relativa): ejecutar el
  /// parcheador dos veces da el mismo resultado y no necesita aleatoriedad.
  int _pickNewId(String key, Map<int, String> claimed) {
    var h = -3750763034362895579; // 0xcbf29ce484222325 (FNV offset basis)
    for (final c in key.toLowerCase().codeUnits) {
      h ^= c;
      h *= 1099511628211; // FNV prime
    }
    // 0 y ~0 no son IDs válidos en UE.
    while (h == 0 || h == -1 || claimed.containsKey(h)) {
      h += 1;
    }
    return h;
  }

  static String _hex(int id) {
    final hi = ((id >> 32) & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
    final lo = (id & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
    return '0x$hi$lo';
  }

  Uint8List _idBytes(int id) =>
      (ByteData(8)..setUint64(0, id, Endian.little)).buffer.asUint8List();

  /// Offsets (dentro de [data]) donde aparece [id] como u64 little-endian.
  List<int> _findIdOffsets(Uint8List data, int id) {
    final needle = _idBytes(id);
    final hits = <int>[];
    var i = 0;
    while (i <= data.length - 8) {
      var match = true;
      for (var j = 0; j < 8; j++) {
        if (data[i + j] != needle[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        hits.add(i);
        i += 8;
      } else {
        i++;
      }
    }
    return hits;
  }

  Future<Uint8List> _readRange(File file, int offset, int length) async {
    final raf = await file.open();
    try {
      await raf.setPosition(offset);
      final data = await raf.read(length);
      if (data.length != length) {
        throw const IoStoreException('Unexpected end of file while reading.');
      }
      return data;
    } finally {
      await raf.close();
    }
  }

  // ----------------------------------------------------------------- parche

  /// Repara el Container ID de [utoc] (ya parseado en [toc]).
  /// Lanza [IoStoreException] si no es seguro => no se escribe NADA.
  Future<void> _patchContainer(File utoc, IoStoreToc toc, int newId) async {
    final ucas = File(p.setExtension(utoc.path, '.ucas'));
    if (!await ucas.exists()) {
      throw const IoStoreException('The matching .ucas file is missing.');
    }

    final oldId = toc.containerId;
    final loc = toc.locateContainerHeader(); // valida antes de tocar nada
    final ucasLength = await ucas.length();
    if (loc.ucasOffset + loc.windowLength > ucasLength) {
      throw const IoStoreException(
          'The ContainerHeader lies outside the .ucas (truncated file?).');
    }

    // Si el ID viejo no está EXACTAMENTE donde esperamos, nuestra lectura del
    // formato es incorrecta para este archivo: no adivinamos.
    final window = await _readRange(ucas, loc.ucasOffset, loc.windowLength);
    final hits = _findIdOffsets(window, oldId);
    if (hits.isEmpty) {
      throw const IoStoreException(
          'Old Container ID not found in the ContainerHeader; refusing to guess.');
    }
    final newBytes = _idBytes(newId);
    final patches = [for (final h in hits) _Patch(loc.ucasOffset + h, newBytes)];
    _add(l10n.ucasReplacementsSuccess(hits.length), LogEntryType.info);

    toc.replaceContainerId(newId);

    final tmpToc = File('${utoc.path}$_tempExt');
    final tmpUcas = File('${ucas.path}$_tempExt');
    try {
      await tmpToc.writeAsBytes(toc.toBytes(), flush: true);
      await _copyWithPatches(ucas, tmpUcas, patches);

      // Verificación previa al reemplazo.
      if (await tmpUcas.length() != ucasLength) {
        throw const IoStoreException('Patched .ucas has a different size.');
      }
      final check = await _readRange(tmpUcas, loc.ucasOffset, loc.windowLength);
      if (_findIdOffsets(check, newId).length != hits.length ||
          _findIdOffsets(check, oldId).isNotEmpty) {
        throw const IoStoreException('Patched .ucas failed verification.');
      }
      final recheck = IoStoreToc.parse(await tmpToc.readAsBytes());
      if (recheck.containerId != newId ||
          recheck.findContainerHeaderChunk() == null) {
        throw const IoStoreException('Patched .utoc failed verification.');
      }

      await _swapIn([_Swap(ucas, tmpUcas), _Swap(utoc, tmpToc)]);
      _add(l10n.utocFilePatched, LogEntryType.info);
    } catch (_) {
      for (final t in [tmpToc, tmpUcas]) {
        try {
          if (await t.exists()) await t.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// Copia [src] -> [dst] por bloques aplicando [patches]; sin cargar el
  /// archivo completo en memoria.
  Future<void> _copyWithPatches(
      File src, File dst, List<_Patch> patches) async {
    final reader = await src.open();
    final writer = await dst.open(mode: FileMode.write);
    try {
      final total = await reader.length();
      var pos = 0;
      while (pos < total) {
        final buf =
            await reader.read(math.min(_copyBufferSize, total - pos));
        if (buf.isEmpty) break;
        final end = pos + buf.length;
        for (final patch in patches) {
          final pStart = patch.offset;
          final pEnd = pStart + patch.bytes.length;
          if (pEnd <= pos || pStart >= end) continue;
          final from = math.max(pStart, pos);
          final to = math.min(pEnd, end);
          for (var k = from; k < to; k++) {
            buf[k - pos] = patch.bytes[k - pStart];
          }
        }
        await writer.writeFrom(buf);
        pos = end;
      }
      await writer.flush();
    } finally {
      await reader.close();
      await writer.close();
    }
  }

  /// Reemplaza los originales por los temporales conservando una copia
  /// (.cnsbak). Si algo falla, deshace lo ya hecho.
  Future<void> _swapIn(List<_Swap> swaps) async {
    final undo = <Future<void> Function()>[];
    try {
      for (final s in swaps) {
        final bak = File('${s.target.path}$_backupExt');
        // Si ya hay backup, es el original verdadero de un parche anterior:
        // no lo sobrescribimos.
        if (!await bak.exists()) {
          await s.target.rename(bak.path);
          undo.add(() async {
            await File(bak.path).rename(s.target.path);
          });
        }
        await s.temp.rename(s.target.path);
        undo.add(() async {
          await s.target.delete();
        });
      }
    } catch (_) {
      for (final u in undo.reversed) {
        try {
          await u();
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// Restaura los archivos originales guardados como *.cnsbak.
  /// Devuelve cuántos archivos se restauraron.
  static Future<int> restoreOriginals(String modsDirectoryPath) async {
    final root = Directory(modsDirectoryPath);
    if (!await root.exists()) return 0;
    var restored = 0;
    await for (final e in root.list(recursive: true, followLinks: false)) {
      if (e is File && e.path.endsWith(_backupExt)) {
        final target = e.path.substring(0, e.path.length - _backupExt.length);
        try {
          final t = File(target);
          if (await t.exists()) await t.delete();
          await e.rename(target);
          restored++;
        } catch (_) {
          // Archivo en uso (juego abierto) u otro error: se deja el .cnsbak.
        }
      }
    }
    return restored;
  }
}