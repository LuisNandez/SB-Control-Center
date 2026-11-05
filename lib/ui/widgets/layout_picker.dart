// lib/ui/widgets/layout_picker.dart
//
// Selector de diseño para Ajustes > Apariencia: una tarjeta por diseño con una
// vista previa en miniatura (dibujada con los colores del tema activo).
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_layout.dart';
import '../theme/ios_theme.dart';

/// Nombre traducido de un diseño.
String layoutLabel(AppLocalizations l10n, AppLayoutId id) {
  switch (id) {
    case AppLayoutId.ios:
      return l10n.layoutMacos;
    case AppLayoutId.material:
      return l10n.layoutMaterial;
    case AppLayoutId.minimal:
      return l10n.layoutFlat;
  }
}

class IosLayoutPicker extends StatelessWidget {
  const IosLayoutPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AppLayoutId selected;
  final ValueChanged<AppLayoutId> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final id in AppLayouts.selectable)
            _LayoutTile(
              id: id,
              label: layoutLabel(l10n, id),
              selected: id == selected,
              onTap: () => onChanged(id),
            ),
        ],
      ),
    );
  }
}

class _LayoutTile extends StatefulWidget {
  const _LayoutTile({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppLayoutId id;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_LayoutTile> createState() => _LayoutTileState();
}

class _LayoutTileState extends State<_LayoutTile> {
  bool _hover = false;

  static const double _w = 176;
  static const double _h = 112;

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
                      switch (widget.id) {
                        AppLayoutId.material => const _MaterialPreview(),
                        AppLayoutId.minimal => const _MinimalPreview(),
                        AppLayoutId.ios => const _IosPreview(),
                      },
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
                  fontSize: 12.5,
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

// ---------------------------------------------------------------- miniaturas

Widget _bar(double w, double h, Color c) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(h / 2),
      ),
    );

/// Zona de "portada" de las tarjetas en miniatura.
Widget _cover(Color a, Color b) => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [a.withOpacity(0.7), b.withOpacity(0.7)],
        ),
      ),
    );

/// Miniatura del diseño Estilo macOS: barra superior, tarjetas con esquinas redondas
/// e interruptor verde en forma de píldora.
class _IosPreview extends StatelessWidget {
  const _IosPreview();

  Widget _card(Color a, Color b) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: IosColors.card,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: IosColors.overlay(0x14), width: 0.5),
        ),
        child: Column(
          children: [
            Expanded(child: SizedBox.expand(child: _cover(a, b))),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(26, 3, IosColors.label),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _bar(16, 4, IosColors.chip),
                      const Spacer(),
                      Container(
                        width: 12,
                        height: 7,
                        decoration: BoxDecoration(
                          color: IosColors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: IosColors.background,
      child: Column(
        children: [
          Container(
            height: 14,
            color: IosColors.bar,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.centerLeft,
            child: _bar(30, 3, IosColors.secondaryLabel),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            child: Row(
              children: [
                _bar(18, 7, IosColors.blue),
                const SizedBox(width: 4),
                Expanded(child: _bar(double.infinity, 7, IosColors.fill)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  _card(IosColors.purple, IosColors.blue),
                  const SizedBox(width: 5),
                  _card(IosColors.teal, IosColors.blue),
                  const SizedBox(width: 5),
                  _card(IosColors.orange, IosColors.purple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Miniatura del diseño Material: botón de acento, búsqueda con contorno,
/// pestañas de filtro y tarjetas con insignia rectangular + interruptor.
class _MaterialPreview extends StatelessWidget {
  const _MaterialPreview();

  Widget _card(Color a, Color b, Color badge) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: IosColors.card,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _cover(a, b),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      width: 12,
                      height: 6,
                      decoration: BoxDecoration(
                        color: badge,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 3, 3, 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _bar(22, 3, IosColors.label),
                      const Spacer(),
                      _bar(8, 3, IosColors.blue),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 5,
                        decoration: BoxDecoration(
                          color: IosColors.chip,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 11,
                        height: 6,
                        decoration: BoxDecoration(
                          color: IosColors.blue,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 2),
                      _bar(2, 6, IosColors.secondaryLabel),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color outline = IosColors.overlay(0x38);
    return ColoredBox(
      color: IosColors.background,
      child: Column(
        children: [
          Container(
            height: 14,
            color: IosColors.bar,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.centerLeft,
            child: _bar(40, 3, IosColors.label),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 8,
                  decoration: BoxDecoration(
                    color: IosColors.blue,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: outline, width: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Pestañas de filtro
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 70,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: outline, width: 0.7),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: IosColors.blue.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  _card(IosColors.purple, IosColors.blue, const Color(0xFF145EC1)),
                  const SizedBox(width: 6),
                  _card(IosColors.teal, IosColors.blue, const Color(0xFF6D47B8)),
                  const SizedBox(width: 6),
                  _card(IosColors.orange, IosColors.purple, const Color(0xFF9A3289)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Miniatura del diseño Plano: navegación plana, controles compactos y filas
/// de contenido discretas.
class _MinimalPreview extends StatelessWidget {
  const _MinimalPreview();

  @override
  Widget build(BuildContext context) {
    Widget line(double width, {bool accent = false}) => Container(
      width: width, height: 3,
      color: accent ? IosColors.blue : IosColors.secondaryLabel.withOpacity(0.5),
    );
    return ColoredBox(
      color: IosColors.background,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            line(48),
            const SizedBox(width: 6),
            Container(width: 10, height: 8, color: IosColors.fill),
            const Spacer(),
            Container(width: 28, height: 12,
              decoration: BoxDecoration(color: IosColors.blue,
                borderRadius: BorderRadius.circular(3))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            line(24, accent: true), const SizedBox(width: 10),
            line(20), const SizedBox(width: 10), line(26),
          ]),
          const SizedBox(height: 8),
          for (var i = 0; i < 2; i++)
            Expanded(child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: IosColors.card,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: IosColors.separator),
              ),
              child: Row(children: [
                Container(width: 12, height: 12, color: IosColors.fill),
                const SizedBox(width: 6), line(i == 0 ? 56 : 40),
                const Spacer(),
                Icon(Icons.check, size: 10, color: IosColors.blue),
              ]),
            )),
        ]),
      ),
    );
  }
}