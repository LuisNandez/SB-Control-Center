import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CNS Control Center'**
  String get appTitle;

  /// No description provided for @appTitleWithVersion.
  ///
  /// In en, this message translates to:
  /// **'Custom Nanosuit System {version}'**
  String appTitleWithVersion(Object version);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the application language'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Information about the application'**
  String get settingsAboutDesc;

  /// No description provided for @settingsRefreshMetadata.
  ///
  /// In en, this message translates to:
  /// **'Update metadata'**
  String get settingsRefreshMetadata;

  /// No description provided for @settingsRefreshMetadataDesc.
  ///
  /// In en, this message translates to:
  /// **'Checks your mods again on Nexus Mods and completes missing details and images'**
  String get settingsRefreshMetadataDesc;

  /// No description provided for @metadataRefreshDone.
  ///
  /// In en, this message translates to:
  /// **'Metadata updated'**
  String get metadataRefreshDone;

  /// No description provided for @metadataRefreshNoApiKey.
  ///
  /// In en, this message translates to:
  /// **'Add your Nexus Mods API key in Settings to update metadata.'**
  String get metadataRefreshNoApiKey;

  /// No description provided for @settingsPathsAndTools.
  ///
  /// In en, this message translates to:
  /// **'Paths & Tools'**
  String get settingsPathsAndTools;

  /// No description provided for @settingsGameFolder.
  ///
  /// In en, this message translates to:
  /// **'Game Folder'**
  String get settingsGameFolder;

  /// No description provided for @settingsGameFolderDesc.
  ///
  /// In en, this message translates to:
  /// **'The root folder of your Stellar Blade installation.'**
  String get settingsGameFolderDesc;

  /// No description provided for @settings7zipPath.
  ///
  /// In en, this message translates to:
  /// **'7-Zip Path'**
  String get settings7zipPath;

  /// No description provided for @settings7zipPathDesc.
  ///
  /// In en, this message translates to:
  /// **'The location of the 7z.exe file for extracting mods.'**
  String get settings7zipPathDesc;

  /// No description provided for @settings7zipPathAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic search'**
  String get settings7zipPathAuto;

  /// No description provided for @settingsRepairMods.
  ///
  /// In en, this message translates to:
  /// **'Repair Legacy Mods'**
  String get settingsRepairMods;

  /// No description provided for @settingsRepairModsDesc.
  ///
  /// In en, this message translates to:
  /// **'Scans and creates info files for old mods using the local database. Requires API key.'**
  String get settingsRepairModsDesc;

  /// No description provided for @settingsConnectivity.
  ///
  /// In en, this message translates to:
  /// **'Connectivity & Updates'**
  String get settingsConnectivity;

  /// No description provided for @settingsApiKey.
  ///
  /// In en, this message translates to:
  /// **'Nexus Mods API Key'**
  String get settingsApiKey;

  /// No description provided for @settingsApiKeyDesc.
  ///
  /// In en, this message translates to:
  /// **'Required for checking mod updates.'**
  String get settingsApiKeyDesc;

  /// No description provided for @settingsApiKeySet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get settingsApiKeySet;

  /// No description provided for @settingsApiKeyNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsApiKeyNotSet;

  /// No description provided for @settingsSkippedVersions.
  ///
  /// In en, this message translates to:
  /// **'Manage Skipped Versions'**
  String get settingsSkippedVersions;

  /// No description provided for @settingsSkippedVersionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage mod versions you have chosen to skip.'**
  String get settingsSkippedVersionsDesc;

  /// No description provided for @settingsSkippedVersionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} versions skipped'**
  String settingsSkippedVersionsCount(Object count);

  /// No description provided for @dialogTitleSkippedVersions.
  ///
  /// In en, this message translates to:
  /// **'Skipped Mod Versions'**
  String get dialogTitleSkippedVersions;

  /// No description provided for @dialogNoSkippedVersions.
  ///
  /// In en, this message translates to:
  /// **'You have not skipped any mod versions.'**
  String get dialogNoSkippedVersions;

  /// No description provided for @dialogSkippedVersions.
  ///
  /// In en, this message translates to:
  /// **'Skipped Version'**
  String get dialogSkippedVersions;

  /// No description provided for @dialogTitleRepairMods.
  ///
  /// In en, this message translates to:
  /// **'Run Legacy Mod Repair?'**
  String get dialogTitleRepairMods;

  /// No description provided for @dialogContentRepairMods.
  ///
  /// In en, this message translates to:
  /// **'Warning: This feature is in development and may not be perfect.\n\nIt will scan mods without a \'nexus_info.json\' file and, if found in your local database, create one for them. It will also attempt to rename the mod\'s folder to include the found version (e.g., \'My Mod\' -> \'My Mod v1.2\').\n\nVersion Priority:\n1. From the folder name.\n2. From the mod\'s description field.\n3. From the latest version on Nexus Mods (requires API).\n\nDo you want to continue?'**
  String get dialogContentRepairMods;

  /// No description provided for @dialogActionRunRepair.
  ///
  /// In en, this message translates to:
  /// **'Run Repair'**
  String get dialogActionRunRepair;

  /// No description provided for @snackBarGamePathInvalid.
  ///
  /// In en, this message translates to:
  /// **'The selected folder does not appear to be a valid game folder.'**
  String get snackBarGamePathInvalid;

  /// No description provided for @snackBar7zipPathInvalid.
  ///
  /// In en, this message translates to:
  /// **'The selected file must be named 7z.exe.'**
  String get snackBar7zipPathInvalid;

  /// No description provided for @snackBarRepairStarted.
  ///
  /// In en, this message translates to:
  /// **'Legacy mod repair process has started...'**
  String get snackBarRepairStarted;

  /// No description provided for @snackBarRepairComplete.
  ///
  /// In en, this message translates to:
  /// **'Repair complete. {count} mod(s) were updated.'**
  String snackBarRepairComplete(Object count);

  /// No description provided for @snackBarRepairNoMods.
  ///
  /// In en, this message translates to:
  /// **'No legacy mods were found that needed repairing.'**
  String get snackBarRepairNoMods;

  /// No description provided for @errorApiRequiredForRepair.
  ///
  /// In en, this message translates to:
  /// **'API Key is required to find the latest version for mods without a local version.'**
  String get errorApiRequiredForRepair;

  /// No description provided for @installNewMod.
  ///
  /// In en, this message translates to:
  /// **'Install Mod'**
  String get installNewMod;

  /// No description provided for @selectFiles.
  ///
  /// In en, this message translates to:
  /// **'Select Files'**
  String get selectFiles;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Folder'**
  String get selectFolder;

  /// No description provided for @installSelectedMod.
  ///
  /// In en, this message translates to:
  /// **'Install Selected Mod'**
  String get installSelectedMod;

  /// No description provided for @filesToInstall.
  ///
  /// In en, this message translates to:
  /// **'Files to Install:'**
  String get filesToInstall;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel Selection'**
  String get cancelSelection;

  /// No description provided for @searchMods.
  ///
  /// In en, this message translates to:
  /// **'Search mods...'**
  String get searchMods;

  /// No description provided for @enabledMods.
  ///
  /// In en, this message translates to:
  /// **'Enabled Mods'**
  String get enabledMods;

  /// No description provided for @disabledMods.
  ///
  /// In en, this message translates to:
  /// **'Disabled Mods'**
  String get disabledMods;

  /// No description provided for @refreshList.
  ///
  /// In en, this message translates to:
  /// **'Refresh list'**
  String get refreshList;

  /// No description provided for @noEnabledMods.
  ///
  /// In en, this message translates to:
  /// **'No enabled mods.'**
  String get noEnabledMods;

  /// No description provided for @noDisabledMods.
  ///
  /// In en, this message translates to:
  /// **'No disabled mods.'**
  String get noDisabledMods;

  /// No description provided for @showInFolder.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get showInFolder;

  /// No description provided for @disableMod.
  ///
  /// In en, this message translates to:
  /// **'Disable mod'**
  String get disableMod;

  /// No description provided for @enableMod.
  ///
  /// In en, this message translates to:
  /// **'Enable mod'**
  String get enableMod;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get selectLanguage;

  /// No description provided for @statusSearchingGame.
  ///
  /// In en, this message translates to:
  /// **'Searching for Stellar Blade installation...'**
  String get statusSearchingGame;

  /// No description provided for @statusGamePathFound.
  ///
  /// In en, this message translates to:
  /// **'Game path found!'**
  String get statusGamePathFound;

  /// No description provided for @statusGamePathNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find the game path automatically.'**
  String get statusGamePathNotFound;

  /// No description provided for @statusErrorFindingGame.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while searching for the game: {error}'**
  String statusErrorFindingGame(Object error);

  /// No description provided for @statusModsFound.
  ///
  /// In en, this message translates to:
  /// **'{enabledCount} mod(s) enabled, {disabledCount} disabled.'**
  String statusModsFound(Object disabledCount, Object enabledCount);

  /// No description provided for @statusErrorReadingMods.
  ///
  /// In en, this message translates to:
  /// **'Error reading installed mods: {error}'**
  String statusErrorReadingMods(Object error);

  /// No description provided for @statusFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) selected. Ready to install.'**
  String statusFilesSelected(Object count);

  /// No description provided for @statusFolderSelected.
  ///
  /// In en, this message translates to:
  /// **'Folder \"{folderName}\" selected. Ready to install.'**
  String statusFolderSelected(Object folderName);

  /// No description provided for @statusArchiveLoaded.
  ///
  /// In en, this message translates to:
  /// **'File \"{fileName}\" loaded. {count} file(s) ready to install.'**
  String statusArchiveLoaded(Object count, Object fileName);

  /// No description provided for @statusSelectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Selection cancelled. Choose a new mod to install.'**
  String get statusSelectionCancelled;

  /// No description provided for @statusUpdateComplete.
  ///
  /// In en, this message translates to:
  /// **'Update complete.'**
  String get statusUpdateComplete;

  /// No description provided for @statusInstallationComplete.
  ///
  /// In en, this message translates to:
  /// **'Installation complete.'**
  String get statusInstallationComplete;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String statusError(Object error);

  /// No description provided for @dialogTitle7zip.
  ///
  /// In en, this message translates to:
  /// **'7-Zip is Required'**
  String get dialogTitle7zip;

  /// No description provided for @dialogContent7zip.
  ///
  /// In en, this message translates to:
  /// **'To decompress this file, the application needs 7-Zip.\n\nPlease install it from its official page and then press \"Confirm\".'**
  String get dialogContent7zip;

  /// No description provided for @dialogContent7zipNotFound.
  ///
  /// In en, this message translates to:
  /// **'7-Zip has not been detected yet. Please make sure it is installed in the default path and try again.'**
  String get dialogContent7zipNotFound;

  /// No description provided for @dialogTitleMultipleJsons.
  ///
  /// In en, this message translates to:
  /// **'Multiple .json Files Detected'**
  String get dialogTitleMultipleJsons;

  /// No description provided for @dialogContentMultipleJsons.
  ///
  /// In en, this message translates to:
  /// **'{count} .json files have been detected. This could be a mod with multiple components.\n\nDo you want to install them all together in a single mod folder?'**
  String dialogContentMultipleJsons(Object count);

  /// No description provided for @dialogTitleModExists.
  ///
  /// In en, this message translates to:
  /// **'Mod Already Exists'**
  String get dialogTitleModExists;

  /// No description provided for @dialogContentModExists.
  ///
  /// In en, this message translates to:
  /// **'A mod named \"{modName}\" is already installed.\n\nDo you want to update it? Old files will be deleted before installing the new ones.'**
  String dialogContentModExists(Object modName);

  /// No description provided for @dialogContentModUpdate.
  ///
  /// In en, this message translates to:
  /// **'An older version \'{oldModName}\' was found.\n\nDo you want to remove it and update to \'{newModName}\'?'**
  String dialogContentModUpdate(Object newModName, Object oldModName);

  /// No description provided for @dialogTitleDeleteMod.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently?'**
  String get dialogTitleDeleteMod;

  /// No description provided for @dialogContentDeleteMod.
  ///
  /// In en, this message translates to:
  /// **'You are about to permanently delete the mod \"{modName}\". This action cannot be undone.\n\nAre you sure?'**
  String dialogContentDeleteMod(Object modName);

  /// Text for the cancel action button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogActionCancel;

  /// No description provided for @dialogActionGoToDownload.
  ///
  /// In en, this message translates to:
  /// **'Go to Download Page'**
  String get dialogActionGoToDownload;

  /// No description provided for @dialogActionConfirmInstallation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Installation'**
  String get dialogActionConfirmInstallation;

  /// No description provided for @dialogActionUpdateSystem.
  ///
  /// In en, this message translates to:
  /// **'Update System'**
  String get dialogActionUpdateSystem;

  /// No description provided for @dialogActionInstallAnyway.
  ///
  /// In en, this message translates to:
  /// **'Install Anyway'**
  String get dialogActionInstallAnyway;

  /// No description provided for @dialogActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogActionDelete;

  /// No description provided for @dialogActionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogActionClose;

  /// No description provided for @snackBarBatchInstallComplete.
  ///
  /// In en, this message translates to:
  /// **'Batch installation complete. Success: {successCount}, Failed: {failedCount}.'**
  String snackBarBatchInstallComplete(Object failedCount, Object successCount);

  /// No description provided for @snackBarModInstalled.
  ///
  /// In en, this message translates to:
  /// **'Mod \"{modName}\" installed successfully.'**
  String snackBarModInstalled(Object modName);

  /// No description provided for @snackBarModEnabled.
  ///
  /// In en, this message translates to:
  /// **'Mod \"{modName}\" enabled.'**
  String snackBarModEnabled(Object modName);

  /// No description provided for @snackBarModDisabled.
  ///
  /// In en, this message translates to:
  /// **'Mod \"{modName}\" disabled.'**
  String snackBarModDisabled(Object modName);

  /// No description provided for @snackBarModDeleted.
  ///
  /// In en, this message translates to:
  /// **'Mod \"{modName}\" permanently deleted.'**
  String snackBarModDeleted(Object modName);

  /// No description provided for @snackBarCNSUpdated.
  ///
  /// In en, this message translates to:
  /// **'Custom Nanosuit System updated successfully.'**
  String get snackBarCNSUpdated;

  /// No description provided for @snackBarApiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API Key saved successfully.'**
  String get snackBarApiKeySaved;

  /// No description provided for @snackBarGamePathSaved.
  ///
  /// In en, this message translates to:
  /// **'Game path saved successfully.'**
  String get snackBarGamePathSaved;

  /// No description provided for @snackBar7zipPathSaved.
  ///
  /// In en, this message translates to:
  /// **'7-Zip path saved successfully.'**
  String get snackBar7zipPathSaved;

  /// No description provided for @snackBarSkippedVersionRemoved.
  ///
  /// In en, this message translates to:
  /// **'Skipped version removed.'**
  String get snackBarSkippedVersionRemoved;

  /// No description provided for @dropTargetOverlay.
  ///
  /// In en, this message translates to:
  /// **'Drop mods here'**
  String get dropTargetOverlay;

  /// No description provided for @pathSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stellar Blade Path Not Found'**
  String get pathSelectionTitle;

  /// No description provided for @pathSelectionButtonManual.
  ///
  /// In en, this message translates to:
  /// **'Select Game Folder Manually'**
  String get pathSelectionButtonManual;

  /// No description provided for @pathSelectionButtonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get pathSelectionButtonRetry;

  /// No description provided for @errorFolderSelection.
  ///
  /// In en, this message translates to:
  /// **'Error selecting folder: {error}'**
  String errorFolderSelection(Object error);

  /// No description provided for @errorFileSelection.
  ///
  /// In en, this message translates to:
  /// **'Error selecting files: {error}'**
  String errorFileSelection(Object error);

  /// No description provided for @errorDecompressing.
  ///
  /// In en, this message translates to:
  /// **'Error decompressing file: {error}'**
  String errorDecompressing(Object error);

  /// No description provided for @errorProcessingArchive.
  ///
  /// In en, this message translates to:
  /// **'Error processing file: {error}'**
  String errorProcessingArchive(Object error);

  /// No description provided for @errorUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format: {extension}'**
  String errorUnsupportedFormat(Object extension);

  /// No description provided for @error7zipRequired.
  ///
  /// In en, this message translates to:
  /// **'Operation cancelled: 7-Zip is required.'**
  String get error7zipRequired;

  /// No description provided for @errorGamePathUndefined.
  ///
  /// In en, this message translates to:
  /// **'Game path is not defined.'**
  String get errorGamePathUndefined;

  /// No description provided for @errorDestinationNotFound.
  ///
  /// In en, this message translates to:
  /// **'The game\'s destination folder does not exist.'**
  String get errorDestinationNotFound;

  /// No description provided for @errorUpdateSystem.
  ///
  /// In en, this message translates to:
  /// **'Error updating system: {error}'**
  String errorUpdateSystem(Object error);

  /// No description provided for @errorInstallNoSelection.
  ///
  /// In en, this message translates to:
  /// **'You have not selected anything to install.'**
  String get errorInstallNoSelection;

  /// No description provided for @errorInstallModExists.
  ///
  /// In en, this message translates to:
  /// **'Installation cancelled: Mod already exists.'**
  String get errorInstallModExists;

  /// No description provided for @errorNoJsonFound.
  ///
  /// In en, this message translates to:
  /// **'Each mod must contain at least one .json file.'**
  String get errorNoJsonFound;

  /// No description provided for @errorInvalidJsonFormat.
  ///
  /// In en, this message translates to:
  /// **'The file {fileName} has an invalid JSON format.'**
  String errorInvalidJsonFormat(Object fileName);

  /// No description provided for @errorNoDisplayName.
  ///
  /// In en, this message translates to:
  /// **'The file {fileName} does not appear to be a Custom Nanosuit System mod (missing \"DisplayName\").'**
  String errorNoDisplayName(Object fileName);

  /// No description provided for @errorNoValidDisplayName.
  ///
  /// In en, this message translates to:
  /// **'No valid \"DisplayName\" was found in the .json files.'**
  String get errorNoValidDisplayName;

  /// No description provided for @errorEnableMod.
  ///
  /// In en, this message translates to:
  /// **'Error enabling mod: {error}'**
  String errorEnableMod(Object error);

  /// No description provided for @errorDisableMod.
  ///
  /// In en, this message translates to:
  /// **'Error disabling mod: {error}'**
  String errorDisableMod(Object error);

  /// No description provided for @errorDeleteMod.
  ///
  /// In en, this message translates to:
  /// **'Error deleting mod: {error}'**
  String errorDeleteMod(Object error);

  /// No description provided for @errorOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Could not open folder: {path}'**
  String errorOpenFolder(Object path);

  /// No description provided for @statusUpdateSystemCancelled.
  ///
  /// In en, this message translates to:
  /// **'System update cancelled.'**
  String get statusUpdateSystemCancelled;

  /// No description provided for @statusUpdatingCNS.
  ///
  /// In en, this message translates to:
  /// **'Updating Custom Nanosuit System...'**
  String get statusUpdatingCNS;

  /// No description provided for @statusExtractingFile.
  ///
  /// In en, this message translates to:
  /// **'Extracting {fileName}...'**
  String statusExtractingFile(Object fileName);

  /// No description provided for @statusInstallationCancelledByUser.
  ///
  /// In en, this message translates to:
  /// **'Installation cancelled by user.'**
  String get statusInstallationCancelledByUser;

  /// No description provided for @errorNoCompatibleFilesInFolder.
  ///
  /// In en, this message translates to:
  /// **'The selected folder does not contain compatible mod files.'**
  String get errorNoCompatibleFilesInFolder;

  /// No description provided for @errorNoCompatibleFilesInArchive.
  ///
  /// In en, this message translates to:
  /// **'The compressed file does not contain compatible mod files.'**
  String get errorNoCompatibleFilesInArchive;

  /// No description provided for @errorNoJsonInSelection.
  ///
  /// In en, this message translates to:
  /// **'The selection does not contain a valid mod .json file.'**
  String get errorNoJsonInSelection;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About SB Control Center'**
  String get aboutTitle;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'SB Control Center is a mod manager for Stellar Blade. It installs, organizes, and updates your mods in one place, and works with the Custom Nanosuit System (CNS) for outfit and nanosuit mods.\n\nIt connects to Nexus Mods to download, check for updates, and endorse the mods you use.\n\nIncludes 7-Zip (7-zip.org) to extract .zip, .rar and .7z archives.'**
  String get aboutContent;

  /// No description provided for @aboutEndorseCta.
  ///
  /// In en, this message translates to:
  /// **'Enjoying the app? An Endorse on Nexus Mods helps a lot.'**
  String get aboutEndorseCta;

  /// No description provided for @aboutEndorseThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get aboutEndorseThanks;

  /// No description provided for @aboutLinkText.
  ///
  /// In en, this message translates to:
  /// **'Visit my creator profile'**
  String get aboutLinkText;

  /// No description provided for @creatorProfileUrl.
  ///
  /// In en, this message translates to:
  /// **'https://next.nexusmods.com/profile/LuisNandez?gameId=7804'**
  String get creatorProfileUrl;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String aboutVersion(Object version);

  /// No description provided for @openModsFolder.
  ///
  /// In en, this message translates to:
  /// **'Open Mods Folder'**
  String get openModsFolder;

  /// No description provided for @openInNexusMods.
  ///
  /// In en, this message translates to:
  /// **'Open in Nexus Mods'**
  String get openInNexusMods;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available: v{version}'**
  String updateAvailable(Object version);

  /// No description provided for @dialogTitleApiKey.
  ///
  /// In en, this message translates to:
  /// **'Nexus Mods API Key'**
  String get dialogTitleApiKey;

  /// No description provided for @dialogContentApiKey.
  ///
  /// In en, this message translates to:
  /// **'To check for mod updates, you need a personal API key from Nexus Mods.'**
  String get dialogContentApiKey;

  /// No description provided for @dialogContentApiKeyInstructions.
  ///
  /// In en, this message translates to:
  /// **'1. Click the button below to open Nexus Mods and log in.\n2. Scroll to the bottom of the page, to the \'Personal API Key\' section.\n3. Request it if you don\'t have one yet, then copy it.\n4. Paste it here.'**
  String get dialogContentApiKeyInstructions;

  /// No description provided for @apiKeyOpenNexusPage.
  ///
  /// In en, this message translates to:
  /// **'Open API Keys Page'**
  String get apiKeyOpenNexusPage;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @apiKeyHintText.
  ///
  /// In en, this message translates to:
  /// **'Paste your API key here'**
  String get apiKeyHintText;

  /// No description provided for @dialogActionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialogActionSave;

  /// No description provided for @apiKeyRemoved.
  ///
  /// In en, this message translates to:
  /// **'API Key removed.'**
  String get apiKeyRemoved;

  /// No description provided for @invalidApiKeyError.
  ///
  /// In en, this message translates to:
  /// **'Invalid API Key.'**
  String get invalidApiKeyError;

  /// No description provided for @validatingApiKey.
  ///
  /// In en, this message translates to:
  /// **'Validating...'**
  String get validatingApiKey;

  /// No description provided for @errorApiKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'Nexus Mods API Key is missing. Add it in Settings › Connectivity & Updates › Nexus Mods API Key.'**
  String get errorApiKeyMissing;

  /// No description provided for @statusCheckingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for mod updates...'**
  String get statusCheckingUpdates;

  /// No description provided for @statusUpdatesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} update(s) found!'**
  String statusUpdatesFound(Object count);

  /// No description provided for @statusNoUpdates.
  ///
  /// In en, this message translates to:
  /// **'All mods are up to date.'**
  String get statusNoUpdates;

  /// No description provided for @selectModArchive.
  ///
  /// In en, this message translates to:
  /// **'Select Mod Archive'**
  String get selectModArchive;

  /// No description provided for @viewImageGallery.
  ///
  /// In en, this message translates to:
  /// **'View Image'**
  String get viewImageGallery;

  /// No description provided for @imageGallery.
  ///
  /// In en, this message translates to:
  /// **'Image Gallery'**
  String get imageGallery;

  /// No description provided for @noImagesFound.
  ///
  /// In en, this message translates to:
  /// **'No images were found for this mod, or the API key has not been entered. Please enter the API key and check for updates afterward.'**
  String get noImagesFound;

  /// No description provided for @errorFetchingImages.
  ///
  /// In en, this message translates to:
  /// **'Error fetching images: {error}'**
  String errorFetchingImages(Object error);

  /// No description provided for @imageMod.
  ///
  /// In en, this message translates to:
  /// **'Mod Image'**
  String get imageMod;

  /// No description provided for @modEnabledBadge.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get modEnabledBadge;

  /// No description provided for @modDisabledBadge.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get modDisabledBadge;

  /// No description provided for @modCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get modCategoryOther;

  /// No description provided for @dialogContentUpdateOptions.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get dialogContentUpdateOptions;

  /// No description provided for @dialogActionIgnoreVersion.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get dialogActionIgnoreVersion;

  /// No description provided for @dialogActionSkipVersion.
  ///
  /// In en, this message translates to:
  /// **'Skip Version'**
  String get dialogActionSkipVersion;

  /// No description provided for @dialogActionGoToDownloadPage.
  ///
  /// In en, this message translates to:
  /// **'Go to Download'**
  String get dialogActionGoToDownloadPage;

  /// No description provided for @installedMods.
  ///
  /// In en, this message translates to:
  /// **'Installed Mods'**
  String get installedMods;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter:'**
  String get filterBy;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get sortBy;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get filterEnabled;

  /// No description provided for @filterDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get filterDisabled;

  /// No description provided for @filterRepaired.
  ///
  /// In en, this message translates to:
  /// **'Repaired'**
  String get filterRepaired;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sortByDate;

  /// No description provided for @noModsFound.
  ///
  /// In en, this message translates to:
  /// **'No mods found.'**
  String get noModsFound;

  /// No description provided for @viewTypeGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get viewTypeGrid;

  /// No description provided for @viewTypeList.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get viewTypeList;

  /// No description provided for @statusExtractingMultipleFiles.
  ///
  /// In en, this message translates to:
  /// **'Extracting {count} of {total}: {fileName}'**
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  );

  /// No description provided for @previewInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Mods to be Installed:'**
  String get previewInstallTitle;

  /// No description provided for @dialogTitleUE4SS.
  ///
  /// In en, this message translates to:
  /// **'UE4SS Installation Detected'**
  String get dialogTitleUE4SS;

  /// No description provided for @dialogContentUE4SS.
  ///
  /// In en, this message translates to:
  /// **'The UE4SS tool has been detected. Do you want to install it to \'StellarBlade\\SB\\Binaries\\Win64\'?\n\nThis is required for many mods to work.'**
  String get dialogContentUE4SS;

  /// No description provided for @dialogActionInstallTool.
  ///
  /// In en, this message translates to:
  /// **'Install Tool'**
  String get dialogActionInstallTool;

  /// No description provided for @statusUE4SSInstallCancelled.
  ///
  /// In en, this message translates to:
  /// **'UE4SS installation cancelled.'**
  String get statusUE4SSInstallCancelled;

  /// No description provided for @statusInstallingUE4SS.
  ///
  /// In en, this message translates to:
  /// **'Installing UE4SS...'**
  String get statusInstallingUE4SS;

  /// No description provided for @snackBarUE4SSInstalled.
  ///
  /// In en, this message translates to:
  /// **'UE4SS installed successfully.'**
  String get snackBarUE4SSInstalled;

  /// No description provided for @error7zipDecompression.
  ///
  /// In en, this message translates to:
  /// **'7-Zip error during decompression: {error}'**
  String error7zipDecompression(Object error);

  /// No description provided for @statusUE4SSInstallComplete.
  ///
  /// In en, this message translates to:
  /// **'UE4SS installation complete.'**
  String get statusUE4SSInstallComplete;

  /// No description provided for @dialogTitleAlternativeVersion.
  ///
  /// In en, this message translates to:
  /// **'Alternative Version Detected'**
  String get dialogTitleAlternativeVersion;

  /// Content for the dialog when a different mod with the same nexus ID is detected.
  ///
  /// In en, this message translates to:
  /// **'An alternative version of this mod is already installed: \'{oldModName}\'.\n\nYou are about to install a different alternative named \'{newModName}\'.'**
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  );

  /// No description provided for @dialogActionReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get dialogActionReplace;

  /// No description provided for @dialogActionInstallAsNew.
  ///
  /// In en, this message translates to:
  /// **'Install as New'**
  String get dialogActionInstallAsNew;

  /// No description provided for @dialogTitleUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get dialogTitleUpdate;

  /// Content for the mod update confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'You are about to update the mod \'{modName}\'.\n\nInstalled version: {oldVersion}\nNew version: {newVersion}'**
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  );

  /// No description provided for @dialogTitleDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Older Version Detected'**
  String get dialogTitleDowngrade;

  /// Content for the mod downgrade warning dialog.
  ///
  /// In en, this message translates to:
  /// **'Warning: You are about to install an older version of the mod \'{modName}\'.\n\nInstalled version: {oldVersion}\nVersion to install: {newVersion}'**
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  );

  /// No description provided for @dialogTitleReinstall.
  ///
  /// In en, this message translates to:
  /// **'Reinstall Mod'**
  String get dialogTitleReinstall;

  /// No description provided for @dialogContentReinstall.
  ///
  /// In en, this message translates to:
  /// **'You are about to reinstall version \'{version}\' of the mod \'{modName}\'.'**
  String dialogContentReinstall(Object modName, Object version);

  /// No description provided for @dialogActionReinstall.
  ///
  /// In en, this message translates to:
  /// **'Reinstall'**
  String get dialogActionReinstall;

  /// No description provided for @editModNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit mod name'**
  String get editModNameTooltip;

  /// No description provided for @setCoverTooltip.
  ///
  /// In en, this message translates to:
  /// **'Set custom cover image'**
  String get setCoverTooltip;

  /// No description provided for @setCoverText.
  ///
  /// In en, this message translates to:
  /// **'Set Cover'**
  String get setCoverText;

  /// No description provided for @restoreOriginalCoverText.
  ///
  /// In en, this message translates to:
  /// **'Restore Original Cover'**
  String get restoreOriginalCoverText;

  /// No description provided for @errorSavingCoverText.
  ///
  /// In en, this message translates to:
  /// **'Error saving cover image: {error}'**
  String errorSavingCoverText(Object error);

  /// No description provided for @errorRestoringCoverText.
  ///
  /// In en, this message translates to:
  /// **'Error restoring original cover image: {error}'**
  String errorRestoringCoverText(Object error);

  /// No description provided for @editVersionText.
  ///
  /// In en, this message translates to:
  /// **'Edit Version'**
  String get editVersionText;

  /// No description provided for @customVersionText.
  ///
  /// In en, this message translates to:
  /// **'Custom Version'**
  String get customVersionText;

  /// No description provided for @editTagText.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get editTagText;

  /// No description provided for @customTagText.
  ///
  /// In en, this message translates to:
  /// **'Custom Tag'**
  String get customTagText;

  /// No description provided for @dialogTitleEditModName.
  ///
  /// In en, this message translates to:
  /// **'Edit Mod Name'**
  String get dialogTitleEditModName;

  /// No description provided for @dialogActionResetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get dialogActionResetToDefault;

  /// No description provided for @dialogLabelNewName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get dialogLabelNewName;

  /// No description provided for @errorModNameExists.
  ///
  /// In en, this message translates to:
  /// **'A mod named \"{modName}\" already exists.'**
  String errorModNameExists(Object modName);

  /// No description provided for @dialogTitleRepairedModWarning.
  ///
  /// In en, this message translates to:
  /// **'Repaired Mod Warning'**
  String get dialogTitleRepairedModWarning;

  /// No description provided for @dialogContentRepairedModWarning.
  ///
  /// In en, this message translates to:
  /// **'This mod might not have the correct version information. Reinstalling the latest version is recommended to ensure compatibility.'**
  String get dialogContentRepairedModWarning;

  /// No description provided for @repairedModTooltip.
  ///
  /// In en, this message translates to:
  /// **'Information about repaired mod'**
  String get repairedModTooltip;

  /// No description provided for @disableAllModsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Disable all mods'**
  String get disableAllModsTooltip;

  /// No description provided for @deleteAllModsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete all disabled mods'**
  String get deleteAllModsTooltip;

  /// No description provided for @dialogTitleDisableAll.
  ///
  /// In en, this message translates to:
  /// **'Disable All Mods?'**
  String get dialogTitleDisableAll;

  /// No description provided for @dialogContentDisableAll.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable all {count} enabled mods? They will be moved to the backup folder.'**
  String dialogContentDisableAll(int count);

  /// No description provided for @dialogTitleDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete Disabled Mods?'**
  String get dialogTitleDeleteAll;

  /// No description provided for @dialogContentDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'You are about to permanently delete all {count} disabled mods. This action cannot be undone.\n\nAre you sure?'**
  String dialogContentDeleteAll(int count);

  /// No description provided for @snackBarAllModsDisabled.
  ///
  /// In en, this message translates to:
  /// **'All {count} enabled mods have been disabled.'**
  String snackBarAllModsDisabled(int count);

  /// No description provided for @snackBarAllModsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All {count} disabled mods have been permanently deleted.'**
  String snackBarAllModsDeleted(int count);

  /// No description provided for @snackBarNoModsToDisable.
  ///
  /// In en, this message translates to:
  /// **'There are no enabled mods to disable.'**
  String get snackBarNoModsToDisable;

  /// No description provided for @snackBarNoModsToDelete.
  ///
  /// In en, this message translates to:
  /// **'There are no disabled mods to delete.'**
  String get snackBarNoModsToDelete;

  /// No description provided for @enableAllModsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Enable all mods'**
  String get enableAllModsTooltip;

  /// No description provided for @dialogTitleEnableAll.
  ///
  /// In en, this message translates to:
  /// **'Enable All Mods?'**
  String get dialogTitleEnableAll;

  /// No description provided for @dialogContentEnableAll.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to enable all {count} disabled mods? They will be moved to the main mods folder.'**
  String dialogContentEnableAll(int count);

  /// No description provided for @snackBarAllModsEnabled.
  ///
  /// In en, this message translates to:
  /// **'All {count} disabled mods have been enabled.'**
  String snackBarAllModsEnabled(int count);

  /// No description provided for @snackBarNoModsToEnable.
  ///
  /// In en, this message translates to:
  /// **'There are no disabled mods to enable.'**
  String get snackBarNoModsToEnable;

  /// No description provided for @editNotes.
  ///
  /// In en, this message translates to:
  /// **'Edit Notes'**
  String get editNotes;

  /// No description provided for @notesHintText.
  ///
  /// In en, this message translates to:
  /// **'Add your personal notes here...'**
  String get notesHintText;

  /// No description provided for @modAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get modAuthor;

  /// No description provided for @modSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get modSummary;

  /// No description provided for @modDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get modDescription;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @personalNotes.
  ///
  /// In en, this message translates to:
  /// **'Personal Notes'**
  String get personalNotes;

  /// No description provided for @noNotesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No notes added yet.'**
  String get noNotesAvailable;

  /// No description provided for @modDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mod Details'**
  String get modDetailsTitle;

  /// No description provided for @modVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get modVersion;

  /// No description provided for @modCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get modCategory;

  /// No description provided for @dialogTitleAddUrl.
  ///
  /// In en, this message translates to:
  /// **'Add Mod Link'**
  String get dialogTitleAddUrl;

  /// No description provided for @dialogLabelUrl.
  ///
  /// In en, this message translates to:
  /// **'Mod URL'**
  String get dialogLabelUrl;

  /// No description provided for @errorInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL.'**
  String get errorInvalidUrl;

  /// No description provided for @addLinkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a download link for this mod'**
  String get addLinkTooltip;

  /// No description provided for @addLinkButtonText.
  ///
  /// In en, this message translates to:
  /// **'Add Link'**
  String get addLinkButtonText;

  /// No description provided for @openLinkButtonText.
  ///
  /// In en, this message translates to:
  /// **'Open Link'**
  String get openLinkButtonText;

  /// No description provided for @editModTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Mod Details'**
  String get editModTitle;

  /// No description provided for @modNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Mod Name'**
  String get modNameLabel;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorLabel;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Description / Summary'**
  String get summaryLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal Notes'**
  String get notesLabel;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'Download URL'**
  String get urlLabel;

  /// No description provided for @changeCoverButton.
  ///
  /// In en, this message translates to:
  /// **'Change Cover Image'**
  String get changeCoverButton;

  /// No description provided for @editButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Mod'**
  String get editButtonTooltip;

  /// No description provided for @errorSavingNotes.
  ///
  /// In en, this message translates to:
  /// **'Error saving notes'**
  String get errorSavingNotes;

  /// No description provided for @errorSavingUrl.
  ///
  /// In en, this message translates to:
  /// **'Error saving URL'**
  String get errorSavingUrl;

  /// No description provided for @errorSavingChanges.
  ///
  /// In en, this message translates to:
  /// **'Error Saving Changes'**
  String get errorSavingChanges;

  /// No description provided for @errorTranslation.
  ///
  /// In en, this message translates to:
  /// **'Could not translate description'**
  String get errorTranslation;

  /// No description provided for @translateSummary.
  ///
  /// In en, this message translates to:
  /// **'Translate summary'**
  String get translateSummary;

  /// No description provided for @translateDescription.
  ///
  /// In en, this message translates to:
  /// **'Translate description'**
  String get translateDescription;

  /// No description provided for @restoreOriginalDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore original description'**
  String get restoreOriginalDescription;

  /// No description provided for @dialogTitleUE4SSReinstall.
  ///
  /// In en, this message translates to:
  /// **'Reinstall UE4SS'**
  String get dialogTitleUE4SSReinstall;

  /// No description provided for @dialogContentUE4SSReinstall.
  ///
  /// In en, this message translates to:
  /// **'UE4SS already seems to be installed. Do you want to overwrite the existing installation? This can be useful if you suspect corrupt files.'**
  String get dialogContentUE4SSReinstall;

  /// No description provided for @dialogTitleCNSReinstall.
  ///
  /// In en, this message translates to:
  /// **'Reinstall CNS System'**
  String get dialogTitleCNSReinstall;

  /// No description provided for @dialogContentCNSReinstall.
  ///
  /// In en, this message translates to:
  /// **'The main CNS system already seems to be installed. Do you want to reinstall it? Your existing mods will not be affected.'**
  String get dialogContentCNSReinstall;

  /// No description provided for @dialogTitleUninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall {componentName}'**
  String dialogTitleUninstall(Object componentName);

  /// No description provided for @dialogContentUninstall.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to uninstall {componentName}? This action will remove the core component files but will not affect your installed mods.'**
  String dialogContentUninstall(Object componentName);

  /// No description provided for @dialogActionUninstall.
  ///
  /// In en, this message translates to:
  /// **'Yes, uninstall'**
  String get dialogActionUninstall;

  /// No description provided for @statusUninstalling.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling {componentName}...'**
  String statusUninstalling(Object componentName);

  /// No description provided for @snackBarUninstalled.
  ///
  /// In en, this message translates to:
  /// **'{componentName} uninstalled successfully'**
  String snackBarUninstalled(Object componentName);

  /// No description provided for @errorUninstalling.
  ///
  /// In en, this message translates to:
  /// **'Error uninstalling {componentName}'**
  String errorUninstalling(Object componentName);

  /// No description provided for @settingsCoreComponents.
  ///
  /// In en, this message translates to:
  /// **'Core Components'**
  String get settingsCoreComponents;

  /// No description provided for @installedStatus.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installedStatus;

  /// No description provided for @notInstalledStatus.
  ///
  /// In en, this message translates to:
  /// **'Not detected'**
  String get notInstalledStatus;

  /// No description provided for @uninstallButton.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstallButton;

  /// No description provided for @cnsCoreSystem.
  ///
  /// In en, this message translates to:
  /// **'Custom Nanosuit System'**
  String get cnsCoreSystem;

  /// No description provided for @ue4ssInstallationDetected.
  ///
  /// In en, this message translates to:
  /// **'Existing UE4SS installation detected and adopted'**
  String get ue4ssInstallationDetected;

  /// No description provided for @cnsInstallationDetected.
  ///
  /// In en, this message translates to:
  /// **'Existing Main CNS installation detected and adopted'**
  String get cnsInstallationDetected;

  /// No description provided for @ue4ssRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'UE4SS Required'**
  String get ue4ssRequiredTitle;

  /// No description provided for @ue4ssRequiredContent.
  ///
  /// In en, this message translates to:
  /// **'To install the Main CNS System, you must first install UE4SS. You can download it from the following link:'**
  String get ue4ssRequiredContent;

  /// No description provided for @uninstallDependencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Dependency Detected'**
  String get uninstallDependencyTitle;

  /// No description provided for @uninstallDependencyContent.
  ///
  /// In en, this message translates to:
  /// **'You must uninstall the Main CNS System before you can uninstall UE4SS, as CNS depends on it.'**
  String get uninstallDependencyContent;

  /// No description provided for @dialogActionUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get dialogActionUnderstood;

  /// No description provided for @appTitleNoCns.
  ///
  /// In en, this message translates to:
  /// **'Custom Nanosuit System (Not Installed)'**
  String get appTitleNoCns;

  /// No description provided for @dialogTitleCNSUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Main CNS System'**
  String get dialogTitleCNSUpdate;

  /// No description provided for @dialogContentCNSUpdate.
  ///
  /// In en, this message translates to:
  /// **'You are about to update CNS from version {oldVersion} to the new version {newVersion}. Do you wish to continue?'**
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion);

  /// No description provided for @dialogTitleCNSDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Downgrade CNS Version'**
  String get dialogTitleCNSDowngrade;

  /// No description provided for @dialogContentCNSDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Warning! You are about to install an older version of CNS ({newVersion}) than your current one ({oldVersion}). This may cause issues. Are you sure?'**
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion);

  /// No description provided for @dialogContentCNSReinstallVersion.
  ///
  /// In en, this message translates to:
  /// **'You already have version {version} of CNS installed. Do you want to reinstall the files anyway?'**
  String dialogContentCNSReinstallVersion(Object version);

  /// No description provided for @dialogActionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get dialogActionUpdate;

  /// No description provided for @dialogActionDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Downgrade'**
  String get dialogActionDowngrade;

  /// No description provided for @dialogTitleCNSInstall.
  ///
  /// In en, this message translates to:
  /// **'Install Main CNS System'**
  String get dialogTitleCNSInstall;

  /// No description provided for @dialogContentCNSInstall.
  ///
  /// In en, this message translates to:
  /// **'You are about to install the base Custom Nanosuit System (CNS). This is required for CNS mods to work. Do you wish to continue?'**
  String get dialogContentCNSInstall;

  /// No description provided for @dialogActionInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get dialogActionInstall;

  /// No description provided for @settingsDeveloperOptions.
  ///
  /// In en, this message translates to:
  /// **'Developer Options'**
  String get settingsDeveloperOptions;

  /// No description provided for @devDeleteNexusInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All nexus_info.json Files'**
  String get devDeleteNexusInfoTitle;

  /// No description provided for @devDeleteNexusInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Removes all manager metadata files from every mod. This is useful for forcing a full repair.'**
  String get devDeleteNexusInfoDesc;

  /// No description provided for @devExtractIdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Extract Identifiers'**
  String get devExtractIdsTitle;

  /// No description provided for @devExtractIdsDesc.
  ///
  /// In en, this message translates to:
  /// **'Creates a file named \'ID Mods.json\' on your desktop containing the displayName and nexusId of each mod.'**
  String get devExtractIdsDesc;

  /// No description provided for @devConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get devConfirmDeleteTitle;

  /// No description provided for @devConfirmDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete all nexus_info.json files? This will remove all custom names, covers, and metadata. This action cannot be undone.'**
  String get devConfirmDeleteDesc;

  /// No description provided for @devDeleteSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Deletion Complete'**
  String get devDeleteSuccessTitle;

  /// No description provided for @devDeleteSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted {count} nexus_info.json files.'**
  String devDeleteSuccessDesc(Object count);

  /// No description provided for @devConfirmExtractTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Extraction'**
  String get devConfirmExtractTitle;

  /// No description provided for @devConfirmExtractDesc.
  ///
  /// In en, this message translates to:
  /// **'This will scan all your mods and create \'ID Mods.json\' on your desktop. This will overwrite any existing file with the same name. Do you want to continue?'**
  String get devConfirmExtractDesc;

  /// No description provided for @devExtractAction.
  ///
  /// In en, this message translates to:
  /// **'Extract'**
  String get devExtractAction;

  /// No description provided for @devTestSelfUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Test self-update'**
  String get devTestSelfUpdateTitle;

  /// No description provided for @devTestSelfUpdateDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick the app\'s .zip package and install it over this app, as the automatic update will do.'**
  String get devTestSelfUpdateDesc;

  /// No description provided for @devSelfUpdateUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Self-update is only available on Windows.'**
  String get devSelfUpdateUnsupported;

  /// No description provided for @devSelfUpdatePickTitle.
  ///
  /// In en, this message translates to:
  /// **'Select the SB Control Center .zip'**
  String get devSelfUpdatePickTitle;

  /// No description provided for @devSelfUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not install the update'**
  String get devSelfUpdateFailed;

  /// No description provided for @devSelfUpdateDryRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Package is valid (test mode)'**
  String get devSelfUpdateDryRunTitle;

  /// No description provided for @devSelfUpdateDryRunDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} files found. It was not installed because this is not a release build.'**
  String devSelfUpdateDryRunDesc(int count);

  /// No description provided for @devSelfUpdateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Install update?'**
  String get devSelfUpdateConfirmTitle;

  /// No description provided for @devSelfUpdateConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'The app will close, replace its files with the ones from the package and open again automatically.'**
  String get devSelfUpdateConfirmDesc;

  /// No description provided for @devSelfUpdateInstallAction.
  ///
  /// In en, this message translates to:
  /// **'Install and restart'**
  String get devSelfUpdateInstallAction;

  /// No description provided for @devSelfUpdateProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Updating SB Control Center'**
  String get devSelfUpdateProgressTitle;

  /// No description provided for @devSelfUpdateExtracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting package…'**
  String get devSelfUpdateExtracting;

  /// No description provided for @devSelfUpdateInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing files…'**
  String get devSelfUpdateInstalling;

  /// No description provided for @devSelfUpdateRestarting.
  ///
  /// In en, this message translates to:
  /// **'Restarting…'**
  String get devSelfUpdateRestarting;

  /// No description provided for @appUpdateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get appUpdateAvailableTitle;

  /// No description provided for @appUpdateAvailableMsg.
  ///
  /// In en, this message translates to:
  /// **'The app will download the update, install it and restart automatically.'**
  String get appUpdateAvailableMsg;

  /// No description provided for @appUpdateInstalledLabel.
  ///
  /// In en, this message translates to:
  /// **'INSTALLED'**
  String get appUpdateInstalledLabel;

  /// No description provided for @appUpdateAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get appUpdateAvailableLabel;

  /// No description provided for @appUpdateDownloadSize.
  ///
  /// In en, this message translates to:
  /// **'Download size: {size}'**
  String appUpdateDownloadSize(String size);

  /// No description provided for @appUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get appUpdateNow;

  /// No description provided for @appUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get appUpdateLater;

  /// No description provided for @appUpdateSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip this version'**
  String get appUpdateSkip;

  /// No description provided for @appUpdateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get appUpdateDownloading;

  /// No description provided for @appUpdateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You already have the latest version'**
  String get appUpdateUpToDate;

  /// No description provided for @appUpdateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates'**
  String get appUpdateCheckFailed;

  /// No description provided for @settingsCheckAppUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for app updates'**
  String get settingsCheckAppUpdate;

  /// No description provided for @settingsCheckAppUpdateDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for a new version of SB Control Center on GitHub'**
  String get settingsCheckAppUpdateDesc;

  /// No description provided for @settingsChangelog.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get settingsChangelog;

  /// No description provided for @settingsChangelogDesc.
  ///
  /// In en, this message translates to:
  /// **'See what\'s new in each version'**
  String get settingsChangelogDesc;

  /// No description provided for @changelogWhatsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new in {version}'**
  String changelogWhatsNewTitle(String version);

  /// No description provided for @changelogUpdatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SB Control Center was updated successfully'**
  String get changelogUpdatedSubtitle;

  /// No description provided for @changelogHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelogHistoryTitle;

  /// No description provided for @changelogInstalledVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed version: {version}'**
  String changelogInstalledVersion(String version);

  /// No description provided for @changelogInstalledBadge.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get changelogInstalledBadge;

  /// No description provided for @changelogPrereleaseBadge.
  ///
  /// In en, this message translates to:
  /// **'Pre-release'**
  String get changelogPrereleaseBadge;

  /// No description provided for @changelogEmpty.
  ///
  /// In en, this message translates to:
  /// **'This release has no notes.'**
  String get changelogEmpty;

  /// No description provided for @changelogViewOnGithub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get changelogViewOnGithub;

  /// No description provided for @changelogLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the changelog. Check your connection.'**
  String get changelogLoadFailed;

  /// No description provided for @changelogRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get changelogRetry;

  /// No description provided for @devExtractNoData.
  ///
  /// In en, this message translates to:
  /// **'No mods with valid identifiers were found to extract.'**
  String get devExtractNoData;

  /// No description provided for @devExtractDesktopNotFound.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not find the Desktop directory.'**
  String get devExtractDesktopNotFound;

  /// No description provided for @devExtractSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Extraction Complete'**
  String get devExtractSuccessTitle;

  /// No description provided for @devExtractSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'File successfully created at: {path}'**
  String devExtractSuccessDesc(Object path);

  /// No description provided for @errorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get errorDialogTitle;

  /// No description provided for @modDetailsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get modDetailsCategory;

  /// No description provided for @modDetailsAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get modDetailsAuthor;

  /// No description provided for @modDetailsNexusId.
  ///
  /// In en, this message translates to:
  /// **'Nexus ID'**
  String get modDetailsNexusId;

  /// No description provided for @modDetailsInstalledOn.
  ///
  /// In en, this message translates to:
  /// **'Installed on'**
  String get modDetailsInstalledOn;

  /// No description provided for @unknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownAuthor;

  /// General status message when the installation process begins.
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get statusInstalling;

  /// Status message shown for each mod being installed, indicating progress.
  ///
  /// In en, this message translates to:
  /// **'Installing {index}/{total}: {modName}'**
  String statusInstallingMod(int index, int total, String modName);

  /// No description provided for @byText.
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String byText(Object author);

  /// No description provided for @filterUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Updates Available'**
  String get filterUpdatesAvailable;

  /// Notification text shown when a user ignores an update for a specific mod.
  ///
  /// In en, this message translates to:
  /// **'Update for \'{modName}\' ignored for this session.'**
  String snackBarUpdateIgnored(String modName);

  /// Notification text shown when a user decides to permanently skip a specific version of a mod.
  ///
  /// In en, this message translates to:
  /// **'Version \'{version}\' of \'{modName}\' will be skipped in future checks.'**
  String snackBarVersionSkipped(String modName, String version);

  /// Status message shown while updating the metadata of a single mod.
  ///
  /// In en, this message translates to:
  /// **'Updating metadata for \'{displayName}\' ({arg1} of {arg2})...'**
  String statusUpdatingMetadata(String displayName, int arg1, int arg2);

  /// No description provided for @genericModInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Generic Mod Installed: {modName}'**
  String genericModInstallTitle(String modName);

  /// No description provided for @genericModInstallDesc.
  ///
  /// In en, this message translates to:
  /// **'Installed to {path}. This mod is not managed by the app and must be uninstalled manually.'**
  String genericModInstallDesc(String path);

  /// No description provided for @genericModInstallError.
  ///
  /// In en, this message translates to:
  /// **'Failed to install generic mod: {modName}'**
  String genericModInstallError(String modName);

  /// No description provided for @modTypeCNS.
  ///
  /// In en, this message translates to:
  /// **'CNS'**
  String get modTypeCNS;

  /// No description provided for @modTypeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Generic'**
  String get modTypeGeneric;

  /// No description provided for @modTypeMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get modTypeMovies;

  /// No description provided for @modTypeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get modTypeSave;

  /// No description provided for @modTypeConfig.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get modTypeConfig;

  /// No description provided for @modTypeSplash.
  ///
  /// In en, this message translates to:
  /// **'Splash'**
  String get modTypeSplash;

  /// No description provided for @replacesOutfitTitle.
  ///
  /// In en, this message translates to:
  /// **'Replaces Outfit'**
  String get replacesOutfitTitle;

  /// No description provided for @replacesOutfitClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear outfit selection'**
  String get replacesOutfitClearTooltip;

  /// No description provided for @replacesOutfitSelectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select outfit to replace'**
  String get replacesOutfitSelectTooltip;

  /// No description provided for @replacesOutfitNone.
  ///
  /// In en, this message translates to:
  /// **'No outfit selected. The tag will be \'Generic\'.'**
  String get replacesOutfitNone;

  /// No description provided for @replacesOutfitSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search outfits...'**
  String get replacesOutfitSearchHint;

  /// No description provided for @modTypeReplacement.
  ///
  /// In en, this message translates to:
  /// **'Replacement'**
  String get modTypeReplacement;

  /// No description provided for @replacesOutfitHover.
  ///
  /// In en, this message translates to:
  /// **'Hover over an outfit to see a preview.'**
  String get replacesOutfitHover;

  /// Title for the dialog that asks if a generic mod is an outfit replacement
  ///
  /// In en, this message translates to:
  /// **'Outfit Replacement?'**
  String get dialogTitleOutfitReplacement;

  /// Content for the outfit replacement dialog
  ///
  /// In en, this message translates to:
  /// **'Is the mod \'{modName}\' an outfit replacement?\n\nSelect \'Yes\' to choose which outfit it replaces, or \'No\' to install it as a generic mod.'**
  String dialogContentOutfitReplacement(String modName);

  /// Button text for 'No'
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get dialogActionNo;

  /// Button text for 'Yes'
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get dialogActionYes;

  /// Title of the dialog when trying to enable a mod that replaces an outfit already replaced by another mod.
  ///
  /// In en, this message translates to:
  /// **'Outfit Conflict Detected'**
  String get dialogTitleOutfitConflict;

  /// Content of the outfit conflict dialog. outfitName is the outfit's name, modName is the conflicting mod's name.
  ///
  /// In en, this message translates to:
  /// **'The outfit \'{outfitName}\' is already being replaced by the mod \'{modName}\'.\n\nDo you want to disable \'{modName}\' and activate this one instead?'**
  String dialogContentOutfitConflict(String outfitName, String modName);

  /// Button to force activation of a mod, disabling the conflicting one.
  ///
  /// In en, this message translates to:
  /// **'Disable and Activate'**
  String get dialogActionActivateAndDisable;

  /// Title for the replacement mod switch
  ///
  /// In en, this message translates to:
  /// **'Replacement mod'**
  String get replacementModSwitchTitle;

  /// Description for the replacement mod switch
  ///
  /// In en, this message translates to:
  /// **'Check if this mod is designed to replace a suit in the game.'**
  String get replacementModSwitchDesc;

  /// Title for the setting that toggles mod tags visibility
  ///
  /// In en, this message translates to:
  /// **'Show mod type tags'**
  String get settingsShowModTagsTitle;

  /// Description for the setting that toggles mod tags visibility
  ///
  /// In en, this message translates to:
  /// **'Display mod type tags (e.g., CNS, Generic) on each mod card in the list.'**
  String get settingsShowModTagsDesc;

  /// Description for the Logic mod type
  ///
  /// In en, this message translates to:
  /// **'Logic'**
  String get modTypeLogic;

  /// No description provided for @patcherStarted.
  ///
  /// In en, this message translates to:
  /// **'=== StellarBlade Dart Patcher Started ==='**
  String get patcherStarted;

  /// No description provided for @workingDirectory.
  ///
  /// In en, this message translates to:
  /// **'Working directory: {path}'**
  String workingDirectory(String path);

  /// No description provided for @modsDirNotFound.
  ///
  /// In en, this message translates to:
  /// **'The ~mods directory does not exist at: {path}'**
  String modsDirNotFound(String path);

  /// No description provided for @warnCannotScanFolder.
  ///
  /// In en, this message translates to:
  /// **'\n  WARNING: Could not scan folder {path}. Skipping.'**
  String warnCannotScanFolder(String path);

  /// No description provided for @errorDetails.
  ///
  /// In en, this message translates to:
  /// **'  Error: {error}\n'**
  String errorDetails(String error);

  /// No description provided for @foundUtocFiles.
  ///
  /// In en, this message translates to:
  /// **'Found {count} .utoc files'**
  String foundUtocFiles(int count);

  /// No description provided for @noModsFound2.
  ///
  /// In en, this message translates to:
  /// **'No mods found to process.'**
  String get noModsFound2;

  /// No description provided for @patcherSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'\n=== Patcher Summary (Raw Data) ==='**
  String get patcherSummaryTitle;

  /// No description provided for @processedMods.
  ///
  /// In en, this message translates to:
  /// **'Processed {count} mods.'**
  String processedMods(int count);

  /// No description provided for @fixedContainerIdConflicts.
  ///
  /// In en, this message translates to:
  /// **'Fixed {count} Container ID conflicts.'**
  String fixedContainerIdConflicts(int count);

  /// No description provided for @foundPackageIdConflicts.
  ///
  /// In en, this message translates to:
  /// **'Found {count} Package ID conflicts.'**
  String foundPackageIdConflicts(int count);

  /// No description provided for @fatalErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'\n=== FATAL ERROR ==='**
  String get fatalErrorTitle;

  /// No description provided for @patcherServiceError.
  ///
  /// In en, this message translates to:
  /// **'Error in PatcherService: {error}'**
  String patcherServiceError(String error);

  /// No description provided for @analyzingFile.
  ///
  /// In en, this message translates to:
  /// **'--- Analyzing: {fileName} ---'**
  String analyzingFile(String fileName);

  /// No description provided for @warnUcasNotFound.
  ///
  /// In en, this message translates to:
  /// **'  WARNING: .ucas file not found. Skipping.'**
  String get warnUcasNotFound;

  /// No description provided for @warnCorruptHeader.
  ///
  /// In en, this message translates to:
  /// **'  WARNING: Corrupt header, entry size exceeds file size. Skipping.'**
  String get warnCorruptHeader;

  /// No description provided for @conflictContainerIdDetected.
  ///
  /// In en, this message translates to:
  /// **'  Container ID CONFLICT detected: {id}'**
  String conflictContainerIdDetected(int id);

  /// No description provided for @generatingNewId.
  ///
  /// In en, this message translates to:
  /// **'  Generating new ID: {id}'**
  String generatingNewId(int id);

  /// No description provided for @utocFilePatched.
  ///
  /// In en, this message translates to:
  /// **'  .utoc file patched.'**
  String get utocFilePatched;

  /// No description provided for @patchingUcasFile.
  ///
  /// In en, this message translates to:
  /// **'  Patching .ucas file...'**
  String get patchingUcasFile;

  /// No description provided for @ucasReplacementsSuccess.
  ///
  /// In en, this message translates to:
  /// **'  Successful replacements in .ucas: {count}'**
  String ucasReplacementsSuccess(int count);

  /// No description provided for @patchComplete.
  ///
  /// In en, this message translates to:
  /// **'  Patch complete!'**
  String get patchComplete;

  /// No description provided for @idRegisteredNoConflict.
  ///
  /// In en, this message translates to:
  /// **'  ID {id} registered. No conflicts.'**
  String idRegisteredNoConflict(int id);

  /// No description provided for @errorProcessingFile.
  ///
  /// In en, this message translates to:
  /// **'  ERROR processing {fileName}: {error}'**
  String errorProcessingFile(String fileName, String error);

  /// No description provided for @statusRunningPatcher.
  ///
  /// In en, this message translates to:
  /// **'Running Conflict Patcher...'**
  String get statusRunningPatcher;

  /// No description provided for @summarySuccessContainerIds.
  ///
  /// In en, this message translates to:
  /// **'✅ Success! Fixed {count} crash-causing Container ID conflicts.'**
  String summarySuccessContainerIds(int count);

  /// No description provided for @summaryNoContainerIdConflicts.
  ///
  /// In en, this message translates to:
  /// **'✅ No Container ID (crash) conflicts were found.'**
  String get summaryNoContainerIdConflicts;

  /// No description provided for @summaryNoPackageIdConflicts.
  ///
  /// In en, this message translates to:
  /// **'✅ Good news! No serious Package ID (overwrite) conflicts were found.'**
  String get summaryNoPackageIdConflicts;

  /// No description provided for @summaryFoundPackageIdConflicts.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning! Found {count} groups of mods that cannot coexist:'**
  String summaryFoundPackageIdConflicts(int count);

  /// No description provided for @summaryConflictGroupDetails.
  ///
  /// In en, this message translates to:
  /// **'  • This group of mods competes for {count} files:'**
  String summaryConflictGroupDetails(int count);

  /// No description provided for @patcherSummaryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Patcher Summary'**
  String get patcherSummaryDialogTitle;

  /// No description provided for @dialogActionShowFullLog.
  ///
  /// In en, this message translates to:
  /// **'Show Full Log'**
  String get dialogActionShowFullLog;

  /// No description provided for @fullLogDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflict Patcher Log (Dart)'**
  String get fullLogDialogTitle;

  /// No description provided for @runConflictPatcherTitle.
  ///
  /// In en, this message translates to:
  /// **'Run Conflict Patcher'**
  String get runConflictPatcherTitle;

  /// No description provided for @runConflictPatcherSubtitlePython.
  ///
  /// In en, this message translates to:
  /// **'Fixes Container_Id & Package_Id crashes'**
  String get runConflictPatcherSubtitlePython;

  /// No description provided for @processingCover.
  ///
  /// In en, this message translates to:
  /// **'Processing Cover...'**
  String get processingCover;

  /// No description provided for @apiKeyTooltip.
  ///
  /// In en, this message translates to:
  /// **'API Key is required for smart Nexus ID extraction.'**
  String get apiKeyTooltip;

  /// Title for the special mod selection dialog
  ///
  /// In en, this message translates to:
  /// **'Installation Options - Mod {nexusId}'**
  String dialogTitleSpecialModSelection(String nexusId);

  /// No description provided for @dialogContentSpecialModSelection.
  ///
  /// In en, this message translates to:
  /// **'Select the options you want to install. The required main files will be installed automatically.'**
  String get dialogContentSpecialModSelection;

  /// No description provided for @snackBarSpecialModNoSelection.
  ///
  /// In en, this message translates to:
  /// **'Select at least one option to continue.'**
  String get snackBarSpecialModNoSelection;

  /// No description provided for @dialogActionInstallSelection.
  ///
  /// In en, this message translates to:
  /// **'Install Selection'**
  String get dialogActionInstallSelection;

  /// No description provided for @downloadStatusFetching.
  ///
  /// In en, this message translates to:
  /// **'Obtaining Nexus Mods data...'**
  String get downloadStatusFetching;

  /// No description provided for @downloadStatusFetchingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get download link. Check your API Key or connection.'**
  String get downloadStatusFetchingFailed;

  /// No description provided for @downloadStatusDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {fileName}'**
  String downloadStatusDownloading(String fileName);

  /// No description provided for @downloadStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error during file download.'**
  String get downloadStatusError;

  /// No description provided for @downloadStatusException.
  ///
  /// In en, this message translates to:
  /// **'Exception: {error}'**
  String downloadStatusException(String error);

  /// No description provided for @dialogTitleDownloadModManager.
  ///
  /// In en, this message translates to:
  /// **'Mod Manager Download'**
  String get dialogTitleDownloadModManager;

  /// No description provided for @launchGameText.
  ///
  /// In en, this message translates to:
  /// **'Launch Stellar Blade'**
  String get launchGameText;

  /// No description provided for @stopGameText.
  ///
  /// In en, this message translates to:
  /// **'Stop Stellar Blade'**
  String get stopGameText;

  /// No description provided for @dialogTitleStopGame.
  ///
  /// In en, this message translates to:
  /// **'Stop Stellar Blade?'**
  String get dialogTitleStopGame;

  /// No description provided for @dialogContentStopGame.
  ///
  /// In en, this message translates to:
  /// **'The game will be closed. Any unsaved progress will be lost.'**
  String get dialogContentStopGame;

  /// No description provided for @dialogActionStopGame.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get dialogActionStopGame;

  /// No description provided for @notificationGameStopped.
  ///
  /// In en, this message translates to:
  /// **'Stellar Blade stopped'**
  String get notificationGameStopped;

  /// No description provided for @errorStoppingGame.
  ///
  /// In en, this message translates to:
  /// **'Could not stop the game'**
  String get errorStoppingGame;

  /// No description provided for @mod801DialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Steam Configuration Required'**
  String get mod801DialogTitle;

  /// No description provided for @mod801DialogIntro.
  ///
  /// In en, this message translates to:
  /// **'The Random Splash mod has been installed. To make it work automatically when you launch the game, you need to configure Steam.'**
  String get mod801DialogIntro;

  /// No description provided for @mod801Step1.
  ///
  /// In en, this message translates to:
  /// **'1. Generate the exact path for your PC below and copy it.'**
  String get mod801Step1;

  /// No description provided for @mod801Step2.
  ///
  /// In en, this message translates to:
  /// **'2. Open your Steam Library.'**
  String get mod801Step2;

  /// No description provided for @mod801Step3.
  ///
  /// In en, this message translates to:
  /// **'3. Right-click on Stellar Blade -> Properties.'**
  String get mod801Step3;

  /// No description provided for @mod801Step4.
  ///
  /// In en, this message translates to:
  /// **'4. In the \'General\' tab, paste the code into \'Launch Options\'.'**
  String get mod801Step4;

  /// No description provided for @mod801BtnGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Path'**
  String get mod801BtnGenerate;

  /// No description provided for @mod801BtnSteam.
  ///
  /// In en, this message translates to:
  /// **'Open Steam'**
  String get mod801BtnSteam;

  /// No description provided for @mod801BtnCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get mod801BtnCopy;

  /// No description provided for @mod801PathGenerated.
  ///
  /// In en, this message translates to:
  /// **'Path generated successfully.'**
  String get mod801PathGenerated;

  /// No description provided for @mod801PathCopied.
  ///
  /// In en, this message translates to:
  /// **'Command copied to clipboard!'**
  String get mod801PathCopied;

  /// No description provided for @statusVerifyingMods.
  ///
  /// In en, this message translates to:
  /// **'Verifying integrity of mods...'**
  String get statusVerifyingMods;

  /// No description provided for @errorSelecting7Zip.
  ///
  /// In en, this message translates to:
  /// **'Error selecting 7-Zip: {error}'**
  String errorSelecting7Zip(String error);

  /// No description provided for @errorInvalidFolderRetry.
  ///
  /// In en, this message translates to:
  /// **'The selected folder does not seem to be correct. Please try again.'**
  String get errorInvalidFolderRetry;

  /// No description provided for @errorSelectingFolderDynamic.
  ///
  /// In en, this message translates to:
  /// **'Error selecting folder: {error}'**
  String errorSelectingFolderDynamic(String error);

  /// No description provided for @statusNoNewModsInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installation produced no new mods.'**
  String get statusNoNewModsInstalled;

  /// No description provided for @errorDisableModBeforeDelete.
  ///
  /// In en, this message translates to:
  /// **'Please disable the mod before deleting it.'**
  String get errorDisableModBeforeDelete;

  /// No description provided for @snackBarModsEnabledWithSkips.
  ///
  /// In en, this message translates to:
  /// **'Enabled: {successCount} (Skipped: {skippedCount} due to conflicts)'**
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount);

  /// No description provided for @snackBarDeveloperModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Developer Mode Enabled!'**
  String get snackBarDeveloperModeEnabled;

  /// No description provided for @errorRenamingMod.
  ///
  /// In en, this message translates to:
  /// **'Error renaming mod: {error}'**
  String errorRenamingMod(String error);

  /// No description provided for @notificationTitleError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get notificationTitleError;

  /// No description provided for @errorGamePathNotFoundNotification.
  ///
  /// In en, this message translates to:
  /// **'Game path not found.'**
  String get errorGamePathNotFoundNotification;

  /// No description provided for @notificationLaunchingGame.
  ///
  /// In en, this message translates to:
  /// **'Launching Stellar Blade...'**
  String get notificationLaunchingGame;

  /// No description provided for @errorLaunchingGame.
  ///
  /// In en, this message translates to:
  /// **'Error launching the game'**
  String get errorLaunchingGame;

  /// No description provided for @dialogTitleSelect7zip.
  ///
  /// In en, this message translates to:
  /// **'Select the 7z.exe file'**
  String get dialogTitleSelect7zip;

  /// No description provided for @dialogTitleSelectGameFolder.
  ///
  /// In en, this message translates to:
  /// **'Please select the main StellarBlade folder'**
  String get dialogTitleSelectGameFolder;

  /// No description provided for @dialogTitleSelectCover.
  ///
  /// In en, this message translates to:
  /// **'Select a cover for the mod'**
  String get dialogTitleSelectCover;

  /// No description provided for @errorGamePathNotFoundException.
  ///
  /// In en, this message translates to:
  /// **'Game path not found.'**
  String get errorGamePathNotFoundException;

  /// No description provided for @errorGamePathNotDefined.
  ///
  /// In en, this message translates to:
  /// **'Game path not defined.'**
  String get errorGamePathNotDefined;

  /// No description provided for @errorLogicModsPathNotDefined.
  ///
  /// In en, this message translates to:
  /// **'LogicMods path is not defined.'**
  String get errorLogicModsPathNotDefined;

  /// No description provided for @errorUe4ssModsPathNotDefined.
  ///
  /// In en, this message translates to:
  /// **'UE4SS Mods path is not defined.'**
  String get errorUe4ssModsPathNotDefined;

  /// No description provided for @errorGenericModsPathNotDefined.
  ///
  /// In en, this message translates to:
  /// **'Generic mods (~mods) path is not defined.'**
  String get errorGenericModsPathNotDefined;

  /// No description provided for @errorReplaceNoOldVersion.
  ///
  /// In en, this message translates to:
  /// **'Attempted to replace a mod but no old version was identified.'**
  String get errorReplaceNoOldVersion;

  /// No description provided for @errorDeleteOldModVersion.
  ///
  /// In en, this message translates to:
  /// **'Could not delete old mod version ({modName}).'**
  String errorDeleteOldModVersion(String modName);

  /// No description provided for @errorDeleteExistingModReinstall.
  ///
  /// In en, this message translates to:
  /// **'Could not delete existing mod ({modName}) to reinstall.'**
  String errorDeleteExistingModReinstall(String modName);

  /// No description provided for @errorDeleteExistingModReinstallAttempts.
  ///
  /// In en, this message translates to:
  /// **'Could not delete existing mod ({modName}) to reinstall after several attempts.'**
  String errorDeleteExistingModReinstallAttempts(String modName);

  /// No description provided for @errorMoviesModNoValidFiles.
  ///
  /// In en, this message translates to:
  /// **'Movies mod contains no valid video files.'**
  String get errorMoviesModNoValidFiles;

  /// No description provided for @errorInstallPathUndetermined.
  ///
  /// In en, this message translates to:
  /// **'Installation path could not be determined.'**
  String get errorInstallPathUndetermined;

  /// No description provided for @errorMoviesPathsNotDefined.
  ///
  /// In en, this message translates to:
  /// **'Movies paths are not defined.'**
  String get errorMoviesPathsNotDefined;

  /// No description provided for @errorNexusInfoNotFoundForMod.
  ///
  /// In en, this message translates to:
  /// **'nexus_info.json not found for {modName}.'**
  String errorNexusInfoNotFoundForMod(String modName);

  /// No description provided for @errorMenuVideoLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Menu video limit of 99 reached.'**
  String get errorMenuVideoLimitReached;

  /// No description provided for @errorModRequires529.
  ///
  /// In en, this message translates to:
  /// **'The mod requires Mod ID 529 to work (contains only WebM files).'**
  String get errorModRequires529;

  /// No description provided for @errorSplashPathsNotDefined.
  ///
  /// In en, this message translates to:
  /// **'Splash paths are not defined.'**
  String get errorSplashPathsNotDefined;

  /// No description provided for @errorSplashNoValidImages.
  ///
  /// In en, this message translates to:
  /// **'No valid images were found in the mod.'**
  String get errorSplashNoValidImages;

  /// No description provided for @errorCouldNotDeleteDirectory.
  ///
  /// In en, this message translates to:
  /// **'Could not delete directory.'**
  String get errorCouldNotDeleteDirectory;

  /// No description provided for @errorGameExeNotFound.
  ///
  /// In en, this message translates to:
  /// **'The game\'s executable file (.exe) was not found in the main folder or in Binaries.'**
  String get errorGameExeNotFound;

  /// Title for the splash mod image selection dialog.
  ///
  /// In en, this message translates to:
  /// **'Splash Options (Images)'**
  String get dialogTitleSplashOptions;

  /// No description provided for @dialogContentSplashOptions.
  ///
  /// In en, this message translates to:
  /// **'Select the images you want to install. You can choose entire folders (batches) or individual images.'**
  String get dialogContentSplashOptions;

  /// No description provided for @snackBarSplashNoSelection.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one image.'**
  String get snackBarSplashNoSelection;

  /// No description provided for @dialogContentSpecialModSingleSelection.
  ///
  /// In en, this message translates to:
  /// **'Select a single option to install.'**
  String get dialogContentSpecialModSingleSelection;

  /// No description provided for @activeDownloads.
  ///
  /// In en, this message translates to:
  /// **'Active Downloads'**
  String get activeDownloads;

  /// Indicates how many mods are currently downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading {count} {count, plural, =1{mod} other{mods}}'**
  String downloadingModsCount(int count);

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get downloadError;

  /// Status text shown when a download is cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get downloadCancelled;

  /// Tooltip for the pause download button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get downloadPause;

  /// Tooltip for the resume download button
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get downloadResume;

  /// Tooltip for the cancel download button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get downloadCancel;

  /// No description provided for @errorNexusInfoNotFound.
  ///
  /// In en, this message translates to:
  /// **'nexus_info.json not found.'**
  String get errorNexusInfoNotFound;

  /// No description provided for @logFixingCorruptedJson.
  ///
  /// In en, this message translates to:
  /// **'Fixing corrupted nexus_info.json for {displayName}.'**
  String logFixingCorruptedJson(String displayName);

  /// No description provided for @logMetadataUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update metadata for {displayName}: {error}'**
  String logMetadataUpdateFailed(String displayName, String error);

  /// No description provided for @logDisablingMovieMod.
  ///
  /// In en, this message translates to:
  /// **'Preventively disabling movie mod due to Mod 529 activation: {modName}'**
  String logDisablingMovieMod(String modName);

  /// No description provided for @logDisablingSplashMod.
  ///
  /// In en, this message translates to:
  /// **'Preventively disabling splash mod due to Mod 801 activation: {modName}'**
  String logDisablingSplashMod(String modName);

  /// No description provided for @logRestoringTildeComponent.
  ///
  /// In en, this message translates to:
  /// **'Restoring ~mods component: {folderName}'**
  String logRestoringTildeComponent(String folderName);

  /// No description provided for @logRestoringUe4ssComponent.
  ///
  /// In en, this message translates to:
  /// **'Restoring UE4SS component: {folderName}'**
  String logRestoringUe4ssComponent(String folderName);

  /// No description provided for @logErrorRestoringLogicMod.
  ///
  /// In en, this message translates to:
  /// **'Error restoring LogicMod components: {error}'**
  String logErrorRestoringLogicMod(String error);

  /// No description provided for @logArchivingTildeComponent.
  ///
  /// In en, this message translates to:
  /// **'Archiving ~mods component: {folderName}'**
  String logArchivingTildeComponent(String folderName);

  /// No description provided for @logArchivingUe4ssComponent.
  ///
  /// In en, this message translates to:
  /// **'Archiving UE4SS component: {folderName}'**
  String logArchivingUe4ssComponent(String folderName);

  /// No description provided for @logErrorArchivingLogicMod.
  ///
  /// In en, this message translates to:
  /// **'Error archiving LogicMod components: {error}'**
  String logErrorArchivingLogicMod(String error);

  /// No description provided for @logSkippingActiveVariant.
  ///
  /// In en, this message translates to:
  /// **'Skipping {modName}: An active variant of this mod already exists.'**
  String logSkippingActiveVariant(String modName);

  /// No description provided for @logSkippingOutfitConflict.
  ///
  /// In en, this message translates to:
  /// **'Skipping {modName}: Conflict with an already occupied outfit.'**
  String logSkippingOutfitConflict(String modName);

  /// No description provided for @logErrorCleaningVideoBackups.
  ///
  /// In en, this message translates to:
  /// **'Could not clean video backups for {modName}: {error}'**
  String logErrorCleaningVideoBackups(String modName, String error);

  /// No description provided for @logNewNexusIdDetected.
  ///
  /// In en, this message translates to:
  /// **'New Nexus ID {nexusId} detected. Fetching metadata...'**
  String logNewNexusIdDetected(String nexusId);

  /// No description provided for @logMetadataApplied.
  ///
  /// In en, this message translates to:
  /// **'Metadata fetched and applied for {nexusId}.'**
  String logMetadataApplied(String nexusId);

  /// No description provided for @logFallbackByteCopy.
  ///
  /// In en, this message translates to:
  /// **'Normal copy failed, using byte brute-force: {error}'**
  String logFallbackByteCopy(String error);

  /// No description provided for @logWarningDeleteModifiedFile.
  ///
  /// In en, this message translates to:
  /// **'Warning: Could not delete modified file: {error}'**
  String logWarningDeleteModifiedFile(String error);

  /// No description provided for @logMod801BatPatched.
  ///
  /// In en, this message translates to:
  /// **'Mod 801 .bat script successfully patched for this system.'**
  String get logMod801BatPatched;

  /// No description provided for @logMod801BatPatchError.
  ///
  /// In en, this message translates to:
  /// **'Error attempting to patch the Mod 801 .bat file: {error}'**
  String logMod801BatPatchError(String error);

  /// No description provided for @errorHomeDirNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find the home directory environment variable.'**
  String get errorHomeDirNotFound;

  /// Placeholder text while fetching file info
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get downloadFetchingPlaceholder;

  /// Error when nxm link resolution fails
  ///
  /// In en, this message translates to:
  /// **'Could not fetch download link'**
  String get downloadErrorLink;

  /// General download failure error
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadErrorGeneral;

  /// Status text when download is paused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get downloadPausedStatus;

  /// No description provided for @settingsFixGameStartup.
  ///
  /// In en, this message translates to:
  /// **'Fix game not starting'**
  String get settingsFixGameStartup;

  /// No description provided for @settingsFixGameStartupDesc.
  ///
  /// In en, this message translates to:
  /// **'Use this if the game closes or crashes on launch. Temporarily uninstalls UE4SS and CNS, starts the game once, then reinstalls them.'**
  String get settingsFixGameStartupDesc;

  /// No description provided for @repairConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Fix game startup?'**
  String get repairConfirmTitle;

  /// No description provided for @repairConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'UE4SS and CNS will be uninstalled (their files are kept safe), the game will start and close automatically, and then everything is reinstalled and the game launches again. Don\'t close the app during the process.'**
  String get repairConfirmMessage;

  /// No description provided for @repairConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Start repair'**
  String get repairConfirmAction;

  /// No description provided for @launchRetryTitle.
  ///
  /// In en, this message translates to:
  /// **'Game didn\'t start'**
  String get launchRetryTitle;

  /// No description provided for @launchRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'Stellar Blade didn\'t start after two attempts. This is usually caused by UE4SS or CNS. \"Fix game not starting\" temporarily uninstalls them, launches the game once and reinstalls them. Run it now?'**
  String get launchRetryMessage;

  /// No description provided for @launchRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Fix now'**
  String get launchRetryAction;

  /// No description provided for @repairOverlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Fixing game startup'**
  String get repairOverlayTitle;

  /// No description provided for @repairOverlayWarning.
  ///
  /// In en, this message translates to:
  /// **'Don\'t close the app or the game manually while this runs.'**
  String get repairOverlayWarning;

  /// No description provided for @repairStepCloseGame.
  ///
  /// In en, this message translates to:
  /// **'Closing the game if it\'s running'**
  String get repairStepCloseGame;

  /// No description provided for @repairStepStashCns.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling CNS (saving its files)'**
  String get repairStepStashCns;

  /// No description provided for @repairStepStashUe4ss.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling UE4SS (saving its files)'**
  String get repairStepStashUe4ss;

  /// No description provided for @repairStepLaunchClean.
  ///
  /// In en, this message translates to:
  /// **'Starting the game without UE4SS and CNS'**
  String get repairStepLaunchClean;

  /// No description provided for @repairStepWaitInit.
  ///
  /// In en, this message translates to:
  /// **'Letting the game load'**
  String get repairStepWaitInit;

  /// No description provided for @repairStepCloseAuto.
  ///
  /// In en, this message translates to:
  /// **'Closing the game automatically'**
  String get repairStepCloseAuto;

  /// No description provided for @repairStepRestoreUe4ss.
  ///
  /// In en, this message translates to:
  /// **'Reinstalling UE4SS'**
  String get repairStepRestoreUe4ss;

  /// No description provided for @repairStepRestoreCns.
  ///
  /// In en, this message translates to:
  /// **'Reinstalling CNS'**
  String get repairStepRestoreCns;

  /// No description provided for @repairStepLaunchFinal.
  ///
  /// In en, this message translates to:
  /// **'Launching the game'**
  String get repairStepLaunchFinal;

  /// No description provided for @repairStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'skipped'**
  String get repairStatusSkipped;

  /// No description provided for @repairResultSuccess.
  ///
  /// In en, this message translates to:
  /// **'Repair completed. The game has been launched.'**
  String get repairResultSuccess;

  /// No description provided for @repairResultErrorRestored.
  ///
  /// In en, this message translates to:
  /// **'The repair failed, but UE4SS and CNS were put back as they were.'**
  String get repairResultErrorRestored;

  /// No description provided for @repairResultErrorRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'The repair failed and the files could not be restored yet. They will be restored automatically the next time the app starts.'**
  String get repairResultErrorRestoreFailed;

  /// No description provided for @repairErrorGameNotStarted.
  ///
  /// In en, this message translates to:
  /// **'The game did not start in time.'**
  String get repairErrorGameNotStarted;

  /// No description provided for @repairButtonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get repairButtonClose;

  /// No description provided for @repairRecoveredNotice.
  ///
  /// In en, this message translates to:
  /// **'An interrupted repair was detected: UE4SS and CNS files were restored.'**
  String get repairRecoveredNotice;

  /// No description provided for @snackBarNewEditionInstalled.
  ///
  /// In en, this message translates to:
  /// **'New edition installed: {name}'**
  String snackBarNewEditionInstalled(Object name);

  /// No description provided for @snackBarNewEditionInstalledDesc.
  ///
  /// In en, this message translates to:
  /// **'This mod now has {count} editions installed.'**
  String snackBarNewEditionInstalledDesc(Object count);

  /// No description provided for @previewTagNewEdition.
  ///
  /// In en, this message translates to:
  /// **'new edition'**
  String get previewTagNewEdition;

  /// No description provided for @previewTagUpdate.
  ///
  /// In en, this message translates to:
  /// **'update'**
  String get previewTagUpdate;

  /// No description provided for @editionsInstalledTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count} editions of this mod installed'**
  String editionsInstalledTooltip(Object count);

  /// No description provided for @editionLabelValue.
  ///
  /// In en, this message translates to:
  /// **'Edition: {edition}'**
  String editionLabelValue(Object edition);

  /// No description provided for @otherEditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other installed editions'**
  String get otherEditionsTitle;

  /// No description provided for @detailsStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get detailsStatusEnabled;

  /// No description provided for @detailsStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get detailsStatusDisabled;

  /// No description provided for @detailsInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get detailsInformation;

  /// No description provided for @detailsRowAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get detailsRowAuthor;

  /// No description provided for @detailsRowType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get detailsRowType;

  /// No description provided for @detailsRowInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get detailsRowInstalled;

  /// No description provided for @detailsRowModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified'**
  String get detailsRowModified;

  /// No description provided for @detailsRowNexusId.
  ///
  /// In en, this message translates to:
  /// **'Nexus ID'**
  String get detailsRowNexusId;

  /// No description provided for @detailsRowFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get detailsRowFolder;

  /// No description provided for @detailsCopyPath.
  ///
  /// In en, this message translates to:
  /// **'Copy path'**
  String get detailsCopyPath;

  /// No description provided for @detailsCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get detailsCopied;

  /// No description provided for @detailsEndorse.
  ///
  /// In en, this message translates to:
  /// **'Endorse'**
  String get detailsEndorse;

  /// No description provided for @detailsEndorsed.
  ///
  /// In en, this message translates to:
  /// **'Endorsed'**
  String get detailsEndorsed;

  /// No description provided for @endorseWaitLabel.
  ///
  /// In en, this message translates to:
  /// **'Wait {minutes} min'**
  String endorseWaitLabel(Object minutes);

  /// No description provided for @endorseSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Mod endorsed'**
  String get endorseSuccessTitle;

  /// No description provided for @endorseRemovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Endorsement removed'**
  String get endorseRemovedTitle;

  /// No description provided for @endorseFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update endorsement'**
  String get endorseFailedTitle;

  /// No description provided for @endorseErrNotNexus.
  ///
  /// In en, this message translates to:
  /// **'This mod isn\'t linked to a Nexus Mods page, so it can\'t be endorsed.'**
  String get endorseErrNotNexus;

  /// No description provided for @endorseErrNoApiKey.
  ///
  /// In en, this message translates to:
  /// **'Add your Nexus Mods API key in Settings to endorse mods.'**
  String get endorseErrNoApiKey;

  /// No description provided for @endorseErrWait.
  ///
  /// In en, this message translates to:
  /// **'Nexus requires waiting 15 minutes after downloading a mod before you can endorse it. Try again in {minutes} min.'**
  String endorseErrWait(Object minutes);

  /// No description provided for @endorseErrNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Nexus only lets you endorse mods you\'ve downloaded with your account.'**
  String get endorseErrNotDownloaded;

  /// No description provided for @endorseErrOwnMod.
  ///
  /// In en, this message translates to:
  /// **'You can\'t endorse your own mod.'**
  String get endorseErrOwnMod;

  /// No description provided for @endorseErrRateLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the Nexus request limit. Try again later.'**
  String get endorseErrRateLimit;

  /// No description provided for @endorseErrInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'Nexus rejected your API key. Check it in Settings.'**
  String get endorseErrInvalidKey;

  /// No description provided for @endorseErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach Nexus Mods. Check your connection and try again.'**
  String get endorseErrNetwork;

  /// No description provided for @endorseErrUnknown.
  ///
  /// In en, this message translates to:
  /// **'Nexus couldn\'t process the request. Try again later.'**
  String get endorseErrUnknown;

  /// No description provided for @endorseRemoveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove endorsement?'**
  String get endorseRemoveConfirmTitle;

  /// No description provided for @endorseRemoveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer be endorsed on Nexus Mods.'**
  String endorseRemoveConfirmMessage(Object name);

  /// No description provided for @endorseRemoveConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get endorseRemoveConfirmAction;

  /// No description provided for @detailsUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get detailsUpdateAction;

  /// No description provided for @detailsShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get detailsShowMore;

  /// No description provided for @detailsShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get detailsShowLess;

  /// No description provided for @detailsAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get detailsAddNote;

  /// Number of outfits a replacement mod replaces
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No outfits} =1{1 outfit} other{{count} outfits}}'**
  String outfitsCount(int count);

  /// Subtitle of the outfit picker with the number of chosen outfits
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String outfitsSelectedCount(int count);

  /// No description provided for @outfitsChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose outfits'**
  String get outfitsChoose;

  /// No description provided for @outfitsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get outfitsDone;

  /// No description provided for @outfitsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get outfitsFilterAll;

  /// No description provided for @outfitsFilterSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get outfitsFilterSelected;

  /// No description provided for @outfitsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get outfitsClearAll;

  /// No description provided for @outfitsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get outfitsRemove;

  /// No description provided for @outfitsActionSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get outfitsActionSelect;

  /// No description provided for @outfitsActionDeselect.
  ///
  /// In en, this message translates to:
  /// **'Deselect'**
  String get outfitsActionDeselect;

  /// Empty state of the outfit picker when the search has no matches
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String outfitsNoResults(String query);

  /// No description provided for @outfitsSelectedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No outfits selected yet.'**
  String get outfitsSelectedEmpty;

  /// No description provided for @outfitsNoPreview.
  ///
  /// In en, this message translates to:
  /// **'No preview available'**
  String get outfitsNoPreview;

  /// No description provided for @replacementOffConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off replacement mod?'**
  String get replacementOffConfirmTitle;

  /// Confirmation shown when disabling the replacement switch while outfits are selected
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The selected outfit will be removed from this mod.} other{The {count} selected outfits will be removed from this mod.}}'**
  String replacementOffConfirmMessage(int count);

  /// No description provided for @replacementOffConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get replacementOffConfirmAction;

  /// Notification after the metadata migration assigned outfits to mods and some were turned off because they share an outfit with another enabled mod
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mod disabled: it replaces an outfit already used by another mod} other{{count} mods disabled: they replace outfits already used by other mods}}'**
  String outfitConflictAutoDisabled(int count);

  /// No description provided for @patcherSharedWith.
  ///
  /// In en, this message translates to:
  /// **'  Same Container ID as: {owner}'**
  String patcherSharedWith(String owner);

  /// No description provided for @patcherIdChange.
  ///
  /// In en, this message translates to:
  /// **'  Container ID {oldId} → {newId}'**
  String patcherIdChange(String oldId, String newId);

  /// No description provided for @patcherBackupSaved.
  ///
  /// In en, this message translates to:
  /// **'  Originals kept as .cnsbak (restorable).'**
  String get patcherBackupSaved;

  /// No description provided for @patcherLeftUntouched.
  ///
  /// In en, this message translates to:
  /// **'  Left untouched (not safe to patch): {reason}'**
  String patcherLeftUntouched(String reason);

  /// No description provided for @summaryUnfixableContainerIds.
  ///
  /// In en, this message translates to:
  /// **'⚠️ {count} mod(s) share a Container ID but could not be fixed safely (left untouched; they may not appear in CNS):'**
  String summaryUnfixableContainerIds(int count);

  /// No description provided for @revertPatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Revert conflict patches'**
  String get revertPatchesTitle;

  /// No description provided for @revertPatchesDesc.
  ///
  /// In en, this message translates to:
  /// **'Restores the original mod files changed by the Conflict Patcher.'**
  String get revertPatchesDesc;

  /// No description provided for @revertPatchesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Revert conflict patches?'**
  String get revertPatchesConfirmTitle;

  /// No description provided for @revertPatchesConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The original files saved by the Conflict Patcher (.cnsbak) will be restored. Close the game first. Conflicting mods may stop showing up in CNS again.'**
  String get revertPatchesConfirmMessage;

  /// No description provided for @revertPatchesAction.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get revertPatchesAction;

  /// No description provided for @revertPatchesDone.
  ///
  /// In en, this message translates to:
  /// **'Restored {count} file(s).'**
  String revertPatchesDone(int count);

  /// No description provided for @revertPatchesNothing.
  ///
  /// In en, this message translates to:
  /// **'No patched files to revert.'**
  String get revertPatchesNothing;

  /// No description provided for @settingsGroupPaths.
  ///
  /// In en, this message translates to:
  /// **'Paths'**
  String get settingsGroupPaths;

  /// No description provided for @settingsGroupTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get settingsGroupTools;

  /// No description provided for @settingsAutoOutfit.
  ///
  /// In en, this message translates to:
  /// **'Assign outfits automatically'**
  String get settingsAutoOutfit;

  /// No description provided for @settingsAutoOutfitDesc.
  ///
  /// In en, this message translates to:
  /// **'When installing a replacement mod, detect which outfit it replaces by reading its files. If turned off, the outfit is assigned manually.'**
  String get settingsAutoOutfitDesc;

  /// No description provided for @variantChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Several variants of the same replacement'**
  String get variantChoiceTitle;

  /// No description provided for @variantChoiceBodyOutfits.
  ///
  /// In en, this message translates to:
  /// **'\"{mod}\" contains several variants that replace {outfits}. Only one can be active at a time. Which one do you want to install?'**
  String variantChoiceBodyOutfits(String mod, String outfits);

  /// No description provided for @variantChoiceBodyFiles.
  ///
  /// In en, this message translates to:
  /// **'\"{mod}\" contains several variants that replace the same files. Only one can be active at a time. Which one do you want to install?'**
  String variantChoiceBodyFiles(String mod);

  /// No description provided for @variantChoiceInstallAll.
  ///
  /// In en, this message translates to:
  /// **'Install all (as separate mods)'**
  String get variantChoiceInstallAll;

  /// No description provided for @installOutfitConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Outfit already in use'**
  String get installOutfitConflictTitle;

  /// No description provided for @installOutfitConflictBody.
  ///
  /// In en, this message translates to:
  /// **'The mod \"{newMod}\" replaces the outfit {outfits}, which is already assigned to the active mod \"{oldMod}\". Only one can be active at a time. Which one do you want to keep active?'**
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  );

  /// No description provided for @installOutfitKeepCurrent.
  ///
  /// In en, this message translates to:
  /// **'Keep current'**
  String get installOutfitKeepCurrent;

  /// No description provided for @installOutfitUseNew.
  ///
  /// In en, this message translates to:
  /// **'Use new mod'**
  String get installOutfitUseNew;

  /// No description provided for @installOutfitNowActive.
  ///
  /// In en, this message translates to:
  /// **'Now active: {active}'**
  String installOutfitNowActive(String active);

  /// No description provided for @fileLockErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not move the mod'**
  String get fileLockErrorTitle;

  /// No description provided for @fileLockErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Another application may be using the game files (FModel, the game itself, an antivirus, File Explorer...). Close it and try again.'**
  String get fileLockErrorMessage;

  /// No description provided for @nexusProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Nexus Mods profile'**
  String get nexusProfileTooltip;

  /// No description provided for @nexusUserFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get nexusUserFallback;

  /// No description provided for @nexusPlanPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get nexusPlanPremium;

  /// No description provided for @nexusPlanMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get nexusPlanMember;

  /// No description provided for @nexusPlanSupporter.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get nexusPlanSupporter;

  /// No description provided for @nexusApiRequestsRemaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING API REQUESTS'**
  String get nexusApiRequestsRemaining;

  /// No description provided for @nexusApiDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get nexusApiDaily;

  /// No description provided for @nexusApiHourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get nexusApiHourly;

  /// No description provided for @downloadMemberAccountLimit.
  ///
  /// In en, this message translates to:
  /// **'Member accounts are limited to 1.5 MB/s by Nexus Mods'**
  String get downloadMemberAccountLimit;

  /// No description provided for @downloadSupporterAccountLimit.
  ///
  /// In en, this message translates to:
  /// **'Supporter accounts are limited to 3 MB/s by Nexus Mods'**
  String get downloadSupporterAccountLimit;

  /// No description provided for @downloadRetryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get downloadRetryTooltip;

  /// No description provided for @downloadRefreshingLink.
  ///
  /// In en, this message translates to:
  /// **'Refreshing link...'**
  String get downloadRefreshingLink;

  /// No description provided for @downloadNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network.'**
  String get downloadNoInternet;

  /// No description provided for @downloadErrorLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'The Nexus link has expired ({code})'**
  String downloadErrorLinkExpired(int code);

  /// No description provided for @downloadErrorHttp.
  ///
  /// In en, this message translates to:
  /// **'HTTP error: {code}'**
  String downloadErrorHttp(int code);

  /// No description provided for @downloadErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout: no network data received'**
  String get downloadErrorTimeout;

  /// No description provided for @splashRootFolder.
  ///
  /// In en, this message translates to:
  /// **'Root (Main)'**
  String get splashRootFolder;

  /// No description provided for @repairErrorGameNotClosed.
  ///
  /// In en, this message translates to:
  /// **'The game process could not be closed.'**
  String get repairErrorGameNotClosed;

  /// No description provided for @errorManifestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Installation manifest not found. Cannot uninstall.'**
  String get errorManifestNotFound;

  /// No description provided for @downloadResuming.
  ///
  /// In en, this message translates to:
  /// **'Resuming...'**
  String get downloadResuming;

  /// No description provided for @apiKeyPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your Nexus Mods API key'**
  String get apiKeyPromptTitle;

  /// No description provided for @apiKeyPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'No API key was detected. Setting it up is optional, but recommended for convenience: it lets you check for mod updates, download with one click (nxm://) and load covers and info from Nexus Mods.'**
  String get apiKeyPromptMessage;

  /// No description provided for @apiKeyPromptConfigure.
  ///
  /// In en, this message translates to:
  /// **'Set up API key'**
  String get apiKeyPromptConfigure;

  /// No description provided for @apiKeyPromptSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get apiKeyPromptSkip;

  /// No description provided for @apiKeyPromptDontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show this message again'**
  String get apiKeyPromptDontShowAgain;

  /// No description provided for @adjustCoverTooltip.
  ///
  /// In en, this message translates to:
  /// **'Adjust cover'**
  String get adjustCoverTooltip;

  /// No description provided for @noCoverToAdjust.
  ///
  /// In en, this message translates to:
  /// **'This mod has no cover to adjust'**
  String get noCoverToAdjust;

  /// No description provided for @errorAdjustingCoverText.
  ///
  /// In en, this message translates to:
  /// **'Error adjusting the cover: {error}'**
  String errorAdjustingCoverText(Object error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
