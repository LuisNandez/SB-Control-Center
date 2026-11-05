// lib/ui/theme/app_themes.dart
//
// Catálogo de temas de la app. Cada tema es una [AppPalette] con todos los
// colores semánticos que usa la interfaz. Para añadir un tema nuevo:
//   1. añade un valor en [AppThemeId],
//   2. crea su paleta en [AppThemes._palettes],
//   3. añade su nombre traducido en el ARB (themeXxx) y en [AppThemes.label]
//      de settings_page.dart / theme_picker.dart.
import 'package:flutter/material.dart';

// SISTEMA DE COLOR
//  * Las superficies de cada tema comparten un mismo matiz (H) y suben de
//    luminosidad por escalones regulares: fondo < hundido < barra < tarjeta
//    < hover < pulsado < elevado. Así las capas se leen sin bordes duros.
//  * Los colores semánticos (verde, rojo, naranja, amarillo, morado, turquesa)
//    comparten luminosidad y croma dentro de cada modo (oscuro / claro): ningún
//    color "grita" más que otro. Solo el acento cambia de tema a tema.
//  * Contraste medido (WCAG): texto principal ≥ 13:1, secundario ≥ 5.7:1,
//    blanco sobre acento ≥ 3.8:1 en oscuros (5.2:1 en claro).
//
/// Identificadores de tema. [system] no es una paleta: sigue el modo claro u
/// oscuro del sistema operativo.
enum AppThemeId { system, dark, midnight, light, ocean, forest, violet, sand, cocoa }

@immutable
class AppPalette {
  const AppPalette({
    required this.id,
    required this.brightness,
    required this.background,
    required this.bar,
    required this.card,
    required this.elevated,
    required this.separator,
    required this.fill,
    required this.chip,
    required this.chipHover,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.labelSoft,
    required this.icon,
    required this.sunken,
    required this.controlHover,
    required this.controlPressed,
    required this.elevatedHover,
    required this.overlayBase,
    required this.blue,
    required this.green,
    required this.red,
    required this.orange,
    required this.yellow,
    required this.purple,
    required this.teal,
    required this.gray,
  });

  final AppThemeId id;
  final Brightness brightness;

  // Superficies
  final Color background;
  final Color bar;
  final Color card;
  final Color elevated;
  final Color separator;

  // Rellenos translúcidos
  final Color fill;
  final Color chip;
  final Color chipHover;

  // Texto e iconos
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color labelSoft;
  final Color icon;

  // Superficies auxiliares
  final Color sunken;
  final Color controlHover;
  final Color controlPressed;
  final Color elevatedHover;

  /// Color base de los resaltados translúcidos: blanco en temas oscuros y
  /// negro en temas claros (así un "14 % de blanco" se vuelve "14 % de negro").
  final Color overlayBase;

  // Colores de sistema; [blue] es el color de acento de todo el tema.
  final Color blue;
  final Color green;
  final Color red;
  final Color orange;
  final Color yellow;
  final Color purple;
  final Color teal;
  final Color gray;

  bool get isDark => brightness == Brightness.dark;
}

class AppThemes {
  AppThemes._();

  static const AppThemeId defaultId = AppThemeId.dark;

  /// Temas elegibles (el orden es el del selector de Ajustes).
  static const List<AppThemeId> selectable = [
    AppThemeId.system,
    AppThemeId.dark,
    AppThemeId.midnight,
    AppThemeId.light,
    AppThemeId.ocean,
    AppThemeId.forest,
    AppThemeId.violet,
    AppThemeId.sand,
    AppThemeId.cocoa,
  ];

  /// Resuelve el id elegido a una paleta concreta. [platformBrightness] solo
  /// importa para [AppThemeId.system].
  static AppPalette resolve(AppThemeId id, Brightness platformBrightness) {
    if (id == AppThemeId.system) {
      return platformBrightness == Brightness.light ? light : dark;
    }
    return byId(id);
  }

  static AppPalette byId(AppThemeId id) {
    switch (id) {
      case AppThemeId.system:
      case AppThemeId.dark:
        return dark;
      case AppThemeId.midnight:
        return midnight;
      case AppThemeId.light:
        return light;
      case AppThemeId.ocean:
        return ocean;
      case AppThemeId.forest:
        return forest;
      case AppThemeId.violet:
        return violet;
      case AppThemeId.sand:
        return sand;
      case AppThemeId.cocoa:
        return cocoa;
    }
  }

  /// Lee el id guardado en preferencias (cualquier valor desconocido → por defecto).
  static AppThemeId parse(String? name) {
    for (final t in AppThemeId.values) {
      if (t.name == name) return t;
    }
    return defaultId;
  }

  // ------------------------------------------------------------------ Oscuro
  // Grafito neutro con un ligero matiz frío (H≈265). Es el tema por defecto:
  // acento azul profundo, texto blanco-hielo (nunca #FFF puro, cansa menos).
  static const AppPalette dark = AppPalette(
    id: AppThemeId.dark,
    brightness: Brightness.dark,
    background: Color(0xFF18191C),
    bar: Color(0xFF212326),
    card: Color(0xFF2A2B2E),
    elevated: Color(0xFF3B3D40),
    separator: Color(0xFF36383B),
    fill: Color(0x26D6DEEF),
    chip: Color(0x1FFFFFFF),
    chipHover: Color(0x2EFFFFFF),
    label: Color(0xFFF5F7FB),
    secondaryLabel: Color(0xADD6DEEF),
    tertiaryLabel: Color(0x6BD6DEEF),
    labelSoft: Color(0xFFE0E3EA),
    icon: Color(0xFFC0C4CD),
    sunken: Color(0xFF1B1D20),
    controlHover: Color(0xFF313336),
    controlPressed: Color(0xFF393A3E),
    elevatedHover: Color(0xFF46484B),
    overlayBase: Color(0xFFFFFFFF),
    blue: Color(0xFF0A7AEA),
    green: Color(0xFF53DE73),
    red: Color(0xFFFF5F5B),
    orange: Color(0xFFFF9F33),
    yellow: Color(0xFFFBD530),
    purple: Color(0xFFD07AF5),
    teal: Color(0xFF4DD4DB),
    gray: Color(0xFF8F929A),
  );

  // ------------------------------------------------------------- Medianoche
  // Negro puro (OLED). Las superficies suben por pasos de luminosidad con un
  // tinte índigo casi imperceptible; el acento es un índigo-azul propio, para
  // que no se confunda con el del tema Oscuro.
  static const AppPalette midnight = AppPalette(
    id: AppThemeId.midnight,
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    bar: Color(0xFF0D0E14),
    card: Color(0xFF18191F),
    elevated: Color(0xFF303138),
    separator: Color(0xFF282A30),
    fill: Color(0x26D9DDEF),
    chip: Color(0x1FFFFFFF),
    chipHover: Color(0x2EFFFFFF),
    label: Color(0xFFF5F6FB),
    secondaryLabel: Color(0xADD9DDEF),
    tertiaryLabel: Color(0x6BD9DDEF),
    labelSoft: Color(0xFFE1E2EA),
    icon: Color(0xFFC1C4CD),
    sunken: Color(0xFF07080D),
    controlHover: Color(0xFF212229),
    controlPressed: Color(0xFF282A30),
    elevatedHover: Color(0xFF3A3B42),
    overlayBase: Color(0xFFFFFFFF),
    blue: Color(0xFF626EEE),
    green: Color(0xFF53DE73),
    red: Color(0xFFFF5F5B),
    orange: Color(0xFFFF9F33),
    yellow: Color(0xFFFBD530),
    purple: Color(0xFFD07AF5),
    teal: Color(0xFF4DD4DB),
    gray: Color(0xFF83868F),
  );

  // ------------------------------------------------------------------ Claro
  // Blanco-azulado muy suave (no gris sucio). Los colores semánticos son más
  // oscuros que en los temas oscuros para alcanzar ≥ 4:1 sobre blanco.
  static const AppPalette light = AppPalette(
    id: AppThemeId.light,
    brightness: Brightness.light,
    background: Color(0xFFF1F4F8),
    bar: Color(0xFFE8EBF0),
    card: Color(0xFFFFFFFF),
    elevated: Color(0xFFFFFFFF),
    separator: Color(0xFFD5D8DC),
    fill: Color(0x29323842),
    chip: Color(0x12000000),
    chipHover: Color(0x1C000000),
    label: Color(0xFF13161C),
    secondaryLabel: Color(0xC7323842),
    tertiaryLabel: Color(0x75323842),
    labelSoft: Color(0xFF34383E),
    icon: Color(0xFF595E66),
    sunken: Color(0xFFE7EAEE),
    controlHover: Color(0xFFEDF0F5),
    controlPressed: Color(0xFFE3E6EB),
    elevatedHover: Color(0xFFF1F4F8),
    overlayBase: Color(0xFF000000),
    blue: Color(0xFF0067DF),
    green: Color(0xFF05893E),
    red: Color(0xFFD4302E),
    orange: Color(0xFFC06100),
    yellow: Color(0xFF937300),
    purple: Color(0xFF8644C1),
    teal: Color(0xFF00828D),
    gray: Color(0xFF81878F),
  );

  // ----------------------------------------------------------------- Océano
  // Azul petróleo profundo; acento cerúleo y turquesa de apoyo bien separado.
  static const AppPalette ocean = AppPalette(
    id: AppThemeId.ocean,
    brightness: Brightness.dark,
    background: Color(0xFF081C27),
    bar: Color(0xFF112531),
    card: Color(0xFF1A2E3A),
    elevated: Color(0xFF2B404D),
    separator: Color(0xFF263B47),
    fill: Color(0x26CFE1ED),
    chip: Color(0x1FFFFFFF),
    chipHover: Color(0x2EFFFFFF),
    label: Color(0xFFF3F7FA),
    secondaryLabel: Color(0xADCFE1ED),
    tertiaryLabel: Color(0x6BCFE1ED),
    labelSoft: Color(0xFFDDE4E9),
    icon: Color(0xFFBCC6CC),
    sunken: Color(0xFF0B1F2B),
    controlHover: Color(0xFF213642),
    controlPressed: Color(0xFF293E4A),
    elevatedHover: Color(0xFF364B58),
    overlayBase: Color(0xFFFFFFFF),
    blue: Color(0xFF0A8CBF),
    green: Color(0xFF53DE73),
    red: Color(0xFFFF5F5B),
    orange: Color(0xFFFF9F33),
    yellow: Color(0xFFFBD530),
    purple: Color(0xFFD07AF5),
    teal: Color(0xFF4DD4DB),
    gray: Color(0xFF8499A5),
  );

  // ----------------------------------------------------------------- Bosque
  // Verde abeto oscuro; acento esmeralda. El verde de "éxito" es más claro y
  // lima, así acento y estado nunca se confunden.
  static const AppPalette forest = AppPalette(
    id: AppThemeId.forest,
    brightness: Brightness.dark,
    background: Color(0xFF0E1D15),
    bar: Color(0xFF18271E),
    card: Color(0xFF202F27),
    elevated: Color(0xFF314138),
    separator: Color(0xFF2C3C33),
    fill: Color(0x26D1E3D8),
    chip: Color(0x1FFFFFFF),
    chipHover: Color(0x2EFFFFFF),
    label: Color(0xFFF3F8F5),
    secondaryLabel: Color(0xADD1E3D8),
    tertiaryLabel: Color(0x6BD1E3D8),
    labelSoft: Color(0xFFDEE5E1),
    icon: Color(0xFFBDC7C1),
    sunken: Color(0xFF122119),
    controlHover: Color(0xFF27372E),
    controlPressed: Color(0xFF2F3F36),
    elevatedHover: Color(0xFF3C4C43),
    overlayBase: Color(0xFFFFFFFF),
    blue: Color(0xFF0A8F5E),
    green: Color(0xFF53DE73),
    red: Color(0xFFFF5F5B),
    orange: Color(0xFFFF9F33),
    yellow: Color(0xFFFBD530),
    purple: Color(0xFFD07AF5),
    teal: Color(0xFF4DD4DB),
    gray: Color(0xFF8A9A91),
  );

  // ---------------------------------------------------------------- Violeta
  // Ciruela oscura; acento violeta y magenta rosado como secundario.
  static const AppPalette violet = AppPalette(
    id: AppThemeId.violet,
    brightness: Brightness.dark,
    background: Color(0xFF1C1627),
    bar: Color(0xFF251F31),
    card: Color(0xFF2E283A),
    elevated: Color(0xFF40394D),
    separator: Color(0xFF3A3447),
    fill: Color(0x26E0DBED),
    chip: Color(0x1FFFFFFF),
    chipHover: Color(0x2EFFFFFF),
    label: Color(0xFFF7F6FA),
    secondaryLabel: Color(0xADE0DBED),
    tertiaryLabel: Color(0x6BE0DBED),
    labelSoft: Color(0xFFE4E1E9),
    icon: Color(0xFFC5C2CC),
    sunken: Color(0xFF1F192B),
    controlHover: Color(0xFF352F42),
    controlPressed: Color(0xFF3D374A),
    elevatedHover: Color(0xFF4A4458),
    overlayBase: Color(0xFFFFFFFF),
    blue: Color(0xFF8C62E5),
    green: Color(0xFF53DE73),
    red: Color(0xFFFF5F5B),
    orange: Color(0xFFFF9F33),
    yellow: Color(0xFFFBD530),
    purple: Color(0xFFFB72C6),
    teal: Color(0xFF4DD4DB),
    gray: Color(0xFF9891A5),
  );

  static const AppPalette sand = AppPalette(
    id: AppThemeId.sand,
    brightness: Brightness.light,
    background: Color(0xFFF5EDE3),
    bar: Color(0xFFF0E8DE),
    card: Color(0xFFFCF7EE),
    elevated: Color(0xFFFFFBF1),
    separator: Color(0xFFDFD8CE),
    fill: Color(0x1F413226),
    chip: Color(0x12000000),
    chipHover: Color(0x1C000000),
    label: Color(0xFF30231B),
    secondaryLabel: Color(0xCC413226),
    tertiaryLabel: Color(0x75413226),
    labelSoft: Color(0xFF4D3F35),
    icon: Color(0xFF6E6055),
    sunken: Color(0xFFECE5DB),
    controlHover: Color(0xFFF3ECE1),
    controlPressed: Color(0xFFE9E2D7),
    elevatedHover: Color(0xFFF6EFE5),
    overlayBase: Color(0xFF000000),
    blue: Color(0xFFB4552D),
    green: Color(0xFF3E8343),
    red: Color(0xFFC8443A),
    orange: Color(0xFFB86A20),
    yellow: Color(0xFF95761A),
    purple: Color(0xFF904895),
    teal: Color(0xFF208085),
    gray: Color(0xFF8D8579),
  );

  // ------------------------------------------------------------------ Cacao
  // Tema oscuro CÁLIDO: chocolate y café con leche, texto crema y acento
  // cobre. La versión nocturna de Arena.
  static const AppPalette cocoa = AppPalette(
    id: AppThemeId.cocoa,
    brightness: Brightness.dark,
    background: Color(0xFF211711),
    bar: Color(0xFF291F18),
    card: Color(0xFF302822),
    elevated: Color(0xFF443932),
    separator: Color(0xFF3F342D),
    fill: Color(0x24ECDBC5),
    chip: Color(0x1FFFFFFF),
    chipHover: Color(0x2EFFFFFF),
    label: Color(0xFFF8F1E5),
    secondaryLabel: Color(0xB2ECDBC5),
    tertiaryLabel: Color(0x6BECDBC5),
    labelSoft: Color(0xFFE9E0D3),
    icon: Color(0xFFCFC2B3),
    sunken: Color(0xFF241B14),
    controlHover: Color(0xFF3A2F28),
    controlPressed: Color(0xFF42372F),
    elevatedHover: Color(0xFF4F443C),
    overlayBase: Color(0xFFFFFFFF),
    blue: Color(0xFFC7601F),
    green: Color(0xFF7ACF7E),
    red: Color(0xFFF5746D),
    orange: Color(0xFFFAA453),
    yellow: Color(0xFFF5D15C),
    purple: Color(0xFFD381D8),
    teal: Color(0xFF68CDD3),
    gray: Color(0xFF9C8F87),
  );
}