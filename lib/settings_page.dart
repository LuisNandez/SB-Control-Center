// Es puramente UI. Es la pantalla de ajustes donde el usuario configura las rutas del juego, 7-Zip, su API Key de Nexus,
// el idioma y desinstala componentes core (UE4SS/CNS). Diseño de escritorio al estilo Ajustes del Sistema de macOS:
// barra lateral con categorías a la izquierda y panel de contenido a la derecha que ocupa todo el espacio.
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:hugeicons/hugeicons.dart';
import 'ui/theme/ios_theme.dart';
import 'ui/widgets/ios_widgets.dart';
import 'ui/widgets/ios_settings_widgets.dart';
import 'ui/dialogs/settings_dialogs.dart';
import 'ui/widgets/self_endorse_section.dart';

class SettingsPage extends StatefulWidget {
  final String? initialGameRootPath;
  final String? initialApiKey;
  final Map<String, String> skippedVersions;

  // Gestión de UE4SS y CNS
  final bool isUe4ssInstalled;
  final bool isCnsCoreInstalled;
  final Future<bool> Function() onUninstallUE4SS;
  final Future<bool> Function() onUninstallCNS;
  final VoidCallback onDeleteAllNexusInfo;
  final VoidCallback onExtractModIds;
  final VoidCallback onTestSelfUpdate;
  /// Busca una versión nueva de la app en GitHub (con aviso manual).
  final Future<void> Function() onCheckAppUpdate;
  /// Abre el historial de versiones (changelog).
  final Future<void> Function() onShowChangelog;
  final bool isDeveloperModeEnabled;

  final Future<String?> Function() onSelectGamePath;
  final Future<String?> Function() onShowApiKeyDialog;
  final Future<void> Function() onManageSkippedVersions;
  final VoidCallback onShowLanguageDialog;
  final VoidCallback onShowAboutDialog;
  final Future<void> Function() onRefreshMetadata;
  final VoidCallback onRunSelfHealing;
  final Future<void> Function() onRepairGameStartup;
  final bool initialShowModTypeTags;
  final ValueChanged<bool> onShowModTypeTagsChanged;
  final bool initialAutoAssignOutfits;
  final ValueChanged<bool> onAutoAssignOutfitsChanged;
  final VoidCallback onRunConflictPatcher;
  final VoidCallback onRevertConflictPatches;

  /// Si es true, la página abre directamente "Conectividad y actualizaciones" y
  /// muestra el diálogo de la API key (lo usa el aviso inicial de la app).
  final bool startOnApiKey;

  const SettingsPage({
    super.key,
    required this.initialGameRootPath,
    required this.initialApiKey,
    required this.skippedVersions,
    required this.isUe4ssInstalled,
    required this.isCnsCoreInstalled,
    required this.onUninstallUE4SS,
    required this.onUninstallCNS,
    required this.onDeleteAllNexusInfo,
    required this.onExtractModIds,
    required this.onTestSelfUpdate,
    required this.onCheckAppUpdate,
    required this.onShowChangelog,
    required this.isDeveloperModeEnabled,
    required this.onSelectGamePath,
    required this.onShowApiKeyDialog,
    required this.onManageSkippedVersions,
    required this.onShowLanguageDialog,
    required this.onShowAboutDialog,
    required this.onRefreshMetadata,
    required this.onRunSelfHealing,
    required this.onRepairGameStartup,
    required this.initialShowModTypeTags,
    required this.onShowModTypeTagsChanged,
    required this.initialAutoAssignOutfits,
    required this.onAutoAssignOutfitsChanged,
    required this.onRunConflictPatcher,
    required this.onRevertConflictPatches,
    this.startOnApiKey = false,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum _Pane { general, paths, core, connectivity, developer }

class _SettingsPageState extends State<SettingsPage> {
  late String? gameRootPath;
  late String? apiKey;

  late bool isUe4ssInstalled;
  late bool isCnsCoreInstalled;
  late bool _showModTypeTags;
  late bool _autoAssignOutfits;

  _Pane _selected = _Pane.general;
  bool _refreshingMetadata = false;
  bool _checkingAppUpdate = false;

  @override
  void initState() {
    super.initState();
    gameRootPath = widget.initialGameRootPath;
    apiKey = widget.initialApiKey;
    isUe4ssInstalled = widget.isUe4ssInstalled;
    isCnsCoreInstalled = widget.isCnsCoreInstalled;
    _showModTypeTags = widget.initialShowModTypeTags;
    _autoAssignOutfits = widget.initialAutoAssignOutfits;
    if (widget.startOnApiKey) {
      _selected = _Pane.connectivity;
      // Tras el primer frame (con la página ya construida) se abre el diálogo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _editApiKey();
      });
    }
  }

  /// Abre el diálogo de la API key y refleja el resultado en la página.
  Future<void> _editApiKey() async {
    final newKey = await widget.onShowApiKeyDialog();
    if (newKey != null && mounted) {
      setState(() => apiKey = newKey);
    }
  }

  /// Icono blanco para dentro de una insignia de color.
  Widget _badgeIcon(dynamic icon) =>
      HugeIcon(icon: icon, color: Colors.white, size: 16.0);

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final panes = <_PaneInfo>[
      _PaneInfo(
        pane: _Pane.general,
        label: l10n.settingsGeneral,
        color: IosColors.gray,
        icon: (s) => HugeIcon(
          icon: HugeIcons.strokeRoundedSetting07,
          color: Colors.white,
          size: s,
        ),
      ),
      _PaneInfo(
        pane: _Pane.paths,
        label: l10n.settingsPathsAndTools,
        color: IosColors.blue,
        icon: (s) => HugeIcon(
          icon: HugeIcons.strokeRoundedFolder02,
          color: Colors.white,
          size: s,
        ),
      ),
      _PaneInfo(
        pane: _Pane.core,
        label: l10n.settingsCoreComponents,
        color: IosColors.purple,
        icon: (s) => HugeIcon(
          icon: HugeIcons.strokeRoundedChip,
          color: Colors.white,
          size: s,
        ),
      ),
      _PaneInfo(
        pane: _Pane.connectivity,
        label: l10n.settingsConnectivity,
        color: IosColors.green,
        icon: (s) => HugeIcon(
          icon: HugeIcons.strokeRoundedWifiSync,
          color: Colors.white,
          size: s,
        ),
      ),
      if (widget.isDeveloperModeEnabled)
        _PaneInfo(
          pane: _Pane.developer,
          label: l10n.settingsDeveloperOptions,
          color: IosColors.orange,
          icon: (s) => Icon(Icons.code_rounded, color: Colors.white, size: s),
        ),
    ];

    // Si el modo desarrollador se desactivara con el panel abierto, volvemos a General.
    final current = panes.firstWhere(
      (p) => p.pane == _selected,
      orElse: () => panes.first,
    );

    return Scaffold(
      backgroundColor: IosColors.background,
      body: Row(
        children: [
          _buildSidebar(l10n, panes, current),
          Container(width: 0.5, color: IosColors.separator),
          Expanded(child: _buildContentPane(l10n, current)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- sidebar

  Widget _buildSidebar(
    AppLocalizations l10n,
    List<_PaneInfo> panes,
    _PaneInfo current,
  ) {
    return Container(
      width: 232,
      color: IosColors.bar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Volver a la ventana principal
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IosToolbarButton(
                width: 34,
                height: 34,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: IosColors.blue,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 14),
            child: Text(
              l10n.settings,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: IosColors.label,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
              children: [
                for (final p in panes)
                  _SidebarItem(
                    label: p.label,
                    color: p.color,
                    icon: p.icon,
                    selected: p.pane == current.pane,
                    onTap: () => setState(() => _selected = p.pane),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ content pane

  Widget _buildContentPane(AppLocalizations l10n, _PaneInfo current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra de título del panel (como la de Ajustes del Sistema)
        Container(
          height: 56,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: const BoxDecoration(
            color: IosColors.background,
            border: Border(
              bottom: BorderSide(color: IosColors.separator, width: 0.5),
            ),
          ),
          child: Text(
            current.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: IosColors.label,
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 140),
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.expand,
              children: [...previous, if (current != null) current],
            ),
            child: ListView(
              key: ValueKey(current.pane),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              children: _paneSections(l10n, current.pane),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _paneSections(AppLocalizations l10n, _Pane pane) {
    switch (pane) {
      case _Pane.general:
        return _generalSections(l10n);
      case _Pane.paths:
        return _pathsSections(l10n);
      case _Pane.core:
        return _coreSections(l10n);
      case _Pane.connectivity:
        return _connectivitySections(l10n);
      case _Pane.developer:
        return _developerSections(l10n);
    }
  }

  // ---------------------------------------------------------------- General

  List<Widget> _generalSections(AppLocalizations l10n) {
    final String langCode = Localizations.localeOf(context).languageCode;
    return [
      IosSettingsSection(
        children: [
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.blue,
              child: _badgeIcon(HugeIcons.strokeRoundedLanguageSquare),
            ),
            title: l10n.settingsLanguage,
            subtitle: l10n.settingsLanguageDesc,
            value: SettingsDialogs.languages[langCode] ?? langCode.toUpperCase(),
            showChevron: true,
            onTap: widget.onShowLanguageDialog,
          ),
          IosSettingsSwitchTile(
            leading: IosIconBadge(
              color: IosColors.orange,
              child: _badgeIcon(HugeIcons.strokeRoundedLabel),
            ),
            title: l10n.settingsShowModTagsTitle,
            subtitle: l10n.settingsShowModTagsDesc,
            value: _showModTypeTags,
            onChanged: (bool newValue) {
              setState(() => _showModTypeTags = newValue);
              widget.onShowModTypeTagsChanged(newValue);
            },
          ),
          IosSettingsSwitchTile(
            leading: IosIconBadge(
              color: IosColors.purple,
              child: _badgeIcon(HugeIcons.strokeRoundedHanger),
            ),
            title: l10n.settingsAutoOutfit,
            subtitle: l10n.settingsAutoOutfitDesc,
            value: _autoAssignOutfits,
            onChanged: (bool newValue) {
              setState(() => _autoAssignOutfits = newValue);
              widget.onAutoAssignOutfitsChanged(newValue);
            },
          ),
        ],
      ),
      // Acerca de (en macOS vive dentro de General)
      IosSettingsSection(
        children: [
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.gray,
              child: _badgeIcon(HugeIcons.strokeRoundedAlertSquare),
            ),
            title: l10n.settingsAbout,
            subtitle: l10n.settingsAboutDesc,
            showChevron: true,
            onTap: widget.onShowAboutDialog,
          ),
        ],
      ),
      // Endorse de la propia app (solo aparece si la cuenta aún no la endorsó)
      const Padding(
        padding: EdgeInsets.only(top: 4),
        child: SelfEndorseSection(),
      ),
    ];
  }

  // ---------------------------------------------------- Rutas y herramientas

  List<Widget> _pathsSections(AppLocalizations l10n) {
    return [
      IosSettingsSection(
        title: l10n.settingsGroupPaths,
        children: [
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.blue,
              child: _badgeIcon(HugeIcons.strokeRoundedFolder02),
            ),
            title: l10n.settingsGameFolder,
            subtitle: gameRootPath ?? l10n.settingsApiKeyNotSet,
            subtitleColor: gameRootPath == null ? IosColors.orange : null,
            showChevron: true,
            onTap: () async {
              final newPath = await widget.onSelectGamePath();
              if (newPath != null) {
                setState(() => gameRootPath = newPath);
              }
            },
          ),
        ],
      ),
      IosSettingsSection(
        title: l10n.settingsGroupTools,
        children: [
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.green,
              child: _badgeIcon(HugeIcons.strokeRoundedRepair),
            ),
            title: l10n.settingsRepairMods,
            subtitle: l10n.settingsRepairModsDesc,
            showChevron: true,
            onTap: widget.onRunSelfHealing,
          ),
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.orange,
              child: _badgeIcon(HugeIcons.strokeRoundedRepair),
            ),
            title: l10n.runConflictPatcherTitle,
            subtitle: l10n.runConflictPatcherSubtitlePython,
            showChevron: true,
            onTap: widget.onRunConflictPatcher,
          ),
          IosSettingsTile(
            leading: const IosIconBadge(
              color: IosColors.gray,
              child: Icon(
                Icons.settings_backup_restore_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            title: l10n.revertPatchesTitle,
            subtitle: l10n.revertPatchesDesc,
            showChevron: true,
            onTap: widget.onRevertConflictPatches,
          ),
          IosSettingsTile(
            leading: const IosIconBadge(
              color: IosColors.red,
              child: Icon(
                Icons.videogame_asset_off_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            title: l10n.settingsFixGameStartup,
            subtitle: l10n.settingsFixGameStartupDesc,
            showChevron: true,
            onTap: widget.onRepairGameStartup,
          ),
        ],
      ),
    ];
  }

  // ------------------------------------------------- Componentes principales

  List<Widget> _coreSections(AppLocalizations l10n) {
    return [
      IosSettingsSection(
        children: [
          IosSettingsTile(
            leading: const IosIconBadge(
              color: IosColors.purple,
              child: Icon(
                Icons.shape_line_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            title: 'UE4SS',
            subtitle:
                isUe4ssInstalled ? l10n.installedStatus : l10n.notInstalledStatus,
            subtitleColor:
                isUe4ssInstalled ? IosColors.green : IosColors.secondaryLabel,
            trailing: isUe4ssInstalled
                ? IosTextButton(
                    label: l10n.uninstallButton,
                    color: IosColors.red,
                    onPressed: () async {
                      final success = await widget.onUninstallUE4SS();
                      if (success && mounted) {
                        setState(() => isUe4ssInstalled = false);
                      }
                    },
                  )
                : null,
          ),
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.teal,
              child: _badgeIcon(HugeIcons.strokeRoundedChip),
            ),
            title: l10n.cnsCoreSystem,
            subtitle: isCnsCoreInstalled
                ? l10n.installedStatus
                : l10n.notInstalledStatus,
            subtitleColor:
                isCnsCoreInstalled ? IosColors.green : IosColors.secondaryLabel,
            trailing: isCnsCoreInstalled
                ? IosTextButton(
                    label: l10n.uninstallButton,
                    color: IosColors.red,
                    onPressed: () async {
                      final success = await widget.onUninstallCNS();
                      if (success && mounted) {
                        setState(() => isCnsCoreInstalled = false);
                      }
                    },
                  )
                : null,
          ),
        ],
      ),
    ];
  }

  // ------------------------------------------------------------ Conectividad

  List<Widget> _connectivitySections(AppLocalizations l10n) {
    final bool isApiKeySet = apiKey != null && apiKey!.isNotEmpty;
    return [
      IosSettingsSection(
        children: [
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.yellow,
              child: _badgeIcon(HugeIcons.strokeRoundedKey01),
            ),
            title: l10n.settingsApiKey,
            subtitle:
                isApiKeySet ? l10n.settingsApiKeySet : l10n.settingsApiKeyNotSet,
            subtitleColor: isApiKeySet ? IosColors.green : IosColors.orange,
            showChevron: true,
            onTap: _editApiKey,
          ),
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.blue,
              child: _badgeIcon(HugeIcons.strokeRoundedArchiveArrowDown),
            ),
            title: l10n.settingsCheckAppUpdate,
            subtitle: l10n.settingsCheckAppUpdateDesc,
            trailing: _checkingAppUpdate
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            showChevron: !_checkingAppUpdate,
            onTap: _checkingAppUpdate
                ? null
                : () async {
                    setState(() => _checkingAppUpdate = true);
                    try {
                      await widget.onCheckAppUpdate();
                    } finally {
                      if (mounted) setState(() => _checkingAppUpdate = false);
                    }
                  },
          ),
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.purple,
              child: _badgeIcon(HugeIcons.strokeRoundedBook04),
            ),
            title: l10n.settingsChangelog,
            subtitle: l10n.settingsChangelogDesc,
            showChevron: true,
            onTap: widget.onShowChangelog,
          ),
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.red,
              child: _badgeIcon(HugeIcons.strokeRoundedNext),
            ),
            title: l10n.settingsSkippedVersions,
            subtitle: l10n.settingsSkippedVersionsCount(
              widget.skippedVersions.length,
            ),
            showChevron: true,
            onTap: () async {
              await widget.onManageSkippedVersions();
              if (mounted) setState(() {});
            },
          ),
          IosSettingsTile(
            leading: IosIconBadge(
              color: IosColors.green,
              child: _badgeIcon(HugeIcons.strokeRoundedRefresh01),
            ),
            title: l10n.settingsRefreshMetadata,
            subtitle: l10n.settingsRefreshMetadataDesc,
            trailing: _refreshingMetadata
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            showChevron: !_refreshingMetadata,
            onTap: _refreshingMetadata
                ? null
                : () async {
                    setState(() => _refreshingMetadata = true);
                    try {
                      await widget.onRefreshMetadata();
                    } finally {
                      if (mounted) setState(() => _refreshingMetadata = false);
                    }
                  },
          ),
        ],
      ),
    ];
  }

  // ------------------------------------------------- Opciones de desarrollador

  List<Widget> _developerSections(AppLocalizations l10n) {
    return [
      IosSettingsSection(
        children: [
          IosSettingsTile(
            leading: const IosIconBadge(
              color: IosColors.orange,
              child: Icon(
                Icons.delete_sweep_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            title: l10n.devDeleteNexusInfoTitle,
            subtitle: l10n.devDeleteNexusInfoDesc,
            showChevron: true,
            onTap: widget.onDeleteAllNexusInfo,
          ),
          IosSettingsTile(
            leading: const IosIconBadge(
              color: IosColors.blue,
              child: Icon(
                Icons.upload_file_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            title: l10n.devExtractIdsTitle,
            subtitle: l10n.devExtractIdsDesc,
            showChevron: true,
            onTap: widget.onExtractModIds,
          ),
          IosSettingsTile(
            leading: const IosIconBadge(
              color: IosColors.green,
              child: Icon(
                Icons.system_update_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            title: l10n.devTestSelfUpdateTitle,
            subtitle: l10n.devTestSelfUpdateDesc,
            showChevron: true,
            onTap: widget.onTestSelfUpdate,
          ),
        ],
      ),
    ];
  }
}

/// Datos de una categoría de la barra lateral.
class _PaneInfo {
  const _PaneInfo({
    required this.pane,
    required this.label,
    required this.color,
    required this.icon,
  });

  final _Pane pane;
  final String label;
  final Color color;
  final Widget Function(double size) icon;
}

/// Fila de la barra lateral: insignia de color + nombre. La categoría activa se
/// resalta con el color de acento, igual que en Ajustes del Sistema de macOS.
class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Widget Function(double size) icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Color bg = widget.selected
        ? IosColors.blue
        : (_hover ? const Color(0x14FFFFFF) : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IosIconBadge(
                color: widget.color,
                size: 24,
                child: widget.icon(15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                        widget.selected ? FontWeight.w500 : FontWeight.w400,
                    letterSpacing: -0.15,
                    color: IosColors.label,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}