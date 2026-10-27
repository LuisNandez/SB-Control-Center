// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => 'Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDesc => 'Choose the application language';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutDesc => 'Information about the application';

  @override
  String get settingsRefreshMetadata => 'Update metadata';

  @override
  String get settingsRefreshMetadataDesc =>
      'Checks your mods again on Nexus Mods and completes missing details and images';

  @override
  String get metadataRefreshDone => 'Metadata updated';

  @override
  String get metadataRefreshNoApiKey =>
      'Add your Nexus Mods API key in Settings to update metadata.';

  @override
  String get settingsPathsAndTools => 'Paths & Tools';

  @override
  String get settingsGameFolder => 'Game Folder';

  @override
  String get settingsGameFolderDesc =>
      'The root folder of your Stellar Blade installation.';

  @override
  String get settings7zipPath => '7-Zip Path';

  @override
  String get settings7zipPathDesc =>
      'The location of the 7z.exe file for extracting mods.';

  @override
  String get settings7zipPathAuto => 'Automatic search';

  @override
  String get settingsRepairMods => 'Repair Legacy Mods';

  @override
  String get settingsRepairModsDesc =>
      'Scans and creates info files for old mods using the local database. Requires API key.';

  @override
  String get settingsConnectivity => 'Connectivity & Updates';

  @override
  String get settingsApiKey => 'Nexus Mods API Key';

  @override
  String get settingsApiKeyDesc => 'Required for checking mod updates.';

  @override
  String get settingsApiKeySet => 'Set';

  @override
  String get settingsApiKeyNotSet => 'Not set';

  @override
  String get settingsSkippedVersions => 'Manage Skipped Versions';

  @override
  String get settingsSkippedVersionsDesc =>
      'Manage mod versions you have chosen to skip.';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count versions skipped';
  }

  @override
  String get dialogTitleSkippedVersions => 'Skipped Mod Versions';

  @override
  String get dialogNoSkippedVersions =>
      'You have not skipped any mod versions.';

  @override
  String get dialogSkippedVersions => 'Skipped Version';

  @override
  String get dialogTitleRepairMods => 'Run Legacy Mod Repair?';

  @override
  String get dialogContentRepairMods =>
      'Warning: This feature is in development and may not be perfect.\n\nIt will scan mods without a \'nexus_info.json\' file and, if found in your local database, create one for them. It will also attempt to rename the mod\'s folder to include the found version (e.g., \'My Mod\' -> \'My Mod v1.2\').\n\nVersion Priority:\n1. From the folder name.\n2. From the mod\'s description field.\n3. From the latest version on Nexus Mods (requires API).\n\nDo you want to continue?';

  @override
  String get dialogActionRunRepair => 'Run Repair';

  @override
  String get snackBarGamePathInvalid =>
      'The selected folder does not appear to be a valid game folder.';

  @override
  String get snackBar7zipPathInvalid =>
      'The selected file must be named 7z.exe.';

  @override
  String get snackBarRepairStarted =>
      'Legacy mod repair process has started...';

  @override
  String snackBarRepairComplete(Object count) {
    return 'Repair complete. $count mod(s) were updated.';
  }

  @override
  String get snackBarRepairNoMods =>
      'No legacy mods were found that needed repairing.';

  @override
  String get errorApiRequiredForRepair =>
      'API Key is required to find the latest version for mods without a local version.';

  @override
  String get installNewMod => 'Install Mod';

  @override
  String get selectFiles => 'Select Files';

  @override
  String get selectFolder => 'Select Folder';

  @override
  String get installSelectedMod => 'Install Selected Mod';

  @override
  String get filesToInstall => 'Files to Install:';

  @override
  String get cancelSelection => 'Cancel Selection';

  @override
  String get searchMods => 'Search mods...';

  @override
  String get enabledMods => 'Enabled Mods';

  @override
  String get disabledMods => 'Disabled Mods';

  @override
  String get refreshList => 'Refresh list';

  @override
  String get noEnabledMods => 'No enabled mods.';

  @override
  String get noDisabledMods => 'No disabled mods.';

  @override
  String get showInFolder => 'Show in folder';

  @override
  String get disableMod => 'Disable mod';

  @override
  String get enableMod => 'Enable mod';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select a language';

  @override
  String get statusSearchingGame =>
      'Searching for Stellar Blade installation...';

  @override
  String get statusGamePathFound => 'Game path found!';

  @override
  String get statusGamePathNotFound =>
      'Could not find the game path automatically.';

  @override
  String statusErrorFindingGame(Object error) {
    return 'An error occurred while searching for the game: $error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount mod(s) enabled, $disabledCount disabled.';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return 'Error reading installed mods: $error';
  }

  @override
  String statusFilesSelected(Object count) {
    return '$count file(s) selected. Ready to install.';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return 'Folder \"$folderName\" selected. Ready to install.';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return 'File \"$fileName\" loaded. $count file(s) ready to install.';
  }

  @override
  String get statusSelectionCancelled =>
      'Selection cancelled. Choose a new mod to install.';

  @override
  String get statusUpdateComplete => 'Update complete.';

  @override
  String get statusInstallationComplete => 'Installation complete.';

  @override
  String statusError(Object error) {
    return 'Error: $error';
  }

  @override
  String get dialogTitle7zip => '7-Zip is Required';

  @override
  String get dialogContent7zip =>
      'To decompress this file, the application needs 7-Zip.\n\nPlease install it from its official page and then press \"Confirm\".';

  @override
  String get dialogContent7zipNotFound =>
      '7-Zip has not been detected yet. Please make sure it is installed in the default path and try again.';

  @override
  String get dialogTitleMultipleJsons => 'Multiple .json Files Detected';

  @override
  String dialogContentMultipleJsons(Object count) {
    return '$count .json files have been detected. This could be a mod with multiple components.\n\nDo you want to install them all together in a single mod folder?';
  }

  @override
  String get dialogTitleModExists => 'Mod Already Exists';

  @override
  String dialogContentModExists(Object modName) {
    return 'A mod named \"$modName\" is already installed.\n\nDo you want to update it? Old files will be deleted before installing the new ones.';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return 'An older version \'$oldModName\' was found.\n\nDo you want to remove it and update to \'$newModName\'?';
  }

  @override
  String get dialogTitleDeleteMod => 'Delete Permanently?';

  @override
  String dialogContentDeleteMod(Object modName) {
    return 'You are about to permanently delete the mod \"$modName\". This action cannot be undone.\n\nAre you sure?';
  }

  @override
  String get dialogActionCancel => 'Cancel';

  @override
  String get dialogActionGoToDownload => 'Go to Download Page';

  @override
  String get dialogActionConfirmInstallation => 'Confirm Installation';

  @override
  String get dialogActionUpdateSystem => 'Update System';

  @override
  String get dialogActionInstallAnyway => 'Install Anyway';

  @override
  String get dialogActionDelete => 'Delete';

  @override
  String get dialogActionClose => 'Close';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return 'Batch installation complete. Success: $successCount, Failed: $failedCount.';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return 'Mod \"$modName\" installed successfully.';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return 'Mod \"$modName\" enabled.';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return 'Mod \"$modName\" disabled.';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return 'Mod \"$modName\" permanently deleted.';
  }

  @override
  String get snackBarCNSUpdated =>
      'Custom Nanosuit System updated successfully.';

  @override
  String get snackBarApiKeySaved => 'API Key saved successfully.';

  @override
  String get snackBarGamePathSaved => 'Game path saved successfully.';

  @override
  String get snackBar7zipPathSaved => '7-Zip path saved successfully.';

  @override
  String get snackBarSkippedVersionRemoved => 'Skipped version removed.';

  @override
  String get dropTargetOverlay => 'Drop mods here';

  @override
  String get pathSelectionTitle => 'Stellar Blade Path Not Found';

  @override
  String get pathSelectionButtonManual => 'Select Game Folder Manually';

  @override
  String get pathSelectionButtonRetry => 'Try Again';

  @override
  String errorFolderSelection(Object error) {
    return 'Error selecting folder: $error';
  }

  @override
  String errorFileSelection(Object error) {
    return 'Error selecting files: $error';
  }

  @override
  String errorDecompressing(Object error) {
    return 'Error decompressing file: $error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return 'Error processing file: $error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return 'Unsupported file format: $extension';
  }

  @override
  String get error7zipRequired => 'Operation cancelled: 7-Zip is required.';

  @override
  String get errorGamePathUndefined => 'Game path is not defined.';

  @override
  String get errorDestinationNotFound =>
      'The game\'s destination folder does not exist.';

  @override
  String errorUpdateSystem(Object error) {
    return 'Error updating system: $error';
  }

  @override
  String get errorInstallNoSelection =>
      'You have not selected anything to install.';

  @override
  String get errorInstallModExists =>
      'Installation cancelled: Mod already exists.';

  @override
  String get errorNoJsonFound =>
      'Each mod must contain at least one .json file.';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return 'The file $fileName has an invalid JSON format.';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return 'The file $fileName does not appear to be a Custom Nanosuit System mod (missing \"DisplayName\").';
  }

  @override
  String get errorNoValidDisplayName =>
      'No valid \"DisplayName\" was found in the .json files.';

  @override
  String errorEnableMod(Object error) {
    return 'Error enabling mod: $error';
  }

  @override
  String errorDisableMod(Object error) {
    return 'Error disabling mod: $error';
  }

  @override
  String errorDeleteMod(Object error) {
    return 'Error deleting mod: $error';
  }

  @override
  String errorOpenFolder(Object path) {
    return 'Could not open folder: $path';
  }

  @override
  String get statusUpdateSystemCancelled => 'System update cancelled.';

  @override
  String get statusUpdatingCNS => 'Updating Custom Nanosuit System...';

  @override
  String statusExtractingFile(Object fileName) {
    return 'Extracting $fileName...';
  }

  @override
  String get statusInstallationCancelledByUser =>
      'Installation cancelled by user.';

  @override
  String get errorNoCompatibleFilesInFolder =>
      'The selected folder does not contain compatible mod files.';

  @override
  String get errorNoCompatibleFilesInArchive =>
      'The compressed file does not contain compatible mod files.';

  @override
  String get errorNoJsonInSelection =>
      'The selection does not contain a valid mod .json file.';

  @override
  String get aboutTitle => 'About SB Control Center';

  @override
  String get aboutContent =>
      'SB Control Center is a mod manager for Stellar Blade. It installs, organizes, and updates your mods in one place, and works with the Custom Nanosuit System (CNS) for outfit and nanosuit mods.\n\nIt connects to Nexus Mods to download, check for updates, and endorse the mods you use.\n\nIncludes 7-Zip (7-zip.org) to extract .zip, .rar and .7z archives.';

  @override
  String get aboutEndorseCta =>
      'Enjoying the app? An Endorse on Nexus Mods helps a lot.';

  @override
  String get aboutEndorseThanks => 'Thank you for your support!';

  @override
  String get aboutLinkText => 'Visit my creator profile';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return 'Version: $version';
  }

  @override
  String get openModsFolder => 'Open Mods Folder';

  @override
  String get openInNexusMods => 'Open in Nexus Mods';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String updateAvailable(Object version) {
    return 'Update available: v$version';
  }

  @override
  String get dialogTitleApiKey => 'Nexus Mods API Key';

  @override
  String get dialogContentApiKey =>
      'To check for mod updates, you need a personal API key from Nexus Mods.';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. Click the button below to open Nexus Mods and log in.\n2. Scroll to the bottom of the page, to the \'Personal API Key\' section.\n3. Request it if you don\'t have one yet, then copy it.\n4. Paste it here.';

  @override
  String get apiKeyOpenNexusPage => 'Open API Keys Page';

  @override
  String get apiKey => 'API Key';

  @override
  String get apiKeyHintText => 'Paste your API key here';

  @override
  String get dialogActionSave => 'Save';

  @override
  String get apiKeyRemoved => 'API Key removed.';

  @override
  String get invalidApiKeyError => 'Invalid API Key.';

  @override
  String get validatingApiKey => 'Validating...';

  @override
  String get errorApiKeyMissing =>
      'Nexus Mods API Key is missing. Add it in Settings › Connectivity & Updates › Nexus Mods API Key.';

  @override
  String get statusCheckingUpdates => 'Checking for mod updates...';

  @override
  String statusUpdatesFound(Object count) {
    return '$count update(s) found!';
  }

  @override
  String get statusNoUpdates => 'All mods are up to date.';

  @override
  String get selectModArchive => 'Select Mod Archive';

  @override
  String get viewImageGallery => 'View Image';

  @override
  String get imageGallery => 'Image Gallery';

  @override
  String get noImagesFound =>
      'No images were found for this mod, or the API key has not been entered. Please enter the API key and check for updates afterward.';

  @override
  String errorFetchingImages(Object error) {
    return 'Error fetching images: $error';
  }

  @override
  String get imageMod => 'Mod Image';

  @override
  String get modEnabledBadge => 'Enabled';

  @override
  String get modDisabledBadge => 'Disabled';

  @override
  String get modCategoryOther => 'Unspecified';

  @override
  String get dialogContentUpdateOptions => 'What would you like to do?';

  @override
  String get dialogActionIgnoreVersion => 'Ignore';

  @override
  String get dialogActionSkipVersion => 'Skip Version';

  @override
  String get dialogActionGoToDownloadPage => 'Go to Download';

  @override
  String get installedMods => 'Installed Mods';

  @override
  String get filterBy => 'Filter:';

  @override
  String get sortBy => 'Sort by:';

  @override
  String get filterAll => 'All';

  @override
  String get filterEnabled => 'Enabled';

  @override
  String get filterDisabled => 'Disabled';

  @override
  String get filterRepaired => 'Repaired';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByDate => 'Date';

  @override
  String get noModsFound => 'No mods found.';

  @override
  String get viewTypeGrid => 'Grid view';

  @override
  String get viewTypeList => 'List view';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return 'Extracting $count of $total: $fileName';
  }

  @override
  String get previewInstallTitle => 'Mods to be Installed:';

  @override
  String get dialogTitleUE4SS => 'UE4SS Installation Detected';

  @override
  String get dialogContentUE4SS =>
      'The UE4SS tool has been detected. Do you want to install it to \'StellarBlade\\SB\\Binaries\\Win64\'?\n\nThis is required for many mods to work.';

  @override
  String get dialogActionInstallTool => 'Install Tool';

  @override
  String get statusUE4SSInstallCancelled => 'UE4SS installation cancelled.';

  @override
  String get statusInstallingUE4SS => 'Installing UE4SS...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SS installed successfully.';

  @override
  String error7zipDecompression(Object error) {
    return '7-Zip error during decompression: $error';
  }

  @override
  String get statusUE4SSInstallComplete => 'UE4SS installation complete.';

  @override
  String get dialogTitleAlternativeVersion => 'Alternative Version Detected';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return 'An alternative version of this mod is already installed: \'$oldModName\'.\n\nYou are about to install a different alternative named \'$newModName\'.';
  }

  @override
  String get dialogActionReplace => 'Replace';

  @override
  String get dialogActionInstallAsNew => 'Install as New';

  @override
  String get dialogTitleUpdate => 'Update Available';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'You are about to update the mod \'$modName\'.\n\nInstalled version: $oldVersion\nNew version: $newVersion';
  }

  @override
  String get dialogTitleDowngrade => 'Older Version Detected';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Warning: You are about to install an older version of the mod \'$modName\'.\n\nInstalled version: $oldVersion\nVersion to install: $newVersion';
  }

  @override
  String get dialogTitleReinstall => 'Reinstall Mod';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return 'You are about to reinstall version \'$version\' of the mod \'$modName\'.';
  }

  @override
  String get dialogActionReinstall => 'Reinstall';

  @override
  String get editModNameTooltip => 'Edit mod name';

  @override
  String get setCoverTooltip => 'Set custom cover image';

  @override
  String get setCoverText => 'Set Cover';

  @override
  String get restoreOriginalCoverText => 'Restore Original Cover';

  @override
  String errorSavingCoverText(Object error) {
    return 'Error saving cover image: $error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return 'Error restoring original cover image: $error';
  }

  @override
  String get editVersionText => 'Edit Version';

  @override
  String get customVersionText => 'Custom Version';

  @override
  String get editTagText => 'Edit Tag';

  @override
  String get customTagText => 'Custom Tag';

  @override
  String get dialogTitleEditModName => 'Edit Mod Name';

  @override
  String get dialogActionResetToDefault => 'Reset to Default';

  @override
  String get dialogLabelNewName => 'New name';

  @override
  String errorModNameExists(Object modName) {
    return 'A mod named \"$modName\" already exists.';
  }

  @override
  String get dialogTitleRepairedModWarning => 'Repaired Mod Warning';

  @override
  String get dialogContentRepairedModWarning =>
      'This mod might not have the correct version information. Reinstalling the latest version is recommended to ensure compatibility.';

  @override
  String get repairedModTooltip => 'Information about repaired mod';

  @override
  String get disableAllModsTooltip => 'Disable all mods';

  @override
  String get deleteAllModsTooltip => 'Delete all disabled mods';

  @override
  String get dialogTitleDisableAll => 'Disable All Mods?';

  @override
  String dialogContentDisableAll(int count) {
    return 'Are you sure you want to disable all $count enabled mods? They will be moved to the backup folder.';
  }

  @override
  String get dialogTitleDeleteAll => 'Delete Disabled Mods?';

  @override
  String dialogContentDeleteAll(int count) {
    return 'You are about to permanently delete all $count disabled mods. This action cannot be undone.\n\nAre you sure?';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return 'All $count enabled mods have been disabled.';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return 'All $count disabled mods have been permanently deleted.';
  }

  @override
  String get snackBarNoModsToDisable => 'There are no enabled mods to disable.';

  @override
  String get snackBarNoModsToDelete => 'There are no disabled mods to delete.';

  @override
  String get enableAllModsTooltip => 'Enable all mods';

  @override
  String get dialogTitleEnableAll => 'Enable All Mods?';

  @override
  String dialogContentEnableAll(int count) {
    return 'Are you sure you want to enable all $count disabled mods? They will be moved to the main mods folder.';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return 'All $count disabled mods have been enabled.';
  }

  @override
  String get snackBarNoModsToEnable => 'There are no disabled mods to enable.';

  @override
  String get editNotes => 'Edit Notes';

  @override
  String get notesHintText => 'Add your personal notes here...';

  @override
  String get modAuthor => 'Author';

  @override
  String get modSummary => 'Summary';

  @override
  String get modDescription => 'Description';

  @override
  String get noDescriptionAvailable => 'No description available.';

  @override
  String get personalNotes => 'Personal Notes';

  @override
  String get noNotesAvailable => 'No notes added yet.';

  @override
  String get modDetailsTitle => 'Mod Details';

  @override
  String get modVersion => 'Version';

  @override
  String get modCategory => 'Category';

  @override
  String get dialogTitleAddUrl => 'Add Mod Link';

  @override
  String get dialogLabelUrl => 'Mod URL';

  @override
  String get errorInvalidUrl => 'Please enter a valid URL.';

  @override
  String get addLinkTooltip => 'Add a download link for this mod';

  @override
  String get addLinkButtonText => 'Add Link';

  @override
  String get openLinkButtonText => 'Open Link';

  @override
  String get editModTitle => 'Edit Mod Details';

  @override
  String get modNameLabel => 'Mod Name';

  @override
  String get authorLabel => 'Author';

  @override
  String get summaryLabel => 'Description / Summary';

  @override
  String get notesLabel => 'Personal Notes';

  @override
  String get urlLabel => 'Download URL';

  @override
  String get changeCoverButton => 'Change Cover Image';

  @override
  String get editButtonTooltip => 'Edit Mod';

  @override
  String get errorSavingNotes => 'Error saving notes';

  @override
  String get errorSavingUrl => 'Error saving URL';

  @override
  String get errorSavingChanges => 'Error Saving Changes';

  @override
  String get errorTranslation => 'Could not translate description';

  @override
  String get translateSummary => 'Translate summary';

  @override
  String get translateDescription => 'Translate description';

  @override
  String get restoreOriginalDescription => 'Restore original description';

  @override
  String get dialogTitleUE4SSReinstall => 'Reinstall UE4SS';

  @override
  String get dialogContentUE4SSReinstall =>
      'UE4SS already seems to be installed. Do you want to overwrite the existing installation? This can be useful if you suspect corrupt files.';

  @override
  String get dialogTitleCNSReinstall => 'Reinstall CNS System';

  @override
  String get dialogContentCNSReinstall =>
      'The main CNS system already seems to be installed. Do you want to reinstall it? Your existing mods will not be affected.';

  @override
  String dialogTitleUninstall(Object componentName) {
    return 'Uninstall $componentName';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return 'Are you sure you want to uninstall $componentName? This action will remove the core component files but will not affect your installed mods.';
  }

  @override
  String get dialogActionUninstall => 'Yes, uninstall';

  @override
  String statusUninstalling(Object componentName) {
    return 'Uninstalling $componentName...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentName uninstalled successfully';
  }

  @override
  String errorUninstalling(Object componentName) {
    return 'Error uninstalling $componentName';
  }

  @override
  String get settingsCoreComponents => 'Core Components';

  @override
  String get installedStatus => 'Installed';

  @override
  String get notInstalledStatus => 'Not detected';

  @override
  String get uninstallButton => 'Uninstall';

  @override
  String get cnsCoreSystem => 'Custom Nanosuit System';

  @override
  String get ue4ssInstallationDetected =>
      'Existing UE4SS installation detected and adopted';

  @override
  String get cnsInstallationDetected =>
      'Existing Main CNS installation detected and adopted';

  @override
  String get ue4ssRequiredTitle => 'UE4SS Required';

  @override
  String get ue4ssRequiredContent =>
      'To install the Main CNS System, you must first install UE4SS. You can download it from the following link:';

  @override
  String get uninstallDependencyTitle => 'Dependency Detected';

  @override
  String get uninstallDependencyContent =>
      'You must uninstall the Main CNS System before you can uninstall UE4SS, as CNS depends on it.';

  @override
  String get dialogActionUnderstood => 'Understood';

  @override
  String get appTitleNoCns => 'Custom Nanosuit System (Not Installed)';

  @override
  String get dialogTitleCNSUpdate => 'Update Main CNS System';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return 'You are about to update CNS from version $oldVersion to the new version $newVersion. Do you wish to continue?';
  }

  @override
  String get dialogTitleCNSDowngrade => 'Downgrade CNS Version';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return 'Warning! You are about to install an older version of CNS ($newVersion) than your current one ($oldVersion). This may cause issues. Are you sure?';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return 'You already have version $version of CNS installed. Do you want to reinstall the files anyway?';
  }

  @override
  String get dialogActionUpdate => 'Update';

  @override
  String get dialogActionDowngrade => 'Downgrade';

  @override
  String get dialogTitleCNSInstall => 'Install Main CNS System';

  @override
  String get dialogContentCNSInstall =>
      'You are about to install the base Custom Nanosuit System (CNS). This is required for CNS mods to work. Do you wish to continue?';

  @override
  String get dialogActionInstall => 'Install';

  @override
  String get settingsDeveloperOptions => 'Developer Options';

  @override
  String get devDeleteNexusInfoTitle => 'Delete All nexus_info.json Files';

  @override
  String get devDeleteNexusInfoDesc =>
      'Removes all manager metadata files from every mod. This is useful for forcing a full repair.';

  @override
  String get devExtractIdsTitle => 'Extract Identifiers';

  @override
  String get devExtractIdsDesc =>
      'Creates a file named \'ID Mods.json\' on your desktop containing the displayName and nexusId of each mod.';

  @override
  String get devConfirmDeleteTitle => 'Confirm Deletion';

  @override
  String get devConfirmDeleteDesc =>
      'Are you sure you want to permanently delete all nexus_info.json files? This will remove all custom names, covers, and metadata. This action cannot be undone.';

  @override
  String get devDeleteSuccessTitle => 'Deletion Complete';

  @override
  String devDeleteSuccessDesc(Object count) {
    return 'Successfully deleted $count nexus_info.json files.';
  }

  @override
  String get devConfirmExtractTitle => 'Confirm Extraction';

  @override
  String get devConfirmExtractDesc =>
      'This will scan all your mods and create \'ID Mods.json\' on your desktop. This will overwrite any existing file with the same name. Do you want to continue?';

  @override
  String get devExtractAction => 'Extract';

  @override
  String get devTestSelfUpdateTitle => 'Test self-update';

  @override
  String get devTestSelfUpdateDesc =>
      'Pick the app\'s .zip package and install it over this app, as the automatic update will do.';

  @override
  String get devSelfUpdateUnsupported =>
      'Self-update is only available on Windows.';

  @override
  String get devSelfUpdatePickTitle => 'Select the SB Control Center .zip';

  @override
  String get devSelfUpdateFailed => 'Could not install the update';

  @override
  String get devSelfUpdateDryRunTitle => 'Package is valid (test mode)';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return '$count files found. It was not installed because this is not a release build.';
  }

  @override
  String get devSelfUpdateConfirmTitle => 'Install update?';

  @override
  String get devSelfUpdateConfirmDesc =>
      'The app will close, replace its files with the ones from the package and open again automatically.';

  @override
  String get devSelfUpdateInstallAction => 'Install and restart';

  @override
  String get devSelfUpdateProgressTitle => 'Updating SB Control Center';

  @override
  String get devSelfUpdateExtracting => 'Extracting package…';

  @override
  String get devSelfUpdateInstalling => 'Installing files…';

  @override
  String get devSelfUpdateRestarting => 'Restarting…';

  @override
  String get devExtractNoData =>
      'No mods with valid identifiers were found to extract.';

  @override
  String get devExtractDesktopNotFound =>
      'Error: Could not find the Desktop directory.';

  @override
  String get devExtractSuccessTitle => 'Extraction Complete';

  @override
  String devExtractSuccessDesc(Object path) {
    return 'File successfully created at: $path';
  }

  @override
  String get errorDialogTitle => 'An Error Occurred';

  @override
  String get modDetailsCategory => 'Category';

  @override
  String get modDetailsAuthor => 'Author';

  @override
  String get modDetailsNexusId => 'Nexus ID';

  @override
  String get modDetailsInstalledOn => 'Installed on';

  @override
  String get unknownAuthor => 'Unknown';

  @override
  String get statusInstalling => 'Installing...';

  @override
  String statusInstallingMod(int index, int total, String modName) {
    return 'Installing $index/$total: $modName';
  }

  @override
  String byText(Object author) {
    return 'by $author';
  }

  @override
  String get filterUpdatesAvailable => 'Updates Available';

  @override
  String snackBarUpdateIgnored(String modName) {
    return 'Update for \'$modName\' ignored for this session.';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return 'Version \'$version\' of \'$modName\' will be skipped in future checks.';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return 'Updating metadata for \'$displayName\' ($arg1 of $arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return 'Generic Mod Installed: $modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return 'Installed to $path. This mod is not managed by the app and must be uninstalled manually.';
  }

  @override
  String genericModInstallError(String modName) {
    return 'Failed to install generic mod: $modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => 'Generic';

  @override
  String get modTypeMovies => 'Movies';

  @override
  String get modTypeSave => 'Save';

  @override
  String get modTypeConfig => 'Config';

  @override
  String get modTypeSplash => 'Splash';

  @override
  String get replacesOutfitTitle => 'Replaces Outfit';

  @override
  String get replacesOutfitClearTooltip => 'Clear outfit selection';

  @override
  String get replacesOutfitSelectTooltip => 'Select outfit to replace';

  @override
  String get replacesOutfitNone =>
      'No outfit selected. The tag will be \'Generic\'.';

  @override
  String get replacesOutfitSearchHint => 'Search outfits...';

  @override
  String get modTypeReplacement => 'Replacement';

  @override
  String get replacesOutfitHover => 'Hover over an outfit to see a preview.';

  @override
  String get dialogTitleOutfitReplacement => 'Outfit Replacement?';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return 'Is the mod \'$modName\' an outfit replacement?\n\nSelect \'Yes\' to choose which outfit it replaces, or \'No\' to install it as a generic mod.';
  }

  @override
  String get dialogActionNo => 'No';

  @override
  String get dialogActionYes => 'Yes';

  @override
  String get dialogTitleOutfitConflict => 'Outfit Conflict Detected';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return 'The outfit \'$outfitName\' is already being replaced by the mod \'$modName\'.\n\nDo you want to disable \'$modName\' and activate this one instead?';
  }

  @override
  String get dialogActionActivateAndDisable => 'Disable and Activate';

  @override
  String get replacementModSwitchTitle => 'Replacement mod';

  @override
  String get replacementModSwitchDesc =>
      'Check if this mod is designed to replace a suit in the game.';

  @override
  String get settingsShowModTagsTitle => 'Show mod type tags';

  @override
  String get settingsShowModTagsDesc =>
      'Display mod type tags (e.g., CNS, Generic) on each mod card in the list.';

  @override
  String get modTypeLogic => 'Logic';

  @override
  String get patcherStarted => '=== StellarBlade Dart Patcher Started ===';

  @override
  String workingDirectory(String path) {
    return 'Working directory: $path';
  }

  @override
  String modsDirNotFound(String path) {
    return 'The ~mods directory does not exist at: $path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  WARNING: Could not scan folder $path. Skipping.';
  }

  @override
  String errorDetails(String error) {
    return '  Error: $error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return 'Found $count .utoc files';
  }

  @override
  String get noModsFound2 => 'No mods found to process.';

  @override
  String get patcherSummaryTitle => '\n=== Patcher Summary (Raw Data) ===';

  @override
  String processedMods(int count) {
    return 'Processed $count mods.';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return 'Fixed $count Container ID conflicts.';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return 'Found $count Package ID conflicts.';
  }

  @override
  String get fatalErrorTitle => '\n=== FATAL ERROR ===';

  @override
  String patcherServiceError(String error) {
    return 'Error in PatcherService: $error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- Analyzing: $fileName ---';
  }

  @override
  String get warnUcasNotFound => '  WARNING: .ucas file not found. Skipping.';

  @override
  String get warnCorruptHeader =>
      '  WARNING: Corrupt header, entry size exceeds file size. Skipping.';

  @override
  String conflictContainerIdDetected(int id) {
    return '  Container ID CONFLICT detected: $id';
  }

  @override
  String generatingNewId(int id) {
    return '  Generating new ID: $id';
  }

  @override
  String get utocFilePatched => '  .utoc file patched.';

  @override
  String get patchingUcasFile => '  Patching .ucas file...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  Successful replacements in .ucas: $count';
  }

  @override
  String get patchComplete => '  Patch complete!';

  @override
  String idRegisteredNoConflict(int id) {
    return '  ID $id registered. No conflicts.';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  ERROR processing $fileName: $error';
  }

  @override
  String get statusRunningPatcher => 'Running Conflict Patcher...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ Success! Fixed $count crash-causing Container ID conflicts.';
  }

  @override
  String get summaryNoContainerIdConflicts =>
      '✅ No Container ID (crash) conflicts were found.';

  @override
  String get summaryNoPackageIdConflicts =>
      '✅ Good news! No serious Package ID (overwrite) conflicts were found.';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ Warning! Found $count groups of mods that cannot coexist:';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • This group of mods competes for $count files:';
  }

  @override
  String get patcherSummaryDialogTitle => 'Patcher Summary';

  @override
  String get dialogActionShowFullLog => 'Show Full Log';

  @override
  String get fullLogDialogTitle => 'Conflict Patcher Log (Dart)';

  @override
  String get runConflictPatcherTitle => 'Run Conflict Patcher';

  @override
  String get runConflictPatcherSubtitlePython =>
      'Fixes Container_Id & Package_Id crashes';

  @override
  String get processingCover => 'Processing Cover...';

  @override
  String get apiKeyTooltip =>
      'API Key is required for smart Nexus ID extraction.';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return 'Installation Options - Mod $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection =>
      'Select the options you want to install. The required main files will be installed automatically.';

  @override
  String get snackBarSpecialModNoSelection =>
      'Select at least one option to continue.';

  @override
  String get dialogActionInstallSelection => 'Install Selection';

  @override
  String get downloadStatusFetching => 'Obtaining Nexus Mods data...';

  @override
  String get downloadStatusFetchingFailed =>
      'Failed to get download link. Check your API Key or connection.';

  @override
  String downloadStatusDownloading(String fileName) {
    return 'Downloading $fileName';
  }

  @override
  String get downloadStatusError => 'Error during file download.';

  @override
  String downloadStatusException(String error) {
    return 'Exception: $error';
  }

  @override
  String get dialogTitleDownloadModManager => 'Mod Manager Download';

  @override
  String get launchGameText => 'Launch Stellar Blade';

  @override
  String get stopGameText => 'Stop Stellar Blade';

  @override
  String get dialogTitleStopGame => 'Stop Stellar Blade?';

  @override
  String get dialogContentStopGame =>
      'The game will be closed. Any unsaved progress will be lost.';

  @override
  String get dialogActionStopGame => 'Stop';

  @override
  String get notificationGameStopped => 'Stellar Blade stopped';

  @override
  String get errorStoppingGame => 'Could not stop the game';

  @override
  String get mod801DialogTitle => 'Steam Configuration Required';

  @override
  String get mod801DialogIntro =>
      'The Random Splash mod has been installed. To make it work automatically when you launch the game, you need to configure Steam.';

  @override
  String get mod801Step1 =>
      '1. Generate the exact path for your PC below and copy it.';

  @override
  String get mod801Step2 => '2. Open your Steam Library.';

  @override
  String get mod801Step3 => '3. Right-click on Stellar Blade -> Properties.';

  @override
  String get mod801Step4 =>
      '4. In the \'General\' tab, paste the code into \'Launch Options\'.';

  @override
  String get mod801BtnGenerate => 'Generate Path';

  @override
  String get mod801BtnSteam => 'Open Steam';

  @override
  String get mod801BtnCopy => 'Copy';

  @override
  String get mod801PathGenerated => 'Path generated successfully.';

  @override
  String get mod801PathCopied => 'Command copied to clipboard!';

  @override
  String get statusVerifyingMods => 'Verifying integrity of mods...';

  @override
  String errorSelecting7Zip(String error) {
    return 'Error selecting 7-Zip: $error';
  }

  @override
  String get errorInvalidFolderRetry =>
      'The selected folder does not seem to be correct. Please try again.';

  @override
  String errorSelectingFolderDynamic(String error) {
    return 'Error selecting folder: $error';
  }

  @override
  String get statusNoNewModsInstalled => 'Installation produced no new mods.';

  @override
  String get errorDisableModBeforeDelete =>
      'Please disable the mod before deleting it.';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return 'Enabled: $successCount (Skipped: $skippedCount due to conflicts)';
  }

  @override
  String get snackBarDeveloperModeEnabled => 'Developer Mode Enabled!';

  @override
  String errorRenamingMod(String error) {
    return 'Error renaming mod: $error';
  }

  @override
  String get notificationTitleError => 'Error';

  @override
  String get errorGamePathNotFoundNotification => 'Game path not found.';

  @override
  String get notificationLaunchingGame => 'Launching Stellar Blade...';

  @override
  String get errorLaunchingGame => 'Error launching the game';

  @override
  String get dialogTitleSelect7zip => 'Select the 7z.exe file';

  @override
  String get dialogTitleSelectGameFolder =>
      'Please select the main StellarBlade folder';

  @override
  String get dialogTitleSelectCover => 'Select a cover for the mod';

  @override
  String get errorGamePathNotFoundException => 'Game path not found.';

  @override
  String get errorGamePathNotDefined => 'Game path not defined.';

  @override
  String get errorLogicModsPathNotDefined => 'LogicMods path is not defined.';

  @override
  String get errorUe4ssModsPathNotDefined => 'UE4SS Mods path is not defined.';

  @override
  String get errorGenericModsPathNotDefined =>
      'Generic mods (~mods) path is not defined.';

  @override
  String get errorReplaceNoOldVersion =>
      'Attempted to replace a mod but no old version was identified.';

  @override
  String errorDeleteOldModVersion(String modName) {
    return 'Could not delete old mod version ($modName).';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return 'Could not delete existing mod ($modName) to reinstall.';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return 'Could not delete existing mod ($modName) to reinstall after several attempts.';
  }

  @override
  String get errorMoviesModNoValidFiles =>
      'Movies mod contains no valid video files.';

  @override
  String get errorInstallPathUndetermined =>
      'Installation path could not be determined.';

  @override
  String get errorMoviesPathsNotDefined => 'Movies paths are not defined.';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return 'nexus_info.json not found for $modName.';
  }

  @override
  String get errorMenuVideoLimitReached => 'Menu video limit of 99 reached.';

  @override
  String get errorModRequires529 =>
      'The mod requires Mod ID 529 to work (contains only WebM files).';

  @override
  String get errorSplashPathsNotDefined => 'Splash paths are not defined.';

  @override
  String get errorSplashNoValidImages =>
      'No valid images were found in the mod.';

  @override
  String get errorCouldNotDeleteDirectory => 'Could not delete directory.';

  @override
  String get errorGameExeNotFound =>
      'The game\'s executable file (.exe) was not found in the main folder or in Binaries.';

  @override
  String get dialogTitleSplashOptions => 'Splash Options (Images)';

  @override
  String get dialogContentSplashOptions =>
      'Select the images you want to install. You can choose entire folders (batches) or individual images.';

  @override
  String get snackBarSplashNoSelection => 'Please select at least one image.';

  @override
  String get dialogContentSpecialModSingleSelection =>
      'Select a single option to install.';

  @override
  String get activeDownloads => 'Active Downloads';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mods',
      one: 'mod',
    );
    return 'Downloading $count $_temp0';
  }

  @override
  String get downloadError => 'Error';

  @override
  String get downloadCancelled => 'Cancelled';

  @override
  String get downloadPause => 'Pause';

  @override
  String get downloadResume => 'Resume';

  @override
  String get downloadCancel => 'Cancel';

  @override
  String get errorNexusInfoNotFound => 'nexus_info.json not found.';

  @override
  String logFixingCorruptedJson(String displayName) {
    return 'Fixing corrupted nexus_info.json for $displayName.';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return 'Failed to update metadata for $displayName: $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return 'Preventively disabling movie mod due to Mod 529 activation: $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return 'Preventively disabling splash mod due to Mod 801 activation: $modName';
  }

  @override
  String logRestoringTildeComponent(String folderName) {
    return 'Restoring ~mods component: $folderName';
  }

  @override
  String logRestoringUe4ssComponent(String folderName) {
    return 'Restoring UE4SS component: $folderName';
  }

  @override
  String logErrorRestoringLogicMod(String error) {
    return 'Error restoring LogicMod components: $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return 'Archiving ~mods component: $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return 'Archiving UE4SS component: $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return 'Error archiving LogicMod components: $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return 'Skipping $modName: An active variant of this mod already exists.';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return 'Skipping $modName: Conflict with an already occupied outfit.';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return 'Could not clean video backups for $modName: $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return 'New Nexus ID $nexusId detected. Fetching metadata...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return 'Metadata fetched and applied for $nexusId.';
  }

  @override
  String logFallbackByteCopy(String error) {
    return 'Normal copy failed, using byte brute-force: $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return 'Warning: Could not delete modified file: $error';
  }

  @override
  String get logMod801BatPatched =>
      'Mod 801 .bat script successfully patched for this system.';

  @override
  String logMod801BatPatchError(String error) {
    return 'Error attempting to patch the Mod 801 .bat file: $error';
  }

  @override
  String get errorHomeDirNotFound =>
      'Could not find the home directory environment variable.';

  @override
  String get downloadFetchingPlaceholder => 'Fetching...';

  @override
  String get downloadErrorLink => 'Could not fetch download link';

  @override
  String get downloadErrorGeneral => 'Download failed';

  @override
  String get downloadPausedStatus => 'Paused';

  @override
  String get settingsFixGameStartup => 'Fix game not starting';

  @override
  String get settingsFixGameStartupDesc =>
      'Use this if the game closes or crashes on launch. Temporarily uninstalls UE4SS and CNS, starts the game once, then reinstalls them.';

  @override
  String get repairConfirmTitle => 'Fix game startup?';

  @override
  String get repairConfirmMessage =>
      'UE4SS and CNS will be uninstalled (their files are kept safe), the game will start and close automatically, and then everything is reinstalled and the game launches again. Don\'t close the app during the process.';

  @override
  String get repairConfirmAction => 'Start repair';

  @override
  String get launchRetryTitle => 'Game didn\'t start';

  @override
  String get launchRetryMessage =>
      'Stellar Blade didn\'t start after two attempts. This is usually caused by UE4SS or CNS. \"Fix game not starting\" temporarily uninstalls them, launches the game once and reinstalls them. Run it now?';

  @override
  String get launchRetryAction => 'Fix now';

  @override
  String get repairOverlayTitle => 'Fixing game startup';

  @override
  String get repairOverlayWarning =>
      'Don\'t close the app or the game manually while this runs.';

  @override
  String get repairStepCloseGame => 'Closing the game if it\'s running';

  @override
  String get repairStepStashCns => 'Uninstalling CNS (saving its files)';

  @override
  String get repairStepStashUe4ss => 'Uninstalling UE4SS (saving its files)';

  @override
  String get repairStepLaunchClean => 'Starting the game without UE4SS and CNS';

  @override
  String get repairStepWaitInit => 'Letting the game load';

  @override
  String get repairStepCloseAuto => 'Closing the game automatically';

  @override
  String get repairStepRestoreUe4ss => 'Reinstalling UE4SS';

  @override
  String get repairStepRestoreCns => 'Reinstalling CNS';

  @override
  String get repairStepLaunchFinal => 'Launching the game';

  @override
  String get repairStatusSkipped => 'skipped';

  @override
  String get repairResultSuccess =>
      'Repair completed. The game has been launched.';

  @override
  String get repairResultErrorRestored =>
      'The repair failed, but UE4SS and CNS were put back as they were.';

  @override
  String get repairResultErrorRestoreFailed =>
      'The repair failed and the files could not be restored yet. They will be restored automatically the next time the app starts.';

  @override
  String get repairErrorGameNotStarted => 'The game did not start in time.';

  @override
  String get repairButtonClose => 'Close';

  @override
  String get repairRecoveredNotice =>
      'An interrupted repair was detected: UE4SS and CNS files were restored.';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return 'New edition installed: $name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return 'This mod now has $count editions installed.';
  }

  @override
  String get previewTagNewEdition => 'new edition';

  @override
  String get previewTagUpdate => 'update';

  @override
  String editionsInstalledTooltip(Object count) {
    return '$count editions of this mod installed';
  }

  @override
  String editionLabelValue(Object edition) {
    return 'Edition: $edition';
  }

  @override
  String get otherEditionsTitle => 'Other installed editions';

  @override
  String get detailsStatusEnabled => 'Enabled';

  @override
  String get detailsStatusDisabled => 'Disabled';

  @override
  String get detailsInformation => 'Information';

  @override
  String get detailsRowAuthor => 'Author';

  @override
  String get detailsRowType => 'Type';

  @override
  String get detailsRowInstalled => 'Installed';

  @override
  String get detailsRowModified => 'Last modified';

  @override
  String get detailsRowNexusId => 'Nexus ID';

  @override
  String get detailsRowFolder => 'Folder';

  @override
  String get detailsCopyPath => 'Copy path';

  @override
  String get detailsCopied => 'Copied to clipboard';

  @override
  String get detailsEndorse => 'Endorse';

  @override
  String get detailsEndorsed => 'Endorsed';

  @override
  String endorseWaitLabel(Object minutes) {
    return 'Wait $minutes min';
  }

  @override
  String get endorseSuccessTitle => 'Mod endorsed';

  @override
  String get endorseRemovedTitle => 'Endorsement removed';

  @override
  String get endorseFailedTitle => 'Couldn\'t update endorsement';

  @override
  String get endorseErrNotNexus =>
      'This mod isn\'t linked to a Nexus Mods page, so it can\'t be endorsed.';

  @override
  String get endorseErrNoApiKey =>
      'Add your Nexus Mods API key in Settings to endorse mods.';

  @override
  String endorseErrWait(Object minutes) {
    return 'Nexus requires waiting 15 minutes after downloading a mod before you can endorse it. Try again in $minutes min.';
  }

  @override
  String get endorseErrNotDownloaded =>
      'Nexus only lets you endorse mods you\'ve downloaded with your account.';

  @override
  String get endorseErrOwnMod => 'You can\'t endorse your own mod.';

  @override
  String get endorseErrRateLimit =>
      'You\'ve reached the Nexus request limit. Try again later.';

  @override
  String get endorseErrInvalidKey =>
      'Nexus rejected your API key. Check it in Settings.';

  @override
  String get endorseErrNetwork =>
      'Couldn\'t reach Nexus Mods. Check your connection and try again.';

  @override
  String get endorseErrUnknown =>
      'Nexus couldn\'t process the request. Try again later.';

  @override
  String get endorseRemoveConfirmTitle => 'Remove endorsement?';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return '$name will no longer be endorsed on Nexus Mods.';
  }

  @override
  String get endorseRemoveConfirmAction => 'Remove';

  @override
  String get detailsUpdateAction => 'Update';

  @override
  String get detailsShowMore => 'Show more';

  @override
  String get detailsShowLess => 'Show less';

  @override
  String get detailsAddNote => 'Add a note';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits',
      one: '1 outfit',
      zero: 'No outfits',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get outfitsChoose => 'Choose outfits';

  @override
  String get outfitsDone => 'Done';

  @override
  String get outfitsFilterAll => 'All';

  @override
  String get outfitsFilterSelected => 'Selected';

  @override
  String get outfitsClearAll => 'Clear all';

  @override
  String get outfitsRemove => 'Remove';

  @override
  String get outfitsActionSelect => 'Select';

  @override
  String get outfitsActionDeselect => 'Deselect';

  @override
  String outfitsNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get outfitsSelectedEmpty => 'No outfits selected yet.';

  @override
  String get outfitsNoPreview => 'No preview available';

  @override
  String get replacementOffConfirmTitle => 'Turn off replacement mod?';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The $count selected outfits will be removed from this mod.',
      one: 'The selected outfit will be removed from this mod.',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => 'Turn off';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count mods disabled: they replace outfits already used by other mods',
      one: '1 mod disabled: it replaces an outfit already used by another mod',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  Same Container ID as: $owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved => '  Originals kept as .cnsbak (restorable).';

  @override
  String patcherLeftUntouched(String reason) {
    return '  Left untouched (not safe to patch): $reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ $count mod(s) share a Container ID but could not be fixed safely (left untouched; they may not appear in CNS):';
  }

  @override
  String get revertPatchesTitle => 'Revert conflict patches';

  @override
  String get revertPatchesDesc =>
      'Restores the original mod files changed by the Conflict Patcher.';

  @override
  String get revertPatchesConfirmTitle => 'Revert conflict patches?';

  @override
  String get revertPatchesConfirmMessage =>
      'The original files saved by the Conflict Patcher (.cnsbak) will be restored. Close the game first. Conflicting mods may stop showing up in CNS again.';

  @override
  String get revertPatchesAction => 'Revert';

  @override
  String revertPatchesDone(int count) {
    return 'Restored $count file(s).';
  }

  @override
  String get revertPatchesNothing => 'No patched files to revert.';

  @override
  String get settingsGroupPaths => 'Paths';

  @override
  String get settingsGroupTools => 'Tools';

  @override
  String get settingsAutoOutfit => 'Assign outfits automatically';

  @override
  String get settingsAutoOutfitDesc =>
      'When installing a replacement mod, detect which outfit it replaces by reading its files. If turned off, the outfit is assigned manually.';

  @override
  String get variantChoiceTitle => 'Several variants of the same replacement';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return '\"$mod\" contains several variants that replace $outfits. Only one can be active at a time. Which one do you want to install?';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return '\"$mod\" contains several variants that replace the same files. Only one can be active at a time. Which one do you want to install?';
  }

  @override
  String get variantChoiceInstallAll => 'Install all (as separate mods)';

  @override
  String get installOutfitConflictTitle => 'Outfit already in use';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return 'The mod \"$newMod\" replaces the outfit $outfits, which is already assigned to the active mod \"$oldMod\". Only one can be active at a time. Which one do you want to keep active?';
  }

  @override
  String get installOutfitKeepCurrent => 'Keep current';

  @override
  String get installOutfitUseNew => 'Use new mod';

  @override
  String installOutfitNowActive(String active) {
    return 'Now active: $active';
  }

  @override
  String get fileLockErrorTitle => 'Could not move the mod';

  @override
  String get fileLockErrorMessage =>
      'Another application may be using the game files (FModel, the game itself, an antivirus, File Explorer...). Close it and try again.';

  @override
  String get nexusProfileTooltip => 'Nexus Mods profile';

  @override
  String get nexusUserFallback => 'User';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => 'Member';

  @override
  String get nexusPlanSupporter => 'Supporter';

  @override
  String get nexusApiRequestsRemaining => 'REMAINING API REQUESTS';

  @override
  String get nexusApiDaily => 'Daily';

  @override
  String get nexusApiHourly => 'Hourly';

  @override
  String get downloadMemberAccountLimit =>
      'Member accounts are limited to 1.5 MB/s by Nexus Mods';

  @override
  String get downloadSupporterAccountLimit =>
      'Supporter accounts are limited to 3 MB/s by Nexus Mods';

  @override
  String get downloadRetryTooltip => 'Retry';

  @override
  String get downloadRefreshingLink => 'Refreshing link...';

  @override
  String get downloadNoInternet =>
      'No internet connection. Check your network.';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'The Nexus link has expired ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'HTTP error: $code';
  }

  @override
  String get downloadErrorTimeout => 'Timeout: no network data received';

  @override
  String get splashRootFolder => 'Root (Main)';

  @override
  String get repairErrorGameNotClosed =>
      'The game process could not be closed.';

  @override
  String get errorManifestNotFound =>
      'Installation manifest not found. Cannot uninstall.';

  @override
  String get downloadResuming => 'Resuming...';

  @override
  String get apiKeyPromptTitle => 'Set up your Nexus Mods API key';

  @override
  String get apiKeyPromptMessage =>
      'No API key was detected. Setting it up is optional, but recommended for convenience: it lets you check for mod updates, download with one click (nxm://) and load covers and info from Nexus Mods.';

  @override
  String get apiKeyPromptConfigure => 'Set up API key';

  @override
  String get apiKeyPromptSkip => 'Skip';

  @override
  String get apiKeyPromptDontShowAgain => 'Don\'t show this message again';

  @override
  String get adjustCoverTooltip => 'Adjust cover';

  @override
  String get noCoverToAdjust => 'This mod has no cover to adjust';

  @override
  String errorAdjustingCoverText(Object error) {
    return 'Error adjusting the cover: $error';
  }
}
