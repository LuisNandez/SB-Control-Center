// lib/ui/widgets/gpu_acceleration_settings.dart
//
// Sección de Ajustes → General: interruptor "Usar la tarjeta gráfica"
// (desactivado por defecto). La lógica vive en [GpuPreferenceService].
//
//  * Al cambiarlo, pregunta si reiniciar ahora (la app se cierra y se vuelve a
//    abrir sola); con "Más tarde" el aviso de reinicio queda en el subtítulo.
//  * Si el equipo solo tiene una tarjeta gráfica, la opción aparece
//    deshabilitada (salvo que ya estuviera activada, para poder desactivarla).
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_prefs.dart';
import '../../l10n/app_localizations.dart';
import '../../services/gpu_preference_service.dart';
import '../theme/ios_theme.dart';
import 'ios_settings_widgets.dart';
import 'ios_widgets.dart';

class GpuAccelerationSection extends StatefulWidget {
  const GpuAccelerationSection({super.key});

  @override
  State<GpuAccelerationSection> createState() => _GpuAccelerationSectionState();
}

class _GpuAccelerationSectionState extends State<GpuAccelerationSection> {
  bool _enabled = false;
  bool _busy = false;
  bool _failed = false;

  /// true solo cuando se SABE que el equipo tiene una única gráfica física.
  bool _singleGpu = false;

  /// Windows lee la preferencia al abrir el proceso: hay que reiniciar si el
  /// valor actual difiere del que tenía la app al arrancar.
  bool get _needsRestart => GpuPreferenceService.restartPending(_enabled);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _enabled = prefs.getBool(AppPrefs.useGpuAcceleration) ?? false);

    final int? count = await GpuPreferenceService.physicalGpuCount();
    if (!mounted) return;
    setState(() => _singleGpu = count == 1);
  }

  Future<void> _toggle(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);
    final bool ok = await GpuPreferenceService.setEnabled(value);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _failed = !ok;
      if (ok) _enabled = value;
    });
    if (ok && GpuPreferenceService.restartPending(value)) {
      await _askRestart();
    }
  }

  /// "¿Reiniciar ahora?": con "Reiniciar ahora" la app se cierra y se abre sola.
  Future<void> _askRestart() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? restart = await showIosDialog<bool>(
      context: context,
      builder: (ctx) => IosDialogShell(
        title: l10n.settingsGpuRestartTitle,
        message: l10n.settingsGpuRestartMsg,
        actions: [
          IosDialogButton(
            label: l10n.settingsGpuRestartLater,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          IosDialogButton(
            label: l10n.settingsGpuRestartNow,
            bold: true,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (restart != true || !mounted) return;
    // Si todo va bien, este proceso termina aquí y la copia nueva toma el relevo.
    await GpuPreferenceService.restartApp();
  }

  @override
  Widget build(BuildContext context) {
    // Solo tiene sentido en Windows.
    if (!GpuPreferenceService.isSupported) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    // Con una sola gráfica no hay nada que elegir (si ya estaba activada se deja
    // tocar para poder volver a desactivarla).
    final bool locked = _singleGpu && !_enabled;
    final String subtitle = _failed
        ? l10n.settingsGpuAccelFailed
        : (locked
            ? l10n.settingsGpuAccelSingle
            : (_needsRestart
                ? l10n.settingsGpuAccelRestart
                : l10n.settingsGpuAccelDesc));

    return IosSettingsSection(
      footer: l10n.settingsGpuAccelFooter,
      children: [
        IosSettingsSwitchTile(
          leading: IosIconBadge(
            color: IosColors.green,
            child: const Icon(Icons.speed_rounded, color: Colors.white, size: 16),
          ),
          title: l10n.settingsGpuAccel,
          subtitle: subtitle,
          value: _enabled,
          enabled: !locked,
          onChanged: _toggle,
        ),
      ],
    );
  }
}
