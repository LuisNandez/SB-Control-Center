// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => '設定';

  @override
  String get settingsGeneral => '一般';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageDesc => 'アプリケーションの言語を選択してください';

  @override
  String get settingsAbout => '概要';

  @override
  String get settingsAboutDesc => 'アプリケーションに関する情報';

  @override
  String get settingsRefreshMetadata => 'メタデータを更新';

  @override
  String get settingsRefreshMetadataDesc =>
      'Nexus ModsでMODを再確認し、不足している情報や画像を補完します';

  @override
  String get metadataRefreshDone => 'メタデータを更新しました';

  @override
  String get metadataRefreshNoApiKey =>
      'メタデータを更新するには、設定でNexus ModsのAPIキーを入力してください。';

  @override
  String get settingsPathsAndTools => 'パスとツール';

  @override
  String get settingsGameFolder => 'ゲームフォルダ';

  @override
  String get settingsGameFolderDesc => 'Stellar Bladeがインストールされているルートフォルダです。';

  @override
  String get settings7zipPath => '7-Zipのパス';

  @override
  String get settings7zipPathDesc => 'MODを解凍するための7z.exeファイルの場所です。';

  @override
  String get settings7zipPathAuto => '自動検索';

  @override
  String get settingsRepairMods => 'レガシーMODを修復';

  @override
  String get settingsRepairModsDesc =>
      'ローカルデータベースを使用して古いMODをスキャンし、情報ファイルを作成します。APIキーが必要です。';

  @override
  String get settingsConnectivity => '接続とアップデート';

  @override
  String get settingsApiKey => 'Nexus Mods APIキー';

  @override
  String get settingsApiKeyDesc => 'MODのアップデートを確認するために必要です。';

  @override
  String get settingsApiKeySet => '設定済み';

  @override
  String get settingsApiKeyNotSet => '未設定';

  @override
  String get settingsSkippedVersions => 'スキップしたバージョンを管理';

  @override
  String get settingsSkippedVersionsDesc => 'スキップすることを選択したMODのバージョンを管理します。';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count個のバージョンがスキップされました';
  }

  @override
  String get dialogTitleSkippedVersions => 'スキップされたMODバージョン';

  @override
  String get dialogNoSkippedVersions => 'スキップしたMODバージョンはありません。';

  @override
  String get dialogSkippedVersions => 'スキップされたバージョン';

  @override
  String get dialogTitleRepairMods => 'レガシーMODの修復を実行しますか？';

  @override
  String get dialogContentRepairMods =>
      '警告：この機能は開発中であり、完全ではない可能性があります。\n\n\'nexus_info.json\'ファイルのないMODをスキャンし、ローカルデータベースで見つかった場合はそれらのファイルを作成します。また、見つかったバージョンを含むようにMODのフォルダ名を変更しようとします（例：\'My Mod\' -> \'My Mod v1.2\'）。\n\nバージョン優先度：\n1. フォルダ名から\n2. MODの説明フィールドから\n3. Nexus Modsの最新バージョンから（APIが必要）\n\n続行しますか？';

  @override
  String get dialogActionRunRepair => '修復を実行';

  @override
  String get snackBarGamePathInvalid => '選択されたフォルダは有効なゲームフォルダではないようです。';

  @override
  String get snackBar7zipPathInvalid => '選択されたファイル名は7z.exeでなければなりません。';

  @override
  String get snackBarRepairStarted => 'レガシーMODの修復プロセスが開始されました...';

  @override
  String snackBarRepairComplete(Object count) {
    return '修復が完了しました。$count個のMODが更新されました。';
  }

  @override
  String get snackBarRepairNoMods => '修復が必要なレガシーMODは見つかりませんでした。';

  @override
  String get errorApiRequiredForRepair =>
      'ローカルバージョンがないMODの最新バージョンを見つけるにはAPIキーが必要です。';

  @override
  String get installNewMod => 'MODをインストール';

  @override
  String get selectFiles => 'ファイルを選択';

  @override
  String get selectFolder => 'フォルダを選択';

  @override
  String get installSelectedMod => '選択したMODをインストール';

  @override
  String get filesToInstall => 'インストールするファイル：';

  @override
  String get cancelSelection => '選択をキャンセル';

  @override
  String get searchMods => 'MODを検索...';

  @override
  String get enabledMods => '有効なMOD';

  @override
  String get disabledMods => '無効なMOD';

  @override
  String get refreshList => 'リストを更新';

  @override
  String get noEnabledMods => '有効なMODはありません。';

  @override
  String get noDisabledMods => '無効なMODはありません。';

  @override
  String get showInFolder => 'フォルダに表示';

  @override
  String get disableMod => 'MODを無効化';

  @override
  String get enableMod => 'MODを有効化';

  @override
  String get deletePermanently => '完全に削除';

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択してください';

  @override
  String get statusSearchingGame => 'Stellar Bladeのインストールを検索中...';

  @override
  String get statusGamePathFound => 'ゲームパスが見つかりました！';

  @override
  String get statusGamePathNotFound => 'ゲームパスを自動的に見つけることができませんでした。';

  @override
  String statusErrorFindingGame(Object error) {
    return 'ゲームの検索中にエラーが発生しました：$error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount個のMODが有効、$disabledCount個が無効です。';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return 'インストールされたMODの読み取り中にエラーが発生しました：$error';
  }

  @override
  String statusFilesSelected(Object count) {
    return '$count個のファイルが選択されました。インストール準備完了です。';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return 'フォルダ「$folderName」が選択されました。インストール準備完了です。';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return 'ファイル「$fileName」が読み込まれました。$count個のファイルがインストール準備完了です。';
  }

  @override
  String get statusSelectionCancelled =>
      '選択がキャンセルされました。インストールする新しいMODを選択してください。';

  @override
  String get statusUpdateComplete => 'アップデートが完了しました。';

  @override
  String get statusInstallationComplete => 'インストールが完了しました。';

  @override
  String statusError(Object error) {
    return 'エラー：$error';
  }

  @override
  String get dialogTitle7zip => '7-Zipが必要です';

  @override
  String get dialogContent7zip =>
      'このファイルを解凍するには、アプリケーションに7-Zipが必要です。\n\n公式サイトからインストールし、「確認」を押してください。';

  @override
  String get dialogContent7zipNotFound =>
      '7-Zipがまだ検出されていません。デフォルトのパスにインストールされていることを確認してから、もう一度お試しください。';

  @override
  String get dialogTitleMultipleJsons => '複数の.jsonファイルが検出されました';

  @override
  String dialogContentMultipleJsons(Object count) {
    return '$count個の.jsonファイルが検出されました。これは複数のコンポーネントを持つMODである可能性があります。\n\nそれらをすべて1つのMODフォルダにまとめてインストールしますか？';
  }

  @override
  String get dialogTitleModExists => 'MODはすでに存在します';

  @override
  String dialogContentModExists(Object modName) {
    return '「$modName」という名前のMODはすでにインストールされています。\n\n更新しますか？新しいファイルをインストールする前に、古いファイルは削除されます。';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return '古いバージョン「$oldModName」が見つかりました。\n\nそれを削除して「$newModName」に更新しますか？';
  }

  @override
  String get dialogTitleDeleteMod => '完全に削除しますか？';

  @override
  String dialogContentDeleteMod(Object modName) {
    return 'MOD「$modName」を完全に削除しようとしています。この操作は元に戻せません。\n\nよろしいですか？';
  }

  @override
  String get dialogActionCancel => 'キャンセル';

  @override
  String get dialogActionGoToDownload => 'ダウンロードページへ';

  @override
  String get dialogActionConfirmInstallation => 'インストールを確認';

  @override
  String get dialogActionUpdateSystem => 'システムを更新';

  @override
  String get dialogActionInstallAnyway => 'とにかくインストール';

  @override
  String get dialogActionDelete => '削除';

  @override
  String get dialogActionClose => '閉じる';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return '一括インストールが完了しました。成功：$successCount、失敗：$failedCount。';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return 'MOD「$modName」が正常にインストールされました。';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return 'MOD「$modName」が有効になりました。';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return 'MOD「$modName」が無効になりました。';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return 'MOD「$modName」が完全に削除されました。';
  }

  @override
  String get snackBarCNSUpdated => 'カスタムナノスーツシステムが正常に更新されました。';

  @override
  String get snackBarApiKeySaved => 'APIキーが正常に保存されました。';

  @override
  String get snackBarGamePathSaved => 'ゲームパスが正常に保存されました。';

  @override
  String get snackBar7zipPathSaved => '7-Zipのパスが正常に保存されました。';

  @override
  String get snackBarSkippedVersionRemoved => 'スキップされたバージョンが削除されました。';

  @override
  String get dropTargetOverlay => 'ここにMODをドロップしてください';

  @override
  String get pathSelectionTitle => 'Stellar Bladeのパスが見つかりません';

  @override
  String get pathSelectionButtonManual => 'ゲームフォルダを手動で選択';

  @override
  String get pathSelectionButtonRetry => '再試行';

  @override
  String errorFolderSelection(Object error) {
    return 'フォルダの選択中にエラーが発生しました：$error';
  }

  @override
  String errorFileSelection(Object error) {
    return 'ファイルの選択中にエラーが発生しました：$error';
  }

  @override
  String errorDecompressing(Object error) {
    return 'ファイルの解凍中にエラーが発生しました：$error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return 'ファイルの処理中にエラーが発生しました：$error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return 'サポートされていないファイル形式です：$extension';
  }

  @override
  String get error7zipRequired => '操作がキャンセルされました：7-Zipが必要です。';

  @override
  String get errorGamePathUndefined => 'ゲームパスが定義されていません。';

  @override
  String get errorDestinationNotFound => 'ゲームの宛先フォルダが存在しません。';

  @override
  String errorUpdateSystem(Object error) {
    return 'システムの更新中にエラーが発生しました：$error';
  }

  @override
  String get errorInstallNoSelection => 'インストールするものを選択していません。';

  @override
  String get errorInstallModExists => 'インストールがキャンセルされました：MODはすでに存在します。';

  @override
  String get errorNoJsonFound => '各MODには少なくとも1つの.jsonファイルが含まれている必要があります。';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return 'ファイル$fileNameは無効なJSON形式です。';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return 'ファイル$fileNameはカスタムナノスーツシステムのMODではないようです（「DisplayName」がありません）。';
  }

  @override
  String get errorNoValidDisplayName =>
      '.jsonファイルに有効な「DisplayName」が見つかりませんでした。';

  @override
  String errorEnableMod(Object error) {
    return 'MODの有効化中にエラーが発生しました：$error';
  }

  @override
  String errorDisableMod(Object error) {
    return 'MODの無効化中にエラーが発生しました：$error';
  }

  @override
  String errorDeleteMod(Object error) {
    return 'MODの削除中にエラーが発生しました：$error';
  }

  @override
  String errorOpenFolder(Object path) {
    return 'フォルダを開けませんでした：$path';
  }

  @override
  String get statusUpdateSystemCancelled => 'システムの更新がキャンセルされました。';

  @override
  String get statusUpdatingCNS => 'カスタムナノスーツシステムを更新中...';

  @override
  String statusExtractingFile(Object fileName) {
    return '$fileNameを解凍中...';
  }

  @override
  String get statusInstallationCancelledByUser => 'ユーザーによってインストールがキャンセルされました。';

  @override
  String get errorNoCompatibleFilesInFolder =>
      '選択されたフォルダには互換性のあるMODファイルが含まれていません。';

  @override
  String get errorNoCompatibleFilesInArchive =>
      '圧縮ファイルには互換性のあるMODファイルが含まれていません。';

  @override
  String get errorNoJsonInSelection => '選択範囲に有効なMODの.jsonファイルが含まれていません。';

  @override
  String get aboutTitle => 'SB Control Centerについて';

  @override
  String get aboutContent =>
      'SB Control CenterはStellar Blade用のMODマネージャーです。MODのインストール、整理、更新を1か所で行え、衣装やナノスーツ系MOD向けのカスタムナノスーツシステム（CNS）にも対応しています。\n\nNexus Modsと連携して、ダウンロード、更新の確認、使用中のMODへのEndorseができます。\n\n.zip、.rar、.7zファイルの展開には、同梱の7-Zip（7-zip.org）を使用しています。';

  @override
  String get aboutEndorseCta =>
      'このアプリを気に入っていただけましたか？Nexus ModsでのEndorseが大きな助けになります。';

  @override
  String get aboutEndorseThanks => '応援ありがとうございます！';

  @override
  String get aboutLinkText => 'クリエイタープロフィールを見る';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return 'バージョン：$version';
  }

  @override
  String get openModsFolder => 'MODフォルダを開く';

  @override
  String get openInNexusMods => 'Nexus Modsで開く';

  @override
  String get checkForUpdates => 'アップデートを確認';

  @override
  String updateAvailable(Object version) {
    return 'アップデートが利用可能です：v$version';
  }

  @override
  String get dialogTitleApiKey => 'Nexus Mods APIキー';

  @override
  String get dialogContentApiKey =>
      'MODのアップデートを確認するには、Nexus Modsの個人APIキーが必要です。';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. 下のボタンでNexus Modsを開き、ログインします。\n2. ページの最下部にある「Personal API Key」セクションまでスクロールします。\n3. まだ持っていない場合はリクエストし、キーをコピーします。\n4. ここに貼り付けます。';

  @override
  String get apiKeyOpenNexusPage => 'APIキーのページを開く';

  @override
  String get apiKey => 'APIキー';

  @override
  String get apiKeyHintText => 'APIキーをここに貼り付けてください';

  @override
  String get dialogActionSave => '保存';

  @override
  String get apiKeyRemoved => 'APIキーが削除されました。';

  @override
  String get invalidApiKeyError => '無効なAPIキーです。';

  @override
  String get validatingApiKey => '検証中...';

  @override
  String get errorApiKeyMissing =>
      'Nexus ModsのAPIキーが設定されていません。「設定 › 接続とアップデート › Nexus Mods APIキー」から追加してください。';

  @override
  String get statusCheckingUpdates => 'MODのアップデートを確認中...';

  @override
  String statusUpdatesFound(Object count) {
    return '$count個のアップデートが見つかりました！';
  }

  @override
  String get statusNoUpdates => 'すべてのMODは最新です。';

  @override
  String get selectModArchive => 'MODアーカイブを選択';

  @override
  String get viewImageGallery => '画像ギャラリーを表示';

  @override
  String get imageGallery => '画像ギャラリー';

  @override
  String get noImagesFound =>
      'このMODの画像が見つからないか、APIキーが入力されていません。APIキーを入力してからアップデートを確認してください。';

  @override
  String errorFetchingImages(Object error) {
    return '画像の取得中にエラーが発生しました：$error';
  }

  @override
  String get imageMod => 'MOD画像';

  @override
  String get modEnabledBadge => '有効';

  @override
  String get modDisabledBadge => '無効';

  @override
  String get modCategoryOther => '未指定';

  @override
  String get dialogContentUpdateOptions => 'どうしますか？';

  @override
  String get dialogActionIgnoreVersion => '無視';

  @override
  String get dialogActionSkipVersion => 'バージョンをスキップ';

  @override
  String get dialogActionGoToDownloadPage => 'ダウンロードへ';

  @override
  String get installedMods => 'インストール済みMOD';

  @override
  String get filterBy => 'フィルター:';

  @override
  String get sortBy => '並べ替え:';

  @override
  String get filterAll => 'すべて';

  @override
  String get filterEnabled => '有効';

  @override
  String get filterDisabled => '無効';

  @override
  String get filterRepaired => '修復済み';

  @override
  String get sortByName => '名前';

  @override
  String get sortByDate => '日付';

  @override
  String get noModsFound => 'MODが見つかりません。';

  @override
  String get viewTypeGrid => 'グリッド表示';

  @override
  String get viewTypeList => 'リスト表示';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return '$total個中$count個を解凍中：$fileName';
  }

  @override
  String get previewInstallTitle => 'インストールされるMOD：';

  @override
  String get dialogTitleUE4SS => 'UE4SSのインストールが検出されました';

  @override
  String get dialogContentUE4SS =>
      'UE4SSツールが検出されました。\'StellarBlade\\SB\\Binaries\\Win64\'にインストールしますか？\n\nこれは多くのMODが機能するために必要です。';

  @override
  String get dialogActionInstallTool => 'ツールをインストール';

  @override
  String get statusUE4SSInstallCancelled => 'UE4SSのインストールがキャンセルされました。';

  @override
  String get statusInstallingUE4SS => 'UE4SSをインストール中...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SSが正常にインストールされました。';

  @override
  String error7zipDecompression(Object error) {
    return '解凍中の7-Zipエラー：$error';
  }

  @override
  String get statusUE4SSInstallComplete => 'UE4SSのインストールが完了しました。';

  @override
  String get dialogTitleAlternativeVersion => '代替バージョンが検出されました';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return 'このMODの代替バージョンがすでにインストールされています：\'$oldModName\'。\n\n\'$newModName\'という名前の別の代替バージョンをインストールしようとしています。';
  }

  @override
  String get dialogActionReplace => '置き換える';

  @override
  String get dialogActionInstallAsNew => '新規としてインストール';

  @override
  String get dialogTitleUpdate => 'アップデートが利用可能です';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return 'MOD「$modName」を更新しようとしています。\n\nインストール済みバージョン：$oldVersion\n新しいバージョン：$newVersion';
  }

  @override
  String get dialogTitleDowngrade => '古いバージョンが検出されました';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return '警告：MOD「$modName」の古いバージョンをインストールしようとしています。\n\nインストール済みバージョン：$oldVersion\nインストールするバージョン：$newVersion';
  }

  @override
  String get dialogTitleReinstall => 'MODを再インストール';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return 'MOD「$modName」のバージョン「$version」を再インストールしようとしています。';
  }

  @override
  String get dialogActionReinstall => '再インストール';

  @override
  String get editModNameTooltip => 'MOD名を編集';

  @override
  String get setCoverTooltip => 'カスタムカバー画像を設定';

  @override
  String get setCoverText => 'カバーを設定';

  @override
  String get restoreOriginalCoverText => '元のカバーを復元';

  @override
  String errorSavingCoverText(Object error) {
    return 'カバー画像の保存中にエラーが発生しました：$error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return '元のカバー画像の復元中にエラーが発生しました：$error';
  }

  @override
  String get editVersionText => 'バージョンを編集';

  @override
  String get customVersionText => 'カスタムバージョン';

  @override
  String get editTagText => 'タグを編集';

  @override
  String get customTagText => 'カスタムタグ';

  @override
  String get dialogTitleEditModName => 'MOD名を編集';

  @override
  String get dialogActionResetToDefault => 'デフォルトにリセット';

  @override
  String get dialogLabelNewName => '新しい名前';

  @override
  String errorModNameExists(Object modName) {
    return '「$modName」という名前のMODはすでに存在します。';
  }

  @override
  String get dialogTitleRepairedModWarning => '修復されたMODの警告';

  @override
  String get dialogContentRepairedModWarning =>
      'このMODには正しいバージョン情報がない可能性があります。互換性を確保するために最新バージョンを再インストールすることをお勧めします。';

  @override
  String get repairedModTooltip => '修復されたMODに関する情報';

  @override
  String get disableAllModsTooltip => 'すべてのMODを無効化';

  @override
  String get deleteAllModsTooltip => '無効なMODをすべて削除';

  @override
  String get dialogTitleDisableAll => 'すべてのMODを無効にしますか？';

  @override
  String dialogContentDisableAll(int count) {
    return '有効な$count個のMODをすべて無効にしてもよろしいですか？それらはバックアップフォルダに移動されます。';
  }

  @override
  String get dialogTitleDeleteAll => '無効なMODを削除しますか？';

  @override
  String dialogContentDeleteAll(int count) {
    return '無効な$count個のMODをすべて完全に削除しようとしています。この操作は元に戻せません。\n\nよろしいですか？';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return '有効な$count個のMODがすべて無効になりました。';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return '無効な$count個のMODがすべて完全に削除されました。';
  }

  @override
  String get snackBarNoModsToDisable => '無効にする有効なMODはありません。';

  @override
  String get snackBarNoModsToDelete => '削除する無効なMODはありません。';

  @override
  String get enableAllModsTooltip => 'すべてのMODを有効化';

  @override
  String get dialogTitleEnableAll => 'すべてのMODを有効にしますか？';

  @override
  String dialogContentEnableAll(int count) {
    return '無効な$count個のMODをすべて有効にしてもよろしいですか？それらはメインのMODフォルダに移動されます。';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return '無効な$count個のMODがすべて有効になりました。';
  }

  @override
  String get snackBarNoModsToEnable => '有効にする無効なMODはありません。';

  @override
  String get editNotes => 'メモを編集';

  @override
  String get notesHintText => 'ここに個人的なメモを追加してください...';

  @override
  String get modAuthor => '作者';

  @override
  String get modSummary => '概要';

  @override
  String get modDescription => '説明';

  @override
  String get noDescriptionAvailable => '説明はありません。';

  @override
  String get personalNotes => '個人メモ';

  @override
  String get noNotesAvailable => 'まだメモは追加されていません。';

  @override
  String get modDetailsTitle => 'MODの詳細';

  @override
  String get modVersion => 'バージョン';

  @override
  String get modCategory => 'カテゴリ';

  @override
  String get dialogTitleAddUrl => 'MODリンクを追加';

  @override
  String get dialogLabelUrl => 'MODのURL';

  @override
  String get errorInvalidUrl => '有効なURLを入力してください。';

  @override
  String get addLinkTooltip => 'このMODのダウンロードリンクを追加';

  @override
  String get addLinkButtonText => 'リンクを追加';

  @override
  String get openLinkButtonText => 'リンクを開く';

  @override
  String get editModTitle => 'MODの詳細を編集';

  @override
  String get modNameLabel => 'MOD名';

  @override
  String get authorLabel => '作者';

  @override
  String get summaryLabel => '説明/概要';

  @override
  String get notesLabel => '個人メモ';

  @override
  String get urlLabel => 'ダウンロードURL';

  @override
  String get changeCoverButton => 'カバー画像を変更';

  @override
  String get editButtonTooltip => 'MODを編集';

  @override
  String get errorSavingNotes => 'メモの保存中にエラー';

  @override
  String get errorSavingUrl => 'URLの保存中にエラー';

  @override
  String get errorSavingChanges => '変更の保存中にエラー';

  @override
  String get errorTranslation => '説明を翻訳できませんでした';

  @override
  String get translateSummary => '概要を翻訳する';

  @override
  String get translateDescription => '説明を翻訳';

  @override
  String get restoreOriginalDescription => '元の説明に戻す';

  @override
  String get dialogTitleUE4SSReinstall => 'UE4SSを再インストール';

  @override
  String get dialogContentUE4SSReinstall =>
      'UE4SSはすでにインストールされているようです。既存のインストールを上書きしますか？ファイルが破損している疑いがある場合に役立ちます。';

  @override
  String get dialogTitleCNSReinstall => 'CNSシステムを再インストール';

  @override
  String get dialogContentCNSReinstall =>
      'メインのCNSシステムはすでにインストールされているようです。再インストールしますか？既存のMODには影響しません。';

  @override
  String dialogTitleUninstall(Object componentName) {
    return '$componentNameをアンインストール';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return '$componentNameをアンインストールしてもよろしいですか？この操作によりコアコンポーネントファイルは削除されますが、インストール済みのMODには影響しません。';
  }

  @override
  String get dialogActionUninstall => 'はい、アンインストールします';

  @override
  String statusUninstalling(Object componentName) {
    return '$componentNameをアンインストール中...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentNameが正常にアンインストールされました';
  }

  @override
  String errorUninstalling(Object componentName) {
    return '$componentNameのアンインストール中にエラー';
  }

  @override
  String get settingsCoreComponents => 'コアコンポーネント';

  @override
  String get installedStatus => 'インストール済み';

  @override
  String get notInstalledStatus => '未検出';

  @override
  String get uninstallButton => 'アンインストール';

  @override
  String get cnsCoreSystem => 'カスタムナノスーツシステム';

  @override
  String get ue4ssInstallationDetected => '既存のUE4SSインストールが検出され、採用されました';

  @override
  String get cnsInstallationDetected => '既存のメインCNSインストールが検出され、採用されました';

  @override
  String get ue4ssRequiredTitle => 'UE4SSが必要です';

  @override
  String get ue4ssRequiredContent =>
      'メインCNSシステムをインストールするには、まずUE4SSをインストールする必要があります。次のリンクからダウンロードできます：';

  @override
  String get uninstallDependencyTitle => '依存関係が検出されました';

  @override
  String get uninstallDependencyContent =>
      'UE4SSをアンインストールする前に、CNSが依存しているため、メインCNSシステムをアンインストールする必要があります。';

  @override
  String get dialogActionUnderstood => '了解';

  @override
  String get appTitleNoCns => 'カスタムナノスーツシステム（未インストール）';

  @override
  String get dialogTitleCNSUpdate => 'メインCNSシステムを更新';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return 'CNSをバージョン$oldVersionから新しいバージョン$newVersionに更新しようとしています。続行しますか？';
  }

  @override
  String get dialogTitleCNSDowngrade => 'CNSのバージョンをダウングレード';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return '警告！現在のバージョン（$oldVersion）より古いバージョンのCNS（$newVersion）をインストールしようとしています。問題が発生する可能性があります。よろしいですか？';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return 'CNSのバージョン$versionはすでにインストールされています。それでもファイルを再インストールしますか？';
  }

  @override
  String get dialogActionUpdate => '更新';

  @override
  String get dialogActionDowngrade => 'ダウングレード';

  @override
  String get dialogTitleCNSInstall => 'メインCNSシステムをインストール';

  @override
  String get dialogContentCNSInstall =>
      'ベースのカスタムナノスーツシステム（CNS）をインストールしようとしています。これはCNS MODが機能するために必要です。続行しますか？';

  @override
  String get dialogActionInstall => 'インストール';

  @override
  String get settingsDeveloperOptions => '開発者向けオプション';

  @override
  String get devDeleteNexusInfoTitle => 'すべてのnexus_info.jsonファイルを削除';

  @override
  String get devDeleteNexusInfoDesc =>
      'すべてのMODからマネージャーのメタデータファイルをすべて削除します。これは完全な修復を強制する場合に役立ちます。';

  @override
  String get devExtractIdsTitle => '識別子を抽出';

  @override
  String get devExtractIdsDesc =>
      '各MODのdisplayNameとnexusIdを含む「ID Mods.json」という名前のファイルをデスクトップに作成します。';

  @override
  String get devConfirmDeleteTitle => '削除の確認';

  @override
  String get devConfirmDeleteDesc =>
      'すべてのnexus_info.jsonファイルを完全に削除してもよろしいですか？これにより、すべてのカスタム名、カバー、メタデータが削除されます。この操作は元に戻せません。';

  @override
  String get devDeleteSuccessTitle => '削除が完了しました';

  @override
  String devDeleteSuccessDesc(Object count) {
    return '$count個のnexus_info.jsonファイルが正常に削除されました。';
  }

  @override
  String get devConfirmExtractTitle => '抽出の確認';

  @override
  String get devConfirmExtractDesc =>
      'これにより、すべてのMODがスキャンされ、デスクトップに「ID Mods.json」が作成されます。これにより、同じ名前の既存のファイルが上書きされます。続行しますか？';

  @override
  String get devExtractAction => '抽出';

  @override
  String get devTestSelfUpdateTitle => '自動インストールのテスト';

  @override
  String get devTestSelfUpdateDesc =>
      'アプリの .zip パッケージを選択し、自動アップデートと同じように、このアプリに上書きインストールします。';

  @override
  String get devSelfUpdateUnsupported => '自動アップデートは Windows でのみ利用できます。';

  @override
  String get devSelfUpdatePickTitle => 'SB Control Center の .zip を選択';

  @override
  String get devSelfUpdateFailed => 'アップデートをインストールできませんでした';

  @override
  String get devSelfUpdateDryRunTitle => 'パッケージは有効です（テストモード）';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return '$count 個のファイルが見つかりました。リリースビルドではないため、インストールは行われませんでした。';
  }

  @override
  String get devSelfUpdateConfirmTitle => 'アップデートをインストールしますか？';

  @override
  String get devSelfUpdateConfirmDesc =>
      'アプリが終了し、ファイルをパッケージ内のファイルに置き換えてから、自動的に再起動します。';

  @override
  String get devSelfUpdateInstallAction => 'インストールして再起動';

  @override
  String get devSelfUpdateProgressTitle => 'SB Control Center を更新中';

  @override
  String get devSelfUpdateExtracting => 'パッケージを展開中…';

  @override
  String get devSelfUpdateInstalling => 'ファイルをインストール中…';

  @override
  String get devSelfUpdateRestarting => '再起動中…';

  @override
  String get devExtractNoData => '抽出する有効な識別子を持つMODが見つかりませんでした。';

  @override
  String get devExtractDesktopNotFound => 'エラー：デスクトップディレクトリが見つかりませんでした。';

  @override
  String get devExtractSuccessTitle => '抽出が完了しました';

  @override
  String devExtractSuccessDesc(Object path) {
    return 'ファイルは正常に作成されました：$path';
  }

  @override
  String get errorDialogTitle => 'エラーが発生しました';

  @override
  String get modDetailsCategory => 'カテゴリ';

  @override
  String get modDetailsAuthor => '作者';

  @override
  String get modDetailsNexusId => 'Nexus ID';

  @override
  String get modDetailsInstalledOn => 'インストール日';

  @override
  String get unknownAuthor => '不明';

  @override
  String get statusInstalling => 'インストール中...';

  @override
  String statusInstallingMod(int index, int total, String modName) {
    return '$total個中$index個をインストール中：$modName';
  }

  @override
  String byText(Object author) {
    return '作成者：$author';
  }

  @override
  String get filterUpdatesAvailable => '利用可能なアップデート';

  @override
  String snackBarUpdateIgnored(String modName) {
    return '「$modName」の更新はこのセッションでは無視されました。';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return '「$modName」のバージョン「$version」は今後のチェックでスキップされます。';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return '「$displayName」のメタデータを更新中 ($arg1/$arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return '汎用MODインストール済み：$modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return '$path にインストールされました。\nこのMODはアプリによって管理されておらず、手動でアンインストールする必要があります。';
  }

  @override
  String genericModInstallError(String modName) {
    return '汎用MODのインストールに失敗しました：$modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => '汎用';

  @override
  String get modTypeMovies => 'ムービー';

  @override
  String get modTypeSave => 'セーブ';

  @override
  String get modTypeConfig => '設定';

  @override
  String get modTypeSplash => 'スプラッシュ';

  @override
  String get replacesOutfitTitle => '置き換え衣装';

  @override
  String get replacesOutfitClearTooltip => '衣装の選択をクリア';

  @override
  String get replacesOutfitSelectTooltip => '置き換える衣装を選択';

  @override
  String get replacesOutfitNone => '衣装が選択されていません。\nタグは「汎用」になります。';

  @override
  String get replacesOutfitSearchHint => '衣装を検索...';

  @override
  String get modTypeReplacement => '置き換え';

  @override
  String get replacesOutfitHover => '衣装にカーソルを合わせるとプレビューが表示されます。';

  @override
  String get dialogTitleOutfitReplacement => '衣装の置き換え？';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return 'MOD \'$modName\' は衣装の置き換えですか？\n\n「はい」を選択して置き換える衣装を選ぶか、「いいえ」を選択して汎用MODとしてインストールします。';
  }

  @override
  String get dialogActionNo => 'いいえ';

  @override
  String get dialogActionYes => 'はい';

  @override
  String get dialogTitleOutfitConflict => '衣装の競合が検出されました';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return '衣装 \'$outfitName\' は既にMOD \'$modName\' によって置き換えられています。\n\n\'$modName\' を無効にして、こちらを有効にしますか？';
  }

  @override
  String get dialogActionActivateAndDisable => '無効にして有効化';

  @override
  String get replacementModSwitchTitle => '置き換えMOD';

  @override
  String get replacementModSwitchDesc =>
      'このMODがゲーム内のスーツを置き換えるように設計されているか確認してください。';

  @override
  String get settingsShowModTagsTitle => 'MODタイプタグを表示';

  @override
  String get settingsShowModTagsDesc => 'リストの各MODカードにMODタイプタグ（例：CNS、汎用）を表示します。';

  @override
  String get modTypeLogic => 'ロジック';

  @override
  String get patcherStarted => '=== StellarBlade Dart Patcher 開始 ===';

  @override
  String workingDirectory(String path) {
    return '作業ディレクトリ：$path';
  }

  @override
  String modsDirNotFound(String path) {
    return '次の場所の ~mods ディレクトリが存在しません：$path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  警告：フォルダ $path をスキャンできませんでした。スキップします。';
  }

  @override
  String errorDetails(String error) {
    return '  エラー：$error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return '$count 個の .utoc ファイルが見つかりました';
  }

  @override
  String get noModsFound2 => '処理するMODが見つかりません。';

  @override
  String get patcherSummaryTitle => '\n=== パッチャーの概要 (生データ) ===';

  @override
  String processedMods(int count) {
    return '$count 個のMODを処理しました。';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return '$count 個の Container ID の競合を修正しました。';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return '$count 個の Package ID の競合が見つかりました。';
  }

  @override
  String get fatalErrorTitle => '\n=== 致命的なエラー ===';

  @override
  String patcherServiceError(String error) {
    return 'PatcherService のエラー：$error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- 分析中：$fileName ---';
  }

  @override
  String get warnUcasNotFound => '  警告：.ucas ファイルが見つかりません。スキップします。';

  @override
  String get warnCorruptHeader =>
      '  警告：ヘッダーが破損しており、エントリサイズがファイルサイズを超えています。スキップします。';

  @override
  String conflictContainerIdDetected(int id) {
    return '  Container ID の競合が検出されました：$id';
  }

  @override
  String generatingNewId(int id) {
    return '  新しい ID を生成中：$id';
  }

  @override
  String get utocFilePatched => '  .utoc ファイルにパッチを適用しました。';

  @override
  String get patchingUcasFile => '  .ucas ファイルにパッチを適用中...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  .ucas での置換に成功しました：$count';
  }

  @override
  String get patchComplete => '  パッチ完了！';

  @override
  String idRegisteredNoConflict(int id) {
    return '  ID $id が登録されました。競合はありません。';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  $fileName の処理中にエラーが発生しました：$error';
  }

  @override
  String get statusRunningPatcher => '競合パッチャーを実行中...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ 成功！クラッシュの原因となる $count 個の Container ID の競合を修正しました。';
  }

  @override
  String get summaryNoContainerIdConflicts =>
      '✅ Container ID (クラッシュ) の競合は見つかりませんでした。';

  @override
  String get summaryNoPackageIdConflicts =>
      '✅ 朗報です！重大な Package ID (上書き) の競合は見つかりませんでした。';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ 警告！共存できないMODのグループが $count 個見つかりました：';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • このMODグループは $count 個のファイルで競合しています：';
  }

  @override
  String get patcherSummaryDialogTitle => 'パッチャーの概要';

  @override
  String get dialogActionShowFullLog => '完全なログを表示';

  @override
  String get fullLogDialogTitle => '競合パッチャーのログ (Dart)';

  @override
  String get runConflictPatcherTitle => '競合パッチャーを実行';

  @override
  String get runConflictPatcherSubtitlePython =>
      'Container_Id と Package_Id のクラッシュを修正します';

  @override
  String get processingCover => 'カバーを処理中...';

  @override
  String get apiKeyTooltip => 'スマートな Nexus ID 抽出には API キーが必要です。';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return 'インストール オプション - MOD $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection =>
      'インストールしたいオプションを選択してください。必要なメインファイルは自動的にインストールされます。';

  @override
  String get snackBarSpecialModNoSelection => '続行するには少なくとも1つのオプションを選択してください。';

  @override
  String get dialogActionInstallSelection => '選択したものをインストール';

  @override
  String get downloadStatusFetching => 'Nexus Modsのデータを取得中...';

  @override
  String get downloadStatusFetchingFailed =>
      'ダウンロードリンクの取得に失敗しました。APIキーまたは接続を確認してください。';

  @override
  String downloadStatusDownloading(String fileName) {
    return '$fileName をダウンロード中';
  }

  @override
  String get downloadStatusError => 'ファイルのダウンロード中にエラーが発生しました。';

  @override
  String downloadStatusException(String error) {
    return '例外：$error';
  }

  @override
  String get dialogTitleDownloadModManager => 'Mod Managerのダウンロード';

  @override
  String get launchGameText => 'Stellar Bladeを起動';

  @override
  String get stopGameText => 'Stellar Bladeを終了';

  @override
  String get dialogTitleStopGame => 'Stellar Bladeを終了しますか？';

  @override
  String get dialogContentStopGame => 'ゲームを閉じます。保存されていない進行状況は失われます。';

  @override
  String get dialogActionStopGame => '終了';

  @override
  String get notificationGameStopped => 'Stellar Bladeを終了しました';

  @override
  String get errorStoppingGame => 'ゲームを終了できませんでした';

  @override
  String get mod801DialogTitle => 'Steamの設定が必要です';

  @override
  String get mod801DialogIntro =>
      'Random Splashモッドがインストールされました。ゲーム起動時に自動的に機能させるには、Steamを設定する必要があります。';

  @override
  String get mod801Step1 => '1. 以下のPC用の正確なパスを生成してコピーします。';

  @override
  String get mod801Step2 => '2. Steamライブラリを開きます。';

  @override
  String get mod801Step3 => '3. Stellar Bladeを右クリック -> プロパティを選択します。';

  @override
  String get mod801Step4 => '4. 「一般」タブの「起動オプション」にコードを貼り付けます。';

  @override
  String get mod801BtnGenerate => 'パスを生成';

  @override
  String get mod801BtnSteam => 'Steamを開く';

  @override
  String get mod801BtnCopy => 'コピー';

  @override
  String get mod801PathGenerated => 'パスが正常に生成されました。';

  @override
  String get mod801PathCopied => 'コマンドをクリップボードにコピーしました！';

  @override
  String get statusVerifyingMods => 'モッドの整合性を確認しています...';

  @override
  String errorSelecting7Zip(String error) {
    return '7-Zipの選択エラー: $error';
  }

  @override
  String get errorInvalidFolderRetry => '選択したフォルダが正しくないようです。もう一度お試しください。';

  @override
  String errorSelectingFolderDynamic(String error) {
    return 'フォルダの選択エラー: $error';
  }

  @override
  String get statusNoNewModsInstalled => 'インストールによる新しいモッドはありません。';

  @override
  String get errorDisableModBeforeDelete => '削除する前にモッドを無効にしてください。';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return '有効化: $successCount (競合のためスキップ: $skippedCount)';
  }

  @override
  String get snackBarDeveloperModeEnabled => '開発者モードが有効になりました！';

  @override
  String errorRenamingMod(String error) {
    return 'モッドの名前変更エラー: $error';
  }

  @override
  String get notificationTitleError => 'エラー';

  @override
  String get errorGamePathNotFoundNotification => 'ゲームのパスが見つかりません。';

  @override
  String get notificationLaunchingGame => 'Stellar Bladeを起動しています...';

  @override
  String get errorLaunchingGame => 'ゲームの起動エラー';

  @override
  String get dialogTitleSelect7zip => '7z.exeファイルを選択してください';

  @override
  String get dialogTitleSelectGameFolder => 'StellarBladeのメインフォルダを選択してください';

  @override
  String get dialogTitleSelectCover => 'モッドのカバー画像を選択してください';

  @override
  String get errorGamePathNotFoundException => 'ゲームのパスが見つかりません。';

  @override
  String get errorGamePathNotDefined => 'ゲームのパスが定義されていません。';

  @override
  String get errorLogicModsPathNotDefined => 'Logicモッドのパスが定義されていません。';

  @override
  String get errorUe4ssModsPathNotDefined => 'UE4SSモッドのパスが定義されていません。';

  @override
  String get errorGenericModsPathNotDefined => '汎用モッド(~mods)のパスが定義されていません。';

  @override
  String get errorReplaceNoOldVersion => 'モッドを置換しようとしましたが、古いバージョンが特定されませんでした。';

  @override
  String errorDeleteOldModVersion(String modName) {
    return '古いバージョンのモッド ($modName) を削除できませんでした。';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return '再インストールのために既存のモッド ($modName) を削除できませんでした。';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return '数回試行しましたが、再インストールのために既存のモッド ($modName) を削除できませんでした。';
  }

  @override
  String get errorMoviesModNoValidFiles => 'ムービーモッドに有効な動画ファイルが含まれていません。';

  @override
  String get errorInstallPathUndetermined => 'インストールパスを特定できませんでした。';

  @override
  String get errorMoviesPathsNotDefined => 'ムービーのパスが定義されていません。';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return '$modName の nexus_info.json が見つかりません。';
  }

  @override
  String get errorMenuVideoLimitReached => 'メニュー動画の制限である99個に達しました。';

  @override
  String get errorModRequires529 =>
      'このモッドを機能させるにはモッドID 529が必要です（WebMファイルのみが含まれています）。';

  @override
  String get errorSplashPathsNotDefined => 'スプラッシュのパスが定義されていません。';

  @override
  String get errorSplashNoValidImages => 'モッド内に有効な画像が見つかりませんでした。';

  @override
  String get errorCouldNotDeleteDirectory => 'ディレクトリを削除できませんでした。';

  @override
  String get errorGameExeNotFound =>
      'ゲームの実行ファイル (.exe) がメインフォルダまたはBinaries内に見つかりませんでした。';

  @override
  String get dialogTitleSplashOptions => 'スプラッシュオプション（画像）';

  @override
  String get dialogContentSplashOptions =>
      'インストールする画像を選択してください。フォルダ全体（一括）または個別の画像を選択できます。';

  @override
  String get snackBarSplashNoSelection => '少なくとも1つの画像を選択してください。';

  @override
  String get dialogContentSpecialModSingleSelection =>
      'インストールするオプションを1つ選択してください。';

  @override
  String get activeDownloads => 'アクティブなダウンロード';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'MOD',
      one: 'MOD',
    );
    return '$count 個の $_temp0 をダウンロード中';
  }

  @override
  String get downloadError => 'エラー';

  @override
  String get downloadCancelled => 'キャンセルされました';

  @override
  String get downloadPause => '一時停止';

  @override
  String get downloadResume => '再開';

  @override
  String get downloadCancel => 'キャンセル';

  @override
  String get errorNexusInfoNotFound => 'nexus_info.json が見つかりません。';

  @override
  String logFixingCorruptedJson(String displayName) {
    return '$displayName の破損した nexus_info.json を修正しています。';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return '$displayName のメタデータを更新できませんでした: $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return 'Mod 529が有効化されたため、ムービーMODを予防的に無効にしています: $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return 'Mod 801が有効化されたため、スプラッシュMODを予防的に無効にしています: $modName';
  }

  @override
  String logRestoringTildeComponent(String folderName) {
    return '~mods コンポーネントを復元しています: $folderName';
  }

  @override
  String logRestoringUe4ssComponent(String folderName) {
    return 'UE4SS コンポーネントを復元しています: $folderName';
  }

  @override
  String logErrorRestoringLogicMod(String error) {
    return 'LogicMod コンポーネントの復元中にエラーが発生しました: $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return '~mods コンポーネントをアーカイブしています: $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return 'UE4SS コンポーネントをアーカイブしています: $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return 'LogicMod コンポーネントのアーカイブ中にエラーが発生しました: $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return '$modName をスキップします: このMODのアクティブなバリアントがすでに存在します。';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return '$modName をスキップします: すでに使用されている衣装との競合があります。';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return '$modName のビデオバックアップをクリーンアップできませんでした: $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return '新しい Nexus ID $nexusId が検出されました。メタデータを取得しています...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return '$nexusId のメタデータを取得して適用しました。';
  }

  @override
  String logFallbackByteCopy(String error) {
    return '通常のコピーが失敗しました。バイトのブルートフォースを使用します: $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return '警告: 変更されたファイルを削除できませんでした: $error';
  }

  @override
  String get logMod801BatPatched => 'このシステム用にMod 801の.batスクリプトが正常にパッチされました。';

  @override
  String logMod801BatPatchError(String error) {
    return 'Mod 801の.batファイルにパッチを適用しようとしてエラーが発生しました: $error';
  }

  @override
  String get errorHomeDirNotFound => 'ホームディレクトリの環境変数が見つかりませんでした。';

  @override
  String get downloadFetchingPlaceholder => '取得中...';

  @override
  String get downloadErrorLink => 'ダウンロードリンクを取得できませんでした';

  @override
  String get downloadErrorGeneral => 'ダウンロードに失敗しました';

  @override
  String get downloadPausedStatus => '一時停止中';

  @override
  String get settingsFixGameStartup => 'ゲームが起動しない問題を修復';

  @override
  String get settingsFixGameStartupDesc =>
      'ゲームが起動時に閉じる、またはクラッシュする場合に使用します。UE4SSとCNSを一時的にアンインストールし、ゲームを一度起動してから再インストールします。';

  @override
  String get repairConfirmTitle => 'ゲームの起動を修復しますか？';

  @override
  String get repairConfirmMessage =>
      'UE4SSとCNSをアンインストールし（ファイルは安全に保管されます）、ゲームを自動で起動・終了した後、すべてを再インストールしてゲームを再度起動します。処理中はアプリを閉じないでください。';

  @override
  String get repairConfirmAction => '修復を開始';

  @override
  String get launchRetryTitle => 'ゲームが起動しませんでした';

  @override
  String get launchRetryMessage =>
      '2回試行しましたが、Stellar Bladeが起動しませんでした。多くの場合、UE4SSまたはCNSが原因です。「ゲームが起動しない問題を修復」を実行すると、これらを一時的にアンインストールし、ゲームを一度起動してから再インストールします。今すぐ実行しますか？';

  @override
  String get launchRetryAction => '今すぐ修復';

  @override
  String get repairOverlayTitle => 'ゲームの起動を修復中';

  @override
  String get repairOverlayWarning => '処理中はアプリやゲームを手動で閉じないでください。';

  @override
  String get repairStepCloseGame => '起動中のゲームを終了';

  @override
  String get repairStepStashCns => 'CNSをアンインストール（ファイルを保管）';

  @override
  String get repairStepStashUe4ss => 'UE4SSをアンインストール（ファイルを保管）';

  @override
  String get repairStepLaunchClean => 'UE4SSとCNSなしでゲームを起動';

  @override
  String get repairStepWaitInit => 'ゲームの読み込みを待機';

  @override
  String get repairStepCloseAuto => 'ゲームを自動的に終了';

  @override
  String get repairStepRestoreUe4ss => 'UE4SSを再インストール';

  @override
  String get repairStepRestoreCns => 'CNSを再インストール';

  @override
  String get repairStepLaunchFinal => 'ゲームを起動';

  @override
  String get repairStatusSkipped => 'スキップ';

  @override
  String get repairResultSuccess => '修復が完了しました。ゲームを起動しました。';

  @override
  String get repairResultErrorRestored => '修復に失敗しましたが、UE4SSとCNSは元の状態に戻されました。';

  @override
  String get repairResultErrorRestoreFailed =>
      '修復に失敗し、ファイルをまだ復元できませんでした。次回アプリ起動時に自動的に復元されます。';

  @override
  String get repairErrorGameNotStarted => 'ゲームが時間内に起動しませんでした。';

  @override
  String get repairButtonClose => '閉じる';

  @override
  String get repairRecoveredNotice => '中断された修復を検出しました。UE4SSとCNSのファイルを復元しました。';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return '新しいエディションをインストールしました: $name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return 'このModには現在 $count 個のエディションがインストールされています。';
  }

  @override
  String get previewTagNewEdition => '新エディション';

  @override
  String get previewTagUpdate => 'アップデート';

  @override
  String editionsInstalledTooltip(Object count) {
    return 'このModのエディションが $count 個インストール済み';
  }

  @override
  String editionLabelValue(Object edition) {
    return 'エディション: $edition';
  }

  @override
  String get otherEditionsTitle => 'インストール済みの他のエディション';

  @override
  String get detailsStatusEnabled => '有効';

  @override
  String get detailsStatusDisabled => '無効';

  @override
  String get detailsInformation => '情報';

  @override
  String get detailsRowAuthor => '作者';

  @override
  String get detailsRowType => '種類';

  @override
  String get detailsRowInstalled => 'インストール日';

  @override
  String get detailsRowModified => '最終更新';

  @override
  String get detailsRowNexusId => 'Nexus ID';

  @override
  String get detailsRowFolder => 'フォルダー';

  @override
  String get detailsCopyPath => 'パスをコピー';

  @override
  String get detailsCopied => 'クリップボードにコピーしました';

  @override
  String get detailsEndorse => 'Endorse';

  @override
  String get detailsEndorsed => 'Endorsed';

  @override
  String endorseWaitLabel(Object minutes) {
    return '$minutes分待つ';
  }

  @override
  String get endorseSuccessTitle => 'MODをEndorseしました';

  @override
  String get endorseRemovedTitle => 'Endorseを解除しました';

  @override
  String get endorseFailedTitle => 'Endorseを更新できませんでした';

  @override
  String get endorseErrNotNexus =>
      'このMODはNexus Modsのページにリンクされていないため、Endorseできません。';

  @override
  String get endorseErrNoApiKey =>
      'MODをEndorseするには、設定でNexus ModsのAPIキーを追加してください。';

  @override
  String endorseErrWait(Object minutes) {
    return 'Nexusでは、MODをダウンロードしてから15分待たないとEndorseできません。$minutes分後にもう一度お試しください。';
  }

  @override
  String get endorseErrNotDownloaded =>
      'Nexusでは、ご自身のアカウントでダウンロードしたMODのみEndorseできます。';

  @override
  String get endorseErrOwnMod => 'ご自身のMODはEndorseできません。';

  @override
  String get endorseErrRateLimit => 'Nexusのリクエスト上限に達しました。しばらくしてからもう一度お試しください。';

  @override
  String get endorseErrInvalidKey => 'NexusがAPIキーを拒否しました。設定で確認してください。';

  @override
  String get endorseErrNetwork => 'Nexus Modsに接続できませんでした。接続を確認してもう一度お試しください。';

  @override
  String get endorseErrUnknown => 'Nexusがリクエストを処理できませんでした。しばらくしてからもう一度お試しください。';

  @override
  String get endorseRemoveConfirmTitle => 'Endorseを解除しますか？';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return '$name はNexus ModsでEndorseされなくなります。';
  }

  @override
  String get endorseRemoveConfirmAction => '解除';

  @override
  String get detailsUpdateAction => '更新';

  @override
  String get detailsShowMore => 'もっと見る';

  @override
  String get detailsShowLess => '閉じる';

  @override
  String get detailsAddNote => 'メモを追加';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '衣装 $count 個',
      one: '衣装 1 個',
      zero: '衣装なし',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return '$count 個選択中';
  }

  @override
  String get outfitsChoose => '衣装を選択';

  @override
  String get outfitsDone => '完了';

  @override
  String get outfitsFilterAll => 'すべて';

  @override
  String get outfitsFilterSelected => '選択済み';

  @override
  String get outfitsClearAll => 'すべてクリア';

  @override
  String get outfitsRemove => '削除';

  @override
  String get outfitsActionSelect => '選択';

  @override
  String get outfitsActionDeselect => '選択解除';

  @override
  String outfitsNoResults(String query) {
    return '「$query」に一致する結果はありません';
  }

  @override
  String get outfitsSelectedEmpty => 'まだ衣装が選択されていません。';

  @override
  String get outfitsNoPreview => 'プレビューはありません';

  @override
  String get replacementOffConfirmTitle => '置き換えMODをオフにしますか？';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '選択した $count 個の衣装がこのMODから削除されます。',
      one: '選択した衣装がこのMODから削除されます。',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => 'オフにする';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'MOD を $count 個オフにしました：他の MOD ですでに使用されている衣装を置き換えるためです',
      one: 'MOD を 1 個オフにしました：他の MOD ですでに使用されている衣装を置き換えるためです',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  次と同じ Container ID：$owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved => '  元のファイルを .cnsbak として保持しました（復元可能）。';

  @override
  String patcherLeftUntouched(String reason) {
    return '  変更せず保持（パッチは安全ではありません）：$reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ $count 個のMODが Container ID を共有していますが、安全に修正できませんでした（変更せず保持。CNSに表示されない場合があります）：';
  }

  @override
  String get revertPatchesTitle => '競合パッチを元に戻す';

  @override
  String get revertPatchesDesc => '競合パッチャーによって変更された元のMODファイルを復元します。';

  @override
  String get revertPatchesConfirmTitle => '競合パッチを元に戻しますか？';

  @override
  String get revertPatchesConfirmMessage =>
      '競合パッチャーが保存した元のファイル（.cnsbak）を復元します。先にゲームを終了してください。競合しているMODが再びCNSに表示されなくなる場合があります。';

  @override
  String get revertPatchesAction => '元に戻す';

  @override
  String revertPatchesDone(int count) {
    return '$count 個のファイルを復元しました。';
  }

  @override
  String get revertPatchesNothing => '元に戻すパッチ済みファイルはありません。';

  @override
  String get settingsGroupPaths => 'パス';

  @override
  String get settingsGroupTools => 'ツール';

  @override
  String get settingsAutoOutfit => '衣装を自動で割り当てる';

  @override
  String get settingsAutoOutfitDesc =>
      '置き換えMODのインストール時に、ファイルを読み取ってどの衣装を置き換えるかを自動検出します。オフにすると衣装は手動で割り当てます。';

  @override
  String get variantChoiceTitle => '同じ置き換えの複数のバリアント';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return 'MOD「$mod」には $outfits を置き換える複数のバリアントが含まれています。同時に有効にできるのは1つだけです。どれをインストールしますか？';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return 'MOD「$mod」には同じファイルを置き換える複数のバリアントが含まれています。同時に有効にできるのは1つだけです。どれをインストールしますか？';
  }

  @override
  String get variantChoiceInstallAll => 'すべてインストール（別々のMODとして）';

  @override
  String get installOutfitConflictTitle => '衣装が使用中';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return 'MOD「$newMod」は衣装 $outfits を置き換えますが、この衣装はすでに有効なMOD「$oldMod」に割り当てられています。同時に有効にできるのは1つだけです。どちらを有効のままにしますか？';
  }

  @override
  String get installOutfitKeepCurrent => '現在のものを維持';

  @override
  String get installOutfitUseNew => '新しいMODを有効化';

  @override
  String installOutfitNowActive(String active) {
    return '現在有効：$active';
  }

  @override
  String get fileLockErrorTitle => 'MODを移動できませんでした';

  @override
  String get fileLockErrorMessage =>
      '別のアプリがゲームのファイルを使用している可能性があります（FModel、ゲーム本体、ウイルス対策ソフト、エクスプローラーなど）。そのアプリを閉じてからもう一度お試しください。';

  @override
  String get nexusProfileTooltip => 'Nexus Modsプロフィール';

  @override
  String get nexusUserFallback => 'ユーザー';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => 'メンバー';

  @override
  String get nexusPlanSupporter => 'サポーター';

  @override
  String get nexusApiRequestsRemaining => '残りのAPIリクエスト';

  @override
  String get nexusApiDaily => '1日あたり';

  @override
  String get nexusApiHourly => '1時間あたり';

  @override
  String get downloadMemberAccountLimit =>
      'メンバーアカウントはNexus Modsにより1.5 MB/sに制限されています';

  @override
  String get downloadSupporterAccountLimit =>
      'サポーターアカウントはNexus Modsにより3 MB/sに制限されています';

  @override
  String get downloadRetryTooltip => '再試行';

  @override
  String get downloadRefreshingLink => 'リンクを更新中...';

  @override
  String get downloadNoInternet => 'インターネットに接続されていません。ネットワークを確認してください。';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'Nexusのリンクの有効期限が切れました ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'HTTPエラー: $code';
  }

  @override
  String get downloadErrorTimeout => 'タイムアウト: ネットワークデータを受信できません';

  @override
  String get splashRootFolder => 'ルート（メイン）';

  @override
  String get repairErrorGameNotClosed => 'ゲームのプロセスを終了できませんでした。';

  @override
  String get errorManifestNotFound => 'インストールマニフェストが見つかりません。アンインストールできません。';

  @override
  String get downloadResuming => '再開中...';

  @override
  String get apiKeyPromptTitle => 'Nexus Mods の APIキーを設定しましょう';

  @override
  String get apiKeyPromptMessage =>
      'APIキーが検出されませんでした。設定は任意ですが、利便性のためにおすすめします。MODの更新確認、ワンクリックでのダウンロード (nxm://)、Nexus Mods からのカバー画像や情報の取得が利用できます。';

  @override
  String get apiKeyPromptConfigure => 'APIキーを設定';

  @override
  String get apiKeyPromptSkip => 'スキップ';

  @override
  String get apiKeyPromptDontShowAgain => '今後このメッセージを表示しない';

  @override
  String get adjustCoverTooltip => 'カバーを調整';

  @override
  String get noCoverToAdjust => 'このModには調整できるカバーがありません';

  @override
  String errorAdjustingCoverText(Object error) {
    return 'カバーの調整中にエラーが発生しました: $error';
  }
}
