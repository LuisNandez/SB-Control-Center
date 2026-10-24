// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'CNS Control Center';

  @override
  String appTitleWithVersion(Object version) {
    return 'Custom Nanosuit System $version';
  }

  @override
  String get settings => '설정';

  @override
  String get settingsGeneral => '일반';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageDesc => '애플리케이션 언어 선택';

  @override
  String get settingsAbout => '정보';

  @override
  String get settingsAboutDesc => '애플리케이션에 대한 정보';

  @override
  String get settingsRefreshMetadata => '메타데이터 업데이트';

  @override
  String get settingsRefreshMetadataDesc =>
      'Nexus Mods에서 모드를 다시 확인하고 부족한 정보와 이미지를 채웁니다';

  @override
  String get metadataRefreshDone => '메타데이터를 업데이트했습니다';

  @override
  String get metadataRefreshNoApiKey =>
      '메타데이터를 업데이트하려면 설정에서 Nexus Mods API 키를 입력하세요.';

  @override
  String get settingsPathsAndTools => '경로 및 도구';

  @override
  String get settingsGameFolder => '게임 폴더';

  @override
  String get settingsGameFolderDesc => 'Stellar Blade 설치의 루트 폴더입니다.';

  @override
  String get settings7zipPath => '7-Zip 경로';

  @override
  String get settings7zipPathDesc => '모드 추출을 위한 7z.exe 파일의 위치입니다.';

  @override
  String get settings7zipPathAuto => '자동 검색';

  @override
  String get settingsRepairMods => '레거시 모드 복구';

  @override
  String get settingsRepairModsDesc =>
      '로컬 데이터베이스를 사용하여 오래된 모드를 스캔하고 정보 파일을 생성합니다. API 키가 필요합니다.';

  @override
  String get settingsConnectivity => '연결 및 업데이트';

  @override
  String get settingsApiKey => 'Nexus Mods API 키';

  @override
  String get settingsApiKeyDesc => '모드 업데이트 확인에 필요합니다.';

  @override
  String get settingsApiKeySet => '설정됨';

  @override
  String get settingsApiKeyNotSet => '설정되지 않음';

  @override
  String get settingsSkippedVersions => '건너뛴 버전 관리';

  @override
  String get settingsSkippedVersionsDesc => '건너뛰기로 선택한 모드 버전을 관리합니다.';

  @override
  String settingsSkippedVersionsCount(Object count) {
    return '$count개 버전 건너뜀';
  }

  @override
  String get dialogTitleSkippedVersions => '건너뛴 모드 버전';

  @override
  String get dialogNoSkippedVersions => '건너뛴 모드 버전이 없습니다.';

  @override
  String get dialogSkippedVersions => '건너뛴 버전';

  @override
  String get dialogTitleRepairMods => '레거시 모드 복구를 실행하시겠습니까?';

  @override
  String get dialogContentRepairMods =>
      '경고: 이 기능은 개발 중이며 완벽하지 않을 수 있습니다.\n\n\'nexus_info.json\' 파일이 없는 모드를 스캔하고 로컬 데이터베이스에서 찾으면 해당 파일을 생성합니다. 또한 찾은 버전을 포함하도록 모드 폴더의 이름을 바꾸려고 시도합니다 (예: \'My Mod\' -> \'My Mod v1.2\').\n\n버전 우선순위:\n1. 폴더 이름에서\n2. 모드 설명 필드에서\n3. Nexus Mods의 최신 버전에서 (API 필요)\n\n계속하시겠습니까?';

  @override
  String get dialogActionRunRepair => '복구 실행';

  @override
  String get snackBarGamePathInvalid => '선택한 폴더가 유효한 게임 폴더가 아닌 것 같습니다.';

  @override
  String get snackBar7zipPathInvalid => '선택한 파일의 이름은 7z.exe여야 합니다.';

  @override
  String get snackBarRepairStarted => '레거시 모드 복구 프로세스가 시작되었습니다...';

  @override
  String snackBarRepairComplete(Object count) {
    return '복구 완료. $count개의 모드가 업데이트되었습니다.';
  }

  @override
  String get snackBarRepairNoMods => '복구가 필요한 레거시 모드를 찾을 수 없습니다.';

  @override
  String get errorApiRequiredForRepair =>
      '로컬 버전이 없는 모드의 최신 버전을 찾으려면 API 키가 필요합니다.';

  @override
  String get installNewMod => '모드 설치';

  @override
  String get selectFiles => '파일 선택';

  @override
  String get selectFolder => '폴더 선택';

  @override
  String get installSelectedMod => '선택한 모드 설치';

  @override
  String get filesToInstall => '설치할 파일:';

  @override
  String get cancelSelection => '선택 취소';

  @override
  String get searchMods => '모드 검색...';

  @override
  String get enabledMods => '활성화된 모드';

  @override
  String get disabledMods => '비활성화된 모드';

  @override
  String get refreshList => '목록 새로고침';

  @override
  String get noEnabledMods => '활성화된 모드가 없습니다.';

  @override
  String get noDisabledMods => '비활성화된 모드가 없습니다.';

  @override
  String get showInFolder => '폴더에 표시';

  @override
  String get disableMod => '모드 비활성화';

  @override
  String get enableMod => '모드 활성화';

  @override
  String get deletePermanently => '영구 삭제';

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get statusSearchingGame => 'Stellar Blade 설치를 검색하는 중...';

  @override
  String get statusGamePathFound => '게임 경로를 찾았습니다!';

  @override
  String get statusGamePathNotFound => '게임 경로를 자동으로 찾을 수 없습니다.';

  @override
  String statusErrorFindingGame(Object error) {
    return '게임 검색 중 오류 발생: $error';
  }

  @override
  String statusModsFound(Object disabledCount, Object enabledCount) {
    return '$enabledCount개의 모드 활성화됨, $disabledCount개 비활성화됨.';
  }

  @override
  String statusErrorReadingMods(Object error) {
    return '설치된 모드 읽기 오류: $error';
  }

  @override
  String statusFilesSelected(Object count) {
    return '$count개의 파일이 선택되었습니다. 설치 준비 완료.';
  }

  @override
  String statusFolderSelected(Object folderName) {
    return '\"$folderName\" 폴더가 선택되었습니다. 설치 준비 완료.';
  }

  @override
  String statusArchiveLoaded(Object count, Object fileName) {
    return '\"$fileName\" 파일이 로드되었습니다. $count개의 파일 설치 준비 완료.';
  }

  @override
  String get statusSelectionCancelled => '선택이 취소되었습니다. 설치할 새 모드를 선택하세요.';

  @override
  String get statusUpdateComplete => '업데이트 완료.';

  @override
  String get statusInstallationComplete => '설치 완료.';

  @override
  String statusError(Object error) {
    return '오류: $error';
  }

  @override
  String get dialogTitle7zip => '7-Zip 필요';

  @override
  String get dialogContent7zip =>
      '이 파일의 압축을 풀려면 애플리케이션에 7-Zip이 필요합니다.\n\n공식 페이지에서 설치한 다음 \"확인\"을 누르세요.';

  @override
  String get dialogContent7zipNotFound =>
      '7-Zip이 아직 감지되지 않았습니다. 기본 경로에 설치되었는지 확인하고 다시 시도하세요.';

  @override
  String get dialogTitleMultipleJsons => '여러 개의 .json 파일 감지됨';

  @override
  String dialogContentMultipleJsons(Object count) {
    return '$count개의 .json 파일이 감지되었습니다. 여러 구성 요소가 있는 모드일 수 있습니다.\n\n모두 단일 모드 폴더에 함께 설치하시겠습니까?';
  }

  @override
  String get dialogTitleModExists => '모드가 이미 존재합니다';

  @override
  String dialogContentModExists(Object modName) {
    return '\"$modName\"이라는 이름의 모드가 이미 설치되어 있습니다.\n\n업데이트하시겠습니까? 새 파일을 설치하기 전에 이전 파일이 삭제됩니다.';
  }

  @override
  String dialogContentModUpdate(Object newModName, Object oldModName) {
    return '이전 버전 \'$oldModName\'이(가) 발견되었습니다.\n\n제거하고 \'$newModName\'(으)로 업데이트하시겠습니까?';
  }

  @override
  String get dialogTitleDeleteMod => '영구적으로 삭제하시겠습니까?';

  @override
  String dialogContentDeleteMod(Object modName) {
    return '\"$modName\" 모드를 영구적으로 삭제하려고 합니다. 이 작업은 취소할 수 없습니다.\n\n확실합니까?';
  }

  @override
  String get dialogActionCancel => '취소';

  @override
  String get dialogActionGoToDownload => '다운로드 페이지로 이동';

  @override
  String get dialogActionConfirmInstallation => '설치 확인';

  @override
  String get dialogActionUpdateSystem => '시스템 업데이트';

  @override
  String get dialogActionInstallAnyway => '그래도 설치';

  @override
  String get dialogActionDelete => '삭제';

  @override
  String get dialogActionClose => '닫기';

  @override
  String snackBarBatchInstallComplete(Object failedCount, Object successCount) {
    return '일괄 설치 완료. 성공: $successCount, 실패: $failedCount.';
  }

  @override
  String snackBarModInstalled(Object modName) {
    return '\"$modName\" 모드가 성공적으로 설치되었습니다.';
  }

  @override
  String snackBarModEnabled(Object modName) {
    return '\"$modName\" 모드가 활성화되었습니다.';
  }

  @override
  String snackBarModDisabled(Object modName) {
    return '\"$modName\" 모드가 비활성화되었습니다.';
  }

  @override
  String snackBarModDeleted(Object modName) {
    return '\"$modName\" 모드가 영구적으로 삭제되었습니다.';
  }

  @override
  String get snackBarCNSUpdated => '커스텀 나노슈트 시스템이 성공적으로 업데이트되었습니다.';

  @override
  String get snackBarApiKeySaved => 'API 키가 성공적으로 저장되었습니다.';

  @override
  String get snackBarGamePathSaved => '게임 경로가 성공적으로 저장되었습니다.';

  @override
  String get snackBar7zipPathSaved => '7-Zip 경로가 성공적으로 저장되었습니다.';

  @override
  String get snackBarSkippedVersionRemoved => '건너뛴 버전이 제거되었습니다.';

  @override
  String get dropTargetOverlay => '여기에 모드 드롭';

  @override
  String get pathSelectionTitle => 'Stellar Blade 경로를 찾을 수 없음';

  @override
  String get pathSelectionButtonManual => '수동으로 게임 폴더 선택';

  @override
  String get pathSelectionButtonRetry => '다시 시도';

  @override
  String errorFolderSelection(Object error) {
    return '폴더 선택 오류: $error';
  }

  @override
  String errorFileSelection(Object error) {
    return '파일 선택 오류: $error';
  }

  @override
  String errorDecompressing(Object error) {
    return '파일 압축 해제 오류: $error';
  }

  @override
  String errorProcessingArchive(Object error) {
    return '파일 처리 오류: $error';
  }

  @override
  String errorUnsupportedFormat(Object extension) {
    return '지원되지 않는 파일 형식: $extension';
  }

  @override
  String get error7zipRequired => '작업이 취소되었습니다: 7-Zip이 필요합니다.';

  @override
  String get errorGamePathUndefined => '게임 경로가 정의되지 않았습니다.';

  @override
  String get errorDestinationNotFound => '게임의 대상 폴더가 존재하지 않습니다.';

  @override
  String errorUpdateSystem(Object error) {
    return '시스템 업데이트 오류: $error';
  }

  @override
  String get errorInstallNoSelection => '설치할 항목을 선택하지 않았습니다.';

  @override
  String get errorInstallModExists => '설치가 취소되었습니다: 모드가 이미 존재합니다.';

  @override
  String get errorNoJsonFound => '각 모드에는 최소한 하나의 .json 파일이 포함되어야 합니다.';

  @override
  String errorInvalidJsonFormat(Object fileName) {
    return '$fileName 파일의 JSON 형식이 잘못되었습니다.';
  }

  @override
  String errorNoDisplayName(Object fileName) {
    return '$fileName 파일은 커스텀 나노슈트 시스템 모드가 아닌 것 같습니다(\"DisplayName\" 누락).';
  }

  @override
  String get errorNoValidDisplayName =>
      '.json 파일에서 유효한 \"DisplayName\"을 찾을 수 없습니다.';

  @override
  String errorEnableMod(Object error) {
    return '모드 활성화 오류: $error';
  }

  @override
  String errorDisableMod(Object error) {
    return '모드 비활성화 오류: $error';
  }

  @override
  String errorDeleteMod(Object error) {
    return '모드 삭제 오류: $error';
  }

  @override
  String errorOpenFolder(Object path) {
    return '폴더를 열 수 없습니다: $path';
  }

  @override
  String get statusUpdateSystemCancelled => '시스템 업데이트가 취소되었습니다.';

  @override
  String get statusUpdatingCNS => '커스텀 나노슈트 시스템 업데이트 중...';

  @override
  String statusExtractingFile(Object fileName) {
    return '$fileName 추출 중...';
  }

  @override
  String get statusInstallationCancelledByUser => '사용자가 설치를 취소했습니다.';

  @override
  String get errorNoCompatibleFilesInFolder => '선택한 폴더에 호환되는 모드 파일이 없습니다.';

  @override
  String get errorNoCompatibleFilesInArchive => '압축 파일에 호환되는 모드 파일이 없습니다.';

  @override
  String get errorNoJsonInSelection => '선택 항목에 유효한 모드 .json 파일이 없습니다.';

  @override
  String get aboutTitle => 'SB Control Center 정보';

  @override
  String get aboutContent =>
      'SB Control Center는 Stellar Blade용 모드 관리자입니다. 모드를 한곳에서 설치, 정리, 업데이트할 수 있으며 의상 및 나노슈트 모드를 위한 Custom Nanosuit System(CNS)과 함께 작동합니다.\n\nNexus Mods와 연동하여 다운로드, 업데이트 확인, 사용 중인 모드에 Endorse를 할 수 있습니다.\n\n요구 사항: .rar 및 .7z 파일을 완전히 지원하려면 시스템에 7-Zip이 설치되어 있어야 합니다.';

  @override
  String get aboutEndorseCta =>
      '앱이 마음에 드시나요? Nexus Mods에서 Endorse해 주시면 큰 도움이 됩니다.';

  @override
  String get aboutEndorseThanks => '응원해 주셔서 감사합니다!';

  @override
  String get aboutLinkText => '내 제작자 프로필 방문';

  @override
  String get creatorProfileUrl =>
      'https://next.nexusmods.com/profile/LuisNandez?gameId=7804';

  @override
  String aboutVersion(Object version) {
    return '버전: $version';
  }

  @override
  String get openModsFolder => '모드 폴더 열기';

  @override
  String get openInNexusMods => 'Nexus Mods에서 열기';

  @override
  String get checkForUpdates => '업데이트 확인';

  @override
  String updateAvailable(Object version) {
    return '사용 가능한 업데이트: v$version';
  }

  @override
  String get dialogTitleApiKey => 'Nexus Mods API 키';

  @override
  String get dialogContentApiKey =>
      '모드 업데이트를 확인하려면 Nexus Mods의 개인 API 키가 필요합니다.';

  @override
  String get dialogContentApiKeyInstructions =>
      '1. 아래 버튼을 눌러 Nexus Mods를 열고 로그인합니다.\n2. 페이지 맨 아래의 \'Personal API Key\' 섹션으로 스크롤합니다.\n3. 아직 없다면 요청한 다음 키를 복사합니다.\n4. 여기에 붙여넣습니다.';

  @override
  String get apiKeyOpenNexusPage => 'API 키 페이지 열기';

  @override
  String get apiKey => 'API 키';

  @override
  String get apiKeyHintText => '여기에 API 키 붙여넣기';

  @override
  String get dialogActionSave => '저장';

  @override
  String get apiKeyRemoved => 'API 키가 제거되었습니다.';

  @override
  String get invalidApiKeyError => '잘못된 API 키입니다.';

  @override
  String get validatingApiKey => '확인 중...';

  @override
  String get errorApiKeyMissing =>
      'Nexus Mods API 키가 설정되지 않았습니다. 설정 › 연결 및 업데이트 › Nexus Mods API 키에서 추가하세요.';

  @override
  String get statusCheckingUpdates => '모드 업데이트 확인 중...';

  @override
  String statusUpdatesFound(Object count) {
    return '$count개의 업데이트를 찾았습니다!';
  }

  @override
  String get statusNoUpdates => '모든 모드가 최신 버전입니다.';

  @override
  String get selectModArchive => '모드 아카이브 선택';

  @override
  String get viewImageGallery => '이미지 갤러리 보기';

  @override
  String get imageGallery => '이미지 갤러리';

  @override
  String get noImagesFound =>
      '이 모드의 이미지를 찾을 수 없거나 API 키가 입력되지 않았습니다. API 키를 입력한 후 업데이트를 확인하십시오.';

  @override
  String errorFetchingImages(Object error) {
    return '이미지 가져오기 오류: $error';
  }

  @override
  String get imageMod => '모드 이미지';

  @override
  String get modEnabledBadge => '활성화됨';

  @override
  String get modDisabledBadge => '비활성화됨';

  @override
  String get modCategoryOther => '지정되지 않음';

  @override
  String get dialogContentUpdateOptions => '무엇을 하시겠습니까?';

  @override
  String get dialogActionIgnoreVersion => '무시';

  @override
  String get dialogActionSkipVersion => '버전 건너뛰기';

  @override
  String get dialogActionGoToDownloadPage => '다운로드로 이동';

  @override
  String get installedMods => '설치된 모드';

  @override
  String get filterBy => '필터:';

  @override
  String get sortBy => '정렬 기준:';

  @override
  String get filterAll => '모두';

  @override
  String get filterEnabled => '활성화됨';

  @override
  String get filterDisabled => '비활성화됨';

  @override
  String get filterRepaired => '복구됨';

  @override
  String get sortByName => '이름';

  @override
  String get sortByDate => '날짜';

  @override
  String get noModsFound => '모드를 찾을 수 없습니다.';

  @override
  String get viewTypeGrid => '그리드 보기';

  @override
  String get viewTypeList => '목록 보기';

  @override
  String statusExtractingMultipleFiles(
    Object count,
    Object fileName,
    Object total,
  ) {
    return '$total개 중 $count개 추출 중: $fileName';
  }

  @override
  String get previewInstallTitle => '설치될 모드:';

  @override
  String get dialogTitleUE4SS => 'UE4SS 설치 감지됨';

  @override
  String get dialogContentUE4SS =>
      'UE4SS 도구가 감지되었습니다. \'StellarBlade\\SB\\Binaries\\Win64\'에 설치하시겠습니까?\n\n많은 모드가 작동하려면 이것이 필요합니다.';

  @override
  String get dialogActionInstallTool => '도구 설치';

  @override
  String get statusUE4SSInstallCancelled => 'UE4SS 설치가 취소되었습니다.';

  @override
  String get statusInstallingUE4SS => 'UE4SS 설치 중...';

  @override
  String get snackBarUE4SSInstalled => 'UE4SS가 성공적으로 설치되었습니다.';

  @override
  String error7zipDecompression(Object error) {
    return '압축 해제 중 7-Zip 오류: $error';
  }

  @override
  String get statusUE4SSInstallComplete => 'UE4SS 설치 완료.';

  @override
  String get dialogTitleAlternativeVersion => '대체 버전 감지됨';

  @override
  String dialogContentAlternativeVersion(
    String oldModName,
    String baseModName,
    String newModName,
  ) {
    return '이 모드의 대체 버전이 이미 설치되어 있습니다: \'$oldModName\'.\n\n\'$newModName\'이라는 다른 대체 버전을 설치하려고 합니다.';
  }

  @override
  String get dialogActionReplace => '교체';

  @override
  String get dialogActionInstallAsNew => '새로 설치';

  @override
  String get dialogTitleUpdate => '업데이트 가능';

  @override
  String dialogContentUpdate(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return '\'$modName\' 모드를 업데이트하려고 합니다.\n\n설치된 버전: $oldVersion\n새 버전: $newVersion';
  }

  @override
  String get dialogTitleDowngrade => '이전 버전 감지됨';

  @override
  String dialogContentDowngrade(
    String modName,
    String oldVersion,
    String newVersion,
  ) {
    return '경고: \'$modName\' 모드의 이전 버전을 설치하려고 합니다.\n\n설치된 버전: $oldVersion\n설치할 버전: $newVersion';
  }

  @override
  String get dialogTitleReinstall => '모드 재설치';

  @override
  String dialogContentReinstall(Object modName, Object version) {
    return '\'$modName\' 모드의 \'$version\' 버전을 다시 설치하려고 합니다.';
  }

  @override
  String get dialogActionReinstall => '재설치';

  @override
  String get editModNameTooltip => '모드 이름 편집';

  @override
  String get setCoverTooltip => '사용자 지정 표지 이미지 설정';

  @override
  String get setCoverText => '표지 설정';

  @override
  String get restoreOriginalCoverText => '원래 표지 복원';

  @override
  String errorSavingCoverText(Object error) {
    return '표지 이미지 저장 오류: $error';
  }

  @override
  String errorRestoringCoverText(Object error) {
    return '원래 표지 이미지 복원 오류: $error';
  }

  @override
  String get editVersionText => '버전 편집';

  @override
  String get customVersionText => '사용자 지정 버전';

  @override
  String get editTagText => '태그 편집';

  @override
  String get customTagText => '사용자 지정 태그';

  @override
  String get dialogTitleEditModName => '모드 이름 편집';

  @override
  String get dialogActionResetToDefault => '기본값으로 재설정';

  @override
  String get dialogLabelNewName => '새 이름';

  @override
  String errorModNameExists(Object modName) {
    return '\"$modName\"이라는 이름의 모드가 이미 존재합니다.';
  }

  @override
  String get dialogTitleRepairedModWarning => '복구된 모드 경고';

  @override
  String get dialogContentRepairedModWarning =>
      '이 모드에 올바른 버전 정보가 없을 수 있습니다. 호환성을 보장하기 위해 최신 버전을 다시 설치하는 것이 좋습니다.';

  @override
  String get repairedModTooltip => '복구된 모드에 대한 정보';

  @override
  String get disableAllModsTooltip => '모든 모드 비활성화';

  @override
  String get deleteAllModsTooltip => '비활성화된 모든 모드 삭제';

  @override
  String get dialogTitleDisableAll => '모든 모드를 비활성화하시겠습니까?';

  @override
  String dialogContentDisableAll(int count) {
    return '활성화된 $count개의 모든 모드를 비활성화하시겠습니까? 백업 폴더로 이동됩니다.';
  }

  @override
  String get dialogTitleDeleteAll => '비활성화된 모드를 삭제하시겠습니까?';

  @override
  String dialogContentDeleteAll(int count) {
    return '비활성화된 $count개의 모든 모드를 영구적으로 삭제하려고 합니다. 이 작업은 취소할 수 없습니다.\n\n확실합니까?';
  }

  @override
  String snackBarAllModsDisabled(int count) {
    return '활성화된 $count개의 모든 모드가 비활성화되었습니다.';
  }

  @override
  String snackBarAllModsDeleted(int count) {
    return '비활성화된 $count개의 모든 모드가 영구적으로 삭제되었습니다.';
  }

  @override
  String get snackBarNoModsToDisable => '비활성화할 활성화된 모드가 없습니다.';

  @override
  String get snackBarNoModsToDelete => '삭제할 비활성화된 모드가 없습니다.';

  @override
  String get enableAllModsTooltip => '모든 모드 활성화';

  @override
  String get dialogTitleEnableAll => '모든 모드를 활성화하시겠습니까?';

  @override
  String dialogContentEnableAll(int count) {
    return '비활성화된 $count개의 모든 모드를 활성화하시겠습니까? 주 모드 폴더로 이동됩니다.';
  }

  @override
  String snackBarAllModsEnabled(int count) {
    return '비활성화된 $count개의 모든 모드가 활성화되었습니다.';
  }

  @override
  String get snackBarNoModsToEnable => '활성화할 비활성화된 모드가 없습니다.';

  @override
  String get editNotes => '메모 편집';

  @override
  String get notesHintText => '여기에 개인 메모 추가...';

  @override
  String get modAuthor => '제작자';

  @override
  String get modSummary => '요약';

  @override
  String get modDescription => '설명';

  @override
  String get noDescriptionAvailable => '설명 없음.';

  @override
  String get personalNotes => '개인 메모';

  @override
  String get noNotesAvailable => '아직 추가된 메모 없음.';

  @override
  String get modDetailsTitle => '모드 세부 정보';

  @override
  String get modVersion => '버전';

  @override
  String get modCategory => '카테고리';

  @override
  String get dialogTitleAddUrl => '모드 링크 추가';

  @override
  String get dialogLabelUrl => '모드 URL';

  @override
  String get errorInvalidUrl => '유효한 URL을 입력하십시오.';

  @override
  String get addLinkTooltip => '이 모드의 다운로드 링크 추가';

  @override
  String get addLinkButtonText => '링크 추가';

  @override
  String get openLinkButtonText => '링크 열기';

  @override
  String get editModTitle => '모드 세부 정보 편집';

  @override
  String get modNameLabel => '모드 이름';

  @override
  String get authorLabel => '제작자';

  @override
  String get summaryLabel => '설명 / 요약';

  @override
  String get notesLabel => '개인 메모';

  @override
  String get urlLabel => '다운로드 URL';

  @override
  String get changeCoverButton => '표지 이미지 변경';

  @override
  String get editButtonTooltip => '모드 편집';

  @override
  String get errorSavingNotes => '메모 저장 오류';

  @override
  String get errorSavingUrl => 'URL 저장 오류';

  @override
  String get errorSavingChanges => '변경 사항 저장 오류';

  @override
  String get errorTranslation => '설명을 번역할 수 없습니다';

  @override
  String get translateSummary => '요약 번역';

  @override
  String get translateDescription => '설명 번역';

  @override
  String get restoreOriginalDescription => '원본 설명 복원';

  @override
  String get dialogTitleUE4SSReinstall => 'UE4SS 재설치';

  @override
  String get dialogContentUE4SSReinstall =>
      'UE4SS가 이미 설치된 것 같습니다. 기존 설치를 덮어쓰시겠습니까? 파일이 손상되었다고 의심되는 경우 유용할 수 있습니다.';

  @override
  String get dialogTitleCNSReinstall => 'CNS 시스템 재설치';

  @override
  String get dialogContentCNSReinstall =>
      '주 CNS 시스템이 이미 설치된 것 같습니다. 다시 설치하시겠습니까? 기존 모드에는 영향을 미치지 않습니다.';

  @override
  String dialogTitleUninstall(Object componentName) {
    return '$componentName 제거';
  }

  @override
  String dialogContentUninstall(Object componentName) {
    return '$componentName을(를) 제거하시겠습니까? 이 작업은 핵심 구성 요소 파일을 제거하지만 설치된 모드에는 영향을 미치지 않습니다.';
  }

  @override
  String get dialogActionUninstall => '예, 제거합니다';

  @override
  String statusUninstalling(Object componentName) {
    return '$componentName 제거 중...';
  }

  @override
  String snackBarUninstalled(Object componentName) {
    return '$componentName이(가) 성공적으로 제거되었습니다';
  }

  @override
  String errorUninstalling(Object componentName) {
    return '$componentName 제거 오류';
  }

  @override
  String get settingsCoreComponents => '핵심 구성 요소';

  @override
  String get installedStatus => '설치됨';

  @override
  String get notInstalledStatus => '감지되지 않음';

  @override
  String get uninstallButton => '제거';

  @override
  String get cnsCoreSystem => '커스텀 나노슈트 시스템';

  @override
  String get ue4ssInstallationDetected => '기존 UE4SS 설치가 감지되어 채택되었습니다';

  @override
  String get cnsInstallationDetected => '기존 주 CNS 설치가 감지되어 채택되었습니다';

  @override
  String get ue4ssRequiredTitle => 'UE4SS 필요';

  @override
  String get ue4ssRequiredContent =>
      '주 CNS 시스템을 설치하려면 먼저 UE4SS를 설치해야 합니다. 다음 링크에서 다운로드할 수 있습니다:';

  @override
  String get uninstallDependencyTitle => '종속성 감지됨';

  @override
  String get uninstallDependencyContent =>
      'CNS가 UE4SS에 의존하므로 UE4SS를 제거하기 전에 주 CNS 시스템을 제거해야 합니다.';

  @override
  String get dialogActionUnderstood => '이해했습니다';

  @override
  String get appTitleNoCns => '커스텀 나노슈트 시스템 (설치되지 않음)';

  @override
  String get dialogTitleCNSUpdate => '주 CNS 시스템 업데이트';

  @override
  String dialogContentCNSUpdate(Object oldVersion, Object newVersion) {
    return '$oldVersion 버전에서 새 버전 $newVersion(으)로 CNS를 업데이트하려고 합니다. 계속하시겠습니까?';
  }

  @override
  String get dialogTitleCNSDowngrade => 'CNS 버전 다운그레이드';

  @override
  String dialogContentCNSDowngrade(Object oldVersion, Object newVersion) {
    return '경고! 현재 버전($oldVersion)보다 이전 버전의 CNS($newVersion)를 설치하려고 합니다. 문제가 발생할 수 있습니다. 확실합니까?';
  }

  @override
  String dialogContentCNSReinstallVersion(Object version) {
    return '이미 CNS 버전 $version이(가) 설치되어 있습니다. 그래도 파일을 다시 설치하시겠습니까?';
  }

  @override
  String get dialogActionUpdate => '업데이트';

  @override
  String get dialogActionDowngrade => '다운그레이드';

  @override
  String get dialogTitleCNSInstall => '주 CNS 시스템 설치';

  @override
  String get dialogContentCNSInstall =>
      '기본 커스텀 나노슈트 시스템(CNS)을 설치하려고 합니다. CNS 모드가 작동하려면 이것이 필요합니다. 계속하시겠습니까?';

  @override
  String get dialogActionInstall => '설치';

  @override
  String get settingsDeveloperOptions => '개발자 옵션';

  @override
  String get devDeleteNexusInfoTitle => '모든 nexus_info.json 파일 삭제';

  @override
  String get devDeleteNexusInfoDesc =>
      '모든 모드에서 모든 관리자 메타데이터 파일을 제거합니다. 전체 복구를 강제하는 데 유용합니다.';

  @override
  String get devExtractIdsTitle => '식별자 추출';

  @override
  String get devExtractIdsDesc =>
      '각 모드의 displayName 및 nexusId를 포함하는 \'ID Mods.json\'이라는 이름의 파일을 바탕 화면에 만듭니다.';

  @override
  String get devConfirmDeleteTitle => '삭제 확인';

  @override
  String get devConfirmDeleteDesc =>
      '모든 nexus_info.json 파일을 영구적으로 삭제하시겠습니까? 그러면 모든 사용자 지정 이름, 표지 및 메타데이터가 제거됩니다. 이 작업은 취소할 수 없습니다.';

  @override
  String get devDeleteSuccessTitle => '삭제 완료';

  @override
  String devDeleteSuccessDesc(Object count) {
    return '$count개의 nexus_info.json 파일을 성공적으로 삭제했습니다.';
  }

  @override
  String get devConfirmExtractTitle => '추출 확인';

  @override
  String get devConfirmExtractDesc =>
      '모든 모드를 스캔하고 바탕 화면에 \'ID Mods.json\'을 만듭니다. 같은 이름의 기존 파일을 덮어씁니다. 계속하시겠습니까?';

  @override
  String get devExtractAction => '추출';

  @override
  String get devTestSelfUpdateTitle => '자동 설치 테스트';

  @override
  String get devTestSelfUpdateDesc =>
      '앱의 .zip 패키지를 선택하여 자동 업데이트와 동일한 방식으로 이 앱 위에 설치합니다.';

  @override
  String get devSelfUpdateUnsupported => '자동 업데이트는 Windows에서만 사용할 수 있습니다.';

  @override
  String get devSelfUpdatePickTitle => 'SB Control Center .zip 선택';

  @override
  String get devSelfUpdateFailed => '업데이트를 설치할 수 없습니다';

  @override
  String get devSelfUpdateDryRunTitle => '패키지가 유효합니다 (테스트 모드)';

  @override
  String devSelfUpdateDryRunDesc(int count) {
    return '파일 $count개를 찾았습니다. 릴리스 빌드가 아니므로 설치되지 않았습니다.';
  }

  @override
  String get devSelfUpdateConfirmTitle => '업데이트를 설치하시겠습니까?';

  @override
  String get devSelfUpdateConfirmDesc =>
      '앱이 종료되고, 파일을 패키지의 파일로 교체한 뒤 자동으로 다시 실행됩니다.';

  @override
  String get devSelfUpdateInstallAction => '설치 후 다시 시작';

  @override
  String get devSelfUpdateProgressTitle => 'SB Control Center 업데이트 중';

  @override
  String get devSelfUpdateExtracting => '패키지 압축 해제 중…';

  @override
  String get devSelfUpdateInstalling => '파일 설치 중…';

  @override
  String get devSelfUpdateRestarting => '다시 시작하는 중…';

  @override
  String get devExtractNoData => '추출할 유효한 식별자가 있는 모드를 찾을 수 없습니다.';

  @override
  String get devExtractDesktopNotFound => '오류: 바탕 화면 디렉터리를 찾을 수 없습니다.';

  @override
  String get devExtractSuccessTitle => '추출 완료';

  @override
  String devExtractSuccessDesc(Object path) {
    return '파일이 성공적으로 생성되었습니다: $path';
  }

  @override
  String get errorDialogTitle => '오류 발생';

  @override
  String get modDetailsCategory => '카테고리';

  @override
  String get modDetailsAuthor => '제작자';

  @override
  String get modDetailsNexusId => 'Nexus ID';

  @override
  String get modDetailsInstalledOn => '설치 날짜';

  @override
  String get unknownAuthor => '알 수 없음';

  @override
  String get statusInstalling => '설치 중...';

  @override
  String statusInstallingMod(int index, int total, String modName) {
    return '$total개 중 $index개 설치 중: $modName';
  }

  @override
  String byText(Object author) {
    return '제작자: $author';
  }

  @override
  String get filterUpdatesAvailable => '사용 가능한 업데이트';

  @override
  String snackBarUpdateIgnored(String modName) {
    return '이번 세션에서 \'$modName\'의 업데이트를 무시했습니다.';
  }

  @override
  String snackBarVersionSkipped(String modName, String version) {
    return '앞으로 \'$modName\'의 \'$version\' 버전은 건너뜁니다.';
  }

  @override
  String statusUpdatingMetadata(String displayName, int arg1, int arg2) {
    return '\'$displayName\'의 메타데이터 업데이트 중($arg1/$arg2)...';
  }

  @override
  String genericModInstallTitle(String modName) {
    return '일반 모드 설치됨: $modName';
  }

  @override
  String genericModInstallDesc(String path) {
    return '$path에 설치되었습니다.\n이 모드는 앱에서 관리하지 않으므로 수동으로 제거해야 합니다.';
  }

  @override
  String genericModInstallError(String modName) {
    return '일반 모드 설치 실패: $modName';
  }

  @override
  String get modTypeCNS => 'CNS';

  @override
  String get modTypeGeneric => '일반';

  @override
  String get modTypeMovies => '무비';

  @override
  String get modTypeSave => '세이브';

  @override
  String get modTypeConfig => '설정';

  @override
  String get modTypeSplash => '스플래시';

  @override
  String get replacesOutfitTitle => '의상 교체';

  @override
  String get replacesOutfitClearTooltip => '의상 선택 지우기';

  @override
  String get replacesOutfitSelectTooltip => '교체할 의상 선택';

  @override
  String get replacesOutfitNone => '선택된 의상 없음.\n태그는 \'일반\'이 됩니다.';

  @override
  String get replacesOutfitSearchHint => '의상 검색...';

  @override
  String get modTypeReplacement => '교체';

  @override
  String get replacesOutfitHover => '의상 위로 마우스를 가져가면 미리보기를 볼 수 있습니다.';

  @override
  String get dialogTitleOutfitReplacement => '의상 교체?';

  @override
  String dialogContentOutfitReplacement(String modName) {
    return '\'$modName\' 모드는 의상 교체 모드입니까?\n\n\'예\'를 선택하여 교체할 의상을 선택하거나 \'아니요\'를 선택하여 일반 모드로 설치하십시오.';
  }

  @override
  String get dialogActionNo => '아니요';

  @override
  String get dialogActionYes => '예';

  @override
  String get dialogTitleOutfitConflict => '의상 충돌 감지됨';

  @override
  String dialogContentOutfitConflict(String outfitName, String modName) {
    return '\'$outfitName\' 의상은 이미 \'$modName\' 모드에 의해 교체되었습니다.\n\n\'$modName\'을(를) 비활성화하고 이 모드를 활성화하시겠습니까?';
  }

  @override
  String get dialogActionActivateAndDisable => '비활성화 및 활성화';

  @override
  String get replacementModSwitchTitle => '교체 모드';

  @override
  String get replacementModSwitchDesc => '이 모드가 게임 내 슈트를 교체하도록 설계되었는지 확인하십시오.';

  @override
  String get settingsShowModTagsTitle => '모드 유형 태그 표시';

  @override
  String get settingsShowModTagsDesc =>
      '목록의 각 모드 카드에 모드 유형 태그(예: CNS, 일반)를 표시합니다.';

  @override
  String get modTypeLogic => '로직';

  @override
  String get patcherStarted => '=== StellarBlade Dart 패처 시작됨 ===';

  @override
  String workingDirectory(String path) {
    return '작업 디렉토리: $path';
  }

  @override
  String modsDirNotFound(String path) {
    return '다음 위치에 ~mods 디렉토리가 존재하지 않습니다: $path';
  }

  @override
  String warnCannotScanFolder(String path) {
    return '\n  경고: $path 폴더를 스캔할 수 없습니다. 건너뜁니다.';
  }

  @override
  String errorDetails(String error) {
    return '  오류: $error\n';
  }

  @override
  String foundUtocFiles(int count) {
    return '$count개의 .utoc 파일을 찾았습니다';
  }

  @override
  String get noModsFound2 => '처리할 모드를 찾을 수 없습니다.';

  @override
  String get patcherSummaryTitle => '\n=== 패처 요약 (원시 데이터) ===';

  @override
  String processedMods(int count) {
    return '$count개의 모드를 처리했습니다.';
  }

  @override
  String fixedContainerIdConflicts(int count) {
    return '$count개의 Container ID 충돌을 해결했습니다.';
  }

  @override
  String foundPackageIdConflicts(int count) {
    return '$count개의 Package ID 충돌을 발견했습니다.';
  }

  @override
  String get fatalErrorTitle => '\n=== 치명적인 오류 ===';

  @override
  String patcherServiceError(String error) {
    return 'PatcherService 오류: $error';
  }

  @override
  String analyzingFile(String fileName) {
    return '--- 분석 중: $fileName ---';
  }

  @override
  String get warnUcasNotFound => '  경고: .ucas 파일을 찾을 수 없습니다. 건너뜁니다.';

  @override
  String get warnCorruptHeader => '  경고: 손상된 헤더, 항목 크기가 파일 크기를 초과합니다. 건너뜁니다.';

  @override
  String conflictContainerIdDetected(int id) {
    return '  Container ID 충돌 감지됨: $id';
  }

  @override
  String generatingNewId(int id) {
    return '  새 ID 생성 중: $id';
  }

  @override
  String get utocFilePatched => '  .utoc 파일이 패치되었습니다.';

  @override
  String get patchingUcasFile => '  .ucas 파일 패치 중...';

  @override
  String ucasReplacementsSuccess(int count) {
    return '  .ucas에서 성공적으로 교체됨: $count';
  }

  @override
  String get patchComplete => '  패치 완료!';

  @override
  String idRegisteredNoConflict(int id) {
    return '  ID $id이(가) 등록되었습니다. 충돌 없음.';
  }

  @override
  String errorProcessingFile(String fileName, String error) {
    return '  $fileName 처리 중 오류 발생: $error';
  }

  @override
  String get statusRunningPatcher => '충돌 패처 실행 중...';

  @override
  String summarySuccessContainerIds(int count) {
    return '✅ 성공! 충돌을 유발하는 $count개의 Container ID 문제를 해결했습니다.';
  }

  @override
  String get summaryNoContainerIdConflicts =>
      '✅ Container ID(충돌) 문제가 발견되지 않았습니다.';

  @override
  String get summaryNoPackageIdConflicts =>
      '✅ 좋은 소식입니다! 심각한 Package ID(덮어쓰기) 충돌이 발견되지 않았습니다.';

  @override
  String summaryFoundPackageIdConflicts(int count) {
    return '⚠️ 경고! 공존할 수 없는 $count개의 모드 그룹을 발견했습니다:';
  }

  @override
  String summaryConflictGroupDetails(int count) {
    return '  • 이 모드 그룹은 $count개의 파일을 두고 경쟁합니다:';
  }

  @override
  String get patcherSummaryDialogTitle => '패처 요약';

  @override
  String get dialogActionShowFullLog => '전체 로그 보기';

  @override
  String get fullLogDialogTitle => '충돌 패처 로그 (Dart)';

  @override
  String get runConflictPatcherTitle => '충돌 패처 실행';

  @override
  String get runConflictPatcherSubtitlePython =>
      'Container_Id 및 Package_Id 충돌 해결';

  @override
  String get processingCover => '표지 처리 중...';

  @override
  String get apiKeyTooltip => '스마트 Nexus ID 추출을 위해 API 키가 필요합니다.';

  @override
  String dialogTitleSpecialModSelection(String nexusId) {
    return '설치 옵션 - 모드 $nexusId';
  }

  @override
  String get dialogContentSpecialModSelection =>
      '설치하려는 옵션을 선택하십시오. 필수 기본 파일이 자동으로 설치됩니다.';

  @override
  String get snackBarSpecialModNoSelection => '계속하려면 하나 이상의 옵션을 선택하십시오.';

  @override
  String get dialogActionInstallSelection => '선택 항목 설치';

  @override
  String get downloadStatusFetching => 'Nexus Mods 데이터 가져오는 중...';

  @override
  String get downloadStatusFetchingFailed =>
      '다운로드 링크를 가져오지 못했습니다. API 키 또는 연결을 확인하세요.';

  @override
  String downloadStatusDownloading(String fileName) {
    return '$fileName 다운로드 중';
  }

  @override
  String get downloadStatusError => '파일 다운로드 중 오류가 발생했습니다.';

  @override
  String downloadStatusException(String error) {
    return '예외: $error';
  }

  @override
  String get dialogTitleDownloadModManager => '모드 매니저 다운로드';

  @override
  String get launchGameText => 'Stellar Blade 실행';

  @override
  String get stopGameText => 'Stellar Blade 종료';

  @override
  String get dialogTitleStopGame => 'Stellar Blade를 종료할까요?';

  @override
  String get dialogContentStopGame => '게임이 종료됩니다. 저장하지 않은 진행 상황은 사라집니다.';

  @override
  String get dialogActionStopGame => '종료';

  @override
  String get notificationGameStopped => 'Stellar Blade를 종료했습니다';

  @override
  String get errorStoppingGame => '게임을 종료할 수 없습니다';

  @override
  String get mod801DialogTitle => 'Steam 설정 필요';

  @override
  String get mod801DialogIntro =>
      'Random Splash 모드가 설치되었습니다. 게임 실행 시 자동으로 작동하게 하려면 Steam을 설정해야 합니다.';

  @override
  String get mod801Step1 => '1. 아래에서 PC의 정확한 경로를 생성하고 복사합니다.';

  @override
  String get mod801Step2 => '2. Steam 라이브러리를 엽니다.';

  @override
  String get mod801Step3 => '3. Stellar Blade를 우클릭 -> 속성을 선택합니다.';

  @override
  String get mod801Step4 => '4. \'일반\' 탭의 \'시작 옵션\'에 코드를 붙여넣습니다.';

  @override
  String get mod801BtnGenerate => '경로 생성';

  @override
  String get mod801BtnSteam => 'Steam 열기';

  @override
  String get mod801BtnCopy => '복사';

  @override
  String get mod801PathGenerated => '경로가 성공적으로 생성되었습니다.';

  @override
  String get mod801PathCopied => '명령어가 클립보드에 복사되었습니다!';

  @override
  String get statusVerifyingMods => '모드 무결성 확인 중...';

  @override
  String errorSelecting7Zip(String error) {
    return '7-Zip 선택 오류: $error';
  }

  @override
  String get errorInvalidFolderRetry => '선택한 폴더가 올바르지 않은 것 같습니다. 다시 시도해 주세요.';

  @override
  String errorSelectingFolderDynamic(String error) {
    return '폴더 선택 오류: $error';
  }

  @override
  String get statusNoNewModsInstalled => '설치된 새로운 모드가 없습니다.';

  @override
  String get errorDisableModBeforeDelete => '삭제하기 전에 모드를 비활성화해 주세요.';

  @override
  String snackBarModsEnabledWithSkips(int successCount, int skippedCount) {
    return '활성화됨: $successCount (충돌로 인해 건너뜀: $skippedCount)';
  }

  @override
  String get snackBarDeveloperModeEnabled => '개발자 모드가 활성화되었습니다!';

  @override
  String errorRenamingMod(String error) {
    return '모드 이름 변경 오류: $error';
  }

  @override
  String get notificationTitleError => '오류';

  @override
  String get errorGamePathNotFoundNotification => '게임 경로를 찾을 수 없습니다.';

  @override
  String get notificationLaunchingGame => 'Stellar Blade 실행 중...';

  @override
  String get errorLaunchingGame => '게임 실행 오류';

  @override
  String get dialogTitleSelect7zip => '7z.exe 파일을 선택해 주세요';

  @override
  String get dialogTitleSelectGameFolder => 'StellarBlade 메인 폴더를 선택해 주세요';

  @override
  String get dialogTitleSelectCover => '모드의 커버 이미지를 선택해 주세요';

  @override
  String get errorGamePathNotFoundException => '게임 경로를 찾을 수 없습니다.';

  @override
  String get errorGamePathNotDefined => '게임 경로가 정의되지 않았습니다.';

  @override
  String get errorLogicModsPathNotDefined => 'Logic 모드 경로가 정의되지 않았습니다.';

  @override
  String get errorUe4ssModsPathNotDefined => 'UE4SS 모드 경로가 정의되지 않았습니다.';

  @override
  String get errorGenericModsPathNotDefined => '일반 모드(~mods) 경로가 정의되지 않았습니다.';

  @override
  String get errorReplaceNoOldVersion => '모드를 교체하려고 했으나 이전 버전을 찾을 수 없습니다.';

  @override
  String errorDeleteOldModVersion(String modName) {
    return '이전 버전의 모드($modName)를 삭제할 수 없습니다.';
  }

  @override
  String errorDeleteExistingModReinstall(String modName) {
    return '재설치를 위해 기존 모드($modName)를 삭제할 수 없습니다.';
  }

  @override
  String errorDeleteExistingModReinstallAttempts(String modName) {
    return '여러 번 시도했지만 재설치를 위해 기존 모드($modName)를 삭제할 수 없습니다.';
  }

  @override
  String get errorMoviesModNoValidFiles => '동영상 모드에 유효한 비디오 파일이 포함되어 있지 않습니다.';

  @override
  String get errorInstallPathUndetermined => '설치 경로를 확인할 수 없습니다.';

  @override
  String get errorMoviesPathsNotDefined => '동영상 경로가 정의되지 않았습니다.';

  @override
  String errorNexusInfoNotFoundForMod(String modName) {
    return '$modName의 nexus_info.json을 찾을 수 없습니다.';
  }

  @override
  String get errorMenuVideoLimitReached => '메뉴 비디오 제한인 99개에 도달했습니다.';

  @override
  String get errorModRequires529 =>
      '모드가 작동하려면 Mod ID 529가 필요합니다(WebM 파일만 포함됨).';

  @override
  String get errorSplashPathsNotDefined => '스플래시 경로가 정의되지 않았습니다.';

  @override
  String get errorSplashNoValidImages => '모드에서 유효한 이미지를 찾을 수 없습니다.';

  @override
  String get errorCouldNotDeleteDirectory => '디렉토리를 삭제할 수 없습니다.';

  @override
  String get errorGameExeNotFound =>
      '게임 실행 파일(.exe)을 메인 폴더나 Binaries에서 찾을 수 없습니다.';

  @override
  String get dialogTitleSplashOptions => '스플래시 옵션 (이미지)';

  @override
  String get dialogContentSplashOptions =>
      '설치할 이미지를 선택해 주세요. 전체 폴더(일괄) 또는 개별 이미지를 선택할 수 있습니다.';

  @override
  String get snackBarSplashNoSelection => '최소 하나 이상의 이미지를 선택해 주세요.';

  @override
  String get dialogContentSpecialModSingleSelection => '설치할 단일 옵션을 선택해 주세요.';

  @override
  String get activeDownloads => '활성 다운로드';

  @override
  String downloadingModsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '모드',
      one: '모드',
    );
    return '$count개의 $_temp0 다운로드 중';
  }

  @override
  String get downloadError => '오류';

  @override
  String get downloadCancelled => '취소됨';

  @override
  String get downloadPause => '일시 정지';

  @override
  String get downloadResume => '계속';

  @override
  String get downloadCancel => '취소';

  @override
  String get errorNexusInfoNotFound => 'nexus_info.json을 찾을 수 없습니다.';

  @override
  String logFixingCorruptedJson(String displayName) {
    return '$displayName의 손상된 nexus_info.json을 수정 중입니다.';
  }

  @override
  String logMetadataUpdateFailed(String displayName, String error) {
    return '$displayName의 메타데이터를 업데이트할 수 없습니다: $error';
  }

  @override
  String logDisablingMovieMod(String modName) {
    return 'Mod 529 활성화로 인해 동영상 모드를 예방 차원에서 비활성화합니다: $modName';
  }

  @override
  String logDisablingSplashMod(String modName) {
    return 'Mod 801 활성화로 인해 스플래시 모드를 예방 차원에서 비활성화합니다: $modName';
  }

  @override
  String logRestoringTildeComponent(String folderName) {
    return '~mods 구성 요소 복원 중: $folderName';
  }

  @override
  String logRestoringUe4ssComponent(String folderName) {
    return 'UE4SS 구성 요소 복원 중: $folderName';
  }

  @override
  String logErrorRestoringLogicMod(String error) {
    return 'LogicMod 구성 요소를 복원하는 중 오류 발생: $error';
  }

  @override
  String logArchivingTildeComponent(String folderName) {
    return '~mods 구성 요소 보관 중: $folderName';
  }

  @override
  String logArchivingUe4ssComponent(String folderName) {
    return 'UE4SS 구성 요소 보관 중: $folderName';
  }

  @override
  String logErrorArchivingLogicMod(String error) {
    return 'LogicMod 구성 요소를 보관하는 중 오류 발생: $error';
  }

  @override
  String logSkippingActiveVariant(String modName) {
    return '$modName 건너뛰기: 이 모드의 활성 변형이 이미 존재합니다.';
  }

  @override
  String logSkippingOutfitConflict(String modName) {
    return '$modName 건너뛰기: 이미 사용 중인 의상과 충돌합니다.';
  }

  @override
  String logErrorCleaningVideoBackups(String modName, String error) {
    return '$modName의 비디오 백업을 정리할 수 없습니다: $error';
  }

  @override
  String logNewNexusIdDetected(String nexusId) {
    return '새로운 Nexus ID $nexusId 감지됨. 메타데이터를 가져오는 중...';
  }

  @override
  String logMetadataApplied(String nexusId) {
    return '$nexusId의 메타데이터를 가져와 적용했습니다.';
  }

  @override
  String logFallbackByteCopy(String error) {
    return '일반 복사에 실패했습니다. 바이트 브루트 포스를 사용합니다: $error';
  }

  @override
  String logWarningDeleteModifiedFile(String error) {
    return '경고: 수정된 파일을 삭제할 수 없습니다: $error';
  }

  @override
  String get logMod801BatPatched =>
      '이 시스템에 맞게 Mod 801 .bat 스크립트가 성공적으로 패치되었습니다.';

  @override
  String logMod801BatPatchError(String error) {
    return 'Mod 801 .bat 파일을 패치하는 중 오류 발생: $error';
  }

  @override
  String get errorHomeDirNotFound => '홈 디렉터리 환경 변수를 찾을 수 없습니다.';

  @override
  String get downloadFetchingPlaceholder => '가져오는 중...';

  @override
  String get downloadErrorLink => '다운로드 링크를 가져올 수 없습니다';

  @override
  String get downloadErrorGeneral => '다운로드 실패';

  @override
  String get downloadPausedStatus => '일시 정지됨';

  @override
  String get settingsFixGameStartup => '게임이 실행되지 않는 문제 해결';

  @override
  String get settingsFixGameStartupDesc =>
      '게임이 실행 중 종료되거나 충돌할 때 사용하세요. UE4SS와 CNS를 일시적으로 제거하고 게임을 한 번 실행한 뒤 다시 설치합니다.';

  @override
  String get repairConfirmTitle => '게임 실행을 복구할까요?';

  @override
  String get repairConfirmMessage =>
      'UE4SS와 CNS를 제거하고(파일은 안전하게 보관됩니다), 게임을 자동으로 실행했다가 종료한 뒤 모두 다시 설치하고 게임을 다시 실행합니다. 진행 중에는 앱을 닫지 마세요.';

  @override
  String get repairConfirmAction => '복구 시작';

  @override
  String get launchRetryTitle => '게임이 실행되지 않았습니다';

  @override
  String get launchRetryMessage =>
      '두 번 시도했지만 Stellar Blade가 실행되지 않았습니다. 보통 UE4SS 또는 CNS가 원인입니다. \"게임이 실행되지 않는 문제 해결\"은 이 둘을 일시적으로 제거하고 게임을 한 번 실행한 뒤 다시 설치합니다. 지금 실행할까요?';

  @override
  String get launchRetryAction => '지금 해결';

  @override
  String get repairOverlayTitle => '게임 실행 복구 중';

  @override
  String get repairOverlayWarning => '진행 중에는 앱이나 게임을 직접 닫지 마세요.';

  @override
  String get repairStepCloseGame => '실행 중인 게임 종료';

  @override
  String get repairStepStashCns => 'CNS 제거 (파일 보관)';

  @override
  String get repairStepStashUe4ss => 'UE4SS 제거 (파일 보관)';

  @override
  String get repairStepLaunchClean => 'UE4SS와 CNS 없이 게임 실행';

  @override
  String get repairStepWaitInit => '게임 로딩 대기';

  @override
  String get repairStepCloseAuto => '게임 자동 종료';

  @override
  String get repairStepRestoreUe4ss => 'UE4SS 재설치';

  @override
  String get repairStepRestoreCns => 'CNS 재설치';

  @override
  String get repairStepLaunchFinal => '게임 실행';

  @override
  String get repairStatusSkipped => '건너뜀';

  @override
  String get repairResultSuccess => '복구가 완료되었습니다. 게임을 실행했습니다.';

  @override
  String get repairResultErrorRestored => '복구에 실패했지만 UE4SS와 CNS는 원래대로 복원되었습니다.';

  @override
  String get repairResultErrorRestoreFailed =>
      '복구에 실패했고 파일을 아직 복원하지 못했습니다. 다음에 앱을 실행할 때 자동으로 복원됩니다.';

  @override
  String get repairErrorGameNotStarted => '게임이 제시간에 실행되지 않았습니다.';

  @override
  String get repairButtonClose => '닫기';

  @override
  String get repairRecoveredNotice => '중단된 복구가 감지되어 UE4SS와 CNS 파일을 복원했습니다.';

  @override
  String snackBarNewEditionInstalled(Object name) {
    return '새 에디션이 설치되었습니다: $name';
  }

  @override
  String snackBarNewEditionInstalledDesc(Object count) {
    return '이 모드에는 이제 $count개의 에디션이 설치되어 있습니다.';
  }

  @override
  String get previewTagNewEdition => '새 에디션';

  @override
  String get previewTagUpdate => '업데이트';

  @override
  String editionsInstalledTooltip(Object count) {
    return '이 모드의 에디션 $count개 설치됨';
  }

  @override
  String editionLabelValue(Object edition) {
    return '에디션: $edition';
  }

  @override
  String get otherEditionsTitle => '설치된 다른 에디션';

  @override
  String get detailsStatusEnabled => '활성화됨';

  @override
  String get detailsStatusDisabled => '비활성화됨';

  @override
  String get detailsInformation => '정보';

  @override
  String get detailsRowAuthor => '제작자';

  @override
  String get detailsRowType => '유형';

  @override
  String get detailsRowInstalled => '설치일';

  @override
  String get detailsRowModified => '마지막 수정';

  @override
  String get detailsRowNexusId => 'Nexus ID';

  @override
  String get detailsRowFolder => '폴더';

  @override
  String get detailsCopyPath => '경로 복사';

  @override
  String get detailsCopied => '클립보드에 복사되었습니다';

  @override
  String get detailsEndorse => 'Endorse';

  @override
  String get detailsEndorsed => 'Endorsed';

  @override
  String endorseWaitLabel(Object minutes) {
    return '$minutes분 대기';
  }

  @override
  String get endorseSuccessTitle => '모드를 Endorse했습니다';

  @override
  String get endorseRemovedTitle => 'Endorse를 취소했습니다';

  @override
  String get endorseFailedTitle => 'Endorse를 업데이트할 수 없습니다';

  @override
  String get endorseErrNotNexus =>
      '이 모드는 Nexus Mods 페이지와 연결되어 있지 않아 Endorse할 수 없습니다.';

  @override
  String get endorseErrNoApiKey =>
      '모드를 Endorse하려면 설정에서 Nexus Mods API 키를 추가하세요.';

  @override
  String endorseErrWait(Object minutes) {
    return 'Nexus에서는 모드를 다운로드한 후 15분이 지나야 Endorse할 수 있습니다. $minutes분 후에 다시 시도하세요.';
  }

  @override
  String get endorseErrNotDownloaded =>
      'Nexus에서는 내 계정으로 다운로드한 모드만 Endorse할 수 있습니다.';

  @override
  String get endorseErrOwnMod => '자신의 모드는 Endorse할 수 없습니다.';

  @override
  String get endorseErrRateLimit => 'Nexus 요청 한도에 도달했습니다. 나중에 다시 시도하세요.';

  @override
  String get endorseErrInvalidKey => 'Nexus가 API 키를 거부했습니다. 설정에서 확인하세요.';

  @override
  String get endorseErrNetwork => 'Nexus Mods에 연결할 수 없습니다. 연결을 확인하고 다시 시도하세요.';

  @override
  String get endorseErrUnknown => 'Nexus가 요청을 처리하지 못했습니다. 나중에 다시 시도하세요.';

  @override
  String get endorseRemoveConfirmTitle => 'Endorse를 취소할까요?';

  @override
  String endorseRemoveConfirmMessage(Object name) {
    return '$name이(가) Nexus Mods에서 더 이상 Endorse 상태가 아니게 됩니다.';
  }

  @override
  String get endorseRemoveConfirmAction => '취소';

  @override
  String get detailsUpdateAction => '업데이트';

  @override
  String get detailsShowMore => '더 보기';

  @override
  String get detailsShowLess => '간략히 보기';

  @override
  String get detailsAddNote => '메모 추가';

  @override
  String outfitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '의상 $count개',
      one: '의상 1개',
      zero: '의상 없음',
    );
    return '$_temp0';
  }

  @override
  String outfitsSelectedCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String get outfitsChoose => '의상 선택';

  @override
  String get outfitsDone => '완료';

  @override
  String get outfitsFilterAll => '전체';

  @override
  String get outfitsFilterSelected => '선택됨';

  @override
  String get outfitsClearAll => '모두 지우기';

  @override
  String get outfitsRemove => '제거';

  @override
  String get outfitsActionSelect => '선택';

  @override
  String get outfitsActionDeselect => '선택 해제';

  @override
  String outfitsNoResults(String query) {
    return '\"$query\"에 대한 결과가 없습니다';
  }

  @override
  String get outfitsSelectedEmpty => '아직 선택한 의상이 없습니다.';

  @override
  String get outfitsNoPreview => '미리보기를 사용할 수 없습니다';

  @override
  String get replacementOffConfirmTitle => '교체 모드를 끌까요?';

  @override
  String replacementOffConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '선택한 의상 $count개가 이 모드에서 제거됩니다.',
      one: '선택한 의상이 이 모드에서 제거됩니다.',
    );
    return '$_temp0';
  }

  @override
  String get replacementOffConfirmAction => '끄기';

  @override
  String outfitConflictAutoDisabled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '모드 $count개를 껐습니다: 다른 모드에서 이미 사용 중인 의상을 교체하기 때문입니다',
      one: '모드 1개를 껐습니다: 다른 모드에서 이미 사용 중인 의상을 교체하기 때문입니다',
    );
    return '$_temp0';
  }

  @override
  String patcherSharedWith(String owner) {
    return '  다음과 동일한 Container ID: $owner';
  }

  @override
  String patcherIdChange(String oldId, String newId) {
    return '  Container ID $oldId → $newId';
  }

  @override
  String get patcherBackupSaved => '  원본을 .cnsbak으로 보관했습니다(복원 가능).';

  @override
  String patcherLeftUntouched(String reason) {
    return '  변경하지 않음(패치하기에 안전하지 않음): $reason';
  }

  @override
  String summaryUnfixableContainerIds(int count) {
    return '⚠️ 모드 $count개가 Container ID를 공유하지만 안전하게 수정할 수 없었습니다(변경하지 않음, CNS에 표시되지 않을 수 있음):';
  }

  @override
  String get revertPatchesTitle => '충돌 패치 되돌리기';

  @override
  String get revertPatchesDesc => '충돌 패처가 변경한 원본 모드 파일을 복원합니다.';

  @override
  String get revertPatchesConfirmTitle => '충돌 패치를 되돌릴까요?';

  @override
  String get revertPatchesConfirmMessage =>
      '충돌 패처가 저장한 원본 파일(.cnsbak)이 복원됩니다. 먼저 게임을 종료하세요. 충돌하는 모드가 CNS에 다시 표시되지 않을 수 있습니다.';

  @override
  String get revertPatchesAction => '되돌리기';

  @override
  String revertPatchesDone(int count) {
    return '$count개 파일을 복원했습니다.';
  }

  @override
  String get revertPatchesNothing => '되돌릴 패치된 파일이 없습니다.';

  @override
  String get settingsGroupPaths => '경로';

  @override
  String get settingsGroupTools => '도구';

  @override
  String get settingsAutoOutfit => '의상 자동 할당';

  @override
  String get settingsAutoOutfitDesc =>
      '교체 모드를 설치할 때 파일을 읽어 어떤 의상을 교체하는지 자동으로 감지합니다. 끄면 의상을 수동으로 지정합니다.';

  @override
  String get variantChoiceTitle => '동일한 교체의 여러 변형';

  @override
  String variantChoiceBodyOutfits(String mod, String outfits) {
    return '모드 \"$mod\"에는 $outfits을(를) 교체하는 여러 변형이 있습니다. 한 번에 하나만 활성화할 수 있습니다. 어떤 것을 설치할까요?';
  }

  @override
  String variantChoiceBodyFiles(String mod) {
    return '모드 \"$mod\"에는 같은 파일을 교체하는 여러 변형이 있습니다. 한 번에 하나만 활성화할 수 있습니다. 어떤 것을 설치할까요?';
  }

  @override
  String get variantChoiceInstallAll => '모두 설치(별도의 모드로)';

  @override
  String get installOutfitConflictTitle => '이미 사용 중인 의상';

  @override
  String installOutfitConflictBody(
    String newMod,
    String outfits,
    String oldMod,
  ) {
    return '모드 \"$newMod\"은(는) 의상 $outfits을(를) 교체하는데, 이 의상은 이미 활성화된 모드 \"$oldMod\"에 할당되어 있습니다. 한 번에 하나만 활성화할 수 있습니다. 어느 쪽을 활성 상태로 둘까요?';
  }

  @override
  String get installOutfitKeepCurrent => '현재 모드 유지';

  @override
  String get installOutfitUseNew => '새 모드 활성화';

  @override
  String installOutfitNowActive(String active) {
    return '현재 활성: $active';
  }

  @override
  String get fileLockErrorTitle => '모드를 이동할 수 없습니다';

  @override
  String get fileLockErrorMessage =>
      '다른 프로그램이 게임 파일을 사용 중일 수 있습니다(FModel, 게임 자체, 백신, 파일 탐색기 등). 해당 프로그램을 닫고 다시 시도하세요.';

  @override
  String get nexusProfileTooltip => 'Nexus Mods 프로필';

  @override
  String get nexusUserFallback => '사용자';

  @override
  String get nexusPlanPremium => 'Premium';

  @override
  String get nexusPlanMember => '멤버';

  @override
  String get nexusPlanSupporter => '서포터';

  @override
  String get nexusApiRequestsRemaining => '남은 API 요청';

  @override
  String get nexusApiDaily => '일일';

  @override
  String get nexusApiHourly => '시간당';

  @override
  String get downloadMemberAccountLimit =>
      '멤버 계정은 Nexus Mods에서 1.5 MB/s로 제한됩니다';

  @override
  String get downloadSupporterAccountLimit =>
      '서포터 계정은 Nexus Mods에서 3 MB/s로 제한됩니다';

  @override
  String get downloadRetryTooltip => '다시 시도';

  @override
  String get downloadRefreshingLink => '링크 새로 고치는 중...';

  @override
  String get downloadNoInternet => '인터넷에 연결되어 있지 않습니다. 네트워크를 확인하세요.';

  @override
  String downloadErrorLinkExpired(int code) {
    return 'Nexus 링크가 만료되었습니다 ($code)';
  }

  @override
  String downloadErrorHttp(int code) {
    return 'HTTP 오류: $code';
  }

  @override
  String get downloadErrorTimeout => '시간 초과: 네트워크 데이터를 받지 못하고 있습니다';

  @override
  String get splashRootFolder => '루트(기본)';

  @override
  String get repairErrorGameNotClosed => '게임 프로세스를 종료할 수 없습니다.';

  @override
  String get errorManifestNotFound => '설치 매니페스트를 찾을 수 없습니다. 제거할 수 없습니다.';

  @override
  String get downloadResuming => '다시 시작하는 중...';

  @override
  String get apiKeyPromptTitle => 'Nexus Mods API 키를 설정하세요';

  @override
  String get apiKeyPromptMessage =>
      'API 키가 감지되지 않았습니다. 설정은 선택 사항이지만 편의를 위해 권장합니다. 모드 업데이트 확인, 원클릭 다운로드(nxm://), Nexus Mods의 커버 이미지와 정보 불러오기를 사용할 수 있습니다.';

  @override
  String get apiKeyPromptConfigure => 'API 키 설정';

  @override
  String get apiKeyPromptSkip => '건너뛰기';

  @override
  String get apiKeyPromptDontShowAgain => '이 메시지를 다시 표시하지 않기';

  @override
  String get adjustCoverTooltip => '커버 조정';

  @override
  String get noCoverToAdjust => '이 모드에는 조정할 커버가 없습니다';

  @override
  String errorAdjustingCoverText(Object error) {
    return '커버 조정 중 오류 발생: $error';
  }
}
