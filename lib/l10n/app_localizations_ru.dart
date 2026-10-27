// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get settingsGeneral => 'Общие';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageDesc => 'Выберите язык приложения';

  @override
  String get settingsAbout => 'О программе';

  @override
  String get settingsAboutDesc => 'Информация о приложении';

  @override
  String get settingsRefreshMetadata => 'Обновить метаданные';

  @override
  String get settingsRefreshMetadataDesc =>
      'Повторно проверяет ваши моды на Nexus Mods и дополняет недостающие данные и изображения';

  @override
  String get metadataRefreshDone => 'Метаданные обновлены';

  @override
  String get metadataRefreshNoApiKey =>
      'Укажите API-ключ Nexus Mods в настройках, чтобы обновить метаданные.';

  @override
  String get settingsPathsAndTools => 'Пути и инструменты';

  @override
  String get settingsGameFolder => 'Папка с игрой';

  @override
  String get settingsGameFolderDesc =>
      'Корневая папка вашей установки Stellar Blade.';

  @override
  String get settings7zipPath => 'Путь к 7-Zip';

  @override
  String get settings7zipPathDesc =>
      'Расположение файла 7z.exe для извлечения модов.';

  @override
  String get settings7zipPathAuto => 'Автоматический поиск';

  @override
  String get settingsRepairMods => 'Восстановить устаревшие моды';

  @override
  String get settingsRepairModsDesc =>
      'Сканирует и создает информационные файлы для старых модов, используя локальную базу данных. Требуется ключ API.';

  @override
  String get settingsConnectivity => 'Подключение и обновления';

  @override
  String get settingsApiKey => 'Ключ API Nexus Mods';

  @override
  String get settingsApiKeyDesc => 'Требуется для проверки обновлений модов.';

  @override
  String get settingsApiKeySet => 'Установлен';

  @override
  String get settingsApiKeyNotSet => 'Не установлен';

  @override
  String get settingsSkippedVersions => 'Управление пропущенными версиями';

  @override
  String get settingsSkippedVersionsDesc =>
      'Управляйте версиями модов, которые вы решили пропустить.';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count пропущенных версий';
  }

  @override
  String get dialogTitleSkippedVersions => 'Пропущенные версии модов';

  @override
  String get dialogNoSkippedVersions => 'У вас нет пропущенных версий модов.';

  @override
  String get dialogSkippedVersions => 'Пропущенная версия';

  @override
  String get dialogTitleRepairMods =>
      'Запустить восстановление устаревших модов?';

  @override
  String get dialogContentRepairMods =>
      'Внимание: Эта функция находится в разработке и может работать неидеально.\n\nОна просканирует моды без файла \'nexus_info.json\' и, если найдет их в вашей локальной базе данных, создаст для них этот файл. Также будет предпринята попытка переименовать папку мода, чтобы включить найденную версию (например, \'My Mod\' -> \'My Mod v1.2\').\n\nПриоритет версии:\n1. Из названия папки.\n2. Из поля описания мода.\n3. Из последней версии на Nexus Mods (требуется API).\n\nВы хотите продолжить?';

  @override
  String get dialogActionRunRepair => 'Запустить восстановление';

  @override
  String get snackBarGamePathInvalid =>
      'Выбранная папка не является действительной папкой с игрой.';

  @override
  String get snackBar7zipPathInvalid =>
      'Выбранный файл должен называться 7z.exe.';

  @override
  String get snackBarRepairStarted =>
      'Процесс восстановления устаревших модов запущен...';

  @override
  String snackBarRepairComplete(Object count) {
    return 'Восстановление завершено. Обновлено $count мод(ов).';
  }

  @override
  String get snackBarRepairNoMods =>
      'Устаревшие моды, требующие восстановления, не найдены.';

  @override
  String get errorApiRequiredForRepair =>
      'Ключ API необходим для поиска последней версии модов без локальной версии.';

  @override
  String get installNewMod => 'Установить мод';

  @override
  String get selectFiles => 'Выбрать файлы';

  @override
  String get selectFolder => 'Выбрать папку';

  @override
  String get installSelectedMod => 'Установить выбранный мод';

  @override
  String get filesToInstall => 'Файлы для установки:';

  @override
  String get cancelSelection => 'Отменить выбор';

  @override
  String get searchMods => 'Поиск модов...';

  @override
  String get enabledMods => 'Включенные моды';

  @override
  String get disabledMods => 'Отключенные моды';

  @override
  String get refreshList => 'Обновить список';

  @override
  String get noEnabledMods => 'Нет включенных модов.';

  @override
  String get noDisabledMods => 'Нет отключенных модов.';

  @override
  String get showInFolder => 'Показать в папке';

  @override
  String get disableMod => 'Отключить мод';

  @override
  String get enableMod => 'Включить мод';

  @override
  String get deletePermanently => 'Удалить навсегда';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get statusSearchingGame => 'Поиск установки Stellar Blade...';

  @override
  String get statusGamePathFound => 'Путь к игре найден!';

  @override
  String get statusGamePathNotFound =>
      'Не удалось автоматически найти путь к игре.';

  @override
  String statusErrorFindingGame(Object error) {
    return 'Произошла ошибка при поиске игры: $error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount мод(ов) включено, $disabledCount отключено.';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return 'Ошибка чтения установленных модов: $error';
  }

  @override
  String statusFilesSelected(Object count) {
    return 'Выбрано $count файл(ов). Готово к установке.';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return 'Папка \"$folderName\" выбрана. Готово к установке.';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return 'Файл \"$fileName\" загружен. $count файл(ов) готово к установке.';
  }

  @override
  String get statusSelectionCancelled =>
      'Выбор отменен. Выберите новый мод для установки.';

  @override
  String get statusUpdateComplete => 'Обновление завершено.';

  @override
  String get statusInstallationComplete => 'Установка завершена.';

  @override
  String statusError(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get dialogTitle7zip => 'Требуется 7-Zip';

  @override
  String get dialogContent7zip =>
      'Для распаковки этого файла приложению требуется 7-Zip.\n\nПожалуйста, установите его с официального сайта, а затем нажмите \"Подтвердить\".';

  @override
  String get dialogContent7zipNotFound =>
      '7-Zip еще не обнаружен. Убедитесь, что он установлен по стандартному пути, и попробуйте снова.';

  @override
  String get dialogTitleMultipleJsons => 'Обнаружено несколько файлов .json';

  @override
  String dialogContentMultipleJsons(Object count) {
    return 'Обнаружено $count .json файлов. Это может быть мод с несколькими компонентами.\n\nХотите установить их все вместе в одну папку мода?';
  }

  @override
  String get dialogTitleModExists => 'Мод уже существует';

  @override
  String dialogContentModExists(Object modName) {
    return 'Мод с названием \"$modName\" уже установлен.\n\nХотите его обновить? Старые файлы будут удалены перед установкой новых.';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return 'Найдена старая версия \'$oldModName\'.\n\nХотите удалить ее и обновиться до \'$newModName\'?';
  }

  @override
  String get dialogTitleDeleteMod => 'Удалить навсегда?';

  @override
  String dialogContentDeleteMod(Object modName) {
    return 'Вы собираетесь навсегда удалить мод \"$modName\". Это действие нельзя отменить.\n\nВы уверены?';
  }

  @override
  String get dialogActionCancel => 'Отмена';

  @override
  String get dialogActionGoToDownload => 'Перейти на страницу загрузки';

  @override
  String get dialogActionConfirmInstallation => 'Подтвердить установку';

  @override
  String get dialogActionUpdateSystem => 'Обновить систему';

  @override
  String get dialogActionInstallAnyway => 'Все равно установить';

  @override
  String get dialogActionDelete => 'Удалить';

  @override
  String get dialogActionClose => 'Закрыть';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return 'Пакетная установка завершена. Успешно: $successCount, Неудачно: $failedCount.';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return 'Мод \"$modName\" успешно установлен.';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return 'Мод \"$modName\" включен.';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return 'Мод \"$modName\" отключен.';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return 'Мод \"$modName\" удален навсегда.';
  }

  @override
  String get snackBarCNSUpdated => 'Custom Nanosuit System успешно обновлена.';

  @override
  String get snackBarApiKeySaved => 'Ключ API успешно сохранен.';

  @override
  String get snackBarGamePathSaved => 'Путь к игре успешно сохранен.';

  @override
  String get snackBar7zipPathSaved => 'Путь к 7-Zip успешно сохранен.';

  @override
  String get snackBarSkippedVersionRemoved => 'Пропущенная версия удалена.';

  @override
  String get dropTargetOverlay => 'Перетащите моды сюда';

  @override
  String get pathSelectionTitle => 'Путь к Stellar Blade не найден';

  @override
  String get pathSelectionButtonManual => 'Выбрать папку с игрой вручную';

  @override
  String get pathSelectionButtonRetry => 'Попробовать снова';

  @override
  String errorFolderSelection(Object error) {
    return 'Ошибка выбора папки: $error';
  }

  @override
  String errorFileSelection(Object error) {
    return 'Ошибка выбора файлов: $error';
  }

  @override
  String errorDecompressing(Object error) {
    return 'Ошибка распаковки файла: $error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return 'Ошибка обработки файла: $error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return 'Неподдерживаемый формат файла: $extension';
  }

  @override
  String get error7zipRequired => 'Операция отменена: требуется 7-Zip.';

  @override
  String get errorGamePathUndefined => 'Путь к игре не определен.';

  @override
  String get errorDestinationNotFound => 'Папка назначения игры не существует.';

  @override
  String errorUpdateSystem(Object error) {
    return 'Ошибка обновления системы: $error';
  }

  @override
  String get errorInstallNoSelection => 'Вы ничего не выбрали для установки.';

  @override
  String get errorInstallModExists => 'Установка отменена: мод уже существует.';

  @override
  String get errorNoJsonFound =>
      'Каждый мод должен содержать хотя бы один файл .json.';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return 'Файл $fileName имеет неверный формат JSON.';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return 'Файл $fileName не является модом Custom Nanosuit System (отсутствует \"DisplayName\").';
  }

  @override
  String get errorNoValidDisplayName =>
      'В файлах .json не найдено действительного \"DisplayName\".';

  @override
  String errorEnableMod(Object error) {
    return 'Ошибка включения мода: $error';
  }

  @override
  String errorDisableMod(Object error) {
    return 'Ошибка отключения мода: $error';
  }

  @override
  String errorDeleteMod(Object error) {
    return 'Ошибка удаления мода: $error';
  }

  @override
  String errorOpenFolder(Object path) {
    return 'Не удалось открыть папку: $path';
  }

  @override
  String get statusUpdateSystemCancelled => 'Обновление системы отменено.';

  @override
  String get statusUpdatingCNS => 'Обновление Custom Nanosuit System...';

  @override
  String statusExtractingFile(Object fileName) {
    return 'Извлечение $fileName...';
  }

  @override
  String get statusInstallationCancelledByUser =>
      'Установка отменена пользователем.';

  @override
  String get errorNoCompatibleFilesInFolder =>
      'Выбранная папка не содержит совместимых файлов мода.';

  @override
  String get errorNoCompatibleFilesInArchive =>
      'Сжатый файл не содержит совместимых файлов мода.';

  @override
  String get errorNoJsonInSelection =>
      'Выбор не содержит действительного .json файла мода.';

  @override
  String get aboutTitle => 'О SB Control Center';

  @override
  String get aboutContent =>
      'SB Control Center — менеджер модов для Stellar Blade. Он устанавливает, упорядочивает и обновляет ваши моды в одном месте и работает с Custom Nanosuit System (CNS) для модов костюмов и наносьюта.\n\nПриложение подключается к Nexus Mods, чтобы скачивать моды, проверять обновления и ставить Endorse используемым модам.\n\nВключает 7-Zip (7-zip.org) для распаковки архивов .zip, .rar и .7z.';

  @override
  String get aboutEndorseCta =>
      'Нравится приложение? Endorse на Nexus Mods очень помогает.';

  @override
  String get aboutEndorseThanks => 'Спасибо за вашу поддержку!';

  @override
  String get aboutLinkText => 'Посетите мой профиль создателя';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return 'Версия: $version';
  }

  @override
  String get openModsFolder => 'Открыть папку с модами';

  @override
  String get openInNexusMods => 'Открыть в Nexus Mods';

  @override
  String get checkForUpdates => 'Проверить обновления';

  @override
  String updateAvailable(Object version) {
    return 'Доступно обновление: v$version';
  }

  @override
  String get dialogTitleApiKey => 'Ключ API Nexus Mods';

  @override
  String get dialogContentApiKey =>
      'Для проверки обновлений модов вам нужен личный ключ API от Nexus Mods.';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. Нажмите кнопку ниже, чтобы открыть Nexus Mods, и войдите в аккаунт.\n2. Прокрутите страницу до самого низа, до раздела \'Personal API Key\'.\n3. Запросите ключ, если его ещё нет, и скопируйте его.\n4. Вставьте его сюда.';

  @override
  String get apiKeyOpenNexusPage => 'Открыть страницу ключей API';

  @override
  String get apiKey => 'Ключ API';

  @override
  String get apiKeyHintText => 'Вставьте ваш ключ API сюда';

  @override
  String get dialogActionSave => 'Сохранить';

  @override
  String get apiKeyRemoved => 'Ключ API удален.';

  @override
  String get invalidApiKeyError => 'Неверный ключ API.';

  @override
  String get validatingApiKey => 'Проверка...';

  @override
  String get errorApiKeyMissing =>
      'Ключ API Nexus Mods не настроен. Добавьте его в разделе Настройки › Подключение и обновления › Ключ API Nexus Mods.';

  @override
  String get statusCheckingUpdates => 'Проверка обновлений модов...';

  @override
  String statusUpdatesFound(Object count) {
    return 'Найдено $count обновлений!';
  }

  @override
  String get statusNoUpdates => 'Все моды обновлены до последней версии.';

  @override
  String get selectModArchive => 'Выбрать архив мода';

  @override
  String get viewImageGallery => 'Просмотр галереи изображений';

  @override
  String get imageGallery => 'Галерея изображений';

  @override
  String get noImagesFound =>
      'Изображения для этого мода не найдены, или ключ API не был введен. Пожалуйста, введите ключ API и проверьте обновления после этого.';

  @override
  String errorFetchingImages(Object error) {
    return 'Ошибка при загрузке изображений: $error';
  }

  @override
  String get imageMod => 'Изображение мода';

  @override
  String get modEnabledBadge => 'Включен';

  @override
  String get modDisabledBadge => 'Отключен';

  @override
  String get modCategoryOther => 'Не указано';

  @override
  String get dialogContentUpdateOptions => 'Что бы вы хотели сделать?';

  @override
  String get dialogActionIgnoreVersion => 'Игнорировать';

  @override
  String get dialogActionSkipVersion => 'Пропустить версию';

  @override
  String get dialogActionGoToDownloadPage => 'Перейти к загрузке';

  @override
  String get installedMods => 'Установленные моды';

  @override
  String get filterBy => 'Фильтр:';

  @override
  String get sortBy => 'Сортировать по:';

  @override
  String get filterAll => 'Все';

  @override
  String get filterEnabled => 'Включенные';

  @override
  String get filterDisabled => 'Отключенные';

  @override
  String get filterRepaired => 'Восстановленные';

  @override
  String get sortByName => 'Имя';

  @override
  String get sortByDate => 'Дата';

  @override
  String get noModsFound => 'Моды не найдены.';

  @override
  String get viewTypeGrid => 'Вид сеткой';

  @override
  String get viewTypeList => 'Вид списком';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return 'Извлечение $count из $total: $fileName';
  }

  @override
  String get previewInstallTitle => 'Моды для установки:';

  @override
  String get dialogTitleUE4SS => 'Обнаружена установка UE4SS';

  @override
  String get dialogContentUE4SS =>
      'Обнаружен инструмент UE4SS. Хотите установить его в \'StellarBlade\\SB\\Binaries\\Win64\'?\n\nЭто необходимо для работы многих модов.';

  @override
  String get dialogActionInstallTool => 'Установить инструмент';

  @override
  String get statusUE4SSInstallCancelled => 'Установка UE4SS отменена.';

  @override
  String get statusInstallingUE4SS => 'Установка UE4SS...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SS успешно установлен.';

  @override
  String error7zipDecompression(Object error) {
    return 'Ошибка 7-Zip во время распаковки: $error';
  }

  @override
  String get statusUE4SSInstallComplete => 'Установка UE4SS завершена.';

  @override
  String get dialogTitleAlternativeVersion =>
      'Обнаружена альтернативная версия';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return 'Альтернативная версия этого мода уже установлена: \'$oldModName\'.\n\nВы собираетесь установить другую альтернативу под названием \'$newModName\'.';
  }

  @override
  String get dialogActionReplace => 'Заменить';

  @override
  String get dialogActionInstallAsNew => 'Установить как новый';

  @override
  String get dialogTitleUpdate => 'Доступно обновление';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Вы собираетесь обновить мод \'$modName\'.\n\nУстановленная версия: $oldVersion\nНовая версия: $newVersion';
  }

  @override
  String get dialogTitleDowngrade => 'Обнаружена более старая версия';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Внимание: вы собираетесь установить более старую версию мода \'$modName\'.\n\nУстановленная версия: $oldVersion\nВерсия для установки: $newVersion';
  }

  @override
  String get dialogTitleReinstall => 'Переустановить мод';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return 'Вы собираетесь переустановить версию \'$version\' мода \'$modName\'.';
  }

  @override
  String get dialogActionReinstall => 'Переустановить';

  @override
  String get editModNameTooltip => 'Редактировать имя мода';

  @override
  String get setCoverTooltip =>
      'Установить пользовательское изображение обложки';

  @override
  String get setCoverText => 'Установить обложку';

  @override
  String get restoreOriginalCoverText => 'Восстановить исходную обложку';

  @override
  String errorSavingCoverText(Object error) {
    return 'Ошибка сохранения изображения обложки: $error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return 'Ошибка восстановления исходного изображения обложки: $error';
  }

  @override
  String get editVersionText => 'Редактировать версию';

  @override
  String get customVersionText => 'Пользовательская версия';

  @override
  String get editTagText => 'Редактировать тег';

  @override
  String get customTagText => 'Пользовательский тег';

  @override
  String get dialogTitleEditModName => 'Редактировать имя мода';

  @override
  String get dialogActionResetToDefault => 'Сбросить по умолчанию';

  @override
  String get dialogLabelNewName => 'Новое имя';

  @override
  String errorModNameExists(Object modName) {
    return 'Мод с именем \"$modName\" уже существует.';
  }

  @override
  String get dialogTitleRepairedModWarning =>
      'Предупреждение о восстановленном моде';

  @override
  String get dialogContentRepairedModWarning =>
      'Этот мод может не содержать правильной информации о версии. Рекомендуется переустановить последнюю версию для обеспечения совместимости.';

  @override
  String get repairedModTooltip => 'Информация о восстановленном моде';

  @override
  String get disableAllModsTooltip => 'Отключить все моды';

  @override
  String get deleteAllModsTooltip => 'Удалить все отключенные моды';

  @override
  String get dialogTitleDisableAll => 'Отключить все моды?';

  @override
  String dialogContentDisableAll(int count) {
    return 'Вы уверены, что хотите отключить все $count включенных модов? Они будут перемещены в папку резервных копий.';
  }

  @override
  String get dialogTitleDeleteAll => 'Удалить отключенные моды?';

  @override
  String dialogContentDeleteAll(int count) {
    return 'Вы собираетесь навсегда удалить все $count отключенных модов. Это действие нельзя отменить.\n\nВы уверены?';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return 'Все $count включенных модов были отключены.';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return 'Все $count отключенных модов были удалены навсегда.';
  }

  @override
  String get snackBarNoModsToDisable => 'Нет включенных модов для отключения.';

  @override
  String get snackBarNoModsToDelete => 'Нет отключенных модов для удаления.';

  @override
  String get enableAllModsTooltip => 'Включить все моды';

  @override
  String get dialogTitleEnableAll => 'Включить все моды?';

  @override
  String dialogContentEnableAll(int count) {
    return 'Вы уверены, что хотите включить все $count отключенных модов? Они будут перемещены в основную папку модов.';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return 'Все $count отключенных модов были включены.';
  }

  @override
  String get snackBarNoModsToEnable => 'Нет отключенных модов для включения.';

  @override
  String get editNotes => 'Редактировать заметки';

  @override
  String get notesHintText => 'Добавьте свои личные заметки здесь...';

  @override
  String get modAuthor => 'Автор';

  @override
  String get modSummary => 'Краткое описание';

  @override
  String get modDescription => 'Описание';

  @override
  String get noDescriptionAvailable => 'Описание отсутствует.';

  @override
  String get personalNotes => 'Личные заметки';

  @override
  String get noNotesAvailable => 'Заметок пока нет.';

  @override
  String get modDetailsTitle => 'Детали мода';

  @override
  String get modVersion => 'Версия';

  @override
  String get modCategory => 'Категория';

  @override
  String get dialogTitleAddUrl => 'Добавить ссылку на мод';

  @override
  String get dialogLabelUrl => 'URL мода';

  @override
  String get errorInvalidUrl => 'Пожалуйста, введите действительный URL.';

  @override
  String get addLinkTooltip => 'Добавить ссылку для скачивания этого мода';

  @override
  String get addLinkButtonText => 'Добавить ссылку';

  @override
  String get openLinkButtonText => 'Открыть ссылку';

  @override
  String get editModTitle => 'Редактировать детали мода';

  @override
  String get modNameLabel => 'Имя мода';

  @override
  String get authorLabel => 'Автор';

  @override
  String get summaryLabel => 'Описание / Сводка';

  @override
  String get notesLabel => 'Личные заметки';

  @override
  String get urlLabel => 'URL для скачивания';

  @override
  String get changeCoverButton => 'Изменить изображение обложки';

  @override
  String get editButtonTooltip => 'Редактировать мод';

  @override
  String get errorSavingNotes => 'Ошибка сохранения заметок';

  @override
  String get errorSavingUrl => 'Ошибка сохранения URL';

  @override
  String get errorSavingChanges => 'Ошибка сохранения изменений';

  @override
  String get errorTranslation => 'Не удалось перевести описание';

  @override
  String get translateSummary => 'Перевести краткое описание';

  @override
  String get translateDescription => 'Перевести описание';

  @override
  String get restoreOriginalDescription => 'Восстановить исходное описание';

  @override
  String get dialogTitleUE4SSReinstall => 'Переустановить UE4SS';

  @override
  String get dialogContentUE4SSReinstall =>
      'UE4SS, похоже, уже установлен. Хотите перезаписать существующую установку? Это может быть полезно, если вы подозреваете повреждение файлов.';

  @override
  String get dialogTitleCNSReinstall => 'Переустановить систему CNS';

  @override
  String get dialogContentCNSReinstall =>
      'Основная система CNS, похоже, уже установлена. Хотите переустановить ее? Ваши существующие моды не будут затронуты.';

  @override
  String dialogTitleUninstall(Object componentName) {
    return 'Удалить $componentName';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return 'Вы уверены, что хотите удалить $componentName? Это действие удалит основные файлы компонента, но не затронет ваши установленные моды.';
  }

  @override
  String get dialogActionUninstall => 'Да, удалить';

  @override
  String statusUninstalling(Object componentName) {
    return 'Удаление $componentName...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentName успешно удален';
  }

  @override
  String errorUninstalling(Object componentName) {
    return 'Ошибка удаления $componentName';
  }

  @override
  String get settingsCoreComponents => 'Основные компоненты';

  @override
  String get installedStatus => 'Установлено';

  @override
  String get notInstalledStatus => 'Не обнаружено';

  @override
  String get uninstallButton => 'Удалить';

  @override
  String get cnsCoreSystem => 'Custom Nanosuit System';

  @override
  String get ue4ssInstallationDetected =>
      'Обнаружена и принята существующая установка UE4SS';

  @override
  String get cnsInstallationDetected =>
      'Обнаружена и принята существующая основная установка CNS';

  @override
  String get ue4ssRequiredTitle => 'Требуется UE4SS';

  @override
  String get ue4ssRequiredContent =>
      'Чтобы установить основную систему CNS, сначала необходимо установить UE4SS. Вы можете скачать его по следующей ссылке:';

  @override
  String get uninstallDependencyTitle => 'Обнаружена зависимость';

  @override
  String get uninstallDependencyContent =>
      'Вы должны удалить основную систему CNS, прежде чем сможете удалить UE4SS, так как CNS зависит от него.';

  @override
  String get dialogActionUnderstood => 'Понятно';

  @override
  String get appTitleNoCns => 'Custom Nanosuit System (Не установлено)';

  @override
  String get dialogTitleCNSUpdate => 'Обновить основную систему CNS';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return 'Вы собираетесь обновить CNS с версии $oldVersion до новой версии $newVersion. Хотите продолжить?';
  }

  @override
  String get dialogTitleCNSDowngrade => 'Понизить версию CNS';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return 'Внимание! Вы собираетесь установить более старую версию CNS ($newVersion), чем ваша текущая ($oldVersion). Это может вызвать проблемы. Вы уверены?';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return 'У вас уже установлена версия $version CNS. Хотите все равно переустановить файлы?';
  }

  @override
  String get dialogActionUpdate => 'Обновить';

  @override
  String get dialogActionDowngrade => 'Понизить';

  @override
  String get dialogTitleCNSInstall => 'Установить основную систему CNS';

  @override
  String get dialogContentCNSInstall =>
      'Вы собираетесь установить базовую систему Custom Nanosuit System (CNS). Это необходимо для работы модов CNS. Хотите продолжить?';

  @override
  String get dialogActionInstall => 'Установить';

  @override
  String get settingsDeveloperOptions => 'Опции разработчика';

  @override
  String get devDeleteNexusInfoTitle => 'Удалить все файлы nexus_info.json';

  @override
  String get devDeleteNexusInfoDesc =>
      'Удаляет все файлы метаданных менеджера из каждого мода. Это полезно для принудительного полного восстановления.';

  @override
  String get devExtractIdsTitle => 'Извлечь идентификаторы';

  @override
  String get devExtractIdsDesc =>
      'Создает на вашем рабочем столе файл с именем \'ID Mods.json\', содержащий displayName и nexusId каждого мода.';

  @override
  String get devConfirmDeleteTitle => 'Подтвердить удаление';

  @override
  String get devConfirmDeleteDesc =>
      'Вы уверены, что хотите навсегда удалить все файлы nexus_info.json? Это приведет к удалению всех пользовательских имен, обложек и метаданных. Это действие нельзя отменить.';

  @override
  String get devDeleteSuccessTitle => 'Удаление завершено';

  @override
  String devDeleteSuccessDesc(Object count) {
    return 'Успешно удалено $count файлов nexus_info.json.';
  }

  @override
  String get devConfirmExtractTitle => 'Подтвердить извлечение';

  @override
  String get devConfirmExtractDesc =>
      'Это просканирует все ваши моды и создаст \'ID Mods.json\' на вашем рабочем столе. Это перезапишет любой существующий файл с тем же именем. Хотите продолжить?';

  @override
  String get devExtractAction => 'Извлечь';

  @override
  String get devTestSelfUpdateTitle => 'Тест самообновления';

  @override
  String get devTestSelfUpdateDesc =>
      'Выберите .zip-пакет приложения и установите его поверх этого приложения — так же, как это сделает автоматическое обновление.';

  @override
  String get devSelfUpdateUnsupported =>
      'Самообновление доступно только в Windows.';

  @override
  String get devSelfUpdatePickTitle => 'Выберите .zip-файл SB Control Center';

  @override
  String get devSelfUpdateFailed => 'Не удалось установить обновление';

  @override
  String get devSelfUpdateDryRunTitle => 'Пакет корректен (тестовый режим)';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return 'Найдено файлов: $count. Установка не выполнялась, так как это не релизная сборка.';
  }

  @override
  String get devSelfUpdateConfirmTitle => 'Установить обновление?';

  @override
  String get devSelfUpdateConfirmDesc =>
      'Приложение закроется, заменит свои файлы файлами из пакета и автоматически запустится снова.';

  @override
  String get devSelfUpdateInstallAction => 'Установить и перезапустить';

  @override
  String get devSelfUpdateProgressTitle => 'Обновление SB Control Center';

  @override
  String get devSelfUpdateExtracting => 'Распаковка пакета…';

  @override
  String get devSelfUpdateInstalling => 'Установка файлов…';

  @override
  String get devSelfUpdateRestarting => 'Перезапуск…';

  @override
  String get devExtractNoData =>
      'Не найдено модов с действительными идентификаторами для извлечения.';

  @override
  String get devExtractDesktopNotFound =>
      'Ошибка: Не удалось найти каталог рабочего стола.';

  @override
  String get devExtractSuccessTitle => 'Извлечение завершено';

  @override
  String devExtractSuccessDesc(Object path) {
    return 'Файл успешно создан по адресу: $path';
  }

  @override
  String get errorDialogTitle => 'Произошла ошибка';

  @override
  String get modDetailsCategory => 'Категория';

  @override
  String get modDetailsAuthor => 'Автор';

  @override
  String get modDetailsNexusId => 'Nexus ID';

  @override
  String get modDetailsInstalledOn => 'Установлено';

  @override
  String get unknownAuthor => 'Неизвестен';

  @override
  String get statusInstalling => 'Установка...';

  @override
  String statusInstallingMod(int index, int total, String modName) {
    return 'Установка $index/$total: $modName';
  }

  @override
  String byText(Object author) {
    return 'от $author';
  }

  @override
  String get filterUpdatesAvailable => 'Доступны обновления';

  @override
  String snackBarUpdateIgnored(String modName) {
    return 'Обновление для \'$modName\' проигнорировано в этом сеансе.';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return 'Версия \'$version\' для \'$modName\' будет пропущена при будущих проверках.';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return 'Обновление метаданных для \'$displayName\' ($arg1 из $arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return 'Установлен общий мод: $modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return 'Установлено в $path.\nЭтот мод не управляется приложением и должен быть удален вручную.';
  }

  @override
  String genericModInstallError(String modName) {
    return 'Не удалось установить общий мод: $modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => 'Общий';

  @override
  String get modTypeMovies => 'Видео';

  @override
  String get modTypeSave => 'Сохранение';

  @override
  String get modTypeConfig => 'Конфигурация';

  @override
  String get modTypeSplash => 'Заставка';

  @override
  String get replacesOutfitTitle => 'Заменяет костюм';

  @override
  String get replacesOutfitClearTooltip => 'Очистить выбор костюма';

  @override
  String get replacesOutfitSelectTooltip => 'Выбрать костюм для замены';

  @override
  String get replacesOutfitNone => 'Костюм не выбран.\nТег будет \'Общий\'.';

  @override
  String get replacesOutfitSearchHint => 'Поиск костюмов...';

  @override
  String get modTypeReplacement => 'Замена';

  @override
  String get replacesOutfitHover =>
      'Наведите курсор на костюм, чтобы увидеть предварительный просмотр.';

  @override
  String get dialogTitleOutfitReplacement => 'Замена костюма?';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return 'Мод \'$modName\' является заменой костюма?\n\nВыберите \'Да\', чтобы указать, какой костюм он заменяет, или \'Нет\', чтобы установить его как общий мод.';
  }

  @override
  String get dialogActionNo => 'Нет';

  @override
  String get dialogActionYes => 'Да';

  @override
  String get dialogTitleOutfitConflict => 'Обнаружен конфликт костюмов';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return 'Костюм \'$outfitName\' уже заменяется модом \'$modName\'.\n\nХотите отключить \'$modName\' и активировать этот мод?';
  }

  @override
  String get dialogActionActivateAndDisable => 'Отключить и Активировать';

  @override
  String get replacementModSwitchTitle => 'Мод-замена';

  @override
  String get replacementModSwitchDesc =>
      'Отметьте, если этот мод предназначен для замены костюма в игре.';

  @override
  String get settingsShowModTagsTitle => 'Показывать теги типов модов';

  @override
  String get settingsShowModTagsDesc =>
      'Отображать теги типов модов (например, CNS, Общий) на каждой карточке мода в списке.';

  @override
  String get modTypeLogic => 'Логика';

  @override
  String get patcherStarted => '=== StellarBlade Dart Patcher Запущен ===';

  @override
  String workingDirectory(String path) {
    return 'Рабочий каталог: $path';
  }

  @override
  String modsDirNotFound(String path) {
    return 'Каталог ~mods не существует по адресу: $path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  ВНИМАНИЕ: Не удалось просканировать папку $path. Пропуск.';
  }

  @override
  String errorDetails(String error) {
    return '  Ошибка: $error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return 'Найдено $count файлов .utoc';
  }

  @override
  String get noModsFound2 => 'Моды для обработки не найдены.';

  @override
  String get patcherSummaryTitle =>
      '\n=== Сводка патчера (Необработанные данные) ===';

  @override
  String processedMods(int count) {
    return 'Обработано $count модов.';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return 'Исправлено $count конфликтов Container ID.';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return 'Найдено $count конфликтов Package ID.';
  }

  @override
  String get fatalErrorTitle => '\n=== КРИТИЧЕСКАЯ ОШИБКА ===';

  @override
  String patcherServiceError(String error) {
    return 'Ошибка в PatcherService: $error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- Анализ: $fileName ---';
  }

  @override
  String get warnUcasNotFound => '  ВНИМАНИЕ: Файл .ucas не найден. Пропуск.';

  @override
  String get warnCorruptHeader =>
      '  ВНИМАНИЕ: Поврежденный заголовок, размер записи превышает размер файла. Пропуск.';

  @override
  String conflictContainerIdDetected(int id) {
    return '  ОБНАРУЖЕН КОНФЛИКТ Container ID: $id';
  }

  @override
  String generatingNewId(int id) {
    return '  Генерация нового ID: $id';
  }

  @override
  String get utocFilePatched => '  Файл .utoc пропатчен.';

  @override
  String get patchingUcasFile => '  Установка патча для файла .ucas...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  Успешные замены в .ucas: $count';
  }

  @override
  String get patchComplete => '  Патч завершен!';

  @override
  String idRegisteredNoConflict(int id) {
    return '  ID $id зарегистрирован. Конфликтов нет.';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  ОШИБКА при обработке $fileName: $error';
  }

  @override
  String get statusRunningPatcher => 'Запуск патчера конфликтов...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ Успешно! Исправлено $count конфликтов Container ID, вызывающих сбои.';
  }

  @override
  String get summaryNoContainerIdConflicts =>
      '✅ Конфликтов Container ID (сбоев) не обнаружено.';

  @override
  String get summaryNoPackageIdConflicts =>
      '✅ Отличные новости! Серьезных конфликтов Package ID (перезаписи) не обнаружено.';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ Внимание! Найдено $count групп модов, которые не могут сосуществовать:';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • Эта группа модов конкурирует за $count файлов:';
  }

  @override
  String get patcherSummaryDialogTitle => 'Сводка патчера';

  @override
  String get dialogActionShowFullLog => 'Показать полный журнал';

  @override
  String get fullLogDialogTitle => 'Журнал патчера конфликтов (Dart)';

  @override
  String get runConflictPatcherTitle => 'Запустить патчер конфликтов';

  @override
  String get runConflictPatcherSubtitlePython =>
      'Исправляет сбои Container_Id и Package_Id';

  @override
  String get processingCover => 'Обработка обложки...';

  @override
  String get apiKeyTooltip =>
      'Ключ API требуется для интеллектуального извлечения Nexus ID.';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return 'Параметры установки - Мод $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection =>
      'Выберите опции, которые вы хотите установить. Необходимые основные файлы будут установлены автоматически.';

  @override
  String get snackBarSpecialModNoSelection =>
      'Выберите хотя бы одну опцию для продолжения.';

  @override
  String get dialogActionInstallSelection => 'Установить выбранное';

  @override
  String get downloadStatusFetching => 'Получение данных Nexus Mods...';

  @override
  String get downloadStatusFetchingFailed =>
      'Не удалось получить ссылку на скачивание. Проверьте ваш API-ключ или подключение.';

  @override
  String downloadStatusDownloading(String fileName) {
    return 'Скачивание $fileName';
  }

  @override
  String get downloadStatusError => 'Ошибка во время скачивания файла.';

  @override
  String downloadStatusException(String error) {
    return 'Исключение: $error';
  }

  @override
  String get dialogTitleDownloadModManager => 'Загрузка Mod Manager';

  @override
  String get launchGameText => 'Запустить Stellar Blade';

  @override
  String get stopGameText => 'Закрыть Stellar Blade';

  @override
  String get dialogTitleStopGame => 'Закрыть Stellar Blade?';

  @override
  String get dialogContentStopGame =>
      'Игра будет закрыта. Несохранённый прогресс будет потерян.';

  @override
  String get dialogActionStopGame => 'Закрыть';

  @override
  String get notificationGameStopped => 'Игра закрыта';

  @override
  String get errorStoppingGame => 'Не удалось закрыть игру';

  @override
  String get mod801DialogTitle => 'Требуется настройка Steam';

  @override
  String get mod801DialogIntro =>
      'Установлен мод Random Splash. Чтобы он работал автоматически при запуске игры, необходимо настроить Steam.';

  @override
  String get mod801Step1 =>
      '1. Сгенерируйте точный путь для вашего ПК ниже и скопируйте его.';

  @override
  String get mod801Step2 => '2. Откройте библиотеку Steam.';

  @override
  String get mod801Step3 =>
      '3. Щелкните правой кнопкой мыши Stellar Blade -> Свойства.';

  @override
  String get mod801Step4 =>
      '4. На вкладке «Общие» вставьте код в «Параметры запуска».';

  @override
  String get mod801BtnGenerate => 'Сгенерировать путь';

  @override
  String get mod801BtnSteam => 'Открыть Steam';

  @override
  String get mod801BtnCopy => 'Копировать';

  @override
  String get mod801PathGenerated => 'Путь успешно сгенерирован.';

  @override
  String get mod801PathCopied => 'Команда скопирована в буфер обмена!';

  @override
  String get statusVerifyingMods => 'Проверка целостности модов...';

  @override
  String errorSelecting7Zip(String error) {
    return 'Ошибка при выборе 7-Zip: $error';
  }

  @override
  String get errorInvalidFolderRetry =>
      'Выбранная папка кажется неправильной. Пожалуйста, попробуйте снова.';

  @override
  String errorSelectingFolderDynamic(String error) {
    return 'Ошибка при выборе папки: $error';
  }

  @override
  String get statusNoNewModsInstalled => 'Установка не добавила новых модов.';

  @override
  String get errorDisableModBeforeDelete =>
      'Пожалуйста, отключите мод перед его удалением.';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return 'Включено: $successCount (Пропущено из-за конфликтов: $skippedCount)';
  }

  @override
  String get snackBarDeveloperModeEnabled => 'Режим разработчика включен!';

  @override
  String errorRenamingMod(String error) {
    return 'Ошибка при переименовании мода: $error';
  }

  @override
  String get notificationTitleError => 'Ошибка';

  @override
  String get errorGamePathNotFoundNotification => 'Путь к игре не найден.';

  @override
  String get notificationLaunchingGame => 'Запуск Stellar Blade...';

  @override
  String get errorLaunchingGame => 'Ошибка при запуске игры';

  @override
  String get dialogTitleSelect7zip => 'Выберите файл 7z.exe';

  @override
  String get dialogTitleSelectGameFolder =>
      'Пожалуйста, выберите главную папку StellarBlade';

  @override
  String get dialogTitleSelectCover => 'Выберите обложку для мода';

  @override
  String get errorGamePathNotFoundException => 'Путь к игре не найден.';

  @override
  String get errorGamePathNotDefined => 'Путь к игре не определен.';

  @override
  String get errorLogicModsPathNotDefined => 'Путь к модам Logic не определен.';

  @override
  String get errorUe4ssModsPathNotDefined => 'Путь к модам UE4SS не определен.';

  @override
  String get errorGenericModsPathNotDefined =>
      'Путь к общим модам (~mods) не определен.';

  @override
  String get errorReplaceNoOldVersion =>
      'Попытка заменить мод, но старая версия не найдена.';

  @override
  String errorDeleteOldModVersion(String modName) {
    return 'Не удалось удалить старую версию мода ($modName).';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return 'Не удалось удалить существующий мод ($modName) для переустановки.';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return 'Не удалось удалить существующий мод ($modName) для переустановки после нескольких попыток.';
  }

  @override
  String get errorMoviesModNoValidFiles =>
      'Мод с видео не содержит допустимых видеофайлов.';

  @override
  String get errorInstallPathUndetermined =>
      'Не удалось определить путь установки.';

  @override
  String get errorMoviesPathsNotDefined => 'Пути к видео не определены.';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return 'Файл nexus_info.json не найден для $modName.';
  }

  @override
  String get errorMenuVideoLimitReached => 'Достигнут лимит в 99 видео в меню.';

  @override
  String get errorModRequires529 =>
      'Для работы мода требуется Mod ID 529 (содержит только файлы WebM).';

  @override
  String get errorSplashPathsNotDefined => 'Пути к заставкам не определены.';

  @override
  String get errorSplashNoValidImages =>
      'В моде не найдено допустимых изображений.';

  @override
  String get errorCouldNotDeleteDirectory => 'Не удалось удалить каталог.';

  @override
  String get errorGameExeNotFound =>
      'Исполняемый файл игры (.exe) не найден в главной папке или в Binaries.';

  @override
  String get dialogTitleSplashOptions => 'Параметры заставки (изображения)';

  @override
  String get dialogContentSplashOptions =>
      'Выберите изображения, которые хотите установить. Вы можете выбирать целые папки или отдельные изображения.';

  @override
  String get snackBarSplashNoSelection =>
      'Пожалуйста, выберите хотя бы одно изображение.';

  @override
  String get dialogContentSpecialModSingleSelection =>
      'Выберите один вариант для установки.';

  @override
  String get activeDownloads => 'Активные загрузки';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'модов',
      one: 'мода',
    );
    return 'Загрузка $count $_temp0';
  }

  @override
  String get downloadError => 'Ошибка';

  @override
  String get downloadCancelled => 'Отменено';

  @override
  String get downloadPause => 'Пауза';

  @override
  String get downloadResume => 'Продолжить';

  @override
  String get downloadCancel => 'Отмена';

  @override
  String get errorNexusInfoNotFound => 'Файл nexus_info.json не найден.';

  @override
  String logFixingCorruptedJson(String displayName) {
    return 'Исправление поврежденного nexus_info.json для $displayName.';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return 'Не удалось обновить метаданные для $displayName: $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return 'Превентивное отключение мода видео из-за активации мода 529: $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return 'Превентивное отключение мода заставки из-за активации мода 801: $modName';
  }

  @override
  String logRestoringTildeComponent(String folderName) {
    return 'Восстановление компонента ~mods: $folderName';
  }

  @override
  String logRestoringUe4ssComponent(String folderName) {
    return 'Восстановление компонента UE4SS: $folderName';
  }

  @override
  String logErrorRestoringLogicMod(String error) {
    return 'Ошибка восстановления компонентов LogicMod: $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return 'Архивация компонента ~mods: $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return 'Архивация компонента UE4SS: $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return 'Ошибка архивации компонентов LogicMod: $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return 'Пропуск $modName: Активный вариант этого мода уже существует.';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return 'Пропуск $modName: Конфликт с уже занятым костюмом.';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return 'Не удалось очистить резервные копии видео для $modName: $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return 'Обнаружен новый Nexus ID $nexusId. Получение метаданных...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return 'Метаданные получены и применены для $nexusId.';
  }

  @override
  String logFallbackByteCopy(String error) {
    return 'Обычное копирование не удалось, используется побайтовый метод: $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return 'Предупреждение: Не удалось удалить измененный файл: $error';
  }

  @override
  String get logMod801BatPatched =>
      'Скрипт .bat мода 801 успешно пропатчен для этой системы.';

  @override
  String logMod801BatPatchError(String error) {
    return 'Ошибка при попытке пропатчить файл .bat мода 801: $error';
  }

  @override
  String get errorHomeDirNotFound =>
      'Не удалось найти переменную среды домашнего каталога.';

  @override
  String get downloadFetchingPlaceholder => 'Получение...';

  @override
  String get downloadErrorLink => 'Не удалось получить ссылку для загрузки';

  @override
  String get downloadErrorGeneral => 'Ошибка загрузки';

  @override
  String get downloadPausedStatus => 'На паузе';

  @override
  String get settingsFixGameStartup => 'Исправить незапуск игры';

  @override
  String get settingsFixGameStartupDesc =>
      'Используйте, если игра закрывается или вылетает при запуске. UE4SS и CNS временно удаляются, игра запускается один раз, после чего они устанавливаются заново.';

  @override
  String get repairConfirmTitle => 'Исправить запуск игры?';

  @override
  String get repairConfirmMessage =>
      'UE4SS и CNS будут удалены (их файлы сохраняются), игра автоматически запустится и закроется, затем всё будет установлено заново и игра запустится снова. Не закрывайте приложение во время процесса.';

  @override
  String get repairConfirmAction => 'Начать';

  @override
  String get launchRetryTitle => 'Игра не запустилась';

  @override
  String get launchRetryMessage =>
      'Stellar Blade не запустилась после двух попыток. Обычно причина в UE4SS или CNS. Функция «Исправить незапуск игры» временно удаляет их, запускает игру один раз и устанавливает их снова. Выполнить сейчас?';

  @override
  String get launchRetryAction => 'Исправить сейчас';

  @override
  String get repairOverlayTitle => 'Исправление запуска игры';

  @override
  String get repairOverlayWarning =>
      'Не закрывайте приложение и игру вручную, пока идёт процесс.';

  @override
  String get repairStepCloseGame => 'Закрытие игры, если она запущена';

  @override
  String get repairStepStashCns => 'Удаление CNS (файлы сохраняются)';

  @override
  String get repairStepStashUe4ss => 'Удаление UE4SS (файлы сохраняются)';

  @override
  String get repairStepLaunchClean => 'Запуск игры без UE4SS и CNS';

  @override
  String get repairStepWaitInit => 'Ожидание загрузки игры';

  @override
  String get repairStepCloseAuto => 'Автоматическое закрытие игры';

  @override
  String get repairStepRestoreUe4ss => 'Повторная установка UE4SS';

  @override
  String get repairStepRestoreCns => 'Повторная установка CNS';

  @override
  String get repairStepLaunchFinal => 'Запуск игры';

  @override
  String get repairStatusSkipped => 'пропущено';

  @override
  String get repairResultSuccess => 'Исправление завершено. Игра запущена.';

  @override
  String get repairResultErrorRestored =>
      'Исправление не удалось, но UE4SS и CNS возвращены на место.';

  @override
  String get repairResultErrorRestoreFailed =>
      'Исправление не удалось, и файлы пока не восстановлены. Они будут восстановлены автоматически при следующем запуске приложения.';

  @override
  String get repairErrorGameNotStarted => 'Игра не запустилась вовремя.';

  @override
  String get repairButtonClose => 'Закрыть';

  @override
  String get repairRecoveredNotice =>
      'Обнаружено прерванное исправление: файлы UE4SS и CNS восстановлены.';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return 'Установлен новый вариант: $name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return 'Теперь у этого мода установлено вариантов: $count.';
  }

  @override
  String get previewTagNewEdition => 'новый вариант';

  @override
  String get previewTagUpdate => 'обновление';

  @override
  String editionsInstalledTooltip(Object count) {
    return 'Установлено вариантов этого мода: $count';
  }

  @override
  String editionLabelValue(Object edition) {
    return 'Вариант: $edition';
  }

  @override
  String get otherEditionsTitle => 'Другие установленные варианты';

  @override
  String get detailsStatusEnabled => 'Включен';

  @override
  String get detailsStatusDisabled => 'Отключен';

  @override
  String get detailsInformation => 'Информация';

  @override
  String get detailsRowAuthor => 'Автор';

  @override
  String get detailsRowType => 'Тип';

  @override
  String get detailsRowInstalled => 'Установлен';

  @override
  String get detailsRowModified => 'Последнее изменение';

  @override
  String get detailsRowNexusId => 'ID Nexus';

  @override
  String get detailsRowFolder => 'Папка';

  @override
  String get detailsCopyPath => 'Копировать путь';

  @override
  String get detailsCopied => 'Скопировано в буфер обмена';

  @override
  String get detailsEndorse => 'Endorse';

  @override
  String get detailsEndorsed => 'Endorsed';

  @override
  String endorseWaitLabel(Object minutes) {
    return 'Подождите $minutes мин';
  }

  @override
  String get endorseSuccessTitle => 'Мод получил Endorse';

  @override
  String get endorseRemovedTitle => 'Endorse снят';

  @override
  String get endorseFailedTitle => 'Не удалось обновить Endorse';

  @override
  String get endorseErrNotNexus =>
      'Этот мод не связан со страницей Nexus Mods, поэтому для него нельзя поставить Endorse.';

  @override
  String get endorseErrNoApiKey =>
      'Добавьте ключ API Nexus Mods в настройках, чтобы ставить Endorse модам.';

  @override
  String endorseErrWait(Object minutes) {
    return 'Nexus требует подождать 15 минут после загрузки мода, прежде чем можно будет поставить ему Endorse. Повторите попытку через $minutes мин.';
  }

  @override
  String get endorseErrNotDownloaded =>
      'Nexus позволяет ставить Endorse только модам, загруженным с вашей учётной записи.';

  @override
  String get endorseErrOwnMod => 'Нельзя поставить Endorse собственному моду.';

  @override
  String get endorseErrRateLimit =>
      'Достигнут лимит запросов Nexus. Повторите попытку позже.';

  @override
  String get endorseErrInvalidKey =>
      'Nexus отклонил ваш ключ API. Проверьте его в настройках.';

  @override
  String get endorseErrNetwork =>
      'Не удалось подключиться к Nexus Mods. Проверьте соединение и повторите попытку.';

  @override
  String get endorseErrUnknown =>
      'Nexus не смог обработать запрос. Повторите попытку позже.';

  @override
  String get endorseRemoveConfirmTitle => 'Снять Endorse?';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return 'У $name больше не будет Endorse на Nexus Mods.';
  }

  @override
  String get endorseRemoveConfirmAction => 'Снять';

  @override
  String get detailsUpdateAction => 'Обновить';

  @override
  String get detailsShowMore => 'Показать больше';

  @override
  String get detailsShowLess => 'Показать меньше';

  @override
  String get detailsAddNote => 'Добавить заметку';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count костюма',
      many: '$count костюмов',
      few: '$count костюма',
      one: '1 костюм',
      zero: 'Нет костюмов',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get outfitsChoose => 'Выбрать костюмы';

  @override
  String get outfitsDone => 'Готово';

  @override
  String get outfitsFilterAll => 'Все';

  @override
  String get outfitsFilterSelected => 'Выбранные';

  @override
  String get outfitsClearAll => 'Очистить всё';

  @override
  String get outfitsRemove => 'Удалить';

  @override
  String get outfitsActionSelect => 'Выбрать';

  @override
  String get outfitsActionDeselect => 'Снять выбор';

  @override
  String outfitsNoResults(String query) {
    return 'Нет результатов для «$query»';
  }

  @override
  String get outfitsSelectedEmpty => 'Костюмы ещё не выбраны.';

  @override
  String get outfitsNoPreview => 'Предпросмотр недоступен';

  @override
  String get replacementOffConfirmTitle => 'Отключить мод-замену?';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбранные $count костюма будут удалены из этого мода.',
      many: 'Выбранные $count костюмов будут удалены из этого мода.',
      few: 'Выбранные $count костюма будут удалены из этого мода.',
      one: 'Выбранный костюм будет удалён из этого мода.',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => 'Отключить';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count мода отключено: они заменяют костюмы, которые уже используются другими модами',
      many:
          '$count модов отключено: они заменяют костюмы, которые уже используются другими модами',
      few:
          '$count мода отключены: они заменяют костюмы, которые уже используются другими модами',
      one:
          '$count мод отключён: он заменяет костюм, который уже используется другим модом',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  Тот же Container ID, что и у: $owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved =>
      '  Оригиналы сохранены как .cnsbak (можно восстановить).';

  @override
  String patcherLeftUntouched(String reason) {
    return '  Оставлено без изменений (патч небезопасен): $reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ $count мод(ов) используют общий Container ID, но их не удалось безопасно исправить (оставлены без изменений; они могут не отображаться в CNS):';
  }

  @override
  String get revertPatchesTitle => 'Откатить патчи конфликтов';

  @override
  String get revertPatchesDesc =>
      'Восстанавливает исходные файлы модов, изменённые патчером конфликтов.';

  @override
  String get revertPatchesConfirmTitle => 'Откатить патчи конфликтов?';

  @override
  String get revertPatchesConfirmMessage =>
      'Исходные файлы, сохранённые патчером конфликтов (.cnsbak), будут восстановлены. Сначала закройте игру. Конфликтующие моды снова могут перестать отображаться в CNS.';

  @override
  String get revertPatchesAction => 'Откатить';

  @override
  String revertPatchesDone(int count) {
    return 'Восстановлено файлов: $count.';
  }

  @override
  String get revertPatchesNothing => 'Нет пропатченных файлов для отката.';

  @override
  String get settingsGroupPaths => 'Пути';

  @override
  String get settingsGroupTools => 'Инструменты';

  @override
  String get settingsAutoOutfit => 'Назначать костюмы автоматически';

  @override
  String get settingsAutoOutfitDesc =>
      'При установке мода-замены определяет, какой костюм он заменяет, по его файлам. Если выключено, костюм назначается вручную.';

  @override
  String get variantChoiceTitle => 'Несколько вариантов одной замены';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return 'Мод «$mod» содержит несколько вариантов, заменяющих $outfits. Одновременно может быть активен только один. Какой установить?';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return 'Мод «$mod» содержит несколько вариантов, заменяющих одни и те же файлы. Одновременно может быть активен только один. Какой установить?';
  }

  @override
  String get variantChoiceInstallAll => 'Установить все (как отдельные моды)';

  @override
  String get installOutfitConflictTitle => 'Костюм уже занят';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return 'Мод «$newMod» заменяет костюм $outfits, который уже назначен активному моду «$oldMod». Одновременно может быть активен только один. Какой оставить активным?';
  }

  @override
  String get installOutfitKeepCurrent => 'Оставить текущий';

  @override
  String get installOutfitUseNew => 'Включить новый';

  @override
  String installOutfitNowActive(String active) {
    return 'Теперь активен: $active';
  }

  @override
  String get fileLockErrorTitle => 'Не удалось переместить мод';

  @override
  String get fileLockErrorMessage =>
      'Возможно, другое приложение использует файлы игры (FModel, сама игра, антивирус, Проводник...). Закройте его и повторите попытку.';

  @override
  String get nexusProfileTooltip => 'Профиль Nexus Mods';

  @override
  String get nexusUserFallback => 'Пользователь';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => 'Участник';

  @override
  String get nexusPlanSupporter => 'Сторонник';

  @override
  String get nexusApiRequestsRemaining => 'ОСТАВШИЕСЯ ЗАПРОСЫ API';

  @override
  String get nexusApiDaily => 'За сутки';

  @override
  String get nexusApiHourly => 'В час';

  @override
  String get downloadMemberAccountLimit =>
      'Аккаунты «Участник» ограничены Nexus Mods до 1,5 МБ/с';

  @override
  String get downloadSupporterAccountLimit =>
      'Аккаунты «Сторонник» ограничены Nexus Mods до 3 МБ/с';

  @override
  String get downloadRetryTooltip => 'Повторить';

  @override
  String get downloadRefreshingLink => 'Обновление ссылки...';

  @override
  String get downloadNoInternet =>
      'Нет подключения к интернету. Проверьте сеть.';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'Срок действия ссылки Nexus истёк ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'Ошибка HTTP: $code';
  }

  @override
  String get downloadErrorTimeout => 'Тайм-аут: данные из сети не поступают';

  @override
  String get splashRootFolder => 'Корень (основная)';

  @override
  String get repairErrorGameNotClosed => 'Не удалось завершить процесс игры.';

  @override
  String get errorManifestNotFound =>
      'Манифест установки не найден. Удаление невозможно.';

  @override
  String get downloadResuming => 'Возобновление...';

  @override
  String get apiKeyPromptTitle => 'Настройте ключ API Nexus Mods';

  @override
  String get apiKeyPromptMessage =>
      'Ключ API не обнаружен. Настройка необязательна, но рекомендуется для удобства: с ним можно проверять обновления модов, скачивать в один клик (nxm://) и загружать обложки и информацию с Nexus Mods.';

  @override
  String get apiKeyPromptConfigure => 'Настроить ключ API';

  @override
  String get apiKeyPromptSkip => 'Пропустить';

  @override
  String get apiKeyPromptDontShowAgain => 'Больше не показывать это сообщение';

  @override
  String get adjustCoverTooltip => 'Настроить обложку';

  @override
  String get noCoverToAdjust => 'У этого мода нет обложки для настройки';

  @override
  String errorAdjustingCoverText(Object error) {
    return 'Ошибка при настройке обложки: $error';
  }
}
