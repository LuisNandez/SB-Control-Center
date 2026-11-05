// lib/ui/theme/app_metrics.dart
//
// TAMAÑOS ÚNICOS del diseño Material (ver app_layout.dart).
//
// Cada tipo de elemento tiene UN solo tamaño en toda la app: todos los botones
// miden lo mismo, todos los interruptores miden lo mismo, todas las ventanas
// (diálogos) tienen el mismo ancho, todas las tarjetas el mismo redondeo, etc.
// Si quieres cambiar el tamaño de algo en TODA la app, cámbialo aquí.
//
// Con el diseño iOS nada de esto se usa: los widgets conservan sus medidas
// originales (por eso [radius] devuelve el valor original cuando no es Material).
import 'package:flutter/material.dart';
import 'app_layout.dart';
import 'minimal_style.dart';

class AppMetrics {
  AppMetrics._();

  /// true cuando el diseño activo es el Material.
  static bool get md => AppLayouts.isMaterial;

  static bool get minimal => AppLayouts.isMinimal;

  /// Con `true`, el diseño Material usaría sus propias medidas unificadas
  /// (alto 46, botones de icono 40, ventanas de 440...). Con `false` (valor
  /// actual) Material usa EXACTAMENTE las mismas medidas que el diseño iOS y
  /// solo cambia la forma y el estilo.
  static const bool useMaterialSizes = false;

  /// true solo si hay que aplicar medidas propias de Material.
  static bool get u => md && useMaterialSizes;

  // ------------------------------------------------------------ Controles
  /// Alto de TODOS los botones con texto, campos de texto, búsqueda, pestañas,
  /// selectores y botones de diálogo.
  static const double controlHeight = 34;

  /// Lado de TODOS los botones de icono (barra superior, tarjetas, listas,
  /// paneles, descargas...).
  static const double iconButton = 32;

  /// Alto de TODAS las etiquetas / chips / insignias.
  static const double chipHeight = 24;

  /// Tamaño del interruptor (el de Material mide 52x32): el mismo en las
  /// tarjetas, la lista, los ajustes y los paneles.
  static const double switchWidth = 51;
  static const double switchHeight = 31;

  /// Alto mínimo de TODAS las filas (ajustes, listas de selección).
  static const double tileMinHeight = 48;

  /// Tamaño del icono dentro de los botones de icono y de las filas.
  static const double iconSize = 20;
  static const double smallIconSize = 18;

  // ------------------------------------------------------------- Ventanas
  /// Ancho de TODAS las ventanas (diálogos) normales.
  static const double dialogWidth = 440;

  /// Los diálogos que piden más de [_dialogWideThreshold] px (editor de
  /// portada, notas de versión, lista de instalación...) necesitan sitio para
  /// su contenido y conservan su ancho.
  static const double _dialogWideThreshold = 520;

  static double dialogWidthFor(double requested) => requested;

  // -------------------------------------------------------- Notificaciones
  /// Ancho de TODAS las notificaciones emergentes.
  static const double notificationWidth = 360;

  // ------------------------------------------------------------ Espaciado
  /// Relleno interior de TODAS las tarjetas y grupos.
  static const double cardPadding = 14;

  /// Separación entre tarjetas (cuadrícula y lista).
  static const double cardGap = 14;

  static double get smallRadius => minimal ? 4 : 8; // chips, insignias, miniaturas
  static double get controlRadius => minimal ? MinimalStyle.controlRadius : 12; // botones, campos, filas
  static double get cardRadius => minimal ? MinimalStyle.cardRadius : 16; // tarjetas, grupos, paneles
  static double get dialogRadius => minimal ? MinimalStyle.dialogRadius : 28; // ventanas (diálogos)

  static BorderRadius radius(double ios) => BorderRadius.circular(radiusValue(ios));

  static double radiusValue(double ios) {
    if (!md) return ios;
    if (ios <= 4) return ios; // marcadores diminutos (barras, asas)
    if (ios <= 8.5) return smallRadius;
    if (ios <= 12) return controlRadius;
    if (ios <= 16) return cardRadius;
    return minimal ? controlRadius : smallRadius;
  }

  /// Esquinas superiores de las hojas inferiores (panel de detalles, selector
  /// de trajes, panel de instalación): una sola medida en Material.
  static BorderRadius sheetRadius(double ios) =>
      BorderRadius.vertical(top: Radius.circular(md ? dialogRadius : ios));

  static double get hairline => md ? 1 : 0.5;
}