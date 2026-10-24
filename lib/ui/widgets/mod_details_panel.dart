import 'dart:async';
import 'dart:io';
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../models/mod_info.dart';
import '../../services/endorse_info_store.dart';
import '../../services/nexus_api_service.dart';
import '../../services/translation_service.dart';
import '../../l10n/app_localizations.dart';
import '../../thumbnail_service.dart';
import '../../notification_service.dart';
import '../../utils/text_utils.dart';
import 'mod_image_widgets.dart';
import '../theme/ios_theme.dart';
import 'bbcode_renderer.dart';
import 'ios_motion.dart';
import 'ios_widgets.dart';
import 'outfit_picker_sheet.dart';
import 'smooth_scroll.dart';
import 'image_viewer.dart' show registerGalleryOrigin, imageViewerActive;

class ModDetailsPanel extends StatefulWidget {
  final ModInfo initialModInfo;
  final ThumbnailService thumbnailService;
  // Funciones que necesita del widget principal
  final Future<ModInfo?> Function(ModInfo, Map<String, dynamic>)
  onUpdateDetails;
  final Future<void> Function(ModInfo) onShowInExplorer;
  final void Function(ModInfo) onShowImageGallery;
  final Future<Map<String, dynamic>?> Function(ModInfo, BuildContext)
  onShowGeneralEditDialog;
  /// Abre el ajuste de la portada actual del mod (la de Nexus o la
  /// personalizada) y devuelve el mod actualizado, o null si se cancela.
  final Future<ModInfo?> Function(ModInfo) onAdjustCover;
  final Function(ModInfo?) onPanelClosed;
  // Información de la actualización disponible.
  final Map<String, dynamic>? updateInfo;
  final bool isIgnored;
  final Future<bool> Function({
    required String newVersion,
    required String nexusId,
    required int fileId,
    required String uniqueIdentifier,
    ModInfo? mod,
  })
  onShowUpdateDialog;

  /// Otras ediciones del mismo mod (mismo ID de Nexus) que también están
  /// instaladas. Vacío si este mod solo tiene una edición.
  final List<ModInfo> otherEditions;

  /// API key de Nexus Mods del usuario (null o vacía si no la ha introducido).
  /// Hace falta para endorsar el mod.
  final String? apiKey;

  const ModDetailsPanel({
    required this.initialModInfo,
    required this.thumbnailService,
    required this.onUpdateDetails,
    required this.onShowInExplorer,
    required this.onShowImageGallery,
    required this.onShowGeneralEditDialog,
    required this.onAdjustCover,
    required this.onPanelClosed,
    this.updateInfo,
    required this.isIgnored,
    required this.onShowUpdateDialog,
    this.otherEditions = const [],
    this.apiKey,
  });

  @override
  State<ModDetailsPanel> createState() => ModDetailsPanelState();
}

class ModDetailsPanelState extends State<ModDetailsPanel> {
  late ModInfo currentModInfo;
  bool _isTranslating = false;
  bool _showTranslateSummaryButton = false;
  bool _showTranslateDescriptionButton = false;
  bool _needsReloadOnClose = false;
  late bool _isIgnored;
  late bool _isReplacementMod;

  // ---- Endorse ---------------------------------------------------------------
  /// Nexus exige esperar este tiempo desde la descarga antes de endorsar.
  static const Duration _endorseMinWait = Duration(minutes: 15);

  /// Cada cuánto se vuelve a preguntar a Nexus por el estado de este mod.
  static const Duration _endorseRefreshEvery = Duration(minutes: 10);

  /// 'Endorsed' | 'Abstained' | 'Undecided'; null = todavía no se sabe.
  String? _endorseStatus;

  /// Lo guardado en el nexus_info.json del mod (estado + cuándo se confirmó).
  EndorseRecord? _endorseRecord;
  Future<void>? _endorseRestore;
  bool _endorseBusy = false;

  /// Se incrementa cada vez que el usuario endorsa / quita el endorse: una
  /// consulta de estado iniciada antes ya está obsoleta y no debe pisar el
  /// resultado.
  int _endorseActionSeq = 0;

  /// Se incrementa si falla un guardado, para recrear las tarjetas de trajes
  /// que se habían "colapsado" visualmente antes de confirmarse.
  int _outfitsRevision = 0;

  final ScrollController _carouselScrollController = ScrollController();

  /// Suavizado de la rueda del ratón, compartido entre el contenido del panel
  /// y los bordes donde está la barra de scroll.
  final IosWheelSmoother _wheelSmoother = IosWheelSmoother();

  /// Desplazamiento vertical del contenido (para mostrar el título compacto
  /// en la cabecera al bajar, como la barra de navegación de iOS).
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  /// Clave de la portada: el visor de imágenes lee su rectángulo en pantalla.
  final GlobalKey _coverKey = GlobalKey(debugLabel: 'details-cover');

  // ---- Apertura fluida ------------------------------------------------------
  // Mientras la hoja sube desde abajo solo se construye lo ligero (cabecera,
  // portada, título y acciones). El resto (resumen, información, descripción
  // BBCode, trajes...) se monta justo cuando termina la animación: así la hoja
  // no compite con el trabajo de construir y pintar todo el contenido.
  bool _contentReady = false;
  bool _transitionHooked = false;
  Animation<double>? _routeAnimation;
  Timer? _readyFallback;

  @override
  void initState() {
    super.initState();
    currentModInfo = widget.initialModInfo;
    _isIgnored = widget.isIgnored;
    _isReplacementMod =
        currentModInfo.modType == 'replacement' ||
        (currentModInfo.modType == 'genericPak' &&
            (currentModInfo.replacesOutfits != null &&
                currentModInfo.replacesOutfits!.isNotEmpty));
    // La comprobación de traducción (peticiones de red + setState) se lanza en
    // _markContentReady, cuando ya terminó la animación de apertura.
    _endorseRestore = _restoreEndorseStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_transitionHooked) return;
    _transitionHooked = true;

    final Animation<double>? animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _markContentReady());
    } else {
      _routeAnimation = animation;
      animation.addStatusListener(_onRouteStatus);
      // Red de seguridad por si la animación nunca llega a "completed".
      _readyFallback = Timer(
        const Duration(milliseconds: 800),
        _markContentReady,
      );
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _markContentReady();
  }

  void _markContentReady() {
    if (_contentReady || !mounted) return;
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _readyFallback?.cancel();
    setState(() => _contentReady = true);
    _updateTranslationButtonVisibility();
    _loadEndorseStatus();
  }

  /// Miniatura de la portada que la lista ya tiene en memoria. Se muestra al
  /// instante mientras llega la imagen a tamaño completo. (La clave es la misma
  /// que usa ModGridCard.)
  File? _coverPlaceholder() {
    final ModInfo mod = currentModInfo;
    String? key;
    if (mod.customCoverPath != null && mod.customCoverPath!.isNotEmpty) {
      key = p.basename(mod.directory.path) + mod.customCoverPath!;
      if (mod.customCoverLastModified != null) {
        key += mod.customCoverLastModified!.millisecondsSinceEpoch.toString();
      }
    } else if (mod.gallery != null && mod.gallery!.isNotEmpty) {
      key = mod.gallery!.first['thumbnail'] as String?;
    }
    if (key == null) return null;
    return widget.thumbnailService.getFromMemoryCache(key);
  }

  /// Se llama AUTOMÁTICAMENTE cuando el widget se va a destruir: entrega al
  /// widget principal el mod actualizado si hubo cambios.
  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _readyFallback?.cancel();
    widget.onPanelClosed(_needsReloadOnClose ? currentModInfo : null);
    _wheelSmoother.cancel();
    _carouselScrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  //  TRADUCCIÓN
  // ---------------------------------------------------------------------------
  Future<bool> _checkIfTextNeedsTranslation(String? text) async {
    if (!mounted) return false;
    if (text == null || text.trim().isEmpty) return false;
    // Compara el idioma detectado con el de la app (válido para todos los
    // idiomas: 'zh-CN' == 'zh', 'pt-BR' == 'pt', etc.).
    return TranslationService.instance.needsTranslation(
      text,
      Localizations.localeOf(context),
    );
  }

  /// Comprueba ambos campos (resumen y descripción) y actualiza la visibilidad de sus botones.
  Future<void> _updateTranslationButtonVisibility() async {
    final isShowingOriginalSummary =
        currentModInfo.customSummary == null ||
        currentModInfo.customSummary!.isEmpty;
    if (isShowingOriginalSummary) {
      final needsTranslation = await _checkIfTextNeedsTranslation(
        currentModInfo.summary,
      );
      if (mounted) {
        setState(() => _showTranslateSummaryButton = needsTranslation);
      }
    } else {
      if (mounted) {
        setState(() => _showTranslateSummaryButton = false);
      }
    }

    final isShowingOriginalDescription =
        currentModInfo.customDescription == null ||
        currentModInfo.customDescription!.isEmpty;
    if (isShowingOriginalDescription) {
      final needsTranslation = await _checkIfTextNeedsTranslation(
        currentModInfo.description,
      );
      if (mounted) {
        setState(() => _showTranslateDescriptionButton = needsTranslation);
      }
    } else {
      if (mounted) {
        setState(() => _showTranslateDescriptionButton = false);
      }
    }
  }

  // Traduce el resumen
  Future<void> _translateSummary() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    if (currentModInfo.summary == null ||
        currentModInfo.summary!.trim().isEmpty)
      return;

    setState(() => _isTranslating = true);

    try {
      final translated = await TranslationService.instance.translatePlain(
        currentModInfo.summary!,
        locale,
      );

      // Se guarda en el campo personalizado ('summary' → 'customSummary' en onUpdateDetails).
      final updatedMod = await widget.onUpdateDetails(currentModInfo, {
        'summary': translated,
      });

      if (updatedMod != null && mounted) {
        setState(() {
          currentModInfo = updatedMod;
          _showTranslateSummaryButton = false;
          _needsReloadOnClose = true;
        });
      }
    } catch (e) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.errorTranslation,
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  // Traduce la descripción
  Future<void> _translateDescription() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    if (currentModInfo.description == null ||
        currentModInfo.description!.trim().isEmpty)
      return;

    setState(() => _isTranslating = true);

    try {
      // Se traduce solo el texto: imágenes, enlaces, listas y formato BBCode
      // se conservan tal cual para que la descripción se siga viendo igual.
      final translated = await TranslationService.instance.translateBBCode(
        currentModInfo.description!,
        locale,
      );

      final updatedMod = await widget.onUpdateDetails(currentModInfo, {
        'customDescription': translated,
      });

      if (updatedMod != null && mounted) {
        setState(() {
          currentModInfo = updatedMod;
          _showTranslateDescriptionButton = false;
          _needsReloadOnClose = true;
        });
      }
    } catch (e) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.errorTranslation,
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  /// Quita la descripción personalizada (traducida o editada) y vuelve a
  /// mostrar la original de Nexus.
  Future<void> _restoreOriginalDescription() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isTranslating = true);
    try {
      // Una cadena vacía hace que onUpdateDetails elimine 'customDescription'.
      final updatedMod = await widget.onUpdateDetails(currentModInfo, {
        'customDescription': '',
      });
      if (updatedMod != null && mounted) {
        setState(() {
          currentModInfo = updatedMod;
          _needsReloadOnClose = true;
        });
        // Vuelve a comprobar si la original necesita traducción.
        _updateTranslationButtonVisibility();
      }
    } catch (e) {
      NotificationService.instance.show(
        context: context,
        type: NotificationType.error,
        title: l10n.errorSavingChanges,
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  // ---------------------------------------------------------------------------
  //  UTILIDADES
  // ---------------------------------------------------------------------------

  /// Copia [text] al portapapeles y avisa con una notificación.
  Future<void> _copy(String text) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    NotificationService.instance.show(
      context: context,
      type: NotificationType.success,
      title: l10n.detailsCopied,
      description: text.length > 90 ? '${text.substring(0, 90)}…' : text,
    );
  }

  String _formatDate(DateTime date) {
    final String locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date.toLocal());
  }

  /// "1.2.0" → "v1.2.0"; "Final" se deja tal cual.
  String _prettyVersion(String version) =>
      RegExp(r'^\d').hasMatch(version) ? 'v$version' : version;

  /// Etiqueta y color del tipo de mod (mismos que en las tarjetas de la lista).
  (String, Color) _typeInfo(AppLocalizations l10n) {
    switch (currentModInfo.displayType) {
      case 'replacement':
        return (l10n.modTypeReplacement, IosColors.purple);
      case 'genericPak':
        return (l10n.modTypeGeneric, IosColors.gray);
      case 'movies':
        return (l10n.modTypeMovies, IosColors.red);
      case 'logicMod':
        return (l10n.modTypeLogic, IosColors.blue);
      case 'save':
        return (l10n.modTypeSave, IosColors.green);
      case 'config':
        return (l10n.modTypeConfig, IosColors.teal);
      case 'splash':
        return (l10n.modTypeSplash, IosColors.orange);
      default:
        return (l10n.modTypeCNS, IosColors.teal);
    }
  }

  // ---------------------------------------------------------------------------
  //  DIÁLOGO DE EDICIÓN DE UN SOLO CAMPO (alerta de vidrio estilo iOS)
  // ---------------------------------------------------------------------------
  Future<String?> _showSingleFieldEditDialog({
    required String title,
    required String label,
    required String initialValue,
    String? defaultValue,
    int? maxLength,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final l10n = AppLocalizations.of(context)!;

    final String? result = await showIosDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final bool isCurrentlyDefault =
                controller.text == (defaultValue ?? '');
            return IosDialogShell(
              title: title,
              width: 380,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 6),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: IosColors.secondaryLabel,
                      ),
                    ),
                  ),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    minLines: 1,
                    maxLines: null,
                    maxLength: maxLength,
                    cursorColor: IosColors.blue,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: IosColors.label,
                    ),
                    decoration: iosInputDecoration(),
                    onChanged: (v) => setDialogState(() {}),
                  ),
                  if (defaultValue != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: IosTextButton(
                          label: l10n.dialogActionResetToDefault,
                          fontSize: 12.5,
                          onPressed: isCurrentlyDefault
                              ? null
                              : () => setDialogState(
                                  () => controller.text = defaultValue,
                                ),
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                IosDialogButton(
                  label: l10n.dialogActionCancel,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                IosDialogButton(
                  label: l10n.dialogActionSave,
                  bold: true,
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(controller.text),
                ),
              ],
            );
          },
        );
      },
    );
    // El diálogo sigue en pantalla durante su animación de salida.
    Future.delayed(const Duration(milliseconds: 400), controller.dispose);
    return result;
  }

  // ---------------------------------------------------------------------------
  //  ACCIONES SOBRE EL MOD
  // ---------------------------------------------------------------------------
  Future<void> _saveField(Map<String, dynamic> data) async {
    final updatedMod = await widget.onUpdateDetails(currentModInfo, data);
    if (updatedMod != null && mounted) {
      setState(() {
        currentModInfo = updatedMod;
        _needsReloadOnClose = true;
      });
    }
  }

  Future<void> _editVersion(String displayVersion, AppLocalizations l10n) async {
    final newVersion = await _showSingleFieldEditDialog(
      title: l10n.editVersionText,
      label: l10n.customVersionText,
      initialValue: displayVersion,
      defaultValue: currentModInfo.localVersion ?? '',
      maxLength: 15,
    );
    if (newVersion == null) return;
    await _saveField({'customVersion': newVersion});
  }

  Future<void> _editSummary(AppLocalizations l10n) async {
    final newSummary = await _showSingleFieldEditDialog(
      title: l10n.modSummary,
      label: l10n.summaryLabel,
      initialValue: currentModInfo.customSummary ?? currentModInfo.summary ?? '',
      defaultValue: currentModInfo.summary ?? '',
    );
    if (newSummary != null) await _saveField({'summary': newSummary});
  }

  Future<void> _editNotes(AppLocalizations l10n) async {
    final newNotes = await _showSingleFieldEditDialog(
      title: l10n.personalNotes,
      label: l10n.notesLabel,
      initialValue: currentModInfo.userNotes ?? '',
    );
    if (newNotes != null) await _saveField({'userNotes': newNotes});
  }

  Future<void> _onUpdatePressed() async {
    if (currentModInfo.nexusId == null) return;
    final updateIdentifier =
        currentModInfo.directory.path +
        (widget.updateInfo!['version'] as String);

    // La función devuelve true si el usuario decidió ocultar el aviso.
    final bool wasHidden = await widget.onShowUpdateDialog(
      newVersion: widget.updateInfo!['version'],
      nexusId: currentModInfo.nexusId!,
      fileId: widget.updateInfo!['fileId'],
      uniqueIdentifier: updateIdentifier,
      mod: currentModInfo,
    );
    if (wasHidden && mounted) {
      setState(() => _isIgnored = true);
    }
  }

  Future<void> _onGeneralEditPressed() async {
    final updatedData = await widget.onShowGeneralEditDialog(
      currentModInfo,
      context,
    );
    if (updatedData == null) return;
    final bool adjustCover = updatedData.remove('adjustCover') == true;
    if (updatedData.isNotEmpty) await _saveField(updatedData);
    if (adjustCover && mounted) {
      final updatedMod = await widget.onAdjustCover(currentModInfo);
      if (updatedMod != null && mounted) {
        setState(() {
          currentModInfo = updatedMod;
          _needsReloadOnClose = true;
        });
      }
    }
  }

  Future<void> _onLinkPressed() async {
    final urlString = currentModInfo.customSourceUrl ?? currentModInfo.sourceUrl;
    if (urlString != null && urlString.isNotEmpty) {
      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) await launchUrl(url);
    } else {
      await _onGeneralEditPressed();
    }
  }

  // ---------------------------------------------------------------------------
  //  ENDORSE (Nexus Mods)
  // ---------------------------------------------------------------------------
  bool get _isNexusMod => (currentModInfo.nexusId ?? '').trim().isNotEmpty;
  bool get _hasApiKey => (widget.apiKey ?? '').trim().isNotEmpty;
  bool get _isEndorsed => _endorseStatus == 'Endorsed';

  int _minutesCeil(Duration d) =>
      d <= Duration.zero ? 0 : (d.inSeconds / 60).ceil();

  /// Mensaje para TOO_SOON_AFTER_DOWNLOAD: explica el motivo y, si se puede, los
  /// minutos que faltan. Se calculan con la fecha de la última descarga que da
  /// Nexus (viewerDownloaded); si no hay, con la de instalación (posterior a la
  /// descarga, así que es una cota segura); y si tampoco, con los 15 min enteros.
  Future<String> _tooSoonText(AppLocalizations l10n) async {
    final DateTime? downloaded = await NexusApiService.fetchViewerDownloadedAt(
      currentModInfo.nexusId!,
      widget.apiKey,
    );
    final DateTime? since = downloaded ?? currentModInfo.installDate;
    final Duration left = since == null
        ? _endorseMinWait
        : _endorseMinWait - DateTime.now().difference(since);
    return l10n.endorseErrWait(_minutesCeil(left).clamp(1, 15).toInt());
  }

  /// Carpetas de TODAS las ediciones instaladas de este mod (incluida la
  /// actual). El endorse es por mod en Nexus, así que se guarda en todas.
  List<Directory> _editionDirs() => [
    currentModInfo.directory,
    ...widget.otherEditions.map((m) => m.directory),
  ];

  /// Lee el estado guardado en el nexus_info.json del mod y lo muestra al
  /// instante, mientras (si hace falta) se confirma con Nexus.
  Future<void> _restoreEndorseStatus() async {
    if (!_isNexusMod) return;
    final int seq = _endorseActionSeq;
    final EndorseRecord? record = await EndorseInfoStore.read(
      currentModInfo.directory,
    );
    if (record == null || seq != _endorseActionSeq) return;
    _endorseRecord = record;
    if (!mounted) return;
    setState(() => _endorseStatus = record.status);
  }

  /// Confirma el estado con Nexus si lo guardado tiene más de 10 minutos (o no
  /// hay nada guardado) y lo escribe en el nexus_info.json del mod.
  Future<void> _loadEndorseStatus() async {
    if (!_isNexusMod || !_hasApiKey) return;
    await _endorseRestore;

    final EndorseRecord? saved = _endorseRecord;
    if (saved != null && saved.isFresh(_endorseRefreshEvery)) return;

    final int seq = _endorseActionSeq;
    final List<Directory> dirs = _editionDirs();
    final String? status = await NexusApiService.fetchEndorseStatus(
      currentModInfo.nexusId!,
      widget.apiKey,
    );
    // Sin dato: se conserva lo guardado y se reintenta la próxima vez que se
    // abra el panel (no se marca como "consultado").
    if (status == null) return;
    // El usuario endorsó o quitó el endorse mientras tanto: esa acción es más
    // reciente que esta respuesta.
    if (seq != _endorseActionSeq || _endorseBusy) return;

    final DateTime now = DateTime.now();
    _endorseRecord = EndorseRecord(status, now);
    // Se guarda aunque el panel ya se haya cerrado.
    await EndorseInfoStore.writeAll(dirs, status, checkedAt: now);

    if (!mounted || seq != _endorseActionSeq || _endorseBusy) return;
    setState(() => _endorseStatus = status);
  }

  String _endorseFailureText(AppLocalizations l10n, EndorseFailure failure) {
    switch (failure) {
      case EndorseFailure.noApiKey:
        return l10n.endorseErrNoApiKey;
      case EndorseFailure.invalidKey:
        return l10n.endorseErrInvalidKey;
      case EndorseFailure.notDownloaded:
        return l10n.endorseErrNotDownloaded;
      case EndorseFailure.tooSoon:
        return l10n.endorseErrWait(_endorseMinWait.inMinutes);
      case EndorseFailure.ownMod:
        return l10n.endorseErrOwnMod;
      case EndorseFailure.rateLimited:
        return l10n.endorseErrRateLimit;
      case EndorseFailure.notFound:
        return l10n.endorseErrNotNexus;
      case EndorseFailure.network:
        return l10n.endorseErrNetwork;
      case EndorseFailure.unknown:
        return l10n.endorseErrUnknown;
    }
  }

  Future<bool> _confirmRemoveEndorse(AppLocalizations l10n) async {
    final bool? result = await showIosDialog<bool>(
      context: context,
      builder: (dialogContext) => IosDialogShell(
        title: l10n.endorseRemoveConfirmTitle,
        message: l10n.endorseRemoveConfirmMessage(currentModInfo.customName),
        actions: [
          IosDialogButton(
            label: l10n.dialogActionCancel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          IosDialogButton(
            label: l10n.endorseRemoveConfirmAction,
            bold: true,
            destructive: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _endorseNotify(NotificationType type, String title, String description) {
    NotificationService.instance.show(
      context: context,
      type: type,
      title: title,
      description: description,
    );
  }

  Future<void> _onEndorsePressed() async {
    if (_endorseBusy) return;
    final l10n = AppLocalizations.of(context)!;

    // 1. Solo los mods de Nexus se pueden endorsar.
    if (!_isNexusMod) {
      _endorseNotify(
        NotificationType.info,
        l10n.endorseFailedTitle,
        l10n.endorseErrNotNexus,
      );
      return;
    }

    // 2. Hace falta la API key.
    if (!_hasApiKey) {
      _endorseNotify(
        NotificationType.info,
        l10n.endorseFailedTitle,
        l10n.endorseErrNoApiKey,
      );
      return;
    }

    // 3. Si ya está endorsado, el botón lo quita (previa confirmación). Si no,
    //    se intenta endorsar siempre: si Nexus lo rechaza (p. ej. por los 15 min
    //    tras la descarga) se avisa del motivo más abajo.
    final bool removing = _isEndorsed;
    if (removing) {
      final bool confirmed = await _confirmRemoveEndorse(l10n);
      if (!confirmed || !mounted) return;
    }

    _endorseActionSeq++;
    setState(() => _endorseBusy = true);
    final EndorseResult result = await NexusApiService.setEndorsement(
      nexusId: currentModInfo.nexusId!,
      apiKey: widget.apiKey,
      endorse: !removing,
      version: currentModInfo.localVersion,
    );
    if (!mounted) return;

    final String? newStatus = result.ok ? result.status : null;
    final DateTime now = DateTime.now();
    if (newStatus != null) {
      // Se guarda en el nexus_info.json del mod: así es lo que se verá al
      // volver a abrir el panel (y durante los próximos 10 minutos).
      _endorseRecord = EndorseRecord(newStatus, now);
      unawaited(
        EndorseInfoStore.writeAll(
          _editionDirs(),
          newStatus,
          checkedAt: now,
        ),
      );
    }
    setState(() {
      _endorseBusy = false;
      if (newStatus != null) _endorseStatus = newStatus;
    });

    if (result.ok) {
      _endorseNotify(
        NotificationType.success,
        removing ? l10n.endorseRemovedTitle : l10n.endorseSuccessTitle,
        currentModInfo.customName,
      );
      return;
    }

    final EndorseFailure failure = result.failure ?? EndorseFailure.unknown;
    final String reason = failure == EndorseFailure.tooSoon
        ? await _tooSoonText(l10n)
        : _endorseFailureText(l10n, failure);
    if (!mounted) return;
    _endorseNotify(NotificationType.error, l10n.endorseFailedTitle, reason);
  }

  // ---------------------------------------------------------------------------
  //  TRAJES QUE REEMPLAZA EL MOD
  // ---------------------------------------------------------------------------

  /// Guarda la lista completa de trajes. Devuelve true si se guardó.
  Future<bool> _onOutfitsSelected(List<String> outfits) async {
    final updatedMod = await widget.onUpdateDetails(currentModInfo, {
      'replacesOutfits': outfits.isEmpty ? null : outfits,
    });

    if (updatedMod != null && mounted) {
      setState(() {
        currentModInfo = updatedMod;
        _needsReloadOnClose = true;
      });
      return true;
    }
    return false;
  }

  Future<void> _openOutfitPicker() async {
    final List<String>? result = await showOutfitPickerSheet(
      context,
      initialSelection: List<String>.from(
        currentModInfo.replacesOutfits ?? const <String>[],
      ),
    );
    if (result == null || !mounted) return;
    await _onOutfitsSelected(result);
  }

  /// Quita un único traje sin abrir el selector.
  Future<void> _removeOutfit(String outfit) async {
    final List<String> remaining = List<String>.from(
      currentModInfo.replacesOutfits ?? const <String>[],
    )..remove(outfit);
    final bool ok = await _onOutfitsSelected(remaining);
    if (!ok && mounted) setState(() => _outfitsRevision++);
  }

  Future<bool> _confirmDisableReplacement(AppLocalizations l10n, int count) async {
    final bool? result = await showIosDialog<bool>(
      context: context,
      builder: (dialogContext) => IosDialogShell(
        title: l10n.replacementOffConfirmTitle,
        message: l10n.replacementOffConfirmMessage(count),
        actions: [
          IosDialogButton(
            label: l10n.dialogActionCancel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          IosDialogButton(
            label: l10n.replacementOffConfirmAction,
            bold: true,
            destructive: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onReplacementSwitchChanged(bool newValue) async {
    final l10n = AppLocalizations.of(context)!;

    // Apagarlo borra los trajes elegidos: se pide confirmación antes.
    final int outfitCount = currentModInfo.replacesOutfits?.length ?? 0;
    if (!newValue && outfitCount > 0) {
      final bool confirmed = await _confirmDisableReplacement(l10n, outfitCount);
      if (!confirmed || !mounted) return;
    }

    final String newModType = newValue ? 'replacement' : 'genericPak';
    final Map<String, dynamic> dataToSave = {'modType': newModType};
    if (newValue == false) {
      dataToSave['replacesOutfits'] = null;
    }

    // Respuesta inmediata del interruptor (como en iOS); se revierte si falla.
    setState(() => _isReplacementMod = newValue);

    final updatedMod = await widget.onUpdateDetails(currentModInfo, dataToSave);
    if (!mounted) return;
    if (updatedMod != null) {
      setState(() {
        currentModInfo = updatedMod;
        _needsReloadOnClose = true;
      });
    } else {
      setState(() => _isReplacementMod = !newValue);
    }
  }

  // ---------------------------------------------------------------------------
  //  PIEZAS DE UI
  // ---------------------------------------------------------------------------
  Widget _sectionIcon(IconData icon) =>
      Icon(icon, size: 15, color: IosColors.secondaryLabel);

  /// Botón de traducir / rueda de carga, alineado con las acciones de sección.
  Widget _translateAction({
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    if (_isTranslating) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: IosSpinner(),
      );
    }
    return IosToolbarButton(
      width: 28,
      height: 28,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: const Icon(Icons.translate_rounded, size: 17, color: IosColors.blue),
    );
  }

  Widget _restoreAction({
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    if (_isTranslating) return const SizedBox.shrink();
    return IosToolbarButton(
      width: 28,
      height: 28,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: const Icon(Icons.restore_rounded, size: 17, color: IosColors.blue),
    );
  }

  Widget _editAction({required VoidCallback onPressed, required String tooltip}) {
    return IosToolbarButton(
      width: 28,
      height: 28,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: const HugeIcon(
        icon: HugeIcons.strokeRoundedEdit01,
        color: IosColors.blue,
        size: 16,
      ),
    );
  }

  /// Sección de texto (resumen): título pequeño + tarjeta translúcida, con
  /// "Mostrar más" si el texto es largo.
  Widget _buildInfoSection({
    required AppLocalizations l10n,
    required String title,
    required String content,
    required Widget icon,
    bool isPlaceholder = false,
    VoidCallback? onEdit,
    VoidCallback? onTranslate,
    String? translateTooltip,
  }) {
    return IosGroup(
      title: title,
      icon: icon,
      actions: [
        if (onTranslate != null)
          _translateAction(
            onPressed: onTranslate,
            tooltip: translateTooltip ?? '',
          ),
        if (onEdit != null)
          _editAction(onPressed: onEdit, tooltip: l10n.editButtonTooltip),
      ],
      child: IosCollapsible(
        enabled: !isPlaceholder,
        collapsedHeight: 96,
        moreLabel: l10n.detailsShowMore,
        lessLabel: l10n.detailsShowLess,
        child: SizedBox(
          width: double.infinity,
          child: Text(
            TextUtils.stripHtml(content),
            style: TextStyle(
              color: isPlaceholder
                  ? IosColors.tertiaryLabel
                  : IosColors.label.withOpacity(0.92),
              fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
              height: 1.45,
              fontSize: 14.5,
              letterSpacing: -0.15,
            ),
          ),
        ),
      ),
    );
  }

  /// Notas personales: toda la tarjeta es pulsable para editar.
  Widget _buildNotesSection(AppLocalizations l10n) {
    final bool isEmpty = !(currentModInfo.userNotes?.isNotEmpty ?? false);
    return IosGroup(
      title: l10n.personalNotes,
      icon: _sectionIcon(Icons.edit_note_outlined),
      actions: [
        if (!isEmpty)
          _editAction(
            onPressed: () => _editNotes(l10n),
            tooltip: l10n.editButtonTooltip,
          ),
      ],
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: IosMotion.sheet,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isEmpty
              ? IosPressable(
                  key: const ValueKey<String>('notes-empty'),
                  scale: 0.985,
                  onTap: () => _editNotes(l10n),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 19,
                          color: IosColors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.detailsAddNote,
                            style: const TextStyle(
                              fontSize: 14.5,
                              letterSpacing: -0.15,
                              color: IosColors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : IosPressable(
                  key: const ValueKey<String>('notes-filled'),
                  scale: 0.995,
                  onTap: () => _editNotes(l10n),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      currentModInfo.userNotes!,
                      style: TextStyle(
                        color: IosColors.label.withOpacity(0.92),
                        height: 1.45,
                        fontSize: 14.5,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(AppLocalizations l10n) {
    final String? raw = currentModInfo.customDescription ??
        currentModInfo.description;
    final bool hasDescription = raw != null && raw.trim().isNotEmpty;
    final bool hasCustomDescription =
        currentModInfo.customDescription != null &&
        currentModInfo.customDescription!.trim().isNotEmpty;

    return IosGroup(
      title: l10n.modDescription,
      icon: const HugeIcon(
        icon: HugeIcons.strokeRoundedBook04,
        color: IosColors.secondaryLabel,
        size: 15,
      ),
      actions: [
        if (hasCustomDescription)
          _restoreAction(
            onPressed: _restoreOriginalDescription,
            tooltip: l10n.restoreOriginalDescription,
          ),
        if (_showTranslateDescriptionButton)
          _translateAction(
            onPressed: _translateDescription,
            tooltip: l10n.translateDescription,
          ),
      ],
      child: IosCollapsible(
        enabled: hasDescription,
        collapsedHeight: 240,
        moreLabel: l10n.detailsShowMore,
        lessLabel: l10n.detailsShowLess,
        child: SizedBox(
          width: double.infinity,
          child: BBCodeRenderer(
            data: hasDescription ? raw : l10n.noDescriptionAvailable,
            defaultStyle: TextStyle(
              color: hasDescription
                  ? IosColors.label.withOpacity(0.92)
                  : IosColors.tertiaryLabel,
              height: 1.45,
              fontSize: 14.5,
              letterSpacing: -0.15,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  CABECERA, PORTADA Y TÍTULO
  // ---------------------------------------------------------------------------
  double _headerProgress(double offset) =>
      ((offset - 150) / 70).clamp(0.0, 1.0).toDouble();

  Widget _buildHeader(AppLocalizations l10n) {
    return SizedBox(
      height: 58,
      child: Stack(
        children: [
          // Asa de arrastre (grabber) de las hojas de iOS.
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0x4DEBEBF5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título compacto: aparece al desplazarse (barra de iOS).
                Expanded(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _scrollOffset,
                    builder: (context, offset, _) {
                      final double t = _headerProgress(offset);
                      return Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, (1 - t) * 6),
                          child: Text(
                            currentModInfo.customName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: IosColors.label,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IosToolbarButton(
                  width: 30,
                  height: 30,
                  tooltip: l10n.editButtonTooltip,
                  onPressed: _onGeneralEditPressed,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    size: 18,
                    color: IosColors.icon,
                  ),
                ),
                const SizedBox(width: 8),
                IosCloseButton(onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          // Filo inferior que aparece junto al título compacto.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (context, offset, _) => Opacity(
                opacity: _headerProgress(offset),
                child: Container(height: 0.5, color: const Color(0x24FFFFFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(String? mainImagePath, AppLocalizations l10n) {
    final int galleryCount = currentModInfo.gallery?.length ?? 0;

    // La portada ya NO es pulsable: el visor se abre solo con el botón de
    // pantalla completa (arriba a la derecha).
    // Se registra la portada para que el visor despegue desde su rectángulo.
    registerGalleryOrigin(currentModInfo.directory.path, _coverKey);
    return KeyedSubtree(
      key: _coverKey,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1FFFFFFF), width: 0.5),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fundido cruzado al cambiar la portada.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                child: SizedBox.expand(
                  key: ValueKey<String>(
                    '${mainImagePath ?? 'none'}|'
                    '${currentModInfo.customCoverLastModified?.millisecondsSinceEpoch}',
                  ),
                  child: mainImagePath != null
                      ? ModImage(
                          imageUrl: mainImagePath,
                          isLocal: !mainImagePath.startsWith('http'),
                          lastModified: currentModInfo.customCoverLastModified,
                          decodeToLayout: true,
                          placeholder: _coverPlaceholder(),
                        )
                      : const Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedPuzzle,
                            size: 64,
                            color: IosColors.tertiaryLabel,
                          ),
                        ),
                ),
              ),
              // Estado del mod (activado / desactivado).
              Positioned(
                top: 10,
                left: 10,
                child: _GlassPill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentModInfo.isEnabled
                              ? IosColors.green
                              : IosColors.gray,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentModInfo.isEnabled
                            ? l10n.detailsStatusEnabled
                            : l10n.detailsStatusDisabled,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.05,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón de pantalla completa: círculo de vidrio sobre la imagen.
              Positioned(
                top: 10,
                right: 10,
                // Sin BackdropFilter: desenfocar la imagen de detrás en cada
                // fotograma es muy caro; un fondo oscuro translúcido se ve igual.
                child: ClipOval(
                  child: IosToolbarButton(
                    width: 32,
                    height: 32,
                    background: const Color(0x8C000000),
                    onPressed: () => widget.onShowImageGallery(currentModInfo),
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedFullscreen,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ),
              // Número de imágenes de la galería.
              if (galleryCount > 1)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: _GlassPill(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$galleryCount',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    );
  }

  Widget _buildTitleBlock(
    AppLocalizations l10n,
    String? author,
    String displayVersion,
  ) {
    final (String typeLabel, Color typeColor) = _typeInfo(l10n);
    final bool hasEdition = currentModInfo.editionName?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentModInfo.customName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.15,
            color: IosColors.label,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (author?.isNotEmpty ?? false) ...[
          const SizedBox(height: 4),
          Text(
            l10n.byText(author!),
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: -0.1,
              color: IosColors.secondaryLabel,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (displayVersion.isNotEmpty)
              _MetaChip(
                label: _prettyVersion(displayVersion),
                color: IosColors.blue,
                tooltip: l10n.editVersionText,
                onTap: () => _editVersion(displayVersion, l10n),
              ),
            _MetaChip(
              label: typeLabel,
              color: typeColor,
              leading: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (hasEdition)
              _MetaChip(
                label: l10n.editionLabelValue(currentModInfo.editionName!),
                color: IosColors.purple,
                leading: const Icon(
                  Icons.layers_rounded,
                  size: 13,
                  color: IosColors.purple,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Aviso de actualización: aparece y desaparece con animación.
  Widget _buildUpdateBanner(AppLocalizations l10n, String displayVersion) {
    final bool show = widget.updateInfo != null && !_isIgnored;

    Widget? banner;
    if (show) {
      final String newVersion = widget.updateInfo!['version'].toString();
      banner = Padding(
        key: const ValueKey<String>('update-banner'),
        padding: const EdgeInsets.only(top: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            color: IosColors.yellow.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: IosColors.yellow.withOpacity(0.35),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: IosColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  size: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.updateAvailable(newVersion),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.15,
                        color: IosColors.label,
                      ),
                    ),
                    if (displayVersion.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${_prettyVersion(displayVersion)}  →  ${_prettyVersion(newVersion)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: IosColors.secondaryLabel,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IosPressable(
                scale: 0.94,
                onTap: _onUpdatePressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: IosColors.yellow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.detailsUpdateAction,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 340),
      curve: IosMotion.sheet,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child:
            banner ??
            const SizedBox(
              key: ValueKey<String>('no-update'),
              width: double.infinity,
            ),
      ),
    );
  }

  /// Fila de acciones rápidas (carpeta, enlace, endorse).
  Widget _buildQuickActions(AppLocalizations l10n, bool hasLink) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            label: l10n.showInFolder,
            iconBuilder: (c) => HugeIcon(
              icon: HugeIcons.strokeRoundedFolderOpen,
              size: 21,
              color: c,
            ),
            onTap: () => widget.onShowInExplorer(currentModInfo),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            label: hasLink ? l10n.openLinkButtonText : l10n.addLinkButtonText,
            tint: hasLink ? IosColors.blue : null,
            iconBuilder: (c) => HugeIcon(
              icon: HugeIcons.strokeRoundedLinkSquare02,
              size: 21,
              color: c,
            ),
            onTap: _onLinkPressed,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildEndorseTile(l10n)),
      ],
    );
  }

  /// Tercer botón: endorsar el mod en Nexus Mods.
  ///  * Atenuado (pero pulsable, para explicar el motivo) si el mod no es de
  ///    Nexus o no hay API key.
  ///  * Verde y relleno si ya está endorsado (al pulsar se ofrece quitarlo).
  ///  * Si no, es el pulgar normal: al pulsarlo se intenta y, si Nexus lo
  ///    rechaza (p. ej. por los 15 min tras la descarga), se avisa del motivo.
  Widget _buildEndorseTile(AppLocalizations l10n) {
    final bool endorsed = _isEndorsed;
    final bool unavailable = !_isNexusMod || !_hasApiKey;
    return _ActionTile(
      label: endorsed ? l10n.detailsEndorsed : l10n.detailsEndorse,
      tint: endorsed ? IosColors.green : null,
      dimmed: unavailable,
      busy: _endorseBusy,
      iconBuilder: (c) => Icon(
        endorsed ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
        size: 21,
        color: c,
      ),
      onTap: _onEndorsePressed,
    );
  }

  // ---------------------------------------------------------------------------
  //  TARJETA DE INFORMACIÓN (filas estilo Ajustes de iOS)
  // ---------------------------------------------------------------------------
  Widget _buildInformationGroup(
    AppLocalizations l10n,
    String? author,
    String displayVersion,
  ) {
    final (String typeLabel, Color typeColor) = _typeInfo(l10n);
    final String nexusId = currentModInfo.nexusId ?? '';
    final String folderName = p.basename(currentModInfo.directory.path);
    const Widget copyIcon = Icon(
      Icons.copy_rounded,
      size: 15,
      color: IosColors.tertiaryLabel,
    );

    final List<Widget> rows = [
      if (displayVersion.isNotEmpty)
        _InfoRow(
          label: l10n.modVersion,
          value: displayVersion,
          onTap: () => _editVersion(displayVersion, l10n),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: IosColors.tertiaryLabel,
          ),
        ),
      if (author?.isNotEmpty ?? false)
        _InfoRow(label: l10n.detailsRowAuthor, value: author!),
      _InfoRow(
        label: l10n.detailsRowType,
        valueWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                typeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: -0.15,
                  color: IosColors.secondaryLabel,
                ),
              ),
            ),
          ],
        ),
      ),
      if (currentModInfo.installDate != null)
        _InfoRow(
          label: l10n.detailsRowInstalled,
          value: _formatDate(currentModInfo.installDate!),
        ),
      _InfoRow(
        label: l10n.detailsRowModified,
        value: _formatDate(currentModInfo.lastModified),
      ),
      if (nexusId.isNotEmpty)
        _InfoRow(
          label: l10n.detailsRowNexusId,
          value: nexusId,
          onTap: () => _copy(nexusId),
          trailing: copyIcon,
        ),
      _InfoRow(
        label: l10n.detailsRowFolder,
        value: folderName,
        onTap: () => _copy(currentModInfo.directory.path),
        trailing: copyIcon,
      ),
    ];

    final List<Widget> spaced = [];
    for (int i = 0; i < rows.length; i++) {
      if (i > 0) {
        spaced.add(
          const Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 14,
            color: Color(0x1FFFFFFF),
          ),
        );
      }
      spaced.add(rows[i]);
    }

    return IosGroup(
      title: l10n.detailsInformation,
      icon: _sectionIcon(Icons.info_outline_rounded),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: spaced,
        ),
      ),
    );
  }

  Widget _buildOtherEditions(AppLocalizations l10n) {
    return IosGroup(
      title: l10n.otherEditionsTitle,
      icon: _sectionIcon(Icons.layers_outlined),
      child: Column(
        children: [
          for (final other in widget.otherEditions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: other.isEnabled
                          ? IosColors.green
                          : IosColors.tertiaryLabel,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      other.customName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        letterSpacing: -0.1,
                        color: IosColors.label,
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

  // ---------------------------------------------------------------------------
  //  SECCIÓN "REEMPLAZA EL TRAJE"
  // ---------------------------------------------------------------------------
  Widget _buildOutfitReplacementSection(AppLocalizations l10n) {
    final List<String> outfits = currentModInfo.replacesOutfits ?? const [];

    return IosGroup(
      title: l10n.replacesOutfitTitle,
      icon: const HugeIcon(
        icon: HugeIcons.strokeRoundedArrowReloadHorizontal,
        color: IosColors.secondaryLabel,
        size: 15,
      ),
      actions: [
        if (outfits.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: IosColors.chip,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IosCountText(
              text: l10n.outfitsCount(outfits.length),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: IosColors.secondaryLabel,
              ),
            ),
          ),
        IosToolbarButton(
          width: 28,
          height: 28,
          tooltip: l10n.replacesOutfitSelectTooltip,
          onPressed: _openOutfitPicker,
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedHanger,
            color: IosColors.blue,
            size: 17,
          ),
        ),
      ],
      child: AnimatedSize(
        duration: const Duration(milliseconds: 340),
        curve: IosMotion.sheet,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: outfits.isEmpty
              ? _buildEmptyOutfits(l10n)
              : _buildOutfitCarousel(l10n, outfits),
        ),
      ),
    );
  }

  Widget _buildEmptyOutfits(AppLocalizations l10n) {
    return SizedBox(
      key: const ValueKey<String>('outfits-empty'),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: IosColors.chip,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedHanger,
                  color: IosColors.secondaryLabel,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.replacesOutfitNone,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: IosColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 14),
            IosActionButton(
              label: l10n.outfitsChoose,
              style: IosButtonStyle.filled,
              iconBuilder: (c) => HugeIcon(
                icon: HugeIcons.strokeRoundedHanger,
                size: 18,
                color: c,
              ),
              onPressed: _openOutfitPicker,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitCarousel(AppLocalizations l10n, List<String> outfits) {
    return SizedBox(
      key: const ValueKey<String>('outfits-list'),
      height: 214,
      child: IosWheelToHorizontal(
        controller: _carouselScrollController,
        child: Scrollbar(
          controller: _carouselScrollController,
          thumbVisibility: true,
          thickness: 4,
          radius: const Radius.circular(10),
          child: ListView(
            controller: _carouselScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 14),
            children: [
              for (final outfit in outfits)
                IosPop(
                  key: ValueKey<String>('$outfit#$_outfitsRevision'),
                  child: _OutfitCard(
                    outfit: outfit,
                    removeTooltip: l10n.outfitsRemove,
                    onTap: _openOutfitPicker,
                    onRemove: () => _removeOutfit(outfit),
                  ),
                ),
              _AddOutfitTile(
                tooltip: l10n.replacesOutfitSelectTooltip,
                onTap: _openOutfitPicker,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool hasLink =
        (currentModInfo.customSourceUrl ?? currentModInfo.sourceUrl)
            ?.isNotEmpty ??
        false;
    final author = currentModInfo.customAuthor ?? currentModInfo.author;

    String? mainImagePath;
    // 1. Prioriza la portada personalizada (incluye '_nexus_cover.jpg' en caché).
    if (currentModInfo.customCoverPath != null &&
        currentModInfo.customCoverPath!.isNotEmpty) {
      mainImagePath = p.join(
        currentModInfo.directory.path,
        currentModInfo.customCoverPath!,
      );
      // 2. Si no hay, usa la imagen de la galería en internet.
    } else if (currentModInfo.gallery != null &&
        currentModInfo.gallery!.isNotEmpty) {
      mainImagePath = currentModInfo.gallery!.first['image'];
    }

    final String displayVersion =
        currentModInfo.customVersion ?? currentModInfo.localVersion ?? '';

    final bool summaryIsPlaceholder =
        (currentModInfo.customSummary ?? currentModInfo.summary) == null;

    final bool showReplacementBlock =
        currentModInfo.modType == 'genericPak' ||
        currentModInfo.modType == 'replacement' ||
        (currentModInfo.modType == null &&
            currentModInfo.replacesOutfits != null);

    // Cada sección entra con un pequeño retraso respecto a la anterior.
    int order = 0;
    Widget reveal(String id, Widget child) =>
        IosReveal(key: ValueKey<String>(id), index: order++, child: child);

    // Las secciones que se montan al terminar la animación de apertura llevan
    // su propio contador, para que su cascada empiece enseguida.
    int lateOrder = 0;
    Widget lateReveal(String id, Widget child) =>
        IosReveal(key: ValueKey<String>(id), index: lateOrder++, child: child);

    // El contenido se construye UNA vez por rebuild del estado (y no en cada
    // fotograma del arrastre de la hoja): Flutter reutiliza estos widgets.
    final List<Widget> sections = [
      reveal('cover', _buildCover(mainImagePath, l10n)),
      const SizedBox(height: 18),
      reveal('title', _buildTitleBlock(l10n, author, displayVersion)),
      _buildUpdateBanner(l10n, displayVersion),
      const SizedBox(height: 16),
      reveal('actions', _buildQuickActions(l10n, hasLink)),
      // Resto del contenido: se monta cuando termina la animación de apertura.
      if (_contentReady) ...[
      if (showReplacementBlock) ...[
        const SizedBox(height: 22),
        lateReveal(
          'replacement',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IosGroup(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: IosSwitchRow(
                  title: l10n.replacementModSwitchTitle,
                  subtitle: l10n.replacementModSwitchDesc,
                  value: _isReplacementMod,
                  onChanged: _onReplacementSwitchChanged,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 380),
                curve: IosMotion.sheet,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: _isReplacementMod
                      ? Padding(
                          key: const ValueKey<String>('outfit-section'),
                          padding: const EdgeInsets.only(top: 18),
                          child: _buildOutfitReplacementSection(l10n),
                        )
                      : const SizedBox(
                          key: ValueKey<String>('outfit-section-off'),
                          width: double.infinity,
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 22),
      lateReveal('info', _buildInformationGroup(l10n, author, displayVersion)),
      if (widget.otherEditions.isNotEmpty) ...[
        const SizedBox(height: 18),
        lateReveal('editions', _buildOtherEditions(l10n)),
      ],
      const SizedBox(height: 22),
      lateReveal(
        'summary',
        _buildInfoSection(
          l10n: l10n,
          title: l10n.modSummary,
          icon: _sectionIcon(Icons.description_outlined),
          content:
              currentModInfo.customSummary ??
              currentModInfo.summary ??
              l10n.noDescriptionAvailable,
          isPlaceholder: summaryIsPlaceholder,
          onTranslate: _showTranslateSummaryButton ? _translateSummary : null,
          translateTooltip: l10n.translateSummary,
          onEdit: () => _editSummary(l10n),
        ),
      ),
      const SizedBox(height: 18),
      lateReveal('notes', _buildNotesSection(l10n)),
      const SizedBox(height: 18),
      lateReveal('description', _buildDescriptionSection(l10n)),
      ],
    ];

    return DraggableScrollableSheet(
      // initial == max: con maxChildSize mayor, la primera vuelta de la rueda
      // agrandaba la hoja (re-maquetando todo su contenido) antes de desplazar.
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        // Mientras el visor de imágenes está abierto este panel queda tapado
        // por su fondo oscuro: se pausa el desenfoque (repetirlo en cada
        // fotograma estorbaba a la animación y al zoom). Al cerrar el visor
        // vuelve solo. El contenido (`child`) no se reconstruye.
        return ValueListenableBuilder<bool>(
          valueListenable: imageViewerActive,
          builder: (context, viewerOpen, child) => IosGlass(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            // Fondo de cristal original: desenfoque de 40 px y color
            // translúcido (86 %). Nota: el desenfoque es lo más caro de
            // pintar; si el scroll se resiente en algún equipo, pon blur: 0 y
            // color: 0xF21C1C1E.
            blur: 40,
            blurEnabled: !viewerOpen,
            color: const Color(0xDB1C1C1E),
            child: child!,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                _buildHeader(l10n),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.depth == 0 &&
                          notification.metrics.axis == Axis.vertical) {
                        // Más allá de 230 px el título compacto ya está
                        // completo: no hace falta notificar más cambios.
                        _scrollOffset.value = notification.metrics.pixels
                            .clamp(0.0, 230.0)
                            .toDouble();
                      }
                      return false;
                    },
                    // La guarda hace que la rueda también sea suave con el
                    // puntero encima de la barra de scroll.
                    child: IosSmoothScrollbarGuard(
                      controller: scrollController,
                      smoother: _wheelSmoother,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
                        // Rueda del ratón con desplazamiento suave.
                        child: IosSmoothWheel(
                          controller: scrollController,
                          smoother: _wheelSmoother,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: sections,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
//  WIDGETS INTERNOS DEL PANEL
// ============================================================================

/// Píldora oscura translúcida para colocar sobre la portada. (Sin desenfoque
/// de fondo: así la portada y el scroll del panel se mantienen fluidos.)
class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x8C000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

/// Chip tintado (versión, tipo, edición).
class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.color,
    this.leading,
    this.onTap,
    this.tooltip,
  });

  final String label;
  final Color color;
  final Widget? leading;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      chip = IosPressable(scale: 0.95, onTap: onTap, child: chip);
    }
    if (tooltip != null) {
      chip = Tooltip(message: tooltip!, child: chip);
    }
    return chip;
  }
}

/// Acción rápida: icono arriba y etiqueta debajo, en una tarjeta con rebote.
class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.label,
    required this.iconBuilder,
    required this.onTap,
    this.tint,
    this.dimmed = false,
    this.busy = false,
  });

  final String label;
  final Widget Function(Color color) iconBuilder;
  final VoidCallback onTap;
  final Color? tint;

  /// Aspecto atenuado (acción no disponible), pero sigue recibiendo pulsaciones.
  final bool dimmed;

  /// Sustituye el icono por una rueda de carga.
  final bool busy;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Color? tint = widget.tint;
    final Color fg = tint ?? IosColors.icon;
    final Color bg = tint != null
        ? tint.withOpacity(_hover ? 0.24 : 0.16)
        : (_hover ? IosColors.chipHover : IosColors.chip);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: widget.dimmed ? 0.45 : 1,
      child: IosPressable(
        scale: 0.95,
        onTap: widget.onTap,
        onHoverChanged: (value) => setState(() => _hover = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 68,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.busy
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: Center(child: IosSpinner()),
                    )
                  : widget.iconBuilder(fg),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.05,
                    color: tint ?? IosColors.secondaryLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de la tarjeta de información: etiqueta a la izquierda, valor a la
/// derecha. Si tiene [onTap] se resalta al pasar el cursor.
class _InfoRow extends StatefulWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  State<_InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<_InfoRow> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool tappable = widget.onTap != null;

    Color bg = Colors.transparent;
    if (tappable) {
      if (_pressed) {
        bg = const Color(0x24FFFFFF);
      } else if (_hover) {
        bg = const Color(0x0FFFFFFF);
      }
    }

    return MouseRegion(
      cursor: tappable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: tappable ? (_) => setState(() => _pressed = true) : null,
        onTapUp: tappable ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: tappable ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: -0.15,
                  color: IosColors.label,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child:
                      widget.valueWidget ??
                      Text(
                        widget.value ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.15,
                          color: IosColors.secondaryLabel,
                        ),
                      ),
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de un traje en el carrusel. Al pasar el cursor aparece una "x"
/// para quitarlo al instante; al quitarlo se encoge y desvanece.
class _OutfitCard extends StatefulWidget {
  const _OutfitCard({
    required this.outfit,
    required this.removeTooltip,
    required this.onTap,
    required this.onRemove,
  });

  final String outfit;
  final String removeTooltip;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<_OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends State<_OutfitCard> {
  static const double _cardWidth = 118;
  static const double _slotWidth = 128; // tarjeta + separación

  bool _hover = false;
  bool _gone = false;

  void _remove() {
    if (_gone) return;
    setState(() => _gone = true);
    Future<void>.delayed(const Duration(milliseconds: 240), () {
      if (mounted) widget.onRemove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInCubic,
      width: _gone ? 0 : _slotWidth,
      child: AnimatedOpacity(
        opacity: _gone ? 0 : 1,
        duration: const Duration(milliseconds: 180),
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: 0,
            maxWidth: _slotWidth,
            child: Padding(
              padding: const EdgeInsets.only(right: _slotWidth - _cardWidth),
              child: SizedBox(
                width: _cardWidth,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hover = true),
                  onExit: (_) => setState(() => _hover = false),
                  child: IosPressable(
                    scale: 0.96,
                    onTap: widget.onTap,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: IosColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0x1FFFFFFF),
                          width: 0.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: OutfitThumb(
                                  outfit: widget.outfit,
                                  cacheWidth: 300,
                                  iconSize: 26,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 7,
                                ),
                                color: const Color(0x33000000),
                                child: Tooltip(
                                  message: widget.outfit,
                                  child: Text(
                                    widget.outfit,
                                    style: const TextStyle(
                                      color: IosColors.secondaryLabel,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: AnimatedOpacity(
                              opacity: _hover ? 1 : 0,
                              duration: const Duration(milliseconds: 160),
                              child: IgnorePointer(
                                ignoring: !_hover,
                                child: Tooltip(
                                  message: widget.removeTooltip,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _remove,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Color(0x99000000),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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
      ),
    );
  }
}

/// Último elemento del carrusel: "+" para añadir más trajes.
class _AddOutfitTile extends StatelessWidget {
  const _AddOutfitTile({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IosPressable(
        scale: 0.95,
        onTap: onTap,
        child: Container(
          width: 84,
          decoration: BoxDecoration(
            color: IosColors.chip,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x1FFFFFFF), width: 0.5),
          ),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: IosColors.blue.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 21,
                color: IosColors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}