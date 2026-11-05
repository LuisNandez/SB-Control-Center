/*Singleton que envuelve la librería toastification y centraliza las notificaciones
 emergentes (éxito, info, error) de la app.

 Estilo: banner de notificación de iOS / macOS.
  - Fondo translúcido con desenfoque (vibrancy) y borde fino.
  - Icono de la notificación en un "badge" de esquinas redondeadas con degradado,
    igual que las filas de Ajustes.
  - Título en semibold y descripción en gris secundario, con tipografía del sistema.
  - Entra deslizándose desde la derecha, se cierra al tocarla, al arrastrarla
    o con la "x" que aparece al pasar el ratón.*/

import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'ui/theme/app_metrics.dart';
import 'ui/theme/ios_theme.dart';
import 'ui/widgets/ios_widgets.dart' show IosCloseButton;

// Tipos de notificación: cada uno tiene su propio color e icono.
enum NotificationType { success, info, error, neutral }

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  /// Posición del banner. macOS los coloca arriba a la derecha (`Alignment.topRight`),
  /// pero ahí tapa los botones de la barra superior, así que se mantiene abajo a la derecha.
  static const Alignment _alignment = Alignment.bottomRight;

  void show({
    required BuildContext context,
    required NotificationType type,
    required String title,
    String? description,
  }) {
    toastification.showCustom(
      context: context,
      alignment: _alignment,
      // El cierre automático lo gestiona el propio banner (se pausa con el ratón encima).
      autoCloseDuration: null,
      animationBuilder: (context, animation, alignment, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: AppMetrics.md ? const Offset(0, 0.35) : const Offset(0.35, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      builder: (context, holder) => _IosBanner(
        type: type,
        title: title,
        description: description,
        duration: Duration(seconds: type == NotificationType.error ? 7 : 5),
        onDismiss: () => toastification.dismiss(holder),
      ),
    );
  }
}

class _IosBanner extends StatefulWidget {
  const _IosBanner({
    required this.type,
    required this.title,
    required this.onDismiss,
    required this.duration,
    this.description,
  });

  final NotificationType type;
  final String title;
  final String? description;
  final VoidCallback onDismiss;
  final Duration duration;

  @override
  State<_IosBanner> createState() => _IosBannerState();
}

class _IosBannerState extends State<_IosBanner> {
  bool _hovered = false;
  Timer? _timer;

  /// Tiempo extra que se concede tras quitar el cursor del banner.
  static const Duration _afterHoverGrace = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _startTimer(widget.duration);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(Duration d) {
    _timer?.cancel();
    _timer = Timer(d, widget.onDismiss);
  }

  void _setHover(bool value) {
    setState(() => _hovered = value);
    if (value) {
      _timer?.cancel(); // con el ratón encima, la notificación no se cierra
    } else {
      _startTimer(_afterHoverGrace);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_rounded;
      case NotificationType.info:
        return Icons.priority_high_rounded;
      case NotificationType.error:
        return Icons.close_rounded;
      case NotificationType.neutral:
        return Icons.notifications_rounded;
    }
  }

  Color get _color {
    switch (widget.type) {
      case NotificationType.success:
        return IosColors.green;
      case NotificationType.info:
        return IosColors.orange;
      case NotificationType.error:
        return IosColors.red;
      case NotificationType.neutral:
        return IosColors.gray;
    }
  }

  /// Notificación del diseño Material: TODAS miden lo mismo (ancho fijo y alto
  /// mínimo), con superficie sólida, icono plano y botón de cerrar siempre visible.
  Widget _buildMaterial() {
    final radius = BorderRadius.circular(AppMetrics.cardRadius);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 300,
          maxWidth: AppMetrics.notificationWidth,
        ),
        child: MouseRegion(
          onEnter: (_) => _setHover(true),
          onExit: (_) => _setHover(false),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: IosColors.elevated,
              borderRadius: radius,
              border: Border.all(color: IosColors.overlay(0x1F), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Badge(color: _color, icon: _icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            color: IosColors.label,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (widget.description != null &&
                            widget.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.description!,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                              color: IosColors.secondaryLabel,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IosCloseButton(onPressed: widget.onDismiss),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (AppMetrics.md) return _buildMaterial();
    final radius = BorderRadius.circular(18);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 360),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _setHover(true),
          onExit: (_) => _setHover(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x59000000),
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: IosColors.card.withAlpha(0xCC), // material "thick" oscuro
                      borderRadius: radius,
                      border: Border.all(
                        color: IosColors.overlay(0x24),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _Badge(color: _color, icon: _icon),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.1,
                                  height: 1.25,
                                  color: IosColors.label,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              if (widget.description != null &&
                                  widget.description!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.description!,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.05,
                                    height: 1.3,
                                    color: IosColors.secondaryLabel,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // "x" circular que aparece al pasar el ratón, como en macOS.
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 120),
                          opacity: _hovered ? 1 : 0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: IosColors.fill,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: IosColors.secondaryLabel,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icono de la notificación: cuadrado redondeado con degradado, como el icono
/// de app de una notificación de iOS / macOS.
class _Badge extends StatelessWidget {
  const _Badge({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (AppMetrics.md) {
      return Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppMetrics.controlRadius),
          color: color,
        ),
        child: Icon(icon, size: 21, color: Colors.white),
      );
    }
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36 * 0.23),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, Colors.white, 0.14)!, color],
        ),
      ),
      child: Icon(icon, size: 21, color: Colors.white),
    );
  }
}