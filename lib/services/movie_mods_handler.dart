import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'special_mods_handler.dart';

// =============================================================================
//  MOVIES (.bk2 / .webm)
//
//  Esquema general:
//   * Carpeta del juego:   <juego>/SB/Content/Movies          (+ /Menu para Mod 529)
//   * Respaldos originales: <juego>/SB/Content/__MOVIES_ORIGINALS__/<ruta>.bak
//   * Cada mod conserva su estructura relativa a "Movies" dentro de su carpeta
//     (ya no se "aplana" todo) y guarda en su nexus_info.json:
//         replacedFiles : archivos que trae el mod (ruta relativa a Movies)
//         movieInstall  : lo que REALMENTE se aplicó en el juego al activarlo
//                         (ruta destino, acción replace/add/menu, tamaño)
//
//  Reglas:
//   * Un archivo con el nombre de uno original de Movies -> REEMPLAZA (con respaldo).
//   * Un archivo con nombre nuevo                         -> se ANEXA (se borra al desactivar).
//   * Dos mods activos nunca comparten un archivo: al activar uno que pisa a otro,
//     el otro se desactiva ENTERO (y se restauran sus originales) antes de aplicar.
//   * Todo cambio es transaccional: si algo falla se deshace lo ya aplicado.
// =============================================================================

enum MovieErrorCode {
  pathsNotDefined,
  noValidFiles,
  requires529,
  menuLimit,
  backupFailed,
  copyFailed,
  verifyFailed,
}

class MovieModException implements Exception {
  final MovieErrorCode code;
  final String detail;
  const MovieModException(this.code, [this.detail = '']);

  @override
  String toString() =>
      'MovieModException(${code.name}${detail.isEmpty ? '' : ': $detail'})';
}

/// Un vídeo encontrado dentro del archivo del mod.
class MovieSourceFile {
  /// Ruta relativa a la carpeta Movies del juego (separador '/').
  final String rel;
  final File file;

  /// Subcarpeta "de variante" (lo que hay por encima de Movies/Menu). '' = raíz.
  final String variantKey;

  const MovieSourceFile({
    required this.rel,
    required this.file,
    this.variantKey = '',
  });

  String get key => rel.toLowerCase();
}

/// Resultado de analizar un mod de películas antes de instalarlo.
class MovieAnalysis {
  final Directory sourceDir;

  /// Archivos que siempre se instalan.
  final List<MovieSourceFile> common;

  /// Variantes que chocan entre sí (mismo archivo en varias carpetas).
  final Map<String, List<MovieSourceFile>> variants;

  /// Distinto de null cuando el usuario debe elegir una variante.
  final SpecialModData? choice;

  /// ruta de directorio de la opción -> variantKey
  final Map<String, String> keyByOptionDir;

  const MovieAnalysis({
    required this.sourceDir,
    required this.common,
    required this.variants,
    required this.choice,
    required this.keyByOptionDir,
  });
}

enum MovieTarget { root, menu }

class MoviePlanEntry {
  /// Ruta relativa dentro de la carpeta del mod.
  final String srcRel;

  /// Destino relativo a Movies (vacío para los de Menu: se asigna al aplicar).
  final String destRel;
  final MovieTarget target;

  /// true si el nombre se cambió (p. ej. un único vídeo con nombre libre -> EVE_Title.bk2).
  final bool renamed;

  const MoviePlanEntry({
    required this.srcRel,
    required this.destRel,
    required this.target,
    this.renamed = false,
  });
}

class MovieInstallPlan {
  final List<MoviePlanEntry> entries;

  /// Archivos del mod que no se usarán (inexistentes, .webm sin Mod 529...).
  final List<String> ignored;

  const MovieInstallPlan(this.entries, this.ignored);

  bool get isEmpty => entries.isEmpty;

  Set<String> get rootKeys => entries
      .where((e) => e.target == MovieTarget.root)
      .map((e) => e.destRel.toLowerCase())
      .toSet();
}

/// Lo que se aplicó realmente en el juego para un archivo.
class MovieInstalledEntry {
  /// Ruta relativa a Movies (p. ej. 'Guide_Camera_1.bk2' o 'Menu/menu_3.bk2').
  final String rel;

  /// Archivo origen dentro de la carpeta del mod ('' si no se conoce: datos antiguos).
  final String src;

  /// 'replace' | 'add' | 'menu' | 'legacy' (datos de la versión anterior de la app)
  final String action;

  /// Tamaño del archivo del mod que se copió (null en datos antiguos).
  final int? size;

  const MovieInstalledEntry({
    required this.rel,
    required this.action,
    this.src = '',
    this.size,
  });

  bool get isMenu =>
      action == 'menu' || rel.toLowerCase().startsWith('menu/');

  Map<String, dynamic> toJson() => {
        'rel': rel,
        'src': src,
        'action': action,
        if (size != null) 'size': size,
      };

  factory MovieInstalledEntry.fromJson(Map<String, dynamic> m) =>
      MovieInstalledEntry(
        rel: (m['rel'] ?? '').toString(),
        src: (m['src'] ?? '').toString(),
        action: (m['action'] ?? 'replace').toString(),
        size: m['size'] is int ? m['size'] as int : null,
      );
}

class MovieDisableReport {
  final List<String> restored = [];
  final List<String> removed = [];

  /// Archivos que ya no eran los del mod (actualización del juego, "verificar
  /// archivos" de Steam...). No se tocan.
  final List<String> detached = [];

  /// Originales que no se pudieron restaurar porque falta el respaldo.
  final List<String> missingBackups = [];
  final List<String> failed = [];
}

class _Undo {
  final File target;
  final File? backup;

  _Undo.delete(this.target) : backup = null;
  _Undo.restore(this.target, File this.backup);

  Future<void> run() async {
    final b = backup;
    if (b == null) {
      if (await target.exists()) await target.delete();
    } else if (await b.exists()) {
      await MovieModsHandler._safeCopy(b, target);
    }
  }
}

class MovieModsHandler {
  /// Los 197 vídeos originales de Movies (según el mapa del juego). Se usa para
  /// distinguir "reemplazo" de "archivo nuevo" aunque el original esté ya pisado.
  static const List<String> originalMovieNames = [
    'DropPod_Hologram_HUD_01.bk2',
    'DropPod_Hologram_HUD_02.bk2',
    'DropPod_Hologram_HUD_FadeOut.bk2',
    'Epilogue_Barrys_dream.bk2',
    'Epilogue_Escape.bk2',
    'Epilogue_HairShop.bk2',
    'EveFinish.bk2',
    'EVE_Title.bk2',
    'EVE_Title_Fusion.bk2',
    'ExosuitFusion_Complete.bk2',
    'ExosuitFusion_Connecting.bk2',
    'ExosuitFusion_Hacked.bk2',
    'ExosuitFusion_Hacking.bk2',
    'ExosuitFusion_WarMode.bk2',
    'ExosuitFusion_Warning.bk2',
    'Guide_ActionAssist_1.bk2',
    'Guide_Balance_2.bk2',
    'Guide_BurstSkill_1.bk2',
    'Guide_BurstSkill_2.bk2',
    'Guide_Camera_1.bk2',
    'Guide_Camera_2.bk2',
    'Guide_Camp_1.bk2',
    'Guide_Camp_2.bk2',
    'Guide_CanCollection_1.bk2',
    'Guide_CanCollection_2.bk2',
    'Guide_CombatItem_1.bk2',
    'Guide_CoreShop_1.bk2',
    'Guide_Exospine_1.bk2',
    'Guide_Exospine_2.bk2',
    'Guide_Fishing_1.bk2',
    'Guide_Fishing_2.bk2',
    'Guide_Fishing_3.bk2',
    'Guide_Fishing_4.bk2',
    'Guide_Friendship_1.bk2',
    'Guide_Friendship_Digger_1.bk2',
    'Guide_Friendship_Temp.bk2',
    'Guide_FullCamp_1.bk2',
    'Guide_FullCamp_2.bk2',
    'Guide_Gear_1.bk2',
    'Guide_Gear_2.bk2',
    'Guide_Grenade_1.bk2',
    'Guide_Grenade_2.bk2',
    'Guide_Map_Unlock_1.bk2',
    'Guide_Map_Unlock_2.bk2',
    'Guide_Move_SwingBar_1.bk2',
    'Guide_Move_WallRun_1.bk2',
    'Guide_NanoSuit_1.bk2',
    'Guide_NanoSuit_2.bk2',
    'Guide_Nier_EmilShop_1.bk2',
    'Guide_Nier_EmilShop_2.bk2',
    'Guide_Quest_2.bk2',
    'Guide_RangeAttack_1.bk2',
    'Guide_RangeAttack_2.bk2',
    'Guide_RangeAttack_3.bk2',
    'Guide_RavenInstaKill_1.bk2',
    'Guide_Request_1.bk2',
    'Guide_Request_2.bk2',
    'Guide_ScanEventMoveObject_1.bk2',
    'Guide_Shield2_2.bk2',
    'Guide_Shield2_3.bk2',
    'Guide_Shield_2.bk2',
    'Guide_Shield_3.bk2',
    'Guide_SkillUnlock_1.bk2',
    'Guide_SkillUnlock_2.bk2',
    'Guide_Skill_Blink_1.bk2',
    'Guide_Skill_Missile_1.bk2',
    'Guide_Skill_Railgun_1.bk2',
    'Guide_Skill_Repulse_1.bk2',
    'Guide_TachyMode_1.bk2',
    'Guide_TachyMode_2.bk2',
    'Guide_Tachymode_3.bk2',
    'Guide_TrainingRoom_2.bk2',
    'Keymapping_Burstskill_View.bk2',
    'Keymapping_Grab_Pivot_Change.bk2',
    'KeyMapping_interaction.bk2',
    'KeyMapping_interaction_cancel.bk2',
    'Manual_BattleBasic_01.bk2',
    'Manual_BattleBasic_02.bk2',
    'Manual_BattleBasic_03.bk2',
    'Manual_BattleExpert_01.bk2',
    'Manual_BattleExpert_02.bk2',
    'Manual_BattleExpert_03.bk2',
    'Manual_Combat_BasicAttack.bk2',
    'Manual_Combat_Evade.bk2',
    'Manual_Combat_Guard_1.bk2',
    'Manual_Combat_Guard_2.bk2',
    'Manual_Combat_MonSkillCombo_1.bk2',
    'Manual_Combat_Monskillunblockable_1.bk2',
    'Manual_Item_00.bk2',
    'Manual_Item_01.bk2',
    'Manual_Item_02.bk2',
    'Manual_Item_Potion.bk2',
    'Manual_RangeMode_01.bk2',
    'Manual_Scan_01.bk2',
    'Manual_Skill_00.bk2',
    'Manual_Skill_01.bk2',
    'Manual_Skill_02.bk2',
    'Manual_Skill_BackStab.bk2',
    'Manual_Skill_BetaSkill.bk2',
    'Manual_Skill_Dash.bk2',
    'Manual_TachyMode_01.bk2',
    'MV_DED01_SDFlashback.bk2',
    'MV_DED01_SDFlashback_low.bk2',
    'MV_DED02_Monorail_Dialogue.bk2',
    'MV_DED02_Monorail_Dialogue_low.bk2',
    'Screen_01.bk2',
    'SkillPreview_AirBreakFall1.bk2',
    'SkillPreview_AirDropAttack1.bk2',
    'SkillPreview_AirGuardBreak1.bk2',
    'SkillPreview_AirGuardBreak1_BetaChain.bk2',
    'Skillpreview_Airlightattackcombo1.bk2',
    'SkillPreview_AirRollingAttack1.bk2',
    'Skillpreview_Airrollingattack1_Betachain.bk2',
    'SkillPreview_BackStab1.bk2',
    'SkillPreview_Blaze1.bk2',
    'SkillPreview_Blaze1Combo1.bk2',
    'SkillPreview_Blaze1Ex.bk2',
    'SkillPreview_BurstFinishAttack1.bk2',
    'SkillPreview_BurstSpinAttack1.bk2',
    'SkillPreview_DashAttack1.bk2',
    'SkillPreview_DashAttack1Combo1.bk2',
    'Skillpreview_Dashattack1combo1_Betachain.bk2',
    'SkillPreview_DashAttack1Combo2.bk2',
    'SkillPreview_DashAttack2.bk2',
    'SkillPreview_DoubleJump1.bk2',
    'SkillPreview_Evade2.bk2',
    'SkillPreview_FastGetup1.bk2',
    'SkillPreview_FlashBehindAttack1.bk2',
    'SkillPreview_JustEvade1.bk2',
    'SkillPreview_JustEvadeLightAttack1.bk2',
    'SkillPreview_JustEvadeLightAttack1Combo1.bk2',
    'SkillPreview_JustEvadeStrongAttack1.bk2',
    'SkillPreview_JustEvadeStrongAttack1Combo1.bk2',
    'Skillpreview_Justevade_Dashattack1.bk2',
    'SkillPreview_JustParry1.bk2',
    'SkillPreview_JustParryLightAttack1.bk2',
    'SkillPreview_JustParryLightAttack1Combo1.bk2',
    'SkillPreview_JustParryStrongAttack1.bk2',
    'SkillPreview_JustParryStrongAttack1Combo1.bk2',
    'SkillPreview_LightAttackAdditionalCombo1.bk2',
    'SkillPreview_LightAttackAdditionalCombo2.bk2',
    'Skillpreview_Lightattackadditionalcombo2_Betachain.bk2',
    'SkillPreview_LightAttackAdditionalCombo3.bk2',
    'Skillpreview_Lightattackadditionalcombo3_Betachain.bk2',
    'SkillPreview_LightAttackAdditionalCombo4.bk2',
    'Skillpreview_Lightattackadditionalcombo4_Betachain.bk2',
    'SkillPreview_LightAttackAdditionalCombo5.bk2',
    'Skillpreview_Lightattackadditionalcombo5_Betachain.bk2',
    'Skillpreview_Lightattackcombo1.bk2',
    'Skillpreview_Lightattackcombo1_Betachain.bk2',
    'SkillPreview_MassiveAttack1.bk2',
    'SkillPreview_MeleeAttackBuff1.bk2',
    'SkillPreview_MoveBackAttack1.bk2',
    'SkillPreview_NormalSkillUpgrade4_1.bk2',
    'SkillPreview_PushBackAttack1.bk2',
    'SkillPreview_RangeAttackBuff1.bk2',
    'SkillPreview_ShieldBreak1.bk2',
    'SkillPreview_ShieldBreak1Double.bk2',
    'SkillPreview_ShieldBreak1Ex.bk2',
    'SkillPreview_StrongAttackAdditionalCombo1.bk2',
    'Skillpreview_Strongattackadditionalcombo1_Betachain.bk2',
    'SkillPreview_StrongAttackAdditionalCombo2.bk2',
    'Skillpreview_Strongattackadditionalcombo2_Betachain.bk2',
    'SkillPreview_StrongAttackAdditionalCombo3.bk2',
    'Skillpreview_Strongattackadditionalcombo3_Betachain.bk2',
    'SkillPreview_StrongAttackAdditionalCombo4.bk2',
    'Skillpreview_Strongattackadditionalcombo4_Betachain.bk2',
    'SkillPreview_SwordAura1.bk2',
    'SkillPreview_SwordAura1Combo1.bk2',
    'SkillPreview_SwordAura1Ex.bk2',
    'SkillPreview_TachyMode1.bk2',
    'SkillPreview_Tachy_AirLightAttackCombo1.bk2',
    'SkillPreview_Tachy_AirStrongAttack1.bk2',
    'SkillPreview_Tachy_DashAttack1.bk2',
    'SkillPreview_Tachy_Evade1.bk2',
    'SkillPreview_Tachy_Guard1.bk2',
    'SkillPreview_Tachy_JustEvadeLightAttack1.bk2',
    'SkillPreview_Tachy_JustEvadeLightAttack1Combo1.bk2',
    'SkillPreview_Tachy_JustEvadeStrongAttack1.bk2',
    'SkillPreview_Tachy_JustEvadeStrongAttack1Combo1.bk2',
    'SkillPreview_Tachy_JustParryLightAttack1.bk2',
    'SkillPreview_Tachy_JustParryLightAttack1Combo1.bk2',
    'SkillPreview_Tachy_JustParryStrongAttack1.bk2',
    'SkillPreview_Tachy_JustParryStrongAttack1Combo1.bk2',
    'SkillPreview_Tachy_LightAttackCombo1.bk2',
    'SkillPreview_Tachy_Skill_ChainSpin1.bk2',
    'SkillPreview_Tachy_Skill_ChainStab1.bk2',
    'SkillPreview_Tachy_Skill_ParrySlash1.bk2',
    'SkillPreview_Tachy_Skill_ScrewAttack1.bk2',
    'SkillPreview_Tachy_Skill_SwordAura1.bk2',
    'SkillPreview_Tachy_StrongAttackCombo1.bk2',
    'SkillPreview_Triplet1.bk2',
    'SkillPreview_Triplet1Combo1.bk2',
    'SkillPreview_Triplet1Ex.bk2',
    'TetrapodScreen_1.bk2',
    'TITLE_mov_L.bk2',
    'warning_01.bk2',
  ];

  static final Map<String, String> _canonicalByKey = {
    for (final n in originalMovieNames) n.toLowerCase(): n,
  };

  static const String _tmpSuffix = '.mmtmp';

  // ---------------------------------------------------------------------------
  //  Utilidades
  // ---------------------------------------------------------------------------

  static String _join(String base, String rel) => p.joinAll([
        base,
        ...rel.split('/').where((s) => s.isNotEmpty),
      ]);

  static String _normalizeRel(String rel) {
    final parts = rel
        .replaceAll('\\', '/')
        .split('/')
        .where((s) => s.isNotEmpty && s != '.')
        .toList();
    if (parts.length > 1 && parts.first.toLowerCase() == 'menu') {
      parts[0] = 'Menu';
    }
    return parts.join('/');
  }

  static Future<void> _quietDelete(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  // Cola: solo una operación de películas a la vez (evita pisarse al activar/desactivar rápido).
  static Future<void> _tail = Future<void>.value();
  static Future<T> _serialize<T>(Future<T> Function() op) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await op());
      } catch (e, s) {
        completer.completeError(e, s);
      }
    });
    return completer.future;
  }

  /// Copia segura: escribe a un temporal, verifica el tamaño y renombra encima del destino.
  static Future<void> _safeCopy(File src, File dest) async {
    await dest.parent.create(recursive: true);
    final tmp = File('${dest.path}$_tmpSuffix');
    try {
      if (await tmp.exists()) await tmp.delete();
      await src.copy(tmp.path);
      if (await src.length() != await tmp.length()) {
        throw MovieModException(
            MovieErrorCode.verifyFailed, p.basename(dest.path));
      }
      await tmp.rename(dest.path);
    } on MovieModException {
      await _quietDelete(tmp);
      rethrow;
    } on FileSystemException catch (e) {
      await _quietDelete(tmp);
      throw MovieModException(MovieErrorCode.copyFailed,
          '${p.basename(dest.path)}: ${e.osError?.message ?? e.message}');
    } catch (_) {
      await _quietDelete(tmp);
      rethrow;
    }
  }

  static Future<void> _cleanTempFiles(Directory dir) async {
    try {
      if (!await dir.exists()) return;
      await for (final e in dir.list(recursive: true, followLinks: false)) {
        if (e is File && e.path.endsWith(_tmpSuffix)) await _quietDelete(e);
      }
    } catch (_) {}
  }

  static Future<void> _pruneEmptyDirs(Directory root) async {
    try {
      if (!await root.exists()) return;
      final dirs = <Directory>[];
      await for (final e in root.list(recursive: true, followLinks: false)) {
        if (e is Directory) dirs.add(e);
      }
      dirs.sort((a, b) => b.path.length.compareTo(a.path.length));
      for (final d in dirs) {
        try {
          if (await d.list().isEmpty) await d.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Archivos .bk2 sueltos que hay AHORA en Movies: nombre en minúsculas -> nombre real.
  static Future<Map<String, String>> _gameRootFiles(Directory moviesDir) async {
    final map = <String, String>{};
    if (!await moviesDir.exists()) return map;
    await for (final e in moviesDir.list(recursive: false, followLinks: false)) {
      if (e is File && p.extension(e.path).toLowerCase() == '.bk2') {
        final name = p.basename(e.path);
        map[name.toLowerCase()] = name;
      }
    }
    return map;
  }

  static Future<Set<int>> _usedMenuIndices(Directory menuDir) async {
    final used = <int>{};
    if (!await menuDir.exists()) return used;
    final regex = RegExp(r'^menu_(\d+)\.(bk2|webm)$', caseSensitive: false);
    await for (final e in menuDir.list(followLinks: false)) {
      final m = regex.firstMatch(p.basename(e.path));
      if (m != null) used.add(int.parse(m.group(1)!));
    }
    return used;
  }

  // ---------------------------------------------------------------------------
  //  1) ANÁLISIS DEL ARCHIVO DEL MOD (al instalar)
  // ---------------------------------------------------------------------------

  /// Busca todos los .bk2/.webm del mod y calcula su ruta relativa a Movies:
  ///   .../Movies/Guide/x.bk2 -> Guide/x.bk2     .../Menu/menu_0.bk2 -> Menu/menu_0.bk2
  ///   cualquier otro sitio   -> solo el nombre del archivo
  static Future<List<MovieSourceFile>> collectSourceFiles(
      Directory sourceDir) async {
    final result = <MovieSourceFile>[];
    await for (final entity
        in sourceDir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final ext = p.extension(entity.path).toLowerCase();
      if (ext != '.bk2' && ext != '.webm') continue;

      final parts = p.split(p.relative(entity.path, from: sourceDir.path));
      if (parts.any((s) => s.toLowerCase() == '__macosx')) continue;
      final name = parts.last;
      if (name.startsWith('._')) continue;
      final dirs = parts.sublist(0, parts.length - 1);

      final moviesIdx = dirs.lastIndexWhere((s) => s.toLowerCase() == 'movies');
      final menuIdx = dirs.lastIndexWhere((s) => s.toLowerCase() == 'menu');

      String rel;
      List<String> variantParts;
      if (moviesIdx >= 0) {
        rel = [...dirs.sublist(moviesIdx + 1), name].join('/');
        variantParts = dirs.sublist(0, moviesIdx);
      } else if (menuIdx >= 0) {
        rel = [...dirs.sublist(menuIdx), name].join('/');
        variantParts = dirs.sublist(0, menuIdx);
      } else {
        rel = name;
        variantParts = dirs;
      }

      result.add(MovieSourceFile(
        rel: _normalizeRel(rel),
        file: entity,
        variantKey: variantParts.join('/'),
      ));
    }
    result.sort((a, b) => a.rel.toLowerCase().compareTo(b.rel.toLowerCase()));
    return result;
  }

  /// Agrupa los vídeos y detecta si hay VARIANTES excluyentes (el mismo archivo
  /// en dos carpetas distintas, p. ej. "Rojo/EVE_Title.bk2" y "Azul/EVE_Title.bk2").
  /// Solo en ese caso hay que preguntar; si no, se instala todo.
  static Future<MovieAnalysis> analyze(
      String archiveName, Directory sourceDir) async {
    final files = await collectSourceFiles(sourceDir);

    final variantsByFile = <String, Set<String>>{};
    for (final f in files) {
      variantsByFile.putIfAbsent(f.key, () => <String>{}).add(f.variantKey);
    }
    final conflicting = variantsByFile.entries
        .where((e) => e.value.length > 1)
        .map((e) => e.key)
        .toSet();

    final common = <MovieSourceFile>[];
    final variants = <String, List<MovieSourceFile>>{};

    if (conflicting.isEmpty) {
      common.addAll(files);
    } else {
      final participating = <String>{
        for (final f in files)
          if (conflicting.contains(f.key)) f.variantKey,
      };
      for (final f in files) {
        if (participating.contains(f.variantKey)) {
          variants.putIfAbsent(f.variantKey, () => []).add(f);
        } else {
          common.add(f);
        }
      }
    }

    SpecialModData? choice;
    final keyByDir = <String, String>{};
    if (variants.length > 1) {
      final keys = variants.keys.toList()..sort();
      final split = keys.map((k) => k.isEmpty ? <String>[] : k.split('/')).toList();

      // Prefijo común (sin consumir nunca una clave entera)
      int prefix = 0;
      while (split.every((s) => s.length > prefix + 1) &&
          split.every((s) => s[prefix] == split.first[prefix])) {
        prefix++;
      }

      final options = <SpecialModOption>[];
      for (var i = 0; i < keys.length; i++) {
        final label =
            split[i].length > prefix ? split[i].sublist(prefix).join(' / ') : '(root)';
        final dir = Directory(_join(sourceDir.path, keys[i]));
        keyByDir[dir.path] = keys[i];
        options.add(SpecialModOption(name: label, directory: dir));
      }
      choice = SpecialModData(
        nexusId: archiveName,
        mainFiles: <File>[],
        options: options,
        originalDir: sourceDir,
        isSingleSelection: true,
      );
    }

    return MovieAnalysis(
      sourceDir: sourceDir,
      common: common,
      variants: variants,
      choice: choice,
      keyByOptionDir: keyByDir,
    );
  }

  /// Archivos finales a instalar tras (opcionalmente) elegir una variante.
  static List<MovieSourceFile> resolveSelection(MovieAnalysis analysis) {
    final chosen = <String, MovieSourceFile>{};
    for (final f in analysis.common) {
      chosen[f.key] = f;
    }
    final choice = analysis.choice;
    if (choice != null) {
      for (final option in choice.options.where((o) => o.isSelected)) {
        final variantKey = analysis.keyByOptionDir[option.directory.path];
        for (final f in analysis.variants[variantKey] ?? const <MovieSourceFile>[]) {
          chosen[f.key] = f; // la variante elegida manda sobre los archivos comunes
        }
      }
    }
    final list = chosen.values.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return list;
  }

  // ---------------------------------------------------------------------------
  //  2) PLAN (qué se hará al activar el mod; no toca el disco)
  // ---------------------------------------------------------------------------

  static bool _isTitle(String nameKey) =>
      nameKey == 'eve_title.bk2' || nameKey == 'eve_title_fusion.bk2';

  /// [files]: lo guardado en `replacedFiles` (rutas relativas dentro de la carpeta del mod).
  /// [ownedAddKeys]: archivos NUEVOS (no originales) que ya anexó otro mod activo.
  static Future<MovieInstallPlan> buildPlan({
    required Directory modDir,
    required List<String> files,
    required bool hasMod529,
    required Directory moviesDir,
    Set<String> ownedAddKeys = const <String>{},
  }) async {
    final inGame = await _gameRootFiles(moviesDir);
    bool isOriginal(String nameKey) =>
        _canonicalByKey.containsKey(nameKey) ||
        (inGame.containsKey(nameKey) && !ownedAddKeys.contains(nameKey));

    String canonical(String name) =>
        inGame[name.toLowerCase()] ?? _canonicalByKey[name.toLowerCase()] ?? name;

    final ignored = <String>[];
    final explicitMenu = <String>[];
    final titles = <String>[];
    final replaceFiles = <String>[];
    final unknownRoot = <String>[];
    final webmRoot = <String>[];
    final nested = <String>[];

    for (final raw in files) {
      final rel = _normalizeRel(raw);
      if (rel.isEmpty) continue;
      final src = File(_join(modDir.path, rel));
      if (!await src.exists()) {
        ignored.add(rel);
        continue;
      }
      final key = rel.toLowerCase();
      final ext = p.extension(key);
      final isNested = rel.contains('/');
      final nameKey = p.basename(key);

      if (key.startsWith('menu/')) {
        explicitMenu.add(rel);
      } else if (ext == '.webm') {
        if (isNested) {
          ignored.add(rel);
        } else {
          webmRoot.add(rel);
        }
      } else if (isNested) {
        nested.add(rel);
      } else if (_isTitle(nameKey)) {
        titles.add(rel);
      } else if (isOriginal(nameKey)) {
        replaceFiles.add(rel);
      } else {
        unknownRoot.add(rel);
      }
    }

    final entries = <MoviePlanEntry>[];
    final usedDest = <String>{};

    void addRoot(String srcRel, String destRel, {bool renamed = false}) {
      if (usedDest.add(destRel.toLowerCase())) {
        entries.add(MoviePlanEntry(
            srcRel: srcRel,
            destRel: destRel,
            target: MovieTarget.root,
            renamed: renamed));
      } else {
        ignored.add(srcRel);
      }
    }

    void addMenu(String srcRel) => entries.add(MoviePlanEntry(
        srcRel: srcRel, destRel: '', target: MovieTarget.menu));

    // Reemplazos de originales y archivos con estructura propia: siempre.
    for (final rel in replaceFiles) {
      addRoot(rel, canonical(rel));
    }
    for (final rel in nested) {
      addRoot(rel, rel);
    }

    if (hasMod529) {
      // Con el Mod 529 los vídeos "de menú" van a Movies/Menu/menu_N.
      final menuSources = [...explicitMenu, ...unknownRoot, ...webmRoot];
      if (menuSources.isNotEmpty) {
        menuSources.forEach(addMenu);
        ignored.addAll(titles); // mod híbrido: manda lo específico de menú
      } else {
        titles.forEach(addMenu); // solo trae el título: se reutiliza como vídeo de menú
      }
    } else {
      for (final rel in titles) {
        addRoot(rel, canonical(rel));
      }
      ignored.addAll(explicitMenu); // necesitan el Mod 529
      ignored.addAll(webmRoot); //     (el reemplazo clásico solo usa .bk2)

      final nothingKnown = replaceFiles.isEmpty &&
          titles.isEmpty &&
          nested.isEmpty &&
          explicitMenu.isEmpty;
      if (nothingKnown && unknownRoot.length == 1) {
        // Un único vídeo con nombre libre: se entiende como el vídeo de título.
        addRoot(unknownRoot.first, 'EVE_Title.bk2', renamed: true);
      } else {
        // Vídeos nuevos: se anexan tal cual.
        for (final rel in unknownRoot) {
          addRoot(rel, rel);
        }
      }
    }

    return MovieInstallPlan(entries, ignored);
  }

  // ---------------------------------------------------------------------------
  //  3) APLICAR (activar el mod)
  // ---------------------------------------------------------------------------

  /// Copia los archivos al juego. Antes de pisar un original crea su respaldo
  /// (nunca sobrescribe un respaldo existente). Si algo falla, deshace todo.
  static Future<List<MovieInstalledEntry>> apply({
    required MovieInstallPlan plan,
    required Directory moviesDir,
    required Directory backupDir,
    required Directory modDir,
  }) =>
      _serialize(() async {
        await moviesDir.create(recursive: true);
        await backupDir.create(recursive: true);
        await _cleanTempFiles(moviesDir);
        await _cleanTempFiles(backupDir);

        final menuDir = Directory(p.join(moviesDir.path, 'Menu'));
        final journal = <_Undo>[];
        final installed = <MovieInstalledEntry>[];
        Set<int>? usedMenu;

        try {
          for (final e in plan.entries) {
            final src = File(_join(modDir.path, e.srcRel));
            if (!await src.exists()) {
              throw MovieModException(MovieErrorCode.copyFailed,
                  'missing ${e.srcRel}');
            }
            final size = await src.length();
            if (size == 0) {
              throw MovieModException(
                  MovieErrorCode.verifyFailed, 'empty ${e.srcRel}');
            }

            if (e.target == MovieTarget.menu) {
              final used = usedMenu ??= await _usedMenuIndices(menuDir);
              var idx = 0;
              while (used.contains(idx)) {
                idx++;
              }
              if (idx > 99) {
                throw const MovieModException(MovieErrorCode.menuLimit);
              }
              used.add(idx);

              final destRel =
                  'Menu/menu_$idx${p.extension(e.srcRel).toLowerCase()}';
              final dest = File(_join(moviesDir.path, destRel));
              journal.add(_Undo.delete(dest));
              await _safeCopy(src, dest);
              installed.add(MovieInstalledEntry(
                  rel: destRel, src: e.srcRel, action: 'menu', size: size));
              continue;
            }

            final dest = File(_join(moviesDir.path, e.destRel));
            if (await dest.exists()) {
              // Original (o archivo ajeno): respaldo antes de tocarlo.
              final backup = File(_join(backupDir.path, '${e.destRel}.bak'));
              await _ensureBackup(dest, backup);
              journal.add(_Undo.restore(dest, backup));
              await _safeCopy(src, dest);
              installed.add(MovieInstalledEntry(
                  rel: e.destRel, src: e.srcRel, action: 'replace', size: size));
            } else {
              journal.add(_Undo.delete(dest));
              await _safeCopy(src, dest);
              installed.add(MovieInstalledEntry(
                  rel: e.destRel, src: e.srcRel, action: 'add', size: size));
            }
          }
          return installed;
        } catch (_) {
          for (final u in journal.reversed) {
            try {
              await u.run();
            } catch (_) {}
          }
          await _cleanTempFiles(moviesDir);
          await _pruneEmptyDirs(moviesDir);
          rethrow;
        }
      });

  /// Crea el respaldo del original si no existe. Un respaldo existente NO se
  /// sobrescribe jamás (el primero que se hizo es el original auténtico).
  static Future<void> _ensureBackup(File game, File backup) async {
    if (await backup.exists()) {
      if (await backup.length() > 0) return;
      await backup.delete(); // respaldo corrupto (0 bytes): se rehace
    }
    if (await game.length() == 0) {
      throw MovieModException(
          MovieErrorCode.backupFailed, p.basename(game.path));
    }
    try {
      await _safeCopy(game, backup);
    } on MovieModException catch (e) {
      throw MovieModException(MovieErrorCode.backupFailed, e.detail);
    }
  }

  // ---------------------------------------------------------------------------
  //  4) QUITAR (desactivar el mod)
  // ---------------------------------------------------------------------------

  /// Lee lo aplicado en el juego desde el nexus_info.json (también el formato
  /// antiguo: activeInstalledFiles + isMenuMode).
  static List<MovieInstalledEntry> entriesFromInfo(Map<String, dynamic> info) {
    final mi = info['movieInstall'];
    if (mi is Map && mi['entries'] is List) {
      return (mi['entries'] as List)
          .whereType<Map>()
          .map((m) =>
              MovieInstalledEntry.fromJson(Map<String, dynamic>.from(m)))
          .where((e) => e.rel.isNotEmpty)
          .toList();
    }
    final active = info['activeInstalledFiles'];
    if (active is! List) return <MovieInstalledEntry>[];
    final menu = info['isMenuMode'] == true;
    return active
        .map((n) => n.toString().replaceAll('\\', '/'))
        .where((n) => n.isNotEmpty)
        .map((n) => MovieInstalledEntry(
              rel: menu ? 'Menu/$n' : n,
              action: menu ? 'menu' : 'legacy',
            ))
        .toList();
  }

  /// Archivos de la raíz de Movies que ocupa el mod (los de Menu no cuentan:
  /// cada mod recibe sus propios menu_N).
  static Set<String> ownedRootKeys(List<MovieInstalledEntry> entries) => entries
      .where((e) => !e.isMenu)
      .map((e) => e.rel.toLowerCase())
      .toSet();

  /// Archivos NUEVOS (no originales) que el mod anexó.
  static Set<String> ownedAddKeys(List<MovieInstalledEntry> entries) => entries
      .where((e) => e.action == 'add' && !e.rel.contains('/'))
      .map((e) => e.rel.toLowerCase())
      .toSet();

  /// Deshace lo que hizo el mod: restaura originales desde el respaldo y borra
  /// lo anexado. Nunca borra un original cuyo respaldo falta, y nunca toca un
  /// archivo que ya no es el del mod (p. ej. actualizado por Steam).
  static Future<MovieDisableReport> remove({
    required List<MovieInstalledEntry> entries,
    required Directory moviesDir,
    required Directory backupDir,
  }) =>
      _serialize(() async {
        final report = MovieDisableReport();
        await _cleanTempFiles(moviesDir);

        for (final e in entries) {
          final game = File(_join(moviesDir.path, e.rel));
          try {
            final exists = await game.exists();
            final ours =
                !exists || e.size == null || await game.length() == e.size;

            if (e.isMenu || e.action == 'add') {
              if (exists && ours) {
                await game.delete();
                report.removed.add(e.rel);
              } else if (exists) {
                report.detached.add(e.rel);
              }
              continue;
            }

            final backup = File(_join(backupDir.path, '${e.rel}.bak'));

            if (!ours) {
              // El archivo del juego ya no es el del mod: no se pisa. El
              // respaldo queda obsoleto, se aparta (no se destruye).
              report.detached.add(e.rel);
              if (await backup.exists()) {
                try {
                  await backup.rename('${backup.path}.stale');
                } catch (_) {}
              }
              continue;
            }

            if (await backup.exists()) {
              await _safeCopy(backup, game);
              report.restored.add(e.rel);
            } else if (e.action == 'legacy' &&
                !_canonicalByKey.containsKey(e.rel.toLowerCase())) {
              // Datos antiguos: no era un original conocido, se anexó sin respaldo.
              if (exists) await game.delete();
              report.removed.add(e.rel);
            } else {
              report.missingBackups.add(e.rel);
            }
          } on MovieModException catch (ex) {
            report.failed.add('${e.rel}: ${ex.detail}');
          } on FileSystemException catch (ex) {
            report.failed.add('${e.rel}: ${ex.osError?.message ?? ex.message}');
          }
        }

        await _pruneEmptyDirs(moviesDir);

        if (report.failed.isNotEmpty) {
          // El mod sigue marcado como activo: se puede reintentar (cerrar el juego).
          throw MovieModException(
              MovieErrorCode.copyFailed, report.failed.join('; '));
        }
        return report;
      });

  // ---------------------------------------------------------------------------
  //  5) VERIFICACIÓN (¿el mod "activo" sigue realmente aplicado en el juego?)
  // ---------------------------------------------------------------------------

  /// false si algún archivo falta o ya no tiene el tamaño del mod (Steam
  /// "verificar archivos", actualización del juego, borrado manual...).
  static Future<bool> isStillApplied({
    required List<MovieInstalledEntry> entries,
    required Directory moviesDir,
    required Directory modDir,
  }) async {
    if (entries.isEmpty) return false;
    for (final e in entries) {
      final game = File(_join(moviesDir.path, e.rel));
      if (!await game.exists()) return false;
      var expected = e.size;
      if (expected == null && e.src.isNotEmpty) {
        final s = File(_join(modDir.path, e.src));
        if (await s.exists()) expected = await s.length();
      }
      if (expected != null && await game.length() != expected) return false;
    }
    return true;
  }
}