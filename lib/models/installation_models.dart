import 'dart:io';
import '../mod_classifier_service.dart';
import '../services/nexus_file_identifier.dart';

class PreparedMod {
  final Directory sourceDir;
  final Directory? ue4ssDir;
  final Directory? tildeModsDir;
  final String? nexusId;
  final String? nexusVersion;
  final String archiveName;
  final ModDirectoryType modType;

  /// Identidad del archivo descargado en Nexus (mod, archivo, nombre y
  /// versión oficiales). Null si no se pudo reconocer el archivo.
  final NexusFileIdentity? identity;

  /// false cuando el mismo archivo contiene varios mods independientes; en ese
  /// caso el nombre del archivo no sirve para distinguirlos.
  bool soleModInArchive;

  /// Carpeta temporal donde se extrajo el archivo comprimido del que sale este
  /// mod. Solo se rellena cuando el archivo trae varias subcarpetas/variantes;
  /// sirve para saber qué mods vienen del MISMO archivo.
  final String? archiveKey;

  /// Nombre de la subcarpeta (variante) dentro del archivo, p. ej. "Red" o
  /// "Option B/No skirt". Null si el archivo solo trae un mod.
  final String? variantLabel;

  PreparedMod({
    required this.sourceDir,
    this.ue4ssDir,
    this.tildeModsDir,
    this.nexusId,
    this.nexusVersion,
    required this.archiveName,
    required this.modType,
    this.identity,
    this.soleModInArchive = true,
    this.archiveKey,
    this.variantLabel,
  });

  /// Copia del mod cambiando solo el nombre (se usa para que dos variantes del
  /// mismo archivo no acaben en la misma carpeta y se sobrescriban).
  PreparedMod withArchiveName(String newName) => PreparedMod(
        sourceDir: sourceDir,
        ue4ssDir: ue4ssDir,
        tildeModsDir: tildeModsDir,
        nexusId: nexusId,
        nexusVersion: nexusVersion,
        archiveName: newName,
        modType: modType,
        identity: identity,
        soleModInArchive: soleModInArchive,
        archiveKey: archiveKey,
        variantLabel: variantLabel,
      );

  /// Nombre oficial de Nexus cuando se conoce y es seguro usarlo para este
  /// mod; null en caso contrario. Incluye el nombre del mod Y el de la
  /// edición (archivo), p. ej. "Alt Goth Mini Set - CNS compatible", para que
  /// dos mods con una edición del mismo nombre no se confundan.
  String? get preferredDisplayName {
    final name = identity?.fullName;
    if (name == null || name.isEmpty || !soleModInArchive) return null;
    return name;
  }

  /// Nombre de la edición (el archivo dentro del mod en Nexus), p. ej.
  /// "CNS compatible". Null si no se reconoció el archivo.
  String? get editionName {
    final name = identity?.editionName;
    if (name == null || name.isEmpty) return null;
    return name;
  }

  /// Nombre del mod en Nexus (null si no se pudo consultar).
  String? get nexusModName => identity?.modName;
}

class PreparedUE4SS {
  final Directory sourceDir;
  PreparedUE4SS({required this.sourceDir});
}

class ArchiveProcessingResult {
  final List<PreparedMod> preparedMods;
  final PreparedUE4SS? preparedUE4SS;
  final Directory? cnsUpdateDir;

  ArchiveProcessingResult({
    required this.preparedMods,
    this.preparedUE4SS,
    this.cnsUpdateDir,
  });
}