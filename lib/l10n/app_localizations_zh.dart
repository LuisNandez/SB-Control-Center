// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => '设置';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageDesc => '选择应用程序语言';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutDesc => '有关应用程序的信息';

  @override
  String get settingsRefreshMetadata => '更新元数据';

  @override
  String get settingsRefreshMetadataDesc =>
      '重新在 Nexus Mods 上检查你的模组，并补全缺失的信息和图片';

  @override
  String get metadataRefreshDone => '元数据已更新';

  @override
  String get metadataRefreshNoApiKey => '请在设置中填写 Nexus Mods API 密钥以更新元数据。';

  @override
  String get settingsPathsAndTools => '路径与工具';

  @override
  String get settingsGameFolder => '游戏文件夹';

  @override
  String get settingsGameFolderDesc => '您的《星刃》安装根文件夹。';

  @override
  String get settings7zipPath => '7-Zip 路径';

  @override
  String get settings7zipPathDesc => '用于提取模组的 7z.exe 文件位置。';

  @override
  String get settings7zipPathAuto => '自动搜索';

  @override
  String get settingsRepairMods => '修复旧版模组';

  @override
  String get settingsRepairModsDesc => '使用本地数据库扫描并为旧模组创建信息文件。需要 API 密钥。';

  @override
  String get settingsConnectivity => '连接与更新';

  @override
  String get settingsApiKey => 'Nexus Mods API 密钥';

  @override
  String get settingsApiKeyDesc => '检查模组更新时需要。';

  @override
  String get settingsApiKeySet => '已设置';

  @override
  String get settingsApiKeyNotSet => '未设置';

  @override
  String get settingsSkippedVersions => '管理已跳过的版本';

  @override
  String get settingsSkippedVersionsDesc => '管理您选择跳过的模组版本。';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count 个版本已跳过';
  }

  @override
  String get dialogTitleSkippedVersions => '已跳过的模组版本';

  @override
  String get dialogNoSkippedVersions => '您没有跳过任何模组版本。';

  @override
  String get dialogSkippedVersions => '已跳过的版本';

  @override
  String get dialogTitleRepairMods => '运行旧版模组修复？';

  @override
  String get dialogContentRepairMods =>
      '警告：此功能正在开发中，可能不完美。\n\n它将扫描没有 \'nexus_info.json\' 文件的模组，如果在您的本地数据库中找到，将为它们创建一个。它还将尝试重命名模组的文件夹以包含找到的版本（例如，\'My Mod\' -> \'My Mod v1.2\'）。\n\n版本优先级：\n1. 从文件夹名称。\n2. 从模组的描述字段。\n3. 从 Nexus Mods 上的最新版本（需要 API）。\n\n您想继续吗？';

  @override
  String get dialogActionRunRepair => '运行修复';

  @override
  String get snackBarGamePathInvalid => '所选文件夹似乎不是有效的游戏文件夹。';

  @override
  String get snackBar7zipPathInvalid => '所选文件必须命名为 7z.exe。';

  @override
  String get snackBarRepairStarted => '旧版模组修复过程已开始...';

  @override
  String snackBarRepairComplete(Object count) {
    return '修复完成。$count 个模组已更新。';
  }

  @override
  String get snackBarRepairNoMods => '未找到需要修复的旧版模组。';

  @override
  String get errorApiRequiredForRepair => '需要 API 密钥才能为没有本地版本的模组找到最新版本。';

  @override
  String get installNewMod => '安装模组';

  @override
  String get selectFiles => '选择文件';

  @override
  String get selectFolder => '选择文件夹';

  @override
  String get installSelectedMod => '安装所选模组';

  @override
  String get filesToInstall => '要安装的文件：';

  @override
  String get cancelSelection => '取消选择';

  @override
  String get searchMods => '搜索模组...';

  @override
  String get enabledMods => '已启用的模组';

  @override
  String get disabledMods => '已禁用的模组';

  @override
  String get refreshList => '刷新列表';

  @override
  String get noEnabledMods => '没有已启用的模组。';

  @override
  String get noDisabledMods => '没有已禁用的模组。';

  @override
  String get showInFolder => '在文件夹中显示';

  @override
  String get disableMod => '禁用模组';

  @override
  String get enableMod => '启用模组';

  @override
  String get deletePermanently => '永久删除';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择一种语言';

  @override
  String get statusSearchingGame => '正在搜索《星刃》安装...';

  @override
  String get statusGamePathFound => '找到游戏路径！';

  @override
  String get statusGamePathNotFound => '无法自动找到游戏路径。';

  @override
  String statusErrorFindingGame(Object error) {
    return '搜索游戏时发生错误：$error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount 个模组已启用，$disabledCount 个已禁用。';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return '读取已安装模组时出错：$error';
  }

  @override
  String statusFilesSelected(Object count) {
    return '已选择 $count 个文件。准备安装。';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return '已选择文件夹 “$folderName”。准备安装。';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return '已加载文件 “$fileName”。$count 个文件准备安装。';
  }

  @override
  String get statusSelectionCancelled => '选择已取消。请选择要安装的新模组。';

  @override
  String get statusUpdateComplete => '更新完成。';

  @override
  String get statusInstallationComplete => '安装完成。';

  @override
  String statusError(Object error) {
    return '错误：$error';
  }

  @override
  String get dialogTitle7zip => '需要 7-Zip';

  @override
  String get dialogContent7zip => '要解压缩此文件，应用程序需要 7-Zip。\n\n请从其官方页面安装，然后按“确认”。';

  @override
  String get dialogContent7zipNotFound => '尚未检测到 7-Zip。请确保它已安装在默认路径中，然后重试。';

  @override
  String get dialogTitleMultipleJsons => '检测到多个 .json 文件';

  @override
  String dialogContentMultipleJsons(Object count) {
    return '已检测到 $count 个 .json 文件。这可能是一个包含多个组件的模组。\n\n您想将它们全部安装到一个模组文件夹中吗？';
  }

  @override
  String get dialogTitleModExists => '模组已存在';

  @override
  String dialogContentModExists(Object modName) {
    return '名为 “$modName” 的模组已安装。\n\n您想更新它吗？旧文件将在安装新文件之前被删除。';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return '找到了一个旧版本 \'$oldModName\'。\n\n您想删除它并更新到 \'$newModName\' 吗？';
  }

  @override
  String get dialogTitleDeleteMod => '永久删除？';

  @override
  String dialogContentDeleteMod(Object modName) {
    return '您即将永久删除模组 “$modName”。此操作无法撤销。\n\n您确定吗？';
  }

  @override
  String get dialogActionCancel => '取消';

  @override
  String get dialogActionGoToDownload => '转到下载页面';

  @override
  String get dialogActionConfirmInstallation => '确认安装';

  @override
  String get dialogActionUpdateSystem => '更新系统';

  @override
  String get dialogActionInstallAnyway => '仍然安装';

  @override
  String get dialogActionDelete => '删除';

  @override
  String get dialogActionClose => '关闭';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return '批量安装完成。成功：$successCount，失败：$failedCount。';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return '模组 “$modName” 安装成功。';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return '模组 “$modName” 已启用。';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return '模组 “$modName” 已禁用。';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return '模组 “$modName” 已永久删除。';
  }

  @override
  String get snackBarCNSUpdated => '自定义纳米服系统更新成功。';

  @override
  String get snackBarApiKeySaved => 'API 密钥保存成功。';

  @override
  String get snackBarGamePathSaved => '游戏路径保存成功。';

  @override
  String get snackBar7zipPathSaved => '7-Zip 路径保存成功。';

  @override
  String get snackBarSkippedVersionRemoved => '已跳过的版本已删除。';

  @override
  String get dropTargetOverlay => '将模组拖放到此处';

  @override
  String get pathSelectionTitle => '未找到《星刃》路径';

  @override
  String get pathSelectionButtonManual => '手动选择游戏文件夹';

  @override
  String get pathSelectionButtonRetry => '重试';

  @override
  String errorFolderSelection(Object error) {
    return '选择文件夹时出错：$error';
  }

  @override
  String errorFileSelection(Object error) {
    return '选择文件时出错：$error';
  }

  @override
  String errorDecompressing(Object error) {
    return '解压缩文件时出错：$error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return '处理文件时出错：$error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return '不支持的文件格式：$extension';
  }

  @override
  String get error7zipRequired => '操作已取消：需要 7-Zip。';

  @override
  String get errorGamePathUndefined => '游戏路径未定义。';

  @override
  String get errorDestinationNotFound => '游戏的目标文件夹不存在。';

  @override
  String errorUpdateSystem(Object error) {
    return '更新系统时出错：$error';
  }

  @override
  String get errorInstallNoSelection => '您没有选择任何要安装的内容。';

  @override
  String get errorInstallModExists => '安装已取消：模组已存在。';

  @override
  String get errorNoJsonFound => '每个模组必须至少包含一个 .json 文件。';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return '文件 $fileName 的 JSON 格式无效。';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return '文件 $fileName 似乎不是自定义纳米服系统模组（缺少“DisplayName”）。';
  }

  @override
  String get errorNoValidDisplayName => '在 .json 文件中未找到有效的“DisplayName”。';

  @override
  String errorEnableMod(Object error) {
    return '启用模组时出错：$error';
  }

  @override
  String errorDisableMod(Object error) {
    return '禁用模组时出错：$error';
  }

  @override
  String errorDeleteMod(Object error) {
    return '删除模组时出错：$error';
  }

  @override
  String errorOpenFolder(Object path) {
    return '无法打开文件夹：$path';
  }

  @override
  String get statusUpdateSystemCancelled => '系统更新已取消。';

  @override
  String get statusUpdatingCNS => '正在更新自定义纳米服系统...';

  @override
  String statusExtractingFile(Object fileName) {
    return '正在提取 $fileName...';
  }

  @override
  String get statusInstallationCancelledByUser => '用户取消了安装。';

  @override
  String get errorNoCompatibleFilesInFolder => '所选文件夹不包含兼容的模组文件。';

  @override
  String get errorNoCompatibleFilesInArchive => '压缩文件不包含兼容的模组文件。';

  @override
  String get errorNoJsonInSelection => '所选内容不包含有效的模组 .json 文件。';

  @override
  String get aboutTitle => '关于 SB Control Center';

  @override
  String get aboutContent =>
      'SB Control Center 是《Stellar Blade》的模组管理器。它可以在一处安装、整理和更新你的模组，并支持用于服装和纳米战衣模组的 Custom Nanosuit System (CNS)。\n\n它会连接 Nexus Mods，用于下载、检查更新，以及为你使用的模组点 Endorse。\n\n内置 7-Zip（7-zip.org），用于解压 .zip、.rar 和 .7z 压缩包。';

  @override
  String get aboutEndorseCta => '喜欢这个应用吗？在 Nexus Mods 上点个 Endorse 会帮上大忙。';

  @override
  String get aboutEndorseThanks => '感谢你的支持！';

  @override
  String get aboutLinkText => '访问我的创作者个人资料';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return '版本：$version';
  }

  @override
  String get openModsFolder => '打开模组文件夹';

  @override
  String get openInNexusMods => '在 Nexus Mods 中打开';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String updateAvailable(Object version) {
    return '有可用更新：v$version';
  }

  @override
  String get dialogTitleApiKey => 'Nexus Mods API 密钥';

  @override
  String get dialogContentApiKey => '要检查模组更新，您需要一个来自 Nexus Mods 的个人 API 密钥。';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. 点击下方按钮打开 Nexus Mods 并登录。\n2. 滚动到页面底部的“Personal API Key”部分。\n3. 如果还没有，请先申请，然后复制密钥。\n4. 粘贴到此处。';

  @override
  String get apiKeyOpenNexusPage => '打开 API 密钥页面';

  @override
  String get apiKey => 'API 密钥';

  @override
  String get apiKeyHintText => '在此处粘贴您的 API 密钥';

  @override
  String get dialogActionSave => '保存';

  @override
  String get apiKeyRemoved => 'API 密钥已删除。';

  @override
  String get invalidApiKeyError => 'API 密钥无效。';

  @override
  String get validatingApiKey => '正在验证...';

  @override
  String get errorApiKeyMissing =>
      '未配置 Nexus Mods API 密钥。请在 设置 › 连接与更新 › Nexus Mods API 密钥 中添加。';

  @override
  String get statusCheckingUpdates => '正在检查模组更新...';

  @override
  String statusUpdatesFound(Object count) {
    return '找到 $count 个更新！';
  }

  @override
  String get statusNoUpdates => '所有模组都是最新的。';

  @override
  String get selectModArchive => '选择模组存档';

  @override
  String get viewImageGallery => '查看图片库';

  @override
  String get imageGallery => '图片库';

  @override
  String get noImagesFound => '未找到此模组的图片，或者未输入 API 密钥。请输入 API 密钥，然后检查更新。';

  @override
  String errorFetchingImages(Object error) {
    return '获取图片时出错：$error';
  }

  @override
  String get imageMod => '模组图片';

  @override
  String get modEnabledBadge => '已启用';

  @override
  String get modDisabledBadge => '已禁用';

  @override
  String get modCategoryOther => '未指定';

  @override
  String get dialogContentUpdateOptions => '您想做什么？';

  @override
  String get dialogActionIgnoreVersion => '忽略';

  @override
  String get dialogActionSkipVersion => '跳过版本';

  @override
  String get dialogActionGoToDownloadPage => '转到下载';

  @override
  String get installedMods => '已安装的模组';

  @override
  String get filterBy => '筛选方式：';

  @override
  String get sortBy => '排序方式：';

  @override
  String get filterAll => '全部';

  @override
  String get filterEnabled => '已启用';

  @override
  String get filterDisabled => '已禁用';

  @override
  String get filterRepaired => '已修复';

  @override
  String get sortByName => '名称';

  @override
  String get sortByDate => '日期';

  @override
  String get noModsFound => '未找到模组。';

  @override
  String get viewTypeGrid => '网格视图';

  @override
  String get viewTypeList => '列表视图';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return '正在提取 $count/$total：$fileName';
  }

  @override
  String get previewInstallTitle => '将要安装的模组：';

  @override
  String get dialogTitleUE4SS => '检测到 UE4SS 安装';

  @override
  String get dialogContentUE4SS =>
      '已检测到 UE4SS 工具。您想将其安装到 \'StellarBlade\\SB\\Binaries\\Win64\' 吗？\n\n许多模组都需要它才能工作。';

  @override
  String get dialogActionInstallTool => '安装工具';

  @override
  String get statusUE4SSInstallCancelled => 'UE4SS 安装已取消。';

  @override
  String get statusInstallingUE4SS => '正在安装 UE4SS...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SS 安装成功。';

  @override
  String error7zipDecompression(Object error) {
    return '解压期间出现 7-Zip 错误：$error';
  }

  @override
  String get statusUE4SSInstallComplete => 'UE4SS 安装完成。';

  @override
  String get dialogTitleAlternativeVersion => '检测到替代版本';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return '此模组的替代版本已安装：\'$oldModName\'。\n\n您即将安装一个名为 \'$newModName\' 的不同替代版本。';
  }

  @override
  String get dialogActionReplace => '替换';

  @override
  String get dialogActionInstallAsNew => '作为新模组安装';

  @override
  String get dialogTitleUpdate => '有可用更新';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return '您即将更新模组 \'$modName\'。\n\n已安装版本：$oldVersion\n新版本：$newVersion';
  }

  @override
  String get dialogTitleDowngrade => '检测到旧版本';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return '警告：您即将安装模组 \'$modName\' 的旧版本。\n\n已安装版本：$oldVersion\n要安装的版本：$newVersion';
  }

  @override
  String get dialogTitleReinstall => '重新安装模组';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return '您即将重新安装模组 \'$modName\' 的版本 \'$version\'。';
  }

  @override
  String get dialogActionReinstall => '重新安装';

  @override
  String get editModNameTooltip => '编辑模组名称';

  @override
  String get setCoverTooltip => '设置自定义封面图片';

  @override
  String get setCoverText => '设置封面';

  @override
  String get restoreOriginalCoverText => '恢复原始封面';

  @override
  String errorSavingCoverText(Object error) {
    return '保存封面图片时出错：$error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return '恢复原始封面图片时出错：$error';
  }

  @override
  String get editVersionText => '编辑版本';

  @override
  String get customVersionText => '自定义版本';

  @override
  String get editTagText => '编辑标签';

  @override
  String get customTagText => '自定义标签';

  @override
  String get dialogTitleEditModName => '编辑模组名称';

  @override
  String get dialogActionResetToDefault => '重置为默认值';

  @override
  String get dialogLabelNewName => '新名称';

  @override
  String errorModNameExists(Object modName) {
    return '名为 “$modName” 的模组已存在。';
  }

  @override
  String get dialogTitleRepairedModWarning => '已修复模组警告';

  @override
  String get dialogContentRepairedModWarning =>
      '此模组可能没有正确的版本信息。建议重新安装最新版本以确保兼容性。';

  @override
  String get repairedModTooltip => '有关已修复模组的信息';

  @override
  String get disableAllModsTooltip => '禁用所有模组';

  @override
  String get deleteAllModsTooltip => '删除所有已禁用的模组';

  @override
  String get dialogTitleDisableAll => '禁用所有模组？';

  @override
  String dialogContentDisableAll(int count) {
    return '您确定要禁用所有 $count 个已启用的模组吗？它们将被移动到备份文件夹。';
  }

  @override
  String get dialogTitleDeleteAll => '删除已禁用的模组？';

  @override
  String dialogContentDeleteAll(int count) {
    return '您即将永久删除所有 $count 个已禁用的模组。此操作无法撤销。\n\n您确定吗？';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return '所有 $count 个已启用的模组都已禁用。';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return '所有 $count 个已禁用的模组都已永久删除。';
  }

  @override
  String get snackBarNoModsToDisable => '没有已启用的模组可以禁用。';

  @override
  String get snackBarNoModsToDelete => '没有已禁用的模组可以删除。';

  @override
  String get enableAllModsTooltip => '启用所有模组';

  @override
  String get dialogTitleEnableAll => '启用所有模组？';

  @override
  String dialogContentEnableAll(int count) {
    return '您确定要启用所有 $count 个已禁用的模组吗？它们将被移动到主模组文件夹。';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return '所有 $count 个已禁用的模组都已启用。';
  }

  @override
  String get snackBarNoModsToEnable => '没有已禁用的模组可以启用。';

  @override
  String get editNotes => '编辑笔记';

  @override
  String get notesHintText => '在此处添加您的个人笔记...';

  @override
  String get modAuthor => '作者';

  @override
  String get modSummary => '摘要';

  @override
  String get modDescription => '描述';

  @override
  String get noDescriptionAvailable => '无可用描述。';

  @override
  String get personalNotes => '个人笔记';

  @override
  String get noNotesAvailable => '尚未添加笔记。';

  @override
  String get modDetailsTitle => '模组详情';

  @override
  String get modVersion => '版本';

  @override
  String get modCategory => '类别';

  @override
  String get dialogTitleAddUrl => '添加模组链接';

  @override
  String get dialogLabelUrl => '模组 URL';

  @override
  String get errorInvalidUrl => '请输入有效的 URL。';

  @override
  String get addLinkTooltip => '为此模组添加下载链接';

  @override
  String get addLinkButtonText => '添加链接';

  @override
  String get openLinkButtonText => '打开链接';

  @override
  String get editModTitle => '编辑模组详情';

  @override
  String get modNameLabel => '模组名称';

  @override
  String get authorLabel => '作者';

  @override
  String get summaryLabel => '描述/摘要';

  @override
  String get notesLabel => '个人笔记';

  @override
  String get urlLabel => '下载 URL';

  @override
  String get changeCoverButton => '更改封面图片';

  @override
  String get editButtonTooltip => '编辑模组';

  @override
  String get errorSavingNotes => '保存笔记时出错';

  @override
  String get errorSavingUrl => '保存 URL 时出错';

  @override
  String get errorSavingChanges => '保存更改时出错';

  @override
  String get errorTranslation => '无法翻译描述';

  @override
  String get translateSummary => '翻译摘要';

  @override
  String get translateDescription => '翻译描述';

  @override
  String get restoreOriginalDescription => '恢复原始描述';

  @override
  String get dialogTitleUE4SSReinstall => '重新安装 UE4SS';

  @override
  String get dialogContentUE4SSReinstall =>
      'UE4SS 似乎已安装。您想覆盖现有安装吗？如果您怀疑文件已损坏，这可能会很有用。';

  @override
  String get dialogTitleCNSReinstall => '重新安装 CNS 系统';

  @override
  String get dialogContentCNSReinstall =>
      '主 CNS 系统似乎已安装。您想重新安装它吗？您现有的模组不会受到影响。';

  @override
  String dialogTitleUninstall(Object componentName) {
    return '卸载 $componentName';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return '您确定要卸载 $componentName 吗？此操作将删除核心组件文件，但不会影响您已安装的模组。';
  }

  @override
  String get dialogActionUninstall => '是，卸载';

  @override
  String statusUninstalling(Object componentName) {
    return '正在卸载 $componentName...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentName 卸载成功';
  }

  @override
  String errorUninstalling(Object componentName) {
    return '卸载 $componentName 时出错';
  }

  @override
  String get settingsCoreComponents => '核心组件';

  @override
  String get installedStatus => '已安装';

  @override
  String get notInstalledStatus => '未检测到';

  @override
  String get uninstallButton => '卸载';

  @override
  String get cnsCoreSystem => '自定义纳米服系统';

  @override
  String get ue4ssInstallationDetected => '检测到并采用现有 UE4SS 安装';

  @override
  String get cnsInstallationDetected => '检测到并采用现有主 CNS 安装';

  @override
  String get ue4ssRequiredTitle => '需要 UE4SS';

  @override
  String get ue4ssRequiredContent => '要安装主 CNS 系统，您必须首先安装 UE4SS。您可以从以下链接下载它：';

  @override
  String get uninstallDependencyTitle => '检测到依赖关系';

  @override
  String get uninstallDependencyContent =>
      '在卸载 UE4SS 之前，您必须先卸载主 CNS 系统，因为 CNS 依赖于它。';

  @override
  String get dialogActionUnderstood => '已理解';

  @override
  String get appTitleNoCns => '自定义纳米服系统（未安装）';

  @override
  String get dialogTitleCNSUpdate => '更新主 CNS 系统';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return '您即将将 CNS 从版本 $oldVersion 更新到新版本 $newVersion。您想继续吗？';
  }

  @override
  String get dialogTitleCNSDowngrade => '降级 CNS 版本';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return '警告！您即将安装比当前版本 ($oldVersion) 更旧的 CNS 版本 ($newVersion)。这可能会导致问题。您确定吗？';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return '您已安装 CNS 版本 $version。您仍要重新安装文件吗？';
  }

  @override
  String get dialogActionUpdate => '更新';

  @override
  String get dialogActionDowngrade => '降级';

  @override
  String get dialogTitleCNSInstall => '安装主 CNS 系统';

  @override
  String get dialogContentCNSInstall =>
      '您即将安装基础自定义纳米服系统（CNS）。这是 CNS 模组工作所必需的。您想继续吗？';

  @override
  String get dialogActionInstall => '安装';

  @override
  String get settingsDeveloperOptions => '开发者选项';

  @override
  String get devDeleteNexusInfoTitle => '删除所有 nexus_info.json 文件';

  @override
  String get devDeleteNexusInfoDesc => '从每个模组中删除所有管理器元数据文件。这对于强制进行完全修复很有用。';

  @override
  String get devExtractIdsTitle => '提取标识符';

  @override
  String get devExtractIdsDesc =>
      '在您的桌面上创建一个名为 \'ID Mods.json\' 的文件，其中包含每个模组的 displayName 和 nexusId。';

  @override
  String get devConfirmDeleteTitle => '确认删除';

  @override
  String get devConfirmDeleteDesc =>
      '您确定要永久删除所有 nexus_info.json 文件吗？这将删除所有自定义名称、封面和元数据。此操作无法撤销。';

  @override
  String get devDeleteSuccessTitle => '删除完成';

  @override
  String devDeleteSuccessDesc(Object count) {
    return '成功删除 $count 个 nexus_info.json 文件。';
  }

  @override
  String get devConfirmExtractTitle => '确认提取';

  @override
  String get devConfirmExtractDesc =>
      '这将扫描您的所有模组并在您的桌面上创建 \'ID Mods.json\'。这将覆盖任何同名的现有文件。您想继续吗？';

  @override
  String get devExtractAction => '提取';

  @override
  String get devTestSelfUpdateTitle => '测试自动安装';

  @override
  String get devTestSelfUpdateDesc =>
      '选择应用的 .zip 安装包，并将其覆盖安装到当前应用上，与自动更新的方式相同。';

  @override
  String get devSelfUpdateUnsupported => '自动更新仅在 Windows 上可用。';

  @override
  String get devSelfUpdatePickTitle => '选择 SB Control Center 的 .zip 文件';

  @override
  String get devSelfUpdateFailed => '无法安装更新';

  @override
  String get devSelfUpdateDryRunTitle => '安装包有效（测试模式）';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return '找到 $count 个文件。由于这不是发布版本，因此未进行安装。';
  }

  @override
  String get devSelfUpdateConfirmTitle => '是否安装更新？';

  @override
  String get devSelfUpdateConfirmDesc => '应用将关闭，用安装包中的文件替换自身文件，然后自动重新打开。';

  @override
  String get devSelfUpdateInstallAction => '安装并重启';

  @override
  String get devSelfUpdateProgressTitle => '正在更新 SB Control Center';

  @override
  String get devSelfUpdateExtracting => '正在解压安装包…';

  @override
  String get devSelfUpdateInstalling => '正在安装文件…';

  @override
  String get devSelfUpdateRestarting => '正在重启…';

  @override
  String get devExtractNoData => '未找到具有有效标识符的模组可供提取。';

  @override
  String get devExtractDesktopNotFound => '错误：找不到桌面目录。';

  @override
  String get devExtractSuccessTitle => '提取完成';

  @override
  String devExtractSuccessDesc(Object path) {
    return '文件成功创建于：$path';
  }

  @override
  String get errorDialogTitle => '发生错误';

  @override
  String get modDetailsCategory => '类别';

  @override
  String get modDetailsAuthor => '作者';

  @override
  String get modDetailsNexusId => 'Nexus ID';

  @override
  String get modDetailsInstalledOn => '安装于';

  @override
  String get unknownAuthor => '未知';

  @override
  String get statusInstalling => '正在安装...';

  @override
  String statusInstallingMod(int index, int total, String modName) {
    return '正在安装 $index/$total: $modName';
  }

  @override
  String byText(Object author) {
    return '作者：$author';
  }

  @override
  String get filterUpdatesAvailable => '可用更新';

  @override
  String snackBarUpdateIgnored(String modName) {
    return '已在此会话中忽略“$modName”的更新。';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return '“$modName”的版本“$version”将在未来的检查中被跳过。';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return '正在更新“$displayName”的元数据($arg1/$arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return '已安装通用 Mod：$modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return '已安装到 $path。\n此 mod 不受应用管理，必须手动卸载。';
  }

  @override
  String genericModInstallError(String modName) {
    return '安装通用 mod 失败：$modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => '通用';

  @override
  String get modTypeMovies => '影片';

  @override
  String get modTypeSave => '存档';

  @override
  String get modTypeConfig => '配置';

  @override
  String get modTypeSplash => '启动画面';

  @override
  String get replacesOutfitTitle => '替换服装';

  @override
  String get replacesOutfitClearTooltip => '清除服装选择';

  @override
  String get replacesOutfitSelectTooltip => '选择要替换的服装';

  @override
  String get replacesOutfitNone => '未选择服装。\n标签将为“通用”。';

  @override
  String get replacesOutfitSearchHint => '搜索服装...';

  @override
  String get modTypeReplacement => '替换';

  @override
  String get replacesOutfitHover => '悬停在服装上以查看预览。';

  @override
  String get dialogTitleOutfitReplacement => '替换服装？';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return 'Mod \'$modName\' 是服装替换吗？\n\n选择“是”以选择它替换的服装，或“否”以将其安装为通用 mod。';
  }

  @override
  String get dialogActionNo => '否';

  @override
  String get dialogActionYes => '是';

  @override
  String get dialogTitleOutfitConflict => '检测到服装冲突';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return '服装 \'$outfitName\' 已被 mod \'$modName\' 替换。\n\n您想禁用 \'$modName\' 并激活这一个吗？';
  }

  @override
  String get dialogActionActivateAndDisable => '禁用并激活';

  @override
  String get replacementModSwitchTitle => '替换 mod';

  @override
  String get replacementModSwitchDesc => '检查此 mod 是否设计为替换游戏中的套装。';

  @override
  String get settingsShowModTagsTitle => '显示 mod 类型标签';

  @override
  String get settingsShowModTagsDesc =>
      '在列表中的每个 mod 卡片上显示 mod 类型标签（例如 CNS、通用）。';

  @override
  String get modTypeLogic => '逻辑';

  @override
  String get patcherStarted => '=== StellarBlade Dart 补丁程序已启动 ===';

  @override
  String workingDirectory(String path) {
    return '工作目录：$path';
  }

  @override
  String modsDirNotFound(String path) {
    return '在以下位置不存在 ~mods 目录：$path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  警告：无法扫描文件夹 $path。跳过。';
  }

  @override
  String errorDetails(String error) {
    return '  错误：$error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return '找到 $count 个 .utoc 文件';
  }

  @override
  String get noModsFound2 => '未找到要处理的模组。';

  @override
  String get patcherSummaryTitle => '\n=== 补丁程序摘要（原始数据） ===';

  @override
  String processedMods(int count) {
    return '已处理 $count 个模组。';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return '修复了 $count 个 Container ID 冲突。';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return '找到了 $count 个 Package ID 冲突。';
  }

  @override
  String get fatalErrorTitle => '\n=== 致命错误 ===';

  @override
  String patcherServiceError(String error) {
    return 'PatcherService 中发生错误：$error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- 正在分析：$fileName ---';
  }

  @override
  String get warnUcasNotFound => '  警告：未找到 .ucas 文件。跳过。';

  @override
  String get warnCorruptHeader => '  警告：标头损坏，条目大小超出了文件大小。跳过。';

  @override
  String conflictContainerIdDetected(int id) {
    return '  检测到 Container ID 冲突：$id';
  }

  @override
  String generatingNewId(int id) {
    return '  正在生成新的 ID：$id';
  }

  @override
  String get utocFilePatched => '  已修补 .utoc 文件。';

  @override
  String get patchingUcasFile => '  正在修补 .ucas 文件...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  在 .ucas 中成功替换：$count';
  }

  @override
  String get patchComplete => '  修补完成！';

  @override
  String idRegisteredNoConflict(int id) {
    return '  已注册 ID $id。无冲突。';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  处理 $fileName 时发生错误：$error';
  }

  @override
  String get statusRunningPatcher => '正在运行冲突修补程序...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ 成功！修复了 $count 个导致崩溃的 Container ID 冲突。';
  }

  @override
  String get summaryNoContainerIdConflicts => '✅ 未发现 Container ID（崩溃）冲突。';

  @override
  String get summaryNoPackageIdConflicts => '✅ 好消息！未发现严重的 Package ID（覆盖）冲突。';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ 警告！发现了 $count 组无法共存的模组：';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • 这组模组竞争 $count 个文件：';
  }

  @override
  String get patcherSummaryDialogTitle => '补丁程序摘要';

  @override
  String get dialogActionShowFullLog => '显示完整日志';

  @override
  String get fullLogDialogTitle => '冲突补丁程序日志 (Dart)';

  @override
  String get runConflictPatcherTitle => '运行冲突补丁程序';

  @override
  String get runConflictPatcherSubtitlePython =>
      '修复 Container_Id 和 Package_Id 崩溃';

  @override
  String get processingCover => '正在处理封面...';

  @override
  String get apiKeyTooltip => '智能提取 Nexus ID 需要 API 密钥。';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return '安装选项 - 模组 $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection => '选择您要安装的选项。所需的主要文件将自动安装。';

  @override
  String get snackBarSpecialModNoSelection => '请至少选择一个选项以继续。';

  @override
  String get dialogActionInstallSelection => '安装所选内容';

  @override
  String get downloadStatusFetching => '正在获取 Nexus Mods 数据...';

  @override
  String get downloadStatusFetchingFailed => '获取下载链接失败。请检查您的 API 密钥或网络连接。';

  @override
  String downloadStatusDownloading(String fileName) {
    return '正在下载 $fileName';
  }

  @override
  String get downloadStatusError => '文件下载期间发生错误。';

  @override
  String downloadStatusException(String error) {
    return '异常：$error';
  }

  @override
  String get dialogTitleDownloadModManager => '模组管理器下载';

  @override
  String get launchGameText => '启动《星刃》';

  @override
  String get stopGameText => '关闭《星刃》';

  @override
  String get dialogTitleStopGame => '要关闭《星刃》吗？';

  @override
  String get dialogContentStopGame => '游戏将被关闭，未保存的进度将丢失。';

  @override
  String get dialogActionStopGame => '关闭';

  @override
  String get notificationGameStopped => '《星刃》已关闭';

  @override
  String get errorStoppingGame => '无法关闭游戏';

  @override
  String get mod801DialogTitle => '需要配置 Steam';

  @override
  String get mod801DialogIntro =>
      '已安装 Random Splash 模组。为了让它在启动游戏时自动生效，您需要配置 Steam。';

  @override
  String get mod801Step1 => '1. 请在下方生成您电脑的准确路径并复制。';

  @override
  String get mod801Step2 => '2. 打开您的 Steam 库。';

  @override
  String get mod801Step3 => '3. 右键点击 Stellar Blade -> 属性。';

  @override
  String get mod801Step4 => '4. 在“通用”选项卡中，将代码粘贴到“启动选项”中。';

  @override
  String get mod801BtnGenerate => '生成路径';

  @override
  String get mod801BtnSteam => '打开 Steam';

  @override
  String get mod801BtnCopy => '复制';

  @override
  String get mod801PathGenerated => '路径生成成功。';

  @override
  String get mod801PathCopied => '命令已复制到剪贴板！';

  @override
  String get statusVerifyingMods => '正在验证模组完整性...';

  @override
  String errorSelecting7Zip(String error) {
    return '选择 7-Zip 时出错：$error';
  }

  @override
  String get errorInvalidFolderRetry => '所选文件夹似乎不正确，请重试。';

  @override
  String errorSelectingFolderDynamic(String error) {
    return '选择文件夹时出错：$error';
  }

  @override
  String get statusNoNewModsInstalled => '安装未产生新模组。';

  @override
  String get errorDisableModBeforeDelete => '请在删除模组前先将其禁用。';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return '已启用：$successCount（由于冲突跳过：$skippedCount）';
  }

  @override
  String get snackBarDeveloperModeEnabled => '开发者模式已启用！';

  @override
  String errorRenamingMod(String error) {
    return '重命名模组时出错：$error';
  }

  @override
  String get notificationTitleError => '错误';

  @override
  String get errorGamePathNotFoundNotification => '未找到游戏路径。';

  @override
  String get notificationLaunchingGame => '正在启动 Stellar Blade...';

  @override
  String get errorLaunchingGame => '启动游戏时出错';

  @override
  String get dialogTitleSelect7zip => '请选择 7z.exe 文件';

  @override
  String get dialogTitleSelectGameFolder => '请选择 StellarBlade 主文件夹';

  @override
  String get dialogTitleSelectCover => '请选择模组封面';

  @override
  String get errorGamePathNotFoundException => '未找到游戏路径。';

  @override
  String get errorGamePathNotDefined => '未定义游戏路径。';

  @override
  String get errorLogicModsPathNotDefined => '未定义 Logic 模组路径。';

  @override
  String get errorUe4ssModsPathNotDefined => '未定义 UE4SS 模组路径。';

  @override
  String get errorGenericModsPathNotDefined => '未定义通用模组 (~mods) 路径。';

  @override
  String get errorReplaceNoOldVersion => '尝试替换模组，但未找到旧版本。';

  @override
  String errorDeleteOldModVersion(String modName) {
    return '无法删除旧版模组 ($modName)。';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return '无法删除现有模组 ($modName) 以重新安装。';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return '多次尝试后仍无法删除现有模组 ($modName) 以重新安装。';
  }

  @override
  String get errorMoviesModNoValidFiles => '电影模组中不包含有效的视频文件。';

  @override
  String get errorInstallPathUndetermined => '无法确定安装路径。';

  @override
  String get errorMoviesPathsNotDefined => '未定义电影路径。';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return '找不到 $modName 的 nexus_info.json。';
  }

  @override
  String get errorMenuVideoLimitReached => '已达到 99 个菜单视频的上限。';

  @override
  String get errorModRequires529 => '该模组需要 Mod ID 529 才能运行（仅包含 WebM 文件）。';

  @override
  String get errorSplashPathsNotDefined => '未定义启动画面路径。';

  @override
  String get errorSplashNoValidImages => '在模组中未找到有效的图像。';

  @override
  String get errorCouldNotDeleteDirectory => '无法删除目录。';

  @override
  String get errorGameExeNotFound => '未在主文件夹或 Binaries 中找到游戏可执行文件 (.exe)。';

  @override
  String get dialogTitleSplashOptions => '启动画面选项（图像）';

  @override
  String get dialogContentSplashOptions => '请选择您要安装的图像。您可以选择整个文件夹（批量）或单个图像。';

  @override
  String get snackBarSplashNoSelection => '请至少选择一张图像。';

  @override
  String get dialogContentSpecialModSingleSelection => '请选择一个要安装的选项。';

  @override
  String get activeDownloads => '活动下载';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '个模组',
      one: '个模组',
    );
    return '正在下载 $count $_temp0';
  }

  @override
  String get downloadError => '错误';

  @override
  String get downloadCancelled => '已取消';

  @override
  String get downloadPause => '暂停';

  @override
  String get downloadResume => '继续';

  @override
  String get downloadCancel => '取消';

  @override
  String get errorNexusInfoNotFound => '找不到 nexus_info.json。';

  @override
  String logFixingCorruptedJson(String displayName) {
    return '正在修复 $displayName 损坏的 nexus_info.json。';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return '无法更新 $displayName 的元数据: $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return '由于启用了模组 529，已预防性禁用电影模组: $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return '由于启用了模组 801，已预防性禁用启动画面模组: $modName';
  }

  @override
  String logRestoringTildeComponent(String folderName) {
    return '正在恢复 ~mods 组件: $folderName';
  }

  @override
  String logRestoringUe4ssComponent(String folderName) {
    return '正在恢复 UE4SS 组件: $folderName';
  }

  @override
  String logErrorRestoringLogicMod(String error) {
    return '恢复 LogicMod 组件时出错: $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return '正在归档 ~mods 组件: $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return '正在归档 UE4SS 组件: $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return '归档 LogicMod 组件时出错: $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return '跳过 $modName: 此模组的活动变体已存在。';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return '跳过 $modName: 与已占用的服装发生冲突。';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return '无法清理 $modName 的视频备份: $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return '检测到新的 Nexus ID $nexusId。正在获取元数据...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return '已获取并应用 $nexusId 的元数据。';
  }

  @override
  String logFallbackByteCopy(String error) {
    return '常规复制失败，正在使用字节暴力破解: $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return '警告: 无法删除修改后的文件: $error';
  }

  @override
  String get logMod801BatPatched => '已成功为此系统修补模组 801 的 .bat 脚本。';

  @override
  String logMod801BatPatchError(String error) {
    return '尝试修补模组 801 的 .bat 文件时出错: $error';
  }

  @override
  String get errorHomeDirNotFound => '找不到主目录环境变量。';

  @override
  String get downloadFetchingPlaceholder => '获取中...';

  @override
  String get downloadErrorLink => '无法获取下载链接';

  @override
  String get downloadErrorGeneral => '下载失败';

  @override
  String get downloadPausedStatus => '已暂停';

  @override
  String get settingsFixGameStartup => '修复游戏无法启动';

  @override
  String get settingsFixGameStartupDesc =>
      '当游戏启动时闪退或崩溃时使用。将临时卸载 UE4SS 和 CNS，启动一次游戏，然后重新安装。';

  @override
  String get repairConfirmTitle => '修复游戏启动？';

  @override
  String get repairConfirmMessage =>
      '将卸载 UE4SS 和 CNS（文件会被安全保存），游戏会自动启动并关闭，然后重新安装所有组件并再次启动游戏。过程中请勿关闭应用。';

  @override
  String get repairConfirmAction => '开始修复';

  @override
  String get launchRetryTitle => '游戏未能启动';

  @override
  String get launchRetryMessage =>
      '尝试两次后 Stellar Blade 仍未启动。这通常由 UE4SS 或 CNS 引起。“修复游戏无法启动”会暂时卸载它们，启动游戏一次，然后重新安装。要现在运行吗？';

  @override
  String get launchRetryAction => '立即修复';

  @override
  String get repairOverlayTitle => '正在修复游戏启动';

  @override
  String get repairOverlayWarning => '运行期间请勿手动关闭应用或游戏。';

  @override
  String get repairStepCloseGame => '如游戏正在运行则关闭';

  @override
  String get repairStepStashCns => '卸载 CNS（保存文件）';

  @override
  String get repairStepStashUe4ss => '卸载 UE4SS（保存文件）';

  @override
  String get repairStepLaunchClean => '在没有 UE4SS 和 CNS 的情况下启动游戏';

  @override
  String get repairStepWaitInit => '等待游戏加载';

  @override
  String get repairStepCloseAuto => '自动关闭游戏';

  @override
  String get repairStepRestoreUe4ss => '重新安装 UE4SS';

  @override
  String get repairStepRestoreCns => '重新安装 CNS';

  @override
  String get repairStepLaunchFinal => '启动游戏';

  @override
  String get repairStatusSkipped => '已跳过';

  @override
  String get repairResultSuccess => '修复完成，游戏已启动。';

  @override
  String get repairResultErrorRestored => '修复失败，但 UE4SS 和 CNS 已恢复原状。';

  @override
  String get repairResultErrorRestoreFailed => '修复失败，文件暂时无法恢复。下次启动应用时将自动恢复。';

  @override
  String get repairErrorGameNotStarted => '游戏未能在规定时间内启动。';

  @override
  String get repairButtonClose => '关闭';

  @override
  String get repairRecoveredNotice => '检测到上次修复被中断：已恢复 UE4SS 和 CNS 文件。';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return '已安装新的变体：$name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return '此 Mod 现已安装 $count 个变体。';
  }

  @override
  String get previewTagNewEdition => '新变体';

  @override
  String get previewTagUpdate => '更新';

  @override
  String editionsInstalledTooltip(Object count) {
    return '已安装此 Mod 的 $count 个变体';
  }

  @override
  String editionLabelValue(Object edition) {
    return '变体：$edition';
  }

  @override
  String get otherEditionsTitle => '已安装的其他变体';

  @override
  String get detailsStatusEnabled => '已启用';

  @override
  String get detailsStatusDisabled => '已禁用';

  @override
  String get detailsInformation => '信息';

  @override
  String get detailsRowAuthor => '作者';

  @override
  String get detailsRowType => '类型';

  @override
  String get detailsRowInstalled => '安装时间';

  @override
  String get detailsRowModified => '最后修改';

  @override
  String get detailsRowNexusId => 'Nexus ID';

  @override
  String get detailsRowFolder => '文件夹';

  @override
  String get detailsCopyPath => '复制路径';

  @override
  String get detailsCopied => '已复制到剪贴板';

  @override
  String get detailsEndorse => 'Endorse';

  @override
  String get detailsEndorsed => 'Endorsed';

  @override
  String endorseWaitLabel(Object minutes) {
    return '请等待 $minutes 分钟';
  }

  @override
  String get endorseSuccessTitle => '已 Endorse 模组';

  @override
  String get endorseRemovedTitle => '已取消 Endorse';

  @override
  String get endorseFailedTitle => '无法更新 Endorse 状态';

  @override
  String get endorseErrNotNexus => '此模组未关联 Nexus Mods 页面，因此无法 Endorse。';

  @override
  String get endorseErrNoApiKey => '请在设置中添加你的 Nexus Mods API 密钥以 Endorse 模组。';

  @override
  String endorseErrWait(Object minutes) {
    return 'Nexus 要求下载模组 15 分钟后才能 Endorse。请在 $minutes 分钟后重试。';
  }

  @override
  String get endorseErrNotDownloaded => 'Nexus 仅允许对你用自己的账号下载过的模组进行 Endorse。';

  @override
  String get endorseErrOwnMod => '你不能 Endorse 自己的模组。';

  @override
  String get endorseErrRateLimit => '你已达到 Nexus 的请求上限。请稍后再试。';

  @override
  String get endorseErrInvalidKey => 'Nexus 拒绝了你的 API 密钥。请在设置中检查。';

  @override
  String get endorseErrNetwork => '无法连接到 Nexus Mods。请检查网络连接后重试。';

  @override
  String get endorseErrUnknown => 'Nexus 无法处理该请求。请稍后再试。';

  @override
  String get endorseRemoveConfirmTitle => '取消 Endorse？';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return '$name 将不再在 Nexus Mods 上被 Endorse。';
  }

  @override
  String get endorseRemoveConfirmAction => '取消认可';

  @override
  String get detailsUpdateAction => '更新';

  @override
  String get detailsShowMore => '显示更多';

  @override
  String get detailsShowLess => '收起';

  @override
  String get detailsAddNote => '添加备注';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件服装',
      one: '1 件服装',
      zero: '无服装',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return '已选择 $count 件';
  }

  @override
  String get outfitsChoose => '选择服装';

  @override
  String get outfitsDone => '完成';

  @override
  String get outfitsFilterAll => '全部';

  @override
  String get outfitsFilterSelected => '已选择';

  @override
  String get outfitsClearAll => '全部清除';

  @override
  String get outfitsRemove => '移除';

  @override
  String get outfitsActionSelect => '选择';

  @override
  String get outfitsActionDeselect => '取消选择';

  @override
  String outfitsNoResults(String query) {
    return '未找到“$query”的结果';
  }

  @override
  String get outfitsSelectedEmpty => '尚未选择服装。';

  @override
  String get outfitsNoPreview => '暂无预览';

  @override
  String get replacementOffConfirmTitle => '关闭替换模组？';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '所选的 $count 件服装将从此模组中移除。',
      one: '所选服装将从此模组中移除。',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => '关闭';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已关闭 $count 个模组：它们替换了其他模组已在使用的服装',
      one: '已关闭 1 个模组：它替换了另一个模组已在使用的服装',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  与以下模组的 Container ID 相同：$owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved => '  原文件已保留为 .cnsbak（可恢复）。';

  @override
  String patcherLeftUntouched(String reason) {
    return '  保持不变（打补丁不安全）：$reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ $count 个模组共用同一个 Container ID，但无法安全修复（保持不变；它们可能不会显示在 CNS 中）：';
  }

  @override
  String get revertPatchesTitle => '还原冲突补丁';

  @override
  String get revertPatchesDesc => '还原被冲突补丁程序修改过的原始模组文件。';

  @override
  String get revertPatchesConfirmTitle => '还原冲突补丁？';

  @override
  String get revertPatchesConfirmMessage =>
      '将还原冲突补丁程序保存的原始文件（.cnsbak）。请先关闭游戏。存在冲突的模组可能会再次不在 CNS 中显示。';

  @override
  String get revertPatchesAction => '还原';

  @override
  String revertPatchesDone(int count) {
    return '已还原 $count 个文件。';
  }

  @override
  String get revertPatchesNothing => '没有需要还原的已打补丁文件。';

  @override
  String get settingsGroupPaths => '路径';

  @override
  String get settingsGroupTools => '工具';

  @override
  String get settingsAutoOutfit => '自动分配服装';

  @override
  String get settingsAutoOutfitDesc =>
      '安装替换类 Mod 时，通过读取其文件自动检测它替换的服装。关闭后需手动分配服装。';

  @override
  String get variantChoiceTitle => '同一替换的多个变体';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return 'Mod“$mod”包含多个替换 $outfits 的变体。同一时间只能启用一个。要安装哪一个？';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return 'Mod“$mod”包含多个替换相同文件的变体。同一时间只能启用一个。要安装哪一个？';
  }

  @override
  String get variantChoiceInstallAll => '全部安装（作为独立 Mod）';

  @override
  String get installOutfitConflictTitle => '服装已被占用';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return 'Mod“$newMod”会替换服装 $outfits，但该服装已分配给已启用的 Mod“$oldMod”。同一时间只能启用一个。要保留哪一个？';
  }

  @override
  String get installOutfitKeepCurrent => '保留当前的';

  @override
  String get installOutfitUseNew => '启用新的';

  @override
  String installOutfitNowActive(String active) {
    return '当前已启用：$active';
  }

  @override
  String get fileLockErrorTitle => '无法移动该 Mod';

  @override
  String get fileLockErrorMessage =>
      '可能有其他应用程序正在使用游戏文件（FModel、游戏本身、杀毒软件、文件资源管理器等）。请关闭后重试。';

  @override
  String get nexusProfileTooltip => 'Nexus Mods 个人资料';

  @override
  String get nexusUserFallback => '用户';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => '会员';

  @override
  String get nexusPlanSupporter => '支持者';

  @override
  String get nexusApiRequestsRemaining => '剩余 API 请求';

  @override
  String get nexusApiDaily => '每日';

  @override
  String get nexusApiHourly => '每小时';

  @override
  String get downloadMemberAccountLimit => 'Nexus Mods 将会员账户限速为 1.5 MB/s';

  @override
  String get downloadSupporterAccountLimit => 'Nexus Mods 将支持者账户限速为 3 MB/s';

  @override
  String get downloadRetryTooltip => '重试';

  @override
  String get downloadRefreshingLink => '正在刷新链接...';

  @override
  String get downloadNoInternet => '无网络连接。请检查你的网络。';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'Nexus 链接已过期 ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'HTTP 错误：$code';
  }

  @override
  String get downloadErrorTimeout => '超时：未收到网络数据';

  @override
  String get splashRootFolder => '根目录（主）';

  @override
  String get repairErrorGameNotClosed => '无法关闭游戏进程。';

  @override
  String get errorManifestNotFound => '未找到安装清单，无法卸载。';

  @override
  String get downloadResuming => '正在恢复...';

  @override
  String get apiKeyPromptTitle => '设置你的 Nexus Mods API 密钥';

  @override
  String get apiKeyPromptMessage =>
      '未检测到 API 密钥。设置是可选的，但为了方便起见建议配置：它可让你检查模组更新、一键下载 (nxm://)，并加载 Nexus Mods 的封面和信息。';

  @override
  String get apiKeyPromptConfigure => '设置 API 密钥';

  @override
  String get apiKeyPromptSkip => '跳过';

  @override
  String get apiKeyPromptDontShowAgain => '不再显示此消息';

  @override
  String get adjustCoverTooltip => '调整封面';

  @override
  String get noCoverToAdjust => '此模组没有可调整的封面';

  @override
  String errorAdjustingCoverText(Object error) {
    return '调整封面时出错：$error';
  }
}
