import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../services/self_endorse_service.dart';
import '../theme/ios_theme.dart';
import 'ios_widgets.dart';

/// Sección "Endorse" (Ajustes > General, al final, centrada): botón para
/// endorsar la app en Nexus Mods. Al endorsar, el botón se desvanece despacio y
/// aparece el agradecimiento. Si la cuenta ya la endorsó, no se muestra nada.
class SelfEndorseSection extends StatefulWidget {
  const SelfEndorseSection({super.key});

  @override
  State<SelfEndorseSection> createState() => _SelfEndorseSectionState();
}

class _SelfEndorseSectionState extends State<SelfEndorseSection> {
  /// El agradecimiento solo se muestra si el usuario pulsó Endorse en esta
  /// sesión, y se desvanece a los 4 s (sin volver a salir al reentrar).
  static bool _pressedThisSession = false;
  static bool _thanksDismissed = false;
  static const Duration _thanksDuration = Duration(seconds: 4);
  Timer? _thanksTimer;

  void _startThanksTimer() {
    _thanksTimer ??= Timer(_thanksDuration, () {
      _thanksDismissed = true;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _thanksTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Comprueba en Nexus si la cuenta ya endorsó la app (una vez por sesión).
    SelfEndorseService.instance.ensureChecked();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = SelfEndorseService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final Widget child;
        if (service.state == SelfEndorseState.available) {
          child = _buildAvailable(l10n, service);
        } else if (service.state == SelfEndorseState.thanked &&
            _pressedThisSession &&
            !_thanksDismissed) {
          _startThanksTimer();
          child = _buildThanks(l10n);
        } else {
          child = const SizedBox.shrink(key: ValueKey('hidden'));
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1100),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, if (current != null) current],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvailable(AppLocalizations l10n, SelfEndorseService service) {
    String? problemText;
    if (service.problem == SelfEndorseProblem.notDownloaded) {
      problemText = l10n.endorseErrNotDownloaded;
    } else if (service.problem == SelfEndorseProblem.invalidKey) {
      problemText = l10n.endorseErrInvalidKey;
    }

    return Padding(
      key: const ValueKey('available'),
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.aboutEndorseCta,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: IosColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          IosButton(
            label: l10n.detailsEndorse,
            icon: const Icon(
              Icons.thumb_up_alt_rounded,
              size: 15,
              color: Colors.white,
            ),
            onPressed: service.busy
                ? null
                : () {
                    _pressedThisSession = true;
                    service.endorse();
                  },
          ),
          if (problemText != null) ...[
            const SizedBox(height: 8),
            Text(
              problemText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: IosColors.red),
            ),
            if (service.problem == SelfEndorseProblem.notDownloaded)
              IosTextButton(
                label: l10n.openInNexusMods,
                onPressed: () => launchUrl(Uri.parse(SelfEndorseService.modUrl)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildThanks(AppLocalizations l10n) {
    return Padding(
      key: const ValueKey('thanks'),
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, size: 15, color: IosColors.red),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.aboutEndorseThanks,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: IosColors.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}