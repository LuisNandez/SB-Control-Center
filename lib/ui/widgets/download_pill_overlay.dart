// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show FontFeature, lerpDouble;
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/nexus_plan.dart';
import '../../services/download_manager.dart';
import '../theme/ios_theme.dart';
import 'ios_progress_bar.dart';
import 'ios_widgets.dart';

class DownloadOverlay {
  static OverlayEntry? _overlayEntry;

  /// Lo activa el panel de instalación mientras está abierto: la cola de
  /// descargas ya se ve dentro del panel, así que la píldora flotante se
  /// desvanece para no duplicar información.
  static final ValueNotifier<bool> suppressed = ValueNotifier<bool>(false);

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 8,
        left: 0,
        right: 0,
        child: SafeArea(
          child: ValueListenableBuilder<bool>(
            valueListenable: suppressed,
            builder: (context, hidden, child) => IgnorePointer(
              ignoring: hidden,
              child: AnimatedOpacity(
                opacity: hidden ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: child,
              ),
            ),
            child: const DownloadPillWidget(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}

class DownloadPillWidget extends StatefulWidget {
  const DownloadPillWidget({super.key});

  @override
  State<DownloadPillWidget> createState() => _DownloadPillWidgetState();
}

class _DownloadPillWidgetState extends State<DownloadPillWidget> {
  /// Tras expandirse sola (descarga nueva o error), la píldora se minimiza
  /// después de este tiempo si el ratón no está encima y no hay errores.
  static const Duration _autoCollapseDelay = Duration(seconds: 5);

  // Material translúcido (como las barras de macOS / centros de control de iOS).
  static const Color _collapsedColor = Color(0xCC3A3A3C);
  static const Color _expandedColor = Color(0xEB2C2C2E);
  static const Color _glassBorder = Color(0x2EFFFFFF);

  bool _isExpanded = false;
  bool _hovering = false; // ratón sobre la píldora (cualquier estado)
  bool _hoverCollapsed = false;
  bool _pressedCollapsed = false;
  int _previousUnfinished = 0;
  int _previousErrors = 0;
  Timer? _collapseTimer;

  DownloadManager get _manager => DownloadManager.instance;

  int _errorCount() => _manager.activeDownloads
      .where((t) => t.status == DownloadStatus.error)
      .length;

  @override
  void initState() {
    super.initState();
    // La píldora puede crearse DESPUÉS de que se añadió la primera descarga.
    _previousUnfinished = _manager.unfinishedCount;
    _previousErrors = _errorCount();
    if (_previousUnfinished > 0) {
      _isExpanded = true;
      _scheduleAutoCollapse();
    }
    _manager.addListener(_onManagerChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onManagerChanged);
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _onManagerChanged() {
    if (!mounted) return;
    final unfinished = _manager.unfinishedCount;
    final errors = _errorCount();
    bool changed = false;

    if (unfinished == 0) {
      // Todo terminó: la píldora desaparece y vuelve a empezar minimizada.
      _collapseTimer?.cancel();
      if (_isExpanded || _hovering) {
        _isExpanded = false;
        _hovering = false;
        changed = true;
      }
    } else if (unfinished > _previousUnfinished || errors > _previousErrors) {
      // Descarga nueva o un error nuevo: se muestra el detalle un momento.
      if (!_isExpanded) {
        _isExpanded = true;
        changed = true;
      }
      _scheduleAutoCollapse();
    }

    _previousUnfinished = unfinished;
    _previousErrors = errors;
    if (changed) setState(() {});
  }

  void _scheduleAutoCollapse() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(_autoCollapseDelay, () {
      if (!mounted || !_isExpanded) return;
      if (_errorCount() > 0) return; // un error espera acción del usuario
      if (_hovering) {
        _scheduleAutoCollapse(); // el usuario está leyendo: espera más
        return;
      }
      setState(() => _isExpanded = false);
    });
  }

  void _expand() {
    _collapseTimer?.cancel();
    setState(() {
      _isExpanded = true;
      _pressedCollapsed = false;
    });
  }

  void _collapse() {
    _collapseTimer?.cancel();
    if (_isExpanded) setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _manager,
      builder: (context, _) {
        final all = _manager.activeDownloads;
        final unfinished = all.where((t) => !t.isFinished).toList();
        final bool visible = unfinished.isNotEmpty;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.86, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          // Sin descargas pendientes la píldora se cierra de inmediato, aunque
          // la lista aún conserve tareas terminadas unos instantes.
          child: !visible
              ? const SizedBox.shrink(key: ValueKey('empty_pill'))
              : Center(
                  key: const ValueKey('active_pill'),
                  child: Material(
                    type: MaterialType.transparency,
                    child: TapRegion(
                      onTapOutside: (_) => _collapse(),
                      child: MouseRegion(
                        onEnter: (_) => _hovering = true,
                        onExit: (_) {
                          _hovering = false;
                          if (_isExpanded && _errorCount() == 0) {
                            _scheduleAutoCollapse();
                          }
                        },
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOutCubic,
                          scale: _isExpanded
                              ? 1.0
                              : (_pressedCollapsed
                                  ? 0.96
                                  : (_hoverCollapsed ? 1.03 : 1.0)),
                          child: _buildGlass(context, all),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildGlass(BuildContext context, List<DownloadTask> all) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _isExpanded ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final radius = lerpDouble(20, 22, t)!;
        return IosGlass(
          shadow: true,
          blur: 34,
          color: Color.lerp(_collapsedColor, _expandedColor, t)!,
          borderColor: _glassBorder,
          borderRadius: BorderRadius.circular(radius),
          child: DecoratedBox(
            // Brillo suave arriba, como el vidrio de macOS (se apaga al expandir).
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.16 * (1 - t)),
                  const Color(0x00FFFFFF),
                ],
              ),
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isExpanded
                    ? _buildExpandedList(context, all)
                    : _buildCollapsedPill(context, all),
              ),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  //  Píldora compacta
  // --------------------------------------------------------------------------
  Widget _buildCollapsedPill(BuildContext context, List<DownloadTask> all) {
    final l10n = AppLocalizations.of(context)!;

    final fetching =
        all.where((t) => t.status == DownloadStatus.fetching).length;
    final downloading =
        all.where((t) => t.status == DownloadStatus.downloading).length;
    final errors = all.where((t) => t.status == DownloadStatus.error).length;
    final inProgress = fetching + downloading;

    // Progreso global: las terminadas cuentan 100 % para que la barra no
    // retroceda cuando una descarga acaba mientras otras siguen.
    final counted = all.where((t) =>
        t.status != DownloadStatus.error && t.status != DownloadStatus.cancelled);
    final double progress = counted.isEmpty
        ? 0.0
        : counted.fold<double>(0.0, (s, t) => s + t.progress) / counted.length;

    Widget leading;
    String label;
    const Color labelColor = IosColors.label;
    bool showPercent = false;

    if (inProgress > 0) {
      leading = (downloading == 0 || progress <= 0)
          ? const IosSpinner(radius: 8)
          : _ProgressRing(progress: progress);
      label = l10n.downloadingModsCount(inProgress);
      showPercent = downloading > 0 && progress > 0;
    } else if (errors > 0) {
      leading = const Icon(Icons.error_rounded, size: 18, color: IosColors.red);
      label = l10n.downloadError;
    } else {
      leading =
          const Icon(Icons.pause_circle_filled_rounded, size: 18, color: IosColors.orange);
      label = l10n.downloadPausedStatus;
      showPercent = progress > 0;
    }

    return MouseRegion(
      key: const ValueKey('collapsed'),
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoverCollapsed = true),
      onExit: (_) => setState(() {
        _hoverCollapsed = false;
        _pressedCollapsed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressedCollapsed = true),
        onTapCancel: () => setState(() => _pressedCollapsed = false),
        onTap: _expand,
        child: Container(
          height: 40,
          constraints: const BoxConstraints(minWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 18, height: 18, child: Center(child: leading)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              if (showPercent) ...[
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: IosColors.secondaryLabel,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  Lista expandida
  // --------------------------------------------------------------------------
  Widget _buildExpandedList(BuildContext context, List<DownloadTask> tasks) {
    final l10n = AppLocalizations.of(context)!;
    final NexusPlan plan = _manager.userPlan;

    return Container(
      key: const ValueKey('expanded'),
      width: 400,
      constraints: const BoxConstraints(maxHeight: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.activeDownloads,
                    style: const TextStyle(
                      color: IosColors.label,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IosCloseButton(onPressed: _collapse),
              ],
            ),
          ),
          Container(height: 0.5, color: const Color(0x1FFFFFFF)),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _buildTaskCard(context, tasks[index], l10n, plan),
            ),
          ),
          if (!plan.isPremium)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: IosColors.tertiaryLabel,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      plan == NexusPlan.supporter
                          ? l10n.downloadSupporterAccountLimit
                          : l10n.downloadMemberAccountLimit,
                      style: const TextStyle(
                        color: IosColors.secondaryLabel,
                        fontSize: 11.5,
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

  Widget _buildTaskCard(
    BuildContext context,
    DownloadTask task,
    AppLocalizations l10n,
    NexusPlan plan,
  ) {
    final bool paused = task.status == DownloadStatus.paused;

    Widget body;
    if (task.status == DownloadStatus.fetching) {
      body = const IosProgressBar();
    } else if (task.status == DownloadStatus.complete) {
      body = Row(
        children: [
          const Expanded(
            child: IosProgressBar(value: 1.0, color: IosColors.green),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.check_circle_rounded,
            color: IosColors.green,
            size: 18,
          ),
          const SizedBox(width: 4),
        ],
      );
    } else if (task.status == DownloadStatus.error) {
      body = Row(
        children: [
          Expanded(
            child: Text(
              task.errorMessage ?? l10n.downloadErrorGeneral,
              style: const TextStyle(color: IosColors.red, fontSize: 12),
            ),
          ),
          IosToolbarButton(
            width: 30,
            height: 30,
            tooltip: l10n.downloadRetryTooltip,
            icon: const Icon(
              Icons.refresh_rounded,
              color: IosColors.blue,
              size: 19,
            ),
            onPressed: () => _manager.retryTask(task.id),
          ),
          const SizedBox(width: 2),
          // Antes una descarga con error no se podía descartar y la píldora
          // se quedaba para siempre.
          IosToolbarButton(
            width: 30,
            height: 30,
            tooltip: l10n.downloadCancel,
            icon: const Icon(
              Icons.close_rounded,
              color: IosColors.red,
              size: 20,
            ),
            onPressed: () => _manager.cancelTask(task.id),
          ),
        ],
      );
    } else if (task.status == DownloadStatus.cancelled) {
      body = Text(
        l10n.downloadCancelled,
        style: const TextStyle(color: IosColors.orange, fontSize: 12),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IosProgressBar(
            value: task.progress,
            color: paused ? IosColors.gray : IosColors.blue,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.downloaded,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: IosColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          task.speed,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: paused
                                ? IosColors.orange
                                : IosColors.secondaryLabel,
                          ),
                        ),
                        if (plan != NexusPlan.member) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: (plan.isPremium ? IosColors.yellow : IosColors.green)
                                  .withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (plan.isPremium
                                      ? l10n.nexusPlanPremium
                                      : l10n.nexusPlanSupporter)
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w700,
                                color: plan.isPremium
                                    ? IosColors.yellow
                                    : IosColors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (task.status == DownloadStatus.downloading)
                IosToolbarButton(
                  width: 30,
                  height: 30,
                  tooltip: l10n.downloadPause,
                  icon: const Icon(
                    Icons.pause_rounded,
                    color: IosColors.icon,
                    size: 20,
                  ),
                  onPressed: () => _manager.pauseTask(
                    task.id,
                    pausedText: l10n.downloadPausedStatus,
                  ),
                )
              else if (paused)
                IosToolbarButton(
                  width: 30,
                  height: 30,
                  tooltip: l10n.downloadResume,
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: IosColors.blue,
                    size: 22,
                  ),
                  onPressed: () => _manager.resumeTask(task.id),
                ),
              const SizedBox(width: 2),
              IosToolbarButton(
                width: 30,
                height: 30,
                tooltip: l10n.downloadCancel,
                icon: const Icon(
                  Icons.close_rounded,
                  color: IosColors.red,
                  size: 20,
                ),
                onPressed: () => _manager.cancelTask(task.id),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              task.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: IosColors.label,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          body,
        ],
      ),
    );
  }
}

/// Anillo de progreso estilo Safari / Finder de macOS: pista tenue y arco azul
/// con extremos redondeados que avanza suavemente.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, this.size = 17});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _RingPainter(value)),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.6;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0x33FFFFFF);
    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = IosColors.blue;
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}