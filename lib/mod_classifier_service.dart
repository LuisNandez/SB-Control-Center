import 'dart:io';
import 'package:path/path.dart' as p;
import 'services/config_mod_detector.dart';
import 'services/logic_mod_detector.dart';

enum ModDirectoryType {
  cns,
  genericPak,
  movies,
  logicMod,
  save,       // <-- NUEVO
  config,     // <-- NUEVO
  splash,     // <-- NUEVO
  unknown
}

class ModClassifierService {
  static Future<ModDirectoryType> classifyModDirectory(Directory modDir) async {
    bool hasJson = false;
    bool hasCnsJson = false;
    bool hasPakFile = false;
    bool hasMovieFile = false; // Cambiado para abarcar .bk2 y .webm
    bool hasSaveFile = false;   // <-- NUEVO
    bool hasConfigFile = false; // <-- NUEVO
    bool hasSplashFile = false; // <-- NUEVO
    final List<File> configCandidates = [];

    await for (final entity in modDir.list(recursive: false, followLinks: false)) {
      if (entity is File) {
        final extension = p.extension(entity.path).toLowerCase();
        final basename = p.basename(entity.path).toLowerCase();

        if (extension == '.json') {
          hasJson = true;
          if (basename.endsWith('.dekcns.json')) hasCnsJson = true;
        } else if (extension == '.pak' || extension == '.ucas' || extension == '.utoc') {
          hasPakFile = true;
        } else if (extension == '.bk2' || extension == '.webm') {
          hasMovieFile = true; // Ahora detecta ambos formatos
        } else if (extension == '.sav') {
          hasSaveFile = true; // <-- NUEVO
        } else if (ConfigModDetector.isConfigFileName(basename)) {
          configCandidates.add(entity); // se valida abajo (que sea texto)
        } else if (basename == 'splash.bmp' || extension == '.bat' || (['.bmp', '.jpg', '.jpeg', '.png'].contains(extension) && entity.path.toLowerCase().contains('splash'))) {
          hasSplashFile = true; // <-- AHORA DETECTA IMÁGENES DENTRO DE CARPETAS "SPLASH"
        }
      }
    }

    // LOGIC: se decide leyendo el ÍNDICE del .utoc/.pak (no por el nombre ni
    // por la carpeta). Un mod con ModActor / Content/Mods es un blueprint de
    // UE4SS aunque solo traiga los 3 archivos y aunque venga con un .json de
    // configuración (que antes lo hacía pasar por CNS).
    //   - ModActor                         -> logicMod
    //   - solo Content/Mods (sin ModActor) -> logicMod (como siempre: aquí no
    //     hay más contexto; si el archivo trae scripts UE4SS ya lo habrá
    //     resuelto LogicModStager antes de llegar aquí)
    //   - reemplaza assets del juego, aunque también lleve Content/Mods
    //     (híbrido)                        -> sigue como CNS / genérico
    if (hasPakFile) {
      final verdict = await LogicModDetector.classifyPackagesIn(modDir);
      if (verdict.isLogicLike) return ModDirectoryType.logicMod;
    }

    // CNS: un .dekcns.json es inequívoco. Un .json cualquiera junto a paks se
    // sigue tratando como CNS (comportamiento anterior).
    if (hasCnsJson && hasPakFile) return ModDirectoryType.cns;
    if (hasJson && hasPakFile) return ModDirectoryType.cns;
    if (!hasJson && hasPakFile) return ModDirectoryType.genericPak;

    // CONFIG: .ini del juego que sean texto de verdad.
    for (final f in configCandidates) {
      if (await ConfigModDetector.isValidIni(f)) {
        hasConfigFile = true;
        break;
      }
    }

    // Si tiene archivos de vídeo y no tiene paks ni json, es de películas
    if (hasMovieFile && !hasJson && !hasPakFile) return ModDirectoryType.movies;
    if (hasSaveFile) return ModDirectoryType.save;     // <-- NUEVO
    if (hasConfigFile) return ModDirectoryType.config; // <-- NUEVO
    if (hasSplashFile) return ModDirectoryType.splash; // <-- NUEVO

    return ModDirectoryType.unknown;
  }
}