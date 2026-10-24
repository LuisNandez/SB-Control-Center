// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => 'Impostazioni';

  @override
  String get settingsGeneral => 'Generali';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageDesc => 'Scegli la lingua dell\'applicazione';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get settingsAboutDesc => 'Informazioni sull\'applicazione';

  @override
  String get settingsRefreshMetadata => 'Aggiorna i metadati';

  @override
  String get settingsRefreshMetadataDesc =>
      'Ricontrolla le tue mod su Nexus Mods e completa i dati e le immagini mancanti';

  @override
  String get metadataRefreshDone => 'Metadati aggiornati';

  @override
  String get metadataRefreshNoApiKey =>
      'Inserisci la tua chiave API di Nexus Mods nelle impostazioni per aggiornare i metadati.';

  @override
  String get settingsPathsAndTools => 'Percorsi e Strumenti';

  @override
  String get settingsGameFolder => 'Cartella del Gioco';

  @override
  String get settingsGameFolderDesc =>
      'La cartella principale della tua installazione di Stellar Blade.';

  @override
  String get settings7zipPath => 'Percorso 7-Zip';

  @override
  String get settings7zipPathDesc =>
      'La posizione del file 7z.exe per estrarre le mod.';

  @override
  String get settings7zipPathAuto => 'Ricerca automatica';

  @override
  String get settingsRepairMods => 'Ripara Mod Legacy';

  @override
  String get settingsRepairModsDesc =>
      'Scansiona e crea file informativi per le vecchie mod utilizzando il database locale. Richiede una chiave API.';

  @override
  String get settingsConnectivity => 'Connettività e Aggiornamenti';

  @override
  String get settingsApiKey => 'Chiave API di Nexus Mods';

  @override
  String get settingsApiKeyDesc =>
      'Necessaria per controllare gli aggiornamenti delle mod.';

  @override
  String get settingsApiKeySet => 'Impostata';

  @override
  String get settingsApiKeyNotSet => 'Non impostata';

  @override
  String get settingsSkippedVersions => 'Gestisci Versioni Saltate';

  @override
  String get settingsSkippedVersionsDesc =>
      'Gestisci le versioni delle mod che hai scelto di saltare.';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count versioni saltate';
  }

  @override
  String get dialogTitleSkippedVersions => 'Versioni Mod Saltate';

  @override
  String get dialogNoSkippedVersions =>
      'Non hai saltato alcuna versione di mod.';

  @override
  String get dialogSkippedVersions => 'Versione Saltata';

  @override
  String get dialogTitleRepairMods =>
      'Eseguire la Riparazione delle Mod Legacy?';

  @override
  String get dialogContentRepairMods =>
      'Attenzione: Questa funzione è in fase di sviluppo e potrebbe non essere perfetta.\n\nScansionerà le mod senza un file \'nexus_info.json\' e, se trovate nel tuo database locale, ne creerà uno per loro. Tenterà anche di rinominare la cartella della mod per includere la versione trovata (es. \'La Mia Mod\' -> \'La Mia Mod v1.2\').\n\nPriorità della Versione:\n1. Dal nome della cartella.\n2. Dal campo descrizione della mod.\n3. Dall\'ultima versione su Nexus Mods (richiede API).\n\nVuoi continuare?';

  @override
  String get dialogActionRunRepair => 'Esegui Riparazione';

  @override
  String get snackBarGamePathInvalid =>
      'La cartella selezionata non sembra essere una cartella di gioco valida.';

  @override
  String get snackBar7zipPathInvalid =>
      'Il file selezionato deve chiamarsi 7z.exe.';

  @override
  String get snackBarRepairStarted =>
      'Il processo di riparazione delle mod legacy è iniziato...';

  @override
  String snackBarRepairComplete(Object count) {
    return 'Riparazione completata. $count mod sono state aggiornate.';
  }

  @override
  String get snackBarRepairNoMods =>
      'Nessuna mod legacy da riparare è stata trovata.';

  @override
  String get errorApiRequiredForRepair =>
      'La Chiave API è necessaria per trovare l\'ultima versione delle mod senza una versione locale.';

  @override
  String get installNewMod => 'Installa Mod';

  @override
  String get selectFiles => 'Seleziona File';

  @override
  String get selectFolder => 'Seleziona Cartella';

  @override
  String get installSelectedMod => 'Installa Mod Selezionata';

  @override
  String get filesToInstall => 'File da Installare:';

  @override
  String get cancelSelection => 'Annulla Selezione';

  @override
  String get searchMods => 'Cerca mod...';

  @override
  String get enabledMods => 'Mod Abilitate';

  @override
  String get disabledMods => 'Mod Disabilitate';

  @override
  String get refreshList => 'Aggiorna elenco';

  @override
  String get noEnabledMods => 'Nessuna mod abilitata.';

  @override
  String get noDisabledMods => 'Nessuna mod disabilitata.';

  @override
  String get showInFolder => 'Mostra nella cartella';

  @override
  String get disableMod => 'Disabilita mod';

  @override
  String get enableMod => 'Abilita mod';

  @override
  String get deletePermanently => 'Elimina definitivamente';

  @override
  String get language => 'Lingua';

  @override
  String get selectLanguage => 'Seleziona una lingua';

  @override
  String get statusSearchingGame =>
      'Ricerca dell\'installazione di Stellar Blade in corso...';

  @override
  String get statusGamePathFound => 'Percorso del gioco trovato!';

  @override
  String get statusGamePathNotFound =>
      'Impossibile trovare automaticamente il percorso del gioco.';

  @override
  String statusErrorFindingGame(Object error) {
    return 'Si è verificato un errore durante la ricerca del gioco: $error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount mod abilitate, $disabledCount disabilitate.';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return 'Errore durante la lettura delle mod installate: $error';
  }

  @override
  String statusFilesSelected(Object count) {
    return '$count file selezionato/i. Pronto per l\'installazione.';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return 'Cartella \"$folderName\" selezionata. Pronta per l\'installazione.';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return 'File \"$fileName\" caricato. $count file pronto/i per l\'installazione.';
  }

  @override
  String get statusSelectionCancelled =>
      'Selezione annullata. Scegli una nuova mod da installare.';

  @override
  String get statusUpdateComplete => 'Aggiornamento completato.';

  @override
  String get statusInstallationComplete => 'Installazione completata.';

  @override
  String statusError(Object error) {
    return 'Errore: $error';
  }

  @override
  String get dialogTitle7zip => '7-Zip è Richiesto';

  @override
  String get dialogContent7zip =>
      'Per decomprimere questo file, l\'applicazione necessita di 7-Zip.\n\nInstallalo dalla sua pagina ufficiale e poi premi \"Conferma\".';

  @override
  String get dialogContent7zipNotFound =>
      '7-Zip non è stato ancora rilevato. Assicurati che sia installato nel percorso predefinito e riprova.';

  @override
  String get dialogTitleMultipleJsons => 'Rilevati File .json Multipli';

  @override
  String dialogContentMultipleJsons(Object count) {
    return 'Sono stati rilevati $count file .json. Potrebbe trattarsi di una mod con più componenti.\n\nVuoi installarli tutti insieme in un\'unica cartella mod?';
  }

  @override
  String get dialogTitleModExists => 'La Mod Esiste Già';

  @override
  String dialogContentModExists(Object modName) {
    return 'Una mod chiamata \"$modName\" è già installata.\n\nVuoi aggiornarla? I vecchi file verranno eliminati prima di installare quelli nuovi.';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return 'È stata trovata una versione precedente \'$oldModName\'.\n\nVuoi rimuoverla e aggiornare a \'$newModName\'?';
  }

  @override
  String get dialogTitleDeleteMod => 'Eliminare Definitivamente?';

  @override
  String dialogContentDeleteMod(Object modName) {
    return 'Stai per eliminare definitivamente la mod \"$modName\". Questa azione non può essere annullata.\n\nSei sicuro?';
  }

  @override
  String get dialogActionCancel => 'Annulla';

  @override
  String get dialogActionGoToDownload => 'Vai alla Pagina di Download';

  @override
  String get dialogActionConfirmInstallation => 'Conferma Installazione';

  @override
  String get dialogActionUpdateSystem => 'Aggiorna Sistema';

  @override
  String get dialogActionInstallAnyway => 'Installa Comunque';

  @override
  String get dialogActionDelete => 'Elimina';

  @override
  String get dialogActionClose => 'Chiudi';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return 'Installazione batch completata. Successo: $successCount, Falliti: $failedCount.';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return 'Mod \"$modName\" installata con successo.';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return 'Mod \"$modName\" abilitata.';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return 'Mod \"$modName\" disabilitata.';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return 'Mod \"$modName\" eliminata definitivamente.';
  }

  @override
  String get snackBarCNSUpdated =>
      'Custom Nanosuit System aggiornato con successo.';

  @override
  String get snackBarApiKeySaved => 'Chiave API salvata con successo.';

  @override
  String get snackBarGamePathSaved =>
      'Percorso del gioco salvato con successo.';

  @override
  String get snackBar7zipPathSaved => 'Percorso di 7-Zip salvato con successo.';

  @override
  String get snackBarSkippedVersionRemoved => 'Versione saltata rimossa.';

  @override
  String get dropTargetOverlay => 'Trascina qui le mod';

  @override
  String get pathSelectionTitle => 'Percorso di Stellar Blade Non Trovato';

  @override
  String get pathSelectionButtonManual =>
      'Seleziona Manualmente la Cartella del Gioco';

  @override
  String get pathSelectionButtonRetry => 'Riprova';

  @override
  String errorFolderSelection(Object error) {
    return 'Errore nella selezione della cartella: $error';
  }

  @override
  String errorFileSelection(Object error) {
    return 'Errore nella selezione dei file: $error';
  }

  @override
  String errorDecompressing(Object error) {
    return 'Errore durante la decompressione del file: $error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return 'Errore durante l\'elaborazione del file: $error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return 'Formato file non supportato: $extension';
  }

  @override
  String get error7zipRequired => 'Operazione annullata: 7-Zip è richiesto.';

  @override
  String get errorGamePathUndefined => 'Il percorso del gioco non è definito.';

  @override
  String get errorDestinationNotFound =>
      'La cartella di destinazione del gioco non esiste.';

  @override
  String errorUpdateSystem(Object error) {
    return 'Errore durante l\'aggiornamento del sistema: $error';
  }

  @override
  String get errorInstallNoSelection =>
      'Non hai selezionato nulla da installare.';

  @override
  String get errorInstallModExists =>
      'Installazione annullata: la mod esiste già.';

  @override
  String get errorNoJsonFound =>
      'Ogni mod deve contenere almeno un file .json.';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return 'Il file $fileName ha un formato JSON non valido.';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return 'Il file $fileName non sembra essere una mod del Custom Nanosuit System (manca \"DisplayName\").';
  }

  @override
  String get errorNoValidDisplayName =>
      'Nessun \"DisplayName\" valido è stato trovato nei file .json.';

  @override
  String errorEnableMod(Object error) {
    return 'Errore durante l\'abilitazione della mod: $error';
  }

  @override
  String errorDisableMod(Object error) {
    return 'Errore durante la disabilitazione della mod: $error';
  }

  @override
  String errorDeleteMod(Object error) {
    return 'Errore durante l\'eliminazione della mod: $error';
  }

  @override
  String errorOpenFolder(Object path) {
    return 'Impossibile aprire la cartella: $path';
  }

  @override
  String get statusUpdateSystemCancelled =>
      'Aggiornamento del sistema annullato.';

  @override
  String get statusUpdatingCNS =>
      'Aggiornamento del Custom Nanosuit System in corso...';

  @override
  String statusExtractingFile(Object fileName) {
    return 'Estrazione di $fileName in corso...';
  }

  @override
  String get statusInstallationCancelledByUser =>
      'Installazione annullata dall\'utente.';

  @override
  String get errorNoCompatibleFilesInFolder =>
      'La cartella selezionata non contiene file di mod compatibili.';

  @override
  String get errorNoCompatibleFilesInArchive =>
      'Il file compresso non contiene file di mod compatibili.';

  @override
  String get errorNoJsonInSelection =>
      'La selezione non contiene un file .json di mod valido.';

  @override
  String get aboutTitle => 'Informazioni su SB Control Center';

  @override
  String get aboutContent =>
      'SB Control Center è un gestore di mod per Stellar Blade. Installa, organizza e aggiorna le tue mod in un unico posto e funziona con il Custom Nanosuit System (CNS) per le mod di outfit e nanosuit.\n\nSi collega a Nexus Mods per scaricare, cercare aggiornamenti e dare un Endorse alle mod che usi.\n\nRequisito: per il supporto completo dei file .rar e .7z, 7-Zip deve essere installato nel sistema.';

  @override
  String get aboutEndorseCta =>
      'Ti piace questa app? Un Endorse su Nexus Mods aiuta molto.';

  @override
  String get aboutEndorseThanks => 'Grazie per il tuo supporto!';

  @override
  String get aboutLinkText => 'Visita il mio profilo creatore';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return 'Versione: $version';
  }

  @override
  String get openModsFolder => 'Apri Cartella Mod';

  @override
  String get openInNexusMods => 'Apri in Nexus Mods';

  @override
  String get checkForUpdates => 'Controlla aggiornamenti';

  @override
  String updateAvailable(Object version) {
    return 'Aggiornamento disponibile: v$version';
  }

  @override
  String get dialogTitleApiKey => 'Chiave API di Nexus Mods';

  @override
  String get dialogContentApiKey =>
      'Per controllare gli aggiornamenti delle mod, hai bisogno di una chiave API personale da Nexus Mods.';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. Clicca sul pulsante qui sotto per aprire Nexus Mods e accedi.\n2. Scorri fino in fondo alla pagina, alla sezione \'Personal API Key\'.\n3. Richiedila se non ne hai ancora una, poi copiala.\n4. Incollala qui.';

  @override
  String get apiKeyOpenNexusPage => 'Apri la pagina delle chiavi API';

  @override
  String get apiKey => 'Chiave API';

  @override
  String get apiKeyHintText => 'Incolla qui la tua chiave API';

  @override
  String get dialogActionSave => 'Salva';

  @override
  String get apiKeyRemoved => 'Chiave API rimossa.';

  @override
  String get invalidApiKeyError => 'Chiave API non valida.';

  @override
  String get validatingApiKey => 'Validazione in corso...';

  @override
  String get errorApiKeyMissing =>
      'La chiave API di Nexus Mods non è configurata. Aggiungila in Impostazioni › Connettività e Aggiornamenti › Chiave API di Nexus Mods.';

  @override
  String get statusCheckingUpdates => 'Controllo aggiornamenti mod in corso...';

  @override
  String statusUpdatesFound(Object count) {
    return '$count aggiornamento/i trovato/i!';
  }

  @override
  String get statusNoUpdates => 'Tutte le mod sono aggiornate.';

  @override
  String get selectModArchive => 'Seleziona Archivio Mod';

  @override
  String get viewImageGallery => 'Visualizza Galleria Immagini';

  @override
  String get imageGallery => 'Galleria Immagini';

  @override
  String get noImagesFound =>
      'Nessuna immagine trovata per questa mod, oppure la chiave API non è stata inserita. Inserisci la chiave API e controlla gli aggiornamenti in seguito.';

  @override
  String errorFetchingImages(Object error) {
    return 'Errore nel recupero delle immagini: $error';
  }

  @override
  String get imageMod => 'Immagine della Mod';

  @override
  String get modEnabledBadge => 'Abilitata';

  @override
  String get modDisabledBadge => 'Disabilitata';

  @override
  String get modCategoryOther => 'Non specificato';

  @override
  String get dialogContentUpdateOptions => 'Cosa vorresti fare?';

  @override
  String get dialogActionIgnoreVersion => 'Ignora';

  @override
  String get dialogActionSkipVersion => 'Salta Versione';

  @override
  String get dialogActionGoToDownloadPage => 'Vai al Download';

  @override
  String get installedMods => 'Mod Installate';

  @override
  String get filterBy => 'Filtra per:';

  @override
  String get sortBy => 'Ordina per:';

  @override
  String get filterAll => 'Tutte';

  @override
  String get filterEnabled => 'Abilitate';

  @override
  String get filterDisabled => 'Disabilitate';

  @override
  String get filterRepaired => 'Riparate';

  @override
  String get sortByName => 'Nome';

  @override
  String get sortByDate => 'Data';

  @override
  String get noModsFound => 'Nessuna mod trovata.';

  @override
  String get viewTypeGrid => 'Vista a griglia';

  @override
  String get viewTypeList => 'Vista a elenco';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return 'Estrazione di $count di $total: $fileName';
  }

  @override
  String get previewInstallTitle => 'Mod da Installare:';

  @override
  String get dialogTitleUE4SS => 'Installazione di UE4SS Rilevata';

  @override
  String get dialogContentUE4SS =>
      'Lo strumento UE4SS è stato rilevato. Vuoi installarlo in \'StellarBlade\\SB\\Binaries\\Win64\'?\n\nQuesto è necessario per il funzionamento di molte mod.';

  @override
  String get dialogActionInstallTool => 'Installa Strumento';

  @override
  String get statusUE4SSInstallCancelled => 'Installazione di UE4SS annullata.';

  @override
  String get statusInstallingUE4SS => 'Installazione di UE4SS in corso...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SS installato con successo.';

  @override
  String error7zipDecompression(Object error) {
    return 'Errore di 7-Zip durante la decompressione: $error';
  }

  @override
  String get statusUE4SSInstallComplete => 'Installazione di UE4SS completata.';

  @override
  String get dialogTitleAlternativeVersion => 'Versione Alternativa Rilevata';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return 'Una versione alternativa di questa mod è già installata: \'$oldModName\'.\n\nStai per installare un\'alternativa diversa chiamata \'$newModName\'.';
  }

  @override
  String get dialogActionReplace => 'Sostituisci';

  @override
  String get dialogActionInstallAsNew => 'Installa come Nuova';

  @override
  String get dialogTitleUpdate => 'Aggiornamento Disponibile';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Stai per aggiornare la mod \'$modName\'.\n\nVersione installata: $oldVersion\nNuova versione: $newVersion';
  }

  @override
  String get dialogTitleDowngrade => 'Versione Precedente Rilevata';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Attenzione: Stai per installare una versione precedente della mod \'$modName\'.\n\nVersione installata: $oldVersion\nVersione da installare: $newVersion';
  }

  @override
  String get dialogTitleReinstall => 'Reinstalla Mod';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return 'Stai per reinstallare la versione \'$version\' della mod \'$modName\'.';
  }

  @override
  String get dialogActionReinstall => 'Reinstalla';

  @override
  String get editModNameTooltip => 'Modifica nome della mod';

  @override
  String get setCoverTooltip => 'Imposta immagine di copertina personalizzata';

  @override
  String get setCoverText => 'Imposta Copertina';

  @override
  String get restoreOriginalCoverText => 'Ripristina Copertina Originale';

  @override
  String errorSavingCoverText(Object error) {
    return 'Errore nel salvataggio dell\'immagine di copertina: $error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return 'Errore nel ripristino dell\'immagine di copertina originale: $error';
  }

  @override
  String get editVersionText => 'Modifica Versione';

  @override
  String get customVersionText => 'Versione Personalizzata';

  @override
  String get editTagText => 'Modifica Tag';

  @override
  String get customTagText => 'Tag Personalizzato';

  @override
  String get dialogTitleEditModName => 'Modifica Nome della Mod';

  @override
  String get dialogActionResetToDefault => 'Ripristina Predefinito';

  @override
  String get dialogLabelNewName => 'Nuovo nome';

  @override
  String errorModNameExists(Object modName) {
    return 'Una mod chiamata \"$modName\" esiste già.';
  }

  @override
  String get dialogTitleRepairedModWarning => 'Avviso Mod Riparata';

  @override
  String get dialogContentRepairedModWarning =>
      'Questa mod potrebbe non avere le informazioni corrette sulla versione. Si consiglia di reinstallare l\'ultima versione per garantire la compatibilità.';

  @override
  String get repairedModTooltip => 'Informazioni sulla mod riparata';

  @override
  String get disableAllModsTooltip => 'Disabilita tutte le mod';

  @override
  String get deleteAllModsTooltip => 'Elimina tutte le mod disabilitate';

  @override
  String get dialogTitleDisableAll => 'Disabilitare Tutte le Mod?';

  @override
  String dialogContentDisableAll(int count) {
    return 'Sei sicuro di voler disabilitare tutte le $count mod abilitate? Saranno spostate nella cartella di backup.';
  }

  @override
  String get dialogTitleDeleteAll => 'Eliminare le Mod Disabilitate?';

  @override
  String dialogContentDeleteAll(int count) {
    return 'Stai per eliminare definitivamente tutte le $count mod disabilitate. Questa azione non può essere annullata.\n\nSei sicuro?';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return 'Tutte le $count mod abilitate sono state disabilitate.';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return 'Tutte le $count mod disabilitate sono state eliminate definitivamente.';
  }

  @override
  String get snackBarNoModsToDisable =>
      'Non ci sono mod abilitate da disabilitare.';

  @override
  String get snackBarNoModsToDelete =>
      'Non ci sono mod disabilitate da eliminare.';

  @override
  String get enableAllModsTooltip => 'Abilita tutte le mod';

  @override
  String get dialogTitleEnableAll => 'Abilitare Tutte le Mod?';

  @override
  String dialogContentEnableAll(int count) {
    return 'Sei sicuro di voler abilitare tutte le $count mod disabilitate? Saranno spostate nella cartella principale delle mod.';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return 'Tutte le $count mod disabilitate sono state abilitate.';
  }

  @override
  String get snackBarNoModsToEnable =>
      'Non ci sono mod disabilitate da abilitare.';

  @override
  String get editNotes => 'Modifica Note';

  @override
  String get notesHintText => 'Aggiungi qui le tue note personali...';

  @override
  String get modAuthor => 'Autore';

  @override
  String get modSummary => 'Riepilogo';

  @override
  String get modDescription => 'Descrizione';

  @override
  String get noDescriptionAvailable => 'Nessuna descrizione disponibile.';

  @override
  String get personalNotes => 'Note Personali';

  @override
  String get noNotesAvailable => 'Nessuna nota ancora aggiunta.';

  @override
  String get modDetailsTitle => 'Dettagli della Mod';

  @override
  String get modVersion => 'Versione';

  @override
  String get modCategory => 'Categoria';

  @override
  String get dialogTitleAddUrl => 'Aggiungi Link della Mod';

  @override
  String get dialogLabelUrl => 'URL della Mod';

  @override
  String get errorInvalidUrl => 'Inserisci un URL valido.';

  @override
  String get addLinkTooltip => 'Aggiungi un link per il download di questa mod';

  @override
  String get addLinkButtonText => 'Aggiungi Link';

  @override
  String get openLinkButtonText => 'Apri Link';

  @override
  String get editModTitle => 'Modifica Dettagli della Mod';

  @override
  String get modNameLabel => 'Nome della Mod';

  @override
  String get authorLabel => 'Autore';

  @override
  String get summaryLabel => 'Descrizione / Sommario';

  @override
  String get notesLabel => 'Note Personali';

  @override
  String get urlLabel => 'URL di Download';

  @override
  String get changeCoverButton => 'Cambia Immagine di Copertina';

  @override
  String get editButtonTooltip => 'Modifica Mod';

  @override
  String get errorSavingNotes => 'Errore nel salvataggio delle note';

  @override
  String get errorSavingUrl => 'Errore nel salvataggio dell\'URL';

  @override
  String get errorSavingChanges => 'Errore nel Salvataggio delle Modifiche';

  @override
  String get errorTranslation => 'Impossibile tradurre la descrizione';

  @override
  String get translateSummary => 'Traduci riepilogo';

  @override
  String get translateDescription => 'Traduci descrizione';

  @override
  String get restoreOriginalDescription => 'Ripristina descrizione originale';

  @override
  String get dialogTitleUE4SSReinstall => 'Reinstalla UE4SS';

  @override
  String get dialogContentUE4SSReinstall =>
      'UE4SS sembra essere già installato. Vuoi sovrascrivere l\'installazione esistente? Questo può essere utile se sospetti file corrotti.';

  @override
  String get dialogTitleCNSReinstall => 'Reinstalla Sistema CNS';

  @override
  String get dialogContentCNSReinstall =>
      'Il sistema principale CNS sembra essere già installato. Vuoi reinstallarlo? Le tue mod esistenti non saranno influenzate.';

  @override
  String dialogTitleUninstall(Object componentName) {
    return 'Disinstalla $componentName';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return 'Sei sicuro di voler disinstallare $componentName? Questa azione rimuoverà i file del componente principale ma non influenzerà le tue mod installate.';
  }

  @override
  String get dialogActionUninstall => 'Sì, disinstalla';

  @override
  String statusUninstalling(Object componentName) {
    return 'Disinstallazione di $componentName in corso...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentName disinstallato con successo';
  }

  @override
  String errorUninstalling(Object componentName) {
    return 'Errore durante la disinstallazione di $componentName';
  }

  @override
  String get settingsCoreComponents => 'Componenti Principali';

  @override
  String get installedStatus => 'Installato';

  @override
  String get notInstalledStatus => 'Non rilevato';

  @override
  String get uninstallButton => 'Disinstalla';

  @override
  String get cnsCoreSystem => 'Custom Nanosuit System';

  @override
  String get ue4ssInstallationDetected =>
      'Installazione esistente di UE4SS rilevata e adottata';

  @override
  String get cnsInstallationDetected =>
      'Installazione principale di CNS esistente rilevata e adottata';

  @override
  String get ue4ssRequiredTitle => 'UE4SS Richiesto';

  @override
  String get ue4ssRequiredContent =>
      'Per installare il Sistema Principale CNS, devi prima installare UE4SS. Puoi scaricarlo dal seguente link:';

  @override
  String get uninstallDependencyTitle => 'Dipendenza Rilevata';

  @override
  String get uninstallDependencyContent =>
      'Devi disinstallare il Sistema Principale CNS prima di poter disinstallare UE4SS, poiché CNS dipende da esso.';

  @override
  String get dialogActionUnderstood => 'Capito';

  @override
  String get appTitleNoCns => 'Custom Nanosuit System (Non Installato)';

  @override
  String get dialogTitleCNSUpdate => 'Aggiorna Sistema Principale CNS';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return 'Stai per aggiornare CNS dalla versione $oldVersion alla nuova versione $newVersion. Desideri continuare?';
  }

  @override
  String get dialogTitleCNSDowngrade => 'Downgrade Versione CNS';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return 'Attenzione! Stai per installare una versione precedente di CNS ($newVersion) rispetto a quella attuale ($oldVersion). Questo potrebbe causare problemi. Sei sicuro?';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return 'Hai già installato la versione $version di CNS. Vuoi reinstallare comunque i file?';
  }

  @override
  String get dialogActionUpdate => 'Aggiorna';

  @override
  String get dialogActionDowngrade => 'Downgrade';

  @override
  String get dialogTitleCNSInstall => 'Installa Sistema Principale CNS';

  @override
  String get dialogContentCNSInstall =>
      'Stai per installare il sistema base Custom Nanosuit System (CNS). Questo è necessario per il funzionamento delle mod CNS. Desideri continuare?';

  @override
  String get dialogActionInstall => 'Installa';

  @override
  String get settingsDeveloperOptions => 'Opzioni Sviluppatore';

  @override
  String get devDeleteNexusInfoTitle => 'Elimina Tutti i File nexus_info.json';

  @override
  String get devDeleteNexusInfoDesc =>
      'Rimuove tutti i file di metadati del gestore da ogni mod. Utile per forzare una riparazione completa.';

  @override
  String get devExtractIdsTitle => 'Estrai Identificatori';

  @override
  String get devExtractIdsDesc =>
      'Crea un file chiamato \'ID Mods.json\' sul tuo desktop contenente il displayName e il nexusId di ogni mod.';

  @override
  String get devConfirmDeleteTitle => 'Conferma Eliminazione';

  @override
  String get devConfirmDeleteDesc =>
      'Sei sicuro di voler eliminare definitivamente tutti i file nexus_info.json? Questo rimuoverà tutti i nomi, le copertine e i metadati personalizzati. Questa azione non può essere annullata.';

  @override
  String get devDeleteSuccessTitle => 'Eliminazione Completata';

  @override
  String devDeleteSuccessDesc(Object count) {
    return 'Eliminati con successo $count file nexus_info.json.';
  }

  @override
  String get devConfirmExtractTitle => 'Conferma Estrazione';

  @override
  String get devConfirmExtractDesc =>
      'Questo scansionerà tutte le tue mod e creerà \'ID Mods.json\' sul tuo desktop. Sovrascriverà qualsiasi file esistente con lo stesso nome. Vuoi continuare?';

  @override
  String get devExtractAction => 'Estrai';

  @override
  String get devTestSelfUpdateTitle => 'Prova l\'auto-installazione';

  @override
  String get devTestSelfUpdateDesc =>
      'Seleziona il pacchetto .zip dell\'app e installalo sopra questa app, proprio come farà l\'aggiornamento automatico.';

  @override
  String get devSelfUpdateUnsupported =>
      'L\'aggiornamento automatico è disponibile solo su Windows.';

  @override
  String get devSelfUpdatePickTitle => 'Seleziona il .zip di SB Control Center';

  @override
  String get devSelfUpdateFailed => 'Impossibile installare l\'aggiornamento';

  @override
  String get devSelfUpdateDryRunTitle =>
      'Il pacchetto è valido (modalità di test)';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return 'Trovati $count file. Non è stato installato perché questa non è una build di release.';
  }

  @override
  String get devSelfUpdateConfirmTitle => 'Installare l\'aggiornamento?';

  @override
  String get devSelfUpdateConfirmDesc =>
      'L\'app si chiuderà, sostituirà i propri file con quelli del pacchetto e si riaprirà automaticamente.';

  @override
  String get devSelfUpdateInstallAction => 'Installa e riavvia';

  @override
  String get devSelfUpdateProgressTitle =>
      'Aggiornamento di SB Control Center in corso';

  @override
  String get devSelfUpdateExtracting => 'Estrazione del pacchetto…';

  @override
  String get devSelfUpdateInstalling => 'Installazione dei file…';

  @override
  String get devSelfUpdateRestarting => 'Riavvio…';

  @override
  String get devExtractNoData =>
      'Nessuna mod con identificatori validi trovata da estrarre.';

  @override
  String get devExtractDesktopNotFound =>
      'Errore: Impossibile trovare la directory del Desktop.';

  @override
  String get devExtractSuccessTitle => 'Estrazione Completata';

  @override
  String devExtractSuccessDesc(Object path) {
    return 'File creato con successo in: $path';
  }

  @override
  String get errorDialogTitle => 'Si è Verificato un Errore';

  @override
  String get modDetailsCategory => 'Categoria';

  @override
  String get modDetailsAuthor => 'Autore';

  @override
  String get modDetailsNexusId => 'ID Nexus';

  @override
  String get modDetailsInstalledOn => 'Installato il';

  @override
  String get unknownAuthor => 'Sconosciuto';

  @override
  String get statusInstalling => 'Installazione in corso...';

  @override
  String statusInstallingMod(int index, int total, String modName) {
    return 'Installazione di $index/$total: $modName';
  }

  @override
  String byText(Object author) {
    return 'di $author';
  }

  @override
  String get filterUpdatesAvailable => 'Aggiornamenti disponibili';

  @override
  String snackBarUpdateIgnored(String modName) {
    return 'Aggiornamento per \'$modName\' ignorato per questa sessione.';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return 'La versione \'$version\' di \'$modName\' verrà saltata nei controlli futuri.';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return 'Aggiornamento dei metadati per \'$displayName\' ($arg1 di $arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return 'Mod Generica Installata: $modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return 'Installata in $path.\nQuesta mod non è gestita dall\'app e deve essere disinstallata manualmente.';
  }

  @override
  String genericModInstallError(String modName) {
    return 'Impossibile installare la mod generica: $modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => 'Generica';

  @override
  String get modTypeMovies => 'Filmati';

  @override
  String get modTypeSave => 'Salvataggio';

  @override
  String get modTypeConfig => 'Configurazione';

  @override
  String get modTypeSplash => 'Splash';

  @override
  String get replacesOutfitTitle => 'Sostituisce Completo';

  @override
  String get replacesOutfitClearTooltip => 'Cancella selezione completo';

  @override
  String get replacesOutfitSelectTooltip => 'Seleziona completo da sostituire';

  @override
  String get replacesOutfitNone =>
      'Nessun completo selezionato.\nIl tag sarà \'Generica\'.';

  @override
  String get replacesOutfitSearchHint => 'Cerca completi...';

  @override
  String get modTypeReplacement => 'Sostituzione';

  @override
  String get replacesOutfitHover =>
      'Passa il mouse su un completo per vedere un\'anteprima.';

  @override
  String get dialogTitleOutfitReplacement => 'Sostituzione Completo?';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return 'La mod \'$modName\' è una sostituzione di un completo?\n\nSeleziona \'Sì\' per scegliere quale completo sostituisce, o \'No\' per installarla come mod generica.';
  }

  @override
  String get dialogActionNo => 'No';

  @override
  String get dialogActionYes => 'Sì';

  @override
  String get dialogTitleOutfitConflict => 'Rilevato Conflitto di Completi';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return 'Il completo \'$outfitName\' è già sostituito dalla mod \'$modName\'.\n\nVuoi disabilitare \'$modName\' e attivare questa al suo posto?';
  }

  @override
  String get dialogActionActivateAndDisable => 'Disabilita e Attiva';

  @override
  String get replacementModSwitchTitle => 'Mod di sostituzione';

  @override
  String get replacementModSwitchDesc =>
      'Spunta se questa mod è progettata per sostituire una tuta nel gioco.';

  @override
  String get settingsShowModTagsTitle => 'Mostra tag tipo di mod';

  @override
  String get settingsShowModTagsDesc =>
      'Mostra i tag del tipo di mod (es. CNS, Generica) su ogni scheda mod nell\'elenco.';

  @override
  String get modTypeLogic => 'Logica';

  @override
  String get patcherStarted => '=== Patcher Dart per StellarBlade Avviato ===';

  @override
  String workingDirectory(String path) {
    return 'Directory di lavoro: $path';
  }

  @override
  String modsDirNotFound(String path) {
    return 'La directory ~mods non esiste in: $path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  ATTENZIONE: Impossibile scansionare la cartella $path. Operazione ignorata.';
  }

  @override
  String errorDetails(String error) {
    return '  Errore: $error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return 'Trovati $count file .utoc';
  }

  @override
  String get noModsFound2 => 'Nessuna mod trovata da elaborare.';

  @override
  String get patcherSummaryTitle => '\n=== Riepilogo Patcher (Dati Grezzi) ===';

  @override
  String processedMods(int count) {
    return 'Elaborate $count mod.';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return 'Risolti $count conflitti di Container ID.';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return 'Trovati $count conflitti di Package ID.';
  }

  @override
  String get fatalErrorTitle => '\n=== ERRORE FATALE ===';

  @override
  String patcherServiceError(String error) {
    return 'Errore in PatcherService: $error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- Analisi: $fileName ---';
  }

  @override
  String get warnUcasNotFound =>
      '  ATTENZIONE: File .ucas non trovato. Operazione ignorata.';

  @override
  String get warnCorruptHeader =>
      '  ATTENZIONE: Intestazione corrotta, la dimensione della voce supera la dimensione del file. Operazione ignorata.';

  @override
  String conflictContainerIdDetected(int id) {
    return '  CONFLITTO di Container ID rilevato: $id';
  }

  @override
  String generatingNewId(int id) {
    return '  Generazione nuovo ID: $id';
  }

  @override
  String get utocFilePatched => '  File .utoc patchato.';

  @override
  String get patchingUcasFile => '  Patch del file .ucas in corso...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  Sostituzioni completate in .ucas: $count';
  }

  @override
  String get patchComplete => '  Patch completata!';

  @override
  String idRegisteredNoConflict(int id) {
    return '  ID $id registrato. Nessun conflitto.';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  ERRORE durante l\'elaborazione di $fileName: $error';
  }

  @override
  String get statusRunningPatcher =>
      'Esecuzione Patcher di Conflitti in corso...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ Successo! Risolti $count conflitti di Container ID che causavano crash.';
  }

  @override
  String get summaryNoContainerIdConflicts =>
      '✅ Non sono stati trovati conflitti di Container ID (crash).';

  @override
  String get summaryNoPackageIdConflicts =>
      '✅ Buone notizie! Non sono stati trovati conflitti gravi di Package ID (sovrascritture).';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ Attenzione! Trovati $count gruppi di mod che non possono coesistere:';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • Questo gruppo di mod compete per $count file:';
  }

  @override
  String get patcherSummaryDialogTitle => 'Riepilogo Patcher';

  @override
  String get dialogActionShowFullLog => 'Mostra Log Completo';

  @override
  String get fullLogDialogTitle => 'Log Patcher di Conflitti (Dart)';

  @override
  String get runConflictPatcherTitle => 'Esegui Patcher di Conflitti';

  @override
  String get runConflictPatcherSubtitlePython =>
      'Risolve i crash di Container_Id e Package_Id';

  @override
  String get processingCover => 'Elaborazione Copertina...';

  @override
  String get apiKeyTooltip =>
      'La chiave API è richiesta per l\'estrazione intelligente dell\'ID Nexus.';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return 'Opzioni di Installazione - Mod $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection =>
      'Seleziona le opzioni che desideri installare. I file principali richiesti verranno installati automaticamente.';

  @override
  String get snackBarSpecialModNoSelection =>
      'Seleziona almeno un\'opzione per continuare.';

  @override
  String get dialogActionInstallSelection => 'Installa Selezione';

  @override
  String get downloadStatusFetching =>
      'Ottenimento dei dati di Nexus Mods in corso...';

  @override
  String get downloadStatusFetchingFailed =>
      'Impossibile ottenere il link di download. Verifica la tua chiave API o la connessione.';

  @override
  String downloadStatusDownloading(String fileName) {
    return 'Download di $fileName in corso';
  }

  @override
  String get downloadStatusError => 'Errore durante il download del file.';

  @override
  String downloadStatusException(String error) {
    return 'Eccezione: $error';
  }

  @override
  String get dialogTitleDownloadModManager => 'Download del Mod Manager';

  @override
  String get launchGameText => 'Avvia Stellar Blade';

  @override
  String get stopGameText => 'Chiudi Stellar Blade';

  @override
  String get dialogTitleStopGame => 'Chiudere Stellar Blade?';

  @override
  String get dialogContentStopGame =>
      'Il gioco verrà chiuso. I progressi non salvati andranno persi.';

  @override
  String get dialogActionStopGame => 'Chiudi';

  @override
  String get notificationGameStopped => 'Stellar Blade chiuso';

  @override
  String get errorStoppingGame => 'Impossibile chiudere il gioco';

  @override
  String get mod801DialogTitle => 'Configurazione di Steam richiesta';

  @override
  String get mod801DialogIntro =>
      'La mod Random Splash è stata installata. Per farla funzionare automaticamente all\'avvio del gioco, devi configurare Steam.';

  @override
  String get mod801Step1 =>
      '1. Genera il percorso esatto per il tuo PC qui sotto e copialo.';

  @override
  String get mod801Step2 => '2. Apri la tua Libreria di Steam.';

  @override
  String get mod801Step3 => '3. Fai clic destro su Stellar Blade -> Proprietà.';

  @override
  String get mod801Step4 =>
      '4. Nella scheda \'Generale\', incolla il codice in \'Opzioni di avvio\'.';

  @override
  String get mod801BtnGenerate => 'Genera percorso';

  @override
  String get mod801BtnSteam => 'Apri Steam';

  @override
  String get mod801BtnCopy => 'Copia';

  @override
  String get mod801PathGenerated => 'Percorso generato con successo.';

  @override
  String get mod801PathCopied => 'Comando copiato negli appunti!';

  @override
  String get statusVerifyingMods =>
      'Verifica dell\'integrità delle mod in corso...';

  @override
  String errorSelecting7Zip(String error) {
    return 'Errore durante la selezione di 7-Zip: $error';
  }

  @override
  String get errorInvalidFolderRetry =>
      'La cartella selezionata non sembra essere corretta. Riprova.';

  @override
  String errorSelectingFolderDynamic(String error) {
    return 'Errore durante la selezione della cartella: $error';
  }

  @override
  String get statusNoNewModsInstalled =>
      'L\'installazione non ha prodotto nuove mod.';

  @override
  String get errorDisableModBeforeDelete =>
      'Disabilita la mod prima di eliminarla.';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return 'Abilitate: $successCount (Ignorate: $skippedCount a causa di conflitti)';
  }

  @override
  String get snackBarDeveloperModeEnabled => 'Modalità sviluppatore abilitata!';

  @override
  String errorRenamingMod(String error) {
    return 'Errore durante la rinominazione della mod: $error';
  }

  @override
  String get notificationTitleError => 'Errore';

  @override
  String get errorGamePathNotFoundNotification =>
      'Percorso del gioco non trovato.';

  @override
  String get notificationLaunchingGame => 'Avvio di Stellar Blade in corso...';

  @override
  String get errorLaunchingGame => 'Errore durante l\'avvio del gioco';

  @override
  String get dialogTitleSelect7zip => 'Seleziona il file 7z.exe';

  @override
  String get dialogTitleSelectGameFolder =>
      'Seleziona la cartella principale di StellarBlade';

  @override
  String get dialogTitleSelectCover => 'Seleziona una copertina per la mod';

  @override
  String get errorGamePathNotFoundException =>
      'Percorso del gioco non trovato.';

  @override
  String get errorGamePathNotDefined => 'Il percorso del gioco non è definito.';

  @override
  String get errorLogicModsPathNotDefined =>
      'Il percorso delle mod Logic non è definito.';

  @override
  String get errorUe4ssModsPathNotDefined =>
      'Il percorso delle mod UE4SS non è definito.';

  @override
  String get errorGenericModsPathNotDefined =>
      'Il percorso delle mod generiche (~mods) non è definito.';

  @override
  String get errorReplaceNoOldVersion =>
      'Tentativo di sostituire una mod, ma non è stata identificata alcuna versione precedente.';

  @override
  String errorDeleteOldModVersion(String modName) {
    return 'Impossibile eliminare la vecchia versione della mod ($modName).';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return 'Impossibile eliminare la mod esistente ($modName) per reinstallarla.';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return 'Impossibile eliminare la mod esistente ($modName) per reinstallarla dopo diversi tentativi.';
  }

  @override
  String get errorMoviesModNoValidFiles =>
      'La mod dei filmati non contiene file video validi.';

  @override
  String get errorInstallPathUndetermined =>
      'Impossibile determinare il percorso di installazione.';

  @override
  String get errorMoviesPathsNotDefined =>
      'I percorsi dei filmati non sono definiti.';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return 'nexus_info.json non trovato per $modName.';
  }

  @override
  String get errorMenuVideoLimitReached =>
      'Limite di 99 video nel menu raggiunto.';

  @override
  String get errorModRequires529 =>
      'La mod richiede l\'ID Mod 529 per funzionare (contiene solo file WebM).';

  @override
  String get errorSplashPathsNotDefined =>
      'I percorsi dello splash non sono definiti.';

  @override
  String get errorSplashNoValidImages =>
      'Nessuna immagine valida trovata nella mod.';

  @override
  String get errorCouldNotDeleteDirectory =>
      'Impossibile eliminare la directory.';

  @override
  String get errorGameExeNotFound =>
      'Il file eseguibile del gioco (.exe) non è stato trovato nella cartella principale o in Binaries.';

  @override
  String get dialogTitleSplashOptions => 'Opzioni Splash (Immagini)';

  @override
  String get dialogContentSplashOptions =>
      'Seleziona le immagini che desideri installare. Puoi scegliere intere cartelle (gruppi) o singole immagini.';

  @override
  String get snackBarSplashNoSelection => 'Seleziona almeno un\'immagine.';

  @override
  String get dialogContentSpecialModSingleSelection =>
      'Seleziona una singola opzione da installare.';

  @override
  String get activeDownloads => 'Download attivi';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mods',
      one: 'mod',
    );
    return 'Download di $count $_temp0 in corso';
  }

  @override
  String get downloadError => 'Errore';

  @override
  String get downloadCancelled => 'Annullato';

  @override
  String get downloadPause => 'Pausa';

  @override
  String get downloadResume => 'Riprendi';

  @override
  String get downloadCancel => 'Annulla';

  @override
  String get errorNexusInfoNotFound => 'nexus_info.json non trovato.';

  @override
  String logFixingCorruptedJson(String displayName) {
    return 'Correzione del file nexus_info.json danneggiato per $displayName.';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return 'Impossibile aggiornare i metadati per $displayName: $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return 'Disattivazione preventiva della mod dei film a causa dell\'attivazione della Mod 529: $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return 'Disattivazione preventiva della mod splash a causa dell\'attivazione della Mod 801: $modName';
  }

  @override
  String logRestoringTildeComponent(String folderName) {
    return 'Ripristino del componente ~mods: $folderName';
  }

  @override
  String logRestoringUe4ssComponent(String folderName) {
    return 'Ripristino del componente UE4SS: $folderName';
  }

  @override
  String logErrorRestoringLogicMod(String error) {
    return 'Errore nel ripristino dei componenti LogicMod: $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return 'Archiviazione del componente ~mods: $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return 'Archiviazione del componente UE4SS: $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return 'Errore nell\'archiviazione dei componenti LogicMod: $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return 'Ignorato $modName: esiste già una variante attiva di questa mod.';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return 'Ignorato $modName: conflitto con un vestito già occupato.';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return 'Impossibile pulire i backup video per $modName: $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return 'Rilevato un nuovo ID Nexus $nexusId. Recupero dei metadati...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return 'Metadati recuperati e applicati per $nexusId.';
  }

  @override
  String logFallbackByteCopy(String error) {
    return 'Copia normale non riuscita, utilizzo della forza bruta dei byte: $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return 'Avviso: Impossibile eliminare il file modificato: $error';
  }

  @override
  String get logMod801BatPatched =>
      'Script .bat della Mod 801 patchato con successo per questo sistema.';

  @override
  String logMod801BatPatchError(String error) {
    return 'Errore durante il tentativo di applicare la patch al file .bat della Mod 801: $error';
  }

  @override
  String get errorHomeDirNotFound =>
      'Impossibile trovare la variabile d\'ambiente della directory home.';

  @override
  String get downloadFetchingPlaceholder => 'Recupero in corso...';

  @override
  String get downloadErrorLink => 'Impossibile recuperare il link di download';

  @override
  String get downloadErrorGeneral => 'Download non riuscito';

  @override
  String get downloadPausedStatus => 'In pausa';

  @override
  String get settingsFixGameStartup => 'Risolvi l\'avvio del gioco';

  @override
  String get settingsFixGameStartupDesc =>
      'Usalo se il gioco si chiude o va in crash all\'avvio. Disinstalla temporaneamente UE4SS e CNS, avvia il gioco una volta e poi li reinstalla.';

  @override
  String get repairConfirmTitle => 'Riparare l\'avvio del gioco?';

  @override
  String get repairConfirmMessage =>
      'UE4SS e CNS verranno disinstallati (i loro file vengono conservati), il gioco si avvierà e si chiuderà automaticamente, poi tutto verrà reinstallato e il gioco riavviato. Non chiudere l\'app durante il processo.';

  @override
  String get repairConfirmAction => 'Avvia riparazione';

  @override
  String get launchRetryTitle => 'Il gioco non si è avviato';

  @override
  String get launchRetryMessage =>
      'Stellar Blade non si è avviato dopo due tentativi. Di solito la causa è UE4SS o CNS. «Risolvi l\'avvio del gioco» li disinstalla temporaneamente, avvia il gioco una volta e li reinstalla. Eseguirlo ora?';

  @override
  String get launchRetryAction => 'Risolvi ora';

  @override
  String get repairOverlayTitle => 'Riparazione dell\'avvio';

  @override
  String get repairOverlayWarning =>
      'Non chiudere manualmente l\'app o il gioco durante il processo.';

  @override
  String get repairStepCloseGame => 'Chiusura del gioco se è aperto';

  @override
  String get repairStepStashCns =>
      'Disinstallazione di CNS (salvataggio dei file)';

  @override
  String get repairStepStashUe4ss =>
      'Disinstallazione di UE4SS (salvataggio dei file)';

  @override
  String get repairStepLaunchClean => 'Avvio del gioco senza UE4SS e CNS';

  @override
  String get repairStepWaitInit => 'Attesa del caricamento del gioco';

  @override
  String get repairStepCloseAuto => 'Chiusura automatica del gioco';

  @override
  String get repairStepRestoreUe4ss => 'Reinstallazione di UE4SS';

  @override
  String get repairStepRestoreCns => 'Reinstallazione di CNS';

  @override
  String get repairStepLaunchFinal => 'Avvio del gioco';

  @override
  String get repairStatusSkipped => 'saltato';

  @override
  String get repairResultSuccess =>
      'Riparazione completata. Il gioco è stato avviato.';

  @override
  String get repairResultErrorRestored =>
      'La riparazione non è riuscita, ma UE4SS e CNS sono stati ripristinati.';

  @override
  String get repairResultErrorRestoreFailed =>
      'La riparazione non è riuscita e i file non sono stati ripristinati. Verranno ripristinati automaticamente al prossimo avvio dell\'app.';

  @override
  String get repairErrorGameNotStarted => 'Il gioco non si è avviato in tempo.';

  @override
  String get repairButtonClose => 'Chiudi';

  @override
  String get repairRecoveredNotice =>
      'Rilevata una riparazione interrotta: i file UE4SS e CNS sono stati ripristinati.';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return 'Nuova edizione installata: $name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return 'Questa mod ora ha $count edizioni installate.';
  }

  @override
  String get previewTagNewEdition => 'nuova edizione';

  @override
  String get previewTagUpdate => 'aggiornamento';

  @override
  String editionsInstalledTooltip(Object count) {
    return '$count edizioni di questa mod installate';
  }

  @override
  String editionLabelValue(Object edition) {
    return 'Edizione: $edition';
  }

  @override
  String get otherEditionsTitle => 'Altre edizioni installate';

  @override
  String get detailsStatusEnabled => 'Abilitata';

  @override
  String get detailsStatusDisabled => 'Disabilitata';

  @override
  String get detailsInformation => 'Informazioni';

  @override
  String get detailsRowAuthor => 'Autore';

  @override
  String get detailsRowType => 'Tipo';

  @override
  String get detailsRowInstalled => 'Installato';

  @override
  String get detailsRowModified => 'Ultima modifica';

  @override
  String get detailsRowNexusId => 'ID Nexus';

  @override
  String get detailsRowFolder => 'Cartella';

  @override
  String get detailsCopyPath => 'Copia percorso';

  @override
  String get detailsCopied => 'Copiato negli appunti';

  @override
  String get detailsEndorse => 'Endorse';

  @override
  String get detailsEndorsed => 'Endorsed';

  @override
  String endorseWaitLabel(Object minutes) {
    return 'Attendi $minutes min';
  }

  @override
  String get endorseSuccessTitle => 'Mod endorsed';

  @override
  String get endorseRemovedTitle => 'Endorse rimosso';

  @override
  String get endorseFailedTitle => 'Impossibile aggiornare l\'endorse';

  @override
  String get endorseErrNotNexus =>
      'Questa mod non è collegata a una pagina di Nexus Mods, quindi non è possibile fare l\'endorse.';

  @override
  String get endorseErrNoApiKey =>
      'Aggiungi la tua chiave API di Nexus Mods nelle Impostazioni per fare l\'endorse delle mod.';

  @override
  String endorseErrWait(Object minutes) {
    return 'Nexus richiede di attendere 15 minuti dopo il download di una mod prima di poter fare l\'endorse. Riprova tra $minutes min.';
  }

  @override
  String get endorseErrNotDownloaded =>
      'Nexus consente di fare l\'endorse solo delle mod scaricate con il tuo account.';

  @override
  String get endorseErrOwnMod => 'Non puoi fare l\'endorse di una tua mod.';

  @override
  String get endorseErrRateLimit =>
      'Hai raggiunto il limite di richieste di Nexus. Riprova più tardi.';

  @override
  String get endorseErrInvalidKey =>
      'Nexus ha rifiutato la tua chiave API. Controllala nelle Impostazioni.';

  @override
  String get endorseErrNetwork =>
      'Impossibile raggiungere Nexus Mods. Controlla la connessione e riprova.';

  @override
  String get endorseErrUnknown =>
      'Nexus non ha potuto elaborare la richiesta. Riprova più tardi.';

  @override
  String get endorseRemoveConfirmTitle => 'Rimuovere l\'endorse?';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return 'Per $name non risulterà più l\'endorse su Nexus Mods.';
  }

  @override
  String get endorseRemoveConfirmAction => 'Rimuovi';

  @override
  String get detailsUpdateAction => 'Aggiorna';

  @override
  String get detailsShowMore => 'Mostra altro';

  @override
  String get detailsShowLess => 'Mostra meno';

  @override
  String get detailsAddNote => 'Aggiungi una nota';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completi',
      one: '1 completo',
      zero: 'Nessun completo',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return '$count selezionati';
  }

  @override
  String get outfitsChoose => 'Scegli i completi';

  @override
  String get outfitsDone => 'Fatto';

  @override
  String get outfitsFilterAll => 'Tutti';

  @override
  String get outfitsFilterSelected => 'Selezionati';

  @override
  String get outfitsClearAll => 'Deseleziona tutto';

  @override
  String get outfitsRemove => 'Rimuovi';

  @override
  String get outfitsActionSelect => 'Seleziona';

  @override
  String get outfitsActionDeselect => 'Deseleziona';

  @override
  String outfitsNoResults(String query) {
    return 'Nessun risultato per «$query»';
  }

  @override
  String get outfitsSelectedEmpty => 'Nessun completo selezionato.';

  @override
  String get outfitsNoPreview => 'Anteprima non disponibile';

  @override
  String get replacementOffConfirmTitle =>
      'Disattivare la mod di sostituzione?';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'I $count completi selezionati verranno rimossi da questa mod.',
      one: 'Il completo selezionato verrà rimosso da questa mod.',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => 'Disattiva';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count mod disattivate: sostituiscono completi già usati da altre mod',
      one:
          '1 mod disattivata: sostituisce un completo già usato da un’altra mod',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  Stesso Container ID di: $owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved =>
      '  Originali conservati come .cnsbak (ripristinabili).';

  @override
  String patcherLeftUntouched(String reason) {
    return '  Lasciato intatto (patch non sicura): $reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ $count mod condividono un Container ID ma non è stato possibile correggerle in sicurezza (lasciate intatte; potrebbero non apparire in CNS):';
  }

  @override
  String get revertPatchesTitle => 'Annulla le patch dei conflitti';

  @override
  String get revertPatchesDesc =>
      'Ripristina i file originali delle mod modificati dal Patcher di Conflitti.';

  @override
  String get revertPatchesConfirmTitle => 'Annullare le patch dei conflitti?';

  @override
  String get revertPatchesConfirmMessage =>
      'I file originali salvati dal Patcher di Conflitti (.cnsbak) verranno ripristinati. Chiudi prima il gioco. Le mod in conflitto potrebbero non apparire più in CNS.';

  @override
  String get revertPatchesAction => 'Annulla patch';

  @override
  String revertPatchesDone(int count) {
    return 'Ripristinati $count file.';
  }

  @override
  String get revertPatchesNothing => 'Nessun file patchato da ripristinare.';

  @override
  String get settingsGroupPaths => 'Percorsi';

  @override
  String get settingsGroupTools => 'Strumenti';

  @override
  String get settingsAutoOutfit => 'Assegna i costumi automaticamente';

  @override
  String get settingsAutoOutfitDesc =>
      'Quando installi una mod sostitutiva, rileva quale costume sostituisce leggendo i suoi file. Se disattivato, il costume si assegna manualmente.';

  @override
  String get variantChoiceTitle => 'Più varianti della stessa sostituzione';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return 'La mod \"$mod\" contiene più varianti che sostituiscono $outfits. Solo una può essere attiva alla volta. Quale vuoi installare?';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return 'La mod \"$mod\" contiene più varianti che sostituiscono gli stessi file. Solo una può essere attiva alla volta. Quale vuoi installare?';
  }

  @override
  String get variantChoiceInstallAll => 'Installa tutte (come mod separate)';

  @override
  String get installOutfitConflictTitle => 'Costume già in uso';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return 'La mod \"$newMod\" sostituisce il costume $outfits, già assegnato alla mod attiva \"$oldMod\". Solo una può essere attiva alla volta. Quale vuoi lasciare attiva?';
  }

  @override
  String get installOutfitKeepCurrent => 'Mantieni quella attuale';

  @override
  String get installOutfitUseNew => 'Attiva la nuova';

  @override
  String installOutfitNowActive(String active) {
    return 'Ora attiva: $active';
  }

  @override
  String get fileLockErrorTitle => 'Impossibile spostare la mod';

  @override
  String get fileLockErrorMessage =>
      'Un\'altra applicazione potrebbe star usando i file del gioco (FModel, il gioco stesso, un antivirus, Esplora file...). Chiudila e riprova.';

  @override
  String get nexusProfileTooltip => 'Profilo Nexus Mods';

  @override
  String get nexusUserFallback => 'Utente';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => 'Membro';

  @override
  String get nexusPlanSupporter => 'Sostenitore';

  @override
  String get nexusApiRequestsRemaining => 'RICHIESTE API RIMANENTI';

  @override
  String get nexusApiDaily => 'Giornaliere';

  @override
  String get nexusApiHourly => 'Orarie';

  @override
  String get downloadMemberAccountLimit =>
      'Gli account Membro sono limitati a 1,5 MB/s da Nexus Mods';

  @override
  String get downloadSupporterAccountLimit =>
      'Gli account Sostenitore sono limitati a 3 MB/s da Nexus Mods';

  @override
  String get downloadRetryTooltip => 'Riprova';

  @override
  String get downloadRefreshingLink => 'Aggiornamento del link...';

  @override
  String get downloadNoInternet =>
      'Nessuna connessione a Internet. Controlla la rete.';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'Il link di Nexus è scaduto ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'Errore HTTP: $code';
  }

  @override
  String get downloadErrorTimeout => 'Timeout: nessun dato di rete ricevuto';

  @override
  String get splashRootFolder => 'Radice (principale)';

  @override
  String get repairErrorGameNotClosed =>
      'Impossibile chiudere il processo del gioco.';

  @override
  String get errorManifestNotFound =>
      'Manifesto di installazione non trovato. Impossibile disinstallare.';

  @override
  String get downloadResuming => 'Ripresa in corso...';

  @override
  String get apiKeyPromptTitle => 'Configura la tua chiave API di Nexus Mods';

  @override
  String get apiKeyPromptMessage =>
      'Non è stata rilevata nessuna chiave API. Configurarla è facoltativo, ma consigliato per comodità: ti permette di cercare aggiornamenti, scaricare con un clic (nxm://) e caricare copertine e informazioni da Nexus Mods.';

  @override
  String get apiKeyPromptConfigure => 'Configura chiave API';

  @override
  String get apiKeyPromptSkip => 'Salta';

  @override
  String get apiKeyPromptDontShowAgain => 'Non mostrare più questo messaggio';

  @override
  String get adjustCoverTooltip => 'Regola copertina';

  @override
  String get noCoverToAdjust => 'Questa mod non ha una copertina da regolare';

  @override
  String errorAdjustingCoverText(Object error) {
    return 'Errore nella regolazione della copertina: $error';
  }
}
