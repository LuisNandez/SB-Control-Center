// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDesc => 'Elige el idioma de la aplicación';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutDesc => 'Información sobre la aplicación';

  @override
  String get settingsRefreshMetadata => 'Actualizar metadatos';

  @override
  String get settingsRefreshMetadataDesc =>
      'Vuelve a revisar tus mods en Nexus Mods y completa los datos e imágenes que falten';

  @override
  String get metadataRefreshDone => 'Metadatos actualizados';

  @override
  String get metadataRefreshNoApiKey =>
      'Introduce tu API key de Nexus Mods en Ajustes para actualizar los metadatos.';

  @override
  String get settingsPathsAndTools => 'Rutas y Herramientas';

  @override
  String get settingsGameFolder => 'Carpeta del Juego';

  @override
  String get settingsGameFolderDesc =>
      'La carpeta raíz de tu instalación de Stellar Blade.';

  @override
  String get settings7zipPath => 'Ruta de 7-Zip';

  @override
  String get settings7zipPathDesc =>
      'La ubicación del archivo 7z.exe para extraer mods.';

  @override
  String get settings7zipPathAuto => 'Búsqueda automática';

  @override
  String get settingsRepairMods => 'Reparar Mods Heredados';

  @override
  String get settingsRepairModsDesc =>
      'Escanea y crea archivos de información para mods antiguos usando la base de datos local. Requiere clave de API.';

  @override
  String get settingsConnectivity => 'Conectividad y Actualizaciones';

  @override
  String get settingsApiKey => 'Clave de API de Nexus Mods';

  @override
  String get settingsApiKeyDesc =>
      'Necesaria para comprobar las actualizaciones de los mods.';

  @override
  String get settingsApiKeySet => 'Establecida';

  @override
  String get settingsApiKeyNotSet => 'No establecida';

  @override
  String get settingsSkippedVersions => 'Gestionar Versiones Omitidas';

  @override
  String get settingsSkippedVersionsDesc =>
      'Gestiona las versiones de mods que has decidido omitir.';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count versiones omitidas';
  }

  @override
  String get dialogTitleSkippedVersions => 'Versiones de Mod Omitidas';

  @override
  String get dialogNoSkippedVersions =>
      'No has omitido ninguna versión de mod.';

  @override
  String get dialogSkippedVersions => 'Versión Omitida';

  @override
  String get dialogTitleRepairMods => '¿Ejecutar Reparación de Mods Heredados?';

  @override
  String get dialogContentRepairMods =>
      'Advertencia: Esta función está en desarrollo y puede no ser perfecta.\n\nEscaneará los mods sin un archivo \'nexus_info.json\' y, si se encuentra en tu base de datos local, creará uno para ellos. También intentará renombrar la carpeta del mod para incluir la versión encontrada (ej., \'Mi Mod\' -> \'Mi Mod v1.2\').\n\nPrioridad de Versión:\n1. Del nombre de la carpeta.\n2. Del campo de descripción del mod.\n3. De la última versión en Nexus Mods (requiere API).\n\n¿Deseas continuar?';

  @override
  String get dialogActionRunRepair => 'Ejecutar Reparación';

  @override
  String get snackBarGamePathInvalid =>
      'La carpeta seleccionada no parece ser una carpeta de juego válida.';

  @override
  String get snackBar7zipPathInvalid =>
      'El archivo seleccionado debe llamarse 7z.exe.';

  @override
  String get snackBarRepairStarted =>
      'El proceso de reparación de mods heredados ha comenzado...';

  @override
  String snackBarRepairComplete(Object count) {
    return 'Reparación completa. Se actualizaron $count mod(s).';
  }

  @override
  String get snackBarRepairNoMods =>
      'No se encontraron mods heredados que necesitaran reparación.';

  @override
  String get errorApiRequiredForRepair =>
      'Se requiere una clave de API para encontrar la última versión de los mods sin una versión local.';

  @override
  String get installNewMod => 'Instalar Mod';

  @override
  String get selectFiles => 'Seleccionar Archivos';

  @override
  String get selectFolder => 'Seleccionar Carpeta';

  @override
  String get installSelectedMod => 'Instalar Mod Seleccionado';

  @override
  String get filesToInstall => 'Archivos a Instalar:';

  @override
  String get cancelSelection => 'Cancelar Selección';

  @override
  String get searchMods => 'Buscar mods...';

  @override
  String get enabledMods => 'Mods Activados';

  @override
  String get disabledMods => 'Mods Desactivados';

  @override
  String get refreshList => 'Actualizar lista';

  @override
  String get noEnabledMods => 'No hay mods activados.';

  @override
  String get noDisabledMods => 'No hay mods desactivados.';

  @override
  String get showInFolder => 'Mostrar en carpeta';

  @override
  String get disableMod => 'Desactivar mod';

  @override
  String get enableMod => 'Activar mod';

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecciona un idioma';

  @override
  String get statusSearchingGame =>
      'Buscando la instalación de Stellar Blade...';

  @override
  String get statusGamePathFound => '¡Ruta del juego encontrada!';

  @override
  String get statusGamePathNotFound =>
      'No se pudo encontrar la ruta del juego automáticamente.';

  @override
  String statusErrorFindingGame(Object error) {
    return 'Ocurrió un error al buscar el juego: $error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount mod(s) activado(s), $disabledCount desactivado(s).';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return 'Error al leer los mods instalados: $error';
  }

  @override
  String statusFilesSelected(Object count) {
    return '$count archivo(s) seleccionado(s). Listo para instalar.';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return 'Carpeta \"$folderName\" seleccionada. Lista para instalar.';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return 'Archivo \"$fileName\" cargado. $count archivo(s) listos para instalar.';
  }

  @override
  String get statusSelectionCancelled =>
      'Selección cancelada. Elige un nuevo mod para instalar.';

  @override
  String get statusUpdateComplete => 'Actualización completa.';

  @override
  String get statusInstallationComplete => 'Instalación completa.';

  @override
  String statusError(Object error) {
    return 'Error: $error';
  }

  @override
  String get dialogTitle7zip => 'Se Requiere 7-Zip';

  @override
  String get dialogContent7zip =>
      'Para descomprimir este archivo, la aplicación necesita 7-Zip.\n\nPor favor, instálalo desde su página oficial y luego presiona \"Confirmar\".';

  @override
  String get dialogContent7zipNotFound =>
      'Aún no se ha detectado 7-Zip. Por favor, asegúrate de que esté instalado en la ruta predeterminada e inténtalo de nuevo.';

  @override
  String get dialogTitleMultipleJsons => 'Múltiples Archivos .json Detectados';

  @override
  String dialogContentMultipleJsons(Object count) {
    return 'Se han detectado $count archivos .json. Podría ser un mod con múltiples componentes.\n\n¿Quieres instalarlos todos juntos en una sola carpeta de mod?';
  }

  @override
  String get dialogTitleModExists => 'El Mod ya Existe';

  @override
  String dialogContentModExists(Object modName) {
    return 'Ya hay un mod llamado \"$modName\" instalado.\n\n¿Quieres actualizarlo? Los archivos antiguos se eliminarán antes de instalar los nuevos.';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return 'Se encontró una versión anterior \'$oldModName\'.\n\n¿Quieres eliminarla y actualizar a \'$newModName\'?';
  }

  @override
  String get dialogTitleDeleteMod => '¿Eliminar Permanentemente?';

  @override
  String dialogContentDeleteMod(Object modName) {
    return 'Estás a punto de eliminar permanentemente el mod \"$modName\". Esta acción no se puede deshacer.\n\n¿Estás seguro?';
  }

  @override
  String get dialogActionCancel => 'Cancelar';

  @override
  String get dialogActionGoToDownload => 'Ir a la Página de Descarga';

  @override
  String get dialogActionConfirmInstallation => 'Confirmar Instalación';

  @override
  String get dialogActionUpdateSystem => 'Actualizar Sistema';

  @override
  String get dialogActionInstallAnyway => 'Instalar de Todos Modos';

  @override
  String get dialogActionDelete => 'Eliminar';

  @override
  String get dialogActionClose => 'Cerrar';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return 'Instalación por lotes completa. Éxito: $successCount, Fallidos: $failedCount.';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return 'Mod \"$modName\" instalado con éxito.';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return 'Mod \"$modName\" activado.';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return 'Mod \"$modName\" desactivado.';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return 'Mod \"$modName\" eliminado permanentemente.';
  }

  @override
  String get snackBarCNSUpdated =>
      'Custom Nanosuit System actualizado con éxito.';

  @override
  String get snackBarApiKeySaved => 'Clave de API guardada con éxito.';

  @override
  String get snackBarGamePathSaved => 'Ruta del juego guardada con éxito.';

  @override
  String get snackBar7zipPathSaved => 'Ruta de 7-Zip guardada con éxito.';

  @override
  String get snackBarSkippedVersionRemoved => 'Versión omitida eliminada.';

  @override
  String get dropTargetOverlay => 'Arrastra los mods aquí';

  @override
  String get pathSelectionTitle => 'Ruta de Stellar Blade no Encontrada';

  @override
  String get pathSelectionButtonManual =>
      'Seleccionar Carpeta del Juego Manualmente';

  @override
  String get pathSelectionButtonRetry => 'Intentar de Nuevo';

  @override
  String errorFolderSelection(Object error) {
    return 'Error al seleccionar la carpeta: $error';
  }

  @override
  String errorFileSelection(Object error) {
    return 'Error al seleccionar archivos: $error';
  }

  @override
  String errorDecompressing(Object error) {
    return 'Error al descomprimir el archivo: $error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return 'Error al procesar el archivo: $error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return 'Formato de archivo no soportado: $extension';
  }

  @override
  String get error7zipRequired => 'Operación cancelada: se requiere 7-Zip.';

  @override
  String get errorGamePathUndefined => 'La ruta del juego no está definida.';

  @override
  String get errorDestinationNotFound =>
      'La carpeta de destino del juego no existe.';

  @override
  String errorUpdateSystem(Object error) {
    return 'Error al actualizar el sistema: $error';
  }

  @override
  String get errorInstallNoSelection =>
      'No has seleccionado nada para instalar.';

  @override
  String get errorInstallModExists =>
      'Instalación cancelada: el mod ya existe.';

  @override
  String get errorNoJsonFound =>
      'Cada mod debe contener al menos un archivo .json.';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return 'El archivo $fileName tiene un formato JSON inválido.';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return 'El archivo $fileName no parece ser un mod de Custom Nanosuit System (falta \"DisplayName\").';
  }

  @override
  String get errorNoValidDisplayName =>
      'No se encontró un \"DisplayName\" válido en los archivos .json.';

  @override
  String errorEnableMod(Object error) {
    return 'Error al activar el mod: $error';
  }

  @override
  String errorDisableMod(Object error) {
    return 'Error al desactivar el mod: $error';
  }

  @override
  String errorDeleteMod(Object error) {
    return 'Error al eliminar el mod: $error';
  }

  @override
  String errorOpenFolder(Object path) {
    return 'No se pudo abrir la carpeta: $path';
  }

  @override
  String get statusUpdateSystemCancelled =>
      'Actualización del sistema cancelada.';

  @override
  String get statusUpdatingCNS => 'Actualizando Custom Nanosuit System...';

  @override
  String statusExtractingFile(Object fileName) {
    return 'Extrayendo $fileName...';
  }

  @override
  String get statusInstallationCancelledByUser =>
      'Instalación cancelada por el usuario.';

  @override
  String get errorNoCompatibleFilesInFolder =>
      'La carpeta seleccionada no contiene archivos de mod compatibles.';

  @override
  String get errorNoCompatibleFilesInArchive =>
      'El archivo comprimido no contiene archivos de mod compatibles.';

  @override
  String get errorNoJsonInSelection =>
      'La selección no contiene un archivo .json de mod válido.';

  @override
  String get aboutTitle => 'Acerca de SB Control Center';

  @override
  String get aboutContent =>
      'SB Control Center es un gestor de mods para Stellar Blade. Instala, organiza y actualiza tus mods en un solo lugar, y funciona con el Custom Nanosuit System (CNS) para los mods de trajes y nanosuit.\n\nSe conecta con Nexus Mods para descargar, buscar actualizaciones y endorsar los mods que usas.\n\nIncluye 7-Zip (7-zip.org) para extraer archivos .zip, .rar y .7z.';

  @override
  String get aboutEndorseCta =>
      '¿Te gusta la app? Un Endorse en Nexus Mods ayuda mucho.';

  @override
  String get aboutEndorseThanks => '¡Gracias por tu apoyo!';

  @override
  String get aboutLinkText => 'Visita mi perfil de creador';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return 'Versión: $version';
  }

  @override
  String get openModsFolder => 'Abrir Carpeta de Mods';

  @override
  String get openInNexusMods => 'Abrir en Nexus Mods';

  @override
  String get checkForUpdates => 'Buscar actualizaciones';

  @override
  String updateAvailable(Object version) {
    return 'Actualización disponible: v$version';
  }

  @override
  String get dialogTitleApiKey => 'Clave de API de Nexus Mods';

  @override
  String get dialogContentApiKey =>
      'Para buscar actualizaciones de mods, necesitas una clave de API personal de Nexus Mods.';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. Pulsa el botón de abajo para abrir Nexus Mods e inicia sesión.\n2. Baja hasta el final de la página, a la sección \'Personal API Key\'.\n3. Solicítala si aún no la tienes y cópiala.\n4. Pégala aquí.';

  @override
  String get apiKeyOpenNexusPage => 'Abrir página de claves de API';

  @override
  String get apiKey => 'Clave de API';

  @override
  String get apiKeyHintText => 'Pega tu clave de API aquí';

  @override
  String get dialogActionSave => 'Guardar';

  @override
  String get apiKeyRemoved => 'Clave de API eliminada.';

  @override
  String get invalidApiKeyError => 'Clave de API inválida.';

  @override
  String get validatingApiKey => 'Validando...';

  @override
  String get errorApiKeyMissing =>
      'Falta la clave de API de Nexus Mods. Añádela en Ajustes › Conectividad y Actualizaciones › Clave de API de Nexus Mods.';

  @override
  String get statusCheckingUpdates => 'Buscando actualizaciones de mods...';

  @override
  String statusUpdatesFound(Object count) {
    return '¡Se encontraron $count actualización(es)!';
  }

  @override
  String get statusNoUpdates => 'Todos los mods están actualizados.';

  @override
  String get selectModArchive => 'Seleccionar Archivo de Mod';

  @override
  String get viewImageGallery => 'Ver Galería de Imágenes';

  @override
  String get imageGallery => 'Galería de Imágenes';

  @override
  String get noImagesFound =>
      'No se encontraron imágenes para este mod, o la clave de API no ha sido ingresada. Por favor, ingresa la clave de API y busca actualizaciones después.';

  @override
  String errorFetchingImages(Object error) {
    return 'Error al obtener las imágenes: $error';
  }

  @override
  String get imageMod => 'Imagen del Mod';

  @override
  String get modEnabledBadge => 'Activado';

  @override
  String get modDisabledBadge => 'Desactivado';

  @override
  String get modCategoryOther => 'Sin especificar';

  @override
  String get dialogContentUpdateOptions => '¿Qué te gustaría hacer?';

  @override
  String get dialogActionIgnoreVersion => 'Ignorar';

  @override
  String get dialogActionSkipVersion => 'Omitir Versión';

  @override
  String get dialogActionGoToDownloadPage => 'Ir a Descargar';

  @override
  String get installedMods => 'Mods Instalados';

  @override
  String get filterBy => 'Filtrar por:';

  @override
  String get sortBy => 'Ordenar por:';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterEnabled => 'Activados';

  @override
  String get filterDisabled => 'Desactivados';

  @override
  String get filterRepaired => 'Reparados';

  @override
  String get sortByName => 'Nombre';

  @override
  String get sortByDate => 'Fecha';

  @override
  String get noModsFound => 'No se encontraron mods.';

  @override
  String get viewTypeGrid => 'Vista de cuadrícula';

  @override
  String get viewTypeList => 'Vista de lista';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return 'Extrayendo $count de $total: $fileName';
  }

  @override
  String get previewInstallTitle => 'Mods a Instalar:';

  @override
  String get dialogTitleUE4SS => 'Instalación de UE4SS Detectada';

  @override
  String get dialogContentUE4SS =>
      'Se ha detectado la herramienta UE4SS. ¿Deseas instalarla en \'StellarBlade\\SB\\Binaries\\Win64\'?\n\nEsto es necesario para que muchos mods funcionen.';

  @override
  String get dialogActionInstallTool => 'Instalar Herramienta';

  @override
  String get statusUE4SSInstallCancelled => 'Instalación de UE4SS cancelada.';

  @override
  String get statusInstallingUE4SS => 'Instalando UE4SS...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SS instalado con éxito.';

  @override
  String error7zipDecompression(Object error) {
    return 'Error de 7-Zip durante la descompresión: $error';
  }

  @override
  String get statusUE4SSInstallComplete => 'Instalación de UE4SS completa.';

  @override
  String get dialogTitleAlternativeVersion => 'Versión Alternativa Detectada';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return 'Ya hay instalada una versión alternativa de este mod: \'$oldModName\'.\n\nEstás a punto de instalar una alternativa diferente llamada \'$newModName\'.';
  }

  @override
  String get dialogActionReplace => 'Reemplazar';

  @override
  String get dialogActionInstallAsNew => 'Instalar como Nuevo';

  @override
  String get dialogTitleUpdate => 'Actualización Disponible';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Estás a punto de actualizar el mod \'$modName\'.\n\nVersión instalada: $oldVersion\nNueva versión: $newVersion';
  }

  @override
  String get dialogTitleDowngrade => 'Versión Anterior Detectada';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Advertencia: Estás a punto de instalar una versión anterior del mod \'$modName\'.\n\nVersión instalada: $oldVersion\nVersión a instalar: $newVersion';
  }

  @override
  String get dialogTitleReinstall => 'Reinstalar Mod';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return 'Estás a punto de reinstalar la versión \'$version\' del mod \'$modName\'.';
  }

  @override
  String get dialogActionReinstall => 'Reinstalar';

  @override
  String get editModNameTooltip => 'Editar nombre del mod';

  @override
  String get setCoverTooltip => 'Establecer imagen de portada personalizada';

  @override
  String get setCoverText => 'Establecer Portada';

  @override
  String get restoreOriginalCoverText => 'Restaurar Portada Original';

  @override
  String errorSavingCoverText(Object error) {
    return 'Error al guardar la imagen de portada: $error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return 'Error al restaurar la imagen de portada original: $error';
  }

  @override
  String get editVersionText => 'Editar Versión';

  @override
  String get customVersionText => 'Versión Personalizada';

  @override
  String get editTagText => 'Editar Etiqueta';

  @override
  String get customTagText => 'Etiqueta Personalizada';

  @override
  String get dialogTitleEditModName => 'Editar Nombre del Mod';

  @override
  String get dialogActionResetToDefault => 'Restablecer a Predeterminado';

  @override
  String get dialogLabelNewName => 'Nuevo nombre';

  @override
  String errorModNameExists(Object modName) {
    return 'Ya existe un mod con el nombre \"$modName\".';
  }

  @override
  String get dialogTitleRepairedModWarning => 'Advertencia de Mod Reparado';

  @override
  String get dialogContentRepairedModWarning =>
      'Este mod podría no tener la información de versión correcta. Se recomienda reinstalar la última versión para asegurar la compatibilidad.';

  @override
  String get repairedModTooltip => 'Información sobre el mod reparado';

  @override
  String get disableAllModsTooltip => 'Desactivar todos los mods';

  @override
  String get deleteAllModsTooltip => 'Eliminar todos los mods desactivados';

  @override
  String get dialogTitleDisableAll => '¿Desactivar Todos los Mods?';

  @override
  String dialogContentDisableAll(int count) {
    return '¿Estás seguro de que quieres desactivar los $count mods activados? Se moverán a la carpeta de respaldo.';
  }

  @override
  String get dialogTitleDeleteAll => '¿Eliminar Mods Desactivados?';

  @override
  String dialogContentDeleteAll(int count) {
    return 'Estás a punto de eliminar permanentemente los $count mods desactivados. Esta acción no se puede deshacer.\n\n¿Estás seguro?';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return 'Se han desactivado los $count mods activados.';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return 'Se han eliminado permanentemente los $count mods desactivados.';
  }

  @override
  String get snackBarNoModsToDisable =>
      'No hay mods activados para desactivar.';

  @override
  String get snackBarNoModsToDelete =>
      'No hay mods desactivados para eliminar.';

  @override
  String get enableAllModsTooltip => 'Activar todos los mods';

  @override
  String get dialogTitleEnableAll => '¿Activar Todos los Mods?';

  @override
  String dialogContentEnableAll(int count) {
    return '¿Estás seguro de que quieres activar los $count mods desactivados? Se moverán a la carpeta principal de mods.';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return 'Se han activado los $count mods desactivados.';
  }

  @override
  String get snackBarNoModsToEnable => 'No hay mods desactivados para activar.';

  @override
  String get editNotes => 'Editar Notas';

  @override
  String get notesHintText => 'Añade tus notas personales aquí...';

  @override
  String get modAuthor => 'Autor';

  @override
  String get modSummary => 'Resumen';

  @override
  String get modDescription => 'Descripción';

  @override
  String get noDescriptionAvailable => 'No hay descripción disponible.';

  @override
  String get personalNotes => 'Notas Personales';

  @override
  String get noNotesAvailable => 'Aún no se han añadido notas.';

  @override
  String get modDetailsTitle => 'Detalles del Mod';

  @override
  String get modVersion => 'Versión';

  @override
  String get modCategory => 'Categoría';

  @override
  String get dialogTitleAddUrl => 'Añadir Enlace del Mod';

  @override
  String get dialogLabelUrl => 'URL del Mod';

  @override
  String get errorInvalidUrl => 'Por favor, introduce una URL válida.';

  @override
  String get addLinkTooltip => 'Añadir un enlace de descarga para este mod';

  @override
  String get addLinkButtonText => 'Añadir Enlace';

  @override
  String get openLinkButtonText => 'Abrir Enlace';

  @override
  String get editModTitle => 'Editar Detalles del Mod';

  @override
  String get modNameLabel => 'Nombre del Mod';

  @override
  String get authorLabel => 'Autor';

  @override
  String get summaryLabel => 'Descripción / Resumen';

  @override
  String get notesLabel => 'Notas Personales';

  @override
  String get urlLabel => 'URL de Descarga';

  @override
  String get changeCoverButton => 'Cambiar Imagen de Portada';

  @override
  String get editButtonTooltip => 'Editar Mod';

  @override
  String get errorSavingNotes => 'Error al guardar las notas';

  @override
  String get errorSavingUrl => 'Error al guardar la URL';

  @override
  String get errorSavingChanges => 'Error al Guardar los Cambios';

  @override
  String get errorTranslation => 'No se pudo traducir la descripción';

  @override
  String get translateSummary => 'Traducir resumen';

  @override
  String get translateDescription => 'Traducir descripción';

  @override
  String get restoreOriginalDescription => 'Restaurar descripción original';

  @override
  String get dialogTitleUE4SSReinstall => 'Reinstalar UE4SS';

  @override
  String get dialogContentUE4SSReinstall =>
      'UE4SS ya parece estar instalado. ¿Quieres sobrescribir la instalación existente? Esto puede ser útil si sospechas que hay archivos corruptos.';

  @override
  String get dialogTitleCNSReinstall => 'Reinstalar Sistema CNS';

  @override
  String get dialogContentCNSReinstall =>
      'El sistema principal de CNS ya parece estar instalado. ¿Quieres reinstalarlo? Tus mods existentes no se verán afectados.';

  @override
  String dialogTitleUninstall(Object componentName) {
    return 'Desinstalar $componentName';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return '¿Estás seguro de que quieres desinstalar $componentName? Esta acción eliminará los archivos del componente principal pero no afectará a tus mods instalados.';
  }

  @override
  String get dialogActionUninstall => 'Sí, desinstalar';

  @override
  String statusUninstalling(Object componentName) {
    return 'Desinstalando $componentName...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentName desinstalado con éxito';
  }

  @override
  String errorUninstalling(Object componentName) {
    return 'Error al desinstalar $componentName';
  }

  @override
  String get settingsCoreComponents => 'Componentes Principales';

  @override
  String get installedStatus => 'Instalado';

  @override
  String get notInstalledStatus => 'No detectado';

  @override
  String get uninstallButton => 'Desinstalar';

  @override
  String get cnsCoreSystem => 'Custom Nanosuit System';

  @override
  String get ue4ssInstallationDetected =>
      'Instalación existente de UE4SS detectada y adoptada';

  @override
  String get cnsInstallationDetected =>
      'Instalación principal de CNS existente detectada y adoptada';

  @override
  String get ue4ssRequiredTitle => 'Se Requiere UE4SS';

  @override
  String get ue4ssRequiredContent =>
      'Para instalar el Sistema Principal de CNS, primero debes instalar UE4SS. Puedes descargarlo desde el siguiente enlace:';

  @override
  String get uninstallDependencyTitle => 'Dependencia Detectada';

  @override
  String get uninstallDependencyContent =>
      'Debes desinstalar el Sistema Principal de CNS antes de poder desinstalar UE4SS, ya que CNS depende de él.';

  @override
  String get dialogActionUnderstood => 'Entendido';

  @override
  String get appTitleNoCns => 'Custom Nanosuit System (No Instalado)';

  @override
  String get dialogTitleCNSUpdate => 'Actualizar Sistema Principal de CNS';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return 'Estás a punto de actualizar CNS de la versión $oldVersion a la nueva versión $newVersion. ¿Deseas continuar?';
  }

  @override
  String get dialogTitleCNSDowngrade => 'Degradar Versión de CNS';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return '¡Advertencia! Estás a punto de instalar una versión anterior de CNS ($newVersion) que la actual ($oldVersion). Esto puede causar problemas. ¿Estás seguro?';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return 'Ya tienes instalada la versión $version de CNS. ¿Quieres reinstalar los archivos de todos modos?';
  }

  @override
  String get dialogActionUpdate => 'Actualizar';

  @override
  String get dialogActionDowngrade => 'Degradar';

  @override
  String get dialogTitleCNSInstall => 'Instalar Sistema Principal de CNS';

  @override
  String get dialogContentCNSInstall =>
      'Estás a punto de instalar el sistema base Custom Nanosuit System (CNS). Esto es necesario para que los mods de CNS funcionen. ¿Deseas continuar?';

  @override
  String get dialogActionInstall => 'Instalar';

  @override
  String get settingsDeveloperOptions => 'Opciones de Desarrollador';

  @override
  String get devDeleteNexusInfoTitle =>
      'Eliminar Todos los Archivos nexus_info.json';

  @override
  String get devDeleteNexusInfoDesc =>
      'Elimina todos los archivos de metadatos del gestor de cada mod. Esto es útil para forzar una reparación completa.';

  @override
  String get devExtractIdsTitle => 'Extraer Identificadores';

  @override
  String get devExtractIdsDesc =>
      'Crea un archivo llamado \'ID Mods.json\' en tu escritorio que contiene el displayName y el nexusId de cada mod.';

  @override
  String get devConfirmDeleteTitle => 'Confirmar Eliminación';

  @override
  String get devConfirmDeleteDesc =>
      '¿Estás seguro de que quieres eliminar permanentemente todos los archivos nexus_info.json? Esto eliminará todos los nombres, portadas y metadatos personalizados. Esta acción no se puede deshacer.';

  @override
  String get devDeleteSuccessTitle => 'Eliminación Completa';

  @override
  String devDeleteSuccessDesc(Object count) {
    return 'Se eliminaron con éxito $count archivos nexus_info.json.';
  }

  @override
  String get devConfirmExtractTitle => 'Confirmar Extracción';

  @override
  String get devConfirmExtractDesc =>
      'Esto escaneará todos tus mods y creará \'ID Mods.json\' en tu escritorio. Esto sobrescribirá cualquier archivo existente con el mismo nombre. ¿Deseas continuar?';

  @override
  String get devExtractAction => 'Extraer';

  @override
  String get devTestSelfUpdateTitle => 'Probar auto-instalación';

  @override
  String get devTestSelfUpdateDesc =>
      'Selecciona el .zip de la app e instálalo sobre esta misma app, igual que hará la actualización automática.';

  @override
  String get devSelfUpdateUnsupported =>
      'La auto-actualización solo está disponible en Windows.';

  @override
  String get devSelfUpdatePickTitle =>
      'Selecciona el .zip de SB Control Center';

  @override
  String get devSelfUpdateFailed => 'No se pudo instalar la actualización';

  @override
  String get devSelfUpdateDryRunTitle => 'Paquete válido (modo de prueba)';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return 'Se encontraron $count archivos. No se instaló porque esta no es una build de release.';
  }

  @override
  String get devSelfUpdateConfirmTitle => '¿Instalar la actualización?';

  @override
  String get devSelfUpdateConfirmDesc =>
      'La app se cerrará, reemplazará sus archivos con los del paquete y se abrirá de nuevo automáticamente.';

  @override
  String get devSelfUpdateInstallAction => 'Instalar y reiniciar';

  @override
  String get devSelfUpdateProgressTitle => 'Actualizando SB Control Center';

  @override
  String get devSelfUpdateExtracting => 'Extrayendo paquete…';

  @override
  String get devSelfUpdateInstalling => 'Instalando archivos…';

  @override
  String get devSelfUpdateRestarting => 'Reiniciando…';

  @override
  String get appUpdateAvailableTitle => 'Actualización disponible';

  @override
  String appUpdateAvailableDesc(String current, String latest) {
    return 'La versión $latest está disponible (tienes la $current). La app la descargará, se cerrará, se actualizará y se abrirá de nuevo.';
  }

  @override
  String get settingsCheckAppUpdate => 'Buscar actualizaciones de la app';

  @override
  String get settingsCheckAppUpdateDesc =>
      'Busca una versión nueva de SB Control Center en GitHub';

  @override
  String get appUpdateNow => 'Actualizar ahora';

  @override
  String get appUpdateLater => 'Más tarde';

  @override
  String get appUpdateSkip => 'Omitir esta versión';

  @override
  String get appUpdateDownloading => 'Descargando actualización…';

  @override
  String get appUpdateUpToDate => 'Ya tienes la última versión';

  @override
  String get appUpdateCheckFailed => 'No se pudo buscar actualizaciones';

  @override
  String get devExtractNoData =>
      'No se encontraron mods con identificadores válidos para extraer.';

  @override
  String get devExtractDesktopNotFound =>
      'Error: No se pudo encontrar el directorio del Escritorio.';

  @override
  String get devExtractSuccessTitle => 'Extracción Completa';

  @override
  String devExtractSuccessDesc(Object path) {
    return 'Archivo creado con éxito en: $path';
  }

  @override
  String get errorDialogTitle => 'Ocurrió un Error';

  @override
  String get modDetailsCategory => 'Categoría';

  @override
  String get modDetailsAuthor => 'Autor';

  @override
  String get modDetailsNexusId => 'ID de Nexus';

  @override
  String get modDetailsInstalledOn => 'Instalado el';

  @override
  String get unknownAuthor => 'Desconocido';

  @override
  String get statusInstalling => 'Instalando...';

  @override
  String statusInstallingMod(int index, int total, String modName) {
    return 'Instalando $index/$total: $modName';
  }

  @override
  String byText(Object author) {
    return 'por $author';
  }

  @override
  String get filterUpdatesAvailable => 'Actualizaciones disponibles';

  @override
  String snackBarUpdateIgnored(String modName) {
    return 'Actualización para \'$modName\' ignorada en esta sesión.';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return 'La versión \'$version\' de \'$modName\' se omitirá en futuras comprobaciones.';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return 'Actualizando metadatos de \'$displayName\' ($arg1 de $arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return 'Mod Genérico Instalado: $modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return 'Instalado en $path.\nEste mod no es gestionado por la app y debe desinstalarse manualmente.';
  }

  @override
  String genericModInstallError(String modName) {
    return 'Error al instalar el mod genérico: $modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => 'Genérico';

  @override
  String get modTypeMovies => 'Películas';

  @override
  String get modTypeSave => 'Guardado';

  @override
  String get modTypeConfig => 'Configuración';

  @override
  String get modTypeSplash => 'Splash';

  @override
  String get replacesOutfitTitle => 'Reemplaza Atuendo';

  @override
  String get replacesOutfitClearTooltip => 'Limpiar selección de atuendo';

  @override
  String get replacesOutfitSelectTooltip => 'Seleccionar atuendo a reemplazar';

  @override
  String get replacesOutfitNone =>
      'Ningún atuendo seleccionado.\nLa etiqueta será \'Genérico\'.';

  @override
  String get replacesOutfitSearchHint => 'Buscar atuendos...';

  @override
  String get modTypeReplacement => 'Reemplazo';

  @override
  String get replacesOutfitHover =>
      'Pasa el ratón sobre un atuendo para ver una vista previa.';

  @override
  String get dialogTitleOutfitReplacement => '¿Reemplazo de Atuendo?';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return '¿Es el mod \'$modName\' un reemplazo de atuendo?\n\nSelecciona \'Sí\' para elegir qué atuendo reemplaza, o \'No\' para instalarlo como un mod genérico.';
  }

  @override
  String get dialogActionNo => 'No';

  @override
  String get dialogActionYes => 'Sí';

  @override
  String get dialogTitleOutfitConflict => 'Conflicto de Atuendo Detectado';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return 'El atuendo \'$outfitName\' ya está siendo reemplazado por el mod \'$modName\'.\n\n¿Quieres desactivar \'$modName\' y activar este en su lugar?';
  }

  @override
  String get dialogActionActivateAndDisable => 'Desactivar y Activar';

  @override
  String get replacementModSwitchTitle => 'Mod de reemplazo';

  @override
  String get replacementModSwitchDesc =>
      'Marca si este mod está diseñado para reemplazar un traje en el juego.';

  @override
  String get settingsShowModTagsTitle => 'Mostrar etiquetas de tipo de mod';

  @override
  String get settingsShowModTagsDesc =>
      'Mostrar etiquetas de tipo de mod (ej. CNS, Genérico) en cada tarjeta de mod en la lista.';

  @override
  String get modTypeLogic => 'Lógica';

  @override
  String get patcherStarted =>
      '=== Patcher Dart para StellarBlade Iniciado ===';

  @override
  String workingDirectory(String path) {
    return 'Directorio de trabajo: $path';
  }

  @override
  String modsDirNotFound(String path) {
    return 'El directorio ~mods no existe en: $path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  ADVERTENCIA: No se pudo escanear la carpeta $path. Omitiendo.';
  }

  @override
  String errorDetails(String error) {
    return '  Error: $error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return 'Se encontraron $count archivos .utoc';
  }

  @override
  String get noModsFound2 => 'No se encontraron mods para procesar.';

  @override
  String get patcherSummaryTitle =>
      '\n=== Resumen del Patcher (Datos sin procesar) ===';

  @override
  String processedMods(int count) {
    return 'Se procesaron $count mods.';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return 'Se corrigieron $count conflictos de Container ID.';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return 'Se encontraron $count conflictos de Package ID.';
  }

  @override
  String get fatalErrorTitle => '\n=== ERROR FATAL ===';

  @override
  String patcherServiceError(String error) {
    return 'Error en PatcherService: $error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- Analizando: $fileName ---';
  }

  @override
  String get warnUcasNotFound =>
      '  ADVERTENCIA: Archivo .ucas no encontrado. Omitiendo.';

  @override
  String get warnCorruptHeader =>
      '  ADVERTENCIA: Encabezado corrupto, el tamaño de la entrada supera el tamaño del archivo. Omitiendo.';

  @override
  String conflictContainerIdDetected(int id) {
    return '  CONFLICTO de Container ID detectado: $id';
  }

  @override
  String generatingNewId(int id) {
    return '  Generando nuevo ID: $id';
  }

  @override
  String get utocFilePatched => '  Archivo .utoc parcheado.';

  @override
  String get patchingUcasFile => '  Parcheando archivo .ucas...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  Reemplazos exitosos en .ucas: $count';
  }

  @override
  String get patchComplete => '  ¡Parche completado!';

  @override
  String idRegisteredNoConflict(int id) {
    return '  ID $id registrado. Sin conflictos.';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  ERROR al procesar $fileName: $error';
  }

  @override
  String get statusRunningPatcher => 'Ejecutando Patcher de Conflictos...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ ¡Éxito! Se corrigieron $count conflictos de Container ID que causaban bloqueos.';
  }

  @override
  String get summaryNoContainerIdConflicts =>
      '✅ No se encontraron conflictos de Container ID (bloqueos).';

  @override
  String get summaryNoPackageIdConflicts =>
      '✅ ¡Buenas noticias! No se encontraron conflictos graves de Package ID (sobrescritura).';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ ¡Advertencia! Se encontraron $count grupos de mods que no pueden coexistir:';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • Este grupo de mods compite por $count archivos:';
  }

  @override
  String get patcherSummaryDialogTitle => 'Resumen del Patcher';

  @override
  String get dialogActionShowFullLog => 'Mostrar Registro Completo';

  @override
  String get fullLogDialogTitle => 'Registro del Patcher de Conflictos (Dart)';

  @override
  String get runConflictPatcherTitle => 'Ejecutar Patcher de Conflictos';

  @override
  String get runConflictPatcherSubtitlePython =>
      'Corrige bloqueos de Container_Id y Package_Id';

  @override
  String get processingCover => 'Procesando Portada...';

  @override
  String get apiKeyTooltip =>
      'Se requiere la Clave API para la extracción inteligente del ID de Nexus.';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return 'Opciones de Instalación - Mod $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection =>
      'Selecciona las opciones que deseas instalar. Los archivos principales requeridos se instalarán automáticamente.';

  @override
  String get snackBarSpecialModNoSelection =>
      'Selecciona al menos una opción para continuar.';

  @override
  String get dialogActionInstallSelection => 'Instalar Selección';

  @override
  String get downloadStatusFetching => 'Obteniendo datos de Nexus Mods...';

  @override
  String get downloadStatusFetchingFailed =>
      'Fallo al obtener el enlace de descarga. Verifica tu API Key o conexión.';

  @override
  String downloadStatusDownloading(String fileName) {
    return 'Descargando $fileName';
  }

  @override
  String get downloadStatusError => 'Error durante la descarga del archivo.';

  @override
  String downloadStatusException(String error) {
    return 'Excepción: $error';
  }

  @override
  String get dialogTitleDownloadModManager => 'Descarga del Mod Manager';

  @override
  String get launchGameText => 'Iniciar Stellar Blade';

  @override
  String get stopGameText => 'Detener Stellar Blade';

  @override
  String get dialogTitleStopGame => '¿Detener Stellar Blade?';

  @override
  String get dialogContentStopGame =>
      'El juego se cerrará. Se perderá el progreso no guardado.';

  @override
  String get dialogActionStopGame => 'Detener';

  @override
  String get notificationGameStopped => 'Stellar Blade detenido';

  @override
  String get errorStoppingGame => 'No se pudo detener el juego';

  @override
  String get mod801DialogTitle => 'Configuración de Steam requerida';

  @override
  String get mod801DialogIntro =>
      'El mod Random Splash se ha instalado. Para que funcione automáticamente al iniciar el juego, necesitas configurar Steam.';

  @override
  String get mod801Step1 =>
      '1. Genera la ruta exacta para tu PC a continuación y cópiala.';

  @override
  String get mod801Step2 => '2. Abre tu Biblioteca de Steam.';

  @override
  String get mod801Step3 =>
      '3. Haz clic derecho en Stellar Blade -> Propiedades.';

  @override
  String get mod801Step4 =>
      '4. En la pestaña \'General\', pega el código en \'Parámetros de lanzamiento\'.';

  @override
  String get mod801BtnGenerate => 'Generar Ruta';

  @override
  String get mod801BtnSteam => 'Abrir Steam';

  @override
  String get mod801BtnCopy => 'Copiar';

  @override
  String get mod801PathGenerated => 'Ruta generada con éxito.';

  @override
  String get mod801PathCopied => '¡Comando copiado al portapapeles!';

  @override
  String get statusVerifyingMods => 'Verificando la integridad de los mods...';

  @override
  String errorSelecting7Zip(String error) {
    return 'Error al seleccionar 7-Zip: $error';
  }

  @override
  String get errorInvalidFolderRetry =>
      'La carpeta seleccionada no parece ser correcta. Por favor, inténtalo de nuevo.';

  @override
  String errorSelectingFolderDynamic(String error) {
    return 'Error al seleccionar la carpeta: $error';
  }

  @override
  String get statusNoNewModsInstalled =>
      'La instalación no produjo nuevos mods.';

  @override
  String get errorDisableModBeforeDelete =>
      'Por favor, desactiva el mod antes de eliminarlo.';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return 'Activados: $successCount (Omitidos: $skippedCount por conflictos)';
  }

  @override
  String get snackBarDeveloperModeEnabled => '¡Modo de Desarrollador Activado!';

  @override
  String errorRenamingMod(String error) {
    return 'Error al renombrar el mod: $error';
  }

  @override
  String get notificationTitleError => 'Error';

  @override
  String get errorGamePathNotFoundNotification =>
      'Ruta del juego no encontrada.';

  @override
  String get notificationLaunchingGame => 'Iniciando Stellar Blade...';

  @override
  String get errorLaunchingGame => 'Error al iniciar el juego';

  @override
  String get dialogTitleSelect7zip => 'Selecciona el archivo 7z.exe';

  @override
  String get dialogTitleSelectGameFolder =>
      'Por favor, selecciona la carpeta principal de StellarBlade';

  @override
  String get dialogTitleSelectCover => 'Selecciona una portada para el mod';

  @override
  String get errorGamePathNotFoundException => 'Ruta del juego no encontrada.';

  @override
  String get errorGamePathNotDefined => 'La ruta del juego no está definida.';

  @override
  String get errorLogicModsPathNotDefined =>
      'La ruta de los mods Logic no está definida.';

  @override
  String get errorUe4ssModsPathNotDefined =>
      'La ruta de los mods de UE4SS no está definida.';

  @override
  String get errorGenericModsPathNotDefined =>
      'La ruta de los mods genéricos (~mods) no está definida.';

  @override
  String get errorReplaceNoOldVersion =>
      'Se intentó reemplazar un mod pero no se identificó ninguna versión anterior.';

  @override
  String errorDeleteOldModVersion(String modName) {
    return 'No se pudo eliminar la versión anterior del mod ($modName).';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return 'No se pudo eliminar el mod existente ($modName) para reinstalarlo.';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return 'No se pudo eliminar el mod existente ($modName) para reinstalarlo tras varios intentos.';
  }

  @override
  String get errorMoviesModNoValidFiles =>
      'El mod de películas no contiene archivos de video válidos.';

  @override
  String get errorInstallPathUndetermined =>
      'No se pudo determinar la ruta de instalación.';

  @override
  String get errorMoviesPathsNotDefined =>
      'Las rutas de películas no están definidas.';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return 'No se encontró nexus_info.json para $modName.';
  }

  @override
  String get errorMenuVideoLimitReached =>
      'Se alcanzó el límite de 99 videos en el menú.';

  @override
  String get errorModRequires529 =>
      'El mod requiere el Mod ID 529 para funcionar (solo contiene archivos WebM).';

  @override
  String get errorSplashPathsNotDefined =>
      'Las rutas de splash no están definidas.';

  @override
  String get errorSplashNoValidImages =>
      'No se encontraron imágenes válidas en el mod.';

  @override
  String get errorCouldNotDeleteDirectory =>
      'No se pudo eliminar el directorio.';

  @override
  String get errorGameExeNotFound =>
      'No se encontró el archivo ejecutable del juego (.exe) en la carpeta principal o en Binaries.';

  @override
  String get dialogTitleSplashOptions => 'Opciones de Splash (Imágenes)';

  @override
  String get dialogContentSplashOptions =>
      'Selecciona las imágenes que deseas instalar. Puedes elegir carpetas enteras (lotes) o imágenes individuales.';

  @override
  String get snackBarSplashNoSelection =>
      'Por favor, selecciona al menos una imagen.';

  @override
  String get dialogContentSpecialModSingleSelection =>
      'Selecciona una única opción para instalar.';

  @override
  String get activeDownloads => 'Descargas activas';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mods',
      one: 'mod',
    );
    return 'Descargando $count $_temp0';
  }

  @override
  String get downloadError => 'Error';

  @override
  String get downloadCancelled => 'Cancelado';

  @override
  String get downloadPause => 'Pausar';

  @override
  String get downloadResume => 'Reanudar';

  @override
  String get downloadCancel => 'Cancelar';

  @override
  String get errorNexusInfoNotFound => 'nexus_info.json no encontrado.';

  @override
  String logFixingCorruptedJson(String displayName) {
    return 'Arreglando nexus_info.json corrupto para $displayName.';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return 'No se pudieron actualizar los metadatos para $displayName: $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return 'Desactivando preventivamente el mod de películas debido a la activación del Mod 529: $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return 'Desactivando preventivamente el mod de inicio debido a la activación del Mod 801: $modName';
  }

  @override
  String logRestoringTildeComponent(String folderName) {
    return 'Restaurando componente ~mods: $folderName';
  }

  @override
  String logRestoringUe4ssComponent(String folderName) {
    return 'Restaurando componente UE4SS: $folderName';
  }

  @override
  String logErrorRestoringLogicMod(String error) {
    return 'Error al restaurar componentes LogicMod: $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return 'Archivando componente ~mods: $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return 'Archivando componente UE4SS: $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return 'Error al archivar componentes LogicMod: $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return 'Omitiendo $modName: Ya existe una variante activa de este mod.';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return 'Omitiendo $modName: Conflicto con un atuendo ya ocupado.';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return 'No se pudieron limpiar las copias de seguridad de video para $modName: $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return 'Nueva Nexus ID $nexusId detectada. Obteniendo metadatos...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return 'Metadatos obtenidos y aplicados para $nexusId.';
  }

  @override
  String logFallbackByteCopy(String error) {
    return 'La copia normal falló, usando fuerza bruta de bytes: $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return 'Advertencia: No se pudo eliminar el archivo modificado: $error';
  }

  @override
  String get logMod801BatPatched =>
      'Script .bat del Mod 801 parcheado exitosamente para este sistema.';

  @override
  String logMod801BatPatchError(String error) {
    return 'Error al intentar parchear el archivo .bat del Mod 801: $error';
  }

  @override
  String get errorHomeDirNotFound =>
      'No se pudo encontrar la variable de entorno del directorio de inicio.';

  @override
  String get downloadFetchingPlaceholder => 'Obteniendo...';

  @override
  String get downloadErrorLink => 'No se pudo obtener el enlace de descarga';

  @override
  String get downloadErrorGeneral => 'Descarga fallida';

  @override
  String get downloadPausedStatus => 'Pausado';

  @override
  String get settingsFixGameStartup => 'Reparar que el juego no inicia';

  @override
  String get settingsFixGameStartupDesc =>
      'Úsalo si el juego se cierra o falla al iniciar. Desinstala temporalmente UE4SS y CNS, inicia el juego una vez y los vuelve a instalar.';

  @override
  String get repairConfirmTitle => '¿Reparar el inicio del juego?';

  @override
  String get repairConfirmMessage =>
      'Se desinstalarán UE4SS y CNS (sus archivos se guardan), el juego se iniciará y se cerrará automáticamente, y luego se reinstalará todo y se lanzará el juego de nuevo. No cierres la aplicación durante el proceso.';

  @override
  String get repairConfirmAction => 'Iniciar reparación';

  @override
  String get launchRetryTitle => 'El juego no se inició';

  @override
  String get launchRetryMessage =>
      'Stellar Blade no se inició tras dos intentos. Suele deberse a UE4SS o CNS. «Reparar que el juego no inicia» los desinstala temporalmente, abre el juego una vez y los vuelve a instalar. ¿Ejecutarlo ahora?';

  @override
  String get launchRetryAction => 'Reparar ahora';

  @override
  String get repairOverlayTitle => 'Reparando el inicio del juego';

  @override
  String get repairOverlayWarning =>
      'No cierres la aplicación ni el juego manualmente mientras se ejecuta.';

  @override
  String get repairStepCloseGame => 'Cerrando el juego si está abierto';

  @override
  String get repairStepStashCns => 'Desinstalando CNS (guardando sus archivos)';

  @override
  String get repairStepStashUe4ss =>
      'Desinstalando UE4SS (guardando sus archivos)';

  @override
  String get repairStepLaunchClean => 'Iniciando el juego sin UE4SS ni CNS';

  @override
  String get repairStepWaitInit => 'Esperando a que el juego cargue';

  @override
  String get repairStepCloseAuto => 'Cerrando el juego automáticamente';

  @override
  String get repairStepRestoreUe4ss => 'Reinstalando UE4SS';

  @override
  String get repairStepRestoreCns => 'Reinstalando CNS';

  @override
  String get repairStepLaunchFinal => 'Lanzando el juego';

  @override
  String get repairStatusSkipped => 'omitido';

  @override
  String get repairResultSuccess =>
      'Reparación completada. El juego fue lanzado.';

  @override
  String get repairResultErrorRestored =>
      'La reparación falló, pero UE4SS y CNS se dejaron como estaban.';

  @override
  String get repairResultErrorRestoreFailed =>
      'La reparación falló y los archivos aún no pudieron restaurarse. Se restaurarán automáticamente la próxima vez que abras la aplicación.';

  @override
  String get repairErrorGameNotStarted => 'El juego no se inició a tiempo.';

  @override
  String get repairButtonClose => 'Cerrar';

  @override
  String get repairRecoveredNotice =>
      'Se detectó una reparación interrumpida: se restauraron los archivos de UE4SS y CNS.';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return 'Nueva edición instalada: $name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return 'Este mod ahora tiene $count ediciones instaladas.';
  }

  @override
  String get previewTagNewEdition => 'nueva edición';

  @override
  String get previewTagUpdate => 'actualización';

  @override
  String editionsInstalledTooltip(Object count) {
    return '$count ediciones de este mod instaladas';
  }

  @override
  String editionLabelValue(Object edition) {
    return 'Edición: $edition';
  }

  @override
  String get otherEditionsTitle => 'Otras ediciones instaladas';

  @override
  String get detailsStatusEnabled => 'Activado';

  @override
  String get detailsStatusDisabled => 'Desactivado';

  @override
  String get detailsInformation => 'Información';

  @override
  String get detailsRowAuthor => 'Autor';

  @override
  String get detailsRowType => 'Tipo';

  @override
  String get detailsRowInstalled => 'Instalado';

  @override
  String get detailsRowModified => 'Última modificación';

  @override
  String get detailsRowNexusId => 'ID de Nexus';

  @override
  String get detailsRowFolder => 'Carpeta';

  @override
  String get detailsCopyPath => 'Copiar ruta';

  @override
  String get detailsCopied => 'Copiado al portapapeles';

  @override
  String get detailsEndorse => 'Endorsar';

  @override
  String get detailsEndorsed => 'Endorsado';

  @override
  String endorseWaitLabel(Object minutes) {
    return 'Espera $minutes min';
  }

  @override
  String get endorseSuccessTitle => 'Mod endorsado';

  @override
  String get endorseRemovedTitle => 'Endorse retirado';

  @override
  String get endorseFailedTitle => 'No se pudo actualizar el endorse';

  @override
  String get endorseErrNotNexus =>
      'Este mod no está vinculado a una página de Nexus Mods, así que no se puede endorsar.';

  @override
  String get endorseErrNoApiKey =>
      'Introduce tu API key de Nexus Mods en Ajustes para poder endorsar mods.';

  @override
  String endorseErrWait(Object minutes) {
    return 'Nexus exige esperar 15 minutos tras descargar un mod antes de poder endorsarlo. Inténtalo de nuevo en $minutes min.';
  }

  @override
  String get endorseErrNotDownloaded =>
      'Nexus solo permite endorsar mods que hayas descargado con tu cuenta.';

  @override
  String get endorseErrOwnMod => 'No puedes endorsar tu propio mod.';

  @override
  String get endorseErrRateLimit =>
      'Se alcanzó el límite de solicitudes de Nexus. Inténtalo más tarde.';

  @override
  String get endorseErrInvalidKey =>
      'Nexus rechazó tu API key. Revísala en Ajustes.';

  @override
  String get endorseErrNetwork =>
      'No se pudo conectar con Nexus Mods. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get endorseErrUnknown =>
      'Nexus no pudo procesar la solicitud. Inténtalo más tarde.';

  @override
  String get endorseRemoveConfirmTitle => '¿Quitar el endorse?';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return '$name dejará de estar endorsado en Nexus Mods.';
  }

  @override
  String get endorseRemoveConfirmAction => 'Quitar';

  @override
  String get detailsUpdateAction => 'Actualizar';

  @override
  String get detailsShowMore => 'Mostrar más';

  @override
  String get detailsShowLess => 'Mostrar menos';

  @override
  String get detailsAddNote => 'Añadir una nota';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atuendos',
      one: '1 atuendo',
      zero: 'Ningún atuendo',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get outfitsChoose => 'Elegir atuendos';

  @override
  String get outfitsDone => 'Listo';

  @override
  String get outfitsFilterAll => 'Todos';

  @override
  String get outfitsFilterSelected => 'Seleccionados';

  @override
  String get outfitsClearAll => 'Borrar todo';

  @override
  String get outfitsRemove => 'Quitar';

  @override
  String get outfitsActionSelect => 'Seleccionar';

  @override
  String get outfitsActionDeselect => 'Deseleccionar';

  @override
  String outfitsNoResults(String query) {
    return 'Sin resultados para «$query»';
  }

  @override
  String get outfitsSelectedEmpty => 'Aún no hay atuendos seleccionados.';

  @override
  String get outfitsNoPreview => 'Vista previa no disponible';

  @override
  String get replacementOffConfirmTitle => '¿Desactivar el mod de reemplazo?';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Los $count atuendos seleccionados se quitarán de este mod.',
      one: 'El atuendo seleccionado se quitará de este mod.',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => 'Desactivar';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count mods desactivados: reemplazan trajes que ya usan otros mods',
      one: '1 mod desactivado: reemplaza un traje que ya usa otro mod',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  Mismo Container ID que: $owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved =>
      '  Originales guardados como .cnsbak (restaurables).';

  @override
  String patcherLeftUntouched(String reason) {
    return '  Sin tocar (no es seguro parchear): $reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ $count mod(s) comparten Container ID pero no se pudieron reparar de forma segura (sin tocar; pueden no aparecer en CNS):';
  }

  @override
  String get revertPatchesTitle => 'Revertir parches de conflictos';

  @override
  String get revertPatchesDesc =>
      'Restaura los archivos originales de los mods modificados por el Patcher de Conflictos.';

  @override
  String get revertPatchesConfirmTitle => '¿Revertir parches de conflictos?';

  @override
  String get revertPatchesConfirmMessage =>
      'Se restaurarán los archivos originales guardados por el Patcher de Conflictos (.cnsbak). Cierra el juego antes. Los mods en conflicto pueden dejar de aparecer en CNS otra vez.';

  @override
  String get revertPatchesAction => 'Revertir';

  @override
  String revertPatchesDone(int count) {
    return 'Se restauraron $count archivo(s).';
  }

  @override
  String get revertPatchesNothing => 'No hay archivos parcheados que revertir.';

  @override
  String get settingsGroupPaths => 'Rutas';

  @override
  String get settingsGroupTools => 'Herramientas';

  @override
  String get settingsAutoOutfit => 'Asignar trajes automáticamente';

  @override
  String get settingsAutoOutfitDesc =>
      'Al instalar un mod de reemplazo, detecta qué traje reemplaza leyendo sus archivos. Si lo desactivas, el traje se asigna manualmente.';

  @override
  String get variantChoiceTitle => 'Varias variantes del mismo reemplazo';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return '\"$mod\" trae varias variantes que reemplazan $outfits. Solo una puede estar activa a la vez. ¿Cuál quieres instalar?';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return '\"$mod\" trae varias variantes que reemplazan los mismos archivos. Solo una puede estar activa a la vez. ¿Cuál quieres instalar?';
  }

  @override
  String get variantChoiceInstallAll => 'Instalar todas (como mods separados)';

  @override
  String get installOutfitConflictTitle => 'Traje ya en uso';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return 'El mod \"$newMod\" reemplaza el traje $outfits, que ya está asignado al mod activo \"$oldMod\". Solo uno puede estar activo a la vez. ¿Cuál quieres dejar activo?';
  }

  @override
  String get installOutfitKeepCurrent => 'Mantener el actual';

  @override
  String get installOutfitUseNew => 'Activar el nuevo';

  @override
  String installOutfitNowActive(String active) {
    return 'Quedó activo: $active';
  }

  @override
  String get fileLockErrorTitle => 'No se pudo mover el mod';

  @override
  String get fileLockErrorMessage =>
      'Es posible que otra aplicación esté usando los archivos del juego (FModel, el propio juego, un antivirus, el Explorador de archivos...). Ciérrala e inténtalo de nuevo.';

  @override
  String get nexusProfileTooltip => 'Perfil de Nexus Mods';

  @override
  String get nexusUserFallback => 'Usuario';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => 'Miembro';

  @override
  String get nexusPlanSupporter => 'Colaborador';

  @override
  String get nexusApiRequestsRemaining => 'SOLICITUDES RESTANTES DE API';

  @override
  String get nexusApiDaily => 'Diarias';

  @override
  String get nexusApiHourly => 'Por hora';

  @override
  String get downloadMemberAccountLimit =>
      'Cuentas Miembro limitadas a 1,5 MB/s por Nexus Mods';

  @override
  String get downloadSupporterAccountLimit =>
      'Cuentas Colaborador limitadas a 3 MB/s por Nexus Mods';

  @override
  String get downloadRetryTooltip => 'Reintentar';

  @override
  String get downloadRefreshingLink => 'Refrescando enlace...';

  @override
  String get downloadNoInternet => 'Sin conexión a internet. Verifica tu red.';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'El enlace de Nexus ha expirado ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'Error HTTP: $code';
  }

  @override
  String get downloadErrorTimeout =>
      'Tiempo de espera agotado: no se reciben datos de red';

  @override
  String get splashRootFolder => 'Raíz (Principal)';

  @override
  String get repairErrorGameNotClosed =>
      'No se pudo cerrar el proceso del juego.';

  @override
  String get errorManifestNotFound =>
      'No se encontró el manifiesto de instalación. No se puede desinstalar.';

  @override
  String get downloadResuming => 'Reanudando...';

  @override
  String get apiKeyPromptTitle => 'Configura tu clave de API de Nexus Mods';

  @override
  String get apiKeyPromptMessage =>
      'No se ha detectado ninguna clave de API. Configurarla es opcional, pero te lo recomendamos por comodidad: te permite buscar actualizaciones de mods, descargar con un clic (nxm://) y cargar portadas e información de Nexus Mods.';

  @override
  String get apiKeyPromptConfigure => 'Configurar clave de API';

  @override
  String get apiKeyPromptSkip => 'Omitir';

  @override
  String get apiKeyPromptDontShowAgain => 'No volver a mostrar este mensaje';

  @override
  String get adjustCoverTooltip => 'Ajustar portada';

  @override
  String get noCoverToAdjust => 'Este mod no tiene una portada que ajustar';

  @override
  String errorAdjustingCoverText(Object error) {
    return 'Error al ajustar la portada: $error';
  }
}
