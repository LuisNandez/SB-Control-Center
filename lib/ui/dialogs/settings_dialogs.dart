// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../theme/ios_theme.dart';
import '../widgets/ios_widgets.dart';

/// Página de Nexus Mods donde se obtiene la clave de API personal
/// (aparece al final de la página, en "Personal API Key").
const String _nexusApiKeysUrl =
    'https://www.nexusmods.com/users/myaccount?tab=api%20access';

/// Entrada de la lista de versiones omitidas.
class SkippedVersionItem {
  const SkippedVersionItem({
    required this.id,
    required this.name,
    required this.version,
  });

  final String id;
  final String name;
  final String version;
}

/// Resultado del aviso que invita a configurar la API key al abrir la app.
class ApiKeyPromptResult {
  const ApiKeyPromptResult({
    required this.configure,
    required this.dontShowAgain,
  });

  /// true = "Configurar API" (ir a Ajustes); false = "Omitir".
  final bool configure;

  /// Estado de la casilla "No volver a mostrar este mensaje".
  final bool dontShowAgain;
}

/// Alertas de vidrio (estilo iOS/macOS) para los submenús de Ajustes.
/// Toda la lógica de negocio llega por callbacks: aquí solo hay interfaz.
class SettingsDialogs {
  SettingsDialogs._();

  /// Idiomas disponibles (código -> nombre nativo).
  static const Map<String, String> languages = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'ru': 'Русский',
    'de': 'Deutsch',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'it': 'Italiano',
    'fr': 'Français',
  };

  // --------------------------------------------------------------------------
  //  Confirmación / aviso genéricos
  // --------------------------------------------------------------------------

  /// Alerta con "Cancelar" + acción principal. Devuelve true si se confirma.
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    String? message,
    bool destructive = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showIosDialog<bool>(
      context: context,
      builder: (ctx) => IosDialogShell(
        title: title,
        message: message,
        actions: [
          IosDialogButton(
            label: l10n.dialogActionCancel,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          IosDialogButton(
            label: confirmLabel,
            bold: true,
            destructive: destructive,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    return result == true;
  }

  /// Alerta informativa con un único botón.
  static Future<void> info({
    required BuildContext context,
    required String title,
    required String okLabel,
    String? message,
  }) {
    return showIosDialog<void>(
      context: context,
      builder: (ctx) => IosDialogShell(
        title: title,
        message: message,
        actions: [
          IosDialogButton(
            label: okLabel,
            bold: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  Idioma
  // --------------------------------------------------------------------------

  /// Lista de selección única con marca azul en el idioma actual.
  /// Cierra la alerta y después llama a [onSelected].
  static Future<void> language(
    BuildContext context, {
    required String current,
    required Future<void> Function(String code) onSelected,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final entries = languages.entries.toList();

    return showIosDialog<void>(
      context: context,
      builder: (ctx) => IosDialogShell(
        title: l10n.language,
        width: 340,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: IosListCard(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: entries.length,
              separatorBuilder: (_, __) => const IosRowSeparator(),
              itemBuilder: (_, i) {
                final e = entries[i];
                return IosChoiceRow(
                  label: e.value,
                  selected: e.key == current,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await onSelected(e.key);
                  },
                );
              },
            ),
          ),
        ),
        actions: [
          IosDialogButton(
            label: l10n.dialogActionClose,
            bold: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  Acerca de
  // --------------------------------------------------------------------------

  /// Pulsar 7 veces la versión cierra la alerta y llama a
  /// [onDeveloperModeUnlocked] (el contador vive aquí dentro).
  static Future<void> about(
    BuildContext context, {
    required String version,
    required VoidCallback onDeveloperModeUnlocked,
  }) {
    final l10n = AppLocalizations.of(context)!;
    int taps = 0;

    return showIosDialog<void>(
      context: context,
      builder: (ctx) => IosDialogShell(
        title: l10n.aboutTitle,
        message: l10n.aboutContent,
        width: 340,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                taps++;
                if (taps >= 7) {
                  Navigator.of(ctx).pop();
                  onDeveloperModeUnlocked();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: IosColors.fill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.aboutVersion(version),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                    color: IosColors.secondaryLabel,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            IosTextButton(
              label: l10n.aboutLinkText,
              onPressed: () => launchUrl(Uri.parse(l10n.creatorProfileUrl)),
            ),
          ],
        ),
        actions: [
          IosDialogButton(
            label: l10n.dialogActionClose,
            bold: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  Aviso inicial: configurar la API key
  // --------------------------------------------------------------------------

  /// Aviso (no obligatorio) que anima a configurar la API key de Nexus.
  /// Botones: "Omitir" y "Configurar API", más la casilla "No volver a mostrar
  /// este mensaje" y un selector de idioma (mini menú con los 10 idiomas) para
  /// poder leer el aviso en tu idioma. Hay que elegir uno de los dos botones
  /// (no se cierra al tocar fuera) para que el estado de la casilla nunca se
  /// pierda.
  ///
  /// [onLanguageChanged] debe guardar el idioma y aplicarlo a la app; el aviso
  /// se vuelve a traducir al instante.
  static Future<ApiKeyPromptResult> apiKeyPrompt(
    BuildContext context, {
    required Future<void> Function(String code) onLanguageChanged,
  }) async {
    bool dontShowAgain = false;

    final result = await showIosDialog<ApiKeyPromptResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            // Se consulta aquí (no fuera) para que, al cambiar de idioma, el
            // aviso se reconstruya con los textos del idioma nuevo.
            final l10n = AppLocalizations.of(ctx)!;
            final currentLang = Localizations.localeOf(ctx).languageCode;

            return IosDialogShell(
              title: l10n.apiKeyPromptTitle,
              message: l10n.apiKeyPromptMessage,
              width: 400,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: _languagePill(
                      context: ctx,
                      current: currentLang,
                      onSelected: (code) async {
                        if (code == currentLang) return;
                        await onLanguageChanged(code);
                        if (ctx.mounted) setS(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  IosCheckRow(
                    label: l10n.apiKeyPromptDontShowAgain,
                    selected: dontShowAgain,
                    onTap: () => setS(() => dontShowAgain = !dontShowAgain),
                  ),
                ],
              ),
              actions: [
                IosDialogButton(
                  label: l10n.apiKeyPromptSkip,
                  onPressed: () => Navigator.of(dialogContext).pop(
                    ApiKeyPromptResult(
                      configure: false,
                      dontShowAgain: dontShowAgain,
                    ),
                  ),
                ),
                IosDialogButton(
                  label: l10n.apiKeyPromptConfigure,
                  bold: true,
                  onPressed: () => Navigator.of(dialogContext).pop(
                    ApiKeyPromptResult(
                      configure: true,
                      dontShowAgain: dontShowAgain,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    return result ??
        ApiKeyPromptResult(configure: false, dontShowAgain: dontShowAgain);
  }

  /// Botón pequeño con el idioma actual (🌐 Español ▾). Al pulsarlo abre un
  /// mini menú emergente, anclado debajo del botón, con los 10 idiomas en su
  /// nombre nativo y una marca azul en el actual.
  static Widget _languagePill({
    required BuildContext context,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    Future<void> open(BuildContext buttonContext) async {
      final button = buttonContext.findRenderObject() as RenderBox;
      final overlay = Navigator.of(buttonContext)
          .overlay!
          .context
          .findRenderObject() as RenderBox;
      final topLeft = button.localToGlobal(
        Offset(0, button.size.height + 4),
        ancestor: overlay,
      );
      final position = RelativeRect.fromLTRB(
        topLeft.dx,
        topLeft.dy,
        overlay.size.width - topLeft.dx - button.size.width,
        overlay.size.height - topLeft.dy,
      );
      final code = await showMenu<String>(
        context: buttonContext,
        position: position,
        constraints: const BoxConstraints(minWidth: 180),
        items: [
          for (final e in languages.entries)
            PopupMenuItem<String>(
              value: e.key,
              height: 36,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: e.key == current
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: IosColors.blue)
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Text(e.value),
                ],
              ),
            ),
        ],
      );
      if (code != null) onSelected(code);
    }

    return Builder(
      builder: (buttonContext) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => open(buttonContext),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: IosColors.fill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded,
                    size: 16, color: IosColors.secondaryLabel),
                const SizedBox(width: 6),
                Text(
                  languages[current] ?? current,
                  style: const TextStyle(
                    fontSize: 13,
                    color: IosColors.label,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.expand_more_rounded,
                    size: 16, color: IosColors.secondaryLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  API key de Nexus
  // --------------------------------------------------------------------------

  /// [onSubmit] recibe la clave (puede estar vacía para borrarla) y devuelve
  /// true si se aceptó/guardó, o false si no es válida (se muestra el error).
  /// Devuelve la clave guardada, o null si se cancela.
  static Future<String?> apiKey({
    required BuildContext context,
    required String? initialKey,
    required Future<bool> Function(String key) onSubmit,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: initialKey ?? '');
    bool checking = false;
    String? error;

    final result = await showIosDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            Future<void> submit() async {
              if (checking) return;
              final key = controller.text.trim();
              setS(() {
                checking = true;
                error = null;
              });
              final ok = await onSubmit(key);
              if (!dialogContext.mounted) return;
              if (ok) {
                Navigator.of(dialogContext).pop(key);
              } else {
                setS(() {
                  checking = false;
                  error = l10n.invalidApiKeyError;
                });
              }
            }

            return IosDialogShell(
              title: l10n.dialogTitleApiKey,
              message: l10n.dialogContentApiKey,
              width: 400,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.dialogContentApiKeyInstructions,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(_nexusApiKeysUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 15),
                      label: Text(l10n.apiKeyOpenNexusPage),
                    ),
                  ),
                  const SizedBox(height: 6),
                  IosFormField(
                    label: l10n.apiKey,
                    hint: l10n.apiKeyHintText,
                    controller: controller,
                    autofocus: true,
                    onChanged: (_) {
                      if (error != null) setS(() => error = null);
                    },
                    onSubmitted: (_) => submit(),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 2),
                      child: Text(
                        error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: IosColors.red,
                        ),
                      ),
                    ),
                  if (checking)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const IosSpinner(),
                          const SizedBox(width: 8),
                          Text(
                            l10n.validatingApiKey,
                            style: const TextStyle(
                              fontSize: 12,
                              color: IosColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                IosDialogButton(
                  label: l10n.dialogActionCancel,
                  onPressed:
                      checking ? null : () => Navigator.of(dialogContext).pop(),
                ),
                IosDialogButton(
                  label: l10n.dialogActionSave,
                  bold: true,
                  onPressed: checking ? null : submit,
                ),
              ],
            );
          },
        );
      },
    );

    // Se libera tras la animación de cierre para no tocar un controlador
    // que aún está en pantalla.
    Future.delayed(const Duration(milliseconds: 400), controller.dispose);
    return result;
  }

  // --------------------------------------------------------------------------
  //  Versiones omitidas
  // --------------------------------------------------------------------------

  static Future<void> skippedVersions({
    required BuildContext context,
    required List<SkippedVersionItem> items,
    required Future<void> Function(String id) onRemove,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final list = List<SkippedVersionItem>.of(items);

    return showIosDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final Widget body = list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    l10n.dialogNoSkippedVersions,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: IosListCard(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const IosRowSeparator(),
                      itemBuilder: (_, i) {
                        final item = list[i];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        letterSpacing: -0.2,
                                        color: IosColors.label,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${l10n.dialogSkippedVersions}: ${item.version}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: IosColors.secondaryLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IosToolbarButton(
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedDelete01,
                                  color: IosColors.red,
                                  size: 18.0,
                                ),
                                onPressed: () async {
                                  await onRemove(item.id);
                                  setS(() =>
                                      list.removeWhere((e) => e.id == item.id));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );

          return IosDialogShell(
            title: l10n.dialogTitleSkippedVersions,
            width: 400,
            content: body,
            actions: [
              IosDialogButton(
                label: l10n.dialogActionClose,
                bold: true,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
//  Piezas internas
// ============================================================================

/// Tarjeta gris translúcida que agrupa filas dentro de una alerta.
class IosListCard extends StatelessWidget {
  const IosListCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class IosRowSeparator extends StatelessWidget {
  const IosRowSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Container(height: 0.5, color: const Color(0x1FFFFFFF)),
    );
  }
}

/// Fila de selección única: texto a la izquierda, marca azul si está elegida.
class IosChoiceRow extends StatefulWidget {
  const IosChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<IosChoiceRow> createState() => IosChoiceRowState();
}

class IosChoiceRowState extends State<IosChoiceRow> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          color: _pressed
              ? const Color(0x1FFFFFFF)
              : (_hover ? const Color(0x0FFFFFFF) : Colors.transparent),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    letterSpacing: -0.2,
                    fontWeight:
                        widget.selected ? FontWeight.w600 : FontWeight.w400,
                    color: IosColors.label,
                  ),
                ),
              ),
              if (widget.selected)
                const Icon(
                  Icons.check_rounded,
                  size: 19,
                  color: IosColors.blue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}