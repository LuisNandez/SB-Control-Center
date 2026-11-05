// lib/config/app_prefs.dart

class AppPrefs {
  static const String languageCode = 'languageCode';
  /// Tema de colores elegido (nombre de [AppThemeId]: system, dark, midnight, light...).
  static const String themeId = 'themeId';
  /// Diseño de la interfaz elegido (nombre de [AppLayoutId]: ios, material,
  /// minimal; en la interfaz se llaman Estilo macOS, Material y Plano).
  static const String layoutId = 'layoutId';
  /// Ajustes → "Usar la tarjeta gráfica": pide a Windows que ejecute la app con
  /// la GPU de alto rendimiento (por defecto: desactivada).
  static const String useGpuAcceleration = 'useGpuAcceleration';
  /// Datos que tenía la entrada de GPU de Windows para esta app ANTES de activar
  /// la opción anterior (se restauran al desactivarla; ausente = no había).
  static const String gpuPreviousPreference = 'gpuPreviousPreference';
  /// Ajustes → Apariencia → "Recordar tamaño y posición": la ventana se abre
  /// como se dejó la última vez (por defecto: activada).
  static const String rememberWindowState = 'rememberWindowState';
  /// Último tamaño/posición de la ventana (JSON: x, y, w, h, max). Lo gestiona
  /// [WindowStateService].
  static const String windowState = 'windowState';
  static const String gameRootPath = 'gameRootPath';
  static const String sevenZipPath = 'sevenZipPath';
  static const String nexusApiKey = 'nexusApiKey';
  static const String skippedVersions = 'skippedVersions';
  static const String filterMode = 'filterMode';
  static const String modTypeFilterMode = 'modTypeFilterMode';
  static const String sortMode = 'sortMode';
  /// Orden manual de los mods: nombres de carpeta en el orden elegido por el
  /// usuario arrastrando (se usa con ModSort.custom).
  static const String customModOrder = 'customModOrder';
  static const String viewMode = 'viewMode';
  static const String showModTypeTags = 'showModTypeTags';
  /// Asignación automática de trajes al instalar mods de reemplazo (por defecto: activada).
  static const String autoAssignOutfits = 'autoAssignOutfits';
  /// El usuario marcó "No volver a mostrar este mensaje" en el aviso que
  /// invita a configurar la API key de Nexus al abrir la app.
  static const String hideApiKeyPrompt = 'hideApiKeyPrompt';
  /// Versión de la app que el usuario eligió "Omitir".
  static const String skippedAppVersion = 'skippedAppVersion';
  /// Notas de la versión que se está instalando; se muestran al abrir la app
  /// ya actualizada (JSON: from, version, name, notes, url).
  static const String pendingChangelog = 'pendingChangelog';
  /// Última lista de releases descargada (para ver el changelog sin conexión).
  static const String releasesCache = 'releasesCache';
}