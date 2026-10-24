import 'dart:io';
import 'package:path/path.dart' as p;

class FileManagerService {
  /// Prefijos de las carpetas temporales que crea la app en %TEMP%.
  static const List<String> tempDirPrefixes = [
    'mod_manager_',
    'mod_special_',
    'mod_movie_',
    'mod_splash_selected_',
  ];

  /// Borra una carpeta aunque Windows se resista.
  ///
  /// La causa más común de "Access denied" es que haya archivos con el
  /// atributo de solo lectura (vienen de archivos comprimidos o de copias de
  /// archivos de solo lectura): `Directory.delete` falla con ellos. Al primer
  /// fallo se les quita el atributo y se reintenta (con espera creciente por si
  /// además hay un antivirus o el Explorador usando los archivos). Como último
  /// recurso se borra archivo por archivo.
  static Future<bool> deleteDirectoryWithRetry(Directory dir, {int retries = 4}) async {
    for (int i = 0; i < retries; i++) {
      try {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
        return true;
      } on FileSystemException {
        // Puede que ya no exista (borrado a medias o por otro proceso).
        if (!await dir.exists()) return true;
        print('Access denied while deleting ${dir.path}. Retrying (${i + 1}/$retries)...');
        await _clearReadOnly(dir);
        await Future.delayed(Duration(milliseconds: 300 * (i + 1)));
      }
    }

    // Último recurso: archivo por archivo, ignorando los que sigan bloqueados.
    await _deleteBestEffort(dir);
    if (!await dir.exists()) return true;
    print('Could not delete directory ${dir.path} after $retries attempts.');
    return false;
  }

  /// Quita el atributo de solo lectura de todo el contenido (solo Windows).
  static Future<void> _clearReadOnly(Directory dir) async {
    if (!Platform.isWindows) return;
    try {
      await Process.run('attrib', ['-R', '${dir.path}\\*', '/S', '/D']);
      await Process.run('attrib', ['-R', dir.path, '/D']);
    } catch (e) {
      print('Could not clear read-only attributes in ${dir.path}: $e');
    }
  }

  static Future<void> _deleteBestEffort(Directory dir) async {
    try {
      if (!await dir.exists()) return;
      await _clearReadOnly(dir);
      await for (final e in dir.list(recursive: true, followLinks: false)) {
        if (e is File) {
          try {
            await e.delete();
          } catch (_) {}
        }
      }
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
    } catch (_) {}
  }

  /// Borra las carpetas temporales de la app que hayan quedado en %TEMP%
  /// (instalaciones interrumpidas, selecciones de mods especiales/películas/
  /// splash, etc.).
  static Future<void> cleanOrphanedTempDirs() async {
    try {
      await for (final entity in Directory.systemTemp.list(followLinks: false)) {
        if (entity is! Directory) continue;
        final name = p.basename(entity.path);
        if (!tempDirPrefixes.any(name.startsWith)) continue;
        try {
          await deleteDirectoryWithRetry(entity);
        } catch (e) {
          print('Could not delete orphan directory ${entity.path}: $e');
        }
      }
    } catch (e) {
      print('An error occurred during general cleanup of temporary folders: $e');
    }
  }

  static Future<void> copyDirectory(Directory source, Directory destination) async {
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        var newDirectory = Directory(
          p.join(destination.absolute.path, p.basename(entity.path)),
        );
        await newDirectory.create();
        await copyDirectory(entity.absolute, newDirectory.absolute);
      } else if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }

  static Future<void> moveMod(Directory modDir, String toPath) async {
    final modName = p.basename(modDir.path);
    final destinationPath = p.join(toPath, modName);
    await modDir.rename(destinationPath);
  }

  static Future<List<File>> findAllModFilesRecursive(Directory dir) async {
    final List<File> foundFiles = [];
    const validExtensions = ['.json', '.pak', '.ucas', '.utoc', '.bk2', '.webm', '.lua', '.txt'];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && validExtensions.contains(p.extension(entity.path).toLowerCase())) {
        foundFiles.add(entity);
      }
    }
    return foundFiles;
  }

  static Future<void> cleanOldCustomCovers(Directory dir) async {
    try {
      if (!await dir.exists()) return;
      
      await for (final entity in dir.list(recursive: false)) {
        if (entity is File) {
          final filename = p.basename(entity.path).toLowerCase();
          // Elimina cualquier archivo que empiece con '_custom_cover.' 
          // (cubre .jpg, .png, .webp, etc.)
          if (filename.startsWith('_custom_cover.')) {
            await entity.delete();
            print('🗑️ Portada anterior eliminada: ${entity.path}');
          }
        }
      }
    } catch (e) {
      print('Error al limpiar portadas antiguas: $e');
    }
  }
}