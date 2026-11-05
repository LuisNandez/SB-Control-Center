// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import '../../models/mod_info.dart';
import '../theme/app_layout.dart';
import '../theme/ios_theme.dart';
import 'material_layout_widgets.dart';

/// Interruptor estilo iOS que maneja su propio estado de animación localmente
/// para permitir una transición visual suave (deslizamiento) al cambiar,
/// mientras sigue llamando a los callbacks del widget principal para
/// ejecutar la lógica de habilitación/deshabilitación.
class AnimatedModSwitch extends StatefulWidget {
  final ModInfo modInfo;
  final bool isLoading;
  final Future<bool> Function(ModInfo) onEnable;
  final Future<bool> Function(ModInfo) onDisable;
  final double scale;

  const AnimatedModSwitch({
    super.key,
    required this.modInfo,
    required this.isLoading,
    required this.onEnable,
    required this.onDisable,
    this.scale = 1.0,
  });

  @override
  State<AnimatedModSwitch> createState() => _AnimatedModSwitchState();
}

class _AnimatedModSwitchState extends State<AnimatedModSwitch> {
  late bool _isEnabled;
  bool _isLocallyLoading = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.modInfo.isEnabled;
  }

  @override
  void didUpdateWidget(covariant AnimatedModSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.modInfo.isEnabled != _isEnabled && !_isLocallyLoading) {
      _isEnabled = widget.modInfo.isEnabled;
    }
  }

  Future<void> _handleChange(bool newValue) async {
    // Mientras se procesa un cambio se ignoran toques extra, pero el
    // interruptor conserva su aspecto normal (como en iOS).
    if (_isLocallyLoading) return;

    setState(() {
      _isEnabled = newValue;
      _isLocallyLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final bool success = newValue
          ? await widget.onEnable(widget.modInfo)
          : await widget.onDisable(widget.modInfo);

      if (!success && mounted) {
        setState(() => _isEnabled = !newValue);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isEnabled = !newValue);
      }
    } finally {
      if (mounted) {
        setState(() => _isLocallyLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Diseño Material: el MISMO interruptor (52x32) en tarjetas, lista y
    // ajustes; el parámetro [scale] solo se usa con el diseño iOS.
    if (AppLayouts.isMaterial) {
      return MdSwitch(
        value: _isEnabled,
        onChanged: widget.isLoading ? null : _handleChange,
      );
    }

    final Widget switchWidget = CupertinoSwitch(
      value: _isEnabled,
      activeColor: IosColors.green,
      onChanged: widget.isLoading ? null : _handleChange,
    );

    if (widget.scale != 1.0) {
      // El CupertinoSwitch mide 51x31; se escala también el espacio que ocupa.
      return SizedBox(
        width: 51 * widget.scale,
        height: 31 * widget.scale,
        child: FittedBox(fit: BoxFit.contain, child: switchWidget),
      );
    }

    return switchWidget;
  }
}