// lib/config/app_prefs.dart

class AppPrefs {
  static const String languageCode = 'languageCode';
  static const String gameRootPath = 'gameRootPath';
  static const String sevenZipPath = 'sevenZipPath';
  static const String nexusApiKey = 'nexusApiKey';
  static const String skippedVersions = 'skippedVersions';
  static const String filterMode = 'filterMode';
  static const String modTypeFilterMode = 'modTypeFilterMode';
  static const String sortMode = 'sortMode';
  static const String viewMode = 'viewMode';
  static const String showModTypeTags = 'showModTypeTags';
  /// Asignación automática de trajes al instalar mods de reemplazo (por defecto: activada).
  static const String autoAssignOutfits = 'autoAssignOutfits';
  /// El usuario marcó "No volver a mostrar este mensaje" en el aviso que
  /// invita a configurar la API key de Nexus al abrir la app.
  static const String hideApiKeyPrompt = 'hideApiKeyPrompt';
  /// Versión de la app que el usuario eligió "Omitir".
  static const String skippedAppVersion = 'skippedAppVersion';
}