// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../l10n/app_localizations.dart';
import '../../models/nexus_plan.dart';
import '../../services/download_manager.dart';
import '../dialogs/settings_dialogs.dart';
import '../theme/ios_theme.dart';
import 'download_pill_overlay.dart';
import 'ios_motion.dart';
import 'ios_progress_bar.dart';
import 'ios_settings_widgets.dart';
import 'ios_widgets.dart';

/// Traduce los colores Material que envía main.dart ("statusColor") a la
/// paleta de sistema de iOS.
Color _iosStatusTone(Color c) {
  final v = c.value;
  if (v == Colors.redAccent.value || v == Colors.red.value) return IosColors.red;
  if (v == Colors.greenAccent.value || v == Colors.green.value) {
    return IosColors.green;
  }
  if (v == Colors.orangeAccent.value || v == Colors.orange.value) {
    return IosColors.orange;
  }
  if (v == Colors.tealAccent.value || v == Colors.lightBlueAccent.value) {
    return IosColors.blue;
  }
  if (v == Colors.white.value) return IosColors.secondaryLabel;
  return c;
}

const TextStyle _tabular = TextStyle(
  fontFeatures: [FontFeature.tabularFigures()],
);

/// Textos propios del panel que aún no están en los .arb. Si prefieres, pásalos
/// a app_*.arb más adelante; mientras tanto el panel funciona sin regenerar
/// nada. Se elige por idioma de la app y, si falta, inglés.
class _Txt {
  _Txt._(this._m);

  final Map<String, String> _m;

  factory _Txt.of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return _Txt._(_all[code] ?? _all['en']!);
  }

  String get preparing => _m['preparing']!;
  String get downloading => _m['downloading']!;
  String get downloaded => _m['downloaded']!;
  String get adding => _m['adding']!;
  String get hint => _m['hint']!;
  String installAll(int n) => _m['installAll']!.replaceAll('{n}', '$n');
  String get discardTitle => _m['discardTitle']!;
  String get discard => _m['discard']!;
  String discardMessage(int n) =>
      _m['discardMessage']!.replaceAll('{n}', '$n');

  static const Map<String, Map<String, String>> _all = {
    'en': {
      'preparing': 'Preparing',
      'downloading': 'Downloading',
      'downloaded': 'Downloaded',
      'adding': 'Adding to the install list…',
      'hint':
          'Downloaded mods are added to the install list so you can install them all together.',
      'installAll': 'Install all ({n})',
      'discardTitle': 'Discard installation?',
      'discardMessage':
          'The {n} mod(s) ready to install will be discarded. This can\'t be undone.',
      'discard': 'Discard',
    },
    'es': {
      'preparing': 'Preparando',
      'downloading': 'Descargando',
      'downloaded': 'Descargado',
      'adding': 'Añadiendo a la lista de instalación…',
      'hint':
          'Los mods descargados se añaden a la lista de instalación para instalarlos todos juntos.',
      'installAll': 'Instalar todo ({n})',
      'discardTitle': '¿Descartar la instalación?',
      'discardMessage':
          'Se descartarán los {n} mod(s) listos para instalar. No se puede deshacer.',
      'discard': 'Descartar',
    },
    'de': {
      'preparing': 'Wird vorbereitet',
      'downloading': 'Lädt herunter',
      'downloaded': 'Heruntergeladen',
      'adding': 'Wird zur Installationsliste hinzugefügt …',
      'hint':
          'Heruntergeladene Mods werden zur Installationsliste hinzugefügt, damit du alle zusammen installieren kannst.',
      'installAll': 'Alle installieren ({n})',
      'discardTitle': 'Installation verwerfen?',
      'discardMessage':
          'Die {n} installationsbereiten Mod(s) werden verworfen. Das lässt sich nicht rückgängig machen.',
      'discard': 'Verwerfen',
    },
    'fr': {
      'preparing': 'Préparation',
      'downloading': 'Téléchargement',
      'downloaded': 'Téléchargé',
      'adding': 'Ajout à la liste d’installation…',
      'hint':
          'Les mods téléchargés sont ajoutés à la liste d’installation pour tous les installer ensemble.',
      'installAll': 'Tout installer ({n})',
      'discardTitle': 'Abandonner l’installation ?',
      'discardMessage':
          'Les {n} mod(s) prêts à être installés seront abandonnés. Cette action est irréversible.',
      'discard': 'Abandonner',
    },
    'it': {
      'preparing': 'Preparazione',
      'downloading': 'Download in corso',
      'downloaded': 'Scaricato',
      'adding': 'Aggiunta all’elenco di installazione…',
      'hint':
          'I mod scaricati vengono aggiunti all’elenco di installazione per installarli tutti insieme.',
      'installAll': 'Installa tutto ({n})',
      'discardTitle': 'Annullare l’installazione?',
      'discardMessage':
          'I {n} mod pronti per l’installazione verranno scartati. Operazione irreversibile.',
      'discard': 'Scarta',
    },
    'ja': {
      'preparing': '準備中',
      'downloading': 'ダウンロード中',
      'downloaded': 'ダウンロード完了',
      'adding': 'インストール一覧に追加中…',
      'hint': 'ダウンロードしたMODはインストール一覧に追加され、まとめてインストールできます。',
      'installAll': 'すべてインストール（{n}）',
      'discardTitle': 'インストールを破棄しますか？',
      'discardMessage':
          'インストール待ちの{n}件のMODが破棄されます。この操作は元に戻せません。',
      'discard': '破棄',
    },
    'ko': {
      'preparing': '준비 중',
      'downloading': '다운로드 중',
      'downloaded': '다운로드 완료',
      'adding': '설치 목록에 추가하는 중…',
      'hint': '다운로드한 모드는 설치 목록에 추가되어 한 번에 설치할 수 있습니다.',
      'installAll': '모두 설치({n})',
      'discardTitle': '설치를 취소할까요?',
      'discardMessage':
          '설치 대기 중인 모드 {n}개가 삭제됩니다. 되돌릴 수 없습니다.',
      'discard': '삭제',
    },
    'pt': {
      'preparing': 'Preparando',
      'downloading': 'Baixando',
      'downloaded': 'Baixado',
      'adding': 'Adicionando à lista de instalação…',
      'hint':
          'Os mods baixados são adicionados à lista de instalação para instalá-los todos juntos.',
      'installAll': 'Instalar tudo ({n})',
      'discardTitle': 'Descartar a instalação?',
      'discardMessage':
          'Os {n} mod(s) prontos para instalar serão descartados. Isso não pode ser desfeito.',
      'discard': 'Descartar',
    },
    'ru': {
      'preparing': 'Подготовка',
      'downloading': 'Загрузка',
      'downloaded': 'Загружено',
      'adding': 'Добавление в список установки…',
      'hint':
          'Загруженные моды добавляются в список установки, чтобы установить их все сразу.',
      'installAll': 'Установить все ({n})',
      'discardTitle': 'Отменить установку?',
      'discardMessage':
          'Моды, готовые к установке ({n}), будут удалены из списка. Это действие нельзя отменить.',
      'discard': 'Отменить',
    },
    'zh': {
      'preparing': '准备中',
      'downloading': '下载中',
      'downloaded': '已下载',
      'adding': '正在添加到安装列表…',
      'hint': '下载完成的模组会加入安装列表，方便一起安装。',
      'installAll': '全部安装（{n}）',
      'discardTitle': '放弃安装？',
      'discardMessage':
          '待安装的 {n} 个模组将被丢弃，此操作无法撤销。',
      'discard': '放弃',
    },
  };
}

/// Pregunta si se quiere descartar lo preparado al cerrar el panel (clic fuera
/// o en la X). Devuelve true si el usuario confirma.
Future<bool> confirmDiscardInstallation(
  BuildContext context, {
  required int modCount,
}) {
  final txt = _Txt.of(context);
  return SettingsDialogs.confirm(
    context: context,
    title: txt.discardTitle,
    message: txt.discardMessage(modCount),
    confirmLabel: txt.discard,
    destructive: true,
  );
}

// ============================================================================
//  PANEL PRINCIPAL
// ============================================================================

/// Hoja de instalación al estilo iOS / macOS.
///
/// Flujo de arriba abajo (un solo panel para todo):
///  1. Zona de arrastre / "Seleccionar archivo" (se oculta si hay descargas).
///  2. DESCARGAS: la cola en vivo, con estado claro por cada mod.
///  3. Actividad: extracción / instalación / mensajes.
///  4. MODS A INSTALAR: lista que se va apilando con cada descarga terminada.
///  5. Barra inferior fija con "Instalar todo".
class InstallationPanelContent extends StatefulWidget {
  final AppLocalizations l10n;
  final bool isDragging;
  final bool isExtracting;
  final bool isInstalling;
  final bool isLoading;
  final double extractionProgress;
  final String extractionStatus;
  final double installationProgress;
  final String installationStatus;
  final String statusMessage;
  final Color statusColor;
  final bool hasPreparedMods;
  final Map<String, List<String>> modsToInstallPreviewMap;

  /// El panel se abrió por una descarga: no se ofrece "Seleccionar archivo".
  final bool downloadMode;

  final Future<void> Function(List<File>) onFilesDropped;
  final void Function(bool) onDragUpdate;
  final VoidCallback onPickArchive;
  final VoidCallback onInstallMod;
  final VoidCallback onCancelSelection;

  const InstallationPanelContent({
    super.key,
    required this.l10n,
    required this.isDragging,
    required this.isExtracting,
    required this.isInstalling,
    required this.isLoading,
    required this.extractionProgress,
    required this.extractionStatus,
    required this.installationProgress,
    required this.installationStatus,
    required this.statusMessage,
    required this.statusColor,
    required this.hasPreparedMods,
    required this.modsToInstallPreviewMap,
    required this.onFilesDropped,
    required this.onDragUpdate,
    required this.onPickArchive,
    required this.onInstallMod,
    required this.onCancelSelection,
    this.downloadMode = false,
  });

  @override
  State<InstallationPanelContent> createState() =>
      _InstallationPanelContentState();
}

class _InstallationPanelContentState extends State<InstallationPanelContent> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // La cola de descargas ya se ve aquí dentro: se oculta la píldora flotante
    // mientras el panel está abierto para no duplicar información.
    Future.microtask(() => DownloadOverlay.suppressed.value = true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    Future.microtask(() => DownloadOverlay.suppressed.value = false);
    super.dispose();
  }

  /// Transición de fundido que conserva el ancho completo del padre.
  static Widget _fadeLayout(Widget? current, List<Widget> previous) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.topCenter,
      children: [...previous, if (current != null) current],
    );
  }

  Widget _buildActivity() {
    final w = widget;
    if (w.isExtracting) {
      return _ActivityCard(
        key: const ValueKey('extracting'),
        status: w.extractionStatus,
        value: w.extractionProgress,
        color: IosColors.blue,
        icon: Icons.unarchive_rounded,
      );
    }
    if (w.isInstalling) {
      return _ActivityCard(
        key: const ValueKey('installing'),
        status: w.installationStatus,
        value: w.installationProgress,
        color: IosColors.green,
        icon: Icons.download_done_rounded,
      );
    }
    final tone = _iosStatusTone(w.statusColor);
    final bool neutral = tone == IosColors.secondaryLabel;
    final bool hasPreview = w.modsToInstallPreviewMap.isNotEmpty;
    // El mensaje neutro "N archivos listos" sobra si la lista ya se ve.
    if ((w.hasPreparedMods || w.statusColor != Colors.white) &&
        w.statusMessage.trim().isNotEmpty &&
        !(neutral && hasPreview)) {
      return _StatusBanner(
        key: const ValueKey('status'),
        message: w.statusMessage,
        tone: tone,
      );
    }
    return const SizedBox.shrink(key: ValueKey('no_activity'));
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final l10n = w.l10n;
    final txt = _Txt.of(context);
    final busy = w.isLoading || w.isExtracting || w.isInstalling;
    final canInstall = w.hasPreparedMods && !busy;
    final int previewCount = w.modsToInstallPreviewMap.length;
    final bool hasPreview = previewCount > 0;

    return DropTarget(
      onDragDone: (details) async {
        final files = details.files.map((f) => File(f.path)).toList();
        if (files.isNotEmpty) {
          await w.onFilesDropped(files);
        }
      },
      onDragEntered: (details) => w.onDragUpdate(true),
      onDragExited: (details) => w.onDragUpdate(false),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Cabecera ------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 36,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: IosColors.tertiaryLabel,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.installNewMod,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: IosColors.label,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: IosMotion.fast,
                          child: busy
                              ? const SizedBox(
                                  key: ValueKey('close_hidden'),
                                  width: 28,
                                  height: 28,
                                )
                              : IosCloseButton(
                                  key: const ValueKey('close_visible'),
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---- Contenido con scroll ------------------------------------
              Flexible(
                child: Scrollbar(
                  controller: _scroll,
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Seleccionar archivo: solo si NO hay descargas.
                        ListenableBuilder(
                          key: const ValueKey('drop_slot'),
                          listenable: DownloadManager.instance,
                          builder: (context, _) {
                            final bool hide = w.downloadMode ||
                                DownloadManager
                                    .instance.activeDownloads.isNotEmpty;
                            return AnimatedSize(
                              duration: IosMotion.base,
                              curve: IosMotion.sheet,
                              alignment: Alignment.topCenter,
                              child: hide
                                  ? const SizedBox(width: double.infinity)
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 18),
                                      child: _DropZone(
                                        l10n: l10n,
                                        compact: hasPreview ||
                                            w.hasPreparedMods,
                                        enabled: !busy,
                                        onTap: w.onPickArchive,
                                      ),
                                    ),
                            );
                          },
                        ),

                        // 2. Cola de descargas
                        _DownloadQueue(
                          key: const ValueKey('download_queue'),
                          l10n: l10n,
                          txt: txt,
                        ),

                        // 3. Extracción / instalación / estado
                        AnimatedSize(
                          key: const ValueKey('activity_slot'),
                          duration: IosMotion.base,
                          curve: IosMotion.sheet,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: IosMotion.base,
                            switchInCurve: IosMotion.standard,
                            switchOutCurve: Curves.easeIn,
                            layoutBuilder: _fadeLayout,
                            child: _buildActivity(),
                          ),
                        ),

                        // 4. Mods a instalar (se apilan solos)
                        AnimatedSize(
                          key: const ValueKey('preview_slot'),
                          duration: IosMotion.base,
                          curve: IosMotion.sheet,
                          alignment: Alignment.topCenter,
                          child: hasPreview
                              ? _PreviewSection(
                                  l10n: l10n,
                                  modsToInstallPreviewMap:
                                      w.modsToInstallPreviewMap,
                                  isInstalling: w.isInstalling,
                                  onCancel: w.onCancelSelection,
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---- Barra inferior fija -------------------------------------
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                decoration: const BoxDecoration(
                  color: IosColors.background,
                  border: Border(
                    top: BorderSide(color: IosColors.separator, width: 0.5),
                  ),
                ),
                child: IosActionButton(
                  label: previewCount > 1
                      ? txt.installAll(previewCount)
                      : l10n.installSelectedMod,
                  height: 46,
                  style: IosButtonStyle.filled,
                  iconBuilder: (c) => Icon(
                    Icons.download_for_offline_rounded,
                    size: 19,
                    color: c,
                  ),
                  onPressed: canInstall ? w.onInstallMod : null,
                ),
              ),
            ],
          ),

          // ---- Capa de "suelta aquí" ---------------------------------------
          if (w.isDragging)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: IosMotion.fast,
                builder: (context, t, child) =>
                    Opacity(opacity: t, child: child),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xE61C1C1E),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    border: Border.all(color: IosColors.blue, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IosPop(
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: IosColors.blue.withOpacity(0.18),
                            ),
                            child: const Icon(
                              Icons.file_download_rounded,
                              size: 40,
                              color: IosColors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.dropTargetOverlay,
                          style: const TextStyle(
                            color: IosColors.label,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
//  PIEZAS BASE: cabecera de sección y tarjeta agrupada
// ============================================================================

/// Cabecera de sección: icono de color + título + contador, y un accesorio
/// opcional a la derecha. Más grande y clara que el título en mayúsculas.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.count,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 2, 8),
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            Icon(icon, size: 19, color: iconColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title.replaceAll(RegExp(r'[:：]\s*$'), ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: IosColors.label,
                ),
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: IosColors.chip,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IosCountText(
                  text: '$count',
                  style: _tabular.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: IosColors.secondaryLabel,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Tarjeta redondeada con filas separadas por filetes de 0.5 px.
class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children, this.dividerIndent = 0});

  final List<Widget> children;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(left: dividerIndent),
            child: Container(height: 0.5, color: IosColors.separator),
          ),
        );
      }
      rows.add(children[i]);
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: IosColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x0FFFFFFF), width: 0.5),
      ),
      child: Column(children: rows),
    );
  }
}

// ============================================================================
//  ZONA DE ARRASTRE
// ============================================================================

class _DropZone extends StatefulWidget {
  const _DropZone({
    required this.l10n,
    required this.compact,
    required this.enabled,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final bool compact;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final bool active = widget.enabled && _hover;
    final Color border = active
        ? IosColors.blue
        : (widget.enabled ? const Color(0x40EBEBF5) : const Color(0x1FEBEBF5));
    final Color fill =
        active ? IosColors.blue.withOpacity(0.10) : const Color(0x0DFFFFFF);

    final Widget content = widget.compact
        ? Row(
            key: const ValueKey('compact'),
            children: [
              IosIconBadge(
                color: IosColors.blue,
                size: 32,
                child: const Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.selectModArchive,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: IosColors.blue,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: IosColors.tertiaryLabel,
              ),
            ],
          )
        : Column(
            key: const ValueKey('full'),
            mainAxisSize: MainAxisSize.min,
            children: [
              IosIconBadge(
                color: IosColors.blue,
                size: 48,
                child: const Icon(
                  Icons.archive_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.selectModArchive,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: IosColors.label,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.dropTargetOverlay,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: IosColors.secondaryLabel,
                ),
              ),
            ],
          );

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: IosPressable(
        scale: 0.985,
        onTap: widget.enabled ? widget.onTap : null,
        onHoverChanged: (h) {
          if (h != _hover) setState(() => _hover = h);
        },
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: border),
          duration: IosMotion.fast,
          builder: (context, color, child) => CustomPaint(
            painter: _DashedRRectPainter(
              color: color ?? border,
              fill: fill,
              radius: 14,
            ),
            child: child,
          ),
          child: AnimatedSize(
            duration: IosMotion.base,
            curve: IosMotion.sheet,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: widget.compact
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: AnimatedSwitcher(
                duration: IosMotion.fast,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rectángulo redondeado con borde discontinuo (zona de "suelta aquí").
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.fill,
    required this.radius,
  });

  final Color color;
  final Color fill;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.75),
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, Paint()..color = fill);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = color;

    const double dash = 6;
    const double gap = 5;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final end = math.min(d + dash, metric.length);
        canvas.drawPath(metric.extractPath(d, end), stroke);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.fill != fill || old.radius != radius;
}

// ============================================================================
//  MODS A INSTALAR (se apilan)
// ============================================================================

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.l10n,
    required this.modsToInstallPreviewMap,
    required this.isInstalling,
    required this.onCancel,
  });

  final AppLocalizations l10n;
  final Map<String, List<String>> modsToInstallPreviewMap;
  final bool isInstalling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final entries = modsToInstallPreviewMap.entries.toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: l10n.previewInstallTitle,
            icon: Icons.library_add_check_rounded,
            iconColor: IosColors.green,
            count: entries.length,
            trailing: IosTextButton(
              label: l10n.cancelSelection,
              color: IosColors.red,
              onPressed: isInstalling ? null : onCancel,
            ),
          ),
          _GroupCard(
            dividerIndent: 56,
            children: [
              for (int i = 0; i < entries.length; i++)
                IosReveal(
                  key: ValueKey('preview_${entries[i].key}'),
                  child: _PreviewRow(
                    name: entries[i].key,
                    files: entries[i].value,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.name, required this.files});

  final String name;
  final List<String> files;

  static const int _maxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final visible = files.take(_maxVisible).toList();
    final extra = files.length - visible.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IosIconBadge(
            color: IosColors.blue,
            size: 30,
            child: const Icon(
              Icons.folder_zip_rounded,
              size: 17,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: IosColors.label,
                    ),
                  ),
                ),
                for (final f in visible)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      f,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: IosColors.secondaryLabel,
                      ),
                    ),
                  ),
                if (extra > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      '+$extra',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: IosColors.tertiaryLabel,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (files.isNotEmpty) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: IosColors.chip,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.insert_drive_file_outlined,
                    size: 11,
                    color: IosColors.secondaryLabel,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${files.length}',
                    style: _tabular.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
//  ACTIVIDAD: EXTRACCIÓN / INSTALACIÓN / ESTADO
// ============================================================================

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    super.key,
    required this.status,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String status;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        decoration: BoxDecoration(
          color: IosColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x0FFFFFFF), width: 0.5),
        ),
        child: Row(
          children: [
            _StatusRing(
              progress: v,
              color: color,
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                      color: IosColors.label,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SmoothBar(value: v, color: color),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(v * 100).round()}%',
              style: _tabular.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: IosColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({super.key, required this.message, required this.tone});

  final String message;
  final Color tone;

  IconData get _icon {
    if (tone == IosColors.red) return Icons.error_rounded;
    if (tone == IosColors.green) return Icons.check_circle_rounded;
    if (tone == IosColors.orange) return Icons.warning_amber_rounded;
    if (tone == IosColors.blue) return Icons.info_rounded;
    return Icons.info_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final bool neutral = tone == IosColors.secondaryLabel;
    final Color accent = neutral ? IosColors.gray : tone;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, size: 18, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  letterSpacing: -0.1,
                  color: neutral ? IosColors.label : tone,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
//  COLA DE DESCARGAS
// ============================================================================

class _DownloadQueue extends StatelessWidget {
  const _DownloadQueue({super.key, required this.l10n, required this.txt});

  final AppLocalizations l10n;
  final _Txt txt;

  @override
  Widget build(BuildContext context) {
    final manager = DownloadManager.instance;

    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        final tasks = List<DownloadTask>.of(manager.activeDownloads);
        final plan = manager.userPlan;

        return AnimatedSize(
          duration: IosMotion.base,
          curve: IosMotion.sheet,
          alignment: Alignment.topCenter,
          child: tasks.isEmpty
              ? const SizedBox(width: double.infinity)
              : _buildSection(tasks, plan),
        );
      },
    );
  }

  Widget _buildSection(List<DownloadTask> tasks, NexusPlan plan) {
    int count(DownloadStatus s) => tasks.where((t) => t.status == s).length;

    final fetching = count(DownloadStatus.fetching);
    final downloading = count(DownloadStatus.downloading);
    final paused = count(DownloadStatus.paused);
    final errors = count(DownloadStatus.error);
    final done = count(DownloadStatus.complete);
    final inProgress = fetching + downloading;

    // Progreso global: las terminadas cuentan 100 % para que la barra no
    // retroceda cuando una acaba mientras otras siguen.
    final counted = tasks.where((t) =>
        t.status != DownloadStatus.error && t.status != DownloadStatus.cancelled);
    final double overall = counted.isEmpty
        ? 0.0
        : counted.fold<double>(0.0, (s, t) => s + t.progress) / counted.length;

    final bool showSummary = tasks.length > 1;

    final notes = <String>[
      if (inProgress > 0) txt.hint,
      if (!plan.isPremium)
        plan == NexusPlan.supporter
            ? l10n.downloadSupporterAccountLimit
            : l10n.downloadMemberAccountLimit,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: l10n.activeDownloads,
            icon: Icons.cloud_download_rounded,
            iconColor: IosColors.blue,
            count: tasks.length,
            trailing: plan == NexusPlan.member
                ? null
                : _PlanChip(l10n: l10n, plan: plan),
          ),
          _GroupCard(
            dividerIndent: 14,
            children: [
              if (showSummary)
                _QueueSummary(
                  key: const ValueKey('queue_summary'),
                  chips: [
                    if (downloading + fetching > 0)
                      _ChipData(
                        IosColors.blue,
                        Icons.arrow_downward_rounded,
                        '${downloading + fetching}  ${txt.downloading}',
                      ),
                    if (paused > 0)
                      _ChipData(
                        IosColors.orange,
                        Icons.pause_rounded,
                        '$paused  ${l10n.downloadPausedStatus}',
                      ),
                    if (errors > 0)
                      _ChipData(
                        IosColors.red,
                        Icons.priority_high_rounded,
                        '$errors  ${l10n.downloadError}',
                      ),
                    if (done > 0)
                      _ChipData(
                        IosColors.green,
                        Icons.check_rounded,
                        '$done  ${txt.downloaded}',
                      ),
                  ],
                  showBar: inProgress > 0,
                  progress: overall,
                ),
              for (final t in tasks)
                IosReveal(
                  key: ValueKey('task_${t.id}'),
                  child: _DownloadRow(task: t, l10n: l10n, txt: txt),
                ),
            ],
          ),
          if (notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final n in notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        n,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: IosColors.secondaryLabel,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.l10n, required this.plan});

  final AppLocalizations l10n;
  final NexusPlan plan;

  @override
  Widget build(BuildContext context) {
    final Color c = plan.isPremium ? IosColors.yellow : IosColors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        (plan.isPremium ? l10n.nexusPlanPremium : l10n.nexusPlanSupporter)
            .toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w700,
          color: c,
        ),
      ),
    );
  }
}

class _ChipData {
  const _ChipData(this.color, this.icon, this.label);
  final Color color;
  final IconData icon;
  final String label;
}

/// Resumen superior de la cola: chips de estado ("2 Descargando",
/// "1 Pausado"...) y la barra de progreso total.
class _QueueSummary extends StatelessWidget {
  const _QueueSummary({
    super.key,
    required this.chips,
    required this.showBar,
    required this.progress,
  });

  final List<_ChipData> chips;
  final bool showBar;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0).toDouble();
    return Container(
      color: const Color(0x0AFFFFFF),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final c in chips)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.color.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.icon, size: 13, color: c.color),
                      const SizedBox(width: 5),
                      Text(
                        c.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: c.color,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (showBar) ...[
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(child: _SmoothBar(value: p, color: IosColors.blue)),
                const SizedBox(width: 10),
                Text(
                  '${(p * 100).round()}%',
                  style: _tabular.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: IosColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Una descarga. De un vistazo: icono de archivo con insignia de estado,
/// nombre, etiqueta de estado con texto ("Descargando", "Pausado"...), datos
/// de tamaño/velocidad y una barra con el porcentaje.
class _DownloadRow extends StatelessWidget {
  const _DownloadRow({
    required this.task,
    required this.l10n,
    required this.txt,
  });

  final DownloadTask task;
  final AppLocalizations l10n;
  final _Txt txt;

  DownloadManager get _manager => DownloadManager.instance;

  Color get _tone {
    switch (task.status) {
      case DownloadStatus.fetching:
        return IosColors.gray;
      case DownloadStatus.downloading:
        return IosColors.blue;
      case DownloadStatus.paused:
        return IosColors.orange;
      case DownloadStatus.complete:
        return IosColors.green;
      case DownloadStatus.error:
        return IosColors.red;
      case DownloadStatus.cancelled:
        return IosColors.gray;
    }
  }

  IconData get _badgeIcon {
    switch (task.status) {
      case DownloadStatus.fetching:
        return Icons.more_horiz_rounded;
      case DownloadStatus.downloading:
        return Icons.arrow_downward_rounded;
      case DownloadStatus.paused:
        return Icons.pause_rounded;
      case DownloadStatus.complete:
        return Icons.check_rounded;
      case DownloadStatus.error:
        return Icons.priority_high_rounded;
      case DownloadStatus.cancelled:
        return Icons.close_rounded;
    }
  }

  String get _label {
    switch (task.status) {
      case DownloadStatus.fetching:
        return txt.preparing;
      case DownloadStatus.downloading:
        return txt.downloading;
      case DownloadStatus.paused:
        return l10n.downloadPausedStatus;
      case DownloadStatus.complete:
        return txt.downloaded;
      case DownloadStatus.error:
        return l10n.downloadError;
      case DownloadStatus.cancelled:
        return l10n.downloadCancelled;
    }
  }

  /// Datos secundarios: tamaño y velocidad (o qué pasa a continuación).
  String get _meta {
    switch (task.status) {
      case DownloadStatus.fetching:
        return task.speed;
      case DownloadStatus.downloading:
        return [task.downloaded, task.speed]
            .where((s) => s.trim().isNotEmpty)
            .join('  ·  ');
      case DownloadStatus.paused:
        return task.downloaded;
      case DownloadStatus.complete:
        return txt.adding;
      case DownloadStatus.error:
      case DownloadStatus.cancelled:
        return '';
    }
  }

  List<Widget> _actions() {
    Widget cancel() => _CircleAction(
          icon: Icons.close_rounded,
          color: IosColors.red,
          tooltip: l10n.downloadCancel,
          onTap: () => _manager.cancelTask(task.id),
        );

    switch (task.status) {
      case DownloadStatus.downloading:
        return [
          _CircleAction(
            icon: Icons.pause_rounded,
            color: IosColors.icon,
            tooltip: l10n.downloadPause,
            onTap: () => _manager.pauseTask(
              task.id,
              pausedText: l10n.downloadPausedStatus,
            ),
          ),
          const SizedBox(width: 8),
          cancel(),
        ];
      case DownloadStatus.paused:
        return [
          _CircleAction(
            icon: Icons.play_arrow_rounded,
            color: IosColors.blue,
            tooltip: l10n.downloadResume,
            onTap: () => _manager.resumeTask(task.id),
          ),
          const SizedBox(width: 8),
          cancel(),
        ];
      case DownloadStatus.fetching:
        return [cancel()];
      case DownloadStatus.error:
      case DownloadStatus.complete:
      case DownloadStatus.cancelled:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = task.status;
    final tone = _tone;
    final bool showBar = status == DownloadStatus.fetching ||
        status == DownloadStatus.downloading ||
        status == DownloadStatus.paused;
    final bool determinate = status != DownloadStatus.fetching;
    final meta = _meta;
    final actions = _actions();
    final double pct = task.progress.clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _FileTile(icon: _badgeIcon, tone: tone),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: IosColors.label,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _StatusPill(
                          label: _label,
                          color: tone,
                          spinner: status == DownloadStatus.fetching,
                        ),
                        if (meta.trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: IosColors.secondaryLabel,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: 10),
                Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ],
          ),
          if (showBar)
            Padding(
              padding: const EdgeInsets.only(top: 11, left: 54),
              child: Row(
                children: [
                  Expanded(
                    child: determinate
                        ? _SmoothBar(
                            value: pct,
                            color: status == DownloadStatus.paused
                                ? IosColors.orange
                                : IosColors.blue,
                            height: 6,
                          )
                        : const IosProgressBar(height: 6),
                  ),
                  if (determinate) ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${(pct * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: _tabular.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: IosColors.label,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (status == DownloadStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 54),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
                decoration: BoxDecoration(
                  color: IosColors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      task.errorMessage ?? l10n.downloadErrorGeneral,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: IosColors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IosTextButton(
                          label: l10n.downloadCancel,
                          color: IosColors.red,
                          onPressed: () => _manager.cancelTask(task.id),
                        ),
                        const SizedBox(width: 4),
                        IosTextButton(
                          label: l10n.downloadRetryTooltip,
                          color: IosColors.blue,
                          bold: true,
                          onPressed: () => _manager.retryTask(task.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Icono de archivo con una insignia de color en la esquina que indica el
/// estado (flecha = descargando, pausa, check, "!"...).
class _FileTile extends StatelessWidget {
  const _FileTile({required this.icon, required this.tone});

  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: IosColors.chip,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.folder_zip_rounded,
                size: 23,
                color: IosColors.icon,
              ),
            ),
          ),
          Positioned(
            right: -5,
            bottom: -5,
            child: AnimatedContainer(
              duration: IosMotion.base,
              curve: IosMotion.standard,
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tone,
                border: Border.all(color: IosColors.card, width: 2),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  icon,
                  key: ValueKey<IconData>(icon),
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta de estado en forma de cápsula tintada.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    this.spinner = false,
  });

  final String label;
  final Color color;
  final bool spinner;

  @override
  Widget build(BuildContext context) {
    // El gris no se lee bien como texto tintado: se usa la etiqueta secundaria.
    final Color text = color == IosColors.gray ? IosColors.icon : color;
    return AnimatedContainer(
      duration: IosMotion.base,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (spinner) ...[
            const SizedBox(width: 10, height: 10, child: IosSpinner(radius: 5)),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón circular pequeño (pausar, reanudar, cancelar).
class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IosPressable(
        scale: 0.9,
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: IosColors.chip,
          ),
          child: Icon(icon, size: 19, color: color),
        ),
      ),
    );
  }
}

// ============================================================================
//  PIEZAS COMPARTIDAS
// ============================================================================

/// Barra de progreso fina cuyo valor "desliza" suavemente entre actualizaciones.
class _SmoothBar extends StatelessWidget {
  const _SmoothBar({required this.value, required this.color, this.height = 4});

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          IosProgressBar(value: v, color: color, height: height),
    );
  }
}

/// Anillo de progreso estilo Safari / Finder: pista tenue y arco con extremos
/// redondeados. El contenido (icono) se centra dentro.
class _StatusRing extends StatelessWidget {
  const _StatusRing({
    required this.progress,
    required this.color,
    required this.child,
    this.size = 32,
    this.stroke = 3,
  });

  final double progress;
  final Color color;
  final Widget child;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RingPainter(value, color, stroke),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color, this.stroke);

  final double progress;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final arcRect = (Offset.zero & size).deflate(stroke / 2);

    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0x26FFFFFF),
    );

    if (progress <= 0) return;
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.stroke != stroke;
}