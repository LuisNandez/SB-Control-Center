// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageDesc => 'Choisissez la langue de l\'application';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutDesc => 'Informations sur l\'application';

  @override
  String get settingsRefreshMetadata => 'Mettre à jour les métadonnées';

  @override
  String get settingsRefreshMetadataDesc =>
      'Revérifie vos mods sur Nexus Mods et complète les informations et images manquantes';

  @override
  String get metadataRefreshDone => 'Métadonnées mises à jour';

  @override
  String get metadataRefreshNoApiKey =>
      'Ajoutez votre clé API Nexus Mods dans les paramètres pour mettre à jour les métadonnées.';

  @override
  String get settingsPathsAndTools => 'Chemins et Outils';

  @override
  String get settingsGameFolder => 'Dossier du jeu';

  @override
  String get settingsGameFolderDesc =>
      'Le dossier racine de votre installation de Stellar Blade.';

  @override
  String get settings7zipPath => 'Chemin de 7-Zip';

  @override
  String get settings7zipPathDesc =>
      'L\'emplacement du fichier 7z.exe pour extraire les mods.';

  @override
  String get settings7zipPathAuto => 'Recherche automatique';

  @override
  String get settingsRepairMods => 'Réparer les mods hérités';

  @override
  String get settingsRepairModsDesc =>
      'Analyse et crée des fichiers d\'information pour les anciens mods en utilisant la base de données locale. Nécessite une clé API.';

  @override
  String get settingsConnectivity => 'Connectivité et Mises à jour';

  @override
  String get settingsApiKey => 'Clé API de Nexus Mods';

  @override
  String get settingsApiKeyDesc =>
      'Nécessaire pour vérifier les mises à jour des mods.';

  @override
  String get settingsApiKeySet => 'Définie';

  @override
  String get settingsApiKeyNotSet => 'Non définie';

  @override
  String get settingsSkippedVersions => 'Gérer les versions ignorées';

  @override
  String get settingsSkippedVersionsDesc =>
      'Gérez les versions de mods que vous avez choisi d\'ignorer.';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count versions ignorées';
  }

  @override
  String get dialogTitleSkippedVersions => 'Versions de mods ignorées';

  @override
  String get dialogNoSkippedVersions =>
      'Vous n\'avez ignoré aucune version de mod.';

  @override
  String get dialogSkippedVersions => 'Version ignorée';

  @override
  String get dialogTitleRepairMods => 'Lancer la réparation des mods hérités ?';

  @override
  String get dialogContentRepairMods =>
      'Attention : Cette fonctionnalité est en cours de développement et peut ne pas être parfaite.\n\nElle analysera les mods sans fichier \'nexus_info.json\' et, s\'ils sont trouvés dans votre base de données locale, en créera un pour eux. Elle tentera également de renommer le dossier du mod pour inclure la version trouvée (par exemple, \'Mon Mod\' -> \'Mon Mod v1.2\').\n\nPriorité de la version :\n1. À partir du nom du dossier.\n2. À partir du champ de description du mod.\n3. À partir de la dernière version sur Nexus Mods (nécessite l\'API).\n\nVoulez-vous continuer ?';

  @override
  String get dialogActionRunRepair => 'Lancer la réparation';

  @override
  String get snackBarGamePathInvalid =>
      'Le dossier sélectionné ne semble pas être un dossier de jeu valide.';

  @override
  String get snackBar7zipPathInvalid =>
      'Le fichier sélectionné doit s\'appeler 7z.exe.';

  @override
  String get snackBarRepairStarted =>
      'Le processus de réparation des mods hérités a commencé...';

  @override
  String snackBarRepairComplete(Object count) {
    return 'Réparation terminée. $count mod(s) ont été mis à jour.';
  }

  @override
  String get snackBarRepairNoMods =>
      'Aucun mod hérité nécessitant une réparation n\'a été trouvé.';

  @override
  String get errorApiRequiredForRepair =>
      'La clé API est requise pour trouver la dernière version des mods sans version locale.';

  @override
  String get installNewMod => 'Installer un mod';

  @override
  String get selectFiles => 'Sélectionner des fichiers';

  @override
  String get selectFolder => 'Sélectionner un dossier';

  @override
  String get installSelectedMod => 'Installer le mod sélectionné';

  @override
  String get filesToInstall => 'Fichiers à installer :';

  @override
  String get cancelSelection => 'Annuler la sélection';

  @override
  String get searchMods => 'Rechercher des mods...';

  @override
  String get enabledMods => 'Mods activés';

  @override
  String get disabledMods => 'Mods désactivés';

  @override
  String get refreshList => 'Actualiser la liste';

  @override
  String get noEnabledMods => 'Aucun mod activé.';

  @override
  String get noDisabledMods => 'Aucun mod désactivé.';

  @override
  String get showInFolder => 'Afficher dans le dossier';

  @override
  String get disableMod => 'Désactiver le mod';

  @override
  String get enableMod => 'Activer le mod';

  @override
  String get deletePermanently => 'Supprimer définitivement';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionnez une langue';

  @override
  String get statusSearchingGame =>
      'Recherche de l\'installation de Stellar Blade...';

  @override
  String get statusGamePathFound => 'Chemin du jeu trouvé !';

  @override
  String get statusGamePathNotFound =>
      'Impossible de trouver automatiquement le chemin du jeu.';

  @override
  String statusErrorFindingGame(Object error) {
    return 'Une erreur s\'est produite lors de la recherche du jeu : $error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount mod(s) activé(s), $disabledCount désactivé(s).';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return 'Erreur lors de la lecture des mods installés : $error';
  }

  @override
  String statusFilesSelected(Object count) {
    return '$count fichier(s) sélectionné(s). Prêt pour l\'installation.';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return 'Dossier \"$folderName\" sélectionné. Prêt pour l\'installation.';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return 'Fichier \"$fileName\" chargé. $count fichier(s) prêt(s) pour l\'installation.';
  }

  @override
  String get statusSelectionCancelled =>
      'Sélection annulée. Choisissez un nouveau mod à installer.';

  @override
  String get statusUpdateComplete => 'Mise à jour terminée.';

  @override
  String get statusInstallationComplete => 'Installation terminée.';

  @override
  String statusError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get dialogTitle7zip => '7-Zip est requis';

  @override
  String get dialogContent7zip =>
      'Pour décompresser ce fichier, l\'application a besoin de 7-Zip.\n\nVeuillez l\'installer depuis sa page officielle, puis appuyez sur \"Confirmer\".';

  @override
  String get dialogContent7zipNotFound =>
      '7-Zip n\'a pas encore été détecté. Veuillez vous assurer qu\'il est installé dans le chemin par défaut et réessayez.';

  @override
  String get dialogTitleMultipleJsons => 'Plusieurs fichiers .json détectés';

  @override
  String dialogContentMultipleJsons(Object count) {
    return '$count fichiers .json ont été détectés. Il pourrait s\'agir d\'un mod avec plusieurs composants.\n\nVoulez-vous les installer tous ensemble dans un seul dossier de mod ?';
  }

  @override
  String get dialogTitleModExists => 'Le mod existe déjà';

  @override
  String dialogContentModExists(Object modName) {
    return 'Un mod nommé \"$modName\" est déjà installé.\n\nVoulez-vous le mettre à jour ? Les anciens fichiers seront supprimés avant l\'installation des nouveaux.';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return 'Une version plus ancienne \'$oldModName\' a été trouvée.\n\nVoulez-vous la supprimer et mettre à jour vers \'$newModName\' ?';
  }

  @override
  String get dialogTitleDeleteMod => 'Supprimer définitivement ?';

  @override
  String dialogContentDeleteMod(Object modName) {
    return 'Vous êtes sur le point de supprimer définitivement le mod \"$modName\". Cette action est irréversible.\n\nÊtes-vous sûr ?';
  }

  @override
  String get dialogActionCancel => 'Annuler';

  @override
  String get dialogActionGoToDownload => 'Aller à la page de téléchargement';

  @override
  String get dialogActionConfirmInstallation => 'Confirmer l\'installation';

  @override
  String get dialogActionUpdateSystem => 'Mettre à jour le système';

  @override
  String get dialogActionInstallAnyway => 'Installer quand même';

  @override
  String get dialogActionDelete => 'Supprimer';

  @override
  String get dialogActionClose => 'Fermer';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return 'Installation par lots terminée. Succès : $successCount, Échecs : $failedCount.';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return 'Le mod \"$modName\" a été installé avec succès.';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return 'Le mod \"$modName\" a été activé.';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return 'Le mod \"$modName\" a été désactivé.';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return 'Le mod \"$modName\" a été supprimé définitivement.';
  }

  @override
  String get snackBarCNSUpdated =>
      'Le système Custom Nanosuit a été mis à jour avec succès.';

  @override
  String get snackBarApiKeySaved => 'La clé API a été enregistrée avec succès.';

  @override
  String get snackBarGamePathSaved =>
      'Le chemin du jeu a été enregistré avec succès.';

  @override
  String get snackBar7zipPathSaved =>
      'Le chemin de 7-Zip a été enregistré avec succès.';

  @override
  String get snackBarSkippedVersionRemoved =>
      'La version ignorée a été supprimée.';

  @override
  String get dropTargetOverlay => 'Déposez les mods ici';

  @override
  String get pathSelectionTitle => 'Chemin de Stellar Blade non trouvé';

  @override
  String get pathSelectionButtonManual =>
      'Sélectionner manuellement le dossier du jeu';

  @override
  String get pathSelectionButtonRetry => 'Réessayer';

  @override
  String errorFolderSelection(Object error) {
    return 'Erreur lors de la sélection du dossier : $error';
  }

  @override
  String errorFileSelection(Object error) {
    return 'Erreur lors de la sélection des fichiers : $error';
  }

  @override
  String errorDecompressing(Object error) {
    return 'Erreur lors de la décompression du fichier : $error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return 'Erreur lors du traitement du fichier : $error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return 'Format de fichier non pris en charge : $extension';
  }

  @override
  String get error7zipRequired => 'Opération annulée : 7-Zip est requis.';

  @override
  String get errorGamePathUndefined => 'Le chemin du jeu n\'est pas défini.';

  @override
  String get errorDestinationNotFound =>
      'Le dossier de destination du jeu n\'existe pas.';

  @override
  String errorUpdateSystem(Object error) {
    return 'Erreur lors de la mise à jour du système : $error';
  }

  @override
  String get errorInstallNoSelection =>
      'Vous n\'avez rien sélectionné à installer.';

  @override
  String get errorInstallModExists =>
      'Installation annulée : le mod existe déjà.';

  @override
  String get errorNoJsonFound =>
      'Chaque mod doit contenir au moins un fichier .json.';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return 'Le fichier $fileName a un format JSON invalide.';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return 'Le fichier $fileName ne semble pas être un mod du Custom Nanosuit System (\"DisplayName\" manquant).';
  }

  @override
  String get errorNoValidDisplayName =>
      'Aucun \"DisplayName\" valide n\'a été trouvé dans les fichiers .json.';

  @override
  String errorEnableMod(Object error) {
    return 'Erreur lors de l\'activation du mod : $error';
  }

  @override
  String errorDisableMod(Object error) {
    return 'Erreur lors de la désactivation du mod : $error';
  }

  @override
  String errorDeleteMod(Object error) {
    return 'Erreur lors de la suppression du mod : $error';
  }

  @override
  String errorOpenFolder(Object path) {
    return 'Impossible d\'ouvrir le dossier : $path';
  }

  @override
  String get statusUpdateSystemCancelled => 'Mise à jour du système annulée.';

  @override
  String get statusUpdatingCNS => 'Mise à jour du Custom Nanosuit System...';

  @override
  String statusExtractingFile(Object fileName) {
    return 'Extraction de $fileName...';
  }

  @override
  String get statusInstallationCancelledByUser =>
      'Installation annulée par l\'utilisateur.';

  @override
  String get errorNoCompatibleFilesInFolder =>
      'Le dossier sélectionné ne contient pas de fichiers de mod compatibles.';

  @override
  String get errorNoCompatibleFilesInArchive =>
      'Le fichier compressé ne contient pas de fichiers de mod compatibles.';

  @override
  String get errorNoJsonInSelection =>
      'La sélection ne contient pas de fichier .json de mod valide.';

  @override
  String get aboutTitle => 'À propos de SB Control Center';

  @override
  String get aboutContent =>
      'SB Control Center est un gestionnaire de mods pour Stellar Blade. Il installe, organise et met à jour vos mods au même endroit, et fonctionne avec le Custom Nanosuit System (CNS) pour les mods de tenues et de nanosuit.\n\nIl se connecte à Nexus Mods pour télécharger, vérifier les mises à jour et donner un Endorse aux mods que vous utilisez.\n\nInclut 7-Zip (7-zip.org) pour extraire les archives .zip, .rar et .7z.';

  @override
  String get aboutEndorseCta =>
      'Vous aimez cette application ? Un Endorse sur Nexus Mods aide beaucoup.';

  @override
  String get aboutEndorseThanks => 'Merci pour votre soutien !';

  @override
  String get aboutLinkText => 'Visitez mon profil de créateur';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return 'Version : $version';
  }

  @override
  String get openModsFolder => 'Ouvrir le dossier des mods';

  @override
  String get openInNexusMods => 'Ouvrir dans Nexus Mods';

  @override
  String get checkForUpdates => 'Vérifier les mises à jour';

  @override
  String updateAvailable(Object version) {
    return 'Mise à jour disponible : v$version';
  }

  @override
  String get dialogTitleApiKey => 'Clé API de Nexus Mods';

  @override
  String get dialogContentApiKey =>
      'Pour vérifier les mises à jour des mods, vous avez besoin d\'une clé API personnelle de Nexus Mods.';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. Cliquez sur le bouton ci-dessous pour ouvrir Nexus Mods et connectez-vous.\n2. Faites défiler jusqu\'en bas de la page, à la section \'Personal API Key\'.\n3. Demandez-la si vous n\'en avez pas encore, puis copiez-la.\n4. Collez-la ici.';

  @override
  String get apiKeyOpenNexusPage => 'Ouvrir la page des clés API';

  @override
  String get apiKey => 'Clé API';

  @override
  String get apiKeyHintText => 'Collez votre clé API ici';

  @override
  String get dialogActionSave => 'Enregistrer';

  @override
  String get apiKeyRemoved => 'Clé API supprimée.';

  @override
  String get invalidApiKeyError => 'Clé API invalide.';

  @override
  String get validatingApiKey => 'Validation en cours...';

  @override
  String get errorApiKeyMissing =>
      'La clé API de Nexus Mods est manquante. Ajoutez-la dans Paramètres › Connectivité et Mises à jour › Clé API de Nexus Mods.';

  @override
  String get statusCheckingUpdates =>
      'Vérification des mises à jour des mods...';

  @override
  String statusUpdatesFound(Object count) {
    return '$count mise(s) à jour trouvée(s) !';
  }

  @override
  String get statusNoUpdates => 'Tous les mods sont à jour.';

  @override
  String get selectModArchive => 'Sélectionner l\'archive du mod';

  @override
  String get viewImageGallery => 'Voir la galerie d\'images';

  @override
  String get imageGallery => 'Galerie d\'images';

  @override
  String get noImagesFound =>
      'Aucune image n\'a été trouvée pour ce mod, ou la clé API n\'a pas été saisie. Veuillez saisir la clé API et vérifier les mises à jour par la suite.';

  @override
  String errorFetchingImages(Object error) {
    return 'Erreur lors de la récupération des images : $error';
  }

  @override
  String get imageMod => 'Image du mod';

  @override
  String get modEnabledBadge => 'Activé';

  @override
  String get modDisabledBadge => 'Désactivé';

  @override
  String get modCategoryOther => 'Non spécifié';

  @override
  String get dialogContentUpdateOptions => 'Que souhaitez-vous faire ?';

  @override
  String get dialogActionIgnoreVersion => 'Ignorer';

  @override
  String get dialogActionSkipVersion => 'Ignorer la version';

  @override
  String get dialogActionGoToDownloadPage => 'Aller au téléchargement';

  @override
  String get installedMods => 'Mods installés';

  @override
  String get filterBy => 'Filtrer par :';

  @override
  String get sortBy => 'Trier par :';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterEnabled => 'Activés';

  @override
  String get filterDisabled => 'Désactivés';

  @override
  String get filterRepaired => 'Réparés';

  @override
  String get sortByName => 'Nom';

  @override
  String get sortByDate => 'Date';

  @override
  String get noModsFound => 'Aucun mod trouvé.';

  @override
  String get viewTypeGrid => 'Vue en grille';

  @override
  String get viewTypeList => 'Vue en liste';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return 'Extraction de $count sur $total : $fileName';
  }

  @override
  String get previewInstallTitle => 'Mods à installer :';

  @override
  String get dialogTitleUE4SS => 'Installation d\'UE4SS détectée';

  @override
  String get dialogContentUE4SS =>
      'L\'outil UE4SS a été détecté. Voulez-vous l\'installer dans \'StellarBlade\\SB\\Binaries\\Win64\' ?\n\nCeci est nécessaire pour que de nombreux mods fonctionnent.';

  @override
  String get dialogActionInstallTool => 'Installer l\'outil';

  @override
  String get statusUE4SSInstallCancelled => 'Installation d\'UE4SS annulée.';

  @override
  String get statusInstallingUE4SS => 'Installation d\'UE4SS...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SS installé avec succès.';

  @override
  String error7zipDecompression(Object error) {
    return 'Erreur de 7-Zip lors de la décompression : $error';
  }

  @override
  String get statusUE4SSInstallComplete => 'Installation d\'UE4SS terminée.';

  @override
  String get dialogTitleAlternativeVersion => 'Version alternative détectée';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return 'Une version alternative de ce mod est déjà installée : \'$oldModName\'.\n\nVous êtes sur le point d\'installer une alternative différente nommée \'$newModName\'.';
  }

  @override
  String get dialogActionReplace => 'Remplacer';

  @override
  String get dialogActionInstallAsNew => 'Installer comme nouveau';

  @override
  String get dialogTitleUpdate => 'Mise à jour disponible';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Vous êtes sur le point de mettre à jour le mod \'$modName\'.\n\nVersion installée : $oldVersion\nNouvelle version : $newVersion';
  }

  @override
  String get dialogTitleDowngrade => 'Version plus ancienne détectée';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Attention : vous êtes sur le point d\'installer une version plus ancienne du mod \'$modName\'.\n\nVersion installée : $oldVersion\nVersion à installer : $newVersion';
  }

  @override
  String get dialogTitleReinstall => 'Réinstaller le mod';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return 'Vous êtes sur le point de réinstaller la version \'$version\' du mod \'$modName\'.';
  }

  @override
  String get dialogActionReinstall => 'Réinstaller';

  @override
  String get editModNameTooltip => 'Modifier le nom du mod';

  @override
  String get setCoverTooltip => 'Définir une image de couverture personnalisée';

  @override
  String get setCoverText => 'Définir la couverture';

  @override
  String get restoreOriginalCoverText => 'Restaurer la couverture originale';

  @override
  String errorSavingCoverText(Object error) {
    return 'Erreur lors de l\'enregistrement de l\'image de couverture : $error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return 'Erreur lors de la restauration de l\'image de couverture originale : $error';
  }

  @override
  String get editVersionText => 'Modifier la version';

  @override
  String get customVersionText => 'Version personnalisée';

  @override
  String get editTagText => 'Modifier le tag';

  @override
  String get customTagText => 'Tag personnalisé';

  @override
  String get dialogTitleEditModName => 'Modifier le nom du mod';

  @override
  String get dialogActionResetToDefault => 'Réinitialiser par défaut';

  @override
  String get dialogLabelNewName => 'Nouveau nom';

  @override
  String errorModNameExists(Object modName) {
    return 'Un mod nommé \"$modName\" existe déjà.';
  }

  @override
  String get dialogTitleRepairedModWarning => 'Avertissement de mod réparé';

  @override
  String get dialogContentRepairedModWarning =>
      'Ce mod pourrait ne pas avoir les informations de version correctes. Il est recommandé de réinstaller la dernière version pour assurer la compatibilité.';

  @override
  String get repairedModTooltip => 'Informations sur le mod réparé';

  @override
  String get disableAllModsTooltip => 'Désactiver tous les mods';

  @override
  String get deleteAllModsTooltip => 'Supprimer tous les mods désactivés';

  @override
  String get dialogTitleDisableAll => 'Désactiver tous les mods ?';

  @override
  String dialogContentDisableAll(int count) {
    return 'Êtes-vous sûr de vouloir désactiver les $count mods activés ? Ils seront déplacés dans le dossier de sauvegarde.';
  }

  @override
  String get dialogTitleDeleteAll => 'Supprimer les mods désactivés ?';

  @override
  String dialogContentDeleteAll(int count) {
    return 'Vous êtes sur le point de supprimer définitivement les $count mods désactivés. Cette action est irréversible.\n\nÊtes-vous sûr ?';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return 'Les $count mods activés ont été désactivés.';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return 'Les $count mods désactivés ont été supprimés définitivement.';
  }

  @override
  String get snackBarNoModsToDisable =>
      'Il n\'y a aucun mod activé à désactiver.';

  @override
  String get snackBarNoModsToDelete =>
      'Il n\'y a aucun mod désactivé à supprimer.';

  @override
  String get enableAllModsTooltip => 'Activer tous les mods';

  @override
  String get dialogTitleEnableAll => 'Activer tous les mods ?';

  @override
  String dialogContentEnableAll(int count) {
    return 'Êtes-vous sûr de vouloir activer les $count mods désactivés ? Ils seront déplacés dans le dossier principal des mods.';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return 'Les $count mods désactivés ont été activés.';
  }

  @override
  String get snackBarNoModsToEnable =>
      'Il n\'y a aucun mod désactivé à activer.';

  @override
  String get editNotes => 'Modifier les notes';

  @override
  String get notesHintText => 'Ajoutez vos notes personnelles ici...';

  @override
  String get modAuthor => 'Auteur';

  @override
  String get modSummary => 'Résumé';

  @override
  String get modDescription => 'Description';

  @override
  String get noDescriptionAvailable => 'Aucune description disponible.';

  @override
  String get personalNotes => 'Notes personnelles';

  @override
  String get noNotesAvailable => 'Aucune note ajoutée pour le moment.';

  @override
  String get modDetailsTitle => 'Détails du mod';

  @override
  String get modVersion => 'Version';

  @override
  String get modCategory => 'Catégorie';

  @override
  String get dialogTitleAddUrl => 'Ajouter un lien de mod';

  @override
  String get dialogLabelUrl => 'URL du mod';

  @override
  String get errorInvalidUrl => 'Veuillez entrer une URL valide.';

  @override
  String get addLinkTooltip => 'Ajouter un lien de téléchargement pour ce mod';

  @override
  String get addLinkButtonText => 'Ajouter un lien';

  @override
  String get openLinkButtonText => 'Ouvrir le lien';

  @override
  String get editModTitle => 'Modifier les détails du mod';

  @override
  String get modNameLabel => 'Nom du mod';

  @override
  String get authorLabel => 'Auteur';

  @override
  String get summaryLabel => 'Description / Résumé';

  @override
  String get notesLabel => 'Notes personnelles';

  @override
  String get urlLabel => 'URL de téléchargement';

  @override
  String get changeCoverButton => 'Changer l\'image de couverture';

  @override
  String get editButtonTooltip => 'Modifier le mod';

  @override
  String get errorSavingNotes => 'Erreur lors de l\'enregistrement des notes';

  @override
  String get errorSavingUrl => 'Erreur lors de l\'enregistrement de l\'URL';

  @override
  String get errorSavingChanges =>
      'Erreur lors de l\'enregistrement des modifications';

  @override
  String get errorTranslation => 'Impossible de traduire la description';

  @override
  String get translateSummary => 'Traduire le résumé';

  @override
  String get translateDescription => 'Traduire la description';

  @override
  String get restoreOriginalDescription => 'Restaurer la description originale';

  @override
  String get dialogTitleUE4SSReinstall => 'Réinstaller UE4SS';

  @override
  String get dialogContentUE4SSReinstall =>
      'UE4SS semble déjà être installé. Voulez-vous écraser l\'installation existante ? Cela peut être utile si vous suspectez des fichiers corrompus.';

  @override
  String get dialogTitleCNSReinstall => 'Réinstaller le système CNS';

  @override
  String get dialogContentCNSReinstall =>
      'Le système CNS principal semble déjà être installé. Voulez-vous le réinstaller ? Vos mods existants ne seront pas affectés.';

  @override
  String dialogTitleUninstall(Object componentName) {
    return 'Désinstaller $componentName';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return 'Êtes-vous sûr de vouloir désinstaller $componentName ? Cette action supprimera les fichiers principaux du composant mais n\'affectera pas vos mods installés.';
  }

  @override
  String get dialogActionUninstall => 'Oui, désinstaller';

  @override
  String statusUninstalling(Object componentName) {
    return 'Désinstallation de $componentName...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentName désinstallé avec succès';
  }

  @override
  String errorUninstalling(Object componentName) {
    return 'Erreur lors de la désinstallation de $componentName';
  }

  @override
  String get settingsCoreComponents => 'Composants principaux';

  @override
  String get installedStatus => 'Installé';

  @override
  String get notInstalledStatus => 'Non détecté';

  @override
  String get uninstallButton => 'Désinstaller';

  @override
  String get cnsCoreSystem => 'Custom Nanosuit System';

  @override
  String get ue4ssInstallationDetected =>
      'Installation existante d\'UE4SS détectée et adoptée';

  @override
  String get cnsInstallationDetected =>
      'Installation principale de CNS existante détectée et adoptée';

  @override
  String get ue4ssRequiredTitle => 'UE4SS requis';

  @override
  String get ue4ssRequiredContent =>
      'Pour installer le système principal de CNS, vous devez d\'abord installer UE4SS. Vous pouvez le télécharger depuis le lien suivant :';

  @override
  String get uninstallDependencyTitle => 'Dépendance détectée';

  @override
  String get uninstallDependencyContent =>
      'Vous devez désinstaller le système principal de CNS avant de pouvoir désinstaller UE4SS, car CNS en dépend.';

  @override
  String get dialogActionUnderstood => 'Compris';

  @override
  String get appTitleNoCns => 'Custom Nanosuit System (Non installé)';

  @override
  String get dialogTitleCNSUpdate =>
      'Mettre à jour le système principal de CNS';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return 'Vous êtes sur le point de mettre à jour CNS de la version $oldVersion à la nouvelle version $newVersion. Souhaitez-vous continuer ?';
  }

  @override
  String get dialogTitleCNSDowngrade => 'Rétrograder la version de CNS';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return 'Attention ! Vous êtes sur le point d\'installer une version plus ancienne de CNS ($newVersion) que votre version actuelle ($oldVersion). Cela peut causer des problèmes. Êtes-vous sûr ?';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return 'Vous avez déjà la version $version de CNS installée. Voulez-vous réinstaller les fichiers quand même ?';
  }

  @override
  String get dialogActionUpdate => 'Mettre à jour';

  @override
  String get dialogActionDowngrade => 'Rétrograder';

  @override
  String get dialogTitleCNSInstall => 'Installer le système principal de CNS';

  @override
  String get dialogContentCNSInstall =>
      'Vous êtes sur le point d\'installer le système de base Custom Nanosuit System (CNS). Ceci est nécessaire pour que les mods CNS fonctionnent. Souhaitez-vous continuer ?';

  @override
  String get dialogActionInstall => 'Installer';

  @override
  String get settingsDeveloperOptions => 'Options pour les développeurs';

  @override
  String get devDeleteNexusInfoTitle =>
      'Supprimer tous les fichiers nexus_info.json';

  @override
  String get devDeleteNexusInfoDesc =>
      'Supprime tous les fichiers de métadonnées du gestionnaire de chaque mod. Ceci est utile pour forcer une réparation complète.';

  @override
  String get devExtractIdsTitle => 'Extraire les identifiants';

  @override
  String get devExtractIdsDesc =>
      'Crée un fichier nommé \'ID Mods.json\' sur votre bureau contenant le displayName et le nexusId de chaque mod.';

  @override
  String get devConfirmDeleteTitle => 'Confirmer la suppression';

  @override
  String get devConfirmDeleteDesc =>
      'Êtes-vous sûr de vouloir supprimer définitivement tous les fichiers nexus_info.json ? Cela supprimera tous les noms, couvertures et métadonnées personnalisés. Cette action est irréversible.';

  @override
  String get devDeleteSuccessTitle => 'Suppression terminée';

  @override
  String devDeleteSuccessDesc(Object count) {
    return '$count fichiers nexus_info.json supprimés avec succès.';
  }

  @override
  String get devConfirmExtractTitle => 'Confirmer l\'extraction';

  @override
  String get devConfirmExtractDesc =>
      'Ceci analysera tous vos mods et créera \'ID Mods.json\' sur votre bureau. Cela écrasera tout fichier existant du même nom. Voulez-vous continuer ?';

  @override
  String get devExtractAction => 'Extraire';

  @override
  String get devTestSelfUpdateTitle => 'Tester l\'auto-installation';

  @override
  String get devTestSelfUpdateDesc =>
      'Sélectionnez le paquet .zip de l\'application et installez-le par-dessus cette application, comme le fera la mise à jour automatique.';

  @override
  String get devSelfUpdateUnsupported =>
      'La mise à jour automatique n\'est disponible que sous Windows.';

  @override
  String get devSelfUpdatePickTitle =>
      'Sélectionnez le .zip de SB Control Center';

  @override
  String get devSelfUpdateFailed => 'Impossible d\'installer la mise à jour';

  @override
  String get devSelfUpdateDryRunTitle => 'Le paquet est valide (mode test)';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return '$count fichiers trouvés. Rien n\'a été installé, car il ne s\'agit pas d\'une build de release.';
  }

  @override
  String get devSelfUpdateConfirmTitle => 'Installer la mise à jour ?';

  @override
  String get devSelfUpdateConfirmDesc =>
      'L\'application va se fermer, remplacer ses fichiers par ceux du paquet, puis se rouvrir automatiquement.';

  @override
  String get devSelfUpdateInstallAction => 'Installer et redémarrer';

  @override
  String get devSelfUpdateProgressTitle => 'Mise à jour de SB Control Center';

  @override
  String get devSelfUpdateExtracting => 'Extraction du paquet…';

  @override
  String get devSelfUpdateInstalling => 'Installation des fichiers…';

  @override
  String get devSelfUpdateRestarting => 'Redémarrage…';

  @override
  String get appUpdateAvailableTitle => 'Update available';

  @override
  String get appUpdateAvailableMsg =>
      'The app will download the update, install it and restart automatically.';

  @override
  String get appUpdateInstalledLabel => 'INSTALLED';

  @override
  String get appUpdateAvailableLabel => 'AVAILABLE';

  @override
  String appUpdateDownloadSize(String size) {
    return 'Download size: $size';
  }

  @override
  String get appUpdateNow => 'Update now';

  @override
  String get appUpdateLater => 'Later';

  @override
  String get appUpdateSkip => 'Skip this version';

  @override
  String get appUpdateDownloading => 'Downloading update…';

  @override
  String get appUpdateUpToDate => 'You already have the latest version';

  @override
  String get appUpdateCheckFailed => 'Could not check for updates';

  @override
  String get settingsCheckAppUpdate => 'Check for app updates';

  @override
  String get settingsCheckAppUpdateDesc =>
      'Look for a new version of SB Control Center on GitHub';

  @override
  String get settingsChangelog => 'Changelog';

  @override
  String get settingsChangelogDesc => 'See what\'s new in each version';

  @override
  String changelogWhatsNewTitle(String version) {
    return 'What\'s new in $version';
  }

  @override
  String get changelogUpdatedSubtitle =>
      'SB Control Center was updated successfully';

  @override
  String get changelogHistoryTitle => 'Changelog';

  @override
  String changelogInstalledVersion(String version) {
    return 'Installed version: $version';
  }

  @override
  String get changelogInstalledBadge => 'Installed';

  @override
  String get changelogPrereleaseBadge => 'Pre-release';

  @override
  String get changelogEmpty => 'This release has no notes.';

  @override
  String get changelogViewOnGithub => 'View on GitHub';

  @override
  String get changelogLoadFailed =>
      'Could not load the changelog. Check your connection.';

  @override
  String get changelogRetry => 'Retry';

  @override
  String get devExtractNoData =>
      'Aucun mod avec des identifiants valides n\'a été trouvé pour l\'extraction.';

  @override
  String get devExtractDesktopNotFound =>
      'Erreur : Impossible de trouver le répertoire du Bureau.';

  @override
  String get devExtractSuccessTitle => 'Extraction terminée';

  @override
  String devExtractSuccessDesc(Object path) {
    return 'Fichier créé avec succès à l\'emplacement : $path';
  }

  @override
  String get errorDialogTitle => 'Une erreur s\'est produite';

  @override
  String get modDetailsCategory => 'Catégorie';

  @override
  String get modDetailsAuthor => 'Auteur';

  @override
  String get modDetailsNexusId => 'ID Nexus';

  @override
  String get modDetailsInstalledOn => 'Installé le';

  @override
  String get unknownAuthor => 'Inconnu';

  @override
  String get statusInstalling => 'Installation...';

  @override
  String statusInstallingMod(int index, int total, String modName) {
    return 'Installation de $index/$total : $modName';
  }

  @override
  String byText(Object author) {
    return 'par $author';
  }

  @override
  String get filterUpdatesAvailable => 'Mises à jour disponibles';

  @override
  String snackBarUpdateIgnored(String modName) {
    return 'Mise à jour pour \'$modName\' ignorée pour cette session.';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return 'La version \'$version\' de \'$modName\' sera ignorée lors des futures vérifications.';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return 'Mise à jour des métadonnées pour \'$displayName\' ($arg1 sur $arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return 'Mod Générique Installé : $modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return 'Installé dans $path.\nCe mod n\'est pas géré par l\'application et doit être désinstallé manuellement.';
  }

  @override
  String genericModInstallError(String modName) {
    return 'Échec de l\'installation du mod générique : $modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => 'Générique';

  @override
  String get modTypeMovies => 'Vidéos';

  @override
  String get modTypeSave => 'Sauvegarde';

  @override
  String get modTypeConfig => 'Configuration';

  @override
  String get modTypeSplash => 'Splash';

  @override
  String get replacesOutfitTitle => 'Remplace la Tenue';

  @override
  String get replacesOutfitClearTooltip => 'Effacer la sélection de tenue';

  @override
  String get replacesOutfitSelectTooltip => 'Sélectionner la tenue à remplacer';

  @override
  String get replacesOutfitNone =>
      'Aucune tenue sélectionnée.\nLe tag sera \'Générique\'.';

  @override
  String get replacesOutfitSearchHint => 'Rechercher des tenues...';

  @override
  String get modTypeReplacement => 'Remplacement';

  @override
  String get replacesOutfitHover => 'Survolez une tenue pour voir un aperçu.';

  @override
  String get dialogTitleOutfitReplacement => 'Remplacement de Tenue ?';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return 'Le mod \'$modName\' est-il un remplacement de tenue ?\n\nSélectionnez \'Oui\' pour choisir la tenue qu\'il remplace, ou \'Non\' pour l\'installer comme un mod générique.';
  }

  @override
  String get dialogActionNo => 'Non';

  @override
  String get dialogActionYes => 'Oui';

  @override
  String get dialogTitleOutfitConflict => 'Conflit de Tenue Détecté';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return 'La tenue \'$outfitName\' est déjà remplacée par le mod \'$modName\'.\n\nVoulez-vous désactiver \'$modName\' et activer celui-ci à la place ?';
  }

  @override
  String get dialogActionActivateAndDisable => 'Désactiver et Activer';

  @override
  String get replacementModSwitchTitle => 'Mod de remplacement';

  @override
  String get replacementModSwitchDesc =>
      'Cochez si ce mod est conçu pour remplacer une combinaison dans le jeu.';

  @override
  String get settingsShowModTagsTitle => 'Afficher les tags de type de mod';

  @override
  String get settingsShowModTagsDesc =>
      'Afficher les tags de type de mod (par ex. CNS, Générique) sur chaque carte de mod dans la liste.';

  @override
  String get modTypeLogic => 'Logique';

  @override
  String get patcherStarted => '=== Patcher Dart pour StellarBlade Démarré ===';

  @override
  String workingDirectory(String path) {
    return 'Répertoire de travail : $path';
  }

  @override
  String modsDirNotFound(String path) {
    return 'Le répertoire ~mods n\'existe pas à l\'emplacement : $path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  AVERTISSEMENT : Impossible d\'analyser le dossier $path. Ignoré.';
  }

  @override
  String errorDetails(String error) {
    return '  Erreur : $error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return '$count fichiers .utoc trouvés';
  }

  @override
  String get noModsFound2 => 'Aucun mod trouvé à traiter.';

  @override
  String get patcherSummaryTitle =>
      '\n=== Résumé du Patcher (Données brutes) ===';

  @override
  String processedMods(int count) {
    return '$count mods traités.';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return '$count conflits de Container ID corrigés.';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return '$count conflits de Package ID trouvés.';
  }

  @override
  String get fatalErrorTitle => '\n=== ERREUR FATALE ===';

  @override
  String patcherServiceError(String error) {
    return 'Erreur dans PatcherService : $error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- Analyse : $fileName ---';
  }

  @override
  String get warnUcasNotFound =>
      '  AVERTISSEMENT : Fichier .ucas introuvable. Ignoré.';

  @override
  String get warnCorruptHeader =>
      '  AVERTISSEMENT : En-tête corrompu, la taille de l\'entrée dépasse la taille du fichier. Ignoré.';

  @override
  String conflictContainerIdDetected(int id) {
    return '  CONFLIT de Container ID détecté : $id';
  }

  @override
  String generatingNewId(int id) {
    return '  Génération d\'un nouvel ID : $id';
  }

  @override
  String get utocFilePatched => '  Fichier .utoc patché.';

  @override
  String get patchingUcasFile => '  Patch du fichier .ucas...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  Remplacements réussis dans .ucas : $count';
  }

  @override
  String get patchComplete => '  Patch terminé !';

  @override
  String idRegisteredNoConflict(int id) {
    return '  ID $id enregistré. Aucun conflit.';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  ERREUR lors du traitement de $fileName : $error';
  }

  @override
  String get statusRunningPatcher => 'Exécution du Patcher de Conflits...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ Succès ! $count conflits de Container ID causant des plantages ont été corrigés.';
  }

  @override
  String get summaryNoContainerIdConflicts =>
      '✅ Aucun conflit de Container ID (plantage) n\'a été trouvé.';

  @override
  String get summaryNoPackageIdConflicts =>
      '✅ Bonne nouvelle ! Aucun conflit sérieux de Package ID (écrasement) n\'a été trouvé.';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ Avertissement ! $count groupes de mods ne pouvant pas coexister ont été trouvés :';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • Ce groupe de mods est en concurrence pour $count fichiers :';
  }

  @override
  String get patcherSummaryDialogTitle => 'Résumé du Patcher';

  @override
  String get dialogActionShowFullLog => 'Afficher le journal complet';

  @override
  String get fullLogDialogTitle => 'Journal du Patcher de Conflits (Dart)';

  @override
  String get runConflictPatcherTitle => 'Exécuter le Patcher de Conflits';

  @override
  String get runConflictPatcherSubtitlePython =>
      'Corrige les plantages Container_Id et Package_Id';

  @override
  String get processingCover => 'Traitement de la couverture...';

  @override
  String get apiKeyTooltip =>
      'La clé API est requise pour l\'extraction intelligente de l\'ID Nexus.';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return 'Options d\'installation - Mod $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection =>
      'Sélectionnez les options que vous souhaitez installer. Les fichiers principaux requis seront installés automatiquement.';

  @override
  String get snackBarSpecialModNoSelection =>
      'Sélectionnez au moins une option pour continuer.';

  @override
  String get dialogActionInstallSelection => 'Installer la sélection';

  @override
  String get downloadStatusFetching => 'Obtention des données de Nexus Mods...';

  @override
  String get downloadStatusFetchingFailed =>
      'Échec de l\'obtention du lien de téléchargement. Vérifiez votre clé API ou votre connexion.';

  @override
  String downloadStatusDownloading(String fileName) {
    return 'Téléchargement de $fileName';
  }

  @override
  String get downloadStatusError => 'Erreur lors du téléchargement du fichier.';

  @override
  String downloadStatusException(String error) {
    return 'Exception : $error';
  }

  @override
  String get dialogTitleDownloadModManager => 'Téléchargement de Mod Manager';

  @override
  String get launchGameText => 'Lancer Stellar Blade';

  @override
  String get stopGameText => 'Arrêter Stellar Blade';

  @override
  String get dialogTitleStopGame => 'Arrêter Stellar Blade ?';

  @override
  String get dialogContentStopGame =>
      'Le jeu sera fermé. La progression non sauvegardée sera perdue.';

  @override
  String get dialogActionStopGame => 'Arrêter';

  @override
  String get notificationGameStopped => 'Stellar Blade arrêté';

  @override
  String get errorStoppingGame => 'Impossible d\'arrêter le jeu';

  @override
  String get mod801DialogTitle => 'Configuration Steam requise';

  @override
  String get mod801DialogIntro =>
      'Le mod Random Splash a été installé. Pour qu\'il fonctionne automatiquement au lancement du jeu, vous devez configurer Steam.';

  @override
  String get mod801Step1 =>
      '1. Générez le chemin exact pour votre PC ci-dessous et copiez-le.';

  @override
  String get mod801Step2 => '2. Ouvrez votre bibliothèque Steam.';

  @override
  String get mod801Step3 =>
      '3. Faites un clic droit sur Stellar Blade -> Propriétés.';

  @override
  String get mod801Step4 =>
      '4. Dans l\'onglet \'Général\', collez le code dans \'Options de lancement\'.';

  @override
  String get mod801BtnGenerate => 'Générer le chemin';

  @override
  String get mod801BtnSteam => 'Ouvrir Steam';

  @override
  String get mod801BtnCopy => 'Copier';

  @override
  String get mod801PathGenerated => 'Chemin généré avec succès.';

  @override
  String get mod801PathCopied => 'Commande copiée dans le presse-papiers !';

  @override
  String get statusVerifyingMods => 'Vérification de l\'intégrité des mods...';

  @override
  String errorSelecting7Zip(String error) {
    return 'Erreur lors de la sélection de 7-Zip : $error';
  }

  @override
  String get errorInvalidFolderRetry =>
      'Le dossier sélectionné ne semble pas correct. Veuillez réessayer.';

  @override
  String errorSelectingFolderDynamic(String error) {
    return 'Erreur lors de la sélection du dossier : $error';
  }

  @override
  String get statusNoNewModsInstalled =>
      'L\'installation n\'a produit aucun nouveau mod.';

  @override
  String get errorDisableModBeforeDelete =>
      'Veuillez désactiver le mod avant de le supprimer.';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return 'Activés : $successCount (Ignorés : $skippedCount en raison de conflits)';
  }

  @override
  String get snackBarDeveloperModeEnabled => 'Mode développeur activé !';

  @override
  String errorRenamingMod(String error) {
    return 'Erreur lors du renommage du mod : $error';
  }

  @override
  String get notificationTitleError => 'Erreur';

  @override
  String get errorGamePathNotFoundNotification => 'Chemin du jeu introuvable.';

  @override
  String get notificationLaunchingGame => 'Lancement de Stellar Blade...';

  @override
  String get errorLaunchingGame => 'Erreur lors du lancement du jeu';

  @override
  String get dialogTitleSelect7zip => 'Sélectionnez le fichier 7z.exe';

  @override
  String get dialogTitleSelectGameFolder =>
      'Veuillez sélectionner le dossier principal de StellarBlade';

  @override
  String get dialogTitleSelectCover =>
      'Sélectionnez une couverture pour le mod';

  @override
  String get errorGamePathNotFoundException => 'Chemin du jeu introuvable.';

  @override
  String get errorGamePathNotDefined => 'Le chemin du jeu n\'est pas défini.';

  @override
  String get errorLogicModsPathNotDefined =>
      'Le chemin des mods Logic n\'est pas défini.';

  @override
  String get errorUe4ssModsPathNotDefined =>
      'Le chemin des mods UE4SS n\'est pas défini.';

  @override
  String get errorGenericModsPathNotDefined =>
      'Le chemin des mods génériques (~mods) n\'est pas défini.';

  @override
  String get errorReplaceNoOldVersion =>
      'Tentative de remplacement d\'un mod, mais aucune ancienne version n\'a été identifiée.';

  @override
  String errorDeleteOldModVersion(String modName) {
    return 'Impossible de supprimer l\'ancienne version du mod ($modName).';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return 'Impossible de supprimer le mod existant ($modName) pour le réinstaller.';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return 'Impossible de supprimer le mod existant ($modName) pour le réinstaller après plusieurs tentatives.';
  }

  @override
  String get errorMoviesModNoValidFiles =>
      'Le mod de films ne contient aucun fichier vidéo valide.';

  @override
  String get errorInstallPathUndetermined =>
      'Le chemin d\'installation n\'a pas pu être déterminé.';

  @override
  String get errorMoviesPathsNotDefined =>
      'Les chemins des films ne sont pas définis.';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return 'nexus_info.json introuvable pour $modName.';
  }

  @override
  String get errorMenuVideoLimitReached =>
      'Limite de 99 vidéos dans le menu atteinte.';

  @override
  String get errorModRequires529 =>
      'Le mod nécessite le Mod ID 529 pour fonctionner (ne contient que des fichiers WebM).';

  @override
  String get errorSplashPathsNotDefined =>
      'Les chemins des splashs ne sont pas définis.';

  @override
  String get errorSplashNoValidImages =>
      'Aucune image valide n\'a été trouvée dans le mod.';

  @override
  String get errorCouldNotDeleteDirectory =>
      'Impossible de supprimer le répertoire.';

  @override
  String get errorGameExeNotFound =>
      'Le fichier exécutable du jeu (.exe) est introuvable dans le dossier principal ou dans Binaries.';

  @override
  String get dialogTitleSplashOptions => 'Options de Splash (Images)';

  @override
  String get dialogContentSplashOptions =>
      'Sélectionnez les images que vous souhaitez installer. Vous pouvez choisir des dossiers entiers (lots) ou des images individuelles.';

  @override
  String get snackBarSplashNoSelection =>
      'Veuillez sélectionner au moins une image.';

  @override
  String get dialogContentSpecialModSingleSelection =>
      'Sélectionnez une seule option à installer.';

  @override
  String get activeDownloads => 'Téléchargements actifs';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mods',
      one: 'mod',
    );
    return 'Téléchargement de $count $_temp0';
  }

  @override
  String get downloadError => 'Erreur';

  @override
  String get downloadCancelled => 'Annulé';

  @override
  String get downloadPause => 'Pause';

  @override
  String get downloadResume => 'Reprendre';

  @override
  String get downloadCancel => 'Annuler';

  @override
  String get errorNexusInfoNotFound => 'nexus_info.json introuvable.';

  @override
  String logFixingCorruptedJson(String displayName) {
    return 'Correction du nexus_info.json corrompu pour $displayName.';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return 'Échec de la mise à jour des métadonnées pour $displayName : $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return 'Désactivation préventive du mod de films suite à l\'activation du Mod 529 : $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return 'Désactivation préventive du mod d\'écran d\'accueil suite à l\'activation du Mod 801 : $modName';
  }

  @override
  String logRestoringTildeComponent(String folderName) {
    return 'Restauration du composant ~mods : $folderName';
  }

  @override
  String logRestoringUe4ssComponent(String folderName) {
    return 'Restauration du composant UE4SS : $folderName';
  }

  @override
  String logErrorRestoringLogicMod(String error) {
    return 'Erreur lors de la restauration des composants LogicMod : $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return 'Archivage du composant ~mods : $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return 'Archivage du composant UE4SS : $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return 'Erreur lors de l\'archivage des composants LogicMod : $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return 'Ignoré $modName : Une variante active de ce mod existe déjà.';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return 'Ignoré $modName : Conflit avec une tenue déjà occupée.';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return 'Impossible de nettoyer les sauvegardes vidéo pour $modName : $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return 'Nouvel ID Nexus $nexusId détecté. Récupération des métadonnées...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return 'Métadonnées récupérées et appliquées pour $nexusId.';
  }

  @override
  String logFallbackByteCopy(String error) {
    return 'Échec de la copie normale, utilisation de la force brute par octets : $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return 'Avertissement : Impossible de supprimer le fichier modifié : $error';
  }

  @override
  String get logMod801BatPatched =>
      'Script .bat du Mod 801 patché avec succès pour ce système.';

  @override
  String logMod801BatPatchError(String error) {
    return 'Erreur lors de la tentative de patch du fichier .bat du Mod 801 : $error';
  }

  @override
  String get errorHomeDirNotFound =>
      'Impossible de trouver la variable d\'environnement du répertoire de base.';

  @override
  String get downloadFetchingPlaceholder => 'Récupération en cours...';

  @override
  String get downloadErrorLink =>
      'Impossible de récupérer le lien de téléchargement';

  @override
  String get downloadErrorGeneral => 'Échec du téléchargement';

  @override
  String get downloadPausedStatus => 'En pause';

  @override
  String get settingsFixGameStartup => 'Réparer le non-démarrage du jeu';

  @override
  String get settingsFixGameStartupDesc =>
      'À utiliser si le jeu se ferme ou plante au lancement. Désinstalle temporairement UE4SS et CNS, lance le jeu une fois, puis les réinstalle.';

  @override
  String get repairConfirmTitle => 'Réparer le démarrage du jeu ?';

  @override
  String get repairConfirmMessage =>
      'UE4SS et CNS seront désinstallés (leurs fichiers sont conservés), le jeu démarrera puis se fermera automatiquement, puis tout sera réinstallé et le jeu relancé. Ne fermez pas l\'application pendant le processus.';

  @override
  String get repairConfirmAction => 'Lancer la réparation';

  @override
  String get launchRetryTitle => 'Le jeu n\'a pas démarré';

  @override
  String get launchRetryMessage =>
      'Stellar Blade n\'a pas démarré après deux tentatives. C\'est généralement dû à UE4SS ou à CNS. « Réparer le non-démarrage du jeu » les désinstalle temporairement, lance le jeu une fois, puis les réinstalle. Lancer maintenant ?';

  @override
  String get launchRetryAction => 'Réparer maintenant';

  @override
  String get repairOverlayTitle => 'Réparation du démarrage';

  @override
  String get repairOverlayWarning =>
      'Ne fermez ni l\'application ni le jeu manuellement pendant ce temps.';

  @override
  String get repairStepCloseGame => 'Fermeture du jeu s\'il est ouvert';

  @override
  String get repairStepStashCns =>
      'Désinstallation de CNS (sauvegarde des fichiers)';

  @override
  String get repairStepStashUe4ss =>
      'Désinstallation de UE4SS (sauvegarde des fichiers)';

  @override
  String get repairStepLaunchClean => 'Démarrage du jeu sans UE4SS ni CNS';

  @override
  String get repairStepWaitInit => 'Attente du chargement du jeu';

  @override
  String get repairStepCloseAuto => 'Fermeture automatique du jeu';

  @override
  String get repairStepRestoreUe4ss => 'Réinstallation de UE4SS';

  @override
  String get repairStepRestoreCns => 'Réinstallation de CNS';

  @override
  String get repairStepLaunchFinal => 'Lancement du jeu';

  @override
  String get repairStatusSkipped => 'ignoré';

  @override
  String get repairResultSuccess => 'Réparation terminée. Le jeu a été lancé.';

  @override
  String get repairResultErrorRestored =>
      'La réparation a échoué, mais UE4SS et CNS ont été remis en place.';

  @override
  String get repairResultErrorRestoreFailed =>
      'La réparation a échoué et les fichiers n\'ont pas pu être restaurés. Ils le seront automatiquement au prochain démarrage de l\'application.';

  @override
  String get repairErrorGameNotStarted => 'Le jeu ne s\'est pas lancé à temps.';

  @override
  String get repairButtonClose => 'Fermer';

  @override
  String get repairRecoveredNotice =>
      'Une réparation interrompue a été détectée : les fichiers UE4SS et CNS ont été restaurés.';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return 'Nouvelle édition installée : $name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return 'Ce mod a maintenant $count éditions installées.';
  }

  @override
  String get previewTagNewEdition => 'nouvelle édition';

  @override
  String get previewTagUpdate => 'mise à jour';

  @override
  String editionsInstalledTooltip(Object count) {
    return '$count éditions de ce mod installées';
  }

  @override
  String editionLabelValue(Object edition) {
    return 'Édition : $edition';
  }

  @override
  String get otherEditionsTitle => 'Autres éditions installées';

  @override
  String get detailsStatusEnabled => 'Activé';

  @override
  String get detailsStatusDisabled => 'Désactivé';

  @override
  String get detailsInformation => 'Informations';

  @override
  String get detailsRowAuthor => 'Auteur';

  @override
  String get detailsRowType => 'Type';

  @override
  String get detailsRowInstalled => 'Installé';

  @override
  String get detailsRowModified => 'Dernière modification';

  @override
  String get detailsRowNexusId => 'ID Nexus';

  @override
  String get detailsRowFolder => 'Dossier';

  @override
  String get detailsCopyPath => 'Copier le chemin';

  @override
  String get detailsCopied => 'Copié dans le presse-papiers';

  @override
  String get detailsEndorse => 'Endorse';

  @override
  String get detailsEndorsed => 'Endorsed';

  @override
  String endorseWaitLabel(Object minutes) {
    return 'Attendre $minutes min';
  }

  @override
  String get endorseSuccessTitle => 'Mod endorsed';

  @override
  String get endorseRemovedTitle => 'Endorse retiré';

  @override
  String get endorseFailedTitle => 'Impossible de mettre à jour l\'endorse';

  @override
  String get endorseErrNotNexus =>
      'Ce mod n\'est pas lié à une page Nexus Mods, il ne peut donc pas être endorsé.';

  @override
  String get endorseErrNoApiKey =>
      'Ajoutez votre clé API Nexus Mods dans les Paramètres pour endorser des mods.';

  @override
  String endorseErrWait(Object minutes) {
    return 'Nexus impose d\'attendre 15 minutes après le téléchargement d\'un mod avant de pouvoir l\'endorser. Réessayez dans $minutes min.';
  }

  @override
  String get endorseErrNotDownloaded =>
      'Nexus ne permet d\'endorser que les mods que vous avez téléchargés avec votre compte.';

  @override
  String get endorseErrOwnMod =>
      'Vous ne pouvez pas endorser votre propre mod.';

  @override
  String get endorseErrRateLimit =>
      'Vous avez atteint la limite de requêtes de Nexus. Réessayez plus tard.';

  @override
  String get endorseErrInvalidKey =>
      'Nexus a rejeté votre clé API. Vérifiez-la dans les Paramètres.';

  @override
  String get endorseErrNetwork =>
      'Impossible de joindre Nexus Mods. Vérifiez votre connexion et réessayez.';

  @override
  String get endorseErrUnknown =>
      'Nexus n\'a pas pu traiter la requête. Réessayez plus tard.';

  @override
  String get endorseRemoveConfirmTitle => 'Retirer l\'endorse ?';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return '$name ne sera plus endorsé sur Nexus Mods.';
  }

  @override
  String get endorseRemoveConfirmAction => 'Retirer';

  @override
  String get detailsUpdateAction => 'Mettre à jour';

  @override
  String get detailsShowMore => 'Afficher plus';

  @override
  String get detailsShowLess => 'Afficher moins';

  @override
  String get detailsAddNote => 'Ajouter une note';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tenues',
      one: '1 tenue',
      zero: 'Aucune tenue',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return '$count sélectionnée(s)';
  }

  @override
  String get outfitsChoose => 'Choisir des tenues';

  @override
  String get outfitsDone => 'Terminé';

  @override
  String get outfitsFilterAll => 'Toutes';

  @override
  String get outfitsFilterSelected => 'Sélectionnées';

  @override
  String get outfitsClearAll => 'Tout effacer';

  @override
  String get outfitsRemove => 'Retirer';

  @override
  String get outfitsActionSelect => 'Sélectionner';

  @override
  String get outfitsActionDeselect => 'Désélectionner';

  @override
  String outfitsNoResults(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get outfitsSelectedEmpty =>
      'Aucune tenue sélectionnée pour le moment.';

  @override
  String get outfitsNoPreview => 'Aucun aperçu disponible';

  @override
  String get replacementOffConfirmTitle =>
      'Désactiver le mod de remplacement ?';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les $count tenues sélectionnées seront retirées de ce mod.',
      one: 'La tenue sélectionnée sera retirée de ce mod.',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => 'Désactiver';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count mods désactivés : ils remplacent des tenues déjà utilisées par d’autres mods',
      one:
          '1 mod désactivé : il remplace une tenue déjà utilisée par un autre mod',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  Même Container ID que : $owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved =>
      '  Originaux conservés en .cnsbak (restaurables).';

  @override
  String patcherLeftUntouched(String reason) {
    return '  Laissé intact (patch non sûr) : $reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ $count mod(s) partagent un Container ID mais n\'ont pas pu être corrigés en toute sécurité (laissés intacts ; ils peuvent ne pas apparaître dans CNS) :';
  }

  @override
  String get revertPatchesTitle => 'Annuler les patchs de conflits';

  @override
  String get revertPatchesDesc =>
      'Restaure les fichiers de mods originaux modifiés par le Patcher de Conflits.';

  @override
  String get revertPatchesConfirmTitle => 'Annuler les patchs de conflits ?';

  @override
  String get revertPatchesConfirmMessage =>
      'Les fichiers originaux sauvegardés par le Patcher de Conflits (.cnsbak) seront restaurés. Fermez d\'abord le jeu. Les mods en conflit risquent de ne plus apparaître dans CNS.';

  @override
  String get revertPatchesAction => 'Annuler';

  @override
  String revertPatchesDone(int count) {
    return '$count fichier(s) restauré(s).';
  }

  @override
  String get revertPatchesNothing => 'Aucun fichier patché à annuler.';

  @override
  String get settingsGroupPaths => 'Chemins';

  @override
  String get settingsGroupTools => 'Outils';

  @override
  String get settingsAutoOutfit => 'Attribuer les tenues automatiquement';

  @override
  String get settingsAutoOutfitDesc =>
      'Lors de l\'installation d\'un mod de remplacement, détecte quelle tenue il remplace en lisant ses fichiers. Si désactivé, la tenue est attribuée manuellement.';

  @override
  String get variantChoiceTitle => 'Plusieurs variantes du même remplacement';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return '« $mod » contient plusieurs variantes qui remplacent $outfits. Une seule peut être active à la fois. Laquelle voulez-vous installer ?';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return '« $mod » contient plusieurs variantes qui remplacent les mêmes fichiers. Une seule peut être active à la fois. Laquelle voulez-vous installer ?';
  }

  @override
  String get variantChoiceInstallAll => 'Tout installer (comme mods séparés)';

  @override
  String get installOutfitConflictTitle => 'Tenue déjà utilisée';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return 'Le mod « $newMod » remplace la tenue $outfits, déjà attribuée au mod actif « $oldMod ». Un seul peut être actif à la fois. Lequel garder actif ?';
  }

  @override
  String get installOutfitKeepCurrent => 'Garder l\'actuel';

  @override
  String get installOutfitUseNew => 'Activer le nouveau';

  @override
  String installOutfitNowActive(String active) {
    return 'Mod actif : $active';
  }

  @override
  String get fileLockErrorTitle => 'Impossible de déplacer le mod';

  @override
  String get fileLockErrorMessage =>
      'Une autre application utilise peut-être les fichiers du jeu (FModel, le jeu lui-même, un antivirus, l\'Explorateur de fichiers...). Fermez-la et réessayez.';

  @override
  String get nexusProfileTooltip => 'Profil Nexus Mods';

  @override
  String get nexusUserFallback => 'Utilisateur';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => 'Membre';

  @override
  String get nexusPlanSupporter => 'Soutien';

  @override
  String get nexusApiRequestsRemaining => 'REQUÊTES API RESTANTES';

  @override
  String get nexusApiDaily => 'Quotidiennes';

  @override
  String get nexusApiHourly => 'Par heure';

  @override
  String get downloadMemberAccountLimit =>
      'Les comptes Membre sont limités à 1,5 Mo/s par Nexus Mods';

  @override
  String get downloadSupporterAccountLimit =>
      'Les comptes Soutien sont limités à 3 Mo/s par Nexus Mods';

  @override
  String get downloadRetryTooltip => 'Réessayer';

  @override
  String get downloadRefreshingLink => 'Actualisation du lien...';

  @override
  String get downloadNoInternet =>
      'Pas de connexion Internet. Vérifiez votre réseau.';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'Le lien Nexus a expiré ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'Erreur HTTP : $code';
  }

  @override
  String get downloadErrorTimeout =>
      'Délai dépassé : aucune donnée réseau reçue';

  @override
  String get splashRootFolder => 'Racine (principal)';

  @override
  String get repairErrorGameNotClosed =>
      'Le processus du jeu n\'a pas pu être fermé.';

  @override
  String get errorManifestNotFound =>
      'Manifeste d\'installation introuvable. Désinstallation impossible.';

  @override
  String get downloadResuming => 'Reprise...';

  @override
  String get apiKeyPromptTitle => 'Configurez votre clé API Nexus Mods';

  @override
  String get apiKeyPromptMessage =>
      'Aucune clé API n\'a été détectée. La configurer est facultatif, mais recommandé pour plus de confort : elle permet de rechercher les mises à jour, de télécharger en un clic (nxm://) et de charger les images et les infos de Nexus Mods.';

  @override
  String get apiKeyPromptConfigure => 'Configurer la clé API';

  @override
  String get apiKeyPromptSkip => 'Ignorer';

  @override
  String get apiKeyPromptDontShowAgain => 'Ne plus afficher ce message';

  @override
  String get adjustCoverTooltip => 'Ajuster la couverture';

  @override
  String get noCoverToAdjust => 'Ce mod n\'a pas de couverture à ajuster';

  @override
  String errorAdjustingCoverText(Object error) {
    return 'Erreur lors de l\'ajustement de la couverture : $error';
  }
}
