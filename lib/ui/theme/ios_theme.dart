// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'app_layout.dart';
import 'app_metrics.dart';
import 'app_themes.dart';

/// Colores semánticos de la interfaz.
///
/// Todos son getters que leen la paleta activa ([AppPalette]); al cambiar de
/// tema con [IosColors.apply] y reconstruir la interfaz, TODA la app cambia.
/// Por eso ya no se pueden usar dentro de expresiones `const`.
/// Para cambiar el color de acento de un tema, edita su `blue` en app_themes.dart.
class IosColors {
  IosColors._();

  static AppPalette _p = AppThemes.dark;

  /// Paleta activa.
  static AppPalette get palette => _p;

  /// Activa una paleta (la interfaz debe reconstruirse después).
  static void apply(AppPalette palette) => _p = palette;

  // Superficies
  static Color get background => _p.background; // fondo de ventana
  static Color get bar => _p.bar; // barra superior
  static Color get card => _p.card; // tarjetas / filas
  static Color get elevated => _p.elevated; // menús, popovers
  static Color get separator => _p.separator;
  static Color get sunken => _p.sunken; // más hundido que la tarjeta
  static Color get controlHover => _p.controlHover;
  static Color get controlPressed => _p.controlPressed;
  static Color get elevatedHover => _p.elevatedHover;

  // Rellenos translúcidos (campos de búsqueda, segmentados, chips)
  static Color get fill => _p.fill;
  static Color get chip => _p.chip;
  static Color get chipHover => _p.chipHover;

  /// Resaltado translúcido con [alpha] (0-255): blanco en temas oscuros y
  /// negro en los claros. Sustituye a `Color(0x14FFFFFF)` y similares.
  static Color overlay(int alpha) => _p.overlayBase.withAlpha(alpha);

  /// Igual que [overlay] pero con opacidad 0.0-1.0
  /// (sustituye a `Colors.white.withOpacity(x)`).
  static Color tint(double opacity) => _p.overlayBase.withOpacity(opacity);

  // Texto
  static Color get label => _p.label;
  static Color get secondaryLabel => _p.secondaryLabel;
  static Color get tertiaryLabel => _p.tertiaryLabel;
  static Color get labelSoft => _p.labelSoft;
  static Color get icon => _p.icon;

  // Colores de sistema
  static Color get blue => _p.blue; // acento
  static Color get green => _p.green;
  static Color get red => _p.red;
  static Color get orange => _p.orange;
  static Color get yellow => _p.yellow;
  static Color get purple => _p.purple;
  static Color get teal => _p.teal;
  static Color get gray => _p.gray;
}

class IosTheme {
  IosTheme._();

  /// Tema oscuro original (compatibilidad).
  static ThemeData dark() => build(AppThemes.dark);

  /// Construye el [ThemeData] de Material a partir de una paleta.
  static ThemeData build(AppPalette p) {
    final bool isDark = p.isDark;
    final bool md = AppMetrics.md;
    final bool u = AppMetrics.u;

    // Esquema COMPLETO: si solo se rellenan unos pocos roles, los widgets de
    // Material (menús, campos, chips, ondas...) heredan los morados por defecto
    // de M3 y rompen la armonía del tema. Aquí todos los roles salen de la paleta.
    final ColorScheme scheme = (isDark ? const ColorScheme.dark() : const ColorScheme.light())
        .copyWith(
      primary: p.blue,
      onPrimary: Colors.white,
      primaryContainer: Color.alphaBlend(p.blue.withOpacity(isDark ? 0.28 : 0.16), p.card),
      onPrimaryContainer: p.label,
      secondary: p.blue,
      onSecondary: Colors.white,
      secondaryContainer: p.chip,
      onSecondaryContainer: p.label,
      tertiary: p.teal,
      onTertiary: isDark ? Colors.black : Colors.white,
      error: p.red,
      onError: Colors.white,
      surface: p.card,
      onSurface: p.label,
      onSurfaceVariant: p.secondaryLabel,
      surfaceDim: p.background,
      surfaceBright: p.elevated,
      surfaceContainerLowest: p.sunken,
      surfaceContainerLow: p.background,
      surfaceContainer: p.card,
      surfaceContainerHigh: p.elevated,
      surfaceContainerHighest: p.elevatedHover,
      outline: p.overlayBase.withOpacity(0.28),
      outlineVariant: p.separator,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: p.label,
      onInverseSurface: p.background,
      inversePrimary: p.blue,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      brightness: p.brightness,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.card,
      cardColor: p.card,
      primaryColor: p.blue,
      dividerColor: p.separator,
      dividerTheme: DividerThemeData(
        color: p.separator,
        thickness: 0.5,
        space: 1,
      ),

      // iOS/macOS: sin ondas, resaltados suaves. Material: ondas de Material.
      splashFactory: md && !AppLayouts.isMinimal ? InkRipple.splashFactory : NoSplash.splashFactory,
      highlightColor: md ? null : Colors.transparent,
      hoverColor: p.overlayBase.withAlpha(0x0F),

      // iOS: SF Pro si existe en el sistema; si no, la mejor fuente disponible.
      // Material: la fuente del sistema (Roboto / Segoe UI).
      fontFamily: md ? null : 'SF Pro Text',
      fontFamilyFallback: md
          ? null
          : const [
              'SF Pro Display',
              '.AppleSystemUIFont',
              'Segoe UI Variable Text',
              'Segoe UI',
            ],

      appBarTheme: AppBarTheme(
        backgroundColor: p.bar,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: u ? 22 : 15,
          fontWeight: u ? FontWeight.w400 : FontWeight.w600,
          letterSpacing: u ? 0 : -0.2,
          color: p.label,
        ),
        iconTheme: IconThemeData(color: p.icon),
      ),

      // Botones: con Material TODOS miden lo mismo (alto y redondeo únicos).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: u ? const Size(64, AppMetrics.controlHeight) : null,
          padding: u
              ? const EdgeInsets.symmetric(horizontal: 20)
              : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: TextStyle(
            fontSize: u ? 15 : 14,
            fontWeight: FontWeight.w600,
            letterSpacing: u ? 0 : -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              md ? AppMetrics.controlRadius : 10,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.blue,
          minimumSize: u ? const Size(64, AppMetrics.controlHeight) : null,
          padding: u ? const EdgeInsets.symmetric(horizontal: 20) : null,
          textStyle: TextStyle(
            fontSize: u ? 15 : 14,
            fontWeight: u ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: u ? 0 : -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              md ? AppMetrics.controlRadius : 8,
            ),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.blue,
          foregroundColor: Colors.white,
          minimumSize: u ? const Size(64, AppMetrics.controlHeight) : null,
          padding: u ? const EdgeInsets.symmetric(horizontal: 20) : null,
          textStyle: TextStyle(
            fontSize: u ? 15 : 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              md ? AppMetrics.controlRadius : 10,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.blue,
          minimumSize: u ? const Size(64, AppMetrics.controlHeight) : null,
          padding: u ? const EdgeInsets.symmetric(horizontal: 20) : null,
          side: BorderSide(color: p.overlayBase.withAlpha(0x38), width: 1),
          textStyle: TextStyle(
            fontSize: u ? 15 : 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              md ? AppMetrics.controlRadius : 10,
            ),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: u
              ? const Size(AppMetrics.iconButton, AppMetrics.iconButton)
              : null,
          fixedSize: u
              ? const Size(AppMetrics.iconButton, AppMetrics.iconButton)
              : null,
          iconSize: u ? AppMetrics.iconSize : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              md ? AppMetrics.controlRadius : 8,
            ),
          ),
        ),
      ),

      // Menús desplegables estilo macOS.
      popupMenuTheme: PopupMenuThemeData(
        color: p.elevated,
        elevation: AppLayouts.isMinimal ? 0 : 16,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
                  color: p.overlayBase.withAlpha(0x1F),
                  width: u ? 1 : 0.5,
                ),
        ),
        textStyle: TextStyle(
          fontSize: u ? 14 : 13,
          color: p.label,
          letterSpacing: u ? 0 : -0.1,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        padding: u
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: p.elevated.withOpacity(0.95),
          borderRadius: BorderRadius.circular((md ? AppMetrics.smallRadius : 7)),
          border: Border.all(
                  color: p.overlayBase.withAlpha(0x1F),
                  width: u ? 1 : 0.5,
                ),
        ),
        textStyle: TextStyle(fontSize: u ? 13 : 12, color: p.label),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.elevated,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(fontSize: u ? 14 : 13, color: p.label),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            md ? AppMetrics.cardRadius : 12,
          ),
        ),
      ),

      bottomSheetTheme: md
          ? BottomSheetThemeData(
              backgroundColor: p.background,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: AppMetrics.sheetRadius(14),
              ),
            )
          : null,

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.blue,
        linearTrackColor: p.overlayBase.withOpacity(0.12),
      ),

      // Selección y cursor con el acento del tema.
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.blue,
        selectionColor: p.blue.withOpacity(0.35),
        selectionHandleColor: p.blue,
      ),

      // Barras de desplazamiento discretas, del mismo tono que el texto.
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => p.overlayBase.withOpacity(
            states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.dragged)
                ? 0.38
                : 0.22,
          ),
        ),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),

      // Casillas e interruptores nativos de Material con el acento.
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.blue : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: p.tertiaryLabel, width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.green : p.overlayBase.withOpacity(0.22),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),


      // iOS: al abrir otra pantalla (p. ej. Ajustes) se desliza como en iOS.
      // Material: transición de zoom + fundido propia de Material.
      pageTransitionsTheme: md
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.windows: ZoomPageTransitionsBuilder(),
                TargetPlatform.linux: ZoomPageTransitionsBuilder(),
                TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
                TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(
              builders: {
                TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
                TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
    );
  }
}