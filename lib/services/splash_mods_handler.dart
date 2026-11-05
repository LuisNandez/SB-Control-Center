import 'dart:io';
import 'package:path/path.dart' as p;

class SplashImageOption {
  final File file;
  final String name;
  bool isSelected;

  SplashImageOption({required this.file, required this.name, this.isSelected = true});
}

class SplashFolderOption {
  final String folderName;
  final List<SplashImageOption> images;

  SplashFolderOption({required this.folderName, required this.images});

  bool get isAllSelected => images.isNotEmpty && images.every((img) => img.isSelected);
  bool get isAnySelected => images.any((img) => img.isSelected);

  void toggleAll(bool? value) {
    final val = value ?? false;
    for (var img in images) {
      img.isSelected = val;
    }
  }
}

class SplashSelectionData {
  final List<SplashFolderOption> folders;
  SplashSelectionData(this.folders);

  // Considera que hay múltiples opciones si hay más de 1 imagen en total
  bool get hasMultipleOptions {
    int totalImages = folders.fold(0, (sum, folder) => sum + folder.images.length);
    return totalImages > 1 || folders.length > 1;
  }

  bool get hasSelection => folders.any((f) => f.isAnySelected);
}

class SplashModsHandler {
  /// Clave interna del grupo "carpeta raíz" (su texto visible es l10n.splashRootFolder).
  static const String rootFolderKey = '<root>';

  static Future<SplashSelectionData> parseSplashMod(Directory sourceDir) async {
    Map<String, List<SplashImageOption>> grouped = {};

    await for (final entity in sourceDir.list(recursive: true)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (['.bmp', '.jpg', '.jpeg', '.png', '.bat'].contains(ext)) {
          final relativeDir = p.dirname(p.relative(entity.path, from: sourceDir.path));
          final folderName = relativeDir == '.' ? rootFolderKey : relativeDir.replaceAll(Platform.pathSeparator, ' / ');

          if (!grouped.containsKey(folderName)) {
            grouped[folderName] = [];
          }
          grouped[folderName]!.add(SplashImageOption(
            file: entity,
            name: p.basename(entity.path),
          ));
        }
      }
    }

    // Ordenar imágenes y carpetas alfabéticamente
    for (var list in grouped.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    final sortedKeys = grouped.keys.toList()..sort();
    final folders = sortedKeys.map((key) => SplashFolderOption(folderName: key, images: grouped[key]!)).toList();

    return SplashSelectionData(folders);
  }

  // Copia lo seleccionado a un entorno plano (Ideal para que el Randomizer lo detecte todo)
  static Future<Directory> buildSelectedInstallation(SplashSelectionData data, Directory tempRoot) async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
    await tempRoot.create(recursive: true);

    for (final folder in data.folders) {
      for (final img in folder.images) {
        if (img.isSelected) {
          String finalName = img.name;
          // Prevenimos colisión de nombres (ej: 2k/splash1.jpg y 4k/splash1.jpg)
          if (folder.folderName != rootFolderKey && p.extension(img.name).toLowerCase() != '.bat') {
             final prefix = folder.folderName.replaceAll(' / ', '_').replaceAll(' ', '');
             finalName = '${prefix}_${img.name}';
          }
          final destPath = p.join(tempRoot.path, finalName);
          await img.file.copy(destPath);
        }
      }
    }
    return tempRoot;
  }
  /// Obtiene el siguiente índice numérico disponible para evitar sobreescribir imágenes
  /// en la carpeta SplashImages del Mod 801.
  static Future<int> getNextAvailableIndex(Directory imagesDir) async {
    if (!await imagesDir.exists()) return 0;

    Set<int> usedIndices = {};
    final regex = RegExp(r'^splash_(\d+)\.(bmp|jpg|png|jpeg)$', caseSensitive: false);

    await for (final entity in imagesDir.list()) {
      final match = regex.firstMatch(p.basename(entity.path));
      if (match != null) {
        usedIndices.add(int.parse(match.group(1)!));
      }
    }

    int index = 0;
    while (usedIndices.contains(index)) {
      index++;
    }
    return index;
  }

  /// Procesa los archivos según la política clásica (Sin el Mod 801)
  /// Retorna un mapa indicando {RutaOrigen: NombreFinalDeseado}
  static Map<File, String> mapFilesForClassicReplacement(List<File> sourceFiles) {
    Map<File, String> mappings = {};
    
    // Filtramos solo imágenes
    final imageFiles = sourceFiles.where((f) {
      final ext = p.extension(f.path).toLowerCase();
      return ['.bmp', '.jpg', '.jpeg', '.png'].contains(ext);
    }).toList();
    
    if (imageFiles.isEmpty) return mappings;

    // En el modo clásico, el juego suele leer splash.bmp (o el formato que traiga el mod original)
    // Tomamos la primera imagen que encontremos y forzamos su nombre para reemplazar la principal.
    final File targetImage = imageFiles.first;
    final ext = p.extension(targetImage.path).toLowerCase();
    
    // Renombramos la imagen principal a splash con su extensión original
    mappings[targetImage] = 'splash$ext';

    return mappings;
  }
}