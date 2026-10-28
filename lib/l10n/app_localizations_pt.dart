// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => 'Configurações';

  @override
  String get settingsGeneral => 'Geral';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDesc => 'Escolha o idioma do aplicativo';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsAboutDesc => 'Informações sobre o aplicativo';

  @override
  String get settingsRefreshMetadata => 'Atualizar metadados';

  @override
  String get settingsRefreshMetadataDesc =>
      'Verifica seus mods novamente no Nexus Mods e completa os dados e imagens que faltam';

  @override
  String get metadataRefreshDone => 'Metadados atualizados';

  @override
  String get metadataRefreshNoApiKey =>
      'Adicione sua chave de API do Nexus Mods nas configurações para atualizar os metadados.';

  @override
  String get settingsPathsAndTools => 'Caminhos e Ferramentas';

  @override
  String get settingsGameFolder => 'Pasta do Jogo';

  @override
  String get settingsGameFolderDesc =>
      'A pasta raiz da sua instalação do Stellar Blade.';

  @override
  String get settings7zipPath => 'Caminho do 7-Zip';

  @override
  String get settings7zipPathDesc =>
      'O local do arquivo 7z.exe para extrair mods.';

  @override
  String get settings7zipPathAuto => 'Busca automática';

  @override
  String get settingsRepairMods => 'Reparar Mods Legados';

  @override
  String get settingsRepairModsDesc =>
      'Verifica e cria arquivos de informação para mods antigos usando o banco de dados local. Requer chave de API.';

  @override
  String get settingsConnectivity => 'Conectividade e Atualizações';

  @override
  String get settingsApiKey => 'Chave de API do Nexus Mods';

  @override
  String get settingsApiKeyDesc =>
      'Necessária para verificar as atualizações dos mods.';

  @override
  String get settingsApiKeySet => 'Definida';

  @override
  String get settingsApiKeyNotSet => 'Não definida';

  @override
  String get settingsSkippedVersions => 'Gerenciar Versões Ignoradas';

  @override
  String get settingsSkippedVersionsDesc =>
      'Gerencie as versões de mods que você escolheu ignorar.';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count versões ignoradas';
  }

  @override
  String get dialogTitleSkippedVersions => 'Versões de Mod Ignoradas';

  @override
  String get dialogNoSkippedVersions =>
      'Você não ignorou nenhuma versão de mod.';

  @override
  String get dialogSkippedVersions => 'Versão Ignorada';

  @override
  String get dialogTitleRepairMods => 'Executar Reparo de Mods Legados?';

  @override
  String get dialogContentRepairMods =>
      'Aviso: Este recurso está em desenvolvimento e pode не ser perfeito.\n\nEle verificará os mods sem um arquivo \'nexus_info.json\' e, se encontrado em seu banco de dados local, criará um para eles. Ele também tentará renomear a pasta do mod para incluir a versão encontrada (ex., \'Meu Mod\' -> \'Meu Mod v1.2\').\n\nPrioridade de Versão:\n1. Do nome da pasta.\n2. Do campo de descrição do mod.\n3. Da versão mais recente no Nexus Mods (requer API).\n\nDeseja continuar?';

  @override
  String get dialogActionRunRepair => 'Executar Reparo';

  @override
  String get snackBarGamePathInvalid =>
      'A pasta selecionada não parece ser uma pasta de jogo válida.';

  @override
  String get snackBar7zipPathInvalid =>
      'O arquivo selecionado deve se chamar 7z.exe.';

  @override
  String get snackBarRepairStarted =>
      'O processo de reparo de mods legados foi iniciado...';

  @override
  String snackBarRepairComplete(Object count) {
    return 'Reparo concluído. $count mod(s) foram atualizados.';
  }

  @override
  String get snackBarRepairNoMods =>
      'Nenhum mod legado que precisasse de reparo foi encontrado.';

  @override
  String get errorApiRequiredForRepair =>
      'A Chave de API é necessária para encontrar a versão mais recente para mods sem uma versão local.';

  @override
  String get installNewMod => 'Instalar Mod';

  @override
  String get selectFiles => 'Selecionar Arquivos';

  @override
  String get selectFolder => 'Selecionar Pasta';

  @override
  String get installSelectedMod => 'Instalar Mod Selecionado';

  @override
  String get filesToInstall => 'Arquivos para Instalar:';

  @override
  String get cancelSelection => 'Cancelar Seleção';

  @override
  String get searchMods => 'Buscar mods...';

  @override
  String get enabledMods => 'Mods Ativados';

  @override
  String get disabledMods => 'Mods Desativados';

  @override
  String get refreshList => 'Atualizar lista';

  @override
  String get noEnabledMods => 'Nenhum mod ativado.';

  @override
  String get noDisabledMods => 'Nenhum mod desativado.';

  @override
  String get showInFolder => 'Mostrar na pasta';

  @override
  String get disableMod => 'Desativar mod';

  @override
  String get enableMod => 'Ativar mod';

  @override
  String get deletePermanently => 'Excluir permanentemente';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecione um idioma';

  @override
  String get statusSearchingGame =>
      'Procurando a instalação do Stellar Blade...';

  @override
  String get statusGamePathFound => 'Caminho do jogo encontrado!';

  @override
  String get statusGamePathNotFound =>
      'Não foi possível encontrar o caminho do jogo automaticamente.';

  @override
  String statusErrorFindingGame(Object error) {
    return 'Ocorreu um erro ao procurar o jogo: $error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount mod(s) ativado(s), $disabledCount desativado(s).';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return 'Erro ao ler os mods instalados: $error';
  }

  @override
  String statusFilesSelected(Object count) {
    return '$count arquivo(s) selecionado(s). Pronto para instalar.';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return 'Pasta \"$folderName\" selecionada. Pronta para instalar.';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return 'Arquivo \"$fileName\" carregado. $count arquivo(s) prontos para instalar.';
  }

  @override
  String get statusSelectionCancelled =>
      'Seleção cancelada. Escolha um novo mod para instalar.';

  @override
  String get statusUpdateComplete => 'Atualização completa.';

  @override
  String get statusInstallationComplete => 'Instalação completa.';

  @override
  String statusError(Object error) {
    return 'Erro: $error';
  }

  @override
  String get dialogTitle7zip => '7-Zip é Necessário';

  @override
  String get dialogContent7zip =>
      'Para descompactar este arquivo, o aplicativo precisa do 7-Zip.\n\nPor favor, instale-o a partir de sua página oficial e, em seguida, pressione \"Confirmar\".';

  @override
  String get dialogContent7zipNotFound =>
      'O 7-Zip ainda не foi detectado. Verifique se ele está instalado no caminho padrão e tente novamente.';

  @override
  String get dialogTitleMultipleJsons => 'Vários Arquivos .json Detectados';

  @override
  String dialogContentMultipleJsons(Object count) {
    return '$count arquivos .json foram detectados. Pode ser um mod com vários componentes.\n\nDeseja instalá-los todos juntos em uma única pasta de mod?';
  }

  @override
  String get dialogTitleModExists => 'O Mod Já Existe';

  @override
  String dialogContentModExists(Object modName) {
    return 'Um mod chamado \"$modName\" já está instalado.\n\nDeseja atualizá-lo? Os arquivos antigos serão excluídos antes de instalar os novos.';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return 'Uma versão mais antiga \'$oldModName\' foi encontrada.\n\nDeseja removê-la e atualizar para \'$newModName\'?';
  }

  @override
  String get dialogTitleDeleteMod => 'Excluir Permanentemente?';

  @override
  String dialogContentDeleteMod(Object modName) {
    return 'Você está prestes a excluir permanentemente o mod \"$modName\". Esta ação não pode ser desfeita.\n\nTem certeza?';
  }

  @override
  String get dialogActionCancel => 'Cancelar';

  @override
  String get dialogActionGoToDownload => 'Ir para a Página de Download';

  @override
  String get dialogActionConfirmInstallation => 'Confirmar Instalação';

  @override
  String get dialogActionUpdateSystem => 'Atualizar Sistema';

  @override
  String get dialogActionInstallAnyway => 'Instalar Mesmo Assim';

  @override
  String get dialogActionDelete => 'Excluir';

  @override
  String get dialogActionClose => 'Fechar';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return 'Instalação em lote concluída. Sucesso: $successCount, Falha: $failedCount.';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return 'Mod \"$modName\" instalado com sucesso.';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return 'Mod \"$modName\" ativado.';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return 'Mod \"$modName\" desativado.';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return 'Mod \"$modName\" excluído permanentemente.';
  }

  @override
  String get snackBarCNSUpdated =>
      'Custom Nanosuit System atualizado com sucesso.';

  @override
  String get snackBarApiKeySaved => 'Chave de API salva com sucesso.';

  @override
  String get snackBarGamePathSaved => 'Caminho do jogo salvo com sucesso.';

  @override
  String get snackBar7zipPathSaved => 'Caminho do 7-Zip salvo com sucesso.';

  @override
  String get snackBarSkippedVersionRemoved => 'Versão ignorada removida.';

  @override
  String get dropTargetOverlay => 'Arraste os mods aqui';

  @override
  String get pathSelectionTitle => 'Caminho do Stellar Blade Não Encontrado';

  @override
  String get pathSelectionButtonManual =>
      'Selecionar Pasta do Jogo Manualmente';

  @override
  String get pathSelectionButtonRetry => 'Tentar Novamente';

  @override
  String errorFolderSelection(Object error) {
    return 'Erro ao selecionar a pasta: $error';
  }

  @override
  String errorFileSelection(Object error) {
    return 'Erro ao selecionar arquivos: $error';
  }

  @override
  String errorDecompressing(Object error) {
    return 'Erro ao descompactar o arquivo: $error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return 'Erro ao processar o arquivo: $error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return 'Formato de arquivo não suportado: $extension';
  }

  @override
  String get error7zipRequired => 'Operação cancelada: 7-Zip é necessário.';

  @override
  String get errorGamePathUndefined => 'O caminho do jogo не está definido.';

  @override
  String get errorDestinationNotFound =>
      'A pasta de destino do jogo não existe.';

  @override
  String errorUpdateSystem(Object error) {
    return 'Erro ao atualizar o sistema: $error';
  }

  @override
  String get errorInstallNoSelection =>
      'Você não selecionou nada para instalar.';

  @override
  String get errorInstallModExists => 'Instalação cancelada: o mod já existe.';

  @override
  String get errorNoJsonFound =>
      'Cada mod deve conter pelo menos um arquivo .json.';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return 'O arquivo $fileName tem um formato JSON inválido.';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return 'O arquivo $fileName não parece ser um mod do Custom Nanosuit System (faltando \"DisplayName\").';
  }

  @override
  String get errorNoValidDisplayName =>
      'Nenhum \"DisplayName\" válido foi encontrado nos arquivos .json.';

  @override
  String errorEnableMod(Object error) {
    return 'Erro ao ativar o mod: $error';
  }

  @override
  String errorDisableMod(Object error) {
    return 'Erro ao desativar o mod: $error';
  }

  @override
  String errorDeleteMod(Object error) {
    return 'Erro ao excluir o mod: $error';
  }

  @override
  String errorOpenFolder(Object path) {
    return 'Não foi possível abrir a pasta: $path';
  }

  @override
  String get statusUpdateSystemCancelled => 'Atualização do sistema cancelada.';

  @override
  String get statusUpdatingCNS => 'Atualizando o Custom Nanosuit System...';

  @override
  String statusExtractingFile(Object fileName) {
    return 'Extraindo $fileName...';
  }

  @override
  String get statusInstallationCancelledByUser =>
      'Instalação cancelada pelo usuário.';

  @override
  String get errorNoCompatibleFilesInFolder =>
      'A pasta selecionada não contém arquivos de mod compatíveis.';

  @override
  String get errorNoCompatibleFilesInArchive =>
      'O arquivo compactado não contém arquivos de mod compatíveis.';

  @override
  String get errorNoJsonInSelection =>
      'A seleção не contém um arquivo .json de mod válido.';

  @override
  String get aboutTitle => 'Sobre o SB Control Center';

  @override
  String get aboutContent =>
      'O SB Control Center é um gerenciador de mods para Stellar Blade. Ele instala, organiza e atualiza seus mods em um só lugar e funciona com o Custom Nanosuit System (CNS) para mods de trajes e nanosuit.\n\nConecta-se ao Nexus Mods para baixar, verificar atualizações e dar Endorse nos mods que você usa.\n\nInclui o 7-Zip (7-zip.org) para extrair arquivos .zip, .rar e .7z.';

  @override
  String get aboutEndorseCta =>
      'Gostando do app? Um Endorse no Nexus Mods ajuda muito.';

  @override
  String get aboutEndorseThanks => 'Obrigado pelo seu apoio!';

  @override
  String get aboutLinkText => 'Visite meu perfil de criador';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return 'Versão: $version';
  }

  @override
  String get openModsFolder => 'Abrir Pasta de Mods';

  @override
  String get openInNexusMods => 'Abrir no Nexus Mods';

  @override
  String get checkForUpdates => 'Verificar atualizações';

  @override
  String updateAvailable(Object version) {
    return 'Atualização disponível: v$version';
  }

  @override
  String get dialogTitleApiKey => 'Chave de API do Nexus Mods';

  @override
  String get dialogContentApiKey =>
      'Para verificar atualizações de mods, você precisa de uma chave de API pessoal do Nexus Mods.';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. Clique no botão abaixo para abrir o Nexus Mods e faça login.\n2. Role até o final da página, na seção \'Personal API Key\'.\n3. Solicite-a se ainda não tiver uma e copie-a.\n4. Cole-a aqui.';

  @override
  String get apiKeyOpenNexusPage => 'Abrir página de chaves de API';

  @override
  String get apiKey => 'Chave de API';

  @override
  String get apiKeyHintText => 'Cole sua chave de API aqui';

  @override
  String get dialogActionSave => 'Salvar';

  @override
  String get apiKeyRemoved => 'Chave de API removida.';

  @override
  String get invalidApiKeyError => 'Chave de API inválida.';

  @override
  String get validatingApiKey => 'Validando...';

  @override
  String get errorApiKeyMissing =>
      'A chave de API do Nexus Mods não está configurada. Adicione-a em Configurações › Conectividade e Atualizações › Chave de API do Nexus Mods.';

  @override
  String get statusCheckingUpdates => 'Verificando atualizações de mods...';

  @override
  String statusUpdatesFound(Object count) {
    return '$count atualização(ões) encontrada(s)!';
  }

  @override
  String get statusNoUpdates => 'Todos os mods estão atualizados.';

  @override
  String get selectModArchive => 'Selecionar Arquivo de Mod';

  @override
  String get viewImageGallery => 'Ver Galeria de Imagens';

  @override
  String get imageGallery => 'Galeria de Imagens';

  @override
  String get noImagesFound =>
      'Nenhuma imagem foi encontrada para este mod, ou a chave de API не foi inserida. Por favor, insira a chave de API e verifique as atualizações depois.';

  @override
  String errorFetchingImages(Object error) {
    return 'Erro ao buscar imagens: $error';
  }

  @override
  String get imageMod => 'Imagem do Mod';

  @override
  String get modEnabledBadge => 'Ativado';

  @override
  String get modDisabledBadge => 'Desativado';

  @override
  String get modCategoryOther => 'Não especificado';

  @override
  String get dialogContentUpdateOptions => 'O que você gostaria de fazer?';

  @override
  String get dialogActionIgnoreVersion => 'Ignorar';

  @override
  String get dialogActionSkipVersion => 'Pular Versão';

  @override
  String get dialogActionGoToDownloadPage => 'Ir para Download';

  @override
  String get installedMods => 'Mods Instalados';

  @override
  String get filterBy => 'Filtrar por:';

  @override
  String get sortBy => 'Ordenar por:';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterEnabled => 'Ativados';

  @override
  String get filterDisabled => 'Desativados';

  @override
  String get filterRepaired => 'Reparados';

  @override
  String get sortByName => 'Nome';

  @override
  String get sortByDate => 'Data';

  @override
  String get noModsFound => 'Nenhum mod encontrado.';

  @override
  String get viewTypeGrid => 'Visualização em grade';

  @override
  String get viewTypeList => 'Visualização em lista';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return 'Extraindo $count de $total: $fileName';
  }

  @override
  String get previewInstallTitle => 'Mods a Serem Instalados:';

  @override
  String get dialogTitleUE4SS => 'Instalação do UE4SS Detectada';

  @override
  String get dialogContentUE4SS =>
      'A ferramenta UE4SS foi detectada. Deseja instalá-la em \'StellarBlade\\SB\\Binaries\\Win64\'?\n\nIsso é necessário para que muitos mods funcionem.';

  @override
  String get dialogActionInstallTool => 'Instalar Ferramenta';

  @override
  String get statusUE4SSInstallCancelled => 'Instalação do UE4SS cancelada.';

  @override
  String get statusInstallingUE4SS => 'Instalando UE4SS...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SS instalado com sucesso.';

  @override
  String error7zipDecompression(Object error) {
    return 'Erro do 7-Zip durante a descompressão: $error';
  }

  @override
  String get statusUE4SSInstallComplete => 'Instalação do UE4SS concluída.';

  @override
  String get dialogTitleAlternativeVersion => 'Versão Alternativa Detectada';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return 'Uma versão alternativa deste mod já está instalada: \'$oldModName\'.\n\nVocê está prestes a instalar uma alternativa diferente chamada \'$newModName\'.';
  }

  @override
  String get dialogActionReplace => 'Substituir';

  @override
  String get dialogActionInstallAsNew => 'Instalar como Novo';

  @override
  String get dialogTitleUpdate => 'Atualização Disponível';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Você está prestes a atualizar o mod \'$modName\'.\n\nVersão instalada: $oldVersion\nNova versão: $newVersion';
  }

  @override
  String get dialogTitleDowngrade => 'Versão Mais Antiga Detectada';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Aviso: Você está prestes a instalar uma versão mais antiga do mod \'$modName\'.\n\nVersão instalada: $oldVersion\nVersão a ser instalada: $newVersion';
  }

  @override
  String get dialogTitleReinstall => 'Reinstalar Mod';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return 'Você está prestes a reinstalar a versão \'$version\' do mod \'$modName\'.';
  }

  @override
  String get dialogActionReinstall => 'Reinstalar';

  @override
  String get editModNameTooltip => 'Editar nome do mod';

  @override
  String get setCoverTooltip => 'Definir imagem de capa personalizada';

  @override
  String get setCoverText => 'Definir Capa';

  @override
  String get restoreOriginalCoverText => 'Restaurar Capa Original';

  @override
  String errorSavingCoverText(Object error) {
    return 'Erro ao salvar a imagem da capa: $error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return 'Erro ao restaurar a imagem da capa original: $error';
  }

  @override
  String get editVersionText => 'Editar Versão';

  @override
  String get customVersionText => 'Versão Personalizada';

  @override
  String get editTagText => 'Editar Etiqueta';

  @override
  String get customTagText => 'Etiqueta Personalizada';

  @override
  String get dialogTitleEditModName => 'Editar Nome do Mod';

  @override
  String get dialogActionResetToDefault => 'Restaurar para Padrão';

  @override
  String get dialogLabelNewName => 'Novo nome';

  @override
  String errorModNameExists(Object modName) {
    return 'Um mod com o nome \"$modName\" já existe.';
  }

  @override
  String get dialogTitleRepairedModWarning => 'Aviso de Mod Reparado';

  @override
  String get dialogContentRepairedModWarning =>
      'Este mod pode não ter as informações de versão corretas. Recomenda-se reinstalar a versão mais recente para garantir a compatibilidade.';

  @override
  String get repairedModTooltip => 'Informações sobre o mod reparado';

  @override
  String get disableAllModsTooltip => 'Desativar todos os mods';

  @override
  String get deleteAllModsTooltip => 'Excluir todos os mods desativados';

  @override
  String get dialogTitleDisableAll => 'Desativar Todos os Mods?';

  @override
  String dialogContentDisableAll(int count) {
    return 'Tem certeza de que deseja desativar todos os $count mods ativados? Eles serão movidos para a pasta de backup.';
  }

  @override
  String get dialogTitleDeleteAll => 'Excluir Mods Desativados?';

  @override
  String dialogContentDeleteAll(int count) {
    return 'Você está prestes a excluir permanentemente todos os $count mods desativados. Esta ação não pode ser desfeita.\n\nTem certeza?';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return 'Todos os $count mods ativados foram desativados.';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return 'Todos os $count mods desativados foram excluídos permanentemente.';
  }

  @override
  String get snackBarNoModsToDisable => 'Não há mods ativados para desativar.';

  @override
  String get snackBarNoModsToDelete => 'Não há mods desativados para excluir.';

  @override
  String get enableAllModsTooltip => 'Ativar todos os mods';

  @override
  String get dialogTitleEnableAll => 'Ativar Todos os Mods?';

  @override
  String dialogContentEnableAll(int count) {
    return 'Tem certeza de que deseja ativar todos os $count mods desativados? Eles serão movidos para a pasta principal de mods.';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return 'Todos os $count mods desativados foram ativados.';
  }

  @override
  String get snackBarNoModsToEnable => 'Não há mods desativados para ativar.';

  @override
  String get editNotes => 'Editar Notas';

  @override
  String get notesHintText => 'Adicione suas notas pessoais aqui...';

  @override
  String get modAuthor => 'Autor';

  @override
  String get modSummary => 'Resumo';

  @override
  String get modDescription => 'Descrição';

  @override
  String get noDescriptionAvailable => 'Nenhuma descrição disponível.';

  @override
  String get personalNotes => 'Notas Pessoais';

  @override
  String get noNotesAvailable => 'Nenhuma nota adicionada ainda.';

  @override
  String get modDetailsTitle => 'Detalhes do Mod';

  @override
  String get modVersion => 'Versão';

  @override
  String get modCategory => 'Categoria';

  @override
  String get dialogTitleAddUrl => 'Adicionar Link do Mod';

  @override
  String get dialogLabelUrl => 'URL do Mod';

  @override
  String get errorInvalidUrl => 'Por favor, insira uma URL válida.';

  @override
  String get addLinkTooltip => 'Adicionar um link de download para este mod';

  @override
  String get addLinkButtonText => 'Adicionar Link';

  @override
  String get openLinkButtonText => 'Abrir Link';

  @override
  String get editModTitle => 'Editar Detalhes do Mod';

  @override
  String get modNameLabel => 'Nome do Mod';

  @override
  String get authorLabel => 'Autor';

  @override
  String get summaryLabel => 'Descrição / Resumo';

  @override
  String get notesLabel => 'Notas Pessoais';

  @override
  String get urlLabel => 'URL de Download';

  @override
  String get changeCoverButton => 'Alterar Imagem da Capa';

  @override
  String get editButtonTooltip => 'Editar Mod';

  @override
  String get errorSavingNotes => 'Erro ao salvar as notas';

  @override
  String get errorSavingUrl => 'Erro ao salvar a URL';

  @override
  String get errorSavingChanges => 'Erro ao Salvar Alterações';

  @override
  String get errorTranslation => 'Não foi possível traduzir a descrição';

  @override
  String get translateSummary => 'Traduzir resumo';

  @override
  String get translateDescription => 'Traduzir descrição';

  @override
  String get restoreOriginalDescription => 'Restaurar descrição original';

  @override
  String get dialogTitleUE4SSReinstall => 'Reinstalar UE4SS';

  @override
  String get dialogContentUE4SSReinstall =>
      'O UE4SS já parece estar instalado. Deseja substituir a instalação existente? Isso pode ser útil se você suspeitar de arquivos corrompidos.';

  @override
  String get dialogTitleCNSReinstall => 'Reinstalar Sistema CNS';

  @override
  String get dialogContentCNSReinstall =>
      'O sistema CNS principal já parece estar instalado. Deseja reinstalá-lo? Seus mods existentes não serão afetados.';

  @override
  String dialogTitleUninstall(Object componentName) {
    return 'Desinstalar $componentName';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return 'Tem certeza de que deseja desinstalar $componentName? Esta ação removerá os arquivos do componente principal, mas не afetará seus mods instalados.';
  }

  @override
  String get dialogActionUninstall => 'Sim, desinstalar';

  @override
  String statusUninstalling(Object componentName) {
    return 'Desinstalando $componentName...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentName desinstalado com sucesso';
  }

  @override
  String errorUninstalling(Object componentName) {
    return 'Erro ao desinstalar $componentName';
  }

  @override
  String get settingsCoreComponents => 'Componentes Principais';

  @override
  String get installedStatus => 'Instalado';

  @override
  String get notInstalledStatus => 'Não detectado';

  @override
  String get uninstallButton => 'Desinstalar';

  @override
  String get cnsCoreSystem => 'Custom Nanosuit System';

  @override
  String get ue4ssInstallationDetected =>
      'Instalação existente do UE4SS detectada e adotada';

  @override
  String get cnsInstallationDetected =>
      'Instalação principal do CNS existente detectada e adotada';

  @override
  String get ue4ssRequiredTitle => 'UE4SS Necessário';

  @override
  String get ue4ssRequiredContent =>
      'Para instalar o Sistema Principal do CNS, você deve primeiro instalar o UE4SS. Você pode baixá-lo no seguinte link:';

  @override
  String get uninstallDependencyTitle => 'Dependência Detectada';

  @override
  String get uninstallDependencyContent =>
      'Você deve desinstalar o Sistema Principal do CNS antes de poder desinstalar o UE4SS, pois o CNS depende dele.';

  @override
  String get dialogActionUnderstood => 'Entendido';

  @override
  String get appTitleNoCns => 'Custom Nanosuit System (Não Instalado)';

  @override
  String get dialogTitleCNSUpdate => 'Atualizar Sistema Principal do CNS';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return 'Você está prestes a atualizar o CNS da versão $oldVersion para a nova versão $newVersion. Deseja continuar?';
  }

  @override
  String get dialogTitleCNSDowngrade => 'Fazer Downgrade da Versão do CNS';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return 'Aviso! Você está prestes a instalar uma versão mais antiga do CNS ($newVersion) do que a sua atual ($oldVersion). Isso pode causar problemas. Tem certeza?';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return 'Você já tem a versão $version do CNS instalada. Deseja reinstalar os arquivos mesmo assim?';
  }

  @override
  String get dialogActionUpdate => 'Atualizar';

  @override
  String get dialogActionDowngrade => 'Fazer Downgrade';

  @override
  String get dialogTitleCNSInstall => 'Instalar Sistema Principal do CNS';

  @override
  String get dialogContentCNSInstall =>
      'Você está prestes a instalar o sistema base Custom Nanosuit System (CNS). Isso é necessário para que os mods do CNS funcionem. Deseja continuar?';

  @override
  String get dialogActionInstall => 'Instalar';

  @override
  String get settingsDeveloperOptions => 'Opções de Desenvolvedor';

  @override
  String get devDeleteNexusInfoTitle =>
      'Excluir Todos os Arquivos nexus_info.json';

  @override
  String get devDeleteNexusInfoDesc =>
      'Remove todos os arquivos de metadados do gerenciador de cada mod. Isso é útil para forçar um reparo completo.';

  @override
  String get devExtractIdsTitle => 'Extrair Identificadores';

  @override
  String get devExtractIdsDesc =>
      'Cria um arquivo chamado \'ID Mods.json\' na sua área de trabalho contendo o displayName e o nexusId de cada mod.';

  @override
  String get devConfirmDeleteTitle => 'Confirmar Exclusão';

  @override
  String get devConfirmDeleteDesc =>
      'Tem certeza de que deseja excluir permanentemente todos os arquivos nexus_info.json? Isso removerá todos os nomes, capas e metadados personalizados. Esta ação não pode ser desfeita.';

  @override
  String get devDeleteSuccessTitle => 'Exclusão Concluída';

  @override
  String devDeleteSuccessDesc(Object count) {
    return '$count arquivos nexus_info.json excluídos com sucesso.';
  }

  @override
  String get devConfirmExtractTitle => 'Confirmar Extração';

  @override
  String get devConfirmExtractDesc =>
      'Isso verificará todos os seus mods e criará \'ID Mods.json\' na sua área de trabalho. Isso substituirá qualquer arquivo existente com o mesmo nome. Deseja continuar?';

  @override
  String get devExtractAction => 'Extrair';

  @override
  String get devTestSelfUpdateTitle => 'Testar autoinstalação';

  @override
  String get devTestSelfUpdateDesc =>
      'Selecione o pacote .zip do app e instale-o sobre este app, como a atualização automática fará.';

  @override
  String get devSelfUpdateUnsupported =>
      'A autoatualização só está disponível no Windows.';

  @override
  String get devSelfUpdatePickTitle => 'Selecione o .zip do SB Control Center';

  @override
  String get devSelfUpdateFailed => 'Não foi possível instalar a atualização';

  @override
  String get devSelfUpdateDryRunTitle => 'O pacote é válido (modo de teste)';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return '$count arquivos encontrados. Não foi instalado porque esta não é uma build de release.';
  }

  @override
  String get devSelfUpdateConfirmTitle => 'Instalar a atualização?';

  @override
  String get devSelfUpdateConfirmDesc =>
      'O app será fechado, substituirá seus arquivos pelos do pacote e será aberto novamente de forma automática.';

  @override
  String get devSelfUpdateInstallAction => 'Instalar e reiniciar';

  @override
  String get devSelfUpdateProgressTitle => 'Atualizando o SB Control Center';

  @override
  String get devSelfUpdateExtracting => 'Extraindo o pacote…';

  @override
  String get devSelfUpdateInstalling => 'Instalando arquivos…';

  @override
  String get devSelfUpdateRestarting => 'Reiniciando…';

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
      'Nenhum mod com identificadores válidos foi encontrado para extrair.';

  @override
  String get devExtractDesktopNotFound =>
      'Erro: Não foi possível encontrar o diretório da Área de Trabalho.';

  @override
  String get devExtractSuccessTitle => 'Extração Concluída';

  @override
  String devExtractSuccessDesc(Object path) {
    return 'Arquivo criado com sucesso em: $path';
  }

  @override
  String get errorDialogTitle => 'Ocorreu um Erro';

  @override
  String get modDetailsCategory => 'Categoria';

  @override
  String get modDetailsAuthor => 'Autor';

  @override
  String get modDetailsNexusId => 'ID do Nexus';

  @override
  String get modDetailsInstalledOn => 'Instalado em';

  @override
  String get unknownAuthor => 'Desconhecido';

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
  String get filterUpdatesAvailable => 'Atualizações disponíveis';

  @override
  String snackBarUpdateIgnored(String modName) {
    return 'Atualização para \'$modName\' ignorada nesta sessão.';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return 'A versão \'$version\' de \'$modName\' será ignorada nas verificações futuras.';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return 'Atualizando metadados de \'$displayName\' ($arg1 de $arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return 'Mod Genérico Instalado: $modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return 'Instalado em $path.\nEste mod não é gerenciado pelo aplicativo e deve ser desinstalado manually.';
  }

  @override
  String genericModInstallError(String modName) {
    return 'Falha ao instalar o mod genérico: $modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => 'Genérico';

  @override
  String get modTypeMovies => 'Filmes';

  @override
  String get modTypeSave => 'Save';

  @override
  String get modTypeConfig => 'Configuração';

  @override
  String get modTypeSplash => 'Splash';

  @override
  String get replacesOutfitTitle => 'Substitui Traje';

  @override
  String get replacesOutfitClearTooltip => 'Limpar seleção de traje';

  @override
  String get replacesOutfitSelectTooltip => 'Selecionar traje a substituir';

  @override
  String get replacesOutfitNone =>
      'Nenhum traje selecionado.\nA etiqueta será \'Genérico\'.';

  @override
  String get replacesOutfitSearchHint => 'Procurar trajes...';

  @override
  String get modTypeReplacement => 'Substituição';

  @override
  String get replacesOutfitHover =>
      'Passe o mouse sobre um traje para ver uma prévia.';

  @override
  String get dialogTitleOutfitReplacement => 'Substituição de Traje?';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return 'O mod \'$modName\' é uma substituição de traje?\n\nSelecione \'Sim\' para escolher qual traje ele substitui, ou \'Não\' para instalá-lo como um mod genérico.';
  }

  @override
  String get dialogActionNo => 'Não';

  @override
  String get dialogActionYes => 'Sim';

  @override
  String get dialogTitleOutfitConflict => 'Conflito de Traje Detectado';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return 'O traje \'$outfitName\' já está sendo substituído pelo mod \'$modName\'.\n\nDeseja desativar \'$modName\' e ativar este em vez dele?';
  }

  @override
  String get dialogActionActivateAndDisable => 'Desativar e Ativar';

  @override
  String get replacementModSwitchTitle => 'Mod de substituição';

  @override
  String get replacementModSwitchDesc =>
      'Marque se este mod foi projetado para substituir um traje no jogo.';

  @override
  String get settingsShowModTagsTitle => 'Mostrar etiquetas de tipo de mod';

  @override
  String get settingsShowModTagsDesc =>
      'Exibir etiquetas de tipo de mod (ex. CNS, Genérico) em cada cartão de mod na lista.';

  @override
  String get modTypeLogic => 'Lógica';

  @override
  String get patcherStarted =>
      '=== Patcher Dart para StellarBlade Iniciado ===';

  @override
  String workingDirectory(String path) {
    return 'Diretório de trabalho: $path';
  }

  @override
  String modsDirNotFound(String path) {
    return 'O diretório ~mods não existe em: $path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  AVISO: Não foi possível verificar a pasta $path. Ignorando.';
  }

  @override
  String errorDetails(String error) {
    return '  Erro: $error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return 'Encontrados $count arquivos .utoc';
  }

  @override
  String get noModsFound2 => 'Nenhum mod encontrado para processar.';

  @override
  String get patcherSummaryTitle =>
      '\n=== Resumo do Patcher (Dados Brutos) ===';

  @override
  String processedMods(int count) {
    return 'Processados $count mods.';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return 'Corrigidos $count conflitos de Container ID.';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return 'Encontrados $count conflitos de Package ID.';
  }

  @override
  String get fatalErrorTitle => '\n=== ERRO FATAL ===';

  @override
  String patcherServiceError(String error) {
    return 'Erro no PatcherService: $error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- Analisando: $fileName ---';
  }

  @override
  String get warnUcasNotFound =>
      '  AVISO: Arquivo .ucas não encontrado. Ignorando.';

  @override
  String get warnCorruptHeader =>
      '  AVISO: Cabeçalho corrompido, o tamanho da entrada excede o tamanho do arquivo. Ignorando.';

  @override
  String conflictContainerIdDetected(int id) {
    return '  CONFLITO de Container ID detectado: $id';
  }

  @override
  String generatingNewId(int id) {
    return '  Gerando novo ID: $id';
  }

  @override
  String get utocFilePatched => '  Arquivo .utoc corrigido.';

  @override
  String get patchingUcasFile => '  Corrigindo arquivo .ucas...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  Substituições bem-sucedidas em .ucas: $count';
  }

  @override
  String get patchComplete => '  Patch concluído!';

  @override
  String idRegisteredNoConflict(int id) {
    return '  ID $id registrado. Sem conflitos.';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  ERRO ao processar $fileName: $error';
  }

  @override
  String get statusRunningPatcher => 'Executando Patcher de Conflitos...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ Sucesso! Foram corrigidos $count conflitos de Container ID que causavam falhas.';
  }

  @override
  String get summaryNoContainerIdConflicts =>
      '✅ Não foram encontrados conflitos de Container ID (falhas).';

  @override
  String get summaryNoPackageIdConflicts =>
      '✅ Boas notícias! Não foram encontrados conflitos graves de Package ID (substituições).';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ Aviso! Encontrados $count grupos de mods que não podem coexistir:';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • Este grupo de mods compete por $count arquivos:';
  }

  @override
  String get patcherSummaryDialogTitle => 'Resumo do Patcher';

  @override
  String get dialogActionShowFullLog => 'Mostrar Log Completo';

  @override
  String get fullLogDialogTitle => 'Log do Patcher de Conflitos (Dart)';

  @override
  String get runConflictPatcherTitle => 'Executar Patcher de Conflitos';

  @override
  String get runConflictPatcherSubtitlePython =>
      'Corrige falhas de Container_Id e Package_Id';

  @override
  String get processingCover => 'Processando Capa...';

  @override
  String get apiKeyTooltip =>
      'A Chave API é necessária para a extração inteligente de ID do Nexus.';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return 'Opções de Instalação - Mod $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection =>
      'Selecione as opções que deseja instalar. Os arquivos principais necessários serão instalados automaticamente.';

  @override
  String get snackBarSpecialModNoSelection =>
      'Selecione pelo menos uma opção para continuar.';

  @override
  String get dialogActionInstallSelection => 'Instalar Seleção';

  @override
  String get downloadStatusFetching => 'Obtendo dados do Nexus Mods...';

  @override
  String get downloadStatusFetchingFailed =>
      'Falha ao obter o link de download. Verifique sua chave de API ou conexão.';

  @override
  String downloadStatusDownloading(String fileName) {
    return 'Baixando $fileName';
  }

  @override
  String get downloadStatusError => 'Erro durante o download do arquivo.';

  @override
  String downloadStatusException(String error) {
    return 'Exceção: $error';
  }

  @override
  String get dialogTitleDownloadModManager => 'Download do Mod Manager';

  @override
  String get launchGameText => 'Iniciar Stellar Blade';

  @override
  String get stopGameText => 'Encerrar Stellar Blade';

  @override
  String get dialogTitleStopGame => 'Encerrar Stellar Blade?';

  @override
  String get dialogContentStopGame =>
      'O jogo será fechado. O progresso não salvo será perdido.';

  @override
  String get dialogActionStopGame => 'Encerrar';

  @override
  String get notificationGameStopped => 'Stellar Blade encerrado';

  @override
  String get errorStoppingGame => 'Não foi possível encerrar o jogo';

  @override
  String get mod801DialogTitle => 'Configuração do Steam Necessária';

  @override
  String get mod801DialogIntro =>
      'O mod Random Splash foi instalado. Para que funcione automaticamente ao iniciar o jogo, você precisa configurar o Steam.';

  @override
  String get mod801Step1 =>
      '1. Gere o caminho exato para o seu PC abaixo e copie-o.';

  @override
  String get mod801Step2 => '2. Abra sua Biblioteca do Steam.';

  @override
  String get mod801Step3 =>
      '3. Clique com o botão direito em Stellar Blade -> Propriedades.';

  @override
  String get mod801Step4 =>
      '4. Na aba \'Geral\', cole o código em \'Opções de Inicialização\'.';

  @override
  String get mod801BtnGenerate => 'Gerar Caminho';

  @override
  String get mod801BtnSteam => 'Abrir Steam';

  @override
  String get mod801BtnCopy => 'Copiar';

  @override
  String get mod801PathGenerated => 'Caminho gerado com sucesso.';

  @override
  String get mod801PathCopied =>
      'Comando copiado para a área de transferência!';

  @override
  String get statusVerifyingMods => 'Verificando a integridade dos mods...';

  @override
  String errorSelecting7Zip(String error) {
    return 'Erro ao selecionar o 7-Zip: $error';
  }

  @override
  String get errorInvalidFolderRetry =>
      'A pasta selecionada não parece estar correta. Por favor, tente novamente.';

  @override
  String errorSelectingFolderDynamic(String error) {
    return 'Erro ao selecionar a pasta: $error';
  }

  @override
  String get statusNoNewModsInstalled =>
      'A instalação não produziu novos mods.';

  @override
  String get errorDisableModBeforeDelete =>
      'Por favor, desative o mod antes de excluí-lo.';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return 'Ativados: $successCount (Ignorados: $skippedCount devido a conflitos)';
  }

  @override
  String get snackBarDeveloperModeEnabled => 'Modo de Desenvolvedor Ativado!';

  @override
  String errorRenamingMod(String error) {
    return 'Erro ao renomear o mod: $error';
  }

  @override
  String get notificationTitleError => 'Erro';

  @override
  String get errorGamePathNotFoundNotification =>
      'Caminho do jogo não encontrado.';

  @override
  String get notificationLaunchingGame => 'Iniciando Stellar Blade...';

  @override
  String get errorLaunchingGame => 'Erro ao iniciar o jogo';

  @override
  String get dialogTitleSelect7zip => 'Selecione o arquivo 7z.exe';

  @override
  String get dialogTitleSelectGameFolder =>
      'Por favor, selecione a pasta principal do StellarBlade';

  @override
  String get dialogTitleSelectCover => 'Selecione uma capa para o mod';

  @override
  String get errorGamePathNotFoundException =>
      'Caminho do jogo não encontrado.';

  @override
  String get errorGamePathNotDefined => 'O caminho do jogo não está definido.';

  @override
  String get errorLogicModsPathNotDefined =>
      'O caminho dos mods Logic não está definido.';

  @override
  String get errorUe4ssModsPathNotDefined =>
      'O caminho dos mods UE4SS não está definido.';

  @override
  String get errorGenericModsPathNotDefined =>
      'O caminho dos mods genéricos (~mods) não está definido.';

  @override
  String get errorReplaceNoOldVersion =>
      'Tentativa de substituir um mod, mas nenhuma versão antiga foi identificada.';

  @override
  String errorDeleteOldModVersion(String modName) {
    return 'Não foi possível excluir a versão antiga do mod ($modName).';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return 'Não foi possível excluir o mod existente ($modName) para reinstalar.';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return 'Não foi possível excluir o mod existente ($modName) para reinstalar após várias tentativas.';
  }

  @override
  String get errorMoviesModNoValidFiles =>
      'O mod de filmes não contém arquivos de vídeo válidos.';

  @override
  String get errorInstallPathUndetermined =>
      'O caminho de instalação não pôde ser determinado.';

  @override
  String get errorMoviesPathsNotDefined =>
      'Os caminhos dos filmes não estão definidos.';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return 'nexus_info.json não encontrado para $modName.';
  }

  @override
  String get errorMenuVideoLimitReached =>
      'Limite de 99 vídeos no menu atingido.';

  @override
  String get errorModRequires529 =>
      'O mod requer o Mod ID 529 para funcionar (contém apenas arquivos WebM).';

  @override
  String get errorSplashPathsNotDefined =>
      'Os caminhos de splash não estão definidos.';

  @override
  String get errorSplashNoValidImages =>
      'Nenhuma imagem válida foi encontrada no mod.';

  @override
  String get errorCouldNotDeleteDirectory =>
      'Não foi possível excluir o diretório.';

  @override
  String get errorGameExeNotFound =>
      'O arquivo executável do jogo (.exe) não foi encontrado na pasta principal ou em Binaries.';

  @override
  String get dialogTitleSplashOptions => 'Opções de Splash (Imagens)';

  @override
  String get dialogContentSplashOptions =>
      'Selecione as imagens que deseja instalar. Você pode escolher pastas inteiras (lotes) ou imagens individuais.';

  @override
  String get snackBarSplashNoSelection =>
      'Por favor, selecione pelo menos uma imagem.';

  @override
  String get dialogContentSpecialModSingleSelection =>
      'Selecione uma única opção para instalar.';

  @override
  String get activeDownloads => 'Downloads ativos';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mods',
      one: 'mod',
    );
    return 'Baixando $count $_temp0';
  }

  @override
  String get downloadError => 'Erro';

  @override
  String get downloadCancelled => 'Cancelado';

  @override
  String get downloadPause => 'Pausar';

  @override
  String get downloadResume => 'Retomar';

  @override
  String get downloadCancel => 'Cancelar';

  @override
  String get errorNexusInfoNotFound => 'nexus_info.json não encontrado.';

  @override
  String logFixingCorruptedJson(String displayName) {
    return 'Corrigindo nexus_info.json corrompido para $displayName.';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return 'Falha ao atualizar metadados para $displayName: $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return 'Desativando preventivamente o mod de filmes devido à ativação do Mod 529: $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return 'Desativando preventivamente o mod de splash devido à ativação do Mod 801: $modName';
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
    return 'Erro ao restaurar componentes LogicMod: $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return 'Arquivando componente ~mods: $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return 'Arquivando componente UE4SS: $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return 'Erro ao arquivar componentes LogicMod: $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return 'Ignorando $modName: Já existe uma variante ativa deste mod.';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return 'Ignorando $modName: Conflito com um traje já ocupado.';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return 'Não foi possível limpar os backups de vídeo para $modName: $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return 'Novo ID Nexus $nexusId detectado. Buscando metadados...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return 'Metadados obtidos e aplicados para $nexusId.';
  }

  @override
  String logFallbackByteCopy(String error) {
    return 'A cópia normal falhou, usando força bruta de bytes: $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return 'Aviso: Não foi possível excluir o arquivo modificado: $error';
  }

  @override
  String get logMod801BatPatched =>
      'Script .bat do Mod 801 corrigido com sucesso para este sistema.';

  @override
  String logMod801BatPatchError(String error) {
    return 'Erro ao tentar corrigir o arquivo .bat do Mod 801: $error';
  }

  @override
  String get errorHomeDirNotFound =>
      'Não foi possível encontrar a variável de ambiente do diretório inicial.';

  @override
  String get downloadFetchingPlaceholder => 'Buscando...';

  @override
  String get downloadErrorLink => 'Não foi possível buscar o link de download';

  @override
  String get downloadErrorGeneral => 'Falha no download';

  @override
  String get downloadPausedStatus => 'Pausado';

  @override
  String get settingsFixGameStartup => 'Corrigir jogo que não inicia';

  @override
  String get settingsFixGameStartupDesc =>
      'Use se o jogo fechar ou travar ao iniciar. Desinstala temporariamente o UE4SS e o CNS, inicia o jogo uma vez e depois os reinstala.';

  @override
  String get repairConfirmTitle => 'Corrigir o início do jogo?';

  @override
  String get repairConfirmMessage =>
      'O UE4SS e o CNS serão desinstalados (os arquivos ficam guardados), o jogo iniciará e fechará automaticamente, e depois tudo será reinstalado e o jogo iniciado novamente. Não feche o aplicativo durante o processo.';

  @override
  String get repairConfirmAction => 'Iniciar reparo';

  @override
  String get launchRetryTitle => 'O jogo não iniciou';

  @override
  String get launchRetryMessage =>
      'O Stellar Blade não iniciou após duas tentativas. Isso geralmente é causado pelo UE4SS ou pelo CNS. \"Corrigir jogo que não inicia\" desinstala ambos temporariamente, abre o jogo uma vez e os reinstala. Executar agora?';

  @override
  String get launchRetryAction => 'Corrigir agora';

  @override
  String get repairOverlayTitle => 'Corrigindo o início do jogo';

  @override
  String get repairOverlayWarning =>
      'Não feche o aplicativo nem o jogo manualmente durante o processo.';

  @override
  String get repairStepCloseGame => 'Fechando o jogo se estiver aberto';

  @override
  String get repairStepStashCns =>
      'Desinstalando o CNS (guardando os arquivos)';

  @override
  String get repairStepStashUe4ss =>
      'Desinstalando o UE4SS (guardando os arquivos)';

  @override
  String get repairStepLaunchClean => 'Iniciando o jogo sem UE4SS e CNS';

  @override
  String get repairStepWaitInit => 'Aguardando o jogo carregar';

  @override
  String get repairStepCloseAuto => 'Fechando o jogo automaticamente';

  @override
  String get repairStepRestoreUe4ss => 'Reinstalando o UE4SS';

  @override
  String get repairStepRestoreCns => 'Reinstalando o CNS';

  @override
  String get repairStepLaunchFinal => 'Iniciando o jogo';

  @override
  String get repairStatusSkipped => 'ignorado';

  @override
  String get repairResultSuccess => 'Reparo concluído. O jogo foi iniciado.';

  @override
  String get repairResultErrorRestored =>
      'O reparo falhou, mas o UE4SS e o CNS foram restaurados.';

  @override
  String get repairResultErrorRestoreFailed =>
      'O reparo falhou e os arquivos ainda não puderam ser restaurados. Eles serão restaurados automaticamente na próxima vez que o aplicativo iniciar.';

  @override
  String get repairErrorGameNotStarted => 'O jogo não iniciou a tempo.';

  @override
  String get repairButtonClose => 'Fechar';

  @override
  String get repairRecoveredNotice =>
      'Foi detectado um reparo interrompido: os arquivos do UE4SS e do CNS foram restaurados.';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return 'Nova edição instalada: $name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return 'Este mod agora tem $count edições instaladas.';
  }

  @override
  String get previewTagNewEdition => 'nova edição';

  @override
  String get previewTagUpdate => 'atualização';

  @override
  String editionsInstalledTooltip(Object count) {
    return '$count edições deste mod instaladas';
  }

  @override
  String editionLabelValue(Object edition) {
    return 'Edição: $edition';
  }

  @override
  String get otherEditionsTitle => 'Outras edições instaladas';

  @override
  String get detailsStatusEnabled => 'Ativado';

  @override
  String get detailsStatusDisabled => 'Desativado';

  @override
  String get detailsInformation => 'Informações';

  @override
  String get detailsRowAuthor => 'Autor';

  @override
  String get detailsRowType => 'Tipo';

  @override
  String get detailsRowInstalled => 'Instalado';

  @override
  String get detailsRowModified => 'Última modificação';

  @override
  String get detailsRowNexusId => 'ID do Nexus';

  @override
  String get detailsRowFolder => 'Pasta';

  @override
  String get detailsCopyPath => 'Copiar caminho';

  @override
  String get detailsCopied => 'Copiado para a área de transferência';

  @override
  String get detailsEndorse => 'Endorse';

  @override
  String get detailsEndorsed => 'Endorsed';

  @override
  String endorseWaitLabel(Object minutes) {
    return 'Aguarde $minutes min';
  }

  @override
  String get endorseSuccessTitle => 'Mod endorsed';

  @override
  String get endorseRemovedTitle => 'Endorse removido';

  @override
  String get endorseFailedTitle => 'Não foi possível atualizar o endorse';

  @override
  String get endorseErrNotNexus =>
      'Este mod não está vinculado a uma página do Nexus Mods, portanto não é possível fazer endorse.';

  @override
  String get endorseErrNoApiKey =>
      'Adicione sua chave de API do Nexus Mods em Configurações para fazer endorse de mods.';

  @override
  String endorseErrWait(Object minutes) {
    return 'O Nexus exige aguardar 15 minutos após baixar um mod antes de poder fazer endorse. Tente novamente em $minutes min.';
  }

  @override
  String get endorseErrNotDownloaded =>
      'O Nexus só permite fazer endorse de mods que você baixou com a sua conta.';

  @override
  String get endorseErrOwnMod =>
      'Você não pode fazer endorse do seu próprio mod.';

  @override
  String get endorseErrRateLimit =>
      'Você atingiu o limite de solicitações do Nexus. Tente novamente mais tarde.';

  @override
  String get endorseErrInvalidKey =>
      'O Nexus rejeitou a sua chave de API. Verifique-a em Configurações.';

  @override
  String get endorseErrNetwork =>
      'Não foi possível acessar o Nexus Mods. Verifique a sua conexão e tente novamente.';

  @override
  String get endorseErrUnknown =>
      'O Nexus não conseguiu processar a solicitação. Tente novamente mais tarde.';

  @override
  String get endorseRemoveConfirmTitle => 'Remover endorse?';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return '$name deixará de ter endorse no Nexus Mods.';
  }

  @override
  String get endorseRemoveConfirmAction => 'Remover';

  @override
  String get detailsUpdateAction => 'Atualizar';

  @override
  String get detailsShowMore => 'Mostrar mais';

  @override
  String get detailsShowLess => 'Mostrar menos';

  @override
  String get detailsAddNote => 'Adicionar uma nota';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trajes',
      one: '1 traje',
      zero: 'Nenhum traje',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return '$count selecionados';
  }

  @override
  String get outfitsChoose => 'Escolher trajes';

  @override
  String get outfitsDone => 'Concluído';

  @override
  String get outfitsFilterAll => 'Todos';

  @override
  String get outfitsFilterSelected => 'Selecionados';

  @override
  String get outfitsClearAll => 'Limpar tudo';

  @override
  String get outfitsRemove => 'Remover';

  @override
  String get outfitsActionSelect => 'Selecionar';

  @override
  String get outfitsActionDeselect => 'Desmarcar';

  @override
  String outfitsNoResults(String query) {
    return 'Nenhum resultado para \"$query\"';
  }

  @override
  String get outfitsSelectedEmpty => 'Nenhum traje selecionado ainda.';

  @override
  String get outfitsNoPreview => 'Nenhuma pré-visualização disponível';

  @override
  String get replacementOffConfirmTitle => 'Desativar mod de substituição?';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Os $count trajes selecionados serão removidos deste mod.',
      one: 'O traje selecionado será removido deste mod.',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => 'Desativar';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count mods desativados: eles substituem trajes que já são usados por outros mods',
      one:
          '1 mod desativado: ele substitui um traje que já é usado por outro mod',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  Mesmo Container ID que: $owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved =>
      '  Originais mantidos como .cnsbak (restauráveis).';

  @override
  String patcherLeftUntouched(String reason) {
    return '  Deixado intacto (não é seguro aplicar patch): $reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ $count mod(s) compartilham um Container ID, mas não puderam ser corrigidos com segurança (deixados intactos; podem não aparecer no CNS):';
  }

  @override
  String get revertPatchesTitle => 'Reverter patches de conflitos';

  @override
  String get revertPatchesDesc =>
      'Restaura os arquivos originais dos mods alterados pelo Patcher de Conflitos.';

  @override
  String get revertPatchesConfirmTitle => 'Reverter patches de conflitos?';

  @override
  String get revertPatchesConfirmMessage =>
      'Os arquivos originais salvos pelo Patcher de Conflitos (.cnsbak) serão restaurados. Feche o jogo antes. Mods em conflito podem deixar de aparecer no CNS novamente.';

  @override
  String get revertPatchesAction => 'Reverter';

  @override
  String revertPatchesDone(int count) {
    return '$count arquivo(s) restaurado(s).';
  }

  @override
  String get revertPatchesNothing => 'Não há arquivos com patch para reverter.';

  @override
  String get settingsGroupPaths => 'Caminhos';

  @override
  String get settingsGroupTools => 'Ferramentas';

  @override
  String get settingsAutoOutfit => 'Atribuir trajes automaticamente';

  @override
  String get settingsAutoOutfitDesc =>
      'Ao instalar um mod de substituição, detecta qual traje ele substitui lendo os seus arquivos. Se desativado, o traje é atribuído manualmente.';

  @override
  String get variantChoiceTitle => 'Várias variantes da mesma substituição';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return 'O mod \"$mod\" contém várias variantes que substituem $outfits. Apenas uma pode estar ativa por vez. Qual você quer instalar?';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return 'O mod \"$mod\" contém várias variantes que substituem os mesmos arquivos. Apenas uma pode estar ativa por vez. Qual você quer instalar?';
  }

  @override
  String get variantChoiceInstallAll => 'Instalar todas (como mods separados)';

  @override
  String get installOutfitConflictTitle => 'Traje já em uso';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return 'O mod \"$newMod\" substitui o traje $outfits, já atribuído ao mod ativo \"$oldMod\". Apenas um pode estar ativo por vez. Qual você quer manter ativo?';
  }

  @override
  String get installOutfitKeepCurrent => 'Manter o atual';

  @override
  String get installOutfitUseNew => 'Ativar o novo';

  @override
  String installOutfitNowActive(String active) {
    return 'Agora ativo: $active';
  }

  @override
  String get fileLockErrorTitle => 'Não foi possível mover o mod';

  @override
  String get fileLockErrorMessage =>
      'Outro aplicativo pode estar usando os arquivos do jogo (FModel, o próprio jogo, um antivírus, o Explorador de Arquivos...). Feche-o e tente novamente.';

  @override
  String get nexusProfileTooltip => 'Perfil do Nexus Mods';

  @override
  String get nexusUserFallback => 'Usuário';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => 'Membro';

  @override
  String get nexusPlanSupporter => 'Apoiador';

  @override
  String get nexusApiRequestsRemaining => 'SOLICITAÇÕES DE API RESTANTES';

  @override
  String get nexusApiDaily => 'Diárias';

  @override
  String get nexusApiHourly => 'Por hora';

  @override
  String get downloadMemberAccountLimit =>
      'Contas Membro são limitadas a 1,5 MB/s pelo Nexus Mods';

  @override
  String get downloadSupporterAccountLimit =>
      'Contas Apoiador são limitadas a 3 MB/s pelo Nexus Mods';

  @override
  String get downloadRetryTooltip => 'Tentar novamente';

  @override
  String get downloadRefreshingLink => 'Atualizando link...';

  @override
  String get downloadNoInternet =>
      'Sem conexão com a internet. Verifique sua rede.';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'O link do Nexus expirou ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'Erro HTTP: $code';
  }

  @override
  String get downloadErrorTimeout =>
      'Tempo esgotado: nenhum dado de rede recebido';

  @override
  String get splashRootFolder => 'Raiz (Principal)';

  @override
  String get repairErrorGameNotClosed =>
      'Não foi possível encerrar o processo do jogo.';

  @override
  String get errorManifestNotFound =>
      'Manifesto de instalação não encontrado. Não é possível desinstalar.';

  @override
  String get downloadResuming => 'Retomando...';

  @override
  String get apiKeyPromptTitle => 'Configure sua chave de API do Nexus Mods';

  @override
  String get apiKeyPromptMessage =>
      'Nenhuma chave de API foi detectada. Configurá-la é opcional, mas recomendado por conveniência: ela permite buscar atualizações de mods, baixar com um clique (nxm://) e carregar capas e informações do Nexus Mods.';

  @override
  String get apiKeyPromptConfigure => 'Configurar chave de API';

  @override
  String get apiKeyPromptSkip => 'Ignorar';

  @override
  String get apiKeyPromptDontShowAgain => 'Não mostrar esta mensagem novamente';

  @override
  String get adjustCoverTooltip => 'Ajustar capa';

  @override
  String get noCoverToAdjust => 'Este mod não tem uma capa para ajustar';

  @override
  String errorAdjustingCoverText(Object error) {
    return 'Erro ao ajustar a capa: $error';
  }
}
