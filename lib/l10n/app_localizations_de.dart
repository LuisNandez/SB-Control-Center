// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsGeneral => 'Allgemein';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageDesc => 'Wählen Sie die Anwendungssprache';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsAboutDesc => 'Informationen über die Anwendung';

  @override
  String get settingsRefreshMetadata => 'Metadaten aktualisieren';

  @override
  String get settingsRefreshMetadataDesc =>
      'Prüft deine Mods erneut auf Nexus Mods und ergänzt fehlende Angaben und Bilder';

  @override
  String get metadataRefreshDone => 'Metadaten aktualisiert';

  @override
  String get metadataRefreshNoApiKey =>
      'Gib deinen Nexus-Mods-API-Schlüssel in den Einstellungen ein, um Metadaten zu aktualisieren.';

  @override
  String get settingsPathsAndTools => 'Pfade & Werkzeuge';

  @override
  String get settingsGameFolder => 'Spielordner';

  @override
  String get settingsGameFolderDesc =>
      'Der Stammordner Ihrer Stellar Blade-Installation.';

  @override
  String get settings7zipPath => '7-Zip-Pfad';

  @override
  String get settings7zipPathDesc =>
      'Der Speicherort der Datei 7z.exe zum Extrahieren von Mods.';

  @override
  String get settings7zipPathAuto => 'Automatische Suche';

  @override
  String get settingsRepairMods => 'Legacy-Mods reparieren';

  @override
  String get settingsRepairModsDesc =>
      'Scannt und erstellt Infodateien für alte Mods unter Verwendung der lokalen Datenbank. Erfordert API-Schlüssel.';

  @override
  String get settingsConnectivity => 'Konnektivität & Updates';

  @override
  String get settingsApiKey => 'Nexus Mods API-Schlüssel';

  @override
  String get settingsApiKeyDesc =>
      'Erforderlich, um nach Mod-Updates zu suchen.';

  @override
  String get settingsApiKeySet => 'Gesetzt';

  @override
  String get settingsApiKeyNotSet => 'Nicht gesetzt';

  @override
  String get settingsSkippedVersions => 'Übersprungene Versionen verwalten';

  @override
  String get settingsSkippedVersionsDesc =>
      'Verwalten Sie Mod-Versionen, die Sie übersprungen haben.';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count Versionen übersprungen';
  }

  @override
  String get dialogTitleSkippedVersions => 'Übersprungene Mod-Versionen';

  @override
  String get dialogNoSkippedVersions =>
      'Sie haben keine Mod-Versionen übersprungen.';

  @override
  String get dialogSkippedVersions => 'Übersprungene Version';

  @override
  String get dialogTitleRepairMods => 'Legacy-Mod-Reparatur ausführen?';

  @override
  String get dialogContentRepairMods =>
      'Warnung: Diese Funktion befindet sich in der Entwicklung und ist möglicherweise nicht perfekt.\n\nSie scannt Mods ohne eine \'nexus_info.json\'-Datei und erstellt eine, falls sie in Ihrer lokalen Datenbank gefunden wird. Es wird auch versucht, den Ordner des Mods umzubenennen, um die gefundene Version einzuschließen (z. B. \'Mein Mod\' -> \'Mein Mod v1.2\').\n\nVersionspriorität:\n1. Aus dem Ordnernamen.\n2. Aus dem Beschreibungsfeld des Mods.\n3. Aus der neuesten Version auf Nexus Mods (erfordert API).\n\nMöchten Sie fortfahren?';

  @override
  String get dialogActionRunRepair => 'Reparatur ausführen';

  @override
  String get snackBarGamePathInvalid =>
      'Der ausgewählte Ordner scheint kein gültiger Spielordner zu sein.';

  @override
  String get snackBar7zipPathInvalid =>
      'Die ausgewählte Datei muss den Namen 7z.exe haben.';

  @override
  String get snackBarRepairStarted =>
      'Der Reparaturprozess für Legacy-Mods wurde gestartet...';

  @override
  String snackBarRepairComplete(Object count) {
    return 'Reparatur abgeschlossen. $count Mod(s) wurden aktualisiert.';
  }

  @override
  String get snackBarRepairNoMods =>
      'Es wurden keine Legacy-Mods gefunden, die repariert werden mussten.';

  @override
  String get errorApiRequiredForRepair =>
      'API-Schlüssel ist erforderlich, um die neueste Version für Mods ohne lokale Version zu finden.';

  @override
  String get installNewMod => 'Mod installieren';

  @override
  String get selectFiles => 'Dateien auswählen';

  @override
  String get selectFolder => 'Ordner auswählen';

  @override
  String get installSelectedMod => 'Ausgewählten Mod installieren';

  @override
  String get filesToInstall => 'Zu installierende Dateien:';

  @override
  String get cancelSelection => 'Auswahl abbrechen';

  @override
  String get searchMods => 'Mods suchen...';

  @override
  String get enabledMods => 'Aktivierte Mods';

  @override
  String get disabledMods => 'Deaktivierte Mods';

  @override
  String get refreshList => 'Liste aktualisieren';

  @override
  String get noEnabledMods => 'Keine aktivierten Mods.';

  @override
  String get noDisabledMods => 'Keine deaktivierten Mods.';

  @override
  String get showInFolder => 'Im Ordner anzeigen';

  @override
  String get disableMod => 'Mod deaktivieren';

  @override
  String get enableMod => 'Mod aktivieren';

  @override
  String get deletePermanently => 'Dauerhaft löschen';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get statusSearchingGame =>
      'Suche nach der Installation von Stellar Blade...';

  @override
  String get statusGamePathFound => 'Spielpfad gefunden!';

  @override
  String get statusGamePathNotFound =>
      'Der Spielpfad konnte nicht automatisch gefunden werden.';

  @override
  String statusErrorFindingGame(Object error) {
    return 'Beim Suchen des Spiels ist ein Fehler aufgetreten: $error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount Mod(s) aktiviert, $disabledCount deaktiviert.';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return 'Fehler beim Lesen der installierten Mods: $error';
  }

  @override
  String statusFilesSelected(Object count) {
    return '$count Datei(en) ausgewählt. Bereit zur Installation.';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return 'Ordner \"$folderName\" ausgewählt. Bereit zur Installation.';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return 'Datei \"$fileName\" geladen. $count Datei(en) bereit zur Installation.';
  }

  @override
  String get statusSelectionCancelled =>
      'Auswahl abgebrochen. Wählen Sie einen neuen Mod zur Installation.';

  @override
  String get statusUpdateComplete => 'Update abgeschlossen.';

  @override
  String get statusInstallationComplete => 'Installation abgeschlossen.';

  @override
  String statusError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get dialogTitle7zip => '7-Zip erforderlich';

  @override
  String get dialogContent7zip =>
      'Um diese Datei zu dekomprimieren, benötigt die Anwendung 7-Zip.\n\nBitte installieren Sie es von der offiziellen Seite und drücken Sie dann \"Bestätigen\".';

  @override
  String get dialogContent7zipNotFound =>
      '7-Zip wurde noch nicht erkannt. Bitte stellen Sie sicher, dass es im Standardpfad installiert ist, und versuchen Sie es erneut.';

  @override
  String get dialogTitleMultipleJsons => 'Mehrere .json-Dateien erkannt';

  @override
  String dialogContentMultipleJsons(Object count) {
    return '$count .json-Dateien wurden erkannt. Dies könnte ein Mod mit mehreren Komponenten sein.\n\nMöchten Sie alle zusammen in einem einzigen Mod-Ordner installieren?';
  }

  @override
  String get dialogTitleModExists => 'Mod existiert bereits';

  @override
  String dialogContentModExists(Object modName) {
    return 'Ein Mod mit dem Namen \"$modName\" ist bereits installiert.\n\nMöchten Sie ihn aktualisieren? Alte Dateien werden vor der Installation der neuen gelöscht.';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return 'Eine ältere Version \'$oldModName\' wurde gefunden.\n\nMöchten Sie sie entfernen und auf \'$newModName\' aktualisieren?';
  }

  @override
  String get dialogTitleDeleteMod => 'Dauerhaft löschen?';

  @override
  String dialogContentDeleteMod(Object modName) {
    return 'Sie sind dabei, den Mod \"$modName\" dauerhaft zu löschen. Diese Aktion kann nicht rückgängig gemacht werden.\n\nSind Sie sicher?';
  }

  @override
  String get dialogActionCancel => 'Abbrechen';

  @override
  String get dialogActionGoToDownload => 'Zur Download-Seite';

  @override
  String get dialogActionConfirmInstallation => 'Installation bestätigen';

  @override
  String get dialogActionUpdateSystem => 'System aktualisieren';

  @override
  String get dialogActionInstallAnyway => 'Trotzdem installieren';

  @override
  String get dialogActionDelete => 'Löschen';

  @override
  String get dialogActionClose => 'Schließen';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return 'Stapelinstallation abgeschlossen. Erfolgreich: $successCount, Fehlgeschlagen: $failedCount.';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return 'Mod \"$modName\" erfolgreich installiert.';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return 'Mod \"$modName\" aktiviert.';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return 'Mod \"$modName\" deaktiviert.';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return 'Mod \"$modName\" dauerhaft gelöscht.';
  }

  @override
  String get snackBarCNSUpdated =>
      'Custom Nanosuit System erfolgreich aktualisiert.';

  @override
  String get snackBarApiKeySaved => 'API-Schlüssel erfolgreich gespeichert.';

  @override
  String get snackBarGamePathSaved => 'Spielpfad erfolgreich gespeichert.';

  @override
  String get snackBar7zipPathSaved => '7-Zip-Pfad erfolgreich gespeichert.';

  @override
  String get snackBarSkippedVersionRemoved => 'Übersprungene Version entfernt.';

  @override
  String get dropTargetOverlay => 'Mods hier ablegen';

  @override
  String get pathSelectionTitle => 'Stellar Blade-Pfad nicht gefunden';

  @override
  String get pathSelectionButtonManual => 'Spielordner manuell auswählen';

  @override
  String get pathSelectionButtonRetry => 'Erneut versuchen';

  @override
  String errorFolderSelection(Object error) {
    return 'Fehler bei der Ordnerauswahl: $error';
  }

  @override
  String errorFileSelection(Object error) {
    return 'Fehler bei der Dateiauswahl: $error';
  }

  @override
  String errorDecompressing(Object error) {
    return 'Fehler beim Dekomprimieren der Datei: $error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return 'Fehler beim Verarbeiten der Datei: $error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return 'Nicht unterstütztes Dateiformat: $extension';
  }

  @override
  String get error7zipRequired =>
      'Vorgang abgebrochen: 7-Zip ist erforderlich.';

  @override
  String get errorGamePathUndefined => 'Spielpfad ist nicht definiert.';

  @override
  String get errorDestinationNotFound =>
      'Der Zielordner des Spiels existiert nicht.';

  @override
  String errorUpdateSystem(Object error) {
    return 'Fehler beim Aktualisieren des Systems: $error';
  }

  @override
  String get errorInstallNoSelection =>
      'Sie haben nichts zur Installation ausgewählt.';

  @override
  String get errorInstallModExists =>
      'Installation abgebrochen: Mod existiert bereits.';

  @override
  String get errorNoJsonFound =>
      'Jeder Mod muss mindestens eine .json-Datei enthalten.';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return 'Die Datei $fileName hat ein ungültiges JSON-Format.';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return 'Die Datei $fileName scheint kein Custom Nanosuit System-Mod zu sein (\"DisplayName\" fehlt).';
  }

  @override
  String get errorNoValidDisplayName =>
      'In den .json-Dateien wurde kein gültiger \"DisplayName\" gefunden.';

  @override
  String errorEnableMod(Object error) {
    return 'Fehler beim Aktivieren des Mods: $error';
  }

  @override
  String errorDisableMod(Object error) {
    return 'Fehler beim Deaktivieren des Mods: $error';
  }

  @override
  String errorDeleteMod(Object error) {
    return 'Fehler beim Löschen des Mods: $error';
  }

  @override
  String errorOpenFolder(Object path) {
    return 'Ordner konnte nicht geöffnet werden: $path';
  }

  @override
  String get statusUpdateSystemCancelled => 'Systemupdate abgebrochen.';

  @override
  String get statusUpdatingCNS => 'Custom Nanosuit System wird aktualisiert...';

  @override
  String statusExtractingFile(Object fileName) {
    return 'Extrahiere $fileName...';
  }

  @override
  String get statusInstallationCancelledByUser =>
      'Installation vom Benutzer abgebrochen.';

  @override
  String get errorNoCompatibleFilesInFolder =>
      'Der ausgewählte Ordner enthält keine kompatiblen Mod-Dateien.';

  @override
  String get errorNoCompatibleFilesInArchive =>
      'Die komprimierte Datei enthält keine kompatiblen Mod-Dateien.';

  @override
  String get errorNoJsonInSelection =>
      'Die Auswahl enthält keine gültige Mod-.json-Datei.';

  @override
  String get aboutTitle => 'Über SB Control Center';

  @override
  String get aboutContent =>
      'SB Control Center ist ein Mod-Manager für Stellar Blade. Er installiert, organisiert und aktualisiert deine Mods an einem Ort und arbeitet mit dem Custom Nanosuit System (CNS) für Outfit- und Nanosuit-Mods zusammen.\n\nEr verbindet sich mit Nexus Mods, um Mods herunterzuladen, Updates zu prüfen und den Mods, die du nutzt, ein Endorse zu geben.\n\nEnthält 7-Zip (7-zip.org) zum Entpacken von .zip-, .rar- und .7z-Archiven.';

  @override
  String get aboutEndorseCta =>
      'Gefällt dir die App? Ein Endorse auf Nexus Mods hilft sehr.';

  @override
  String get aboutEndorseThanks => 'Danke für deine Unterstützung!';

  @override
  String get aboutLinkText => 'Besuchen Sie mein Erstellerprofil';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return 'Version: $version';
  }

  @override
  String get openModsFolder => 'Mods-Ordner öffnen';

  @override
  String get openInNexusMods => 'In Nexus Mods öffnen';

  @override
  String get checkForUpdates => 'Nach Updates suchen';

  @override
  String updateAvailable(Object version) {
    return 'Update verfügbar: v$version';
  }

  @override
  String get dialogTitleApiKey => 'Nexus Mods API-Schlüssel';

  @override
  String get dialogContentApiKey =>
      'Um nach Mod-Updates zu suchen, benötigen Sie einen persönlichen API-Schlüssel von Nexus Mods.';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. Klicken Sie unten auf die Schaltfläche, um Nexus Mods zu öffnen, und melden Sie sich an.\n2. Scrollen Sie ans Ende der Seite zum Abschnitt \'Personal API Key\'.\n3. Fordern Sie ihn an, falls Sie noch keinen haben, und kopieren Sie ihn.\n4. Fügen Sie ihn hier ein.';

  @override
  String get apiKeyOpenNexusPage => 'API-Schlüssel-Seite öffnen';

  @override
  String get apiKey => 'API-Schlüssel';

  @override
  String get apiKeyHintText => 'Fügen Sie Ihren API-Schlüssel hier ein';

  @override
  String get dialogActionSave => 'Speichern';

  @override
  String get apiKeyRemoved => 'API-Schlüssel entfernt.';

  @override
  String get invalidApiKeyError => 'Ungültiger API-Schlüssel.';

  @override
  String get validatingApiKey => 'Wird validiert...';

  @override
  String get errorApiKeyMissing =>
      'Der Nexus Mods API-Schlüssel fehlt. Fügen Sie ihn unter Einstellungen › Konnektivität & Updates › Nexus Mods API-Schlüssel hinzu.';

  @override
  String get statusCheckingUpdates => 'Suche nach Mod-Updates...';

  @override
  String statusUpdatesFound(Object count) {
    return '$count Update(s) gefunden!';
  }

  @override
  String get statusNoUpdates => 'Alle Mods sind auf dem neuesten Stand.';

  @override
  String get selectModArchive => 'Mod-Archiv auswählen';

  @override
  String get viewImageGallery => 'Bildergalerie anzeigen';

  @override
  String get imageGallery => 'Bildergalerie';

  @override
  String get noImagesFound =>
      'Für diesen Mod wurden keine Bilder gefunden, oder der API-Schlüssel wurde nicht eingegeben. Bitte geben Sie den API-Schlüssel ein und suchen Sie anschließend nach Updates.';

  @override
  String errorFetchingImages(Object error) {
    return 'Fehler beim Abrufen der Bilder: $error';
  }

  @override
  String get imageMod => 'Mod-Bild';

  @override
  String get modEnabledBadge => 'Aktiviert';

  @override
  String get modDisabledBadge => 'Deaktiviert';

  @override
  String get modCategoryOther => 'Nicht angegeben';

  @override
  String get dialogContentUpdateOptions => 'Was möchten Sie tun?';

  @override
  String get dialogActionIgnoreVersion => 'Ignorieren';

  @override
  String get dialogActionSkipVersion => 'Version überspringen';

  @override
  String get dialogActionGoToDownloadPage => 'Zum Download gehen';

  @override
  String get installedMods => 'Installierte Mods';

  @override
  String get filterBy => 'Filtern nach:';

  @override
  String get sortBy => 'Sortieren nach:';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterEnabled => 'Aktiviert';

  @override
  String get filterDisabled => 'Deaktiviert';

  @override
  String get filterRepaired => 'Repariert';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByDate => 'Datum';

  @override
  String get noModsFound => 'Keine Mods gefunden.';

  @override
  String get viewTypeGrid => 'Rasteransicht';

  @override
  String get viewTypeList => 'Listenansicht';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return 'Extrahiere $count von $total: $fileName';
  }

  @override
  String get previewInstallTitle => 'Zu installierende Mods:';

  @override
  String get dialogTitleUE4SS => 'UE4SS-Installation erkannt';

  @override
  String get dialogContentUE4SS =>
      'Das UE4SS-Tool wurde erkannt. Möchten Sie es in \'StellarBlade\\SB\\Binaries\\Win64\' installieren?\n\nDies ist für die Funktion vieler Mods erforderlich.';

  @override
  String get dialogActionInstallTool => 'Tool installieren';

  @override
  String get statusUE4SSInstallCancelled => 'UE4SS-Installation abgebrochen.';

  @override
  String get statusInstallingUE4SS => 'Installiere UE4SS...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SS erfolgreich installiert.';

  @override
  String error7zipDecompression(Object error) {
    return '7-Zip-Fehler bei der Dekomprimierung: $error';
  }

  @override
  String get statusUE4SSInstallComplete => 'UE4SS-Installation abgeschlossen.';

  @override
  String get dialogTitleAlternativeVersion => 'Alternative Version erkannt';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return 'Eine alternative Version dieses Mods ist bereits installiert: \'$oldModName\'.\n\nSie sind dabei, eine andere Alternative mit dem Namen \'$newModName\' zu installieren.';
  }

  @override
  String get dialogActionReplace => 'Ersetzen';

  @override
  String get dialogActionInstallAsNew => 'Als neu installieren';

  @override
  String get dialogTitleUpdate => 'Update verfügbar';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Sie sind dabei, den Mod \'$modName\' zu aktualisieren.\n\nInstallierte Version: $oldVersion\nNeue Version: $newVersion';
  }

  @override
  String get dialogTitleDowngrade => 'Ältere Version erkannt';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Warnung: Sie sind dabei, eine ältere Version des Mods \'$modName\' zu installieren.\n\nInstallierte Version: $oldVersion\nZu installierende Version: $newVersion';
  }

  @override
  String get dialogTitleReinstall => 'Mod neu installieren';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return 'Sie sind dabei, Version \'$version\' des Mods \'$modName\' neu zu installieren.';
  }

  @override
  String get dialogActionReinstall => 'Neu installieren';

  @override
  String get editModNameTooltip => 'Mod-Namen bearbeiten';

  @override
  String get setCoverTooltip => 'Benutzerdefiniertes Coverbild festlegen';

  @override
  String get setCoverText => 'Cover festlegen';

  @override
  String get restoreOriginalCoverText => 'Original-Cover wiederherstellen';

  @override
  String errorSavingCoverText(Object error) {
    return 'Fehler beim Speichern des Coverbildes: $error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return 'Fehler beim Wiederherstellen des Original-Coverbildes: $error';
  }

  @override
  String get editVersionText => 'Version bearbeiten';

  @override
  String get customVersionText => 'Benutzerdefinierte Version';

  @override
  String get editTagText => 'Tag bearbeiten';

  @override
  String get customTagText => 'Benutzerdefinierter Tag';

  @override
  String get dialogTitleEditModName => 'Mod-Namen bearbeiten';

  @override
  String get dialogActionResetToDefault => 'Auf Standard zurücksetzen';

  @override
  String get dialogLabelNewName => 'Neuer Name';

  @override
  String errorModNameExists(Object modName) {
    return 'Ein Mod mit dem Namen \"$modName\" existiert bereits.';
  }

  @override
  String get dialogTitleRepairedModWarning => 'Warnung bei repariertem Mod';

  @override
  String get dialogContentRepairedModWarning =>
      'Dieser Mod hat möglicherweise nicht die korrekten Versionsinformationen. Es wird empfohlen, die neueste Version neu zu installieren, um die Kompatibilität sicherzustellen.';

  @override
  String get repairedModTooltip => 'Informationen über reparierten Mod';

  @override
  String get disableAllModsTooltip => 'Alle Mods deaktivieren';

  @override
  String get deleteAllModsTooltip => 'Alle deaktivierten Mods löschen';

  @override
  String get dialogTitleDisableAll => 'Alle Mods deaktivieren?';

  @override
  String dialogContentDisableAll(int count) {
    return 'Sind Sie sicher, dass Sie alle $count aktivierten Mods deaktivieren möchten? Sie werden in den Backup-Ordner verschoben.';
  }

  @override
  String get dialogTitleDeleteAll => 'Deaktivierte Mods löschen?';

  @override
  String dialogContentDeleteAll(int count) {
    return 'Sie sind dabei, alle $count deaktivierten Mods dauerhaft zu löschen. Diese Aktion kann nicht rückgängig gemacht werden.\n\nSind Sie sicher?';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return 'Alle $count aktivierten Mods wurden deaktiviert.';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return 'Alle $count deaktivierten Mods wurden dauerhaft gelöscht.';
  }

  @override
  String get snackBarNoModsToDisable =>
      'Es gibt keine aktivierten Mods zum Deaktivieren.';

  @override
  String get snackBarNoModsToDelete =>
      'Es gibt keine deaktivierten Mods zum Löschen.';

  @override
  String get enableAllModsTooltip => 'Alle Mods aktivieren';

  @override
  String get dialogTitleEnableAll => 'Alle Mods aktivieren?';

  @override
  String dialogContentEnableAll(int count) {
    return 'Sind Sie sicher, dass Sie alle $count deaktivierten Mods aktivieren möchten? Sie werden in den Haupt-Mods-Ordner verschoben.';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return 'Alle $count deaktivierten Mods wurden aktiviert.';
  }

  @override
  String get snackBarNoModsToEnable =>
      'Es gibt keine deaktivierten Mods zum Aktivieren.';

  @override
  String get editNotes => 'Notizen bearbeiten';

  @override
  String get notesHintText =>
      'Fügen Sie hier Ihre persönlichen Notizen hinzu...';

  @override
  String get modAuthor => 'Autor';

  @override
  String get modSummary => 'Zusammenfassung';

  @override
  String get modDescription => 'Beschreibung';

  @override
  String get noDescriptionAvailable => 'Keine Beschreibung verfügbar.';

  @override
  String get personalNotes => 'Persönliche Notizen';

  @override
  String get noNotesAvailable => 'Noch keine Notizen hinzugefügt.';

  @override
  String get modDetailsTitle => 'Mod-Details';

  @override
  String get modVersion => 'Version';

  @override
  String get modCategory => 'Kategorie';

  @override
  String get dialogTitleAddUrl => 'Mod-Link hinzufügen';

  @override
  String get dialogLabelUrl => 'Mod-URL';

  @override
  String get errorInvalidUrl => 'Bitte geben Sie eine gültige URL ein.';

  @override
  String get addLinkTooltip => 'Einen Download-Link für diesen Mod hinzufügen';

  @override
  String get addLinkButtonText => 'Link hinzufügen';

  @override
  String get openLinkButtonText => 'Link öffnen';

  @override
  String get editModTitle => 'Mod-Details bearbeiten';

  @override
  String get modNameLabel => 'Mod-Name';

  @override
  String get authorLabel => 'Autor';

  @override
  String get summaryLabel => 'Beschreibung / Zusammenfassung';

  @override
  String get notesLabel => 'Persönliche Notizen';

  @override
  String get urlLabel => 'Download-URL';

  @override
  String get changeCoverButton => 'Coverbild ändern';

  @override
  String get editButtonTooltip => 'Mod bearbeiten';

  @override
  String get errorSavingNotes => 'Fehler beim Speichern der Notizen';

  @override
  String get errorSavingUrl => 'Fehler beim Speichern der URL';

  @override
  String get errorSavingChanges => 'Fehler beim Speichern der Änderungen';

  @override
  String get errorTranslation => 'Beschreibung konnte nicht übersetzt werden';

  @override
  String get translateSummary => 'Zusammenfassung übersetzen';

  @override
  String get translateDescription => 'Beschreibung übersetzen';

  @override
  String get restoreOriginalDescription =>
      'Originalbeschreibung wiederherstellen';

  @override
  String get dialogTitleUE4SSReinstall => 'UE4SS neu installieren';

  @override
  String get dialogContentUE4SSReinstall =>
      'UE4SS scheint bereits installiert zu sein. Möchten Sie die vorhandene Installation überschreiben? Dies kann nützlich sein, wenn Sie beschädigte Dateien vermuten.';

  @override
  String get dialogTitleCNSReinstall => 'CNS-System neu installieren';

  @override
  String get dialogContentCNSReinstall =>
      'Das Haupt-CNS-System scheint bereits installiert zu sein. Möchten Sie es neu installieren? Ihre vorhandenen Mods bleiben davon unberührt.';

  @override
  String dialogTitleUninstall(Object componentName) {
    return '$componentName deinstallieren';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return 'Sind Sie sicher, dass Sie $componentName deinstallieren möchten? Diese Aktion entfernt die Kerndateien der Komponente, hat aber keine Auswirkungen auf Ihre installierten Mods.';
  }

  @override
  String get dialogActionUninstall => 'Ja, deinstallieren';

  @override
  String statusUninstalling(Object componentName) {
    return 'Deinstalliere $componentName...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentName erfolgreich deinstalliert';
  }

  @override
  String errorUninstalling(Object componentName) {
    return 'Fehler beim Deinstallieren von $componentName';
  }

  @override
  String get settingsCoreComponents => 'Kernkomponenten';

  @override
  String get installedStatus => 'Installiert';

  @override
  String get notInstalledStatus => 'Nicht erkannt';

  @override
  String get uninstallButton => 'Deinstallieren';

  @override
  String get cnsCoreSystem => 'Custom Nanosuit System';

  @override
  String get ue4ssInstallationDetected =>
      'Bestehende UE4SS-Installation erkannt und übernommen';

  @override
  String get cnsInstallationDetected =>
      'Bestehende Haupt-CNS-Installation erkannt und übernommen';

  @override
  String get ue4ssRequiredTitle => 'UE4SS erforderlich';

  @override
  String get ue4ssRequiredContent =>
      'Um das Haupt-CNS-System zu installieren, müssen Sie zuerst UE4SS installieren. Sie können es unter folgendem Link herunterladen:';

  @override
  String get uninstallDependencyTitle => 'Abhängigkeit erkannt';

  @override
  String get uninstallDependencyContent =>
      'Sie müssen das Haupt-CNS-System deinstallieren, bevor Sie UE4SS deinstallieren können, da CNS davon abhängt.';

  @override
  String get dialogActionUnderstood => 'Verstanden';

  @override
  String get appTitleNoCns => 'Custom Nanosuit System (Nicht installiert)';

  @override
  String get dialogTitleCNSUpdate => 'Haupt-CNS-System aktualisieren';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return 'Sie sind dabei, CNS von Version $oldVersion auf die neue Version $newVersion zu aktualisieren. Möchten Sie fortfahren?';
  }

  @override
  String get dialogTitleCNSDowngrade => 'CNS-Version herabstufen';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return 'Warnung! Sie sind dabei, eine ältere Version von CNS ($newVersion) als Ihre aktuelle ($oldVersion) zu installieren. Dies kann zu Problemen führen. Sind Sie sicher?';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return 'Sie haben bereits Version $version von CNS installiert. Möchten Sie die Dateien trotzdem neu installieren?';
  }

  @override
  String get dialogActionUpdate => 'Aktualisieren';

  @override
  String get dialogActionDowngrade => 'Herabstufen';

  @override
  String get dialogTitleCNSInstall => 'Haupt-CNS-System installieren';

  @override
  String get dialogContentCNSInstall =>
      'Sie sind dabei, das Basissystem Custom Nanosuit System (CNS) zu installieren. Dies ist erforderlich, damit CNS-Mods funktionieren. Möchten Sie fortfahren?';

  @override
  String get dialogActionInstall => 'Installieren';

  @override
  String get settingsDeveloperOptions => 'Entwickleroptionen';

  @override
  String get devDeleteNexusInfoTitle => 'Alle nexus_info.json-Dateien löschen';

  @override
  String get devDeleteNexusInfoDesc =>
      'Entfernt alle Metadatendateien des Managers von jedem Mod. Dies ist nützlich, um eine vollständige Reparatur zu erzwingen.';

  @override
  String get devExtractIdsTitle => 'Identifikatoren extrahieren';

  @override
  String get devExtractIdsDesc =>
      'Erstellt auf Ihrem Desktop eine Datei mit dem Namen \'ID Mods.json\', die den displayName und die nexusId jedes Mods enthält.';

  @override
  String get devConfirmDeleteTitle => 'Löschung bestätigen';

  @override
  String get devConfirmDeleteDesc =>
      'Sind Sie sicher, dass Sie alle nexus_info.json-Dateien dauerhaft löschen möchten? Dadurch werden alle benutzerdefinierten Namen, Cover und Metadaten entfernt. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get devDeleteSuccessTitle => 'Löschung abgeschlossen';

  @override
  String devDeleteSuccessDesc(Object count) {
    return 'Erfolgreich $count nexus_info.json-Dateien gelöscht.';
  }

  @override
  String get devConfirmExtractTitle => 'Extraktion bestätigen';

  @override
  String get devConfirmExtractDesc =>
      'Dies scannt alle Ihre Mods und erstellt \'ID Mods.json\' auf Ihrem Desktop. Dadurch wird jede vorhandene Datei mit demselben Namen überschrieben. Möchten Sie fortfahren?';

  @override
  String get devExtractAction => 'Extrahieren';

  @override
  String get devTestSelfUpdateTitle => 'Selbst-Update testen';

  @override
  String get devTestSelfUpdateDesc =>
      'Wählen Sie das .zip-Paket der App aus und installieren Sie es über diese App – genau so, wie es das automatische Update tun wird.';

  @override
  String get devSelfUpdateUnsupported =>
      'Das Selbst-Update ist nur unter Windows verfügbar.';

  @override
  String get devSelfUpdatePickTitle =>
      'Wählen Sie die .zip-Datei von SB Control Center aus';

  @override
  String get devSelfUpdateFailed =>
      'Das Update konnte nicht installiert werden';

  @override
  String get devSelfUpdateDryRunTitle => 'Paket ist gültig (Testmodus)';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return '$count Dateien gefunden. Es wurde nicht installiert, da dies kein Release-Build ist.';
  }

  @override
  String get devSelfUpdateConfirmTitle => 'Update installieren?';

  @override
  String get devSelfUpdateConfirmDesc =>
      'Die App wird geschlossen, ersetzt ihre Dateien durch die Dateien aus dem Paket und öffnet sich automatisch erneut.';

  @override
  String get devSelfUpdateInstallAction => 'Installieren und neu starten';

  @override
  String get devSelfUpdateProgressTitle =>
      'SB Control Center wird aktualisiert';

  @override
  String get devSelfUpdateExtracting => 'Paket wird extrahiert…';

  @override
  String get devSelfUpdateInstalling => 'Dateien werden installiert…';

  @override
  String get devSelfUpdateRestarting => 'Neustart…';

  @override
  String get devExtractNoData =>
      'Es wurden keine Mods mit gültigen Identifikatoren zum Extrahieren gefunden.';

  @override
  String get devExtractDesktopNotFound =>
      'Fehler: Das Desktop-Verzeichnis konnte nicht gefunden werden.';

  @override
  String get devExtractSuccessTitle => 'Extraktion abgeschlossen';

  @override
  String devExtractSuccessDesc(Object path) {
    return 'Datei erfolgreich erstellt unter: $path';
  }

  @override
  String get errorDialogTitle => 'Ein Fehler ist aufgetreten';

  @override
  String get modDetailsCategory => 'Kategorie';

  @override
  String get modDetailsAuthor => 'Autor';

  @override
  String get modDetailsNexusId => 'Nexus-ID';

  @override
  String get modDetailsInstalledOn => 'Installiert am';

  @override
  String get unknownAuthor => 'Unbekannt';

  @override
  String get statusInstalling => 'Installiere...';

  @override
  String statusInstallingMod(int index, int total, String modName) {
    return 'Installiere $index/$total: $modName';
  }

  @override
  String byText(Object author) {
    return 'von $author';
  }

  @override
  String get filterUpdatesAvailable => 'Updates verfügbar';

  @override
  String snackBarUpdateIgnored(String modName) {
    return 'Update für \'$modName\' für diese Sitzung ignoriert.';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return 'Version \'$version\' von \'$modName\' wird bei zukünftigen Prüfungen übersprungen.';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return 'Metadaten für \'$displayName\' werden aktualisiert ($arg1 von $arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return 'Allgemeiner Mod installiert: $modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return 'Installiert in $path.\nDieser Mod wird nicht von der App verwaltet und muss manuell deinstalliert werden.';
  }

  @override
  String genericModInstallError(String modName) {
    return 'Installation des allgemeinen Mods fehlgeschlagen: $modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => 'Allgemein';

  @override
  String get modTypeMovies => 'Filme';

  @override
  String get modTypeSave => 'Speichern';

  @override
  String get modTypeConfig => 'Konfiguration';

  @override
  String get modTypeSplash => 'Splash';

  @override
  String get replacesOutfitTitle => 'Ersetzt Outfit';

  @override
  String get replacesOutfitClearTooltip => 'Outfit-Auswahl löschen';

  @override
  String get replacesOutfitSelectTooltip => 'Zu ersetzendes Outfit auswählen';

  @override
  String get replacesOutfitNone =>
      'Kein Outfit ausgewählt.\nDer Tag wird \'Allgemein\' sein.';

  @override
  String get replacesOutfitSearchHint => 'Outfits suchen...';

  @override
  String get modTypeReplacement => 'Ersatz';

  @override
  String get replacesOutfitHover =>
      'Fahren Sie mit der Maus über ein Outfit, um eine Vorschau anzuzeigen.';

  @override
  String get dialogTitleOutfitReplacement => 'Outfit-Ersatz?';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return 'Ist der Mod \'$modName\' ein Outfit-Ersatz?\n\nWählen Sie \'Ja\', um auszuwählen, welches Outfit er ersetzt, oder \'Nein\', um ihn als allgemeinen Mod zu installieren.';
  }

  @override
  String get dialogActionNo => 'Nein';

  @override
  String get dialogActionYes => 'Ja';

  @override
  String get dialogTitleOutfitConflict => 'Outfit-Konflikt erkannt';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return 'Das Outfit \'$outfitName\' wird bereits durch den Mod \'$modName\' ersetzt.\n\nMöchten Sie \'$modName\' deaktivieren und stattdessen diesen aktivieren?';
  }

  @override
  String get dialogActionActivateAndDisable => 'Deaktivieren und Aktivieren';

  @override
  String get replacementModSwitchTitle => 'Ersatz-Mod';

  @override
  String get replacementModSwitchDesc =>
      'Aktivieren Sie diese Option, wenn dieser Mod dazu dient, einen Anzug im Spiel zu ersetzen.';

  @override
  String get settingsShowModTagsTitle => 'Mod-Typ-Tags anzeigen';

  @override
  String get settingsShowModTagsDesc =>
      'Zeigt Mod-Typ-Tags (z. B. CNS, Allgemein) auf jeder Mod-Karte in der Liste an.';

  @override
  String get modTypeLogic => 'Logik';

  @override
  String get patcherStarted => '=== StellarBlade Dart Patcher Gestartet ===';

  @override
  String workingDirectory(String path) {
    return 'Arbeitsverzeichnis: $path';
  }

  @override
  String modsDirNotFound(String path) {
    return 'Das ~mods-Verzeichnis existiert nicht unter: $path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  WARNUNG: Ordner $path konnte nicht gescannt werden. Wird übersprungen.';
  }

  @override
  String errorDetails(String error) {
    return '  Fehler: $error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return '$count .utoc-Dateien gefunden';
  }

  @override
  String get noModsFound2 => 'Keine zu verarbeitenden Mods gefunden.';

  @override
  String get patcherSummaryTitle =>
      '\n=== Patcher-Zusammenfassung (Rohdaten) ===';

  @override
  String processedMods(int count) {
    return '$count Mods verarbeitet.';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return '$count Container-ID-Konflikte behoben.';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return '$count Package-ID-Konflikte gefunden.';
  }

  @override
  String get fatalErrorTitle => '\n=== SCHWERWIEGENDER FEHLER ===';

  @override
  String patcherServiceError(String error) {
    return 'Fehler in PatcherService: $error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- Analysiere: $fileName ---';
  }

  @override
  String get warnUcasNotFound =>
      '  WARNUNG: .ucas-Datei nicht gefunden. Wird übersprungen.';

  @override
  String get warnCorruptHeader =>
      '  WARNUNG: Beschädigter Header, Eintragsgröße überschreitet Dateigröße. Wird übersprungen.';

  @override
  String conflictContainerIdDetected(int id) {
    return '  Container-ID-KONFLIKT erkannt: $id';
  }

  @override
  String generatingNewId(int id) {
    return '  Generiere neue ID: $id';
  }

  @override
  String get utocFilePatched => '  .utoc-Datei gepatcht.';

  @override
  String get patchingUcasFile => '  Patche .ucas-Datei...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  Erfolgreiche Ersetzungen in .ucas: $count';
  }

  @override
  String get patchComplete => '  Patch abgeschlossen!';

  @override
  String idRegisteredNoConflict(int id) {
    return '  ID $id registriert. Keine Konflikte.';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  FEHLER beim Verarbeiten von $fileName: $error';
  }

  @override
  String get statusRunningPatcher => 'Konflikt-Patcher wird ausgeführt...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ Erfolg! $count absturzverursachende Container-ID-Konflikte wurden behoben.';
  }

  @override
  String get summaryNoContainerIdConflicts =>
      '✅ Es wurden keine Container-ID-Konflikte (Absturz) gefunden.';

  @override
  String get summaryNoPackageIdConflicts =>
      '✅ Gute Nachrichten! Es wurden keine schwerwiegenden Package-ID-Konflikte (Überschreiben) gefunden.';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ Warnung! $count Gruppen von Mods gefunden, die nicht koexistieren können:';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • Diese Mod-Gruppe konkurriert um $count Dateien:';
  }

  @override
  String get patcherSummaryDialogTitle => 'Patcher-Zusammenfassung';

  @override
  String get dialogActionShowFullLog => 'Vollständiges Protokoll anzeigen';

  @override
  String get fullLogDialogTitle => 'Konflikt-Patcher-Protokoll (Dart)';

  @override
  String get runConflictPatcherTitle => 'Konflikt-Patcher ausführen';

  @override
  String get runConflictPatcherSubtitlePython =>
      'Behebt Container_Id- und Package_Id-Abstürze';

  @override
  String get processingCover => 'Cover wird verarbeitet...';

  @override
  String get apiKeyTooltip =>
      'API-Schlüssel ist für die intelligente Nexus-ID-Extraktion erforderlich.';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return 'Installationsoptionen - Mod $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection =>
      'Wählen Sie die Optionen aus, die Sie installieren möchten. Die erforderlichen Hauptdateien werden automatisch installiert.';

  @override
  String get snackBarSpecialModNoSelection =>
      'Wählen Sie mindestens eine Option aus, um fortzufahren.';

  @override
  String get dialogActionInstallSelection => 'Auswahl installieren';

  @override
  String get downloadStatusFetching => 'Nexus Mods Daten werden abgerufen...';

  @override
  String get downloadStatusFetchingFailed =>
      'Download-Link konnte nicht abgerufen werden. Überprüfen Sie Ihren API-Schlüssel oder Ihre Verbindung.';

  @override
  String downloadStatusDownloading(String fileName) {
    return 'Lade $fileName herunter';
  }

  @override
  String get downloadStatusError => 'Fehler beim Herunterladen der Datei.';

  @override
  String downloadStatusException(String error) {
    return 'Ausnahme: $error';
  }

  @override
  String get dialogTitleDownloadModManager => 'Mod Manager Download';

  @override
  String get launchGameText => 'Stellar Blade starten';

  @override
  String get stopGameText => 'Stellar Blade beenden';

  @override
  String get dialogTitleStopGame => 'Stellar Blade beenden?';

  @override
  String get dialogContentStopGame =>
      'Das Spiel wird geschlossen. Nicht gespeicherter Fortschritt geht verloren.';

  @override
  String get dialogActionStopGame => 'Beenden';

  @override
  String get notificationGameStopped => 'Stellar Blade beendet';

  @override
  String get errorStoppingGame => 'Das Spiel konnte nicht beendet werden';

  @override
  String get mod801DialogTitle => 'Steam-Konfiguration erforderlich';

  @override
  String get mod801DialogIntro =>
      'Die Random Splash-Mod wurde installiert. Damit sie beim Spielstart automatisch funktioniert, musst du Steam konfigurieren.';

  @override
  String get mod801Step1 =>
      '1. Generiere unten den genauen Pfad für deinen PC und kopiere ihn.';

  @override
  String get mod801Step2 => '2. Öffne deine Steam-Bibliothek.';

  @override
  String get mod801Step3 =>
      '3. Mache einen Rechtsklick auf Stellar Blade -> Eigenschaften.';

  @override
  String get mod801Step4 =>
      '4. Füge den Code im Reiter \'Allgemein\' unter \'Startoptionen\' ein.';

  @override
  String get mod801BtnGenerate => 'Pfad generieren';

  @override
  String get mod801BtnSteam => 'Steam öffnen';

  @override
  String get mod801BtnCopy => 'Kopieren';

  @override
  String get mod801PathGenerated => 'Pfad erfolgreich generiert.';

  @override
  String get mod801PathCopied => 'Befehl in die Zwischenablage kopiert!';

  @override
  String get statusVerifyingMods => 'Integrität der Mods wird überprüft...';

  @override
  String errorSelecting7Zip(String error) {
    return 'Fehler bei der Auswahl von 7-Zip: $error';
  }

  @override
  String get errorInvalidFolderRetry =>
      'Der ausgewählte Ordner scheint nicht korrekt zu sein. Bitte versuche es erneut.';

  @override
  String errorSelectingFolderDynamic(String error) {
    return 'Fehler bei der Ordnerauswahl: $error';
  }

  @override
  String get statusNoNewModsInstalled =>
      'Die Installation hat keine neuen Mods hervorgebracht.';

  @override
  String get errorDisableModBeforeDelete =>
      'Bitte deaktiviere die Mod, bevor du sie löschst.';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return 'Aktiviert: $successCount (Übersprungen: $skippedCount wegen Konflikten)';
  }

  @override
  String get snackBarDeveloperModeEnabled => 'Entwicklermodus aktiviert!';

  @override
  String errorRenamingMod(String error) {
    return 'Fehler beim Umbenennen der Mod: $error';
  }

  @override
  String get notificationTitleError => 'Fehler';

  @override
  String get errorGamePathNotFoundNotification => 'Spielpfad nicht gefunden.';

  @override
  String get notificationLaunchingGame => 'Stellar Blade wird gestartet...';

  @override
  String get errorLaunchingGame => 'Fehler beim Starten des Spiels';

  @override
  String get dialogTitleSelect7zip => 'Wähle die Datei 7z.exe aus';

  @override
  String get dialogTitleSelectGameFolder =>
      'Bitte wähle den Hauptordner von StellarBlade aus';

  @override
  String get dialogTitleSelectCover => 'Wähle ein Cover für die Mod aus';

  @override
  String get errorGamePathNotFoundException => 'Spielpfad nicht gefunden.';

  @override
  String get errorGamePathNotDefined => 'Der Spielpfad ist nicht definiert.';

  @override
  String get errorLogicModsPathNotDefined =>
      'Der Pfad für Logic-Mods ist nicht definiert.';

  @override
  String get errorUe4ssModsPathNotDefined =>
      'Der Pfad für UE4SS-Mods ist nicht definiert.';

  @override
  String get errorGenericModsPathNotDefined =>
      'Der Pfad für generische Mods (~mods) ist nicht definiert.';

  @override
  String get errorReplaceNoOldVersion =>
      'Es wurde versucht, eine Mod zu ersetzen, aber es wurde keine alte Version gefunden.';

  @override
  String errorDeleteOldModVersion(String modName) {
    return 'Die alte Version der Mod ($modName) konnte nicht gelöscht werden.';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return 'Die vorhandene Mod ($modName) konnte zur Neuinstallation nicht gelöscht werden.';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return 'Die vorhandene Mod ($modName) konnte nach mehreren Versuchen nicht zur Neuinstallation gelöscht werden.';
  }

  @override
  String get errorMoviesModNoValidFiles =>
      'Die Film-Mod enthält keine gültigen Videodateien.';

  @override
  String get errorInstallPathUndetermined =>
      'Der Installationspfad konnte nicht ermittelt werden.';

  @override
  String get errorMoviesPathsNotDefined =>
      'Die Filmpfade sind nicht definiert.';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return 'nexus_info.json für $modName nicht gefunden.';
  }

  @override
  String get errorMenuVideoLimitReached =>
      'Das Limit von 99 Menüvideos wurde erreicht.';

  @override
  String get errorModRequires529 =>
      'Die Mod benötigt die Mod-ID 529, um zu funktionieren (enthält nur WebM-Dateien).';

  @override
  String get errorSplashPathsNotDefined =>
      'Die Splash-Pfade sind nicht definiert.';

  @override
  String get errorSplashNoValidImages =>
      'In der Mod wurden keine gültigen Bilder gefunden.';

  @override
  String get errorCouldNotDeleteDirectory =>
      'Das Verzeichnis konnte nicht gelöscht werden.';

  @override
  String get errorGameExeNotFound =>
      'Die ausführbare Datei (.exe) des Spiels wurde weder im Hauptordner noch in Binaries gefunden.';

  @override
  String get dialogTitleSplashOptions => 'Splash-Optionen (Bilder)';

  @override
  String get dialogContentSplashOptions =>
      'Wähle die Bilder aus, die du installieren möchtest. Du kannst ganze Ordner (Stapel) oder einzelne Bilder auswählen.';

  @override
  String get snackBarSplashNoSelection =>
      'Bitte wähle mindestens ein Bild aus.';

  @override
  String get dialogContentSpecialModSingleSelection =>
      'Wähle eine einzige Option zur Installation aus.';

  @override
  String get activeDownloads => 'Aktive Downloads';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mods',
      one: 'Mod',
    );
    return 'Lade $count $_temp0 herunter';
  }

  @override
  String get downloadError => 'Fehler';

  @override
  String get downloadCancelled => 'Abgebrochen';

  @override
  String get downloadPause => 'Pausieren';

  @override
  String get downloadResume => 'Fortsetzen';

  @override
  String get downloadCancel => 'Abbrechen';

  @override
  String get errorNexusInfoNotFound => 'nexus_info.json nicht gefunden.';

  @override
  String logFixingCorruptedJson(String displayName) {
    return 'Beschädigte nexus_info.json für $displayName wird repariert.';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return 'Fehler beim Aktualisieren der Metadaten für $displayName: $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return 'Film-Mod wird aufgrund der Aktivierung von Mod 529 vorsorglich deaktiviert: $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return 'Splash-Mod wird aufgrund der Aktivierung von Mod 801 vorsorglich deaktiviert: $modName';
  }

  @override
  String logRestoringTildeComponent(String folderName) {
    return '~mods-Komponente wird wiederhergestellt: $folderName';
  }

  @override
  String logRestoringUe4ssComponent(String folderName) {
    return 'UE4SS-Komponente wird wiederhergestellt: $folderName';
  }

  @override
  String logErrorRestoringLogicMod(String error) {
    return 'Fehler beim Wiederherstellen der LogicMod-Komponenten: $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return '~mods-Komponente wird archiviert: $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return 'UE4SS-Komponente wird archiviert: $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return 'Fehler beim Archivieren der LogicMod-Komponenten: $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return 'Überspringe $modName: Eine aktive Variante dieser Mod existiert bereits.';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return 'Überspringe $modName: Konflikt mit einem bereits belegten Outfit.';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return 'Videobackups für $modName konnten nicht bereinigt werden: $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return 'Neue Nexus-ID $nexusId erkannt. Metadaten werden abgerufen...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return 'Metadaten für $nexusId abgerufen und angewendet.';
  }

  @override
  String logFallbackByteCopy(String error) {
    return 'Normaler Kopiervorgang fehlgeschlagen, nutze Byte-Brute-Force: $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return 'Warnung: Geänderte Datei konnte nicht gelöscht werden: $error';
  }

  @override
  String get logMod801BatPatched =>
      'Mod 801 .bat-Skript erfolgreich für dieses System gepatcht.';

  @override
  String logMod801BatPatchError(String error) {
    return 'Fehler beim Versuch, die Mod 801 .bat-Datei zu patchen: $error';
  }

  @override
  String get errorHomeDirNotFound =>
      'Die Umgebungsvariable für das Home-Verzeichnis konnte nicht gefunden werden.';

  @override
  String get downloadFetchingPlaceholder => 'Wird abgerufen...';

  @override
  String get downloadErrorLink => 'Download-Link konnte nicht abgerufen werden';

  @override
  String get downloadErrorGeneral => 'Download fehlgeschlagen';

  @override
  String get downloadPausedStatus => 'Pausiert';

  @override
  String get settingsFixGameStartup => 'Spielstart-Problem beheben';

  @override
  String get settingsFixGameStartupDesc =>
      'Verwende dies, wenn sich das Spiel beim Start schließt oder abstürzt. UE4SS und CNS werden vorübergehend deinstalliert, das Spiel wird einmal gestartet und beide danach neu installiert.';

  @override
  String get repairConfirmTitle => 'Spielstart reparieren?';

  @override
  String get repairConfirmMessage =>
      'UE4SS und CNS werden deinstalliert (ihre Dateien werden sicher aufbewahrt), das Spiel startet und schließt sich automatisch, danach wird alles neu installiert und das Spiel erneut gestartet. Schließe die App währenddessen nicht.';

  @override
  String get repairConfirmAction => 'Reparatur starten';

  @override
  String get launchRetryTitle => 'Das Spiel hat nicht gestartet';

  @override
  String get launchRetryMessage =>
      'Stellar Blade wurde nach zwei Versuchen nicht gestartet. Meist liegt das an UE4SS oder CNS. „Spielstart-Problem beheben“ deinstalliert beide vorübergehend, startet das Spiel einmal und installiert sie wieder. Jetzt ausführen?';

  @override
  String get launchRetryAction => 'Jetzt beheben';

  @override
  String get repairOverlayTitle => 'Spielstart wird repariert';

  @override
  String get repairOverlayWarning =>
      'Schließe die App und das Spiel währenddessen nicht manuell.';

  @override
  String get repairStepCloseGame => 'Spiel schließen, falls es läuft';

  @override
  String get repairStepStashCns => 'CNS deinstallieren (Dateien sichern)';

  @override
  String get repairStepStashUe4ss => 'UE4SS deinstallieren (Dateien sichern)';

  @override
  String get repairStepLaunchClean => 'Spiel ohne UE4SS und CNS starten';

  @override
  String get repairStepWaitInit => 'Warten, bis das Spiel geladen ist';

  @override
  String get repairStepCloseAuto => 'Spiel automatisch schließen';

  @override
  String get repairStepRestoreUe4ss => 'UE4SS neu installieren';

  @override
  String get repairStepRestoreCns => 'CNS neu installieren';

  @override
  String get repairStepLaunchFinal => 'Spiel starten';

  @override
  String get repairStatusSkipped => 'übersprungen';

  @override
  String get repairResultSuccess =>
      'Reparatur abgeschlossen. Das Spiel wurde gestartet.';

  @override
  String get repairResultErrorRestored =>
      'Die Reparatur ist fehlgeschlagen, aber UE4SS und CNS wurden wiederhergestellt.';

  @override
  String get repairResultErrorRestoreFailed =>
      'Die Reparatur ist fehlgeschlagen und die Dateien konnten noch nicht wiederhergestellt werden. Sie werden beim nächsten Start der App automatisch wiederhergestellt.';

  @override
  String get repairErrorGameNotStarted =>
      'Das Spiel wurde nicht rechtzeitig gestartet.';

  @override
  String get repairButtonClose => 'Schließen';

  @override
  String get repairRecoveredNotice =>
      'Eine unterbrochene Reparatur wurde erkannt: UE4SS- und CNS-Dateien wurden wiederhergestellt.';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return 'Neue Edition installiert: $name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return 'Dieser Mod hat jetzt $count installierte Editionen.';
  }

  @override
  String get previewTagNewEdition => 'neue Edition';

  @override
  String get previewTagUpdate => 'Update';

  @override
  String editionsInstalledTooltip(Object count) {
    return '$count Editionen dieses Mods installiert';
  }

  @override
  String editionLabelValue(Object edition) {
    return 'Edition: $edition';
  }

  @override
  String get otherEditionsTitle => 'Weitere installierte Editionen';

  @override
  String get detailsStatusEnabled => 'Aktiviert';

  @override
  String get detailsStatusDisabled => 'Deaktiviert';

  @override
  String get detailsInformation => 'Informationen';

  @override
  String get detailsRowAuthor => 'Autor';

  @override
  String get detailsRowType => 'Typ';

  @override
  String get detailsRowInstalled => 'Installiert';

  @override
  String get detailsRowModified => 'Zuletzt geändert';

  @override
  String get detailsRowNexusId => 'Nexus-ID';

  @override
  String get detailsRowFolder => 'Ordner';

  @override
  String get detailsCopyPath => 'Pfad kopieren';

  @override
  String get detailsCopied => 'In die Zwischenablage kopiert';

  @override
  String get detailsEndorse => 'Endorse';

  @override
  String get detailsEndorsed => 'Endorsed';

  @override
  String endorseWaitLabel(Object minutes) {
    return '$minutes Min. warten';
  }

  @override
  String get endorseSuccessTitle => 'Mod endorsed';

  @override
  String get endorseRemovedTitle => 'Endorse entfernt';

  @override
  String get endorseFailedTitle => 'Endorse konnte nicht aktualisiert werden';

  @override
  String get endorseErrNotNexus =>
      'Dieser Mod ist nicht mit einer Nexus-Mods-Seite verknüpft, daher kann kein Endorse vergeben werden.';

  @override
  String get endorseErrNoApiKey =>
      'Füge deinen Nexus-Mods-API-Schlüssel in den Einstellungen hinzu, um Mods zu endorsen.';

  @override
  String endorseErrWait(Object minutes) {
    return 'Nexus verlangt 15 Minuten Wartezeit nach dem Herunterladen eines Mods, bevor du ihn endorsen kannst. Versuche es in $minutes Min. erneut.';
  }

  @override
  String get endorseErrNotDownloaded =>
      'Nexus erlaubt Endorses nur für Mods, die du mit deinem Konto heruntergeladen hast.';

  @override
  String get endorseErrOwnMod => 'Du kannst deinen eigenen Mod nicht endorsen.';

  @override
  String get endorseErrRateLimit =>
      'Das Anfragelimit von Nexus wurde erreicht. Versuche es später erneut.';

  @override
  String get endorseErrInvalidKey =>
      'Nexus hat deinen API-Schlüssel abgelehnt. Überprüfe ihn in den Einstellungen.';

  @override
  String get endorseErrNetwork =>
      'Nexus Mods ist nicht erreichbar. Überprüfe deine Verbindung und versuche es erneut.';

  @override
  String get endorseErrUnknown =>
      'Nexus konnte die Anfrage nicht verarbeiten. Versuche es später erneut.';

  @override
  String get endorseRemoveConfirmTitle => 'Endorse entfernen?';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return '$name ist auf Nexus Mods dann nicht mehr endorsed.';
  }

  @override
  String get endorseRemoveConfirmAction => 'Entfernen';

  @override
  String get detailsUpdateAction => 'Aktualisieren';

  @override
  String get detailsShowMore => 'Mehr anzeigen';

  @override
  String get detailsShowLess => 'Weniger anzeigen';

  @override
  String get detailsAddNote => 'Notiz hinzufügen';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Outfits',
      one: '1 Outfit',
      zero: 'Keine Outfits',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get outfitsChoose => 'Outfits auswählen';

  @override
  String get outfitsDone => 'Fertig';

  @override
  String get outfitsFilterAll => 'Alle';

  @override
  String get outfitsFilterSelected => 'Ausgewählt';

  @override
  String get outfitsClearAll => 'Alle löschen';

  @override
  String get outfitsRemove => 'Entfernen';

  @override
  String get outfitsActionSelect => 'Auswählen';

  @override
  String get outfitsActionDeselect => 'Abwählen';

  @override
  String outfitsNoResults(String query) {
    return 'Keine Ergebnisse für „$query“';
  }

  @override
  String get outfitsSelectedEmpty => 'Noch keine Outfits ausgewählt.';

  @override
  String get outfitsNoPreview => 'Keine Vorschau verfügbar';

  @override
  String get replacementOffConfirmTitle => 'Ersatz-Mod ausschalten?';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Die $count ausgewählten Outfits werden aus diesem Mod entfernt.',
      one: 'Das ausgewählte Outfit wird aus diesem Mod entfernt.',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => 'Ausschalten';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Mods ausgeschaltet: Sie ersetzen Outfits, die bereits von anderen Mods verwendet werden',
      one:
          '1 Mod ausgeschaltet: Er ersetzt ein Outfit, das bereits von einem anderen Mod verwendet wird',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  Gleiche Container-ID wie: $owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container-ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved =>
      '  Originale als .cnsbak behalten (wiederherstellbar).';

  @override
  String patcherLeftUntouched(String reason) {
    return '  Unverändert belassen (Patchen nicht sicher): $reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ $count Mod(s) teilen sich eine Container-ID, konnten aber nicht sicher repariert werden (unverändert belassen; sie erscheinen möglicherweise nicht in CNS):';
  }

  @override
  String get revertPatchesTitle => 'Konfliktpatches rückgängig machen';

  @override
  String get revertPatchesDesc =>
      'Stellt die vom Konflikt-Patcher geänderten Original-Mod-Dateien wieder her.';

  @override
  String get revertPatchesConfirmTitle => 'Konfliktpatches rückgängig machen?';

  @override
  String get revertPatchesConfirmMessage =>
      'Die vom Konflikt-Patcher gespeicherten Originaldateien (.cnsbak) werden wiederhergestellt. Schließe zuerst das Spiel. Konfliktierende Mods werden möglicherweise wieder nicht mehr in CNS angezeigt.';

  @override
  String get revertPatchesAction => 'Rückgängig machen';

  @override
  String revertPatchesDone(int count) {
    return '$count Datei(en) wiederhergestellt.';
  }

  @override
  String get revertPatchesNothing =>
      'Keine gepatchten Dateien zum Rückgängigmachen.';

  @override
  String get settingsGroupPaths => 'Pfade';

  @override
  String get settingsGroupTools => 'Werkzeuge';

  @override
  String get settingsAutoOutfit => 'Outfits automatisch zuweisen';

  @override
  String get settingsAutoOutfitDesc =>
      'Beim Installieren eines Ersatz-Mods wird anhand seiner Dateien erkannt, welches Outfit er ersetzt. Wenn deaktiviert, wird das Outfit manuell zugewiesen.';

  @override
  String get variantChoiceTitle => 'Mehrere Varianten desselben Ersatzes';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return '„$mod“ enthält mehrere Varianten, die $outfits ersetzen. Es kann nur eine gleichzeitig aktiv sein. Welche möchtest du installieren?';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return '„$mod“ enthält mehrere Varianten, die dieselben Dateien ersetzen. Es kann nur eine gleichzeitig aktiv sein. Welche möchtest du installieren?';
  }

  @override
  String get variantChoiceInstallAll => 'Alle installieren (als separate Mods)';

  @override
  String get installOutfitConflictTitle => 'Outfit bereits belegt';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return 'Die Mod „$newMod“ ersetzt das Outfit $outfits, das bereits der aktiven Mod „$oldMod“ zugewiesen ist. Es kann nur eine gleichzeitig aktiv sein. Welche soll aktiv bleiben?';
  }

  @override
  String get installOutfitKeepCurrent => 'Aktuelle behalten';

  @override
  String get installOutfitUseNew => 'Neue Mod aktivieren';

  @override
  String installOutfitNowActive(String active) {
    return 'Jetzt aktiv: $active';
  }

  @override
  String get fileLockErrorTitle => 'Mod konnte nicht verschoben werden';

  @override
  String get fileLockErrorMessage =>
      'Möglicherweise verwendet eine andere Anwendung die Spieldateien (FModel, das Spiel selbst, ein Virenscanner, der Explorer...). Schließe sie und versuche es erneut.';

  @override
  String get nexusProfileTooltip => 'Nexus-Mods-Profil';

  @override
  String get nexusUserFallback => 'Benutzer';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => 'Mitglied';

  @override
  String get nexusPlanSupporter => 'Unterstützer';

  @override
  String get nexusApiRequestsRemaining => 'VERBLEIBENDE API-ANFRAGEN';

  @override
  String get nexusApiDaily => 'Täglich';

  @override
  String get nexusApiHourly => 'Pro Stunde';

  @override
  String get downloadMemberAccountLimit =>
      'Mitgliedskonten werden von Nexus Mods auf 1,5 MB/s begrenzt';

  @override
  String get downloadSupporterAccountLimit =>
      'Unterstützerkonten werden von Nexus Mods auf 3 MB/s begrenzt';

  @override
  String get downloadRetryTooltip => 'Erneut versuchen';

  @override
  String get downloadRefreshingLink => 'Link wird aktualisiert...';

  @override
  String get downloadNoInternet =>
      'Keine Internetverbindung. Überprüfe dein Netzwerk.';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'Der Nexus-Link ist abgelaufen ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'HTTP-Fehler: $code';
  }

  @override
  String get downloadErrorTimeout =>
      'Zeitüberschreitung: Es werden keine Netzwerkdaten empfangen';

  @override
  String get splashRootFolder => 'Stammordner (Hauptordner)';

  @override
  String get repairErrorGameNotClosed =>
      'Der Spielprozess konnte nicht beendet werden.';

  @override
  String get errorManifestNotFound =>
      'Installationsmanifest nicht gefunden. Deinstallation nicht möglich.';

  @override
  String get downloadResuming => 'Wird fortgesetzt...';

  @override
  String get apiKeyPromptTitle => 'Nexus-Mods-API-Schlüssel einrichten';

  @override
  String get apiKeyPromptMessage =>
      'Es wurde kein API-Schlüssel erkannt. Die Einrichtung ist optional, wird aber der Bequemlichkeit halber empfohlen: Damit kannst du nach Mod-Updates suchen, Mods mit einem Klick (nxm://) herunterladen und Titelbilder sowie Infos von Nexus Mods laden.';

  @override
  String get apiKeyPromptConfigure => 'API-Schlüssel einrichten';

  @override
  String get apiKeyPromptSkip => 'Überspringen';

  @override
  String get apiKeyPromptDontShowAgain => 'Diese Meldung nicht mehr anzeigen';

  @override
  String get adjustCoverTooltip => 'Cover anpassen';

  @override
  String get noCoverToAdjust => 'Diese Mod hat kein Cover zum Anpassen';

  @override
  String errorAdjustingCoverText(Object error) {
    return 'Fehler beim Anpassen des Covers: $error';
  }
}
