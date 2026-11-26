// lib/l10n/nexus_oauth_strings.dart
//
// Textos del inicio de sesión con Nexus Mods. Van aquí (y no en los .arb) para
// que el zip compile sin regenerar las localizaciones. Idiomas: en, es; el
// resto usa inglés. Si prefieres moverlos a los .arb, son 12 claves.
import 'package:flutter/widgets.dart';

class NexusOAuthStrings {
  final String signInTitle;
  final String signInSubtitle;
  final String notConfigured;
  final String waiting;
  final String waitingTapToCancel;
  final String signedInAs; // usa {name}
  final String signedInGeneric;
  final String signOutTitle;
  final String signOutMessage;
  final String signOutAction;
  final String signedInOk;
  final String signedOut;
  final String cancelled;
  final String portBusy; // usa {port}
  final String denied;
  final String timeout;
  final String browserFailed;
  final String failed;
  final String sessionExpired;

  const NexusOAuthStrings({
    required this.signInTitle,
    required this.signInSubtitle,
    required this.notConfigured,
    required this.waiting,
    required this.waitingTapToCancel,
    required this.signedInAs,
    required this.signedInGeneric,
    required this.signOutTitle,
    required this.signOutMessage,
    required this.signOutAction,
    required this.signedInOk,
    required this.signedOut,
    required this.cancelled,
    required this.portBusy,
    required this.denied,
    required this.timeout,
    required this.browserFailed,
    required this.failed,
    required this.sessionExpired,
  });

  static const NexusOAuthStrings en = NexusOAuthStrings(
    signInTitle: 'Sign in with Nexus Mods',
    signInSubtitle:
        'Recommended. Authorize the app in your browser; no API key needed.',
    notConfigured: 'Coming soon (pending registration with Nexus Mods).',
    waiting: 'Waiting for you to approve in the browser…',
    waitingTapToCancel: 'Tap to cancel',
    signedInAs: 'Signed in as {name}',
    signedInGeneric: 'Signed in to Nexus Mods',
    signOutTitle: 'Sign out of Nexus Mods?',
    signOutMessage:
        'The app will stop using your Nexus account. If you saved a personal API key, it will be used instead.',
    signOutAction: 'Sign out',
    signedInOk: 'Signed in to Nexus Mods',
    signedOut: 'Signed out of Nexus Mods',
    cancelled: 'Sign-in cancelled.',
    portBusy:
        'Port {port} is in use. Close whatever is using it and try again.',
    denied: 'Nexus Mods did not authorize the sign-in.',
    timeout: 'Sign-in timed out. Please try again.',
    browserFailed: 'Could not open the browser.',
    failed: 'Sign-in failed. Please try again.',
    sessionExpired:
        'Your Nexus Mods session expired. Sign in again or use your API key.',
  );

  static const NexusOAuthStrings es = NexusOAuthStrings(
    signInTitle: 'Iniciar sesión con Nexus Mods',
    signInSubtitle:
        'Recomendado. Autoriza la app en tu navegador; no hace falta API key.',
    notConfigured: 'Próximamente (pendiente del registro con Nexus Mods).',
    waiting: 'Esperando a que apruebes en el navegador…',
    waitingTapToCancel: 'Toca para cancelar',
    signedInAs: 'Sesión iniciada como {name}',
    signedInGeneric: 'Sesión iniciada en Nexus Mods',
    signOutTitle: '¿Cerrar sesión de Nexus Mods?',
    signOutMessage:
        'La app dejará de usar tu cuenta de Nexus. Si guardaste una API key personal, se usará esa.',
    signOutAction: 'Cerrar sesión',
    signedInOk: 'Sesión iniciada en Nexus Mods',
    signedOut: 'Sesión de Nexus Mods cerrada',
    cancelled: 'Inicio de sesión cancelado.',
    portBusy:
        'El puerto {port} está en uso. Cierra lo que lo use e inténtalo de nuevo.',
    denied: 'Nexus Mods no autorizó el inicio de sesión.',
    timeout: 'Se agotó el tiempo del inicio de sesión. Inténtalo de nuevo.',
    browserFailed: 'No se pudo abrir el navegador.',
    failed: 'No se pudo iniciar sesión. Inténtalo de nuevo.',
    sessionExpired:
        'Tu sesión de Nexus Mods caducó. Inicia sesión de nuevo o usa tu API key.',
  );

  static NexusOAuthStrings of(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'es':
        return es;
      default:
        return en;
    }
  }
}
