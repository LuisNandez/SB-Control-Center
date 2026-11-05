// lib/ui/widgets/theme_picker.dart
//
// Selector de tema para Ajustes: una cuadrícula de tarjetas con una vista
// previa en miniatura de cada paleta (fondo, barra, tarjetas y color de acento).
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_themes.dart';
import '../theme/ios_theme.dart';

/// Nombre traducido de un tema.
String themeLabel(AppLocalizations l10n, AppThemeId id) {
  switch (id) {
    case AppThemeId.system:
      return l10n.themeSystem;
    case AppThemeId.dark:
      return l10n.themeDark;
    case AppThemeId.midnight:
      return l10n.themeMidnight;
    case AppThemeId.light:
      return l10n.themeLight;
    case AppThemeId.ocean:
      return l10n.themeOcean;
    case AppThemeId.forest:
      return l10n.themeForest;
    case AppThemeId.violet:
      return l10n.themeViolet;
    case AppThemeId.sand:
      return l10n.themeSand;
    case AppThemeId.cocoa:
      return l10n.themeCocoa;
  }
}

class IosThemePicker extends StatelessWidget {
  const IosThemePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AppThemeId selected;
  final ValueChanged<AppThemeId> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [
          for (final id in AppThemes.selectable)
            _ThemeTile(
              id: id,
              label: themeLabel(l10n, id),
              selected: id == selected,
              onTap: () => onChanged(id),
            ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatefulWidget {
  const _ThemeTile({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppThemeId id;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ThemeTile> createState() => _ThemeTileState();
}

class _ThemeTileState extends State<_ThemeTile> {
  bool _hover = false;

  static const double _w = 104;
  static const double _h = 68;

  Widget _preview() {
    if (widget.id == AppThemeId.system) {
      // Mitad oscura / mitad clara.
      return Stack(
        children: [
          const _MiniWindow(palette: AppThemes.dark),
          Positioned.fill(
            child: ClipRect(
              clipper: _RightHalfClipper(),
              child: const _MiniWindow(palette: AppThemes.light),
            ),
          ),
        ],
      );
    }
    return _MiniWindow(palette: AppThemes.byId(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: _w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: _w,
                height: _h,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? IosColors.blue
                        : (_hover
                            ? IosColors.overlay(0x38)
                            : IosColors.overlay(0x1F)),
                    width: sel ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _preview(),
                      if (sel)
                        Positioned(
                          right: 5,
                          bottom: 5,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: IosColors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                  color: sel ? IosColors.label : IosColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini ventana que imita la interfaz con los colores de una paleta.
class _MiniWindow extends StatelessWidget {
  const _MiniWindow({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SizedBox.expand(
      child: ColoredBox(
        color: p.background,
        child: Column(
          children: [
            // Barra superior
            Container(
              height: 11,
              color: p.bar,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 3,
                decoration: BoxDecoration(
                  color: p.secondaryLabel,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: p.card,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: p.separator, width: 0.5),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 3,
                              decoration: BoxDecoration(
                                color: p.label,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 44,
                              height: 3,
                              decoration: BoxDecoration(
                                color: p.tertiaryLabel,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 20,
                              height: 7,
                              decoration: BoxDecoration(
                                color: p.blue,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recorta y deja visible solo la mitad derecha del hijo.
class _RightHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}