import 'dart:io';
import 'package:flutter/material.dart';

// Data class to hold all information about a mod.
class ModInfo {
  final Directory directory;
  final String? nexusId;
  String? localVersion;
  final DateTime lastModified;
  final DateTime? installDate;
  bool isEnabled;
  final String? origin;
  final String displayName;
  String customName;
  final List<dynamic>? gallery;
  final String? fitMeshType;
  final String? modType;
  final String? customCoverPath;
  final Alignment? customCoverAlignment;
  final DateTime? customCoverLastModified;
  final String? customVersion;
  final String? customFitMeshType;
  String? summary;
  String? description;
  final String? customSummary;
  final String? customDescription;
  final String? author;
  final String? customAuthor;
  String? userNotes;
  final String? sourceUrl;
  final String? customSourceUrl;
  final List<String>? replacesOutfits;

  /// Nombre del MOD en Nexus (p. ej. "Alt Goth Mini Set"). Null en mods
  /// instalados antes de que la app distinguiera ediciones.
  final String? modName;

  /// Nombre de la EDICIÓN dentro del mod (el archivo de Nexus, p. ej.
  /// "CNS compatible"). Un mismo mod puede tener varias ediciones instaladas.
  final String? editionName;

  ModInfo({
    required this.directory,
    this.nexusId,
    this.localVersion,
    required this.lastModified,
    this.installDate,
    required this.isEnabled,
    this.origin,
    required this.displayName,
    required this.customName,
    this.gallery,
    this.fitMeshType,
    this.modType,
    this.customCoverPath,
    this.customCoverAlignment,
    this.customCoverLastModified,
    this.customVersion,
    this.customFitMeshType,
    this.summary,
    this.customSummary,
    this.description,
    this.customDescription,
    this.author,
    this.customAuthor,
    this.userNotes,
    this.sourceUrl,
    this.customSourceUrl,
    this.replacesOutfits,
    this.modName,
    this.editionName,
  });

  /// Tipo para MOSTRAR y FILTRAR. Un mod `logicMod` cuyos .pak/.utoc/.ucas
  /// viven en ~mods (sin blueprint en LogicMods; solo lo acompañan scripts
  /// UE4SS) se instala con el tipo interno `logicMod` -para que activar,
  /// desactivar y borrar muevan todas sus partes-, pero se marca con
  /// fitMeshType "Generic" y aquí se presenta como genérico.
  /// No usar para decidir rutas de instalación: para eso sigue siendo
  /// [modType].
  String? get displayType =>
      (modType == 'logicMod' && fitMeshType == 'Generic')
          ? 'genericPak'
          : modType;

  ModInfo copyWith({
    Directory? directory,
    String? nexusId,
    String? localVersion,
    DateTime? lastModified,
    DateTime? installDate,
    bool? isEnabled,
    String? origin,
    String? displayName,
    String? customName,
    List<dynamic>? gallery,
    String? fitMeshType,
    String? modType,
    String? customCoverPath,
    Alignment? customCoverAlignment,
    DateTime? customCoverLastModified,
    String? customVersion,
    String? customFitMeshType,
    String? summary,
    String? customSummary,
    String? description,
    String? customDescription,
    String? author,
    String? customAuthor,
    String? userNotes,
    String? sourceUrl,
    String? customSourceUrl,
    List<String>? replacesOutfits,
    String? modName,
    String? editionName,
  }) {
    return ModInfo(
      directory: directory ?? this.directory,
      nexusId: nexusId ?? this.nexusId,
      localVersion: localVersion ?? this.localVersion,
      lastModified: lastModified ?? this.lastModified,
      installDate: installDate ?? this.installDate,
      isEnabled: isEnabled ?? this.isEnabled,
      origin: origin ?? this.origin,
      displayName: displayName ?? this.displayName,
      customName: customName ?? this.customName,
      gallery: gallery ?? this.gallery,
      fitMeshType: fitMeshType ?? this.fitMeshType,
      modType: modType ?? this.modType,
      customCoverPath: customCoverPath ?? this.customCoverPath,
      customCoverAlignment: customCoverAlignment ?? this.customCoverAlignment,
      customCoverLastModified:
          customCoverLastModified ?? this.customCoverLastModified,
      customVersion: customVersion ?? this.customVersion,
      customFitMeshType: customFitMeshType ?? this.customFitMeshType,
      summary: summary ?? this.summary,
      customSummary: customSummary ?? this.customSummary,
      description: description ?? this.description,
      customDescription: customDescription ?? this.customDescription,
      author: author ?? this.author,
      customAuthor: customAuthor ?? this.customAuthor,
      userNotes: userNotes ?? this.userNotes,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      customSourceUrl: customSourceUrl ?? this.customSourceUrl,
      replacesOutfits: replacesOutfits ?? this.replacesOutfits,
      modName: modName ?? this.modName,
      editionName: editionName ?? this.editionName,
    );
  }

  static String? extractVersionFromName(String name) {
    final regex = RegExp(r'\b[vV][\s-]?([0-9]+(\.[0-9a-zA-Z]+)*)');
    final match = regex.firstMatch(name);
    return match?.group(1);
  }
}