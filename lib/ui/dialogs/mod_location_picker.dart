// lib/ui/dialogs/mod_location_picker.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../services/mod_locations_service.dart';
import '../theme/ios_theme.dart';
import '../widgets/ios_widgets.dart';

/// Cuando un mod tiene archivos en varias carpetas del juego, deja elegir
/// cuál abrir. El diálogo NO se cierra al abrir una carpeta (se pueden abrir
/// varias seguidas); se cierra con el botón o tocando fuera.
class ModLocationPicker {
  static Future<void> show(
    BuildContext context,
    List<ModLocation> locations, {
    required Future<void> Function(ModLocation) onOpen,
  }) {
    return showIosDialog<void>(
      context: context,
      builder: (ctx) {
        final es = Localizations.localeOf(ctx).languageCode == 'es';
        return IosDialogShell(
          title: es ? 'Carpetas del mod' : 'Mod folders',
          message: es
              ? 'Este mod tiene archivos en varias carpetas del juego. '
                  'Haz clic en una para abrirla.'
              : 'This mod has files in several game folders. '
                  'Click one to open it.',
          width: 500,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (final loc in locations)
                    _LocationRow(location: loc, es: es, onOpen: onOpen),
                ],
              ),
            ),
          ),
          actions: [
            IosDialogButton(
              label: es ? 'Cerrar' : 'Close',
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  static String label(ModLocationKind kind, bool es) {
    switch (kind) {
      case ModLocationKind.paks:
        return 'Paks (~mods)';
      case ModLocationKind.logic:
        return 'Blueprint (LogicMods)';
      case ModLocationKind.ue4ssScript:
        return es ? 'Scripts UE4SS' : 'UE4SS scripts';
      case ModLocationKind.ue4ssFile:
        return es ? 'Archivo de UE4SS' : 'UE4SS file';
      case ModLocationKind.installed:
        return es ? 'Instalado en el juego' : 'Installed in game';
      case ModLocationKind.mod:
        return es ? 'Carpeta del mod' : 'Mod folder';
    }
  }

  /// Acorta la ruta para que empiece en la carpeta "SB"
  /// (p. ej. `SB\Content\Paks\~mods\...`). Si no hay una carpeta "SB",
  /// devuelve la ruta completa.
  static String shortPath(String fullPath) {
    final parts = fullPath.split(RegExp(r'[\\/]'));
    final i = parts.indexWhere((p) => p.toLowerCase() == 'sb');
    if (i == -1) return fullPath;
    return parts.sublist(i).join(r'\');
  }

  static List<List<dynamic>> icon(ModLocationKind kind) {
    switch (kind) {
      case ModLocationKind.paks:
        return HugeIcons.strokeRoundedFolderZip;
      case ModLocationKind.ue4ssScript:
        return HugeIcons.strokeRoundedFolder02;
      case ModLocationKind.ue4ssFile:
        return HugeIcons.strokeRoundedFolderOpen;
      default:
        return HugeIcons.strokeRoundedFolder01;
    }
  }
}

class _LocationRow extends StatefulWidget {
  final ModLocation location;
  final bool es;
  final Future<void> Function(ModLocation) onOpen;

  const _LocationRow({
    required this.location,
    required this.es,
    required this.onOpen,
  });

  @override
  State<_LocationRow> createState() => _LocationRowState();
}

class _LocationRowState extends State<_LocationRow> {
  bool _hover = false;
  bool _pressed = false;
  bool _opened = false;
  Timer? _openedTimer;

  @override
  void dispose() {
    _openedTimer?.cancel();
    super.dispose();
  }

  Future<void> _open() async {
    await widget.onOpen(widget.location);
    if (!mounted) return;
    // Confirmación visual breve de que se abrió.
    setState(() => _opened = true);
    _openedTimer?.cancel();
    _openedTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _opened = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.location;
    final active = _hover || _pressed;
    final Color bg = _pressed
        ? const Color(0x730A84FF) // azul ~45%
        : _hover
            ? const Color(0x4D0A84FF) // azul ~30%
            : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? IosColors.blue : Colors.transparent,
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              HugeIcon(
                icon: ModLocationPicker.icon(loc.kind),
                size: 20,
                color: active ? IosColors.label : IosColors.icon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ModLocationPicker.label(loc.kind, widget.es)}'
                      ' · ${loc.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: IosColors.label,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Tooltip(
                      message: loc.path,
                      waitDuration: const Duration(milliseconds: 500),
                      child: Text(
                        ModLocationPicker.shortPath(loc.path),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active
                              ? const Color(0xCCEBEBF5)
                              : IosColors.secondaryLabel,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _opened ? 1 : 0,
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: IosColors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}