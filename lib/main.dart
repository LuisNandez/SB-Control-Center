// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, no_leading_underscores_for_local_identifiers, constant_pattern_never_matches_value_type, unreachable_switch_default, non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use, prefer_interpolation_to_compose_strings, control_flow_in_finally

import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show ImageFilter, FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'settings_page.dart';
import 'thumbnail_service.dart';
import 'notification_service.dart';
import 'mod_classifier_service.dart';
import 'dart:async';
import 'patcher_service.dart';
import 'package:hugeicons/hugeicons.dart';

import 'models/mod_info.dart';
import 'config/app_prefs.dart';
import 'models/app_enums.dart';
import 'models/nexus_plan.dart';
import 'services/self_endorse_service.dart';
import 'utils/version_utils.dart';
import 'services/nexus_api_service.dart';
import 'services/endorse_info_store.dart';
import 'services/file_manager_service.dart';
import 'services/game_locator_service.dart';
import 'ui/widgets/mod_grid_card.dart';
import 'ui/widgets/mod_list_tile.dart';
import 'ui/widgets/mod_details_panel.dart';
import 'ui/widgets/image_viewer.dart';
import 'utils/text_utils.dart';
import 'ui/dialogs/edit_dialogs.dart';
import 'ui/widgets/installation_panel.dart';
import 'services/core_installer_service.dart';
import 'models/installation_models.dart';
import 'services/archive_service.dart';
import 'services/mod_manager_service.dart';
import 'services/mod_locations_service.dart';
import 'ui/dialogs/mod_location_picker.dart';
import 'services/mod_metadata_migrator.dart';
import 'services/update_service.dart';
import 'services/self_update_service.dart';
import 'services/github_update_service.dart';
import 'ui/dialogs/self_update_dialog.dart';
import 'services/special_mods_handler.dart';
import 'ui/dialogs/special_mod_dialog.dart';
import 'ui/dialogs/variant_choice_dialog.dart';
import 'services/variant_conflict_service.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'ui/dialogs/download_dialog.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'services/movie_mods_handler.dart';
import 'ui/dialogs/mod_801_steam_dialog.dart';
import 'services/splash_mods_handler.dart';
import 'services/config_mod_detector.dart';
import 'ui/dialogs/splash_mod_dialog.dart';
import 'services/download_manager.dart';
import 'ui/widgets/download_pill_overlay.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'ui/theme/ios_theme.dart';
import 'ui/widgets/ios_widgets.dart';
import 'ui/widgets/ios_motion.dart' show IosMotion;
import 'ui/widgets/smooth_scroll.dart';
import 'ui/widgets/ios_progress_bar.dart';
import 'ui/dialogs/settings_dialogs.dart';
import 'ui/dialogs/install_dialogs.dart';
import 'services/game_repair_service.dart';
import 'ui/dialogs/repair_game_dialog.dart';
import 'services/outfit_detector.dart';
import 'services/hd_atool_audio_service.dart';

final StreamController<String> multiInstanceLinkStream = StreamController<String>.broadcast();

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Si la app fue reabierta por una auto-actualización, espera a que la
  // instancia anterior termine (control de instancia única).
  await SelfUpdateService.waitForPreviousInstance(args);
  HttpOverrides.global = NexusHttpOverrides();

  await windowManager.ensureInitialized();
  await protocolHandler.register('nxm');

  await WindowsSingleInstance.ensureSingleInstance(
    args,
    "SB_Control_Center_Unique_Instance", // Un ID único interno para el proceso de Windows
    onSecondWindow: (List<String> newArgs) {
      // ESTO SE EJECUTA EN LA APP ORIGINAL CUANDO INTENTAN ABRIR UNA SEGUNDA

      // Traemos la app original al frente
      windowManager.show();
      windowManager.focus();

      // Buscamos si la app fantasma traía un enlace de descarga en sus argumentos
      for (String arg in newArgs) {
        if (arg.startsWith('nxm://')) {
          // Lo enviamos por nuestro túnel hacia la UI
          multiInstanceLinkStream.add(arg);
          break;
        }
      }
    },
  );

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(680, 700),
    size: Size(1100, 700),
    center: true,
    title: 'SB Control Center',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ModInstallerApp());
}

class ModInstallerApp extends StatefulWidget {
  const ModInstallerApp({super.key});

  @override
  State<ModInstallerApp> createState() => _ModInstallerAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _ModInstallerAppState? state = context
        .findAncestorStateOfType<_ModInstallerAppState>();
    state?.setLocale(newLocale);
  }
}

class _ModInstallerAppState extends State<ModInstallerApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(AppPrefs.languageCode);
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SB Control Center',
      debugShowCheckedModeBanner: false,
      theme: IosTheme.dark(),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ModInstallerHomePage(),
    );
  }
}

class ModInstallerHomePage extends StatefulWidget {
  const ModInstallerHomePage({super.key});

  @override
  State<ModInstallerHomePage> createState() => _ModInstallerHomePageState();
}

class _ModInstallerHomePageState extends State<ModInstallerHomePage> with ProtocolListener {
  final List<PreparedMod> _preparedMods = [];
  PreparedUE4SS? _preparedUE4SS;
  Map<String, List<String>> _modsToInstallPreviewMap = {};
  final List<File> _installQueue = [];
  bool _isProcessingQueue = false;

  // --- Panel único de instalación (las descargas se apilan dentro) ---------
  bool _installPanelOpen = false;
  bool _panelFromDownloads = false;
  bool _isDrainingQueue = false;
  int _extractionBatch = 0;
  VoidCallback? _drainPanelQueue;
  final Set<String> _enqueuedDownloadPaths = {};
  final List<File> _consumedDownloads = [];

  String _statusMessage = '';
  Color _statusColor = Colors.white;
  bool _isLoading = true;
  bool _isLaunchingGame = false;
  bool _isGameRunning = false; // el juego está en ejecución (botón rojo)
  bool _isStoppingGame = false;
  bool _gameCheckInFlight = false;
  Timer? _gameWatcher;

  List<ModInfo> _allMods = [];

  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Scroll de la cuadrícula y de la lista de mods, con la rueda del ratón
  // suavizada. Son dos controladores porque durante el cambio de vista (fundido
  // de 300 ms) ambas vistas existen a la vez.
  final IosSmoothScrollController _gridScrollController =
      IosSmoothScrollController();
  final IosSmoothScrollController _listScrollController =
      IosSmoothScrollController();

  bool _isDragging = false;
  Directory? _tempExtractionDir;

  String? _gameRootPath;
  String? _finalModsPath;
  String? _genericModsPath;
  String? _moviesPath;
  String? _moviesBackupPath;
  String? _logicModsPath;
  String? _ue4ssModsPath;
  String? _savesPath;         // <-- NUEVO: Ruta a %LOCALAPPDATA%/SB/Saved/SaveGames
  String? _configPath;        // <-- NUEVO: Ruta a %LOCALAPPDATA%/SB/Saved/Config/WindowsNoEditor
  String? _splashPath;        // <-- NUEVO: Ruta a SB/Content/Splash

  String? _savesBackupPath;   // <-- NUEVO: Respaldo seguro de partidas originales
  String? _configBackupPath;  // <-- NUEVO: Respaldo seguro de configuraciones (.ini)
  String? _splashBackupPath;  // <-- NUEVO: Respaldo seguro del splash original

  String? _7zipPath;

  String? _apiKey;

  List<String> _lastInstalledModNames = [];

  String _appVersion = '';

  String? _cnsVersion;
  String? _cnsNexusId;
  Map<String, dynamic>? _cnsUpdateInfo;

  final Map<String, Map<String, dynamic>> _modUpdates = {};
  final Set<String> _ignoredUpdates = {};
  bool _isCheckingForUpdates = false;

  Map<String, String> _skippedVersions = {};
  Map<String, dynamic> _modDatabase = {};

  bool _isExtracting = false;
  double _extractionProgress = 0.0;
  String _extractionStatus = '';

  bool _isInstalling = false;
  double _installationProgress = 0.0;
  String _installationStatus = '';
  Set<String> _logicModIds = {};

  ModFilter _currentFilter = ModFilter.all;
  ModTypeFilter _currentModTypeFilter = ModTypeFilter.all;
  ModSort _currentSort = ModSort.date;
  ModListViewMode _viewMode = ModListViewMode.grid;
  bool _showModTypeTags = true;
  bool _autoAssignOutfits = true; // Ajustes: asignación automática de trajes

  bool _isUe4ssInstalled = false;
  bool _isCnsCoreInstalled = false;

  bool _developerModeEnabled = false;
  Timer? _hoverTimer;
  OverlayEntry? _previewOverlay;
  Offset _cursorPosition = Offset.zero;

  final ThumbnailService _thumbnailService = ThumbnailService();
  StreamSubscription<String>? _multiInstanceSubscription;

  String? _nexusUserName;
  NexusPlan _nexusPlan = NexusPlan.member;
  String? _nexusAvatarUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statusMessage.isEmpty && mounted) {
      _statusMessage = AppLocalizations.of(context)!.statusSearchingGame;
    }
  }

  @override
  void initState() {
    super.initState();
    _startGameWatcher();
    
    // Esperamos a que todo se inicialice (incluyendo la carga de la API Key)
    _initialize().then((_) {
      _checkForAppUpdate(); // sin await: no bloquea el arranque
      // Invita a configurar la API key de Nexus si no hay ninguna (opcional).
      _maybeShowApiKeyPrompt();
      // Solo registramos el listener y revisamos el link cuando todo está listo
      protocolHandler.addListener(this);
      _checkInitialProtocolUrl();
      _multiInstanceSubscription = multiInstanceLinkStream.stream.listen((String url) {
      _handleNxmDownload(url);
    });
  });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    _multiInstanceSubscription?.cancel();
    _searchController.dispose();
    _gridScrollController.dispose();
    _listScrollController.dispose();
    _gameWatcher?.cancel();
    _hoverTimer?.cancel();
    _previewOverlay?.remove();
    try {
      if (_tempExtractionDir != null && _tempExtractionDir!.existsSync()) {
        _tempExtractionDir!.deleteSync(recursive: true);
      }
    } catch (e) {
      print('Could not clean up temporary directory on exit: $e');
    }
    super.dispose();
  }

  Future<void> _checkInitialProtocolUrl() async {
    String? initialUrl = await protocolHandler.getInitialUrl();
    if (initialUrl != null && initialUrl.startsWith('nxm://')) {
      _handleNxmDownload(initialUrl);
    }
  }

  // Intercepta los clics en nxm:// cuando la aplicación ya está abierta
  @override
  void onProtocolUrlReceived(String url) {
    if (url.startsWith('nxm://')) {
      windowManager.show();
      windowManager.focus();
      _handleNxmDownload(url);
    }
  }

  // En main.dart

  Future<void> _handleNxmDownload(String url) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: AppLocalizations.of(context)!.errorApiKeyMissing,
        );
      }
      return;
    }
    final l10n = AppLocalizations.of(context)!;

    // Mostrar el Overlay de descargas (la píldora)
    DownloadOverlay.show(context);

    // Añadir la descarga al gestor global
    DownloadManager.instance.addDownload(
      nxmUrl: url, 
      apiKey: _apiKey!, 
      fetchingText: l10n.downloadFetchingPlaceholder,
      linkErrorText: l10n.downloadErrorLink,
      downloadErrorText: l10n.downloadErrorGeneral,
      l10n: l10n,
      onComplete: (File readyFile, String modId, String version) {
        // Se apila: si el panel ya está abierto lo absorbe; si no, se abre uno.
        _enqueuedDownloadPaths.add(readyFile.path);
        _installQueue.add(readyFile);
        _processInstallQueue();
      },
    );
  }

  bool _isUpdatingMetadata = false;
  double _metadataUpdateProgress = 0.0;
  String _metadataUpdateStatus = '';

  Future<void> _initialize() async {
    await _getAppVersion();
    await _thumbnailService.initialize();
    await _cleanUpOrphanedTempDirs();
    await SelfUpdateService.cleanupLeftovers();
    await GithubUpdateService.cleanupDownloads();
    await _loadModDatabase();
    await _loadLogicModIds();
    await _find7zipPath();
    await _loadApiKey();
    SelfEndorseService.instance.configure(apiKey: _apiKey, version: _appVersion);
    await _loadSkippedVersions();
    await _loadPrefs();
    await _findGamePath();

    if (_finalModsPath != null) {
      await _checkCoreInstallations();
      await _recoverInterruptedRepair();
      await _migrateModFolders();
      await _runMetadataUpdateIfNeeded();
      await _loadAllMods();
      await _readCNSData();
    }
  }

  /*// Escribe los scripts empaquetados en el disco al iniciar la app.
  Future<void> _deployScriptAssets() async {
  final l10n = AppLocalizations.of(context)!;
  try {
    // 1. Obtener el directorio de la aplicación
    String appPath = Platform.resolvedExecutable;
    String appDir = p.dirname(appPath);

    // 2. Definir el nombre y la ruta final del script
    const String scriptFileName = 'StellarBlade_Chunk_Id_exe.py';
    final File targetFile = File(p.join(appDir, scriptFileName));

    // 3. Cargar el contenido del asset
    final String scriptContent =
        await rootBundle.loadString('assets/scripts/conflict_patcher.py');

    // 4. Escribir el archivo en el disco
    // Esto sobrescribirá el archivo si ya existe,
    // asegurando que la app siempre tenga la versión más reciente del script.
    await targetFile.writeAsString(scriptContent);

    print("Script de Patcher de Conflictos desplegado en: ${targetFile.path}");
  } catch (e) {
    print("Falló al desplegar el script de assets: $e");
    if (mounted) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: "Error de inicialización",
        description: "No se pudo crear el script del patcher: $e",
      );
    }
  }
  }*/

  Future<void> _checkCoreInstallations() async {
    if (_gameRootPath == null) return;
    final l10n = AppLocalizations.of(context)!;

    final win64Dir = Directory(
      p.join(_gameRootPath!, 'SB', 'Binaries', 'Win64'),
    );
    final metadataDir = Directory(p.join(win64Dir.path, '_manager_metadata'));

    final ue4ssManifest = File(p.join(metadataDir.path, 'ue4ss_manifest.json'));
    final cnsManifest = File(p.join(metadataDir.path, 'cns_manifest.json'));

 
    if (!await ue4ssManifest.exists()) {
      final ue4ssTriggerDir = Directory(
        p.join(win64Dir.path, 'ue4ss', 'Mods', 'ConsoleCommandsMod'),
      );
      if (await ue4ssTriggerDir.exists()) {
        print("Adopting existing UE4SS installation...");
        if (!await metadataDir.exists())
          await metadataDir.create(recursive: true);
        await ue4ssManifest.writeAsString(CoreInstallerService.defaultUe4ssManifestContent);
        if (mounted) {
          NotificationService.instance.show(
            context: context,
            type: NotificationType.info,
            title: l10n.ue4ssInstallationDetected,
          );
        }
      }
    }

    if (!await cnsManifest.exists()) {
      final cnsTriggerDir = Directory(
        p.join(win64Dir.path, 'ue4ss', 'Mods', 'DekCNS'),
      );
      if (await cnsTriggerDir.exists()) {
        print("Adopting existing CNS installation...");
        if (!await metadataDir.exists())
          await metadataDir.create(recursive: true);
        await cnsManifest.writeAsString(CoreInstallerService.defaultCnsManifestContent);
        if (mounted) {
          NotificationService.instance.show(
            context: context,
            type: NotificationType.info,
            title: l10n.cnsInstallationDetected,
          );
        }
      }
    }
    setState(() {
      _isUe4ssInstalled = ue4ssManifest.existsSync();
      _isCnsCoreInstalled = cnsManifest.existsSync();
    });
  }

  Future<void> _showInstallationPanel({
    List<File>? initialFiles,
    bool fromDownloads = false,
  }) async {
    // UN solo panel: si ya está abierto, lo que llegue se apila dentro.
    if (_installPanelOpen) return;
    if (_preparedMods.isNotEmpty) {
      _clearSelection();
    }

    final l10n = AppLocalizations.of(context)!;
    _installPanelOpen = true;
    _panelFromDownloads = fromDownloads;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: IosColors.background,
        barrierColor: const Color(0x66000000),
        constraints: const BoxConstraints(maxWidth: 640),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          side: BorderSide(color: Color(0x1FFFFFFF), width: 0.5),
        ),
        enableDrag: false,
        builder: (context) {
          var hasStarted = false;
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setPanelState) {
              // Cierra SOLO este panel (y solo si sigue abierto).
              void closePanel() {
                final route = ModalRoute.of(context);
                if (route != null && route.isActive) {
                  Navigator.of(context).pop();
                }
              }

              // Lo usa _processInstallQueue cuando llega una descarga nueva.
              _drainPanelQueue =
                  () => _drainInstallQueue(setPanelState, closePanel);

              if (!hasStarted) {
                hasStarted = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (initialFiles != null && initialFiles.isNotEmpty) {
                    final bool didInstall = await _processArchives(
                      initialFiles,
                      panelStateSetter: setPanelState,
                    );
                    if (didInstall &&
                        mounted &&
                        _preparedMods.isEmpty &&
                        !_hasPendingDownloads()) {
                      closePanel();
                      return;
                    }
                  }
                  // Descargas que ya estaban esperando en la cola.
                  await _drainInstallQueue(setPanelState, closePanel);
                });
              }
              return WillPopScope(
                onWillPop: () async {
                  if (_isExtracting || _isLoading || _isInstalling) {
                    return false;
                  }

                  if (_preparedMods.isNotEmpty) {
                    // Cerrar sin querer (clic fuera / X) perdería lo apilado.
                    final bool discard = await confirmDiscardInstallation(
                      context,
                      modCount: _modsToInstallPreviewMap.isNotEmpty
                          ? _modsToInstallPreviewMap.length
                          : _preparedMods.length,
                    );
                    if (!discard) return false;
                    await _cancelAndCleanInstallation();
                    setState(() {
                      _statusMessage =
                          AppLocalizations.of(context)!.statusSelectionCancelled;
                      _statusColor = Colors.white;
                    });
                  }
                  return true;
                },
                child: InstallationPanelContent(
                  l10n: l10n,
                  isDragging: _isDragging,
                  isExtracting: _isExtracting,
                  isInstalling: _isInstalling,
                  isLoading: _isLoading,
                  extractionProgress: _extractionProgress,
                  extractionStatus: _extractionStatus,
                  installationProgress: _installationProgress,
                  installationStatus: _installationStatus,
                  statusMessage: _statusMessage,
                  statusColor: _statusColor,
                  hasPreparedMods: _preparedMods.isNotEmpty,
                  modsToInstallPreviewMap: _modsToInstallPreviewMap,
                  downloadMode: _panelFromDownloads,
                  onFilesDropped: (files) async {
                    final bool didInstall = await _processArchives(
                      files,
                      panelStateSetter: setPanelState,
                    );
                    if (didInstall &&
                        mounted &&
                        _preparedMods.isEmpty &&
                        !_hasPendingDownloads()) {
                      closePanel();
                    } else {
                      setPanelState(() {});
                    }
                  },
                  onDragUpdate: (isDragging) =>
                      setPanelState(() => _isDragging = isDragging),
                  onPickArchive: () async {
                    final bool didInstall = await _pickArchive(
                      panelStateSetter: setPanelState,
                    );
                    if (didInstall &&
                        mounted &&
                        _preparedMods.isEmpty &&
                        !_hasPendingDownloads()) {
                      closePanel();
                    } else {
                      setPanelState(() {});
                    }
                  },
                  onInstallMod: () async {
                    await _installMod(panelStateSetter: setPanelState);
                    if (!mounted) return;
                    if (_hasPendingDownloads()) {
                      // Vienen más descargas: el panel sigue abierto y las
                      // irá apilando (en vez de cerrar y abrir otro).
                      await Future.delayed(const Duration(milliseconds: 400));
                      if (!mounted || !_installPanelOpen) return;
                      setPanelState(() {});
                      _drainInstallQueue(setPanelState, closePanel);
                    } else {
                      closePanel();
                    }
                  },
                  onCancelSelection: () =>
                      _clearSelection(panelStateSetter: setPanelState),
                ),
              );
            },
          );
        },
      );
    } finally {
      _installPanelOpen = false;
      _panelFromDownloads = false;
      _drainPanelQueue = null;
    }
    await _loadAllMods();
  }

  Future<void> _cancelAndCleanInstallation() async {
  _preparedMods.clear();
  _modsToInstallPreviewMap.clear();
  try {
    if (_tempExtractionDir != null && await _tempExtractionDir!.exists()) {
      // Usar el FileManagerService para evadir los bloqueos de Windows
      await FileManagerService.deleteDirectoryWithRetry(_tempExtractionDir!);
      _tempExtractionDir = null;
      print('Temporary extraction directory cleaned up successfully.');
    }
  } catch (e) {
    print('Failed to clean up temp directory during cancellation: $e');
  }
}

  Future<bool> _uninstallCoreComponent({required bool isUe4ss}) async {
    final l10n = AppLocalizations.of(context)!;
    final componentName = isUe4ss ? "UE4SS" : "CNS";

    if (isUe4ss && _isCnsCoreInstalled) {
      await SettingsDialogs.info(
        context: context,
        title: l10n.uninstallDependencyTitle,
        message: l10n.uninstallDependencyContent,
        okLabel: l10n.dialogActionUnderstood,
      );
      return false;
    }

    final confirm = await SettingsDialogs.confirm(
      context: context,
      title: l10n.dialogTitleUninstall(componentName),
      message: l10n.dialogContentUninstall(componentName),
      confirmLabel: l10n.dialogActionUninstall,
      destructive: true,
    );

    if (!confirm) return false;

    setState(() {
      _isLoading = true;
      _statusMessage = l10n.statusUninstalling(componentName);
    });

    try {
      if (_gameRootPath == null) throw Exception(l10n.errorGamePathNotFoundException);

      // Llama al nuevo servicio para hacer el trabajo sucio
      await CoreInstallerService.uninstallCoreComponent(
        isUe4ss: isUe4ss,
        gameRootPath: _gameRootPath!,
      );

      NotificationService.instance.show(
        context: context,
        type: NotificationType.success,
        title: l10n.snackBarUninstalled(componentName),
      );

      return true;
    } catch (e) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.errorUninstalling(componentName),
        description: e is InstallManifestNotFoundException
            ? l10n.errorManifestNotFound
            : e.toString(),
      );
      return false;
    } finally {
      await _checkCoreInstallations();
      await _readCNSData();
      setState(() {
        _isLoading = false;
        _statusMessage = "";
      });
    }
  }

  Future<void> _cleanUpOrphanedTempDirs() =>
      FileManagerService.cleanOrphanedTempDirs();

  Future<void> _showRepairedModInfoDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await SettingsDialogs.info(
      context: context,
      title: l10n.dialogTitleRepairedModWarning,
      message: l10n.dialogContentRepairedModWarning,
      okLabel: l10n.dialogActionClose,
    );
  }

  Future<void> _migrateModFolders() async {
    setState(() {
      _statusMessage = AppLocalizations.of(context)!.statusVerifyingMods;
      _isLoading = true;
    });

    Future<List<Map<String, dynamic>>> _scanForMigration(String path) async {
      final dir = Directory(path);
      if (!await dir.exists()) return [];

      final List<Map<String, dynamic>> tasks = [];
      List<FileSystemEntity> entities;
      try {
        entities = dir.listSync();
      } catch (e) {
        print("Error listing directory $path: $e");
        return [];
      }

      for (var entity in entities) {
        if (entity is Directory) {
          if (p.basename(entity.path) == '__MOD_BACKUPS__') continue;
          // Animations / Cosmetics del CNS principal: la app no las toca.
          if (await ModManagerService.isCoreCnsAddon(entity,
              inCnsFolder: _finalModsPath != null &&
                  p.equals(path, _finalModsPath!))) {
            continue;
          }

          final infoFile = File(p.join(entity.path, 'nexus_info.json'));
          if (await infoFile.exists()) {
            try {
              final content = await infoFile.readAsString();
              Map<String, dynamic> data = json.decode(content);

              if (data['customName'] == null && data['displayName'] != null) {
                final String newFolderName = data['displayName'].replaceAll(
                  RegExp(r'[\\/:*?"<>|]'),
                  '-',
                );
                tasks.add({
                  'oldPath': entity.path,
                  'newPath': p.join(entity.parent.path, newFolderName),
                  'jsonData': data,
                });
              }
            } catch (e) {
              print('Error scanning ${entity.path} for migration: $e');
            }
          }
        }
      }
      return tasks;
    }

    final List<Map<String, dynamic>> allTasks = [];
    if (_finalModsPath != null) {
      allTasks.addAll(await _scanForMigration(_finalModsPath!));
    }
    if (_gameRootPath != null) {
      final backupDirPath = p.join(
        _gameRootPath!,
        'SB',
        'Content',
        '__MOD_BACKUPS__',
      );
      allTasks.addAll(await _scanForMigration(backupDirPath));
    }

    if (allTasks.isNotEmpty) {
      print('Found ${allTasks.length} mods to migrate.');
      for (final task in allTasks) {
        try {
          final oldPath = task['oldPath'] as String;
          final newPath = task['newPath'] as String;
          final jsonData = task['jsonData'] as Map<String, dynamic>;

          Directory newDirHandle = Directory(newPath);
          if (oldPath != newPath) {
            if (await Directory(newPath).exists()) {
              print(
                'Migration conflict: Destination folder "$newPath" already exists. Skipping rename for "$oldPath".',
              );
              newDirHandle = Directory(oldPath);
            } else {
              await Directory(oldPath).rename(newPath);
              print('Renamed: $oldPath -> $newPath');
            }
          }

          final infoFile = File(p.join(newDirHandle.path, 'nexus_info.json'));
          jsonData['customName'] = jsonData['displayName'];
          jsonData['managerVersion'] = _appVersion;

          final encoder = JsonEncoder.withIndent('  ');
          await infoFile.writeAsString(encoder.convert(jsonData));
        } catch (e) {
          print('Migration failed for ${task['oldPath']}: $e');
        }
      }
      print('Migration complete.');
    }
  }

  Future<void> _loadModDatabase() async {
    try {
      final String content = await rootBundle.loadString('mod_database.json');
      final data = json.decode(content);
      if (data is Map<String, dynamic>) {
        setState(() {
          _modDatabase = data;
        });
        print('Local mod database loaded successfully.');
      }
    } catch (e) {
      print('Could not find or read mod_database.json, skipping: $e');
    }
  }

  Future<void> _loadLogicModIds() async {
    try {
      final String content = await rootBundle.loadString('logic_mod_ids.json');
      final List<dynamic> idList = json.decode(content);
      setState(() {
        _logicModIds = idList.cast<String>().toSet();
      });
      print(
        'Local logic mod ID database loaded successfully (${_logicModIds.length} IDs).',
      );
    } catch (e) {
      print('Could not find or read logic_mod_ids.json, skipping: $e');
    }
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString(AppPrefs.nexusApiKey);
    });
    // 1. Cargamos el último estado conocido rápido para que la UI no espere
    // (antes solo se guardaba 'is_premium'; se migra si aún no hay 'nexus_plan')
    final savedPlan = prefs.getString('nexus_plan');
    final NexusPlan lastPlan = savedPlan != null
        ? NexusPlan.fromName(savedPlan)
        : ((prefs.getBool('is_premium') ?? false)
            ? NexusPlan.premium
            : NexusPlan.member);
    DownloadManager.instance.userPlan = lastPlan;
    if (mounted) setState(() => _nexusPlan = lastPlan);

    // 2. Verificación silenciosa en segundo plano para actualizar el estado
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _refreshPremiumStatusSilently(_apiKey!);
    }
  }

  Future<void> _refreshPremiumStatusSilently(String key) async {
    final profileData = await NexusApiService.validateAndGetProfile(key);
    
    if (profileData != null && profileData['isValid'] == true) {
      final plan = profileData['plan'] as NexusPlan;
      
      // Actualizamos las preferencias locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nexus_plan', plan.name);
      
      // Inyectamos el nuevo estado (si cambió, notifyListeners actualizará la píldora)
      DownloadManager.instance.userPlan = plan;

      if (mounted) {
        setState(() {
          _nexusUserName = profileData['name'];
          _nexusPlan = plan;
          _nexusAvatarUrl = profileData['profileUrl'];
        });
      }
    }
  }

  Future<void> _saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppPrefs.nexusApiKey, apiKey);
    setState(() {
      _apiKey = apiKey;
    });
    SelfEndorseService.instance.configure(apiKey: apiKey, version: _appVersion);
  }

  Future<void> _loadSkippedVersions() async {
    final prefs = await SharedPreferences.getInstance();
    final skippedList = prefs.getStringList(AppPrefs.skippedVersions) ?? [];
    setState(() {
      _skippedVersions = {
        for (var e in skippedList) e.split(';')[0]: e.split(';')[1],
      };
    });
  }

  Future<void> _saveSkippedVersions() async {
    final prefs = await SharedPreferences.getInstance();
    final skippedList = _skippedVersions.entries
        .map((e) => '${e.key};${e.value}')
        .toList();
    await prefs.setStringList(AppPrefs.skippedVersions, skippedList);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final filterIndex =
        prefs.getInt(AppPrefs.filterMode) ?? ModFilter.all.index;
    final modTypeFilterIndex =
        prefs.getInt(AppPrefs.modTypeFilterMode) ?? ModTypeFilter.all.index;
    final sortIndex = prefs.getInt(AppPrefs.sortMode) ?? ModSort.date.index;
    final viewModeIndex =
        prefs.getInt(AppPrefs.viewMode) ?? ModListViewMode.grid.index;
    final showTags = prefs.getBool(AppPrefs.showModTypeTags) ?? true;
    final autoOutfits = prefs.getBool(AppPrefs.autoAssignOutfits) ?? true;

    setState(() {
      _currentFilter = ModFilter.values[filterIndex];
      _currentModTypeFilter = ModTypeFilter.values[modTypeFilterIndex];
      _currentSort = ModSort.values[sortIndex];
      _viewMode = ModListViewMode.values[viewModeIndex];
      _showModTypeTags = showTags;
      _autoAssignOutfits = autoOutfits;
    });
  }

  Future<void> _removeSkippedVersion(String nexusId) async {
    setState(() {
      _skippedVersions.remove(nexusId);
    });
    await _saveSkippedVersions();
    if (mounted) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.info,
        title: AppLocalizations.of(context)!.snackBarSkippedVersionRemoved,
      );
    }
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  /// Ruta de 7z.exe incluido junto a la app: <carpeta del .exe>\tools\7zip\7z.exe
  static String get _bundledSevenZipPath => p.join(
      p.dirname(Platform.resolvedExecutable), 'tools', '7zip', '7z.exe');

  Future<void> _find7zipPath() async {
    // La ruta manual de 7-Zip ya no existe en Ajustes: se limpia el valor
    // guardado por versiones anteriores para que no interfiera.
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(AppPrefs.sevenZipPath)) {
        await prefs.remove(AppPrefs.sevenZipPath);
      }
    } catch (_) {}

    // 1) 7-Zip incluido con la app (tools\7zip\7z.exe + 7z.dll).
    final bundled = _bundledSevenZipPath;
    if (await File(bundled).exists()) {
      setState(() => _7zipPath = bundled);
      return;
    }

    // 2) Respaldo: 7-Zip instalado en el sistema (solo si falta el incluido).
    const List<String> possiblePaths = [
      r'C:\Program Files\7-Zip\7z.exe',
      r'C:\Program Files (x86)\7-Zip\7z.exe',
    ];
    for (final path in possiblePaths) {
      if (await File(path).exists()) {
        setState(() => _7zipPath = path);
        return;
      }
    }
  }

  Future<void> _findGamePath() async {
    setState(() {
      _isLoading = true;
      if (mounted) {
        _statusMessage = AppLocalizations.of(context)!.statusSearchingGame;
      }
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedPath = prefs.getString(AppPrefs.gameRootPath);
      String? gamePath;

      if (savedPath != null && await Directory(savedPath).exists()) {
        final validationPath = p.join(savedPath, 'SB', 'Content', 'Paks');
        if (await Directory(validationPath).exists()) {
          gamePath = savedPath;
        }
      }

      gamePath ??= await GameLocatorService.findSteamInstallation();

      // Resolver la ruta de %LOCALAPPDATA% de Windows de forma segura
      String? localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData == null && Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          localAppData = p.join(userProfile, 'AppData', 'Local');
        }
      }

      if (gamePath != null && await Directory(gamePath).exists() && localAppData != null) {
        // 1. Rutas estándar del juego
        final cnsModPath = p.join(gamePath, 'SB', 'Content', 'Paks', '~mods', 'CustomNanosuitSystem');
        final genericModPath = p.join(gamePath, 'SB', 'Content', 'Paks', '~mods');
        final moviesPath = p.join(gamePath, 'SB', 'Content', 'Movies');
        final logicModsPath = p.join(gamePath, 'SB', 'Content', 'Paks', 'LogicMods');
        final ue4ssModsPath = p.join(gamePath, 'SB', 'Binaries', 'Win64', 'ue4ss', 'Mods');
        
        // [NUEVO] 2. Rutas de Datos de Usuario e Inyecciones de Contenido
        String savesPath = p.join(localAppData, 'SB', 'Saved', 'SaveGames');
        final savesBaseDir = Directory(savesPath);
        
        // Emular la lógica de Vortex: buscar la carpeta con el ID de usuario
        if (await savesBaseDir.exists()) {
          try {
            final entities = await savesBaseDir.list().toList();
            for (var entity in entities) {
              if (entity is Directory) {
                // Tomamos la primera subcarpeta (ej: 76561198388357018)
                savesPath = entity.path;
                break;
              }
            }
          } catch (e) {
            print("Error al leer la subcarpeta de SaveGames: $e");
          }
        }

        final configPath = p.join(localAppData, 'SB', 'Saved', 'Config', 'WindowsNoEditor');
        final splashPath = p.join(gamePath, 'SB', 'Content', 'Splash');

        // [NUEVO] 3. Rutas de Respaldos de Seguridad Reversibles
        final moviesBackupPath = p.join(gamePath, 'SB', 'Content', '__MOVIES_ORIGINALS__');
        final savesBackupPath = p.join(gamePath, 'SB', 'Content', '__SAVES_ORIGINALS__');
        final configBackupPath = p.join(gamePath, 'SB', 'Content', '__CONFIG_ORIGINALS__');
        final splashBackupPath = p.join(gamePath, 'SB', 'Content', '__SPLASH_ORIGINALS__');

        // Asegurar la existencia de directorios base y nuevas rutas
        await Directory(cnsModPath).create(recursive: true);
        await Directory(genericModPath).create(recursive: true);
        await Directory(moviesPath).create(recursive: true);
        await Directory(logicModsPath).create(recursive: true);
        await Directory(ue4ssModsPath).create(recursive: true);
        
        // Crear las nuevas carpetas físicas en el sistema si no existen
        await Directory(savesPath).create(recursive: true);
        await Directory(configPath).create(recursive: true);
        await Directory(splashPath).create(recursive: true);
        await Directory(moviesBackupPath).create(recursive: true);
        await Directory(savesBackupPath).create(recursive: true);
        await Directory(configBackupPath).create(recursive: true);
        await Directory(splashBackupPath).create(recursive: true);

        setState(() {
          _gameRootPath = gamePath;
          _finalModsPath = cnsModPath;
          _genericModsPath = genericModPath;
          _moviesPath = moviesPath;
          _moviesBackupPath = moviesBackupPath;
          _logicModsPath = logicModsPath;
          _ue4ssModsPath = ue4ssModsPath;
          
          // Asignar nuevos estados de rutas
          _savesPath = savesPath;
          _configPath = configPath;
          _splashPath = splashPath;
          _savesBackupPath = savesBackupPath;
          _configBackupPath = configBackupPath;
          _splashBackupPath = splashBackupPath;

          if (mounted) {
            _statusMessage = AppLocalizations.of(context)!.statusGamePathFound;
          }
        });
      } else {
        _resetCustomPaths();
        setState(() {
          if (mounted) {
            _statusMessage = AppLocalizations.of(context)!.statusGamePathNotFound;
          }
          _statusColor = Colors.orangeAccent;
        });
      }
    } catch (e) {
      _resetCustomPaths();
      setState(() {
        if (mounted) {
          _statusMessage = AppLocalizations.of(context)!.statusErrorFindingGame(e.toString());
        }
        _statusColor = Colors.redAccent;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Método auxiliar para limpiar estados en caso de error o desconfiguración
  void _resetCustomPaths() {
    _gameRootPath = null;
    _finalModsPath = null;
    _genericModsPath = null;
    _moviesPath = null;
    _moviesBackupPath = null;
    _logicModsPath = null;
    _ue4ssModsPath = null;
    _savesPath = null;
    _configPath = null;
    _splashPath = null;
    _savesBackupPath = null;
    _configBackupPath = null;
    _splashBackupPath = null;
  }

  Future<String?> _readCNSData() async {
    if (_gameRootPath == null) {
      setState(() {
        _cnsVersion = null;
        _cnsNexusId = null;
      });
      return null;
    }

    setState(() {
      _cnsVersion = null;
      _cnsNexusId = null;
    });

    String? newVersion;

    try {
      final infoFile = File(
        p.join(
          _gameRootPath!,
          'SB',
          'Binaries',
          'Win64',
          'ue4ss',
          'nexus_info.json',
        ),
      );
      if (await infoFile.exists()) {
        final content = await infoFile.readAsString();
        final data = json.decode(content);
        setState(() {
          _cnsNexusId = data['nexusId'];
          _cnsVersion = data['installedVersion'];
        });
        newVersion = data['installedVersion'];
        return newVersion;
      }
    } catch (e) {
      print('Error reading CNS nexus_info.json: $e');
    }

    try {
      final luaFile = File(
        p.join(
          _gameRootPath!,
          'SB',
          'Binaries',
          'Win64',
          'ue4ss',
          'Mods',
          'DekCNS',
          'Scripts',
          'main.lua',
        ),
      );
      if (await luaFile.exists()) {
        final content = await luaFile.readAsString();
        final regex = RegExp(r'local CNS_Version = "(.+)"');
        final match = regex.firstMatch(content);
        if (match != null && match.group(1) != null) {
          setState(() {
            _cnsVersion = match.group(1);
          });
          newVersion = match.group(1);
        }
      }
    } catch (e) {
      print('Error reading CNS version from LUA: $e');
    }

    return newVersion;
  }

  Future<String?> _selectGamePathManually() async {
    try {
      String? result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: AppLocalizations.of(context)!.dialogTitleSelectGameFolder,
      );
      if (result != null) {
        final validationPath = p.join(result, 'SB', 'Content', 'Paks');
        if (await Directory(validationPath).exists()) {
          final modPath = p.join(
            result,
            'SB',
            'Content',
            'Paks',
            '~mods',
            'CustomNanosuitSystem',
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppPrefs.gameRootPath, result);
          setState(() {
            _gameRootPath = result;
            _finalModsPath = modPath;
          });
          if (mounted) {
            NotificationService.instance.show(
              context: context,
              type: NotificationType.success,
              title: AppLocalizations.of(context)!.snackBarGamePathSaved,
            );
          }
          await _initialize();
          return result;
        } else {
          if (mounted) {
            NotificationService.instance.show(
              context: context,
              type: NotificationType.error,
              title: AppLocalizations.of(context)!.snackBarGamePathInvalid,
            );
          }
          setState(() {
            _statusMessage =
                AppLocalizations.of(context)!.errorInvalidFolderRetry;
            _statusColor = Colors.redAccent;
          });
        }
      }
    } catch (e) {
      setState(() => _statusMessage = AppLocalizations.of(context)!.errorSelectingFolderDynamic(e.toString()));
    }
    return null;
  }

  Future<void> _runMetadataUpdateIfNeeded() async {
    if (_finalModsPath == null) return;
    // Sin API key no se puede migrar nada: se evita mostrar el progreso en
    // vano y se reintenta cuando el usuario la configure.
    if (_apiKey == null || _apiKey!.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> modsToUpdate = [];
    final List<String> modPaths = [];

    // Mods activos (CNS, genéricos y logic mods) y desactivados (backups).
    final List<String?> roots = [
      _finalModsPath,
      _genericModsPath,
      _logicModsPath,
      if (_gameRootPath != null)
        p.join(_gameRootPath!, 'SB', 'Content', '__MOD_BACKUPS__'),
    ];
    for (final root in roots) {
      if (root == null) continue;
      final dir = Directory(root);
      if (!await dir.exists()) continue;
      await for (var entity in dir.list()) {
        if (entity is! Directory) continue;
        // Animations / Cosmetics del CNS principal: se ignoran.
        if (await ModManagerService.isCoreCnsAddon(entity,
            inCnsFolder: p.equals(root, _finalModsPath ?? ''))) {
          continue;
        }
        modPaths.add(entity.path);
      }
    }

    for (final modPath in modPaths) {
      if (p.basename(modPath) == '__MOD_BACKUPS__') continue;
      final infoFile = File(p.join(modPath, 'nexus_info.json'));
      if (await infoFile.exists()) {
        try {
          final content = await infoFile.readAsString();
          Map<String, dynamic> data = json.decode(content);
          final String? nexusIdForCheck = data['nexusId']?.toString();

          final bool needsNexusMigration =
              ModMetadataMigrator.needsMigration(data, _appVersion) &&
                  ModMetadataMigrator.canAttempt(modPath);
          // Trajes de mods genéricos / de reemplazo aún sin asignar (local).
          final bool needsOutfits = _autoAssignOutfits &&
              ModMetadataMigrator.needsOutfitScan(data);
          final bool needsMigration = needsNexusMigration || needsOutfits;
          // Mods instalados antes de la galería completa: se les baja ahora.
          final bool needsGallery = ModManagerService.needsGalleryCache(data) &&
              ModManagerService.canCacheGallery(modPath);

          if (needsMigration || needsGallery) {
            modsToUpdate.add({
              'path': modPath,
              'nexusId': nexusIdForCheck,
              'displayName': data['displayName'] ?? p.basename(modPath),
              'needsMigration': needsMigration,
            });
          }
        } catch (e) {
          print(
            'No se pudo analizar nexus_info.json para la comprobación de actualización de metadatos en $modPath: $e',
          );
        }
      }
    }

    if (modsToUpdate.isEmpty) return;

    // La barra NO se muestra de inmediato: la mayoría de arranques solo
    // comprueba mods que ya están al día o que no se pueden migrar (sin red,
    // mod retirado de Nexus...) y terminan en milisegundos. Solo si el
    // trabajo real se alarga se revela la barra, así no hay parpadeo.
    const revealDelay = Duration(milliseconds: 900);
    final revealTimer = Timer(revealDelay, () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isUpdatingMetadata = true;
      });
    });

    // Actualiza el estado; solo reconstruye la UI si la barra ya es visible.
    void updateProgress(VoidCallback change) {
      if (_isUpdatingMetadata && mounted) {
        setState(change);
      } else {
        change();
      }
    }

    _metadataUpdateProgress = 0.0;
    _metadataUpdateStatus = '';

    try {
      for (int i = 0; i < modsToUpdate.length; i++) {
        final modData = modsToUpdate[i];
        final modDirectory = Directory(modData['path']);
        final nexusId = modData['nexusId'];
        final displayName = modData['displayName'];
        final infoFile = File(p.join(modDirectory.path, 'nexus_info.json'));

        updateProgress(() {
          _metadataUpdateProgress = (i + 1) / modsToUpdate.length;
          _metadataUpdateStatus = l10n.statusUpdatingMetadata(
            displayName,
            i + 1,
            modsToUpdate.length,
          );
        });

        try {
          Map<String, dynamic> data = {};
          if (await infoFile.exists()) {
            try {
              final content = await infoFile.readAsString();
              data = json.decode(content);
            } catch (e) {
              print(l10n.logFixingCorruptedJson(displayName));
            }
          }

          // Rellena los metadatos que faltan en mods antiguos (resumen,
          // autor, nombre del mod, edición, archivo de Nexus...).
          final migrated = modData['needsMigration'] == true
              ? await ModMetadataMigrator.migrate(
                  modDirectory: modDirectory,
                  data: data,
                  appVersion: _appVersion,
                  apiKey: _apiKey,
                  assignOutfits: _autoAssignOutfits,
                )
              : false;
          if (migrated) {
            // Portada y galería completa (cacheNexusThumbnail baja ambas).
            await ModManagerService.cacheNexusThumbnail(
              apiKey: _apiKey,
              modDirectory: modDirectory,
              nexusId: nexusId,
            );
            if (await infoFile.exists()) {
              data = json.decode(await infoFile.readAsString());
            }
          } else if (nexusId != null) {
            // Sin migración pendiente (o no posible): solo la galería.
            await ModManagerService.cacheNexusGallery(
              modDirectory: modDirectory,
              nexusId: nexusId.toString(),
              apiKey: _apiKey,
            );
          }

          final String? customCoverPath = data['customCoverPath'];
          if (customCoverPath != null && customCoverPath.isNotEmpty) {
            updateProgress(() {
              _metadataUpdateStatus = l10n.statusUpdatingMetadata(
                displayName,
                i + 1,
                modsToUpdate.length,
              ) + " (${l10n.processingCover})";
            });

            final String sourcePath = p.join(modDirectory.path, customCoverPath);
            final String cacheKey = p.basename(modDirectory.path) + customCoverPath;

            await _thumbnailService.getThumbnail(
              cacheKey,
              sourcePath,
              isLocalFile: true,
            );
          }
        } catch (e) {
          print(l10n.logMetadataUpdateFailed(displayName, e.toString()));
        }
      }
    } finally {
      revealTimer.cancel();
      if (mounted) {
        setState(() {
          _isUpdatingMetadata = false;
          _metadataUpdateStatus = '';
        });
      }
    }
  }

  bool _refreshingMetadata = false;

  /// Botón "Actualizar metadatos" de Ajustes: quita las marcas de "no
  /// reintentar" / "ya analizado" de todos los mods y repite la actualización
  /// (datos de Nexus, galería y trajes asignados automáticamente).
  Future<void> _refreshAllMetadata() async {
    if (_refreshingMetadata || _finalModsPath == null) return;
    final l10n = AppLocalizations.of(context)!;
    if (_apiKey == null || _apiKey!.isEmpty) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.info,
        title: l10n.metadataRefreshNoApiKey,
      );
      return;
    }

    _refreshingMetadata = true;
    try {
      final List<String?> roots = [
        _finalModsPath,
        _genericModsPath,
        _logicModsPath,
        if (_gameRootPath != null)
          p.join(_gameRootPath!, 'SB', 'Content', '__MOD_BACKUPS__'),
      ];
      for (final root in roots) {
        if (root == null) continue;
        final dir = Directory(root);
        if (!await dir.exists()) continue;
        await for (final entity in dir.list()) {
          if (entity is! Directory) continue;
          if (p.basename(entity.path) == '__MOD_BACKUPS__') continue;
          final infoFile = File(p.join(entity.path, 'nexus_info.json'));
          if (!await infoFile.exists()) continue;
          try {
            final data =
                Map<String, dynamic>.from(json.decode(await infoFile.readAsString()));
            if (ModMetadataMigrator.resetForRefresh(data)) {
              await infoFile
                  .writeAsString(JsonEncoder.withIndent('  ').convert(data));
            }
          } catch (e) {
            print('No se pudo preparar ${entity.path} para actualizar metadatos: $e');
          }
        }
      }

      ModMetadataMigrator.clearSessionFailures();
      ModManagerService.clearGalleryFailuresThisSession();
      ModMetadataMigrator.forceRefresh = true;
      await _runMetadataUpdateIfNeeded();
      await _loadAllMods(clearHighlight: false);

      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.success,
          title: AppLocalizations.of(context)!.metadataRefreshDone,
        );
      }
    } catch (e) {
      print('Error al actualizar metadatos: $e');
    } finally {
      ModMetadataMigrator.forceRefresh = false;
      _refreshingMetadata = false;
    }
  }

  Future<void> _loadAllMods({bool clearHighlight = true}) async {
    if (_finalModsPath == null) return;
    setState(() {
      _isLoading = true;
      if (clearHighlight) {
        _lastInstalledModNames.clear();
      }
    });

    try {
      final mods = await ModManagerService.loadMods(
        gameRootPath: _gameRootPath,
        finalModsPath: _finalModsPath!,
        genericModsPath: _genericModsPath!,
        logicModsPath: _logicModsPath!,
        appVersion: _appVersion,
        apiKey: _apiKey,
        autoAssignOutfits: _autoAssignOutfits,
      );

      setState(() {
        _allMods = mods;
        if (clearHighlight && mounted) {
          final totalEnabled = _allMods.where((m) => m.isEnabled).length;
          final totalDisabled = _allMods.length - totalEnabled;
          _statusMessage = AppLocalizations.of(context)!.statusModsFound(totalDisabled, totalEnabled);
          _statusColor = Colors.white;
        }
      });

      // Mods de películas marcados como activos que ya no están aplicados en el juego.
      await _reconcileMovieMods();

      // Si la migración acaba de asignar trajes, desactiva los mods que
      // quedaron compartiendo traje con otro mod activo.
      await _disableOutfitConflictsFromMigration();
    } catch (e) {
      setState(() {
        if (mounted) {
          _statusMessage = AppLocalizations.of(context)!.statusErrorReadingMods(e.toString());
        }
        _statusColor = Colors.redAccent;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _resolvingOutfitConflicts = false;

  /// Tras la migración de metadatos (que asigna trajes a mods que no tenían),
  /// varios mods activos pueden acabar reemplazando el mismo traje: solo uno
  /// puede ganar en el juego. Aquí se desactivan los sobrantes.
  ///
  /// Reglas:
  ///  - Solo se desactivan mods a los que la migración acaba de asignar trajes;
  ///    un mod que ya tenía trajes (elección del usuario) nunca se toca.
  ///  - Si un traje ya lo usa un mod que no es nuevo, ese mod manda.
  ///  - Entre mods nuevos que chocan entre sí se queda el instalado más
  ///    recientemente (el resto se desactiva).
  ///  - Los desactivados se mueven a __MOD_BACKUPS__ (se pueden reactivar; al
  ///    hacerlo se muestra el diálogo de conflicto de siempre).
  Future<void> _disableOutfitConflictsFromMigration() async {
    final fresh = ModMetadataMigrator.takeNewlyAssignedOutfitMods();
    if (fresh.isEmpty || _resolvingOutfitConflicts || !mounted) return;
    _resolvingOutfitConflicts = true;
    try {
      bool isNew(ModInfo m) => fresh.contains(p.normalize(m.directory.path));

      final enabled = _allMods
          .where((m) => m.isEnabled && (m.replacesOutfits?.isNotEmpty ?? false))
          .toList();

      // Trajes ya ocupados por mods que no acaban de migrarse.
      final claimed = <String>{
        for (final m in enabled.where((m) => !isNew(m))) ...m.replacesOutfits!,
      };

      // Los nuevos, del más reciente al más antiguo.
      final candidates = enabled.where(isNew).toList()
        ..sort((a, b) => (b.installDate ?? b.lastModified)
            .compareTo(a.installDate ?? a.lastModified));

      final toDisable = <ModInfo>[];
      for (final m in candidates) {
        final outfits = m.replacesOutfits!;
        if (outfits.any(claimed.contains)) {
          toDisable.add(m);
        } else {
          claimed.addAll(outfits);
        }
      }
      if (toDisable.isEmpty) return;

      final disabledNames = <String>[];
      for (final m in toDisable) {
        print('[OutfitConflict] Desactivando ${m.customName}: comparte traje '
            '${m.replacesOutfits} con otro mod activo.');
        if (await _disableMod(m)) disabledNames.add(m.customName);
      }

      if (disabledNames.isNotEmpty && mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.info,
          title: AppLocalizations.of(context)!
              .outfitConflictAutoDisabled(disabledNames.length),
          description: disabledNames.join(', '),
        );
      }
    } finally {
      _resolvingOutfitConflicts = false;
    }
  }

  Future<void> _showSelfHealConfirmationDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await SettingsDialogs.confirm(
      context: context,
      title: l10n.dialogTitleRepairMods,
      message: l10n.dialogContentRepairMods,
      confirmLabel: l10n.dialogActionRunRepair,
    );
    if (confirm) _runSelfHealing();
  }

  Future<void> _runSelfHealing() async {
    final l10n = AppLocalizations.of(context)!;
    NotificationService.instance.show(
      context: context,
      type: NotificationType.info,
      title: l10n.snackBarRepairStarted,
    );

    setState(() => _isLoading = true);

    int repairedCount = await ModManagerService.runSelfHealing(
      allMods: _allMods,
      modDatabase: _modDatabase,
      apiKey: _apiKey,
    );

    if (mounted) {
      if (repairedCount > 0) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.success,
          title: l10n.snackBarRepairComplete(repairedCount),
        );
      } else {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.info,
          title: l10n.snackBarRepairNoMods,
        );
      }
    }

    await _loadAllMods();
    setState(() => _isLoading = false);
  }

  /// Ejecuta el Patcher de Conflictos nativo de Dart.
  Future<void> _runConflictPatcher() async {
    final l10n = AppLocalizations.of(context)!;

    if (_genericModsPath == null ||
        !await Directory(_genericModsPath!).exists()) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.errorDialogTitle,
        description: l10n.statusGamePathNotFound,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = l10n.statusRunningPatcher;
    });

    List<LogEntry> fullLog = []; // Para el botón "Mostrar Log Completo"

    try {
      // 1. Crear una instancia del servicio y ejecutar el parcheo
      final PatcherService patcher = PatcherService(l10n);
      // Carpetas "reservadas": juego base (Paks) y LogicMods (núcleo CNS).
      // Sus Container IDs cuentan como ocupados y nunca se modifican.
      final String paksDir = p.dirname(_genericModsPath!);
      final PatcherResult result = await patcher.patchConflictsInDirectory(
        _genericModsPath!,
        reservedDirectories: [paksDir, p.join(paksDir, 'LogicMods')],
      );

      fullLog = result.logEntries; // Guardamos el log completo

      // 2. Procesar los resultados para crear un resumen simple
      final StringBuffer summary = StringBuffer();

      // --- Resumen de Container ID (Correcciones de Crashes) ---
      if (result.containerIdsFixed > 0) {
        summary.writeln(
          l10n.summarySuccessContainerIds(result.containerIdsFixed),
        );
      } else {
        summary.writeln(
          l10n.summaryNoContainerIdConflicts,
        );
      }
      if (result.unresolvedContainerConflicts.isNotEmpty) {
        summary.writeln(
          l10n.summaryUnfixableContainerIds(
            result.unresolvedContainerConflicts.length,
          ),
        );
        for (final c in result.unresolvedContainerConflicts) {
          summary.writeln('    ${c.mod}  ↔  ${c.conflictsWith}');
        }
      }

      // Los grupos de mods con Package ID compartido ("Warning! Found N groups
      // of mods that cannot coexist") ya no se muestran en el resumen: no
      // aportan nada accionable. El recuento sigue en el log completo.

      // 3. Mostrar el nuevo diálogo de resumen
      await showIosDialog<void>(
        context: context,
        builder: (summaryContext) => IosDialogShell(
          title: l10n.patcherSummaryDialogTitle,
          width: 460,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  summary.toString(),
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: IosColors.label,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IosDialogButton(
              label: l10n.dialogActionClose,
              onPressed: () => Navigator.of(summaryContext).pop(),
            ),
            // El botón "MOSTRAR LOG COMPLETO"
            IosDialogButton(
              label: l10n.dialogActionShowFullLog,
              bold: true,
              onPressed: () {
                Navigator.of(summaryContext).pop(); // Cierra el resumen
                _showFullPatcherLog(fullLog); // Abre el log completo
              },
            ),
          ],
        ),
      );
    } catch (e) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.errorDialogTitle,
        description: e.toString(),
      );
      // Si falla, muestra el log que se haya acumulado
      if (fullLog.isEmpty) {
        // Si el log está vacío pero hubo un error, crea una entrada de error
        _showFullPatcherLog([LogEntry(e.toString(), LogEntryType.error)]);
      } else {
        // Si ya había log, muéstralo
        _showFullPatcherLog(fullLog);
      }
    } finally {
      setState(() {
        _isLoading = false;
        _statusMessage = '';
      });
    }
  }

  /// Revierte los parches del Patcher de Conflictos (restaura los *.cnsbak).
  Future<void> _revertConflictPatches() async {
    final l10n = AppLocalizations.of(context)!;

    if (_genericModsPath == null ||
        !await Directory(_genericModsPath!).exists()) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.errorDialogTitle,
        description: l10n.statusGamePathNotFound,
      );
      return;
    }

    final bool? confirmed = await showIosDialog<bool>(
      context: context,
      builder: (ctx) => IosDialogShell(
        title: l10n.revertPatchesConfirmTitle,
        message: l10n.revertPatchesConfirmMessage,
        actions: [
          IosDialogButton(
            label: l10n.dialogActionCancel,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          IosDialogButton(
            label: l10n.revertPatchesAction,
            bold: true,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final int restored =
          await PatcherService.restoreOriginals(_genericModsPath!);
      if (!mounted) return;
      NotificationService.instance.show(
        context: context,
        type: restored > 0 ? NotificationType.success : NotificationType.info,
        title: restored > 0
            ? l10n.revertPatchesDone(restored)
            : l10n.revertPatchesNothing,
      );
      await _loadAllMods();
    } catch (e) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.errorDialogTitle,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ++ AÑADE ESTA NUEVA FUNCIÓN DE AYUDA (para no repetir código) ++
  void _showFullPatcherLog(List<LogEntry> logEntries) {
    final l10n = AppLocalizations.of(context)!;

    // Función de ayuda para mapear el tipo a un color (colores de sistema iOS)
    Color _getLogColor(LogEntryType type) {
      switch (type) {
        case LogEntryType.success:
          return IosColors.green;
        case LogEntryType.error:
          return IosColors.red;
        case LogEntryType.info:
          return IosColors.blue;
        case LogEntryType.normal:
        default:
          return IosColors.label;
      }
    }

    showIosDialog<void>(
      context: context,
      builder: (logContext) => IosDialogShell(
        title: l10n.fullLogDialogTitle,
        width: 720,
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              // SelectableText.rich para los TextSpans coloreados
              child: SelectableText.rich(
                TextSpan(
                  style: const TextStyle(
                    color: IosColors.label,
                    fontFamily: 'Consolas', // monoespaciada, mejor para logs
                    fontSize: 12,
                    height: 1.4,
                  ),
                  children: logEntries.map((entry) {
                    return TextSpan(
                      text: "${entry.text}\n",
                      style: TextStyle(color: _getLogColor(entry.type)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        actions: [
          IosDialogButton(
            label: l10n.dialogActionClose,
            bold: true,
            onPressed: () => Navigator.of(logContext).pop(),
          ),
        ],
      ),
    );
  }

  Future<bool> _pickArchive({StateSetter? panelStateSetter}) async {
    // <-- AÑADE EL PARÁMETRO AQUÍ
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'rar', '7z'],
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final files = result.paths.map((path) => File(path!)).toList();
        // ++ PASA EL PARÁMETRO A LA SIGUIENTE FUNCIÓN ++
        return await _processArchives(
          files,
          panelStateSetter: panelStateSetter,
        );
      }
    } catch (e) {
      // Usa el setter si está disponible, si no, usa setState
      final updateState = panelStateSetter ?? setState;
      updateState(
        () => _statusMessage = AppLocalizations.of(
          context,
        )!.statusError(e.toString()),
      );
    }
    return false;
  }
  
  Future<bool> _show7zipRequiredDialog() {
    return InstallDialogs.sevenZipRequired(
      context,
      onVerify: () async {
        await _find7zipPath();
        return _7zipPath != null;
      },
    );
  }

  Future<bool> _promptAndInstallUE4SS(Directory sourceDir) async {
    final l10n = AppLocalizations.of(context)!;

    if (_isUe4ssInstalled) {
      final reinstall = await SettingsDialogs.confirm(
        context: context,
        title: l10n.dialogTitleUE4SSReinstall,
        message: l10n.dialogContentUE4SSReinstall,
        confirmLabel: l10n.dialogActionReinstall,
      );
      if (reinstall != true) return false;
    } else {
      final confirm = await SettingsDialogs.confirm(
        context: context,
        title: l10n.dialogTitleUE4SS,
        message: l10n.dialogContentUE4SS,
        confirmLabel: l10n.dialogActionInstallTool,
      );
      if (confirm != true) {
        setState(() => _statusMessage = l10n.statusUE4SSInstallCancelled);
        return false;
      }
    }

    setState(() {
      _isLoading = true;
      _statusMessage = l10n.statusInstallingUE4SS;
    });

    try {
      if (_gameRootPath == null) throw Exception(l10n.errorGamePathUndefined);

      if (_gameRootPath == null) throw Exception(l10n.errorGamePathUndefined);

   // Llama al nuevo servicio
   await CoreInstallerService.installUE4SS(
     sourceDir: sourceDir,
     gameRootPath: _gameRootPath!,
   );

      NotificationService.instance.show(
        context: context,
        type: NotificationType.success,
        title: l10n.snackBarUE4SSInstalled,
      );

      setState(() {
        _statusMessage = l10n.statusUE4SSInstallComplete;
        _isUe4ssInstalled = true;
        _clearSelection();
      });
      return true;
    } catch (e) {
      setState(() {
        _statusMessage = l10n.statusError(e.toString());
        _statusColor = Colors.redAccent;
      });
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _processArchives(
    List<File> archives, {
    StateSetter? panelStateSetter,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final updateState = panelStateSetter ?? setState;
    updateState(() {
      _isExtracting = true;
      _extractionProgress = 0.0;
      _extractionStatus = '';
    });

    try {
      // APILAR: ya no se borra lo extraído antes. Cada tanda va a su propia
      // subcarpeta del directorio temporal y sus mods se SUMAN a la lista.
      if (_tempExtractionDir == null || !await _tempExtractionDir!.exists()) {
        _tempExtractionDir =
            Directory.systemTemp.createTempSync('mod_manager_');
      }
      final Directory stackRoot = _tempExtractionDir!;
      final Directory batchDir = Directory(
        p.join(stackRoot.path, 'batch_${_extractionBatch++}'),
      );
      await batchDir.create(recursive: true);

      final result = await ArchiveService.processArchives(
        archives: archives,
        tempExtractionDir: batchDir,
        sevenZipPath: _7zipPath,
        apiKey: _apiKey,
        logicModIds: _logicModIds,
        l10n: l10n,
        onProgress: (progress, status) {
          updateState(() {
            _extractionProgress = progress;
            _extractionStatus = status;
          });
        },
      );

      _preparedUE4SS = result.preparedUE4SS;

      // Paquetes del núcleo (UE4SS / actualización de CNS): se instalan solos.
      if (result.cnsUpdateDir != null || _preparedUE4SS != null) {
        Future<bool> runCore() => result.cnsUpdateDir != null
            ? _promptAndUpdateCNS(result.cnsUpdateDir!)
            : _promptAndInstallUE4SS(_preparedUE4SS!.sourceDir);

        if (_preparedMods.isEmpty) {
          return await runCore();
        }

        // Hay mods apilados: se protegen, porque instalar el núcleo limpia
        // la selección y el directorio temporal.
        final stashedMods = List<PreparedMod>.of(_preparedMods);
        final stashedPreview =
            Map<String, List<String>>.of(_modsToInstallPreviewMap);
        _preparedMods.clear();
        _tempExtractionDir = batchDir; // la limpieza solo borra esta tanda
        bool ok = false;
        try {
          ok = await runCore();
          if (ok) {
            // La limpieza del núcleo no se espera dentro de _promptAnd...:
            // aguardamos a que termine antes de restaurar lo apilado.
            for (int i = 0;
                i < 250 && _tempExtractionDir != null && batchDir.existsSync();
                i++) {
              await Future.delayed(const Duration(milliseconds: 40));
            }
          }
        } finally {
          _tempExtractionDir = stackRoot;
          _preparedMods
            ..clear()
            ..addAll(stashedMods);
          _modsToInstallPreviewMap = stashedPreview;
        }
        return ok;
      }

      final List<PreparedMod> newMods =
          List<PreparedMod>.of(result.preparedMods);
      final int previousCount = _preparedMods.length;
      _preparedMods.addAll(newMods);

      if (newMods.isEmpty && previousCount > 0) {
        // El archivo nuevo no trae nada compatible: se avisa y se conserva
        // lo que ya estaba apilado.
        updateState(() {
          _statusMessage = l10n.errorNoCompatibleFilesInArchive;
          _statusColor = Colors.orangeAccent;
        });
        return false;
      }

      // Si el archivo trae varias variantes que reemplazan lo mismo, deja que
      // el usuario elija cuál instalar (si cancela, se descarta lo NUEVO).
      final bool proceed = await _resolveVariantConflicts();
      if (!proceed) {
        if (previousCount == 0) {
          await _clearSelection(panelStateSetter: panelStateSetter);
          return false;
        }
        _preparedMods.removeWhere(newMods.contains);
      }
      await _prepareInstallationPreview(panelStateSetter: panelStateSetter);
      return false;
    } catch (e) {
      if (e.toString().contains('7ZIP_MISSING')) {
        final installed = await _show7zipRequiredDialog();
        if (!installed) {
          updateState(() {
            _statusMessage = l10n.statusError(l10n.error7zipRequired);
            _statusColor = Colors.redAccent;
          });
        }
        return false;
      }

      updateState(() {
        _statusMessage = l10n.statusError(e.toString());
        _statusColor = Colors.redAccent;
      });
      return false;
    } finally {
      updateState(() {
        _isExtracting = false;
      });
    }
  }

  /// Detecta variantes del mismo archivo que reemplazan lo mismo y pregunta cuál
  /// instalar. Devuelve false si el usuario cancela.
  Future<bool> _resolveVariantConflicts() async {
    try {
      final groups = await VariantConflictService.findGroups(
        _preparedMods,
        detectOutfits: _autoAssignOutfits,
      );
      for (int i = 0; i < groups.length; i++) {
        if (!mounted) return false;
        final keep = await VariantChoiceDialog.show(
          context,
          group: groups[i],
          position: i + 1,
          total: groups.length,
        );
        if (keep == null) return false;
        VariantConflictService.applyChoice(_preparedMods, groups[i], keep);
      }
      // Recalcula nombres/flags: evita que dos variantes compartan carpeta.
      VariantConflictService.finalize(_preparedMods);
    } catch (e) {
      print('[VariantConflict] Error al comprobar variantes: $e');
    }
    return true;
  }

  Future<void> _prepareInstallationPreview({
    StateSetter? panelStateSetter,
  }) async {
    // ++ INICIO DE LA MODIFICACIÓN ++
    AppLocalizations? l10n;
    if (mounted) {
      l10n = AppLocalizations.of(context);
    }

    if (_preparedMods.isEmpty) {
      final errorMessage =
          l10n?.errorNoCompatibleFilesInArchive ??
          'No compatible files found in archive.';
      _clearSelection(
        message: errorMessage,
        panelStateSetter: panelStateSetter,
      );
      return;
    }
    // ++ FIN DE LA MODIFICACIÓN ++

    final Map<String, List<String>> previewMap = {};

    for (final preparedMod in _preparedMods) {
      // 1. Intenta obtener el nombre del .json (para mods CNS)
      String? displayName = preparedMod.preferredDisplayName ??
          await ModManagerService.getDisplayNameForMod(preparedMod.sourceDir);

      // 2. Si falla (es null), usa el nombre del zip (para mods Genéricos)
      displayName ??= preparedMod.archiveName;

      // 3. Ahora displayName no debería ser nulo
      if (displayName.isNotEmpty) {
        String finalFolderName = displayName;
        if (preparedMod.nexusVersion != null) {
          finalFolderName = '$finalFolderName v${preparedMod.nexusVersion}';
        }

        // 4. CORRECCIÓN: Usamos la misma función que el instalador
        final List<String> allFileDisplayPaths = [];

        // 4a. Archivos del sourceDir (LogicMods, CNS, Genérico, etc.)
        // Estos solo mostrarán el nombre del archivo, ya que van a la carpeta principal del mod.
        if (await preparedMod.sourceDir.exists()) {
          final sourceFiles = await FileManagerService.findAllModFilesRecursive(
            preparedMod.sourceDir,
          );
          allFileDisplayPaths.addAll(
            sourceFiles.map((f) => p.basename(f.path)),
          );
        }

        // 4b. Archivos del ue4ssDir (si existen)
        if (preparedMod.ue4ssDir != null &&
            await preparedMod.ue4ssDir!.exists()) {
          final ue4ssFiles = await FileManagerService.findAllModFilesRecursive(
            preparedMod.ue4ssDir!,
          );
          for (final file in ue4ssFiles) {
            // Obtenemos la ruta relativa para mostrar la estructura (ej: ModName/Scripts/main.lua)
            final relativePath = p.relative(
              file.path,
              from: preparedMod.ue4ssDir!.path,
            );
            // Añadimos un prefijo para que el usuario sepa dónde va
            allFileDisplayPaths.add(
              p.join("[UE4SS]", relativePath).replaceAll(r'\', '/'),
            );
          }
        }

        // 4c. Archivos del tildeModsDir (si existen)
        if (preparedMod.tildeModsDir != null &&
            await preparedMod.tildeModsDir!.exists()) {
          final tildeFiles = await FileManagerService.findAllModFilesRecursive(
            preparedMod.tildeModsDir!,
          );
          for (final file in tildeFiles) {
            final relativePath = p.relative(
              file.path,
              from: preparedMod.tildeModsDir!.path,
            );
            // Añadimos un prefijo para que el usuario sepa dónde va
            allFileDisplayPaths.add(
              p.join("[~MODS]", relativePath).replaceAll(r'\', '/'),
            );
          }
        }

        // 5. Etiqueta lo que va a pasar con este archivo: actualizar una
        //    edición instalada o añadir una edición nueva de un mod existente.
        String previewLabel = finalFolderName;
        final previewNexusId = preparedMod.nexusId;
        if (previewNexusId != null && l10n != null) {
          final sameMod =
              _allMods.where((m) => m.nexusId == previewNexusId).toList();
          if (sameMod.isNotEmpty) {
            final isUpdate =
                await _findInstalledByFileLineage(preparedMod, sameMod) != null ||
                    sameMod.any((m) =>
                        _isSameEditionByName(m, preparedMod, displayName!));
            if (isUpdate) {
              previewLabel = '$finalFolderName  ·  ${l10n.previewTagUpdate}';
            } else if (_isNewEditionOfSameMod(preparedMod)) {
              previewLabel = '$finalFolderName  ·  ${l10n.previewTagNewEdition}';
            }
          }
        }

        // 6. Asigna la lista COMPLETA al mapa
        previewMap[previewLabel] = allFileDisplayPaths;
      }
    }

    // Usa el actualizador de estado del panel si se proporciona
    final updateState = panelStateSetter ?? setState;
    updateState(() {
      _modsToInstallPreviewMap = previewMap;
      _statusMessage = AppLocalizations.of(
        context,
      )!.statusFilesSelected(_modsToInstallPreviewMap.length);
      _statusColor = Colors.white;
    });
  }

  Future<bool> _promptAndUpdateCNS(Directory sourceSBDir) async {
    final l10n = AppLocalizations.of(context)!;

    if (!_isUe4ssInstalled) {
      await InstallDialogs.ue4ssRequired(context);
      return false; // Detiene la instalación si UE4SS no está presente.
    }

    final newVersion = await CoreInstallerService.getVersionFromCnsPackage(sourceSBDir);

    if (_isCnsCoreInstalled) {
      // CASO: YA HAY UNA VERSIÓN INSTALADA (Actualizar, Reinstalar o Revertir)
      final oldVersion = _cnsVersion ?? "N/A";

      // Comparamos la nueva versión con la antigua.
      final comparison = (newVersion != null && _cnsVersion != null)
          ? VersionUtils.compareVersions(newVersion, _cnsVersion!)
          : 1; // Si no podemos comparar, asumimos que es una actualización.

      String title, content, actionText;
      Color actionColor = Colors.orangeAccent;

      if (comparison > 0) {
        // UPDATE (Actualización)
        title = l10n.dialogTitleCNSUpdate;
        content = l10n.dialogContentCNSUpdate(oldVersion, newVersion!);
        actionText = l10n.dialogActionUpdate;
        actionColor = Colors.tealAccent;
      } else if (comparison < 0) {
        // DOWNGRADE (Revertir)
        title = l10n.dialogTitleCNSDowngrade;
        content = l10n.dialogContentCNSDowngrade(oldVersion, newVersion!);
        actionText = l10n.dialogActionDowngrade;
        actionColor = Colors.redAccent;
      } else {
        // REINSTALL (Misma versión)
        title = l10n.dialogTitleCNSReinstall;
        content = l10n.dialogContentCNSReinstallVersion(
          newVersion ?? oldVersion,
        );
        actionText = l10n.dialogActionReinstall;
      }

      final confirm = await SettingsDialogs.confirm(
        context: context,
        title: title,
        message: content,
        confirmLabel: actionText,
        destructive: comparison < 0,
      );
      if (confirm != true) return false;
    } else {
      final confirm = await SettingsDialogs.confirm(
        context: context,
        title: l10n.dialogTitleCNSInstall,
        message: l10n.dialogContentCNSInstall,
        confirmLabel: l10n.dialogActionInstall,
      );
      if (confirm != true) {
        setState(() => _statusMessage = l10n.statusUpdateSystemCancelled);
        return false;
      }
    }

    setState(() {
      _isLoading = true;
      _statusMessage = l10n.statusUpdatingCNS;
    });

    try {
      if (_gameRootPath == null) throw Exception(l10n.errorGamePathUndefined);

      if (_gameRootPath == null) throw Exception(l10n.errorGamePathUndefined);

      // Llama al nuevo servicio
      await CoreInstallerService.installCNS(
        sourceSBDir: sourceSBDir,
        gameRootPath: _gameRootPath!,
      );

      // ignore: unused_local_variable
      String? versionFromLua;
      try {
        final luaFile = File(
          p.join(
            _gameRootPath!,
            'SB',
            'Binaries',
            'Win64',
            'ue4ss',
            'Mods',
            'DekCNS',
            'Scripts',
            'main.lua',
          ),
        );
        if (await luaFile.exists()) {
          final content = await luaFile.readAsString();
          final regex = RegExp(r'local CNS_Version = "(.+)"');
          final match = regex.firstMatch(content);
          if (match != null && match.group(1) != null) {
            versionFromLua = match.group(1);
          }
        }
      } catch (e) {
        /* ... */
      }

      // ... (resto de la lógica para crear nexus_info.json sin cambios)

      NotificationService.instance.show(
        context: context,
        type: NotificationType.success,
        title: l10n.snackBarCNSUpdated,
      );
      setState(() {
        _statusMessage = l10n.statusUpdateComplete;
        _isCnsCoreInstalled = true;
        _clearSelection();
      });

      await _readCNSData();
      return true;
    } catch (e) {
      setState(() {
        _statusMessage = l10n.statusError(e.toString());
        _statusColor = Colors.redAccent;
      });
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _installMod({StateSetter? panelStateSetter}) async {
    final l10n = AppLocalizations.of(context)!;
    final updateState = panelStateSetter ?? setState;
    if (_finalModsPath == null) {
      updateState(() {
        _statusMessage = l10n.errorGamePathUndefined;
        _statusColor = Colors.redAccent;
      });
      return;
    }
    if (_preparedMods.isEmpty) {
      updateState(() {
        _statusMessage = l10n.errorInstallNoSelection;
        _statusColor = Colors.redAccent;
      });
      return;
    }

    // Usa los nuevos estados de instalación en lugar de _isLoading
    updateState(() {
      _isInstalling = true;
      _installationProgress = 0.0;
      _installationStatus =
          l10n.statusInstalling; // Necesitarás esta traducción
      _lastInstalledModNames.clear();
    });

    List<String> installedNames = [];
    String? errorMessage;
    int successCount = 0;
    int failCount = 0;
    bool installedMod801 = false;

    try {
      for (int i = 0; i < _preparedMods.length; i++) {
        final preparedMod =
            _preparedMods[i]; // <-- Obtenemos el objeto completo
        try {
          // Llamamos a nuestra nueva función de instalación unificada
          final modName = await _installSingleMod(preparedMod, l10n: l10n);

          if (modName != null) {
            installedNames.add(modName);
            successCount++;
            if (preparedMod.nexusId == '801') {
              installedMod801 = true;
            }
            updateState(() {
              _installationProgress = (i + 1) / _preparedMods.length;
              _installationStatus = l10n.statusInstallingMod(
                i + 1,
                _preparedMods.length,
                modName,
              );
            });
          } else {
            failCount++;
          }
        } catch (e) {
          print('Failed to install mod from ${preparedMod.sourceDir.path}: $e');
          failCount++;
        }
      }

      if (mounted) {
        // This block now correctly handles showing the final summary.
        if (_preparedMods.length > 1) {
          NotificationService.instance.show(
            context: context,
            type: failCount > 0
                ? (successCount > 0
                      ? NotificationType.info
                      : NotificationType.error)
                : NotificationType.success,
            title: l10n.snackBarBatchInstallComplete(failCount, successCount),
          );
        } else if (successCount == 1) {
          NotificationService.instance.show(
            context: context,
            type: NotificationType.success,
            title: l10n.snackBarModInstalled(installedNames.first),
          );
        }
        if (installedMod801 && _gameRootPath != null) {
          // Un pequeño delay visual para que el usuario vea que la instalación terminó primero
          await Future.delayed(const Duration(milliseconds: 500));
          await Mod801SteamDialog.show(context, _gameRootPath!);
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.statusError(errorMessage),
        );
      }
    } finally {
      setState(() {
        _lastInstalledModNames = installedNames;
        if (errorMessage == null) {
          _statusMessage = installedNames.isNotEmpty
              ? l10n.statusInstallationComplete
              : l10n.statusNoNewModsInstalled;
        } else {
          _statusMessage = l10n.statusError(errorMessage);
          _statusColor = Colors.redAccent;
        }
        _clearSelection();
        _isLoading = false;
        _isInstalling = false;
      });
      //await _loadAllMods(clearHighlight: false);
      try {
        if (_tempExtractionDir != null && await _tempExtractionDir!.exists()) {
          // Usar el FileManagerService
          await FileManagerService.deleteDirectoryWithRetry(_tempExtractionDir!);
        }
        _tempExtractionDir = null;
        await _cleanUpOrphanedTempDirs();
      } catch (e) {
        print('Failed to clean up temp directory: $e');
      }
    }
  }

  // ++ AÑADIR ESTA FUNCIÓN (COPIADA DE _ModDetailsPanelState) ++
  /// Genera la ruta del asset para la vista previa de un traje.
  String _generateOutfitImagePath(String outfitName) {
    // 1. Minúsculas
    String safeName = outfitName.toLowerCase();
    // 2. Quitar (NG+) y caracteres especiales
    safeName = safeName
        .replaceAll('(ng+)', 'ng_plus')
        .replaceAll(RegExp(r'[^\w\s-]'), '');
    // 3. Reemplazar espacios y guiones con guiones bajos
    safeName = safeName.replaceAll(RegExp(r'[\s-]+'), '_');

    // 4. Devolver la ruta completa del asset
    return 'assets/images/outfits/$safeName.webp'; // Asume .webp
  }

  Future<String> _getComparableNameForMod(ModInfo mod) async {
    return mod.displayName;
  }

  /// file_id de Nexus guardado en el nexus_info.json de un mod instalado.
  Future<String?> _readNexusFileId(ModInfo mod) async {
    try {
      final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
      if (!await infoFile.exists()) return null;
      final data = json.decode(await infoFile.readAsString());
      return data['nexusFileId']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Busca entre [candidates] el mod instalado que corresponde al mismo archivo
  /// de Nexus que [preparedMod] (mismo file_id) o a una versión anterior suya.
  /// Tipos de mod que pueden llevar partes fuera de su carpeta (scripts UE4SS,
  /// archivos sueltos de UE4SS y, en los logic antiguos, paks en ~mods). Para
  /// el resto, los bloques de componentes simplemente no encuentran nada.
  bool _canHaveExtraParts(ModInfo mod) =>
      mod.modType == 'logicMod' ||
      mod.modType == 'genericPak' ||
      mod.modType == 'replacement';

  /// Un logic antiguo con paks en ~mods/<nombre> (componente aparte): al
  /// reemplazarlo hay que borrar también esa carpeta. Con el mod desactivado
  /// vive dentro de su respaldo y se borra con él.
  Future<void> _removeOldTildeComponent(ModInfo old) async {
    if (!old.isEnabled || _genericModsPath == null) return;
    try {
      final info = File(p.join(old.directory.path, 'nexus_info.json'));
      if (!await info.exists()) return;
      final data = json.decode(await info.readAsString());
      final folder = data is Map ? data['tildeModsComponentFolder'] : null;
      if (folder is! String || folder.isEmpty) return;
      final dir = Directory(p.join(_genericModsPath!, folder));
      if (p.equals(dir.path, old.directory.path)) return;
      if (await dir.exists()) {
        await FileManagerService.deleteDirectoryWithRetry(dir);
      }
    } catch (_) {}
  }

  /// ¿[dir] contiene algún .pak/.utoc/.ucas (en cualquier subcarpeta)?
  Future<bool> _dirHasPackageFiles(Directory dir) async {
    const exts = {'.pak', '.utoc', '.ucas'};
    try {
      await for (final e in dir.list(recursive: true, followLinks: false)) {
        if (e is File && exts.contains(p.extension(e.path).toLowerCase())) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<ModInfo?> _findInstalledByFileLineage(
    PreparedMod preparedMod,
    Iterable<ModInfo> candidates,
  ) async {
    final lineage = preparedMod.identity?.lineageFileIds ?? const <String>[];
    if (lineage.isEmpty) return null;
    for (final candidate in candidates) {
      final fileId = await _readNexusFileId(candidate);
      if (fileId != null && lineage.contains(fileId)) return candidate;
    }
    return null;
  }

  /// Normaliza un nombre para compararlo (sin mayúsculas, espacios ni símbolos).
  String _compactName(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Nombre de edición de un mod ya instalado. Los mods instalados antes de
  /// que existieran las ediciones solo tienen `displayName`, que entonces era
  /// el nombre del archivo de Nexus (= la edición).
  String _editionNameOf(ModInfo mod) => mod.editionName ?? mod.displayName;

  /// ¿Es [candidate] la MISMA edición que el archivo nuevo? (misma edición
  /// = se puede actualizar / reinstalar; otra edición = se instala aparte).
  bool _isSameEditionByName(
    ModInfo candidate,
    PreparedMod preparedMod,
    String baseDisplayName,
  ) {
    final newEdition = preparedMod.editionName;
    if (newEdition != null &&
        _compactName(_editionNameOf(candidate)) == _compactName(newEdition)) {
      return true;
    }
    return _compactName(candidate.displayName) == _compactName(baseDisplayName);
  }

  /// true cuando se sabe con certeza que el archivo nuevo es OTRA EDICIÓN de
  /// un mod de Nexus que ya tienes instalado (p. ej. tienes "CNS" y ahora
  /// instalas "Replacer"): Nexus confirmó el archivo (tiene file_id) y ningún
  /// mod instalado corresponde a su misma línea de versiones ni a su nombre.
  bool _isNewEditionOfSameMod(PreparedMod preparedMod) =>
      preparedMod.identity?.fileId != null;

  /// Mods instalados que son ediciones del mismo mod de Nexus que [mod]
  /// (incluido [mod]). Vacío si el mod no tiene ID de Nexus.
  List<ModInfo> _installedEditionsOf(ModInfo mod) {
    final id = mod.nexusId;
    if (id == null || id.isEmpty || id == _cnsNexusId) return const [];
    return _allMods.where((m) => m.nexusId == id).toList();
  }

  /// Otros mods instalados con el mismo ID de Nexus (sin contar a [mod]).
  List<ModInfo> _otherEditionsOf(ModInfo mod) => _installedEditionsOf(mod)
      .where((m) => m.directory.path != mod.directory.path)
      .toList();

  /// Si [name] ya lo usa un mod instalado de OTRO mod de Nexus, le añade el ID
  /// de Nexus para que las carpetas y los nombres no choquen.
  /// (Pasa, p. ej., sin API key: dos mods distintos con una edición llamada
  /// "CNS compatible" no se pueden distinguir por el nombre del archivo.)
  String _disambiguateAcrossMods(String name, String? nexusId) {
    if (nexusId == null) return name;
    final target = name.toLowerCase();
    final clash = _allMods.any((m) =>
        m.nexusId != null &&
        m.nexusId != nexusId &&
        (m.displayName.toLowerCase() == target ||
            p.basename(m.directory.path).toLowerCase() == target));
    return clash ? '$name [$nexusId]' : name;
  }

  Future<AlternativeVersionAction?> _showSmartInstallDialog({
    required ModInfo oldVersionMod,
    required String baseDisplayName,
    required String? newVersion,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final oldVersion = oldVersionMod.localVersion ?? 'N/A';
    final newVersionStr = newVersion ?? 'N/A';
    final modName = oldVersionMod.customName;

    String title = l10n.dialogTitleAlternativeVersion;
    String content;
    String replaceActionText = l10n.dialogActionReplace;

    if (oldVersionMod.localVersion != null && newVersion != null) {
      final comparison = VersionUtils.compareVersions(
        newVersion,
        oldVersionMod.localVersion!,
      );

      if (comparison > 0) {
        title = l10n.dialogTitleUpdate;
        content = l10n.dialogContentUpdate(modName, oldVersion, newVersionStr);
        replaceActionText = l10n.dialogActionUpdate;
      } else if (comparison < 0) {
        title = l10n.dialogTitleDowngrade;
        content = l10n.dialogContentDowngrade(
          modName,
          oldVersion,
          newVersionStr,
        );
        replaceActionText = l10n.dialogActionDowngrade;
      } else {
        title = l10n.dialogTitleReinstall;
        content = l10n.dialogContentReinstall(modName, newVersionStr);
        replaceActionText = l10n.dialogActionReinstall;
      }
    } else {
      content = l10n.dialogContentAlternativeVersion(
        modName,
        baseDisplayName,
        baseDisplayName,
      );
    }

    final bool isDowngrade = title == l10n.dialogTitleDowngrade;
    final bool replace = await SettingsDialogs.confirm(
      context: context,
      title: title,
      message: content,
      confirmLabel: replaceActionText,
      destructive: isDowngrade,
    );
    return replace
        ? AlternativeVersionAction.replace
        : AlternativeVersionAction.cancel;
  }

  // ---------------------------------------------------------------------------
  //  Conflicto de traje al INSTALAR un mod con traje detectado automáticamente
  // ---------------------------------------------------------------------------

  /// Convierte el texto traducido en spans: los marcadores {new} y {outfits}
  /// van en negrita y cada mod en conflicto ({old}) es un enlace que abre su
  /// panel de detalles (como en el diálogo de activar con el interruptor).
  List<InlineSpan> _buildInstallConflictSpans(
    String template, {
    required String newName,
    required List<String> outfits,
    required List<ModInfo> conflicting,
  }) {
    const bold = TextStyle(
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: IosColors.label,
    );
    const link = TextStyle(
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: IosColors.blue,
    );

    final spans = <InlineSpan>[];
    final marker = RegExp(r'\{(new|old|outfits)\}');
    var last = 0;
    for (final m in marker.allMatches(template)) {
      if (m.start > last) {
        spans.add(TextSpan(text: template.substring(last, m.start)));
      }
      switch (m.group(1)) {
        case 'new':
          spans.add(TextSpan(text: newName, style: bold));
          break;
        case 'outfits':
          spans.add(TextSpan(text: outfits.join(', '), style: bold));
          break;
        case 'old':
          for (var i = 0; i < conflicting.length; i++) {
            if (i > 0) spans.add(const TextSpan(text: ', '));
            final mod = conflicting[i];
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _showDetailsPage(mod),
                    child: Text(mod.customName, style: link),
                  ),
                ),
              ),
            );
          }
          break;
      }
      last = m.end;
    }
    if (last < template.length) {
      spans.add(TextSpan(text: template.substring(last)));
    }
    return spans;
  }

  /// true = activar el mod nuevo (y desactivar los anteriores);
  /// false = mantener los actuales (el nuevo queda desactivado).
  Future<bool?> _showInstallOutfitConflictDialog({
    required String newName,
    required List<String> outfits,
    required List<ModInfo> conflicting,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showIosDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => IosDialogShell(
        title: l10n.installOutfitConflictTitle,
        width: 360,
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: IosColors.secondaryLabel,
            ),
            children: _buildInstallConflictSpans(
              // Los marcadores {new}/{old}/{outfits} se resuelven en spans
              l10n.installOutfitConflictBody('{new}', '{outfits}', '{old}'),
              newName: newName,
              outfits: outfits,
              conflicting: conflicting,
            ),
          ),
        ),
        actions: [
          IosDialogButton(
            label: l10n.installOutfitKeepCurrent,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          IosDialogButton(
            label: l10n.installOutfitUseNew,
            bold: true,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }

  /// Tras instalar un mod con traje detectado: si ese traje ya lo tiene otro
  /// mod ACTIVO, avisa y deja elegir cuál queda activo (nunca los dos).
  Future<void> _resolveInstallOutfitConflict({
    required String newModPath,
    required String newName,
    required List<String> outfits,
    required Directory backupDir,
  }) async {
    if (!mounted) return;

    final conflicting = <ModInfo>[];
    for (final m in _allMods) {
      if (!m.isEnabled || m.directory.path == newModPath) continue;
      final other = m.replacesOutfits ?? const <String>[];
      if (!other.any(outfits.contains)) continue;
      // Descarta entradas obsoletas (p. ej. la versión anterior ya borrada).
      if (!await m.directory.exists()) continue;
      conflicting.add(m);
    }
    if (conflicting.isEmpty) return;

    final useNew = await _showInstallOutfitConflictDialog(
      newName: newName,
      outfits: outfits,
      conflicting: conflicting,
    );

    final String activeName;
    try {
      if (useNew == true) {
        for (final m in conflicting) {
          final ok = await _disableMod(m);
          if (!ok) return; // _disableMod ya mostró el motivo
        }
        activeName = newName;
      } else {
        await FileManagerService.moveMod(Directory(newModPath), backupDir.path);
        activeName = conflicting.map((m) => m.customName).join(', ');
      }
    } catch (e) {
      print('[OutfitConflict] $e');
      _reportToggleError(e, enabling: false);
      return;
    }

    if (!mounted) return;
    NotificationService.instance.show(
      context: context,
      type: NotificationType.info,
      title: AppLocalizations.of(context)!.installOutfitNowActive(activeName),
    );
  }

  Future<String?> _installSingleMod(
  PreparedMod preparedMod, {
  required AppLocalizations l10n,
  }) async {
    Directory modDir = preparedMod.sourceDir;
    final nexusId = preparedMod.nexusId;
    if (SpecialModsHandler.isSpecialMod(nexusId)) {
      // Parsear la estructura
      final modData = await SpecialModsHandler.parseMod(nexusId!, modDir);
      
      // Mostrar el panel UI al usuario SOLO si hay MÁS de una opción
      if (modData.options.length > 1) {
        final confirmed = await SpecialModSelectionDialog.show(context, modData);
        
        if (!confirmed) {
          throw Exception(l10n.statusInstallationCancelledByUser);
        }
      } else if (modData.options.length == 1) {
        // Si solo hay una opción, la auto-seleccionamos para instalar directo
        modData.options.first.isSelected = true;
      }

      // Reconstruir un nuevo directorio fuente solo con los archivos seleccionados (o principales)
      final tempRoot = Directory.systemTemp.createTempSync('mod_special_');
      modDir = await SpecialModsHandler.buildSelectedInstallation(modData, tempRoot);
      
      // A partir de aquí, el código estándar de tu app tratará "modDir" 
      // como un mod limpio y consolidado, y lo instalará normalmente.
    }
    final nexusVersion = preparedMod.nexusVersion;
    final modType = preparedMod.modType;
    final ue4ssDir = preparedMod.ue4ssDir;
    final tildeModsDir = preparedMod.tildeModsDir;

    String? preservedCustomName;
    // Estado de endorse del mod que se reemplaza (se copia al nuevo nexus_info.json).
    EndorseRecord? preservedEndorse;
    String? selectedOutfit;
    // Trajes detectados automáticamente en mods genéricos de reemplazo.
    List<String>? autoOutfits;

    // 1. CLASIFICAR EL MOD Y OBTENER SUS DATOS
    //final modType = await ModClassifierService.classifyModDirectory(modDir); // <-- ELIMINADO: Ya tenemos el tipo
    String? baseDisplayName;
    String? fitMeshType;
    String? installPath;
    List<String> replacedFiles = [];
    // Mods de películas: vídeos elegidos (conservan su ruta relativa a Movies)
    List<MovieSourceFile> selectedMovieFiles = [];

    // Definir la ruta de backup general (para mods deshabilitados y movies)
    if (_gameRootPath == null) throw Exception(l10n.errorGamePathNotDefined);
    final backupDirPath = p.join(
      _gameRootPath!,
      'SB',
      'Content',
      '__MOD_BACKUPS__',
    );
    // Asegurarse de que exista
    final backupDir = Directory(backupDirPath);
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    String
    finalFolderName; // La movemos aquí para que sea accesible por LogicMod

    // HD-ATOOL (1662): carpeta fija LogicMods/HD-ATOOL_P y audios a conservar.
    final bool isAtoolTool = modType == ModDirectoryType.logicMod &&
        HdAtoolAudio.isToolMain(nexusId, preparedMod.identity);
    Directory? atoolAudioStash;

    if (modType == ModDirectoryType.logicMod) {
      // Es un LogicMod: Lógica de instalación dividida
      baseDisplayName = _disambiguateAcrossMods(preparedMod.archiveName, nexusId);
      fitMeshType = "Logic"; // Etiqueta

      // --- 1. Definir rutas ---
      // Ruta de la carpeta "LogicMods" en el zip (la fuente es la raíz del zip)
      if (isAtoolTool) await HdAtoolAudio.flattenToolFolder(modDir);
      final logicSourceDir = modDir; // sourceDir *es* la carpeta LogicMods
      final ue4ssSourceDir = ue4ssDir; // ue4ssDir *es* la carpeta Mods
      final tildeModsSourceDir =
          tildeModsDir; // tildeModsDir *es* la carpeta Mods

      // Ruta de destino para los LogicMods (.../Paks/LogicMods)
      installPath = _logicModsPath;
      if (installPath == null)
        throw Exception(l10n.errorLogicModsPathNotDefined);

      // Ruta de destino para los archivos UE4SS (.../ue4ss/Mods)
      final ue4ssDestPath = _ue4ssModsPath;
      if (ue4ssDestPath == null)
        throw Exception(l10n.errorUe4ssModsPathNotDefined);

      final tildeModsDestPath = _genericModsPath;
      if (tildeModsDestPath == null)
        throw Exception(l10n.errorGenericModsPathNotDefined);

      // Nombre de la carpeta del mod (para la parte Lógica)
      finalFolderName = baseDisplayName;
      if (isAtoolTool) {
        finalFolderName = HdAtoolAudio.toolFolder; // siempre HD-ATOOL_P
      } else if (nexusVersion != null) {
        finalFolderName = '$finalFolderName v$nexusVersion';
      }

      // ¿Es en realidad un mod GENÉRICO con scripts UE4SS? Pasa cuando el
      // archivo trae paks para ~mods y UE4SS, pero ningún pak para LogicMods
      // (sin ModActor). Entonces no tiene sentido crear una carpeta en
      // LogicMods solo para guardar nexus_info.json y la portada: el mod se
      // instala como genericPak -su carpeta es ~mods/<mod_name>- y sus
      // scripts UE4SS se registran como componentes (ue4ssComponents /
      // ue4ssLooseFiles) para que activar, desactivar y borrar los muevan.
      final bool asGeneric = !isAtoolTool &&
          tildeModsSourceDir != null &&
          await tildeModsSourceDir.exists() &&
          !await _dirHasPackageFiles(logicSourceDir);
      if (asGeneric) fitMeshType = "Generic";

      // Ruta final de la carpeta del mod:
      //   logic   -> .../Paks/LogicMods/<mod_name>
      //   generic -> .../Paks/~mods/<mod_name>
      final logicModDestPath =
          p.join(asGeneric ? tildeModsDestPath : installPath, finalFolderName);

      // --- 2. Lógica de Reemplazo ---
      // La "carpeta del mod" que gestionamos (activar/desactivar) es la de LogicMods.
      // La parte de UE4SS se considera una dependencia permanente.

      ModInfo? oldVersionMod;
      // 1) Mismo archivo de Nexus (file_id) o una versión anterior de él
      oldVersionMod = await _findInstalledByFileLineage(
        preparedMod,
        _allMods.where((mod) => _canHaveExtraParts(mod) && mod.nexusId == nexusId),
      );
      // 2) Si no, un mod existente con el mismo nombre Y que sea 'logicMod'
      if (oldVersionMod == null) {
        try {
          oldVersionMod = _allMods.firstWhere(
            (mod) =>
                mod.displayName == baseDisplayName &&
                _canHaveExtraParts(mod) &&
                // Un mod de OTRO ID de Nexus nunca es una versión anterior.
                (mod.nexusId == null ||
                    nexusId == null ||
                    mod.nexusId == nexusId),
          );
        } catch (e) {
          oldVersionMod = null; // No se encontró
        }
      }

      AlternativeVersionAction? action;
      if (oldVersionMod != null) {
        // Ya existe un mod con este nombre.
        action = await _showSmartInstallDialog(
          oldVersionMod: oldVersionMod,
          baseDisplayName: baseDisplayName,
          newVersion: nexusVersion,
        );
      }

      if (action != null) {
        switch (action) {
          case AlternativeVersionAction.replace:
            if (oldVersionMod == null) {
              // Comprobación de seguridad
              throw Exception(
                l10n.errorReplaceNoOldVersion,
              );
            }
            // Preservar customName
            final oldInfoFile = File(
              p.join(oldVersionMod.directory.path, 'nexus_info.json'),
            );
            if (await oldInfoFile.exists()) {
              try {
                final oldData = json.decode(await oldInfoFile.readAsString());
                if (oldData['customName'] != null) {
                  preservedCustomName = oldData['customName'];
                }
                preservedEndorse ??= EndorseRecord.fromInfo(oldData);
              } catch (e) {
                print('Could not read old custom name. Error: $e');
              }
            }
            // HD-ATOOL: conservar los audios de otros mods al reemplazar la herramienta
            if (isAtoolTool) {
              atoolAudioStash ??= await HdAtoolAudio.stashAudio(oldVersionMod.directory);
            }
            // Si el mod antiguo estaba activo, quitar sus audios de HD-ATOOL
            if (oldVersionMod.isEnabled) {
              await HdAtoolAudio.deactivate(
                oldVersionMod.directory,
                HdAtoolAudio.gameAudioPath(installPath),
              );
            }
            // Una versión anterior tipo logic con paks en ~mods: quitar también
            // esa carpeta, que queda fuera de la del mod.
            await _removeOldTildeComponent(oldVersionMod);
            // Borramos la carpeta del mod antigua
            final deleted = await FileManagerService.deleteDirectoryWithRetry(
              oldVersionMod.directory,
            );
            if (!deleted) {
              throw Exception(
                l10n.errorDeleteOldModVersion(oldVersionMod.customName),
              );
            }
            // NOTA: No podemos desinstalar la parte de UE4SS. El usuario es responsable.
            break;
          case AlternativeVersionAction.installAsNew:
            break; // No hacer nada
          case AlternativeVersionAction.cancel:
          case null:
          default:
            throw Exception(l10n.statusInstallationCancelledByUser);
        }
      }

      // --- 3. Comprobar si la carpeta de destino existe (después del reemplazo) ---
      // HD-ATOOL: una carpeta HD-ATOOL_P "suelta" (solo audios de otros mods o
      // copiada a mano) no es una instalación: se funde sin preguntar ni borrar.
      final bool destIsStrayTool = isAtoolTool &&
          await Directory(logicModDestPath).exists() &&
          await HdAtoolAudio.isStrayToolFolder(Directory(logicModDestPath));
      if (!destIsStrayTool && await Directory(logicModDestPath).exists()) {
        final confirmReinstall = await SettingsDialogs.confirm(
          context: context,
          title: l10n.dialogTitleModExists,
          message: l10n.dialogContentModExists(finalFolderName),
          confirmLabel: l10n.dialogActionUpdate,
        );

        if (confirmReinstall != true) {
          throw Exception(l10n.errorInstallModExists);
        } else {
          // Preservar customName al reinstalar
          final oldInfoFile = File(p.join(logicModDestPath, 'nexus_info.json'));
          if (preservedCustomName == null && await oldInfoFile.exists()) {
            try {
              final oldData = json.decode(await oldInfoFile.readAsString());
              if (oldData['customName'] != null) {
                preservedCustomName = oldData['customName'];
              }
              preservedEndorse ??= EndorseRecord.fromInfo(oldData);
            } catch (e) {
              print('Could not read old custom name. Error: $e');
            }
          }
          if (isAtoolTool) {
            atoolAudioStash ??=
                await HdAtoolAudio.stashAudio(Directory(logicModDestPath));
          }
          await HdAtoolAudio.deactivate(
            Directory(logicModDestPath),
            HdAtoolAudio.gameAudioPath(installPath),
          );
          final deleted = await FileManagerService.deleteDirectoryWithRetry(
            Directory(logicModDestPath),
          );
          if (!deleted) {
            throw Exception(
              l10n.errorDeleteExistingModReinstall(finalFolderName),
            );
          }
        }
      }

      // --- 4. Copiar los archivos ---

      // Parte A: Copiar .../zip/LogicMods/* A .../Paks/LogicMods/<mod_name>/
      await Directory(logicModDestPath).create(recursive: true);
      await FileManagerService.copyDirectory(logicSourceDir, Directory(logicModDestPath));

      // Parte A2: audios de HD-ATOOL (si el mod trae _hd_atool_audio) ->
      // .../Paks/LogicMods/HD-ATOOL_P/audio. Se recuerdan en nexus_info.json.
      // HD-ATOOL: devolver los audios de otros mods que había en su carpeta
      List<String> hdAtoolAudioNames = [];
      if (!asGeneric) {
        await HdAtoolAudio.restoreAudio(atoolAudioStash, Directory(logicModDestPath));
        if (!isAtoolTool) await HdAtoolAudio.adoptInPlace(Directory(logicModDestPath));
        hdAtoolAudioNames = await HdAtoolAudio.activate(
          Directory(logicModDestPath),
          HdAtoolAudio.gameAudioPath(installPath),
        );
      }

      // Parte B: Copiar componentes de UE4SS (Carpetas de mods y archivos sueltos raíz)
      List<String> ue4ssComponentFolders = [];
      List<String> looseFilesLog = [];

      if (ue4ssSourceDir != null && await ue4ssSourceDir.exists()) {
        final ue4ssRootDestPath = p.dirname(ue4ssDestPath!); // Ruta raíz de ue4ss del juego

        // 1. Copiar subcarpetas dentro de ue4ss/Mods si existen
        final sourceModsFolder = Directory(p.join(ue4ssSourceDir.path, 'Mods'));
        if (await sourceModsFolder.exists()) {
          await FileManagerService.copyDirectory(sourceModsFolder, Directory(ue4ssDestPath));
          await for (final entity in sourceModsFolder.list()) {
            if (entity is Directory) {
              ue4ssComponentFolders.add(p.basename(entity.path));
            }
          }
        }

        // 2. Detectar y copiar archivos sueltos directamente en la raíz de ue4ss (ej: UE4SS-settings.ini)
        await for (final entity in ue4ssSourceDir.list(recursive: false)) {
          if (entity is File) {
            final fileName = p.basename(entity.path);
            if (fileName == 'nexus_info.json') continue;

            final gameTargetFile = File(p.join(ue4ssRootDestPath, fileName));
            final originalsBackupDir = Directory(p.join(logicModDestPath, '_ue4ss_originals'));

            // Si el archivo ya existe en el juego, guardamos una copia del original antes de sobrescribir
            if (await gameTargetFile.exists()) {
              if (!await originalsBackupDir.exists()) {
                await originalsBackupDir.create(recursive: true);
              }
              final backupOriginalFile = File(p.join(originalsBackupDir.path, fileName));
              if (!await backupOriginalFile.exists()) {
                await gameTargetFile.copy(backupOriginalFile.path);
              }
            }

            // Copiamos el archivo del mod al directorio de ejecución del juego
            await entity.copy(gameTargetFile.path);
            looseFilesLog.add(fileName);
          }
        }
      }
      
      bool hasTildeModsComponent = false;
      if (tildeModsSourceDir != null && await tildeModsSourceDir.exists()) {
        if (asGeneric) {
          // Los paks van DENTRO de la carpeta del mod (~mods/<mod_name>).
          await FileManagerService.copyDirectory(
              tildeModsSourceDir, Directory(logicModDestPath));
        } else {
          final tildeModDestPathWithFolder = p.join(tildeModsDestPath, finalFolderName);
          hasTildeModsComponent = true;
          final destDir = Directory(tildeModDestPathWithFolder);
          if (!await destDir.exists()) await destDir.create(recursive: true);
          await FileManagerService.copyDirectory(tildeModsSourceDir, destDir);
        }
      }

      // --- 5. Crear nexus_info.json ---
      final infoFile = File(p.join(logicModDestPath, 'nexus_info.json'));
      final versionForFile = nexusVersion;

      final Map<String, dynamic> modData = {
        'nexusId': nexusId,
        'displayName': baseDisplayName,
        'customName': preservedCustomName ?? baseDisplayName,
        'installedVersion': versionForFile,
        'nexusFileId': preparedMod.identity?.fileId,
        'modName': preparedMod.nexusModName,
        'editionName': preparedMod.editionName,
        'nexusFileName': preparedMod.identity?.remoteFileName,
        'identifiedBy': preparedMod.identity?.source.name,
        'installDate': DateTime.now().toIso8601String(),
        'managerVersion': _appVersion,
        'fitMeshType': fitMeshType,
        'modType': asGeneric ? ModDirectoryType.genericPak.name : modType.name,
        'sourceUrl': nexusId != null ? 'https://www.nexusmods.com/stellarblade/mods/$nexusId' : null,
        'tildeModsComponentFolder': hasTildeModsComponent ? finalFolderName : null,
        'ue4ssComponents': ue4ssComponentFolders.isNotEmpty ? ue4ssComponentFolders : null,
        'ue4ssLooseFiles': looseFilesLog.isNotEmpty ? looseFilesLog : null, // Guardamos registro de los archivos raíz instalados
        HdAtoolAudio.infoKey: hdAtoolAudioNames.isNotEmpty ? hdAtoolAudioNames : null,
      };
      modData.removeWhere((key, value) => value == null); // Limpia nulos
      preservedEndorse?.applyTo(modData);

      if (nexusId != null) {
        final nexusData = await NexusApiService.fetchNexusModData(nexusId, _apiKey);
        if (nexusData != null) {
          modData['gallery'] = nexusData['gallery'];
          modData['summary'] = nexusData['summary'];
          modData['author'] = nexusData['author'];
          modData['description'] = nexusData['description'];
        }
      }

      final encoder = JsonEncoder.withIndent('  ');
      await infoFile.writeAsString(encoder.convert(modData));

      // --- 6. Copiar miniatura (igual que antes) ---
      if (nexusId != null) {
        await ModManagerService.cacheNexusThumbnail(apiKey: _apiKey,
          modDirectory: Directory(logicModDestPath),
          nexusId: nexusId,
        );
      }
      return finalFolderName; // Devuelve el nombre para el snackbar
    } else if (modType == ModDirectoryType.cns) {
      // Es un mod CNS: obtenemos el nombre y la etiqueta desde sus .json
      // Nombre oficial del archivo en Nexus; si no se reconoce, el de los .json
      baseDisplayName = preparedMod.preferredDisplayName ??
          await ModManagerService.getCompositeDisplayName(modDir);
      fitMeshType = await ModManagerService.getFitMeshTypeForMod(modDir);
      installPath = _finalModsPath; // Se instala en la carpeta CNS
    } else if (modType == ModDirectoryType.genericPak) {
      // Es un mod Genérico: usamos el nombre del ZIP y la etiqueta "Generic"
      baseDisplayName = preparedMod.archiveName;
      fitMeshType = "Generic";
      installPath = _genericModsPath; // Se instala en la carpeta genérica
      // Detecta qué traje(s) reemplaza leyendo los nombres dentro del .pak/.utoc.
      // Si falla o no encuentra nada, queda como "Genérico" (selección manual).
      // Solo si la opción de Ajustes está activada.
      if (_autoAssignOutfits) {
        try {
          final found = await OutfitDetector.detect(modDir);
          if (found.isNotEmpty) autoOutfits = found;
        } catch (_) {}
      }
    } else if (modType == ModDirectoryType.movies) {
      baseDisplayName = preparedMod.archiveName;
      fitMeshType = null;
      installPath = backupDirPath;

      // Se conserva la estructura relativa a la carpeta Movies del juego (Movies/Menu...).
      // Solo se pregunta si el archivo trae variantes excluyentes (mismo vídeo en
      // varias carpetas); en cualquier otro caso se instala todo.
      final movieAnalysis = await MovieModsHandler.analyze(preparedMod.archiveName, modDir);
      final movieChoice = movieAnalysis.choice;
      if (movieChoice != null) {
        final confirmed = await SpecialModSelectionDialog.show(context, movieChoice);
        if (!confirmed) {
          throw Exception(l10n.statusInstallationCancelledByUser);
        }
      }
      selectedMovieFiles = MovieModsHandler.resolveSelection(movieAnalysis);
      for (final movieFile in selectedMovieFiles) {
        replacedFiles.add(movieFile.rel);
      }

      if (replacedFiles.isEmpty) {
        throw Exception(l10n.errorMoviesModNoValidFiles);
      }
    }
    else if (modType == ModDirectoryType.save) {
      baseDisplayName = preparedMod.archiveName;
      fitMeshType = "Save Game";
      installPath = backupDirPath; // Se registra inactivo dentro de backups

      await for (final entity in modDir.list(recursive: false)) {
        if (entity is File && p.extension(entity.path).toLowerCase() == '.sav') {
          replacedFiles.add(p.basename(entity.path));
        }
      }
    } else if (modType == ModDirectoryType.config) {
      baseDisplayName = preparedMod.archiveName;
      fitMeshType = "Config (.ini)";
      installPath = backupDirPath;

      await for (final entity in modDir.list(recursive: false)) {
        if (entity is File) {
          final name = p.basename(entity.path).toLowerCase();
          // Todos los .ini de configuración del juego (Engine, Scalability, Input,
          // Game, GameUserSettings, DeviceProfiles...) y solo si son texto.
          if (ConfigModDetector.isConfigFileName(name) &&
              await ConfigModDetector.isValidIni(entity)) {
            replacedFiles.add(p.basename(entity.path));
          }
        }
      }
    } else if (modType == ModDirectoryType.splash) {
      baseDisplayName = preparedMod.archiveName;
      fitMeshType = "Splash Screen";
      installPath = backupDirPath;

      // 1. Parseamos el directorio para estructurar las opciones
      final splashData = await SplashModsHandler.parseSplashMod(modDir);

      // 2. Si hay múltiples imágenes/carpetas, mostramos el UI
      if (splashData.hasMultipleOptions) {
        final confirmed = await SplashModSelectionDialog.show(context, splashData);
        if (!confirmed) {
          throw Exception(l10n.statusInstallationCancelledByUser);
        }
        
        // Creamos un nuevo directorio temporal consolidando SOLO lo seleccionado
        final tempRoot = Directory.systemTemp.createTempSync('mod_splash_selected_');
        modDir = await SplashModsHandler.buildSelectedInstallation(splashData, tempRoot);
      } else if (splashData.folders.isNotEmpty) {
        // Auto-selección si solo hay un archivo sin necesidad de interrumpir con el diálogo
        final tempRoot = Directory.systemTemp.createTempSync('mod_splash_selected_');
        modDir = await SplashModsHandler.buildSelectedInstallation(splashData, tempRoot);
      }

      // 3. Pasamos los archivos consolidados a la variable que _installSingleMod espera
      await for (final entity in modDir.list(recursive: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (['.bmp', '.jpg', '.jpeg', '.png', '.bat'].contains(ext)) {
            replacedFiles.add(p.basename(entity.path));
          }
        }
      }
    } else {
      // No debería pasar si el clasificador de _processArchives funcionó
      throw Exception(l10n.errorNoCompatibleFilesInArchive);
    }

    if (baseDisplayName == null) {
      throw FormatException(l10n.errorNoValidDisplayName);
    }
    if (installPath == null) {
      throw Exception(l10n.errorInstallPathUndetermined);
    }

    // Si otro mod de Nexus (distinto ID) ya usa este mismo nombre, se
    // diferencia para que no se confunda con él ni comparta carpeta.
    baseDisplayName = _disambiguateAcrossMods(baseDisplayName, nexusId);
    finalFolderName = baseDisplayName;

    // 2. LÓGICA DE REEMPLAZO/ACTUALIZACIÓN
    //    - Misma EDICIÓN (mismo archivo de Nexus o una versión anterior) -> actualizar.
    //    - OTRA edición del mismo mod                                    -> instalar aparte.
    //    - Otro mod con el mismo nombre de archivo                       -> nunca reemplaza.
    ModInfo? oldVersionMod;
    AlternativeVersionAction? action;
    ModInfo? siblingEdition; // edición del mismo mod que ya estaba instalada

    List<ModInfo> nexusIdMatches = [];
    if (nexusId != null) {
      nexusIdMatches = _allMods.where((mod) => mod.nexusId == nexusId).toList();
    }

    if (nexusIdMatches.isNotEmpty) {
      // 1) Mismo archivo de Nexus (mismo file_id) o una versión anterior de él.
      oldVersionMod = await _findInstalledByFileLineage(preparedMod, nexusIdMatches);

      // 2) Si no se pudo por file_id, por el nombre de la EDICIÓN (también
      //    reconoce mods instalados antes de que existieran las ediciones).
      if (oldVersionMod == null) {
        for (final candidateMod in nexusIdMatches) {
          if (_isSameEditionByName(candidateMod, preparedMod, baseDisplayName)) {
            oldVersionMod = candidateMod;
            break;
          }
        }
      }

      if (oldVersionMod != null) {
        action = await _showSmartInstallDialog(
          oldVersionMod: oldVersionMod,
          baseDisplayName: baseDisplayName,
          newVersion: nexusVersion,
        );
      } else if (_isNewEditionOfSameMod(preparedMod)) {
        // Es otra EDICIÓN del mismo mod (p. ej. "CNS" y "Replacer"): se instala
        // aparte sin preguntar, porque Nexus confirma que no es una versión
        // de ninguna de las que ya tienes. Más abajo se avisa al usuario.
        siblingEdition = nexusIdMatches.first;
        action = AlternativeVersionAction.installAsNew;
      } else {
        final existingModExample = nexusIdMatches.first.customName;
        action = await SettingsDialogs.confirm(
          context: context,
          title: l10n.dialogTitleAlternativeVersion,
          message: l10n.dialogContentAlternativeVersion(
            existingModExample,
            baseDisplayName!,
            finalFolderName,
          ),
          confirmLabel: l10n.dialogActionInstallAsNew,
        )
            ? AlternativeVersionAction.installAsNew
            : AlternativeVersionAction.cancel;
      }
    } else {
      for (final existingMod in _allMods) {
        // Un mod de OTRO ID de Nexus nunca es una versión anterior de este.
        final differentNexusMod = existingMod.nexusId != null &&
            nexusId != null &&
            existingMod.nexusId != nexusId;
        if (!differentNexusMod && existingMod.displayName == baseDisplayName) {
          oldVersionMod = existingMod;
          break;
        }
      }
      if (oldVersionMod != null) {
        action = await _showSmartInstallDialog(
          oldVersionMod: oldVersionMod,
          baseDisplayName: baseDisplayName,
          newVersion: nexusVersion,
        );
      }
    }

    if (action != null) {
      switch (action) {
        case AlternativeVersionAction.replace:
          if (oldVersionMod == null) {
            throw Exception(l10n.errorReplaceNoOldVersion);
          }
          final oldInfoFile = File(
            p.join(oldVersionMod.directory.path, 'nexus_info.json'),
          );
          if (await oldInfoFile.exists()) {
            try {
              final oldData = json.decode(await oldInfoFile.readAsString());
              if (oldData['customName'] != null) {
                preservedCustomName = oldData['customName'];
                print('Preserving custom name: $preservedCustomName');
              }
              preservedEndorse ??= EndorseRecord.fromInfo(oldData);
            } catch (e) {
              print('Could not read old custom name. Defaulting. Error: $e');
            }
          }

          final oldModName = oldVersionMod.customName;
          // Si el mod a reemplazar era un 'Movies' habilitado, deshabilítalo primero
          if (oldVersionMod.modType == 'movies' && oldVersionMod.isEnabled) {
            await _disableMod(oldVersionMod);
          }
          final deleted = await FileManagerService.deleteDirectoryWithRetry(
            oldVersionMod.directory,
          );
          if (!deleted) {
            throw Exception(l10n.errorDeleteOldModVersion(oldModName));
          }
          break;
        case AlternativeVersionAction.installAsNew:
          break;
        case AlternativeVersionAction.cancel:
        case null:
        default:
          throw Exception(l10n.statusInstallationCancelledByUser);
      }
    }

    // 3. LÓGICA DE INSTALACIÓN (Esto también se copia)
    final newModPath = p.join(installPath, finalFolderName);

    if (await Directory(newModPath).exists()) {
      final confirmReinstall = await SettingsDialogs.confirm(
          context: context,
          title: l10n.dialogTitleModExists,
          message: l10n.dialogContentModExists(finalFolderName),
          confirmLabel: l10n.dialogActionUpdate,
        );

      if (confirmReinstall != true) {
        throw Exception(l10n.errorInstallModExists);
      } else {
        final oldInfoFile = File(p.join(newModPath, 'nexus_info.json'));
        if (preservedCustomName == null && await oldInfoFile.exists()) {
          try {
            final oldData = json.decode(await oldInfoFile.readAsString());
            if (oldData['customName'] != null) {
              preservedCustomName = oldData['customName'];
              print('Preserving custom name: $preservedCustomName');
            }
            preservedEndorse ??= EndorseRecord.fromInfo(oldData);
          } catch (e) {
            print('Could not read old custom name. Defaulting. Error: $e');
          }
        }
        // Si el mod a reinstalar es un 'Movies' habilitado, deshabilítalo primero
        final modToReinstall = _allMods.firstWhere(
          (m) => m.directory.path == newModPath,
          orElse: () => ModInfo(
            directory: Directory(''),
            lastModified: DateTime.now(),
            isEnabled: false,
            displayName: '',
            customName: '',
          ),
        );
        if (modToReinstall.directory.path.isNotEmpty &&
            modToReinstall.modType == 'movies' &&
            modToReinstall.isEnabled) {
          await _disableMod(modToReinstall);
        }

        final deleted = await FileManagerService.deleteDirectoryWithRetry(Directory(newModPath));
        if (!deleted) {
          throw Exception(
            l10n.errorDeleteExistingModReinstallAttempts(finalFolderName),
          );
        }
      }
    }

    await Directory(newModPath).create(recursive: true);

    // 4. CREAR nexus_info.json (Aquí es donde guardamos la etiqueta)
    // Usamos el nexusId si existe, pero ahora creamos el archivo *siempre*.
    final infoFile = File(p.join(newModPath, 'nexus_info.json'));
    final versionForFile = nexusVersion;

    final Map<String, dynamic> modData = {
      'nexusId': nexusId,
      'displayName': baseDisplayName,
      'customName': preservedCustomName ?? baseDisplayName,
      'installedVersion': versionForFile,
      'nexusFileId': preparedMod.identity?.fileId,
      'modName': preparedMod.nexusModName,
      'editionName': preparedMod.editionName,
      'variantName': preparedMod.variantLabel,
      'nexusFileName': preparedMod.identity?.remoteFileName,
      'identifiedBy': preparedMod.identity?.source.name,
      'installDate': DateTime.now().toIso8601String(),
      'managerVersion': _appVersion,
      'fitMeshType': fitMeshType, // <-- "Generic" o el tipo de CNS
      // Si se detectaron trajes, el mod es de reemplazo (etiqueta "Replacement",
      // mismo valor que escribe el interruptor del panel de detalles).
      'modType': (autoOutfits != null && autoOutfits.isNotEmpty)
          ? 'replacement'
          : modType.name,
      'sourceUrl': nexusId != null
          ? 'https://www.nexusmods.com/stellarblade/mods/$nexusId'
          : null,
      'isEnabled': (modType == ModDirectoryType.movies ||
                    modType == ModDirectoryType.save ||
                    modType == ModDirectoryType.config ||
                    modType == ModDirectoryType.splash)
          ? false
          : null, // Se registran deshabilitados para evitar sobrescrituras accidentales
      'replacedFiles': (modType == ModDirectoryType.movies ||
                        modType == ModDirectoryType.save ||
                        modType == ModDirectoryType.config ||
                        modType == ModDirectoryType.splash)
          ? replacedFiles
          : null,
      'replacesOutfits': autoOutfits ??
          (selectedOutfit != null ? [selectedOutfit] : null),
      // Detección automática: se marca para poder reanalizarlo si el detector
      // mejora (una selección manual no lleva marca y nunca se reescribe).
      if (autoOutfits != null) ...{
        ModMetadataMigrator.outfitsAutoDetectedKey: true,
        'outfitScanSchema': ModMetadataMigrator.outfitScanSchema,
      },
    };
    // Limpia valores nulos para no ensuciar el JSON
    modData.removeWhere((key, value) => value == null);
    preservedEndorse?.applyTo(modData);

    if (nexusId != null) {
      final nexusData = await NexusApiService.fetchNexusModData(nexusId, _apiKey);
      if (nexusData != null) {
        modData['gallery'] = nexusData['gallery'];
        modData['summary'] = nexusData['summary'];
        modData['author'] = nexusData['author'];
        modData['description'] = nexusData['description'];
      }
    }

    final encoder = JsonEncoder.withIndent('  ');
    await infoFile.writeAsString(encoder.convert(modData));

    // 5. COPIAR ARCHIVOS (Usando la función auxiliar que ya tenías)
    List<File> filesToInstall = [];
    if (modType == ModDirectoryType.movies) {
      // Los vídeos se guardan con su ruta relativa (no se aplanan) para poder
      // reproducir exactamente la estructura de Movies al activar el mod.
      for (final movieFile in selectedMovieFiles) {
        final movieDest = File(p.joinAll([newModPath, ...movieFile.rel.split('/')]));
        await movieDest.parent.create(recursive: true);
        await movieFile.file.copy(movieDest.path);
      }
    } else if (modType == ModDirectoryType.save ||
        modType == ModDirectoryType.config ||
        modType == ModDirectoryType.splash) {
      for (final fileName in replacedFiles) {
        filesToInstall.add(File(p.join(modDir.path, fileName)));
      }
    } else {
      filesToInstall = await FileManagerService.findAllModFilesRecursive(modDir);
    }

    for (final file in filesToInstall) {
      final fileName = p.basename(file.path);
      final destinationPath = p.join(newModPath, fileName);
      await file.copy(destinationPath);
      if (nexusId == '801' && p.extension(destinationPath).toLowerCase() == '.bat') {
        if (_gameRootPath != null) {
          try {
            final batFile = File(destinationPath);
            List<String> lines = await batFile.readAsLines();
            List<String> patchedLines = [];

            // Construimos las rutas dinámicas basadas en la instalación real del usuario
            final dynamicSplashDir = p.join(_gameRootPath!, 'SB', 'Content', 'Splash', 'ModSplash', 'SplashImages');
            final dynamicGameSplash = p.join(_gameRootPath!, 'SB', 'Content', 'Splash', 'splash.jpg');
            
            // Buscamos cuál es el ejecutable correcto del juego para este usuario
            String dynamicGameExe = p.join(_gameRootPath!, 'StellarBlade.exe');
            if (!await File(dynamicGameExe).exists()) {
              dynamicGameExe = p.join(_gameRootPath!, 'SB.exe');
            }

            // Reemplazamos línea por línea si coincide con las variables del script
            for (String line in lines) {
              final upperLine = line.trim().toUpperCase();
              if (upperLine.startsWith('SET "SPLASH_DIR=')) {
                patchedLines.add('set "SPLASH_DIR=$dynamicSplashDir"');
              } else if (upperLine.startsWith('SET "GAME_SPLASH=')) {
                patchedLines.add('set "GAME_SPLASH=$dynamicGameSplash"');
              } else if (upperLine.startsWith('SET "GAME_EXE=')) {
                patchedLines.add('set "GAME_EXE=$dynamicGameExe"');
              } else {
                patchedLines.add(line);
              }
            }

            // Guardamos el .bat ya parcheado (con formato de salto de línea de Windows)
            await batFile.writeAsString(patchedLines.join('\r\n'));
            print('Script .bat del Mod 801 parcheado con éxito para este equipo.');
          } catch (e) {
            print('Error al intentar parchear el archivo .bat del Mod 801: $e');
          }
        }
      }
    }

    if (nexusId != null) {
      await ModManagerService.cacheNexusThumbnail(apiKey: _apiKey,
        modDirectory: Directory(newModPath),
        nexusId: nexusId,
      );
    }

    // Si el traje detectado automáticamente ya lo tiene otro mod ACTIVO, avisa
    // y deja elegir cuál queda activo.
    final List<String>? detectedOutfits = autoOutfits;
    if (detectedOutfits != null &&
        detectedOutfits.isNotEmpty &&
        modType == ModDirectoryType.genericPak) {
      try {
        await _resolveInstallOutfitConflict(
          newModPath: newModPath,
          newName: preservedCustomName ?? baseDisplayName ?? finalFolderName,
          outfits: detectedOutfits,
          backupDir: backupDir,
        );
      } catch (e) {
        print('[OutfitConflict] Error al comprobar conflictos: $e');
      }
    }

    // Avisa de que es una edición más de un mod que ya estaba instalado.
    if (siblingEdition != null && mounted) {
      final int editionsNow =
          _allMods.where((m) => m.nexusId == nexusId).length + 1;
      NotificationService.instance.show(
        context: context,
        type: NotificationType.info,
        title: l10n.snackBarNewEditionInstalled(baseDisplayName),
        description: l10n.snackBarNewEditionInstalledDesc(editionsNow),
      );
    }
    return finalFolderName;
  }

  // ---------------------------------------------------------------------------
  //  Errores al activar/desactivar: detecta archivos bloqueados por otra app
  // ---------------------------------------------------------------------------

  /// true si [e] es un bloqueo típico de Windows (acceso denegado / archivo en
  /// uso) al mover la carpeta de un mod: otra aplicación (FModel, el juego, un
  /// antivirus, el Explorador...) tiene abiertos archivos de esa carpeta.
  bool _isFileLockError(Object e) {
    if (e is FileSystemException) {
      final code = e.osError?.errorCode;
      // 5 = acceso denegado, 32 = usado por otro proceso, 33 = bloqueado
      if (code == 5 || code == 32 || code == 33) return true;
      if (e is PathAccessException) return true;
    }
    final msg = e.toString().toLowerCase();
    return msg.contains('errno = 5') ||
        msg.contains('errno = 32') ||
        msg.contains('being used by another process');
  }

  /// Muestra el error de activar/desactivar. Si es un bloqueo de archivos,
  /// avisa de que probablemente otra aplicación está usando los recursos del
  /// juego; si no, muestra el error original.
  void _reportToggleError(Object e, {required bool enabling}) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (_isFileLockError(e)) {
      setState(() {
        _statusMessage = l10n.fileLockErrorMessage;
        _statusColor = Colors.redAccent;
      });
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.fileLockErrorTitle,
        description: l10n.fileLockErrorMessage,
      );
      return;
    }

    final msg = enabling ? l10n.errorEnableMod(e.toString()) : l10n.errorDisableMod(e.toString());
    setState(() {
      _statusMessage = msg;
      _statusColor = Colors.redAccent;
    });
    NotificationService.instance.show(
      context: context,
      type: NotificationType.error,
      title: l10n.errorDialogTitle,
      description: e.toString(),
    );
  }

  Future<bool> _enableMod(ModInfo modInfo) async {
    final l10n = AppLocalizations.of(context)!;
    if (_finalModsPath == null ||
        _genericModsPath == null ||
        _logicModsPath == null)
      return false;

    if (modInfo.nexusId == '529') {
      final activeMovieMods = _allMods
          .where((m) => m.isEnabled && m.modType == 'movies' && m.directory.path != modInfo.directory.path)
          .toList();
      
      for (final movieMod in activeMovieMods) {
        print(l10n.logDisablingMovieMod(movieMod.customName));
        await _disableMod(movieMod);
      }
    }
    if (modInfo.nexusId == '801') {
      final activeSplashMods = _allMods
          .where((m) => m.isEnabled && m.modType == 'splash' && m.directory.path != modInfo.directory.path)
          .toList();
      
      for (final splashMod in activeSplashMods) {
        print(l10n.logDisablingSplashMod(splashMod.customName));
        await _disableMod(splashMod);
      }
    }

    final List<String> outfitsToReplace = modInfo.replacesOutfits ?? [];
    final bool isReplacementMod = outfitsToReplace.isNotEmpty;

    if (isReplacementMod) {
      ModInfo? conflictingMod;
      List<String> overlappingOutfits = [];

      try {
        for (final otherMod in _allMods) {
          if (otherMod.isEnabled && otherMod.directory.path != modInfo.directory.path) {
            final otherOutfits = otherMod.replacesOutfits ?? [];
            // Busca la intersección (trajes que ambos mods intentan usar)
            final intersection = outfitsToReplace.where((o) => otherOutfits.contains(o)).toList();
            
            if (intersection.isNotEmpty) {
              conflictingMod = otherMod;
              overlappingOutfits = intersection;
              break; // ¡Conflicto encontrado!
            }
          }
        }
      } catch (e) {
        conflictingMod = null;
      }

      if (conflictingMod != null) {
        final l10n = AppLocalizations.of(context)!;
        // Une los nombres con coma si hay múltiples conflictos
        final String outfitName = overlappingOutfits.join(', ');
        final String modName = conflictingMod.customName;

        // Obtenemos el texto completo de la localización
        final String fullString = l10n.dialogContentOutfitConflict(
          outfitName,
          modName,
        );

        // Dividimos el texto usando los nombres como separadores
        final List<String> parts = fullString.split(outfitName);
        final String part1 = parts.isNotEmpty ? parts[0] : "";

        String part2 = "";
        String part3 = "";

        if (parts.length > 1) {
          // Buscamos el nombre del mod en la segunda parte del texto
          final List<String> parts2 = parts[1].split(modName);
          part2 = parts2.isNotEmpty ? parts2[0] : "";
          if (parts2.length > 1) {
            part3 = parts2[1];
          }
        }

        // Ahora el diálogo devuelve un booleano (true = forzar activación)
        final bool? forceActivate = await _showOutfitConflictDialog(
          part1: part1,
          outfitName: outfitName,
          part2: part2,
          modName: modName,
          part3: part3,
          conflictingMod: conflictingMod,
        );

        // Si el usuario no forzó la activación (canceló)
        if (forceActivate != true) {
          return false;
        }

        // Si el usuario SÍ forzó la activación, desactiva el mod conflictivo
        // antes de continuar con la activación del nuevo.
        final bool disabled = await _disableMod(conflictingMod);
        if (!disabled) {
          // Si no se pudo deshabilitar el mod conflictivo,
          // cancela la activación del nuevo.
          return false;
        }
        // ++ FIN DE LA MODIFICACIÓN DEL DIÁLOGO ++
      }
    }
    //setState(() => _isLoading = true);

    try {
      ModInfo updatedMod;

      // --- INICIO DE LÓGICA DE BIFURCACIÓN ---
      if (modInfo.modType == 'movies') {
        await _enableMovieMod(modInfo, _allMods);
        updatedMod = modInfo.copyWith(isEnabled: true);
      } else if (modInfo.modType == 'save') {
        await _enableCustomFileMod(modInfo, _savesPath!, _savesBackupPath!);
        updatedMod = modInfo.copyWith(isEnabled: true);
      } else if (modInfo.modType == 'config') {
        await _enableCustomFileMod(modInfo, _configPath!, _configBackupPath!);
        updatedMod = modInfo.copyWith(isEnabled: true);
      } else if (modInfo.modType == 'splash') {
        await _enableSplashMod(modInfo, _allMods);
        
        // Creación requerida de la carpeta "ModSplash" específica para el mod 801
        if (modInfo.nexusId == '801' && _splashPath != null) {
          final modSplashDir = Directory(p.join(_splashPath!, 'ModSplash'));
          if (!await modSplashDir.exists()) {
            await modSplashDir.create(recursive: true);
          }
        }
        
        updatedMod = modInfo.copyWith(isEnabled: true);
      } else {
        // LÓGICA DE MOVIMIENTO DE CARPETA (CNS/GENÉRICO)
        final modName = p.basename(modInfo.directory.path);

        final backupContainerDir = modInfo.directory;

        // ++ INICIO DE LA MODIFICACIÓN ++
        // 1. Restaurar componentes adicionales (logic, o genérico con UE4SS)
        if (_canHaveExtraParts(modInfo)) {
          // Leer el JSON desde su ubicación actual (dentro del respaldo)
          final infoFile = File(
            p.join(backupContainerDir.path, 'nexus_info.json'),
          );
          if (await infoFile.exists()) {
            try {
              final data = json.decode(await infoFile.readAsString());

              // 2. Restaurar Parte C (~mods component)
              final String? tildeFolder = data['tildeModsComponentFolder'];
              if (tildeFolder != null && _genericModsPath != null) {
                // Origen: __MOD_BACKUPS__/<mod_name>/_tilde_mods/<mod_name>
                final tildeBackupContainer = Directory(
                  p.join(backupContainerDir.path, "_tilde_mods"),
                );
                final tildeSourceDir = Directory(
                  p.join(tildeBackupContainer.path, tildeFolder),
                );

                if (await tildeSourceDir.exists()) {
                  print(l10n.logRestoringTildeComponent(tildeFolder));
                  // Mover de vuelta a .../Paks/~mods/
                  await FileManagerService.moveMod(tildeSourceDir, _genericModsPath!);
                  // Limpiar la carpeta contenedora vacía
                  if (await tildeBackupContainer.list().isEmpty)
                    await tildeBackupContainer.delete();
                }
              }

              // 3. Restaurar Parte B (UE4SS components)
              final List<dynamic>? ue4ssFolders = data['ue4ssComponents'];
              if (ue4ssFolders != null && _ue4ssModsPath != null) {
                // Origen: __MOD_BACKUPS__/<mod_name>/_ue4ss_mods/
                final ue4ssBackupContainer = Directory(
                  p.join(backupContainerDir.path, "_ue4ss_mods"),
                );

                for (final folderName in ue4ssFolders.cast<String>()) {
                  // Origen: .../_ue4ss_mods/<component_name>
                  final ue4ssSourceDir = Directory(
                    p.join(ue4ssBackupContainer.path, folderName),
                  );
                  if (await ue4ssSourceDir.exists()) {
                    print(l10n.logRestoringUe4ssComponent(folderName));
                    // Mover de vuelta a .../ue4ss/Mods/
                    await FileManagerService.moveMod(ue4ssSourceDir, _ue4ssModsPath!);
                  }
                }
                // Limpiar la carpeta contenedora vacía
                if (await ue4ssBackupContainer.list().isEmpty)
                  await ue4ssBackupContainer.delete();
              }

              final List<dynamic>? ue4ssLooseFiles = data['ue4ssLooseFiles'];
              if (ue4ssLooseFiles != null && _ue4ssModsPath != null) {
                final ue4ssRootDestPath = p.dirname(_ue4ssModsPath!);
                final looseFilesBackupContainer = Directory(p.join(backupContainerDir.path, "_ue4ss_loose_files"));
                final originalsBackupDir = Directory(p.join(backupContainerDir.path, "_ue4ss_originals"));

                for (final fileName in ue4ssLooseFiles.cast<String>()) {
                  final activeGameFile = File(p.join(ue4ssRootDestPath, fileName));

                  // Resguardo de seguridad preventivo si no existiera backup original previo
                  if (await activeGameFile.exists()) {
                    if (!await originalsBackupDir.exists()) await originalsBackupDir.create(recursive: true);
                    final backupOriginal = File(p.join(originalsBackupDir.path, fileName));
                    if (!await backupOriginal.exists()) {
                      await activeGameFile.copy(backupOriginal.path);
                    }
                  }

                  // Volvemos a colocar el archivo personalizado del mod en el juego
                  final modCustomFile = File(p.join(looseFilesBackupContainer.path, fileName));
                  if (await modCustomFile.exists()) {
                    await modCustomFile.rename(activeGameFile.path);
                  }
                }
                if (await looseFilesBackupContainer.exists() && await looseFilesBackupContainer.list().isEmpty) {
                  await looseFilesBackupContainer.delete();
                }
              }
            } catch (e) {
              print(l10n.logErrorRestoringLogicMod(e.toString()));
            }
          }
        }

        String modType = modInfo.modType ?? 'cns'; // Usa el tipo del ModInfo

        final String targetPath;
        if (modType == 'genericPak' || modType == 'replacement') {
          targetPath = _genericModsPath!;
        } else if (modType == 'logicMod') {
          targetPath = _logicModsPath!; // RUTA NUEVA
        } else {
          targetPath = _finalModsPath!; // Default a CNS para los cns puros
        }

        final newDirectory = Directory(p.join(targetPath, modName));
        // HD-ATOOL: si ya hay una carpeta HD-ATOOL_P suelta (audios de otros
        // mods activos), se funde antes de mover para no perder nada.
        if (modInfo.modType == 'logicMod' && modName == HdAtoolAudio.toolFolder) {
          await HdAtoolAudio.absorbStrayToolFolder(newDirectory, backupContainerDir);
        }
        await FileManagerService.moveMod(backupContainerDir, targetPath);

        // Audios de HD-ATOOL: volver a colocarlos en LogicMods/HD-ATOOL_P/audio
        if (modInfo.modType == 'logicMod') {
          await HdAtoolAudio.activate(
            newDirectory,
            HdAtoolAudio.gameAudioPath(_logicModsPath!),
          );
        }

        updatedMod = modInfo.copyWith(directory: newDirectory, isEnabled: true);
      }
      // --- FIN DE LÓGICA DE BIFURCACIÓN ---

      final modIndex = _allMods.indexWhere(
        (m) => m.directory.path == modInfo.directory.path,
      );
      if (modIndex != -1) {
        setState(() {
          _allMods[modIndex] = updatedMod;
        });
      } else {
        await _loadAllMods();
      }
      return true;
    } catch (e, st) {
      print('[ModToggle] enable ${modInfo.directory.path}: $e\n$st');
      // clearHighlight:false evita que la recarga pise el mensaje de error.
      await _loadAllMods(clearHighlight: false);
      _reportToggleError(e, enabling: true);
      return false;
    } finally {
      //setState(() => _isLoading = false);
    }
  }

  Future<bool> _disableMod(ModInfo modInfo) async {
    final l10n = AppLocalizations.of(context)!;
    if (_gameRootPath == null) return false;
    //setState(() => _isLoading = true);

    if (modInfo.nexusId == '529') {
      final activeMovieMods = _allMods
          .where((m) => m.isEnabled && m.modType == 'movies' && m.directory.path != modInfo.directory.path)
          .toList();
      
      for (final movieMod in activeMovieMods) {
        print("Desactivando mod de película preventivamente por apagado del Mod 529: ${movieMod.customName}");
        await _disableMod(movieMod);
      }
    }
    if (modInfo.nexusId == '801') {
      final activeSplashMods = _allMods
          .where((m) => m.isEnabled && m.modType == 'splash' && m.directory.path != modInfo.directory.path)
          .toList();
      
      for (final splashMod in activeSplashMods) {
        print("Desactivando mod splash preventivamente por activación del Mod 801: ${splashMod.customName}");
        await _disableMod(splashMod);
      }
    }

    try {
      final backupDir = Directory(
        p.join(_gameRootPath!, 'SB', 'Content', '__MOD_BACKUPS__'),
      );
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      ModInfo updatedMod;

      // --- INICIO DE LÓGICA DE BIFURCACIÓN ---
      if (modInfo.modType == 'movies') {
        await _disableMovieMod(modInfo);
        updatedMod = modInfo.copyWith(isEnabled: false);
      } else if (modInfo.modType == 'save') {
        await _disableCustomFileMod(modInfo, _savesPath!, _savesBackupPath!);
        updatedMod = modInfo.copyWith(isEnabled: false);
      } else if (modInfo.modType == 'config') {
        await _disableCustomFileMod(modInfo, _configPath!, _configBackupPath!);
        updatedMod = modInfo.copyWith(isEnabled: false);
      } else if (modInfo.modType == 'splash') {
        await _disableSplashMod(modInfo);
        updatedMod = modInfo.copyWith(isEnabled: false);
      } else {
        // LÓGICA DE MOVIMIENTO DE CARPETA (CNS/GENÉRICO)
        final modName = p.basename(modInfo.directory.path);
        final newDirectory = Directory(p.join(backupDir.path, modName));
        // 1. Mover Parte A (La carpeta principal, ej: LogicMods/<mod_name>)
        await FileManagerService.moveMod(modInfo.directory, backupDir.path);

        // Audios de HD-ATOOL: quitarlos del juego y restaurar los originales
        if (modInfo.modType == 'logicMod' && _logicModsPath != null) {
          await HdAtoolAudio.deactivate(
            newDirectory,
            HdAtoolAudio.gameAudioPath(_logicModsPath!),
          );
        }

        // ++ INICIO DE LA MODIFICACIÓN ++
        // 2. Mover componentes adicionales (logic, o genérico con UE4SS)
        if (_canHaveExtraParts(modInfo)) {
          // Leer el JSON desde su *nueva* ubicación (dentro del respaldo)
          final infoFile = File(p.join(newDirectory.path, 'nexus_info.json'));
          if (await infoFile.exists()) {
            try {
              final data = json.decode(await infoFile.readAsString());

              // 3. Mover Parte C (~mods component)
              final String? tildeFolder = data['tildeModsComponentFolder'];
              if (tildeFolder != null && _genericModsPath != null) {
                final tildeSourceDir = Directory(
                  p.join(_genericModsPath!, tildeFolder),
                );
                // Destino: __MOD_BACKUPS__/<mod_name>/_tilde_mods/
                final tildeDestContainer = Directory(
                  p.join(newDirectory.path, "_tilde_mods"),
                );
                if (!await tildeDestContainer.exists())
                  await tildeDestContainer.create();

                if (await tildeSourceDir.exists()) {
                  print(l10n.logArchivingTildeComponent(tildeFolder));
                  await FileManagerService.moveMod(tildeSourceDir, tildeDestContainer.path);
                }
              }

              // 4. Mover Parte B (UE4SS components)
              final List<dynamic>? ue4ssFolders = data['ue4ssComponents'];
              if (ue4ssFolders != null && _ue4ssModsPath != null) {
                // Destino: __MOD_BACKUPS__/<mod_name>/_ue4ss_mods/
                final ue4ssDestContainer = Directory(
                  p.join(newDirectory.path, "_ue4ss_mods"),
                );
                if (!await ue4ssDestContainer.exists())
                  await ue4ssDestContainer.create();

                for (final folderName in ue4ssFolders.cast<String>()) {
                  final ue4ssSourceDir = Directory(
                    p.join(_ue4ssModsPath!, folderName),
                  );
                  if (await ue4ssSourceDir.exists()) {
                    print(l10n.logArchivingUe4ssComponent(folderName));
                    await FileManagerService.moveMod(ue4ssSourceDir, ue4ssDestContainer.path);
                  }
                }
              }
              final List<dynamic>? ue4ssLooseFiles = data['ue4ssLooseFiles'];
              if (ue4ssLooseFiles != null && _ue4ssModsPath != null) {
                final ue4ssRootDestPath = p.dirname(_ue4ssModsPath!);
                final looseFilesBackupContainer = Directory(p.join(newDirectory.path, "_ue4ss_loose_files"));
                if (!await looseFilesBackupContainer.exists()) await looseFilesBackupContainer.create(recursive: true);
                final originalsBackupDir = Directory(p.join(newDirectory.path, "_ue4ss_originals"));

                for (final fileName in ue4ssLooseFiles.cast<String>()) {
                  final activeGameFile = File(p.join(ue4ssRootDestPath, fileName));
                  if (await activeGameFile.exists()) {
                    // Guardamos la configuración personalizada del mod en la carpeta de respaldos
                    await activeGameFile.rename(p.join(looseFilesBackupContainer.path, fileName));
                  }

                  // Restauramos el archivo original intacto de vuelta al juego
                  final originalFile = File(p.join(originalsBackupDir.path, fileName));
                  if (await originalFile.exists()) {
                    await originalFile.copy(activeGameFile.path);
                  }
                }
              }
            } catch (e) {
              print(l10n.logErrorArchivingLogicMod(e.toString()));
            }
          }
        }

        updatedMod = modInfo.copyWith(
          directory: newDirectory,
          isEnabled: false,
        );
      }
      // --- FIN DE LÓGICA DE BIFURCACIÓN ---

      final modIndex = _allMods.indexWhere(
        (m) => m.directory.path == modInfo.directory.path,
      );
      if (modIndex != -1) {
        setState(() {
          _allMods[modIndex] = updatedMod;
        });
      } else {
        await _loadAllMods();
      }
      return true;
    } catch (e, st) {
      print('[ModToggle] disable ${modInfo.directory.path}: $e\n$st');
      // clearHighlight:false evita que la recarga pise el mensaje de error.
      await _loadAllMods(clearHighlight: false);
      _reportToggleError(e, enabling: false);
      return false;
    } finally {
      //setState(() => _isLoading = false);
    }
  }

  /// Texto de error de un [MovieModException] (usa los textos ya traducidos cuando existen).
  String _movieErrorText(MovieModException e, AppLocalizations l10n) {
    switch (e.code) {
      case MovieErrorCode.pathsNotDefined:
        return l10n.errorMoviesPathsNotDefined;
      case MovieErrorCode.noValidFiles:
        return l10n.errorMoviesModNoValidFiles;
      case MovieErrorCode.requires529:
        return l10n.errorModRequires529;
      case MovieErrorCode.menuLimit:
        return l10n.errorMenuVideoLimitReached;
      case MovieErrorCode.backupFailed:
        return 'Could not back up the original movie (${e.detail}). Nothing was changed.';
      case MovieErrorCode.verifyFailed:
        return 'The copied movie did not pass verification (${e.detail}). Nothing was changed.';
      case MovieErrorCode.copyFailed:
        return 'Could not write the movie files (${e.detail}). Close the game and try again.';
    }
  }

  /// Lógica específica para HABILITAR un mod de tipo "Movies".
  ///
  ///  - Reemplaza los vídeos originales de Movies (con respaldo previo) y anexa los nuevos.
  ///  - Si otro mod de películas activo ocupa alguno de esos archivos, se desactiva ENTERO
  ///    antes de aplicar (así sus originales se restauran y el respaldo es siempre el original).
  ///  - Con el Mod 529 activo, los vídeos "de menú" van a Movies/Menu/menu_N.
  ///  - Es transaccional: si algo falla, se deshace lo ya copiado.
  Future<void> _enableMovieMod(ModInfo modInfo, List<ModInfo> allMods) async {
    final l10n = AppLocalizations.of(context)!;
    if (_moviesPath == null || _moviesBackupPath == null) {
      throw Exception(l10n.errorMoviesPathsNotDefined);
    }

    final infoFile = File(p.join(modInfo.directory.path, 'nexus_info.json'));
    if (!await infoFile.exists()) {
      throw Exception(l10n.errorNexusInfoNotFoundForMod(modInfo.customName));
    }

    final data = Map<String, dynamic>.from(json.decode(await infoFile.readAsString()));
    final List<String> rawFiles = List<String>.from(data['replacedFiles'] ?? []);
    final moviesDir = Directory(_moviesPath!);
    final backupDir = Directory(_moviesBackupPath!);

    // Verificamos dinámicamente si el Mod 529 está presente y activado
    final bool hasMod529 = allMods.any((m) => m.nexusId == '529' && m.isEnabled);

    try {
      // 1) Qué ocupan ahora los demás mods de películas activos
      final otherEntries = <String, List<MovieInstalledEntry>>{};
      for (final other in allMods) {
        if (other.directory.path == modInfo.directory.path ||
            !other.isEnabled ||
            other.modType != 'movies') {
          continue;
        }
        try {
          final otherInfo = File(p.join(other.directory.path, 'nexus_info.json'));
          if (!await otherInfo.exists()) continue;
          final otherData = Map<String, dynamic>.from(json.decode(await otherInfo.readAsString()));
          otherEntries[other.directory.path] = MovieModsHandler.entriesFromInfo(otherData);
        } catch (e) {
          print('Error reading movie mod state: $e');
        }
      }
      final ownedAdd = <String>{};
      for (final entries in otherEntries.values) {
        ownedAdd.addAll(MovieModsHandler.ownedAddKeys(entries));
      }

      // 2) Plan (no toca el disco)
      final plan = await MovieModsHandler.buildPlan(
        modDir: modInfo.directory,
        files: rawFiles,
        hasMod529: hasMod529,
        moviesDir: moviesDir,
        ownedAddKeys: ownedAdd,
      );
      if (plan.isEmpty) {
        throw MovieModException(
          hasMod529 ? MovieErrorCode.noValidFiles : MovieErrorCode.requires529,
        );
      }

      // 3) Exclusividad: se desactiva cualquier mod activo que pise alguno de estos archivos
      final targetKeys = plan.rootKeys;
      for (final other in allMods) {
        final entries = otherEntries[other.directory.path];
        if (entries == null) continue;
        if (MovieModsHandler.ownedRootKeys(entries).any(targetKeys.contains)) {
          print('Disabling conflicting movie mod: ${other.customName}');
          await _disableMovieMod(other);
          final modIndex = allMods.indexWhere((m) => m.directory.path == other.directory.path);
          if (modIndex != -1) allMods[modIndex] = other.copyWith(isEnabled: false);
        }
      }

      // 4) Respaldo + copia verificada (con rollback si falla)
      final installed = await MovieModsHandler.apply(
        plan: plan,
        moviesDir: moviesDir,
        backupDir: backupDir,
        modDir: modInfo.directory,
      );

      data['isEnabled'] = true;
      data['isMenuMode'] = installed.any((e) => e.isMenu);
      data['activeInstalledFiles'] = installed.map((e) => e.rel).toList();
      data['movieInstall'] = {
        'schema': 2,
        'entries': installed.map((e) => e.toJson()).toList(),
      };
      final encoder = JsonEncoder.withIndent('  ');
      await infoFile.writeAsString(encoder.convert(data));
    } on MovieModException catch (e) {
      throw Exception(_movieErrorText(e, l10n));
    }
  }

  /// Lógica específica para DESHABILITAR un mod de tipo "Movies".
  /// Restaura los originales desde el respaldo y borra lo que el mod anexó.
  Future<void> _disableMovieMod(ModInfo modInfo) async {
    final l10n = AppLocalizations.of(context)!;
    if (_moviesPath == null || _moviesBackupPath == null) {
      throw Exception(l10n.errorMoviesPathsNotDefined);
    }

    final infoFile = File(p.join(modInfo.directory.path, 'nexus_info.json'));
    if (!await infoFile.exists()) {
      throw Exception(l10n.errorNexusInfoNotFoundForMod(modInfo.customName));
    }

    final data = Map<String, dynamic>.from(json.decode(await infoFile.readAsString()));
    final entries = MovieModsHandler.entriesFromInfo(data);

    try {
      final report = await MovieModsHandler.remove(
        entries: entries,
        moviesDir: Directory(_moviesPath!),
        backupDir: Directory(_moviesBackupPath!),
      );
      if (report.missingBackups.isNotEmpty && mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: modInfo.customName,
          description:
              'The backup of the original movie is missing for: ${report.missingBackups.join(', ')}. '
              'The file was left untouched; use "Verify integrity of game files" in Steam to restore it.',
        );
      }
    } on MovieModException catch (e) {
      throw Exception(_movieErrorText(e, l10n));
    }

    data['isEnabled'] = false;
    data.remove('activeInstalledFiles'); // Limpiamos el rastro
    data.remove('movieInstall');
    data.remove('isMenuMode');
    final encoder = JsonEncoder.withIndent('  ');
    await infoFile.writeAsString(encoder.convert(data));
  }

  /// Comprueba que los mods de películas marcados como activos siguen realmente
  /// aplicados en el juego (Steam "verificar archivos", actualización, borrado manual).
  /// Si no, se desactivan limpiamente para que el estado de la app sea real.
  Future<void> _reconcileMovieMods() async {
    if (_moviesPath == null || _moviesBackupPath == null) return;
    final activeMovieMods =
        _allMods.where((m) => m.modType == 'movies' && m.isEnabled).toList();
    if (activeMovieMods.isEmpty) return;

    bool changed = false;
    for (final mod in activeMovieMods) {
      try {
        final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
        if (!await infoFile.exists()) continue;
        final data = Map<String, dynamic>.from(json.decode(await infoFile.readAsString()));
        final stillApplied = await MovieModsHandler.isStillApplied(
          entries: MovieModsHandler.entriesFromInfo(data),
          moviesDir: Directory(_moviesPath!),
          modDir: mod.directory,
        );
        if (stillApplied) continue;

        print('Movie mod no longer applied in the game, disabling: ${mod.customName}');
        await _disableMovieMod(mod);
        final i = _allMods.indexWhere((m) => m.directory.path == mod.directory.path);
        if (i != -1) {
          _allMods[i] = mod.copyWith(isEnabled: false);
          changed = true;
        }
      } catch (e) {
        print('Error verifying movie mod ${mod.customName}: $e');
      }
    }
    if (changed && mounted) setState(() {});
  }

  /// Lógica específica para HABILITAR un mod de tipo "Splash".
  Future<void> _enableSplashMod(ModInfo modInfo, List<ModInfo> allMods) async {
    if (_splashPath == null || _splashBackupPath == null) {
      throw Exception(AppLocalizations.of(context)!.errorSplashPathsNotDefined);
    }

    final infoFile = File(p.join(modInfo.directory.path, 'nexus_info.json'));
    if (!await infoFile.exists()) {
      throw Exception(AppLocalizations.of(context)!.errorNexusInfoNotFoundForMod(modInfo.customName));
    }

    final data = json.decode(await infoFile.readAsString());
    final List<String> rawFiles = List<String>.from(data['replacedFiles'] ?? []);
    
    // Verificamos si el Mod 801 está activo (excepto si el mod que estamos instalando ES el 801)
    final bool hasMod801 = allMods.any((m) => m.nexusId == '801' && m.isEnabled) || modInfo.nexusId == '801';
    
    List<String> actuallyInstalledFiles = [];

    // Ignorar la lógica de imágenes si el mod es el propio Mod 801 (solo instala el .bat)
    if (modInfo.nexusId == '801') {
       for (final fileName in rawFiles) {
          final sourceFile = File(p.join(modInfo.directory.path, fileName));
          
          if (p.extension(fileName).toLowerCase() == '.bat') {
             // 1. Apuntamos a la carpeta ModSplash
             final modSplashDir = Directory(p.join(_splashPath!, 'ModSplash'));
             if (!await modSplashDir.exists()) {
               await modSplashDir.create(recursive: true);
             }
             
             // 2. Definimos el destino FINAL dentro de ModSplash
             final targetFile = File(p.join(modSplashDir.path, fileName));
             
             // 3. Copiamos el archivo .bat
             await sourceFile.copy(targetFile.path);
             
             // 4. Guardamos el registro con la ruta relativa 'ModSplash\nombre_del_archivo.bat'
             // Esto es crucial para que la función de desactivar sepa dónde encontrarlo.
             actuallyInstalledFiles.add(p.join('ModSplash', fileName));
          }
       }
       data['isRandomizerMode'] = false; // El 801 es la base, no el contenido
    }
    else if (hasMod801) {
      // ==== MODO RANDOMIZER (Mod 801 Activo) ====
      final imagesDir = Directory(p.join(_splashPath!, 'ModSplash', 'SplashImages'));
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

      for (final relativePath in rawFiles) {
        final sourceFile = File(p.join(modInfo.directory.path, relativePath));
        if (await sourceFile.exists() && ['.bmp', '.jpg', '.jpeg', '.png'].contains(p.extension(sourceFile.path).toLowerCase())) {
          var ext = p.extension(sourceFile.path).toLowerCase();
          
          // Forzar la extensión a .jpg si el archivo original es .bmp
          if (ext == '.bmp') {
            ext = '.jpg';
          }

          // Se calcula el índice dentro del bucle para detectar y llenar huecos correctamente
          // por cada archivo individual, evitando sobreescrituras si el mod tiene varias imágenes.
          int nextIndex = await SplashModsHandler.getNextAvailableIndex(imagesDir);
          
          final newName = 'splash_$nextIndex$ext';
          final targetFile = File(p.join(imagesDir.path, newName));
          
          await sourceFile.copy(targetFile.path);
          actuallyInstalledFiles.add(newName);
        }
      }
      data['isRandomizerMode'] = true;

    } else {
      // ==== MODO CLÁSICO REEMPLAZO (Sin Mod 801) ====
      List<File> fileObjects = rawFiles
        .map((path) => File(p.join(modInfo.directory.path, path)))
        .where((f) => f.existsSync())
        .toList();

      final mappings = SplashModsHandler.mapFilesForClassicReplacement(fileObjects);
      
      if (mappings.isEmpty) throw Exception(AppLocalizations.of(context)!.errorSplashNoValidImages);

      for (var entry in mappings.entries) {
        final sourceFile = entry.key;
        final targetName = entry.value; 
        final gameFile = File(p.join(_splashPath!, targetName));
        final backupFile = File(p.join(_splashBackupPath!, '$targetName.bak'));

        if (await gameFile.exists() && !await backupFile.exists()) {
          await gameFile.copy(backupFile.path);
        }

        await sourceFile.copy(gameFile.path);
        actuallyInstalledFiles.add(targetName);
      }
      data['isRandomizerMode'] = false;
    }

    data['isEnabled'] = true;
    data['activeInstalledFiles'] = actuallyInstalledFiles; 
    final encoder = JsonEncoder.withIndent('  ');
    await infoFile.writeAsString(encoder.convert(data));
  }

  /// Lógica específica para DESHABILITAR un mod de tipo "Splash".
  Future<void> _disableSplashMod(ModInfo modInfo) async {
    if (_splashPath == null || _splashBackupPath == null) {
      throw Exception(AppLocalizations.of(context)!.errorSplashPathsNotDefined);
    }

    final infoFile = File(p.join(modInfo.directory.path, 'nexus_info.json'));
    if (!await infoFile.exists()) return;

    final data = json.decode(await infoFile.readAsString());
    final bool isRandomizerMode = data['isRandomizerMode'] ?? false;
    final List<String> activeFiles = List<String>.from(data['activeInstalledFiles'] ?? []);

    if (modInfo.nexusId == '801') {
       // Eliminar el archivo .bat
       for (final relativePath in activeFiles) {
          final installedFile = File(p.join(_splashPath!, relativePath));
          if (await installedFile.exists()) await installedFile.delete();
       }
    }
    else if (isRandomizerMode) {
      // ==== MODO RANDOMIZER ====
      final imagesDir = Directory(p.join(_splashPath!, 'ModSplash', 'SplashImages'));
      if (await imagesDir.exists()) {
        for (final fileName in activeFiles) {
          final installedFile = File(p.join(imagesDir.path, fileName));
          if (await installedFile.exists()) await installedFile.delete();
        }
      }
    } else {
      // ==== MODO REEMPLAZO CLÁSICO ====
      for (final fileName in activeFiles) {
        final gameFile = File(p.join(_splashPath!, fileName));
        final backupFile = File(p.join(_splashBackupPath!, '$fileName.bak'));

        if (await backupFile.exists()) {
          await backupFile.copy(gameFile.path);
        } else if (await gameFile.exists()) {
          await gameFile.delete();
        }
      }
    }

    data['isEnabled'] = false;
    data.remove('activeInstalledFiles'); 
    final encoder = JsonEncoder.withIndent('  ');
    await infoFile.writeAsString(encoder.convert(data));
  }

  Future<void> _enableCustomFileMod(ModInfo modInfo, String targetPath, String backupPath) async {
    final l10n = AppLocalizations.of(context)!;
    final infoFile = File(p.join(modInfo.directory.path, 'nexus_info.json'));
    if (!await infoFile.exists()) {
      throw Exception(l10n.errorNexusInfoNotFoundForMod(modInfo.customName));
    }

    final data = json.decode(await infoFile.readAsString());
    final List<String> files = List<String>.from(data['replacedFiles'] ?? []);

    // Asegurar que el directorio de copias de seguridad exista
    final backupDir = Directory(backupPath);
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    for (final fileName in files) {
      final gameFile = File(p.join(targetPath, fileName));
      // Guardamos el archivo con su nombre original (ej: Engine.ini) en la carpeta de backup
      final backupFile = File(p.join(backupPath, fileName));
      final sourceFile = File(p.join(modInfo.directory.path, fileName));

      // Si el archivo original existe en el juego y no hay un respaldo previo, lo copiamos tal cual
      if (await gameFile.exists() && !await backupFile.exists()) {
        await gameFile.copy(backupFile.path);
      }

      // Inyectamos el archivo modificado del mod
      if (await sourceFile.exists()) {
        if (await gameFile.exists()) {
          // Muchos .ini del juego quedan en "Solo lectura" (los mods de config lo
          // recomiendan): sin quitarlo, el borrado/sobrescritura falla.
          if (Platform.isWindows) {
            try {
              await Process.run('attrib', ['-R', gameFile.path]);
            } catch (_) {}
          }
          await gameFile.delete(); // Eliminar para evitar bloqueos de escritura de Windows/Unreal
        }
        await sourceFile.copy(gameFile.path);
      }
    }

    data['isEnabled'] = true;
    final encoder = JsonEncoder.withIndent('  ');
    await infoFile.writeAsString(encoder.convert(data));
  }

  Future<void> _disableCustomFileMod(ModInfo modInfo, String targetPath, String backupPath) async {
    final l10n = AppLocalizations.of(context)!;
    final infoFile = File(p.join(modInfo.directory.path, 'nexus_info.json'));
    if (!await infoFile.exists()) {
      throw Exception(l10n.errorNexusInfoNotFoundForMod(modInfo.customName));
    }

    final data = json.decode(await infoFile.readAsString());
    final List<String> files = List<String>.from(data['replacedFiles'] ?? []);

    for (final fileName in files) {
      final gameFile = File(p.join(targetPath, fileName));
      final backupFile = File(p.join(backupPath, fileName));

      if (await backupFile.exists()) {
        // 1. Quitar el bloqueo de "Solo lectura" de Windows (Muy común en los .ini)
        if (Platform.isWindows) {
          try {
            await Process.run('attrib', ['-R', gameFile.path]);
          } catch (_) {} // Lo ignoramos si la consola no responde
        }

        // 2. Eliminar de forma segura el archivo inyectado
        if (await gameFile.exists()) {
          try {
            await gameFile.delete();
          } catch (e) {
            print(AppLocalizations.of(context)!.logWarningDeleteModifiedFile(e.toString()));
          }
        }
        
        // 3. Restaurar original y borrar temporal (Con sistema anti-fallos)
        try {
          await backupFile.copy(gameFile.path);
          await backupFile.delete();
        } catch (e) {
          print(AppLocalizations.of(context)!.logFallbackByteCopy(e.toString()));
          // Fallback: Fuerza bruta leyendo y escribiendo los bytes directamente
          final bytes = await backupFile.readAsBytes();
          await gameFile.writeAsBytes(bytes);
          await backupFile.delete();
        }
      } else {
        // Si no existía original, borramos el archivo inyectado (con desbloqueo previo)
        if (await gameFile.exists()) {
           if (Platform.isWindows) {
              try { await Process.run('attrib', ['-R', gameFile.path]); } catch (_) {}
           }
           try { await gameFile.delete(); } catch (_) {}
        }
      }
    }

    data['isEnabled'] = false;
    final encoder = JsonEncoder.withIndent('  ');
    await infoFile.writeAsString(encoder.convert(data));
  }

  Future<void> _deleteModPermanently(ModInfo modInfo) async {
    final l10n = AppLocalizations.of(context)!;

    // Validación de seguridad: bloquea la eliminación si el mod sigue activo
    if (modInfo.isEnabled) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.errorDialogTitle,
        description: l10n.errorDisableModBeforeDelete, // O usa una variable de l10n si la tienes creada
      );
      return;
    }

    final modName = modInfo.customName;
    final confirm = await SettingsDialogs.confirm(
      context: context,
      title: l10n.dialogTitleDeleteMod,
      message: l10n.dialogContentDeleteMod(modName),
      confirmLabel: l10n.dialogActionDelete,
      destructive: true,
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _lastInstalledModNames.clear();
    });

    try {
      // Como el mod ya se validó como inactivo, pasamos directo al borrado de la carpeta
      final deleted = await FileManagerService.deleteDirectoryWithRetry(modInfo.directory);

      if (deleted && mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.snackBarModDeleted(modName),
        );
      } else if (!deleted) {
        throw Exception(l10n.errorCouldNotDeleteDirectory);
      }
      await _loadAllMods();
    } catch (e) {
      setState(() {
        _statusMessage = l10n.errorDeleteMod(e.toString());
        _statusColor = Colors.redAccent;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enableAllMods(List<ModInfo> modsInView) async {
    final l10n = AppLocalizations.of(context)!;
    final disabledMods = modsInView.where((mod) => !mod.isEnabled).toList();

    if (disabledMods.isEmpty) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.info,
          title: l10n.snackBarNoModsToEnable,
        );
      }
      return;
    }

    // 1. Orden de prioridad vital (529 primero)
    disabledMods.sort((a, b) {
      if (a.nexusId == '529' && b.nexusId != '529') return -1;
      if (b.nexusId == '529' && a.nexusId != '529') return 1;
      
      if (a.modType == 'movies' && b.modType != 'movies') return 1;
      if (b.modType == 'movies' && a.modType != 'movies') return -1;
      
      return 0;
    });

    final confirm = await SettingsDialogs.confirm(
      context: context,
      title: l10n.dialogTitleEnableAll,
      message: l10n.dialogContentEnableAll(disabledMods.length),
      confirmLabel: l10n.enableMod,
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    int successCount = 0;
    int skippedCount = 0;

    // --- LÓGICA DE FILTRADO INTELIGENTE (PREVENCIÓN DE CONFLICTOS) ---
    // 1. Reservamos los trajes que ya están siendo usados por mods habilitados
    Set<String> claimedOutfits = _allMods
        .where((m) => m.isEnabled)
        .expand((m) => m.replacesOutfits ?? <String>[])
        .toSet();
    
    // 2. Reservamos las "firmas" (ID + Tipo) de mods activos para no activar versiones alternativas
    Set<String> activeModSignatures = _allMods
        .where((m) => m.isEnabled && m.nexusId != null)
        .map((m) => '${m.nexusId}_${m.modType}')
        .toSet();

    try {
      for (final mod in disabledMods) {
        // Filtrar Alternativas (Mismo ID de Nexus y mismo tipo de mod)
        if (mod.nexusId != null) {
          final signature = '${mod.nexusId}_${mod.modType}';
          if (activeModSignatures.contains(signature)) {
            print(l10n.logSkippingActiveVariant(mod.customName));
            skippedCount++;
            continue;
          }
        }

        // Filtrar Conflictos de Outfits (Evita choques y diálogos de interrupción)
        if (mod.replacesOutfits != null && mod.replacesOutfits!.isNotEmpty) {
          final hasConflict = mod.replacesOutfits!.any((outfit) => claimedOutfits.contains(outfit));
          if (hasConflict) {
            print(l10n.logSkippingOutfitConflict(mod.customName));
            skippedCount++;
            continue;
          }
        }

        // Si pasó los filtros, "reservamos" sus recursos para los mods que le siguen en el bucle
        if (mod.nexusId != null) {
          activeModSignatures.add('${mod.nexusId}_${mod.modType}');
        }
        if (mod.replacesOutfits != null) {
          claimedOutfits.addAll(mod.replacesOutfits!);
        }

        // Y lo activamos de forma segura
        final success = await _enableMod(mod);
        if (success) {
          successCount++;
        }
      }

      if (mounted) {
        // Notificación dinámica: Avisa al usuario si hubo mods saltados para que no piense que fue un error
        final String titleMsg = skippedCount > 0 
            ? l10n.snackBarModsEnabledWithSkips(successCount, skippedCount)
            : l10n.snackBarAllModsEnabled(successCount);

        NotificationService.instance.show(
          context: context,
          type: skippedCount > 0 ? NotificationType.info : NotificationType.success,
          title: titleMsg,
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.errorEnableMod(e.toString());
        _statusColor = Colors.redAccent;
      });
      await _loadAllMods(); 
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disableAllMods(List<ModInfo> modsInView) async {
    final l10n = AppLocalizations.of(context)!;
    final enabledMods = modsInView.where((mod) => mod.isEnabled).toList();

    if (enabledMods.isEmpty) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.info,
          title: l10n.snackBarNoModsToDisable,
        );
      }
      return;
    }

    final confirm = await SettingsDialogs.confirm(
      context: context,
      title: l10n.dialogTitleDisableAll,
      message: l10n.dialogContentDisableAll(enabledMods.length),
      confirmLabel: l10n.disableMod,
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    int successCount = 0;

    try {
      // Delegamos TODA la lógica a la función singular
      for (final mod in enabledMods) {
        final success = await _disableMod(mod);
        if (success) {
          successCount++;
        }
      }

      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.info,
          title: l10n.snackBarAllModsDisabled(successCount),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.errorDisableMod(e.toString());
        _statusColor = Colors.redAccent;
      });
      await _loadAllMods();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDisabledMods(List<ModInfo> modsInView) async {
    final l10n = AppLocalizations.of(context)!;
    final disabledMods = modsInView.where((mod) => !mod.isEnabled).toList();

    if (disabledMods.isEmpty) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.info,
          title: l10n.snackBarNoModsToDelete,
        );
      }
      return;
    }

    final confirm = await SettingsDialogs.confirm(
      context: context,
      title: l10n.dialogTitleDeleteAll,
      message: l10n.dialogContentDeleteAll(disabledMods.length),
      confirmLabel: l10n.dialogActionDelete,
      destructive: true,
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      int deletedCount = 0;
      for (final mod in disabledMods) {
        // Los respaldos de __MOVIES_ORIGINALS__ NO se borran: son los originales del
        // juego y los comparten todos los mods de películas (otro mod activo puede
        // seguir necesitándolos para restaurar).
        // Eliminación del directorio principal
        if (await FileManagerService.deleteDirectoryWithRetry(mod.directory)) {
          deletedCount++;
        }
      }

      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.snackBarAllModsDeleted(deletedCount),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.errorDeleteMod(e.toString());
        _statusColor = Colors.redAccent;
      });
    } finally {
      await _loadAllMods();
      setState(() => _isLoading = false);
    }
  }

  /// Abre la carpeta de un mod donde están DE VERDAD sus archivos. Un mod con
  /// partes (blueprint, paks en ~mods, scripts UE4SS) puede tener varias: si
  /// es así se deja elegir. Con el mod desactivado todo está en su respaldo.
  Future<void> _showModInExplorer(ModInfo mod) async {
    List<ModLocation> locations;
    try {
      locations = await ModLocationsService.resolve(
        mod,
        genericModsPath: _genericModsPath,
        ue4ssModsPath: _ue4ssModsPath,
        moviesPath: _moviesPath,
        savesPath: _savesPath,
        configPath: _configPath,
        splashPath: _splashPath,
      );
    } catch (_) {
      locations = const [];
    }
    if (locations.isEmpty) {
      await _showInExplorer(mod.directory);
      return;
    }
    if (locations.length == 1) {
      await _revealLocation(locations.first);
      return;
    }
    if (!mounted) return;
    // El diálogo queda abierto: cada clic abre su carpeta.
    await ModLocationPicker.show(context, locations, onOpen: _revealLocation);
  }

  /// Abre una ubicación; un archivo suelto se abre seleccionado en su carpeta.
  Future<void> _revealLocation(ModLocation loc) async {
    if (loc.isFile && Platform.isWindows) {
      try {
        // OJO: '/select,' y la ruta van como argumentos SEPARADOS. Si se pasan
        // juntos ('/select,C:\\Mi carpeta\\x') y la ruta tiene espacios, Dart
        // entrecomilla todo el argumento y el Explorador abre Documentos.
        // explorer devuelve código 1 aunque funcione: no se comprueba.
        await Process.run(
            'explorer.exe', ['/select,', p.normalize(loc.path)]);
        return;
      } catch (_) {}
    }
    await _showInExplorer(
      Directory(loc.isFile ? p.dirname(loc.path) : loc.path),
    );
  }

  Future<void> _showInExplorer(Directory modDirectory) async {
    final uri = Uri.file(modDirectory.path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      setState(() {
        _statusMessage = AppLocalizations.of(
          context,
        )!.errorOpenFolder(modDirectory.path);
        _statusColor = Colors.redAccent;
      });
    }
  }

  Future<void> _clearSelection({
    String? message,
    StateSetter? panelStateSetter,
  }) async {
    final updateState = panelStateSetter ?? setState;

    await _cancelAndCleanInstallation();

    updateState(() {
      if (mounted) {
        _statusMessage =
            //message ?? AppLocalizations.of(context)!.statusSelectionCancelled;
            _statusMessage = '';
        _statusColor = Colors.white;
      }
      // ++ CAMBIO: Usa un color distintivo para que el mensaje sea visible. ++
      _statusColor = message == null
          ? Colors.orangeAccent
          : Colors.orangeAccent;
    });
  }

  /// Guarda el idioma elegido y lo aplica a toda la app al instante.
  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppPrefs.languageCode, code);
    if (mounted) ModInstallerApp.setLocale(context, Locale(code));
  }

  void _showLanguageDialog() {
    SettingsDialogs.language(
      context,
      current: Localizations.localeOf(context).languageCode,
      onSelected: _setLanguage,
    );
  }

  void _showAboutDialog() {
    SettingsDialogs.about(
      context,
      version: _appVersion,
      onDeveloperModeUnlocked: () {
        setState(() => _developerModeEnabled = true);
        NotificationService.instance.show(
          context: context,
          type: NotificationType.success,
          title: AppLocalizations.of(context)!.snackBarDeveloperModeEnabled,
        );
      },
    );
  }

  /// Abre la página de Ajustes. Con [startOnApiKey] entra directamente en
  /// "Conectividad y actualizaciones" y abre el diálogo de la API key.
  Future<void> _openSettings({bool startOnApiKey = false}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          initialGameRootPath: _gameRootPath,
          initialApiKey: _apiKey,
          skippedVersions: _skippedVersions,
          // Pasar los nuevos estados y funciones a la página de configuración
          isUe4ssInstalled: _isUe4ssInstalled,
          isCnsCoreInstalled: _isCnsCoreInstalled,
          onUninstallUE4SS: () =>
              _uninstallCoreComponent(isUe4ss: true),
          onUninstallCNS: () =>
              _uninstallCoreComponent(isUe4ss: false),
          // Resto de callbacks
          onSelectGamePath: _selectGamePathManually,
          onShowApiKeyDialog: _showApiKeyDialog,
          onManageSkippedVersions: _manageSkippedVersions,
          onShowLanguageDialog: _showLanguageDialog,
          onDeleteAllNexusInfo: _deleteAllNexusInfoFiles,
          onExtractModIds: _extractModIdentifiers,
          onTestSelfUpdate: _testSelfUpdate,
          onCheckAppUpdate: () => _checkForAppUpdate(manual: true),
          isDeveloperModeEnabled: _developerModeEnabled,
          initialShowModTypeTags: _showModTypeTags,
          onShowModTypeTagsChanged: (newValue) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppPrefs.showModTypeTags, newValue);
            setState(() {
              _showModTypeTags = newValue;
            });
          },
          initialAutoAssignOutfits: _autoAssignOutfits,
          onAutoAssignOutfitsChanged: (newValue) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(AppPrefs.autoAssignOutfits, newValue);
            setState(() {
              _autoAssignOutfits = newValue;
            });
          },
          onShowAboutDialog: _showAboutDialog,
          onRefreshMetadata: _refreshAllMetadata,
          onRunSelfHealing: _showSelfHealConfirmationDialog,
          onRepairGameStartup: _runGameStartupRepair,
          onRunConflictPatcher: _runConflictPatcher,
          onRevertConflictPatches: _revertConflictPatches,
            startOnApiKey: startOnApiKey,
        ),
      ),
    );
  }

  /// Aviso (una vez por sesión) que invita a configurar la API key de Nexus
  /// cuando no hay ninguna. Se puede omitir y silenciar para siempre con la
  /// casilla "No volver a mostrar este mensaje".
  bool _apiKeyPromptHandled = false;

  Future<void> _maybeShowApiKeyPrompt() async {
    if (_apiKeyPromptHandled || !mounted) return;
    _apiKeyPromptHandled = true;
    if (_apiKey != null && _apiKey!.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(AppPrefs.hideApiKeyPrompt) ?? false) return;
    if (!mounted) return;

    final result = await SettingsDialogs.apiKeyPrompt(
      context,
      onLanguageChanged: _setLanguage,
    );
    if (result.dontShowAgain) {
      await prefs.setBool(AppPrefs.hideApiKeyPrompt, true);
    }
    if (result.configure && mounted) {
      await _openSettings(startOnApiKey: true);
    }
  }

  Future<String?> _showApiKeyDialog() {
    final l10n = AppLocalizations.of(context)!;
    return SettingsDialogs.apiKey(
      context: context,
      initialKey: _apiKey,
      onSubmit: (key) async {
        if (key.isEmpty) {
          if (mounted) {
            setState(() {
              _nexusUserName = null;
              _nexusPlan = NexusPlan.member;
              _nexusAvatarUrl = null;
            });
          }
          DownloadManager.instance.userPlan = NexusPlan.member;
          final clearPrefs = await SharedPreferences.getInstance();
          await clearPrefs.setString('nexus_plan', NexusPlan.member.name);
          await _saveApiKey('');
          if (mounted) {
            NotificationService.instance.show(
              context: context,
              type: NotificationType.info,
              title: l10n.apiKeyRemoved,
            );
          }
          return true;
        }

        final profileData = await NexusApiService.validateAndGetProfile(key);
        if (profileData == null || profileData['isValid'] != true) return false;

        // Perfil disponible al instante (avatar, nombre y plan) sin reiniciar la app.
        if (mounted) {
          setState(() {
            _nexusUserName = profileData['name'];
            _nexusPlan = profileData['plan'] as NexusPlan;
            _nexusAvatarUrl = profileData['profileUrl'];
          });
        }
        await _saveApiKey(key);
        final plan = profileData['plan'] as NexusPlan;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nexus_plan', plan.name);
        DownloadManager.instance.userPlan = plan;

        if (mounted) {
          NotificationService.instance.show(
            context: context,
            type: NotificationType.success,
            title: l10n.snackBarApiKeySaved,
          );
        }
        return true;
      },
    );
  }

  Future<ModInfo?> _updateModCustomName(
    ModInfo mod,
    String newCustomName,
  ) async {
    if (newCustomName.isEmpty || newCustomName == mod.customName) {
      return null; // No hay cambios, no hagas nada
    }

    try {
      final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
      Map<String, dynamic> data = {};
      if (await infoFile.exists()) {
        final content = await infoFile.readAsString();
        if (content.isNotEmpty) data = json.decode(content);
      }

      if (newCustomName == mod.displayName) {
        data.remove('customName');
      } else {
        data['customName'] = newCustomName;
      }

      final encoder = JsonEncoder.withIndent('  ');
      await infoFile.writeAsString(encoder.convert(data));

      // Reconstruye manualmente el objeto para asegurar que el nombre se actualice
      return ModInfo(
        directory: mod.directory,
        nexusId: mod.nexusId,
        localVersion: mod.localVersion,
        lastModified: mod.lastModified,
        installDate: mod.installDate,
        isEnabled: mod.isEnabled,
        origin: mod.origin,
        displayName: mod.displayName,
        // Asigna directamente desde el mapa 'data', con fallback al nombre de visualización
        customName: data['customName'] ?? mod.displayName,
        gallery: mod.gallery,
        fitMeshType: mod.fitMeshType,
        customCoverPath: mod.customCoverPath,
        customCoverAlignment: mod.customCoverAlignment,
        customCoverLastModified: mod.customCoverLastModified,
        customVersion: mod.customVersion,
        customFitMeshType: mod.customFitMeshType,
        summary: mod.summary,
        customSummary: mod.customSummary,
        description: mod.description,
        customDescription: mod.customDescription,
        author: mod.author,
        customAuthor: mod.customAuthor,
        userNotes: mod.userNotes,
        sourceUrl: mod.sourceUrl,
        customSourceUrl: mod.customSourceUrl,
        modName: mod.modName,
        editionName: mod.editionName,
      );
    } catch (e) {
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.errorRenamingMod(e.toString());
        _statusColor = Colors.redAccent;
      });
      return null;
    }
  }

  // ID de Stellar Blade en Steam (permite lanzarlo con steam://rungameid/...)
  static const String _stellarBladeSteamAppId = '3489700';

  /// true si el juego está dentro de una biblioteca de Steam (.../steamapps/...).
  bool _isSteamInstall(String root) =>
      p.split(root).any((part) => part.toLowerCase() == 'steamapps');

  /// Lanza el juego a través de Steam. Así Steam se abre solo si estaba cerrado
  /// e inicializa el juego correctamente (y respeta las opciones de lanzamiento
  /// del juego, p. ej. el .bat del mod 801).
  Future<bool> _launchViaSteam() async {
    try {
      return await launchUrl(
        Uri.parse('steam://rungameid/$_stellarBladeSteamAppId'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// Lanza el .exe directamente, desacoplado de la app y sin pasar por cmd
  /// (evita los problemas de comillas/espacios de `cmd /c start`).
  Future<void> _launchExecutable(String exe) async {
    await Process.start(
      exe,
      const [],
      workingDirectory: p.dirname(exe),
      mode: ProcessStartMode.detached,
    );
  }

  // Procesos que identifican a Stellar Blade en ejecución (nombres en minúsculas).
  static const Set<String> _gameProcessNames = {
    'sb-win64-shipping.exe',
    'stellarblade-win64-shipping.exe',
    'stellarblade.exe',
  };

  /// Devuelve los procesos del juego que están corriendo ahora mismo
  /// (conjunto vacío = el juego no está abierto) o null si no se pudo consultar.
  Future<Set<String>?> _findGameProcesses() async {
    if (!Platform.isWindows) return null;
    try {
      final result = await Process.run('tasklist', ['/FO', 'CSV', '/NH']);
      if (result.exitCode != 0) return null;
      final found = <String>{};
      for (final line in result.stdout.toString().split('\n')) {
        final t = line.trim();
        if (!t.startsWith('"')) continue;
        final end = t.indexOf('"', 1);
        if (end < 0) continue;
        final name = t.substring(1, end).toLowerCase();
        if (_gameProcessNames.contains(name)) found.add(name);
      }
      return found;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _isGameProcessRunning() async {
    final procs = await _findGameProcesses();
    return procs != null && procs.isNotEmpty;
  }

  /// Vigila cada pocos segundos si el juego está abierto (también si se lanzó
  /// desde fuera de la app) para poner el botón en rojo / verde.
  void _startGameWatcher() {
    if (!Platform.isWindows) return;
    _refreshGameRunning();
    _gameWatcher = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _refreshGameRunning(),
    );
  }

  Future<void> _refreshGameRunning() async {
    if (_gameCheckInFlight) return;
    _gameCheckInFlight = true;
    try {
      final procs = await _findGameProcesses();
      if (procs == null) return; // no se pudo consultar: no cambiamos el estado
      final running = procs.isNotEmpty;
      if (mounted && running != _isGameRunning) {
        setState(() => _isGameRunning = running);
      }
    } finally {
      _gameCheckInFlight = false;
    }
  }

  /// Cierra el juego: primero con una petición de cierre normal y, si no
  /// responde en unos segundos, de forma forzada.
  Future<void> _stopGame() async {
    if (_isStoppingGame) return;
    final l10n = AppLocalizations.of(context)!;

    final confirm = await SettingsDialogs.confirm(
      context: context,
      title: l10n.dialogTitleStopGame,
      message: l10n.dialogContentStopGame,
      confirmLabel: l10n.dialogActionStopGame,
      destructive: true,
    );
    if (!confirm || !mounted) return;

    setState(() => _isStoppingGame = true);
    try {
      // 1) Cierre normal (WM_CLOSE)
      for (final name in await _findGameProcesses() ?? <String>{}) {
        await Process.run('taskkill', ['/IM', name, '/T']);
      }
      bool gone = false;
      for (int i = 0; i < 8 && !gone; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        final procs = await _findGameProcesses();
        gone = procs != null && procs.isEmpty;
      }

      // 2) Si sigue abierto, cierre forzado
      if (!gone) {
        for (final name in await _findGameProcesses() ?? <String>{}) {
          await Process.run('taskkill', ['/F', '/IM', name, '/T']);
        }
        await Future.delayed(const Duration(seconds: 1));
        final procs = await _findGameProcesses();
        gone = procs != null && procs.isEmpty;
      }

      if (!gone) throw Exception(l10n.errorStoppingGame);

      if (mounted) {
        setState(() => _isGameRunning = false);
        NotificationService.instance.show(
          context: context,
          type: NotificationType.info,
          title: l10n.notificationGameStopped,
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.errorStoppingGame,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isStoppingGame = false);
    }
  }

  /// Lanza el juego sin tocar la interfaz (Steam o .exe). Lo reutiliza
  /// también "Reparar inicio del juego".
  Future<void> _launchGameRaw() async {
    bool launched = false;

    // 1) Instalación de Steam: lanzar vía Steam (lo más fiable).
    if (Platform.isWindows && _isSteamInstall(_gameRootPath!)) {
      launched = await _launchViaSteam();
    }

    // 2) Respaldo (Epic u otras rutas, o si Steam no respondió): lanzar el .exe.
    if (!launched) {
      final possibleExes = [
        p.join(_gameRootPath!, 'SB', 'Binaries', 'Win64', 'StellarBlade-Win64-Shipping.exe'),
        p.join(_gameRootPath!, 'SB', 'Binaries', 'Win64', 'SB-Win64-Shipping.exe'),
        p.join(_gameRootPath!, 'StellarBlade.exe'),
        p.join(_gameRootPath!, 'SB.exe'),
      ];

      String? exeToLaunch;
      for (final exe in possibleExes) {
        if (await File(exe).exists()) {
          exeToLaunch = exe;
          break;
        }
      }

      if (exeToLaunch == null) {
        throw Exception(AppLocalizations.of(context)!.errorGameExeNotFound);
      }
      await _launchExecutable(exeToLaunch);
    }
  }

  /// Ajustes > "Reparar que el juego no inicia".
  /// Desinstala UE4SS y CNS (guardando sus archivos), inicia el juego hasta que
  /// arranque, lo cierra solo, reinstala todo y vuelve a lanzar el juego. El
  /// progreso se muestra en una ventana emergente siempre al frente.
  Future<void> _runGameStartupRepair({bool skipConfirm = false}) async {
    if (_gameRootPath == null || _isLaunchingGame) {
      if (mounted && _gameRootPath == null) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: AppLocalizations.of(context)!.notificationTitleError,
          description: AppLocalizations.of(context)!.errorGamePathNotFoundNotification,
        );
      }
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    if (!skipConfirm) {
      final confirm = await SettingsDialogs.confirm(
        context: context,
        title: l10n.repairConfirmTitle,
        message: l10n.repairConfirmMessage,
        confirmLabel: l10n.repairConfirmAction,
      );
      if (!confirm || !mounted) return;
    }

    // Reutilizamos el estado "lanzando" para bloquear el botón de jugar.
    setState(() => _isLaunchingGame = true);
    try {
      await RepairGameDialog.run(
        context: context,
        gameRootPath: _gameRootPath!,
        launchGame: _launchGameRaw,
        findGameProcesses: _findGameProcesses,
      );
    } finally {
      await _checkCoreInstallations();
      await _readCNSData();
      await _refreshGameRunning();
      if (mounted) setState(() => _isLaunchingGame = false);
    }
  }

  /// Si una reparación anterior se interrumpió (la app se cerró o crasheó a
  /// mitad), devuelve UE4SS y CNS a su sitio al iniciar.
  Future<void> _recoverInterruptedRepair() async {
    final root = _gameRootPath;
    if (root == null) return;
    try {
      if (!await CoreInstallerService.hasPendingRepair(root)) return;
      // Con el juego abierto sus archivos están bloqueados: se reintenta en el
      // próximo inicio.
      if (await _isGameProcessRunning()) return;

      await CoreInstallerService.recoverPendingRepair(root);
      await _checkCoreInstallations();

      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.info,
          title: AppLocalizations.of(context)!.repairRecoveredNotice,
        );
      }
    } catch (e) {
      print('Could not recover interrupted repair: $e');
    }
  }

  /// Espera a que el juego aparezca como proceso y se mantenga estable.
  /// true  = arrancó y sigue abierto tras la ventana de estabilidad.
  /// false = nunca apareció (máx. [appearTimeout]) o se cerró enseguida
  ///         (crash al iniciar).
  Future<bool> _waitForStableGameStart({
    Duration appearTimeout = const Duration(seconds: 45),
    Duration stableFor = const Duration(seconds: 12),
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // 1) Esperar a que aparezca el proceso (Steam puede tardar en abrirse).
    final appearDeadline = DateTime.now().add(appearTimeout);
    bool appeared = false;
    while (mounted && DateTime.now().isBefore(appearDeadline)) {
      if (await _isGameProcessRunning()) {
        appeared = true;
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!appeared) return false;
    if (mounted) setState(() => _isGameRunning = true);

    // 2) Comprobar que no se cierra de inmediato.
    final stableDeadline = DateTime.now().add(stableFor);
    while (mounted && DateTime.now().isBefore(stableDeadline)) {
      await Future.delayed(const Duration(seconds: 1));
      final procs = await _findGameProcesses();
      // Si no se pudo consultar (null) no lo damos por caído.
      if (procs != null && procs.isEmpty) {
        if (mounted) setState(() => _isGameRunning = false);
        return false;
      }
    }
    return true;
  }

  Future<void> _launchGame() async {
    // Evitamos que se ejecute si ya está intentando abrir el juego
    if (_gameRootPath == null || _isLaunchingGame) {
      if (mounted && _gameRootPath == null) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: AppLocalizations.of(context)!.notificationTitleError,
          description: AppLocalizations.of(context)!.errorGamePathNotFoundNotification,
        );
      }
      return;
    }

    setState(() {
      _isLaunchingGame = true;
    });

    bool offerRepair = false;
    try {
      // Hasta 2 intentos: si el primero no arranca (o se cierra enseguida),
      // se vuelve a lanzar una vez.
      bool started = false;
      for (int attempt = 1; attempt <= 2 && !started && mounted; attempt++) {
        await _launchGameRaw();

        if (mounted && attempt == 1) {
          NotificationService.instance.show(
            context: context,
            type: NotificationType.success,
            title: AppLocalizations.of(context)!.notificationLaunchingGame,
          );
        }

        started = await _waitForStableGameStart();

        // Si quedó algún proceso a medias, se limpia antes de reintentar.
        if (!started && attempt == 1 && mounted) {
          for (final name in await _findGameProcesses() ?? <String>{}) {
            try {
              await Process.run('taskkill', ['/F', '/IM', name, '/T']);
            } catch (_) {}
          }
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      // Solo se sugiere la reparación si hay algo que reparar (UE4SS o CNS).
      offerRepair = !started &&
          mounted &&
          (_isUe4ssInstalled || _isCnsCoreInstalled);
    } catch (e) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: AppLocalizations.of(context)!.errorLaunchingGame,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunchingGame = false;
        });
      }
    }

    if (offerRepair && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final bool fix = await SettingsDialogs.confirm(
        context: context,
        title: l10n.launchRetryTitle,
        message: l10n.launchRetryMessage,
        confirmLabel: l10n.launchRetryAction,
      );
      // Ya se ha confirmado aquí: se omite el segundo aviso.
      if (fix && mounted) await _runGameStartupRepair(skipConfirm: true);
    }
  }

  Future<void> _checkForUpdates() async {
    final l10n = AppLocalizations.of(context)!;

    if (_apiKey == null || _apiKey!.isEmpty) {
      await _showApiKeyDialog();
      if (_apiKey == null || _apiKey!.isEmpty) {
        setState(() {
          _statusMessage = l10n.errorApiKeyMissing;
          _statusColor = Colors.orangeAccent;
        });
        return;
      }
    }

    setState(() {
      _isCheckingForUpdates = true;
      _statusMessage = l10n.statusCheckingUpdates;
      _modUpdates.clear();
      _cnsUpdateInfo = null;
      _ignoredUpdates.clear();
    });

    final result = await UpdateService.checkForAllUpdates(
      apiKey: _apiKey!,
      cnsNexusId: _cnsNexusId,
      cnsVersion: _cnsVersion,
      gameRootPath: _gameRootPath,
      allMods: _allMods,
      skippedVersions: _skippedVersions,
    );

    setState(() {
      if (result.error != null) {
        _statusMessage = l10n.statusError(result.error!);
        _statusColor = Colors.redAccent;
      } else if (result.updatesFound > 0) {
        _statusMessage = l10n.statusUpdatesFound(result.updatesFound);
        _statusColor = Colors.yellowAccent;
        _cnsUpdateInfo = result.cnsUpdateInfo;
        _modUpdates.addAll(result.modUpdates);
      } else {
        _statusMessage = l10n.statusNoUpdates;
        _statusColor = Colors.greenAccent;
      }
      _isCheckingForUpdates = false;
    });
  }

  void _showImageGalleryDialog(
    ModInfo modInfo, {
    int initialIndex = 0,
    String? initialImage,
    bool prewarmOnly = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    // Prefiere la copia local de cada imagen (carga instantánea y funciona
    // sin conexión); si falta, usa la URL de Nexus.
    final List<String> images = (modInfo.gallery ?? []).map<String>((img) {
      final String? local = img['localImage'] as String?;
      if (local != null && local.isNotEmpty) {
        final String fullPath = p.join(modInfo.directory.path, local);
        if (File(fullPath).existsSync()) return fullPath;
      }
      return img['image'] as String;
    }).toList();

    if (modInfo.customCoverPath != null) {
      final customCoverFullPath = p.join(
        modInfo.directory.path,
        modInfo.customCoverPath!,
      );
      // `_nexus_cover.*` es solo la copia automática de la primera imagen de la
      // galería: añadirla duplicaría esa imagen en el visor.
      final bool isAutoNexusCover =
          p.basename(customCoverFullPath).toLowerCase().startsWith('_nexus_cover');
      final bool galleryHasImages = (modInfo.gallery ?? const []).isNotEmpty;
      if (!images.contains(customCoverFullPath) &&
          !(isAutoNexusCover && galleryHasImages)) {
        images.insert(0, customCoverFullPath);
      }
    }

    if (images.isEmpty) {
      // No hacer nada si no hay imágenes
      return;
    }
    if (prewarmOnly) {                 // <-- nuevo
    prewarmImageViewer(context, images, initialIndex: initialIndex);
    return;
  }

    // Determina el índice inicial si se pasó una imagen específica
    int finalInitialIndex = initialIndex;
    if (initialImage != null) {
      int foundIndex = images.indexOf(initialImage);
      if (foundIndex != -1) {
        finalInitialIndex = foundIndex;
      }
    }

    showImageViewer(
      context,
      images: images,
      initialIndex: finalInitialIndex,
      modPath: modInfo.directory.path,
      closeTooltip: l10n.dialogActionClose,
    );
  }

  /// Alerta iOS para el conflicto de trajes (el nombre del traje enseña la
  /// vista previa al pasar el ratón; el nombre del mod abre sus detalles).
  Future<bool?> _showOutfitConflictDialog({
    required String part1,
    required String outfitName,
    required String part2,
    required String modName,
    required String part3,
    required ModInfo conflictingMod,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showIosDialog<bool>(
      context: context,
      barrierDismissible: false, // No permitir cerrar sin elegir
      builder: (ctx) => IosDialogShell(
        title: l10n.dialogTitleOutfitConflict,
        width: 360,
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: IosColors.secondaryLabel,
            ),
            children: [
              TextSpan(text: part1),
              // Nombre del traje (vista previa al mantener el ratón encima)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: MouseRegion(
                  onEnter: (event) {
                    _cursorPosition = event.position;
                    _hoverTimer?.cancel();
                    _hoverTimer = Timer(const Duration(milliseconds: 800), () {
                      if (mounted) {
                        _showPreviewOverlay(context, outfitName, _cursorPosition);
                      }
                    });
                  },
                  onExit: (event) => _hidePreviewOverlay(),
                  onHover: (event) => _cursorPosition = event.position,
                  child: Text(
                    outfitName,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: IosColors.label,
                    ),
                  ),
                ),
              ),
              TextSpan(text: part2),
              // Nombre del mod en conflicto (abre su panel de detalles)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _showDetailsPage(conflictingMod),
                    child: Text(
                      modName,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: IosColors.blue,
                      ),
                    ),
                  ),
                ),
              ),
              TextSpan(text: part3),
            ],
          ),
        ),
        actions: [
          IosDialogButton(
            label: l10n.dialogActionCancel,
            onPressed: () {
              _hidePreviewOverlay();
              Navigator.of(ctx).pop(false);
            },
          ),
          IosDialogButton(
            label: l10n.dialogActionActivateAndDisable,
            bold: true,
            onPressed: () {
              _hidePreviewOverlay();
              Navigator.of(ctx).pop(true);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _showUpdateOptionsDialog({
    required String newVersion,
    required String nexusId,
    required int fileId,
    required String uniqueIdentifier,
    // Edición concreta a la que se refiere el aviso. Con ella, "Omitir esta
    // versión" solo afecta a esa edición y no a todo el mod.
    ModInfo? mod,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final String cleanedVersion = newVersion.toLowerCase().startsWith('v')
        ? newVersion.substring(1)
        : newVersion;

    // Busca el nombre del mod para mostrarlo en la notificación.
    // Incluye un respaldo para el CNS, que no está en la lista general de mods.
    final ModInfo? namedMod = mod ??
        _allMods.cast<ModInfo?>().firstWhere(
              (m) => m!.nexusId == nexusId,
              orElse: () => null,
            );
    final String modName = namedMod?.customName ?? l10n.cnsCoreSystem;

    // El diálogo devuelve 'true' si la notificación se ocultó (ignorar/omitir)
    // y 'false' si se fue a la descarga o se cerró sin elegir.
    final bool? result = await showIosDialog<bool>(
      context: context,
      builder: (ctx) => IosDialogShell(
        title: l10n.updateAvailable(cleanedVersion),
        message: '$modName\n${l10n.dialogContentUpdateOptions}',
        stacked: true,
        actions: [
          IosDialogButton(
            label: l10n.dialogActionGoToDownloadPage,
            bold: true,
            onPressed: () async {
              // nmm=1 abre directamente la descarga con "Mod manager download"
              // (en vez de la pestaña de descarga manual).
              final url = Uri.parse(
                'https://www.nexusmods.com/stellarblade/mods/$nexusId?tab=files&file_id=$fileId&nmm=1',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
              if (ctx.mounted) Navigator.of(ctx).pop(false); // Devuelve 'false'
            },
          ),
          IosDialogButton(
            label: l10n.dialogActionSkipVersion,
            onPressed: () async {
              setState(() {
                if (mod != null) {
                  // Por EDICIÓN: solo se omite la de este mod, las demás
                  // ediciones del mismo mod siguen avisando.
                  _skippedVersions[UpdateService.editionSkipKey(mod)] =
                      newVersion;
                  if (_installedEditionsOf(mod).length <= 1) {
                    // Clave antigua (por mod) ya sustituida por la de edición.
                    _skippedVersions.remove(nexusId);
                  }
                  _modUpdates.remove(mod.directory.path);
                } else {
                  _skippedVersions[nexusId] = newVersion;
                  if (nexusId == _cnsNexusId) {
                    _cnsUpdateInfo = null;
                  } else {
                    final stale = _modUpdates.keys.where((key) {
                      final i = _allMods.indexWhere(
                        (m) => m.directory.path == key,
                      );
                      return i != -1 && _allMods[i].nexusId == nexusId;
                    }).toList();
                    for (final key in stale) {
                      _modUpdates.remove(key);
                    }
                  }
                }
              });
              await _saveSkippedVersions();
              NotificationService.instance.show(
                context: ctx,
                type: NotificationType.info,
                title: l10n.snackBarVersionSkipped(modName, newVersion),
              );
              if (ctx.mounted) Navigator.of(ctx).pop(true); // Devuelve 'true'
            },
          ),
          IosDialogButton(
            label: l10n.dialogActionIgnoreVersion,
            onPressed: () {
              setState(() {
                _ignoredUpdates.add(uniqueIdentifier);
              });
              NotificationService.instance.show(
                context: ctx,
                type: NotificationType.info,
                title: l10n.snackBarUpdateIgnored(modName),
              );
              Navigator.of(ctx).pop(true); // Devuelve 'true'
            },
          ),
        ],
      ),
    );
    // Si el diálogo se cierra sin seleccionar, devuelve 'false'.
    return result ?? false;
  }

  Future<void> _manageSkippedVersions() {
    final items = _skippedVersions.entries.map((entry) {
      // La clave es "<nexusId>#<edición>" (nueva) o solo "<nexusId>" (antigua).
      final i = _allMods.indexWhere((m) =>
          m.nexusId != null &&
          (entry.key == UpdateService.editionSkipKey(m) ||
              entry.key == m.nexusId));
      final nexusIdOfKey = entry.key.split('#').first;
      return SkippedVersionItem(
        id: entry.key,
        name: i != -1 ? _allMods[i].customName : 'ID: $nexusIdOfKey',
        version: entry.value,
      );
    }).toList();

    return SettingsDialogs.skippedVersions(
      context: context,
      items: items,
      onRemove: (id) => _removeSkippedVersion(id),
    );
  }

  List<ModInfo> _getFilteredAndSortedMods(AppLocalizations l10n) {
    List<ModInfo> mods = List.from(_allMods);

    // --- 1. APLICA EL FILTRO DE TIPO DE MOD (Barra de Navegación) ---
    switch (_currentModTypeFilter) {
      case ModTypeFilter.cns:
        // Incluye mods 'cns' y mods antiguos (null) que son tratados como cns
        mods.retainWhere((mod) => mod.modType == 'cns' || mod.modType == null);
        break;
      case ModTypeFilter.generic:
        // Ahora solo busca mods marcados explícitamente como 'genericPak'
        mods.retainWhere((mod) => mod.displayType == 'genericPak');
        break;
      case ModTypeFilter.replacement:
        // Ahora busca mods marcados explícitamente como 'replacement'
        // (Esto también incluirá los mods antiguos que tenías,
        // una vez que actives el switch en ellos por primera vez).
        mods.retainWhere((mod) => mod.modType == 'replacement');
        break;
      case ModTypeFilter.movies:
        mods.retainWhere((mod) => mod.modType == 'movies');
        break;
      case ModTypeFilter.logicMod:
        mods.retainWhere((mod) => mod.displayType == 'logicMod');
        break;
      case ModTypeFilter.save:
        mods.retainWhere((mod) => mod.modType == 'save');
        break;
      case ModTypeFilter.config:
        mods.retainWhere((mod) => mod.modType == 'config');
        break;
      case ModTypeFilter.splash:
        mods.retainWhere((mod) => mod.modType == 'splash');
        break;
      case ModTypeFilter.all:
      default:
        // No filtrar por tipo
        break;
    }

    // --- 2. APLICA EL FILTRO DE ESTADO (Dropdown) ---
    // Esto ahora filtra SOBRE la lista ya filtrada por tipo.
    switch (_currentFilter) {
      case ModFilter.enabled:
        mods.retainWhere((mod) => mod.isEnabled);
        break;
      case ModFilter.disabled:
        mods.retainWhere((mod) => !mod.isEnabled);
        break;
      case ModFilter.updatesAvailable:
        mods.retainWhere((mod) {
          final updateInfo = _modUpdates[mod.directory.path];
          if (updateInfo == null) return false;

          final updateIdentifier = mod.directory.path + updateInfo['version'];
          return !_ignoredUpdates.contains(updateIdentifier);
        });
        break;
      case ModFilter.all:
      default:
        // No filtrar por estado
        break;
    }

    // --- 3. APLICA EL FILTRO DE BÚSQUEDA ---
    if (_searchQuery.isNotEmpty) {
      mods.retainWhere((mod) {
        final displayTag =
            mod.customFitMeshType ?? mod.fitMeshType ?? l10n.modCategoryOther;
        final query = _searchQuery.toLowerCase();

        final nameMatch = mod.customName.toLowerCase().contains(query);
        final tagMatch = displayTag.toLowerCase().contains(query);
        // Comprueba si el traje reemplazado coincide con la búsqueda
        final outfitMatch = (mod.replacesOutfits != null)
            ? mod.replacesOutfits!.any((outfit) => outfit.toLowerCase().contains(query))
            : false;

        return nameMatch || tagMatch || outfitMatch; // Añade outfitMatch
      });
    }

    // --- 4. APLICA EL ORDENAMIENTO ---
    switch (_currentSort) {
      case ModSort.name:
        mods.sort(
          (a, b) =>
              a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
        );
        break;
      case ModSort.date:
      default:
        mods.sort((a, b) {
          final dateCompare = b.lastModified.compareTo(a.lastModified);

          if (dateCompare != 0) {
            return dateCompare;
          }
          return a.customName.toLowerCase().compareTo(
            b.customName.toLowerCase(),
          );
        });
        break;
    }
    return mods;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredAndSortedMods = _getFilteredAndSortedMods(l10n);

    final cnsUpdateIdentifier = _cnsUpdateInfo != null
        ? 'CNS_' + _cnsUpdateInfo!['version']
        : '';
    final cnsIsIgnored = _ignoredUpdates.contains(cnsUpdateIdentifier);
    final hasEnabledMods = _allMods.any((mod) => mod.isEnabled);
    final hasDisabledMods = _allMods.any((mod) => !mod.isEnabled);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: IosColors.bar,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 52,
        centerTitle: false,
        titleSpacing: 16,
        shape: const Border(
          bottom: BorderSide(color: IosColors.separator, width: 0.5),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                _cnsVersion != null
                    ? l10n.appTitleWithVersion(_cnsVersion!)
                    : l10n.appTitleNoCns,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: IosColors.label,
                ),
              ),
            ),
            if (_cnsUpdateInfo != null && !cnsIsIgnored)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IosToolbarButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    color: IosColors.yellow,
                    size: 20.0,
                  ),
                  tooltip: l10n.updateAvailable(_cnsUpdateInfo!['version']),
                  onPressed: () {
                    if (_cnsNexusId != null) {
                      _showUpdateOptionsDialog(
                        newVersion: _cnsUpdateInfo!['version'],
                        nexusId: _cnsNexusId!,
                        fileId: _cnsUpdateInfo!['fileId'],
                        uniqueIdentifier: cnsUpdateIdentifier,
                      );
                    }
                  },
                ),
              ),
          ],
        ),
        actions: [
          // Botón "Jugar / Detener": cápsula verde para lanzar el juego y roja
          // mientras está en ejecución (al pulsarla lo cierra).
          IosToolbarButton(
            width: 44,
            height: 28,
            background: _isGameRunning ? IosColors.red : IosColors.green,
            // 'busy' ignora los clics sin atenuar el botón, para que se vea el spinner.
            busy: _isLaunchingGame || _isStoppingGame,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
              child: (_isLaunchingGame || _isStoppingGame)
                  ? const CupertinoActivityIndicator(
                      key: ValueKey('game-spinner'),
                      radius: 8,
                      color: Colors.white,
                    )
                  : (_isGameRunning
                      ? const Icon(
                          Icons.stop_rounded,
                          key: ValueKey('game-stop'),
                          color: Colors.white,
                          size: 20.0,
                        )
                      : const Icon(
                          Icons.sports_esports_rounded,
                          key: ValueKey('game-play'),
                          color: Colors.white,
                          size: 18.0,
                        )),
            ),
            tooltip: _isGameRunning
                ? AppLocalizations.of(context)!.stopGameText
                : AppLocalizations.of(context)!.launchGameText,
            onPressed: _isGameRunning
                ? _stopGame
                : ((_isLoading || _gameRootPath == null) ? null : _launchGame),
          ),
          const SizedBox(width: 8),
          IosToolbarButton(
            icon: _isCheckingForUpdates
                ? const CupertinoActivityIndicator(radius: 8)
                : const HugeIcon(icon: HugeIcons.strokeRoundedWifiSync, color: IosColors.icon, size: 20.0),
            tooltip: l10n.checkForUpdates,
            onPressed: _isLoading || _isCheckingForUpdates
                ? null
                : _checkForUpdates,
          ),
          if (_apiKey != null && _apiKey!.isNotEmpty)
            _buildUserProfileMenu(),
          IosToolbarButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedSetting07, color: IosColors.icon, size: 20.0),
            tooltip: l10n.settings,
            onPressed: () => _openSettings(),
          ),
          const SizedBox(width: 10),
        ],
      ),

      // El body del Scaffold ahora es un Stack que contiene
      // el DropTarget (cuerpo principal) Y el nuevo Overlay de vista previa
      body: Stack(
        children: [
          DropTarget(
            onDragDone: (details) async {
              final files = details.files
                  .map((file) => File(file.path))
                  .toList();
              if (files.isNotEmpty) {
                // En lugar de procesar, ahora abre el panel CON los archivos.
                _showInstallationPanel(initialFiles: files);
              }
            },
            onDragEntered: (details) => setState(() => _isDragging = true),
            onDragExited: (details) => setState(() => _isDragging = false),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _finalModsPath == null && !_isLoading
                      ? _buildPathSelectionScreen(l10n)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_modsToInstallPreviewMap.isNotEmpty)
                              const Divider(height: 30, thickness: 1),
                            Expanded(
                              child: _buildModsListSection(
                                l10n.installedMods,
                                filteredAndSortedMods,
                                l10n,
                                hasEnabledMods,
                                hasDisabledMods,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_isUpdatingMetadata)
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      _metadataUpdateStatus,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  IosProgressBar(
                                    value: _metadataUpdateProgress,
                                  ),
                                ],
                              )
                            else if (_isCheckingForUpdates)
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      l10n.statusCheckingUpdates,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const IosProgressBar(),
                                ],
                              )
                            else if (_isLoading)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: IosSpinner(radius: 12),
                                ),
                              )
                            else
                              Text(
                                _statusMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                ),
                if (_isDragging)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.72),
                      border: Border.all(
                        color: IosColors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedArchiveArrowDown,
                            size: 80,
                            color: IosColors.blue,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.dropTargetOverlay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ++ AÑADIDO: El overlay de vista previa se renderiza aquí ++
          //_buildOutfitPreviewOverlay(),
        ],
      ),
    );
  }

  Widget _buildPathSelectionScreen(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.orangeAccent, size: 64),
          const SizedBox(height: 24),
          Text(
            l10n.pathSelectionTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _statusMessage,
            style: TextStyle(color: _statusColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedFolder01, color: Colors.white, size: 24.0),
            label: Text(l10n.pathSelectionButtonManual),
            onPressed: _selectGamePathManually,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          TextButton(
            onPressed: _findGamePath,
            child: Text(l10n.pathSelectionButtonRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildModGridCard(ModInfo modInfo, AppLocalizations l10n) {
  final updateInfo = _modUpdates[modInfo.directory.path];
  final hasUpdate = updateInfo != null;
  final updateIdentifier = hasUpdate ? modInfo.directory.path + updateInfo['version'] : '';
  final isIgnored = _ignoredUpdates.contains(updateIdentifier);
  final isHighlighted = _lastInstalledModNames.contains(p.basename(modInfo.directory.path));
  final displayVersion = modInfo.customVersion ?? modInfo.localVersion;
  final bool isReplacement = modInfo.replacesOutfits != null && modInfo.replacesOutfits!.isNotEmpty;
  final String displayTag = isReplacement
      ? modInfo.replacesOutfits!.first
      : (modInfo.customFitMeshType ?? modInfo.fitMeshType ?? l10n.modCategoryOther);

  void _performSurgicalUpdate(ModInfo? updatedMod) {
    if (updatedMod == null) return;
    final modIndex = _allMods.indexWhere((m) => m.directory.path == updatedMod.directory.path);
    if (modIndex != -1) {
      setState(() {
        _allMods[modIndex] = updatedMod;
      });
    }
  }

  return ModGridCard(
    modInfo: modInfo,
    editionCount: _installedEditionsOf(modInfo).length,
    l10n: l10n,
    thumbnailService: _thumbnailService,
    updateInfo: updateInfo,
    isIgnored: isIgnored,
    isHighlighted: isHighlighted,
    showModTypeTags: _showModTypeTags,
    isLoading: _isLoading,
    onTapDetails: () => _showDetailsPage(modInfo),
    onUpdateAvailableTap: () {
      if (modInfo.nexusId != null) {
        _showUpdateOptionsDialog(
          newVersion: updateInfo!['version'],
          nexusId: modInfo.nexusId!,
          fileId: updateInfo['fileId'],
          uniqueIdentifier: updateIdentifier,
          mod: modInfo,
        );
      }
    },
    onEditVersionTap: () async {
      final updatedMod = await EditDialogs.showEditDialog(
        context: context,
        title: l10n.editVersionText,
        label: l10n.customVersionText,
        initialValue: displayVersion ?? '',
        defaultValue: modInfo.localVersion ?? '',
        maxLength: 15,
        onSave: (newValue) => _updateModCustomProperty(modInfo, newVersion: newValue),
      );
      _performSurgicalUpdate(updatedMod);
    },
    onEditTagTap: () async {
      final updatedMod = await EditDialogs.showEditDialog(
        context: context,
        title: l10n.editTagText,
        label: l10n.customTagText,
        initialValue: displayTag,
        defaultValue: modInfo.fitMeshType ?? l10n.modCategoryOther,
        onSave: (newValue) => _updateModCustomProperty(modInfo, newTag: newValue),
      );
      _performSurgicalUpdate(updatedMod);
    },
    onHoverEnter: (position, outfitName) {
      _cursorPosition = position;
      _hoverTimer?.cancel();
      _hoverTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          _showPreviewOverlay(context, outfitName, _cursorPosition);
        }
      });
    },
    onHoverMove: (position) => _cursorPosition = position,
    onHoverExit: () => _hidePreviewOverlay(),
    onEnable: _enableMod,
    onDisable: _disableMod,
    onEditNameTap: () async {
      final newName = await EditDialogs.showEditModNameDialog(context, modInfo);
      if (newName != null && newName.trim().isNotEmpty) {
        final updatedMod = await _updateModCustomName(modInfo, newName.trim());
        _performSurgicalUpdate(updatedMod);
      }
    },
    onSetCoverTap: () => _setCustomCover(modInfo),
    onAdjustCoverTap: () => _adjustCover(modInfo),
    onRevertCoverTap: () => _revertToDefaultCover(modInfo),
    onShowFolderTap: () => _showModInExplorer(modInfo),
    onShowGalleryTap: () => _showImageGalleryDialog(modInfo),
    onOpenNexusTap: () async {
      if (modInfo.nexusId != null) {
        final url = Uri.parse('https://www.nexusmods.com/stellarblade/mods/${modInfo.nexusId}');
        if (await canLaunchUrl(url)) await launchUrl(url);
      }
    },
    onDeleteTap: () => _deleteModPermanently(modInfo),
  );
}

  Widget _buildModListTile(ModInfo modInfo, AppLocalizations l10n) {
  final isHighlighted = _lastInstalledModNames.contains(p.basename(modInfo.directory.path));
  final updateInfo = _modUpdates[modInfo.directory.path];
  final hasUpdate = updateInfo != null;
  final updateIdentifier = hasUpdate ? modInfo.directory.path + updateInfo['version'] : '';
  final isIgnored = _ignoredUpdates.contains(updateIdentifier);

  void _performSurgicalUpdate(ModInfo? updatedMod) {
    if (updatedMod == null) return;
    final modIndex = _allMods.indexWhere((m) => m.directory.path == updatedMod.directory.path);
    if (modIndex != -1) {
      setState(() {
        _allMods[modIndex] = updatedMod;
      });
    }
  }

  return ModListTile(
    modInfo: modInfo,
    editionCount: _installedEditionsOf(modInfo).length,
    l10n: l10n,
    updateInfo: updateInfo,
    isIgnored: isIgnored,
    isHighlighted: isHighlighted,
    isLoading: _isLoading,
    onRepairedInfoTap: _showRepairedModInfoDialog,
    onDeleteTap: () => _deleteModPermanently(modInfo),
    onUpdateAvailableTap: () {
      if (modInfo.nexusId != null) {
        _showUpdateOptionsDialog(
          newVersion: updateInfo!['version'],
          nexusId: modInfo.nexusId!,
          fileId: updateInfo['fileId'],
          uniqueIdentifier: updateIdentifier,
          mod: modInfo,
        );
      }
    },
    onEditNameTap: () async {
      final newName = await EditDialogs.showEditModNameDialog(context, modInfo);
      if (newName != null && newName.trim().isNotEmpty) {
        final updatedMod = await _updateModCustomName(modInfo, newName.trim());
        _performSurgicalUpdate(updatedMod);
      }
    },
    onAdjustCoverTap: () => _adjustCover(modInfo),
    onShowFolderTap: () => _showModInExplorer(modInfo),
    onShowGalleryTap: () => _showImageGalleryDialog(modInfo),
    onOpenNexusTap: () async {
      if (modInfo.nexusId != null) {
        final url = Uri.parse('https://www.nexusmods.com/stellarblade/mods/${modInfo.nexusId}');
        if (await canLaunchUrl(url)) await launchUrl(url);
      }
    },
    onEnable: _enableMod,
    onDisable: _disableMod,
  );
}

  Widget _buildModsListSection(
    String title,
    List<ModInfo> mods,
    AppLocalizations l10n,
    bool hasEnabledMods,
    bool hasDisabledMods,
  ) {
    // Estados calculados sobre la vista actual (ya filtrada)
    final bool hasEnabledModsInView = mods.any((mod) => mod.isEnabled);
    final bool hasDisabledModsInView = mods.any((mod) => !mod.isEnabled);

    // Mismo orden que el enum ModTypeFilter
    final typeLabels = <ModTypeFilter, String>{
      ModTypeFilter.all: l10n.filterAll,
      ModTypeFilter.cns: l10n.modTypeCNS,
      ModTypeFilter.replacement: l10n.modTypeReplacement,
      ModTypeFilter.movies: l10n.modTypeMovies,
      ModTypeFilter.logicMod: l10n.modTypeLogic,
      ModTypeFilter.generic: l10n.modTypeGeneric,
      ModTypeFilter.save: l10n.modTypeSave,
      ModTypeFilter.config: l10n.modTypeConfig,
      ModTypeFilter.splash: l10n.modTypeSplash,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IosButton(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedAddCircle, color: Colors.white, size: 18.0),
              label: l10n.installNewMod,
              onPressed: _showInstallationPanel,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: IosSearchField(
                controller: _searchController,
                placeholder: l10n.searchMods,
              ),
            ),
            const SizedBox(width: 10),
            IosSegmented<ModListViewMode>(
              value: _viewMode,
              onChanged: (newMode) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt(AppPrefs.viewMode, newMode.index);
                setState(() => _viewMode = newMode);
              },
              children: {
                ModListViewMode.grid: Tooltip(
                  message: l10n.viewTypeGrid,
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedLayoutGrid, color: IosColors.label, size: 17.0),
                ),
                ModListViewMode.list: Tooltip(
                  message: l10n.viewTypeList,
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedLeftToRightListBullet, color: IosColors.label, size: 17.0),
                ),
              },
            ),
            const SizedBox(width: 6),
            IosMenuButton<ModFilter>(
              tooltip: l10n.filterBy,
              // El icono se pinta de azul cuando hay un filtro activo
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedFilter,
                size: 20.0,
                color: _currentFilter != ModFilter.all ? IosColors.blue : IosColors.icon,
              ),
              onSelected: (ModFilter result) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt(AppPrefs.filterMode, result.index);
                setState(() => _currentFilter = result);
              },
              itemBuilder: (context) => [
                iosMenuItem<ModFilter>(value: ModFilter.all, label: l10n.filterAll, selected: _currentFilter == ModFilter.all),
                iosMenuItem<ModFilter>(value: ModFilter.enabled, label: l10n.filterEnabled, selected: _currentFilter == ModFilter.enabled),
                iosMenuItem<ModFilter>(value: ModFilter.disabled, label: l10n.filterDisabled, selected: _currentFilter == ModFilter.disabled),
                iosMenuItem<ModFilter>(value: ModFilter.updatesAvailable, label: l10n.filterUpdatesAvailable, selected: _currentFilter == ModFilter.updatesAvailable),
              ],
            ),
            IosMenuButton<ModSort>(
              tooltip: l10n.sortBy,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedSorting01, color: IosColors.icon, size: 20.0),
              onSelected: (ModSort result) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt(AppPrefs.sortMode, result.index);
                setState(() => _currentSort = result);
              },
              itemBuilder: (context) => [
                iosMenuItem<ModSort>(value: ModSort.date, label: l10n.sortByDate, selected: _currentSort == ModSort.date),
                iosMenuItem<ModSort>(value: ModSort.name, label: l10n.sortByName, selected: _currentSort == ModSort.name),
              ],
            ),
            IosToolbarButton(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedFolderSymlink, color: IosColors.icon, size: 20.0),
              tooltip: l10n.openModsFolder,
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_finalModsPath != null) {
                        _showInExplorer(Directory(_genericModsPath!));
                      }
                    },
            ),
            IosToolbarButton(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh01, color: IosColors.icon, size: 20.0),
              tooltip: l10n.refreshList,
              onPressed: _isLoading ? null : () => _loadAllMods(clearHighlight: true),
            ),
            // Acciones masivas agrupadas en un solo menú (⋯)
            IosMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: IosColors.icon, size: 22),
              onSelected: (action) {
                switch (action) {
                  case 'enable_all':
                    _enableAllMods(mods);
                    break;
                  case 'disable_all':
                    _disableAllMods(mods);
                    break;
                  case 'delete_disabled':
                    _deleteDisabledMods(mods);
                    break;
                }
              },
              itemBuilder: (context) => [
                iosMenuItem<String>(
                  value: 'enable_all',
                  label: l10n.enableAllModsTooltip,
                  enabled: !_isLoading && hasDisabledModsInView,
                  leading: const HugeIcon(icon: HugeIcons.strokeRoundedPower, color: IosColors.green, size: 16.0),
                ),
                iosMenuItem<String>(
                  value: 'disable_all',
                  label: l10n.disableAllModsTooltip,
                  enabled: !_isLoading && hasEnabledModsInView,
                  leading: const HugeIcon(icon: HugeIcons.strokeRoundedPowerOff, color: IosColors.orange, size: 16.0),
                ),
                const PopupMenuDivider(height: 8),
                iosMenuItem<String>(
                  value: 'delete_disabled',
                  label: l10n.deleteAllModsTooltip,
                  destructive: true,
                  enabled: !_isLoading && hasDisabledModsInView,
                  leading: const HugeIcon(icon: HugeIcons.strokeRoundedDelete04, color: IosColors.red, size: 16.0),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Filtros por tipo: control segmentado centrado y adaptable. Reduce su
        // tamaño al estrecharse la ventana y, si no cabe, pasa a ser un
        // selector desplegable.
        IosAdaptiveSegmented<ModTypeFilter>(
          value: _currentModTypeFilter,
          labels: typeLabels,
          onChanged: (newFilter) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt(AppPrefs.modTypeFilterMode, newFilter.index);
            setState(() => _currentModTypeFilter = newFilter);
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: mods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 44, color: IosColors.tertiaryLabel),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noModsFound,
                        style: const TextStyle(fontSize: 14, color: IosColors.secondaryLabel),
                      ),
                    ],
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _viewMode == ModListViewMode.grid
                      ? GridView.builder(
                          key: const ValueKey('grid'),
                          controller: _gridScrollController,
                          // Construye (y decodifica las portadas de) unas filas
                          // por delante de lo visible: al hacer scroll las
                          // tarjetas ya están listas al entrar en pantalla.
                          cacheExtent: 700,
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                childAspectRatio: 3 / 4.5,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                          itemCount: mods.length,
                          itemBuilder: (context, index) {
                            return _buildModGridCard(mods[index], l10n);
                          },
                        )
                      : ListView.builder(
                          key: const ValueKey('list'),
                          controller: _listScrollController,
                          cacheExtent: 700,
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: mods.length,
                          itemBuilder: (context, index) {
                            return _buildModListTile(mods[index], l10n);
                          },
                        ),
                ),
        ),
      ],
    );
  }

  Future<void> _setCustomCover(ModInfo mod) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp', 'pwebp', 'tiff'],
      dialogTitle: AppLocalizations.of(context)!.dialogTitleSelectCover,
    );

    if (result != null && result.files.single.path != null) {
      final imageFile = File(result.files.single.path!);
      final Alignment? alignment = await EditDialogs.showCoverAlignmentDialog(context,imageFile);

      if (alignment == null) return;

      setState(() => _isLoading = true);
      try {
        // ===== INICIO DE LA CORRECCIÓN =====
        await FileManagerService.cleanOldCustomCovers(mod.directory);
        // 1. Guarda los cambios en el archivo nexus_info.json
        final extension = p.extension(imageFile.path);
        final newFileName = '_custom_cover$extension';
        final destinationPath = p.join(mod.directory.path, newFileName);
        await imageFile.copy(destinationPath);

        PaintingBinding.instance.imageCache.clear(); // <--- NUEVO (Fuerza a Flutter a olvidar la imagen vieja)
        PaintingBinding.instance.imageCache.clearLiveImages(); // <--- NUEVO (Limpia las imágenes que aún están en uso)

        final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
        Map<String, dynamic> data = {};
        if (await infoFile.exists()) {
          final content = await infoFile.readAsString();
          if (content.isNotEmpty) data = json.decode(content);
        }
        data['customCoverPath'] = newFileName;
        data['customCoverAlignmentX'] = alignment.x;
        data['customCoverAlignmentY'] = alignment.y;
        final encoder = JsonEncoder.withIndent('  ');
        await infoFile.writeAsString(encoder.convert(data));

        // 2. Llama a _loadAllMods() para recargar discretamente toda la lista
        // con la información 100% correcta desde los archivos.
        await _loadAllMods(clearHighlight: false);
        // ===== FIN DE LA CORRECCIÓN =====
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          NotificationService.instance.show(
            context: context,
            type: NotificationType.error,
            title: l10n.errorRestoringCoverText(e.toString()),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Reajusta el encuadre de la portada que el mod muestra ahora: la
  /// personalizada si la tiene, o la de Nexus (`_nexus_cover.*`). Si la portada
  /// de Nexus aún no está en disco se descarga primero. Devuelve el mod
  /// recargado, o null si no se cambió nada.
  Future<ModInfo?> _adjustCover(ModInfo mod) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
      Map<String, dynamic> data = {};
      if (await infoFile.exists()) {
        final content = await infoFile.readAsString();
        if (content.isNotEmpty) data = json.decode(content);
      }

      // 1. Portada actual en disco (personalizada o `_nexus_cover.*`).
      String? coverName = data['customCoverPath'] as String?;
      File? coverFile;
      if (coverName != null && coverName.isNotEmpty) {
        final f = File(p.join(mod.directory.path, coverName));
        if (await f.exists()) coverFile = f;
      }

      // 2. Sin portada local: se baja la primera imagen de la galería.
      if (coverFile == null) {
        final String? url = (mod.gallery != null && mod.gallery!.isNotEmpty)
            ? mod.gallery!.first['image'] as String?
            : null;
        if (url == null || url.isEmpty) {
          if (mounted) {
            NotificationService.instance.show(
              context: context,
              type: NotificationType.error,
              title: l10n.noCoverToAdjust,
            );
          }
          return null;
        }
        setState(() => _isLoading = true);
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode != 200) {
            throw Exception('HTTP ${response.statusCode}');
          }
          final String ext = p.extension(Uri.parse(url).path);
          coverName = '_nexus_cover${ext.isNotEmpty ? ext : '.jpg'}';
          coverFile = File(p.join(mod.directory.path, coverName));
          await coverFile.writeAsBytes(response.bodyBytes);
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }

      if (!mounted) return null;

      // 3. Diálogo de encuadre, empezando por el ajuste que ya tenga.
      final Alignment current = Alignment(
        (data['customCoverAlignmentX'] as num?)?.toDouble() ?? 0.0,
        (data['customCoverAlignmentY'] as num?)?.toDouble() ?? 0.0,
      );
      final Alignment? alignment = await EditDialogs.showCoverAlignmentDialog(
        context,
        coverFile,
        initialAlignment: current,
      );
      if (alignment == null) return null;

      // 4. Se guarda solo el encuadre (y la ruta si venía de Nexus).
      data['customCoverPath'] = coverName;
      data['customCoverAlignmentX'] = alignment.x;
      data['customCoverAlignmentY'] = alignment.y;
      await infoFile.writeAsString(JsonEncoder.withIndent('  ').convert(data));

      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      await _loadAllMods(clearHighlight: false);
      final idx = _allMods.indexWhere((m) => m.directory.path == mod.directory.path);
      return idx != -1 ? _allMods[idx] : null;
    } catch (e) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.errorAdjustingCoverText(e.toString()),
        );
      }
      return null;
    }
  }

  Future<void> _revertToDefaultCover(ModInfo mod) async {
    final l10n = AppLocalizations.of(context)!;
    if (mod.customCoverPath == null || mod.customCoverPath!.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
      if (!await infoFile.exists()) {
        throw Exception(l10n.errorNexusInfoNotFound);
      }

      // --- START: NEW SMART REVERT LOGIC ---

      // 1. Delete the current custom cover file, but ONLY if it's NOT the cached nexus file.
      final currentCoverFile = File(
        p.join(mod.directory.path, mod.customCoverPath!),
      );
      if (!p.basename(currentCoverFile.path).startsWith('_nexus_cover')) {
        if (await currentCoverFile.exists()) {
          await currentCoverFile.delete();
        }
      }

      // 2. Read the JSON data.
      Map<String, dynamic> data = json.decode(await infoFile.readAsString());

      // 3. Check if a cached nexus cover exists in the mod's folder.
      String? cachedNexusCoverName;
      await for (final file in mod.directory.list()) {
        if (file is File && p.basename(file.path).startsWith('_nexus_cover')) {
          cachedNexusCoverName = p.basename(file.path);
          break;
        }
      }

      // 4. Update the JSON based on whether a cached cover was found.
      if (cachedNexusCoverName != null) {
        // A cached version exists, so point the custom path to it.
        data['customCoverPath'] = cachedNexusCoverName;
        // Also set a default center alignment for it.
        data['customCoverAlignmentX'] = 0.0;
        data['customCoverAlignmentY'] = 0.0;
      } else {
        // No cached version was found, so remove the custom path and alignment completely.
        // This will force the UI to fall back to the internet URL.
        data.remove('customCoverPath');
        data.remove('customCoverAlignmentX');
        data.remove('customCoverAlignmentY');
      }

      // --- END: NEW SMART REVERT LOGIC ---

      // 5. Write the updated data back to the file.
      final encoder = JsonEncoder.withIndent('  ');
      await infoFile.writeAsString(encoder.convert(data));

      // 6. Reload the mods list to reflect the changes in the UI.
      await _loadAllMods(clearHighlight: false);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.errorRestoringCoverText(e.toString()),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDetailsPage(ModInfo modInfo) async {
    void onPanelClosed(ModInfo? updatedModInfo) {
      if (updatedModInfo != null) {
        // Usamos addPostFrameCallback para posponer la actualización hasta que el árbol de widgets
        // esté desbloqueado (después de que el panel se haya cerrado por completo).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted)
            return; // Buena práctica: verificar si el widget aún existe.

          final modIndex = _allMods.indexWhere(
            (mod) => mod.directory.path == updatedModInfo.directory.path,
          );

          if (modIndex != -1) {
            setState(() {
              _allMods[modIndex] = updatedModInfo;
            });
          }
        });
      }
    }

    // ++ INICIO DE LA MODIFICACIÓN ++
    // Obtenemos la información de actualización y el estado "ignorado" para este mod específico.
    final updateInfo = _modUpdates[modInfo.directory.path];
    final hasUpdate = updateInfo != null;
    final updateIdentifier = hasUpdate
        ? modInfo.directory.path + (updateInfo['version'] as String)
        : '';
    final isIgnored = _ignoredUpdates.contains(updateIdentifier);
    // ++ FIN DE LA MODIFICACIÓN ++

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Subida más larga y con la curva de las hojas de iOS (arranque rápido,
      // frenado muy suave). El panel monta su contenido pesado al terminar.
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 380),
        curve: IosMotion.sheet,
        reverseDuration: const Duration(milliseconds: 260),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (context) => ModDetailsPanel(
        initialModInfo: modInfo,
        otherEditions: _otherEditionsOf(modInfo),
        thumbnailService: _thumbnailService,
        onUpdateDetails: _updateModDetails,
        onShowInExplorer: _showModInExplorer,
        onShowImageGallery: _showImageGalleryDialog,
        onShowGeneralEditDialog: EditDialogs.showGeneralEditDialog,
        onAdjustCover: _adjustCover,
        onPanelClosed: onPanelClosed,

        // ++ INICIO DE LA MODIFICACIÓN ++
        // Pasamos la información de la actualización y la función del diálogo al panel.
        updateInfo: updateInfo,
        isIgnored: isIgnored,
        onShowUpdateDialog: _showUpdateOptionsDialog,
        // API key de Nexus: necesaria para el botón de endorse del panel.
        apiKey: _apiKey,
        // ++ FIN DE LA MODIFICACIÓN ++
      ),
    );
    Future<void>.delayed(const Duration(milliseconds: 600), () {
  if (mounted) _showImageGalleryDialog(modInfo, prewarmOnly: true);
});
  }

  /// Guarda una propiedad personalizada (versión o etiqueta) en el JSON y actualiza el estado.
  Future<ModInfo?> _updateModCustomProperty(
    ModInfo mod, {
    String? newVersion,
    String? newTag,
  }) async {
    try {
      final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
      Map<String, dynamic> data = {};
      if (await infoFile.exists()) {
        final content = await infoFile.readAsString();
        if (content.isNotEmpty) data = json.decode(content);
      }

      if (newVersion != null) {
        if (newVersion.isEmpty || newVersion == mod.localVersion) {
          data.remove('customVersion');
        } else {
          data['customVersion'] = newVersion;
        }
      }

      if (newTag != null) {
        if (newTag.isEmpty || newTag == mod.fitMeshType) {
          data.remove('customFitMeshType');
        } else {
          data['customFitMeshType'] = newTag;
        }
      }

      final encoder = JsonEncoder.withIndent('  ');
      await infoFile.writeAsString(encoder.convert(data));

      // Reconstruye manualmente el objeto para asegurar que los nulos se apliquen
      return ModInfo(
        directory: mod.directory,
        nexusId: mod.nexusId,
        localVersion: mod.localVersion,
        lastModified: mod.lastModified,
        installDate: mod.installDate,
        isEnabled: mod.isEnabled,
        origin: mod.origin,
        displayName: mod.displayName,
        customName: mod.customName,
        gallery: mod.gallery,
        fitMeshType: mod.fitMeshType,
        customCoverPath: mod.customCoverPath,
        customCoverAlignment: mod.customCoverAlignment,
        customCoverLastModified: mod.customCoverLastModified,
        // Asigna directamente desde el mapa 'data' para reflejar los valores eliminados
        customVersion: data['customVersion'],
        customFitMeshType: data['customFitMeshType'],
        summary: mod.summary,
        customSummary: mod.customSummary,
        description: mod.description,
        customDescription: data['customDescription'],
        author: mod.author,
        customAuthor: mod.customAuthor,
        userNotes: mod.userNotes,
        sourceUrl: mod.sourceUrl,
        customSourceUrl: mod.customSourceUrl,
        modName: mod.modName,
        editionName: mod.editionName,
      );
    } catch (e) {
      print('Error updating custom property: $e');
      return null;
    }
  }

  String? _extractNexusIdFromUrl(String url) {
    try {
      // Regex para encontrar ".../stellarblade/mods/123"
      final regex = RegExp(r'nexusmods\.com/stellarblade/mods/(\d+)');
      final match = regex.firstMatch(url);
      // Devuelve el primer grupo capturado (el ID) si hay coincidencia.
      return match?.group(1);
    } catch (e) {
      print("Error al analizar la URL de Nexus: $e");
      return null;
    }
  }

  /// Actualiza múltiples detalles del mod en el archivo JSON y devuelve un ModInfo actualizado.
  Future<ModInfo?> _updateModDetails(
    ModInfo mod,
    Map<String, dynamic> newData,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      Directory modDirectory = mod.directory;

      // Prepara la compatibilidad para recibir listas de la futura UI
      if (newData.containsKey('replacesOutfit') || newData.containsKey('replacesOutfits')) {
        List<String> newOutfits = [];
        if (newData.containsKey('replacesOutfits') && newData['replacesOutfits'] != null) {
          newOutfits = List<String>.from(newData['replacesOutfits']);
        } else if (newData.containsKey('replacesOutfit') && newData['replacesOutfit'] != null) {
          final String single = newData['replacesOutfit'] as String;
          if (single.isNotEmpty) newOutfits.add(single);
        }

        if (newOutfits.isNotEmpty) {
          ModInfo? conflictingMod;
          List<String> overlappingOutfits = [];
          
          try {
            for (final otherMod in _allMods) {
              if (otherMod.isEnabled && otherMod.directory.path != mod.directory.path) {
                final otherOutfits = otherMod.replacesOutfits ?? [];
                // Compara si la nueva lista de trajes choca con algún mod habilitado
                final intersection = newOutfits.where((o) => otherOutfits.contains(o)).toList();
                
                if (intersection.isNotEmpty) {
                  conflictingMod = otherMod;
                  overlappingOutfits = intersection;
                  break;
                }
              }
            }
          } catch (e) {
            conflictingMod = null;
          }

          if (conflictingMod != null && mod.isEnabled) {
            final String outfitName = overlappingOutfits.join(', ');
            final String modName = conflictingMod.customName;

            // Obtenemos el texto completo de la localización
            final String fullString = l10n.dialogContentOutfitConflict(
              outfitName,
              modName,
            );

            // Dividimos el texto usando los nombres como separadores
            final List<String> parts = fullString.split(outfitName);
            final String part1 = parts.isNotEmpty ? parts[0] : "";

            String part2 = "";
            String part3 = "";

            if (parts.length > 1) {
              // Buscamos el nombre del mod en la segunda parte del texto
              final List<String> parts2 = parts[1].split(modName);
              part2 = parts2.isNotEmpty ? parts2[0] : "";
              if (parts2.length > 1) {
                part3 = parts2[1];
              }
            }

            final bool? forceActivate = await _showOutfitConflictDialog(
          part1: part1,
          outfitName: outfitName,
          part2: part2,
          modName: modName,
          part3: part3,
          conflictingMod: conflictingMod,
        );

            // 4. Si el usuario canceló, detenemos el guardado
            if (forceActivate != true) {
              return null; // Devuelve null para indicar que no se guardó nada
            }

            // 5. Si el usuario confirmó, desactiva el mod conflictivo
            await _disableMod(conflictingMod);
          }
        }
      }

      final infoFile = File(p.join(modDirectory.path, 'nexus_info.json'));
      Map<String, dynamic> data = {};
      if (await infoFile.exists()) {
        final content = await infoFile.readAsString();
        if (content.isNotEmpty) data = json.decode(content);
      }

      String?
      newNexusId; // Para almacenar un nuevo ID y usarlo para cachear la miniatura
      if (newData.containsKey('customSourceUrl')) {
        final newUrl = newData['customSourceUrl'] as String;
        final potentialNexusId = _extractNexusIdFromUrl(newUrl);
        final oldNexusId = data['nexusId'] as String?;

        // Comprueba si es una URL de Nexus válida, nueva y diferente a la que ya teníamos
        if (potentialNexusId != null && potentialNexusId != oldNexusId) {
          print(
            'Nuevo Nexus ID $potentialNexusId detectado. Obteniendo metadatos...',
          );
          // Si es así, obtenemos los datos de la API
          final nexusData = await NexusApiService.fetchNexusModData(potentialNexusId, _apiKey);

          if (nexusData != null) {
            newNexusId =
                potentialNexusId; // Guardamos el ID para cachear la miniatura más tarde

            // Rellenamos el mapa 'data' con los nuevos metadatos
            data['nexusId'] = newNexusId;
            data['gallery'] = nexusData['gallery'];
            data['summary'] = nexusData['summary'];
            data['author'] = nexusData['author'];
            data['description'] = nexusData['description'];
            data['sourceUrl'] = newUrl; // Establece la URL principal

            // Limpiamos todos los campos personalizados que serían anulados por estos nuevos datos
            data.remove('customSourceUrl');
            data.remove('customSummary');
            data.remove('customAuthor');
            data.remove('customDescription');

            // También eliminamos las claves de 'newData' para que no se procesen de nuevo más abajo
            newData.remove('customSourceUrl');
            newData.remove(
              'author',
            ); // El diálogo 'General Edit' también envía 'author'
            // (No es necesario eliminar 'summary' o 'customDescription' ya que vienen de otros diálogos)

            print('Metadatos obtenidos y aplicados para $newNexusId.');
          }
        }
      }

      if (newData.containsKey('newCoverFile')) {
        await FileManagerService.cleanOldCustomCovers(modDirectory);
        final imageFile = newData['newCoverFile'] as File;
        final alignment = newData['newCoverAlignment'] as Alignment?;
        final extension = p.extension(imageFile.path);
        final newFileName = '_custom_cover$extension';
        final destinationPath = p.join(modDirectory.path, newFileName);
        await imageFile.copy(destinationPath);
        PaintingBinding.instance.imageCache.clear(); // <--- NUEVO
        PaintingBinding.instance.imageCache.clearLiveImages(); // <--- NUEVO
        data['customCoverPath'] = newFileName;
        if (alignment != null) {
          data['customCoverAlignmentX'] = alignment.x;
          data['customCoverAlignmentY'] = alignment.y;
        }
      }

      if (newData.containsKey('customName')) {
        final value = newData['customName'] as String;
        if (value.isEmpty || value == mod.displayName)
          data.remove('customName');
        else
          data['customName'] = value;
      }
      if (newData.containsKey('author')) {
        final value = newData['author'] as String;
        if (value.isEmpty || value == mod.author)
          data.remove('customAuthor');
        else
          data['customAuthor'] = value;
      }

      if (newData.containsKey('summary')) {
        final newCustomSummary = newData['summary'] as String;
        if (newCustomSummary.isEmpty || newCustomSummary == mod.summary) {
          data.remove('customSummary');
        } else {
          data['customSummary'] = newCustomSummary;
        }
      }

      if (newData.containsKey('customDescription')) {
        final newCustomDescription = newData['customDescription'] as String;
        // Si la nueva descripción es igual a la original (sin HTML), la eliminamos para no guardar datos redundantes.
        final originalDescriptionStripped = TextUtils.stripHtml(mod.description);
        if (newCustomDescription.isEmpty ||
            newCustomDescription == originalDescriptionStripped) {
          data.remove('customDescription');
        } else {
          data['customDescription'] = newCustomDescription;
        }
      }

      if (newData.containsKey('userNotes'))
        data['userNotes'] = newData['userNotes'];

      if (newData.containsKey('modType')) {
        data['modType'] = newData['modType'];
      }

      if (newData.containsKey('replacesOutfits') || newData.containsKey('replacesOutfit')) {
        // Edición manual: los trajes dejan de ser "auto-detectados" y el
        // reanálisis automático ya no los toca.
        data.remove(ModMetadataMigrator.outfitsAutoDetectedKey);
        List<String>? outList;
        if (newData.containsKey('replacesOutfits')) {
          outList = newData['replacesOutfits'] as List<String>?;
        } else {
          final val = newData['replacesOutfit'] as String?;
          outList = (val != null && val.isNotEmpty) ? [val] : null;
        }

        if (outList == null || outList.isEmpty) {
          data.remove('replacesOutfits');
          data.remove('replacesOutfit'); // Limpiamos la clave vieja
        } else {
          data['replacesOutfits'] = outList;
          data.remove('replacesOutfit'); // Nos aseguramos de no dejar basura
        }
      }

      if (newData.containsKey('customSourceUrl')) {
        final value = newData['customSourceUrl'] as String;
        if (value.isEmpty || value == mod.sourceUrl)
          data.remove('customSourceUrl');
        else
          data['customSourceUrl'] = value;
      }

      // Añade la lógica para manejar la versión y la etiqueta personalizadas.
      if (newData.containsKey('customVersion')) {
        final value = newData['customVersion'] as String;
        if (value.isEmpty || value == mod.localVersion) {
          data.remove('customVersion');
        } else {
          data['customVersion'] = value;
        }
      }

      if (newData.containsKey('customFitMeshType')) {
        final value = newData['customFitMeshType'] as String;
        if (value.isEmpty || value == mod.fitMeshType) {
          data.remove('customFitMeshType');
        } else {
          data['customFitMeshType'] = value;
        }
      }

      final encoder = JsonEncoder.withIndent('  ');
      await infoFile.writeAsString(encoder.convert(data));

      // --- LÍNEA ELIMINADA ---
      // await _loadAllMods(clearHighlight: false);  <-- ESTO CAUSABA EL PARPADEO
      if (newNexusId != null) {
        await ModManagerService.cacheNexusThumbnail(apiKey: _apiKey,
          modDirectory: modDirectory,
          nexusId: newNexusId,
        );
      }
      // Ahora, construimos y devolvemos un nuevo objeto ModInfo con los datos actualizados
      // para que el panel pueda refrescar su propia UI sin afectar el fondo.
      return ModInfo(
        directory: modDirectory,
        isEnabled: mod.isEnabled,
        lastModified: mod.lastModified,
        installDate: mod.installDate,
        displayName: data['displayName'] ?? mod.displayName,
        customName:
            data['customName'] ?? data['displayName'] ?? mod.displayName,
        nexusId: data['nexusId'] ?? mod.nexusId,
        localVersion: data['installedVersion'] ?? mod.localVersion,
        customVersion: data['customVersion'],
        origin: data['origin'] ?? mod.origin,
        gallery: data['gallery'] ?? mod.gallery,
        modType: data['modType'] ?? mod.modType,
        fitMeshType: data['fitMeshType'] ?? mod.fitMeshType,
        customFitMeshType: data['customFitMeshType'],
        customCoverPath: data['customCoverPath'],
        customCoverAlignment: data.containsKey('customCoverAlignmentX')
            ? Alignment(
                data['customCoverAlignmentX'],
                data['customCoverAlignmentY'],
              )
            : null,
        customCoverLastModified: data.containsKey('customCoverPath')
            ? await File(
                p.join(modDirectory.path, data['customCoverPath']),
              ).lastModified()
            : null,
        summary: data['summary'] ?? mod.summary,
        customSummary: data['customSummary'],
        description: data['description'] ?? mod.description,
        customDescription: data['customDescription'],
        author: data['author'] ?? mod.author,
        customAuthor: data['customAuthor'],
        userNotes: data['userNotes'],
        sourceUrl: data['sourceUrl'] ?? mod.sourceUrl,
        customSourceUrl: data['customSourceUrl'],
        replacesOutfits: data['replacesOutfits'] != null ? List<String>.from(data['replacesOutfits']) : null,
        modName: data['modName'] ?? mod.modName,
        editionName: data['editionName'] ?? mod.editionName,
      );
    } catch (e) {
      print('Error updating mod details: $e');
      final l10n = AppLocalizations.of(context)!;
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.errorSavingChanges,
          description: e.toString(),
        );
      }
      return null;
    }
  }

  /// Displays a confirmation dialog and then proceeds to delete all nexus_info.json files.
  Future<void> _deleteAllNexusInfoFiles() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await SettingsDialogs.confirm(
      context: context,
      title: l10n.devConfirmDeleteTitle,
      message: l10n.devConfirmDeleteDesc,
      confirmLabel: l10n.dialogActionDelete,
      destructive: true,
    );

    if (!confirm) return;

    setState(() => _isLoading = true);
    int deleteCount = 0;
    try {
      for (final mod in _allMods) {
        final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
        if (await infoFile.exists()) {
          try {
            await infoFile.delete();
            deleteCount++;
          } catch (e) {
            print('Could not delete nexus_info.json for ${mod.customName}: $e');
          }
        }
      }

      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.success,
          title: l10n.devDeleteSuccessTitle,
          description: l10n.devDeleteSuccessDesc(deleteCount),
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.errorDialogTitle,
          description: e.toString(),
        );
      }
    } finally {
      await _loadAllMods();
      setState(() => _isLoading = false);
    }
  }

  /// Extracts mod identifiers to a JSON file on the user's desktop.
  /// OPCIÓN DE DESARROLLADOR: prueba la auto-instalación de la propia app con
  /// un .zip local (el mismo que se distribuye en Nexus). Extrae, valida y, en
  /// una build de release, reemplaza los archivos de la app y la reinicia.
  Future<void> _testSelfUpdate() async {
    final l10n = AppLocalizations.of(context)!;

    if (!SelfUpdateService.isSupported) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.devSelfUpdateUnsupported,
      );
      return;
    }

    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      dialogTitle: l10n.devSelfUpdatePickTitle,
    );
    final String? zipPath = picked?.files.single.path;
    if (zipPath == null || !mounted) return;

    if (SelfUpdateService.canApply) {
      final confirm = await SettingsDialogs.confirm(
        context: context,
        title: l10n.devSelfUpdateConfirmTitle,
        message: l10n.devSelfUpdateConfirmDesc,
        confirmLabel: l10n.devSelfUpdateInstallAction,
      );
      if (!confirm || !mounted) return;
    }
    await _runSelfUpdate(zipPath: zipPath);
  }

  /// Consulta GitHub Releases. [manual] = true cuando lo pide el usuario
  /// (muestra "ya estás al día" / errores y no respeta "Omitir").
  Future<void> _checkForAppUpdate({bool manual = false}) async {
    if (!SelfUpdateService.isSupported || _appVersion.isEmpty) return;
    // En debug no se molesta con el aviso automático (no se puede aplicar).
    if (!manual && !SelfUpdateService.canApply) return;

    AppReleaseInfo? release;
    try {
      release = await GithubUpdateService.checkForUpdate(_appVersion);
    } catch (e) {
      print('App update check failed: $e');
      if (manual && mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: AppLocalizations.of(context)!.appUpdateCheckFailed,
        );
      }
      return;
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (release == null) {
      if (manual) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.success,
          title: l10n.appUpdateUpToDate,
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (!manual &&
        prefs.getString(AppPrefs.skippedAppVersion) == release.version) {
      return;
    }
    if (!mounted) return;

    var notes = release.notes;
    if (notes.length > 600) notes = '${notes.substring(0, 600)}…';
    final message = l10n.appUpdateAvailableDesc(_appVersion, release.version) +
        (notes.isEmpty ? '' : '\n\n$notes');

    final choice = await showIosDialog<String>(
      context: context,
      builder: (ctx) => IosDialogShell(
        title: l10n.appUpdateAvailableTitle,
        message: message,
        actions: [
          IosDialogButton(
            label: l10n.appUpdateSkip,
            onPressed: () => Navigator.of(ctx).pop('skip'),
          ),
          IosDialogButton(
            label: l10n.appUpdateLater,
            onPressed: () => Navigator.of(ctx).pop('later'),
          ),
          IosDialogButton(
            label: l10n.appUpdateNow,
            bold: true,
            onPressed: () => Navigator.of(ctx).pop('update'),
          ),
        ],
      ),
    );

    if (choice == 'skip') {
      await prefs.setString(AppPrefs.skippedAppVersion, release.version);
    } else if (choice == 'update' && mounted) {
      await _runSelfUpdate(release: release);
    }
  }

  /// Flujo común: (descarga) → extrae → instala → reinicia.
  /// Usa [zipPath] (zip local) o [release] (descarga desde GitHub).
  Future<void> _runSelfUpdate({String? zipPath, AppReleaseInfo? release}) async {
    assert(zipPath != null || release != null);
    final l10n = AppLocalizations.of(context)!;

    final navigator = Navigator.of(context, rootNavigator: true);
    final state = ValueNotifier<SelfUpdateUiState>(
      SelfUpdateUiState(release != null
          ? SelfUpdateStage.downloading
          : SelfUpdateStage.extracting),
    );
    SelfUpdateDialog.show(context, state);
    // Deja que el diálogo se pinte antes de empezar el trabajo pesado.
    await Future<void>.delayed(const Duration(milliseconds: 250));

    void report(SelfUpdateStage stage, double? fraction) {
      state.value = SelfUpdateUiState(stage, fraction: fraction);
    }

    File? downloaded;
    SelfUpdatePlan? plan;
    try {
      var path = zipPath;
      if (release != null) {
        downloaded = await GithubUpdateService.download(
          release,
          onProgress: (f) => report(SelfUpdateStage.downloading, f),
        );
        path = downloaded.path;
      }

      plan = await SelfUpdateService.prepareFromZip(path!, onProgress: report);

      if (downloaded != null) {
        try {
          await downloaded.delete();
        } catch (_) {}
        downloaded = null;
      }

      // Debug/profile: solo se valida el paquete, no se toca la app en ejecución.
      if (!SelfUpdateService.canApply) {
        final count = plan.fileCount;
        await SelfUpdateService.discard(plan);
        navigator.pop();
        if (mounted) {
          NotificationService.instance.show(
            context: context,
            type: NotificationType.info,
            title: l10n.devSelfUpdateDryRunTitle,
            description: l10n.devSelfUpdateDryRunDesc(count),
          );
        }
        return;
      }

      await SelfUpdateService.install(plan, onProgress: report);

      report(SelfUpdateStage.restarting, null);
      await SelfUpdateService.relaunch(plan);
      await Future<void>.delayed(const Duration(milliseconds: 600));
    } catch (e) {
      if (plan != null) await SelfUpdateService.discard(plan);
      try {
        if (downloaded != null && await downloaded.exists()) {
          await downloaded.delete();
        }
      } catch (_) {}
      // El diálogo pasa a mostrar el error con un botón Cerrar.
      state.value = SelfUpdateUiState(
        SelfUpdateStage.extracting,
        error: e.toString(),
      );
      return;
    }

    // La versión nueva ya está abierta y esperando a que este proceso termine.
    try {
      await windowManager.destroy();
    } catch (_) {}
    exit(0);
  }

  Future<void> _extractModIdentifiers() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await SettingsDialogs.confirm(
      context: context,
      title: l10n.devConfirmExtractTitle,
      message: l10n.devConfirmExtractDesc,
      confirmLabel: l10n.devExtractAction,
    );

    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> extractedData = {};
      for (final mod in _allMods) {
        final infoFile = File(p.join(mod.directory.path, 'nexus_info.json'));
        if (await infoFile.exists()) {
          try {
            final content = await infoFile.readAsString();
            final data = json.decode(content);
            final displayName = data['displayName'] as String?;
            final nexusId = data['nexusId'] as String?;

            if (displayName != null &&
                nexusId != null &&
                displayName.isNotEmpty &&
                nexusId.isNotEmpty) {
              extractedData[displayName] = {'nexusId': nexusId};
            }
          } catch (e) {
            print(
              'Could not parse nexus_info.json for ${mod.customName}, skipping.',
            );
          }
        }
      }

      if (extractedData.isEmpty) {
        if (mounted) {
          NotificationService.instance.show(
            context: context,
            type: NotificationType.info,
            title: l10n.devExtractNoData,
          );
        }
        return;
      }

      String? homePath;
      if (Platform.isWindows) {
        homePath = Platform.environment['USERPROFILE'];
      } else if (Platform.isLinux || Platform.isMacOS) {
        homePath = Platform.environment['HOME'];
      }

      if (homePath == null) {
        throw Exception(l10n.errorHomeDirNotFound);
      }

      final desktopDir = Directory(p.join(homePath, 'Desktop'));
      if (!await desktopDir.exists()) {
        if (mounted) {
          NotificationService.instance.show(
            context: context,
            type: NotificationType.error,
            title: l10n.devExtractDesktopNotFound,
          );
        }
        return;
      }

      final outputFile = File(p.join(desktopDir.path, 'ID Mods.json'));

      final encoder = JsonEncoder.withIndent('  ');
      await outputFile.writeAsString(encoder.convert(extractedData));

      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.success,
          title: l10n.devExtractSuccessTitle,
          description: l10n.devExtractSuccessDesc(outputFile.path),
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationService.instance.show(
          context: context,
          type: NotificationType.error,
          title: l10n.errorDialogTitle,
          description: e.toString(),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ¿Queda algo por llegar al panel? (descargas en curso, o ya terminadas
  /// pero aún sin apilar). Mientras sea así, el panel NO se cierra.
  bool _hasPendingDownloads() {
    if (_installQueue.isNotEmpty) return true;
    for (final t in DownloadManager.instance.activeDownloads) {
      if (t.status == DownloadStatus.fetching ||
          t.status == DownloadStatus.downloading) {
        return true;
      }
      if (t.status == DownloadStatus.complete &&
          t.file != null &&
          !_enqueuedDownloadPaths.contains(t.file!.path)) {
        return true;
      }
    }
    return false;
  }

  /// Pasa a la cola del panel los archivos que van llegando, de uno en uno
  /// (o en tandas) y SIN abrir otro panel: se extraen y se suman a la lista
  /// "Mods a instalar". Espera si el panel está extrayendo o instalando.
  Future<void> _drainInstallQueue(
    StateSetter setPanelState,
    VoidCallback closePanel,
  ) async {
    if (_isDrainingQueue) return;
    _isDrainingQueue = true;
    try {
      while (mounted && _installPanelOpen && _installQueue.isNotEmpty) {
        if (_isExtracting || _isInstalling) {
          await Future.delayed(const Duration(milliseconds: 250));
          continue;
        }
        final batch = List<File>.of(_installQueue);
        _installQueue.clear();
        // Solo se borrarán después los archivos que DESCARGÓ la app.
        _consumedDownloads.addAll(
          batch.where((f) => _enqueuedDownloadPaths.contains(f.path)),
        );

        final bool didInstall = await _processArchives(
          batch,
          panelStateSetter: setPanelState,
        );
        if (!mounted || !_installPanelOpen) break;
        if (didInstall && _preparedMods.isEmpty && !_hasPendingDownloads()) {
          closePanel();
          break;
        }
        setPanelState(() {});
      }
    } finally {
      _isDrainingQueue = false;
    }
  }

  /// Borra los archivos descargados que ya se extrajeron.
  Future<void> _deleteConsumedDownloads() async {
    final files = List<File>.of(_consumedDownloads);
    _consumedDownloads.clear();
    for (final f in files) {
      try {
        if (await f.exists()) {
          await f.delete();
          final parentDir = f.parent;
          if (await parentDir.exists() && await parentDir.list().isEmpty) {
            await parentDir.delete();
          }
        }
      } catch (e) {
        print("No se pudo limpiar el archivo descargado: $e");
      }
    }
  }

  /// Se llama cada vez que termina una descarga. UN solo panel para todas:
  /// si ya hay uno abierto, la descarga se apila ahí; si no, se abre uno.
  Future<void> _processInstallQueue() async {
    if (_installPanelOpen) {
      _drainPanelQueue?.call();
      return;
    }
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;
    try {
      while (mounted && _installQueue.isNotEmpty) {
        await _showInstallationPanel(fromDownloads: true);
        await _deleteConsumedDownloads();
        // Pausa breve para que la transición no sea brusca.
        await Future.delayed(const Duration(milliseconds: 400));
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// Widget auxiliar para dar padding uniforme a los botones de navegación
  Widget _buildNavButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(text),
    );
  }

  /*/ ++ AÑADIDO: Función para construir el overlay de vista previa del traje ++
  Widget _buildOutfitPreviewOverlay() {
    return ValueListenableBuilder<String?>(
      valueListenable: _hoveredOutfitNotifier,
      builder: (context, outfitName, child) {
        // Usa AnimatedOpacity para una aparición/desaparición suave
        return AnimatedOpacity(
          opacity: outfitName != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          // Si no hay outfit, no renderiza nada
          child: (outfitName == null)
              ? const SizedBox.shrink()
              // IgnorePointer evita que el overlay bloquee clics
              : IgnorePointer(
                  child: Align(
                    // Posiciona el overlay en la esquina inferior izquierda
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      // Tamaño fijo para la vista previa
                      width: 210, // Proporción 3:4.5 (como la tarjeta)
                      height: 315,
                      margin: const EdgeInsets.all(24), // Margen desde la esquina
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.tealAccent, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Column(
                          children: [
                            // La imagen del traje
                            Expanded(
                              child: Image.asset(
                                _generateOutfitImagePath(outfitName),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                  child: Icon(
                                    Icons.hide_image_outlined,
                                    color: Colors.grey[700],
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                            // El nombre del traje
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                outfitName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }*/

  /// Muestra el overlay de vista previa del traje en la posición del cursor.
  void _showPreviewOverlay(
    BuildContext context,
    String outfitName,
    Offset position,
  ) {
    // Oculta cualquier overlay anterior
    _hidePreviewOverlay();

    _previewOverlay = OverlayEntry(
      builder: (context) => Positioned(
        // Posiciona el overlay ligeramente abajo y a la derecha del cursor
        // para que el cursor no lo tape.
        left: position.dx - 50,
        top: position.dy - 220,
        child: IgnorePointer(
          // Evita que el overlay bloquee clics
          child: Opacity(
            opacity: 1, // 100% de opacidad (totalmente visible)
            child: SizedBox(
              // Tamaño de la vista previa (sin borde)
              width: 100,
              height: 211,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Un leve redondeo
                child: Image.asset(
                  _generateOutfitImagePath(
                    outfitName,
                  ), // Reutiliza la función existente
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    // Placeholder en caso de error
                    color: Colors.black.withOpacity(0.5),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedImageDelete02,
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Inserta el overlay en la pantalla
    if (mounted) {
      Overlay.of(context).insert(_previewOverlay!);
    }
  }

  /// Oculta y limpia el temporizador y el overlay de vista previa.
  void _hidePreviewOverlay() {
    _hoverTimer?.cancel(); // Cancela el temporizador si está activo
    _previewOverlay?.remove(); // Elimina el overlay de la pantalla
    _previewOverlay = null; // Limpia la referencia
  }

  // ---------------------------------------------------------------------------
  //  PERFIL DE NEXUS MODS · estilo iOS / macOS
  // ---------------------------------------------------------------------------

  // Colores del sistema de Apple (modo oscuro)
  static const Color _iosBlue = Color(0xFF0A84FF);
  static const Color _iosGreen = Color(0xFF30D158);
  static const Color _iosYellow = Color(0xFFFFD60A);
  static const Color _iosRed = Color(0xFFFF453A);
  static const Color _iosOrange = Color(0xFFFF9F0A);
  static const Color _iosLabelSecondary = Color(0x99EBEBF5); // 60 %
  static const Color _iosLabelTertiary = Color(0x4DEBEBF5); // 30 %

  Widget _buildNexusAvatar(double radius, Color accent) {
    final hasAvatar = _nexusAvatarUrl != null && _nexusAvatarUrl!.isNotEmpty;

    // Avatar de letra (sin imagen, o si la imagen no carga): círculo de color.
    Widget letterAvatar() => CircleAvatar(
      radius: radius,
      backgroundColor: accent,
      child: Text(
        (_nexusUserName != null && _nexusUserName!.isNotEmpty)
            ? _nexusUserName![0].toUpperCase()
            : 'U',
        style: TextStyle(
          fontSize: radius * 0.95,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (!hasAvatar) return letterAvatar();

    // La imagen se recorta en círculo SIN color de fondo, así los PNG con
    // transparencia se ven tal cual (CircleAvatar pintaba [accent] detrás).
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: ClipOval(
        child: Image.network(
          _nexusAvatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => letterAvatar(),
        ),
      ),
    );
  }

  String _formatThousands(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// Fila estilo "Ajustes" de iOS: icono en cuadrado redondeado de color,
  /// título, valor a la derecha y una barra de progreso fina.
  Widget _buildApiLimitRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String remaining,
    required String limit,
    required int fallbackMax,
  }) {
    final int? value = int.tryParse(remaining);
    // Límite real informado por Nexus. Si todavía no se conoce (la API no lo
    // envió), se usa un valor de respaldo según el plan. El límite NUNCA se
    // deriva de las solicitudes restantes: así no baja al consumirlas.
    final int effectiveMax = int.tryParse(limit) ?? fallbackMax;
    final double ratio = value == null ? 0.0 : (value / effectiveMax).clamp(0.0, 1.0);

    final Color barColor = value == null
        ? _iosLabelTertiary
        : ratio > 0.5
            ? _iosGreen
            : ratio > 0.2
                ? _iosYellow
                : _iosRed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value == null ? 'N/A' : _formatThousands(value),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (value != null)
                      Text(
                        ' / ${_formatThousands(effectiveMax)}',
                        style: const TextStyle(fontSize: 12, color: _iosLabelTertiary),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(
                    children: [
                      Container(height: 4, color: Colors.white.withOpacity(0.12)),
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        widthFactor: ratio,
                        child: Container(height: 4, color: barColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileMenu() {
    final l10n = AppLocalizations.of(context)!;
    final bool isPremium = _nexusPlan.isPremium;
    final Color planColor = _nexusPlan == NexusPlan.premium
        ? _iosOrange
        : (_nexusPlan == NexusPlan.supporter ? _iosGreen : _iosBlue);
    final IconData planIcon = _nexusPlan == NexusPlan.premium
        ? Icons.workspace_premium_rounded
        : (_nexusPlan == NexusPlan.supporter
            ? Icons.favorite_rounded
            : Icons.person_rounded);
    final String planLabel = _nexusPlan == NexusPlan.premium
        ? l10n.nexusPlanPremium
        : (_nexusPlan == NexusPlan.supporter
            ? l10n.nexusPlanSupporter
            : l10n.nexusPlanMember);
    // Valores de respaldo por si Nexus no informa el límite real en los headers.
    final int dailyFallback = isPremium ? 20000 : 2500;
    final int hourlyFallback = isPremium ? 500 : 100;

    return PopupMenuButton<String>(
      tooltip: l10n.nexusProfileTooltip,
      offset: const Offset(0, 45),
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        ),
        child: _buildNexusAvatar(12.5, planColor),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: 284,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E).withOpacity(0.78),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.14), width: 0.8),
                ),
                // Datos en tiempo real al abrir el menú
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: NexusApiService.validateAndGetProfile(_apiKey ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 150,
                        child: Center(child: IosSpinner(radius: 10)),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---------- CABECERA (centrada, como macOS) ----------
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.35),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: _buildNexusAvatar(30, planColor),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _nexusUserName ?? l10n.nexusUserFallback,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: planColor.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      planIcon,
                                      size: 13,
                                      color: planColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      planLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: planColor,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ---------- GRUPO "SOLICITUDES DE API" ----------
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 4, 16, 6),
                          child: Text(
                            l10n.nexusApiRequestsRemaining,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _iosLabelSecondary,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              _buildApiLimitRow(
                                icon: Icons.calendar_today_rounded,
                                iconBg: _iosBlue,
                                label: l10n.nexusApiDaily,
                                remaining: NexusApiService.dailyRemaining,
                                limit: NexusApiService.dailyLimit,
                                fallbackMax: dailyFallback,
                              ),
                              // Separador fino con sangría (como UITableView)
                              Container(
                                height: 0.5,
                                margin: const EdgeInsets.only(left: 54),
                                color: Colors.white.withOpacity(0.15),
                              ),
                              _buildApiLimitRow(
                                icon: Icons.schedule_rounded,
                                iconBg: _iosOrange,
                                label: l10n.nexusApiHourly,
                                remaining: NexusApiService.hourlyRemaining,
                                limit: NexusApiService.hourlyLimit,
                                fallbackMax: hourlyFallback,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NexusHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Permitir la conexión aunque el certificado parezca expirado
        // en el SO del usuario, SOLO si el host pertenece a Nexus Mods.
        if (host.contains('nexusmods.com')) {
          return true;
        }
        return false; // Rechazar para cualquier otro dominio por seguridad
      };
  }
}