// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../models/mod_info.dart';
import '../../l10n/app_localizations.dart';
import '../theme/ios_theme.dart';
import '../widgets/ios_widgets.dart';
import '../widgets/mod_image_widgets.dart';

class EditDialogs {
  /// Libera un controlador una vez terminada la animación de salida del
  /// diálogo (el campo sigue montado unos milisegundos tras cerrarlo).
  static void _disposeLater(List<TextEditingController> controllers) {
    Future.delayed(const Duration(milliseconds: 400), () {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }

  /// Alerta de vidrio con un único campo de texto (nombre, versión, etiqueta…).
  static Future<String?> _showTextFieldDialog({
    required BuildContext context,
    required String title,
    required String label,
    required String initialValue,
    String? hint,
    String? defaultValue,
    int? maxLength,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final l10n = AppLocalizations.of(context)!;

    final result = await showIosDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return IosDialogShell(
              title: title,
              width: 380,
              content: IosFormField(
                label: label,
                controller: controller,
                hint: hint,
                autofocus: true,
                maxLength: maxLength,
                onChanged: (_) => setDialogState(() {}),
                onSubmitted: (v) => Navigator.of(dialogContext).pop(v),
                resetLabel: l10n.dialogActionResetToDefault,
                onReset: defaultValue == null
                    ? null
                    : () => setDialogState(() {
                        controller.text = defaultValue;
                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length),
                        );
                      }),
                canReset: controller.text != (defaultValue ?? ''),
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

    _disposeLater([controller]);
    return result;
  }

  static Future<String?> showEditModNameDialog(
    BuildContext context,
    ModInfo modInfo,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _showTextFieldDialog(
      context: context,
      title: l10n.dialogTitleEditModName,
      label: l10n.dialogLabelNewName,
      initialValue: modInfo.customName,
      hint: modInfo.customName,
      defaultValue: modInfo.displayName,
    );
  }

  static Future<ModInfo?> showEditDialog({
    required BuildContext context,
    required String title,
    required String label,
    required String initialValue,
    required String defaultValue,
    required Future<ModInfo?> Function(String) onSave,
    int? maxLength,
  }) async {
    final newValue = await _showTextFieldDialog(
      context: context,
      title: title,
      label: label,
      initialValue: initialValue,
      defaultValue: defaultValue,
      maxLength: maxLength,
    );

    if (newValue != null) {
      return await onSave(newValue);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> showGeneralEditDialog(
    ModInfo modInfo,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final nameController = TextEditingController(text: modInfo.customName);
    final authorController = TextEditingController(
      text: modInfo.customAuthor ?? modInfo.author ?? '',
    );
    final String defaultUrl = modInfo.sourceUrl ??
        (modInfo.nexusId != null
            ? 'https://www.nexusmods.com/stellarblade/mods/${modInfo.nexusId}'
            : '');
    final urlController = TextEditingController(
      text: modInfo.customSourceUrl ?? defaultUrl,
    );

    File? newCoverFile;
    Alignment? newCoverAlignment;

    final updatedData = await showIosDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final bool canResetName =
                nameController.text != modInfo.displayName;
            final bool canResetAuthor =
                authorController.text != (modInfo.author ?? '');
            final bool canResetUrl = urlController.text != defaultUrl;
            final double maxContentHeight =
                MediaQuery.of(ctx).size.height * 0.6;

            Map<String, dynamic> buildData({bool adjustCover = false}) {
              final Map<String, dynamic> dataToSave = {
                'customName': nameController.text,
                'author': authorController.text,
                'customSourceUrl': urlController.text,
              };
              if (newCoverFile != null) {
                dataToSave['newCoverFile'] = newCoverFile;
                dataToSave['newCoverAlignment'] = newCoverAlignment;
              }
              // El ajuste de la portada que ya tiene el mod lo hace quien
              // llama, después de guardar el resto de campos.
              if (adjustCover) dataToSave['adjustCover'] = true;
              return dataToSave;
            }

            return IosDialogShell(
              title: l10n.editModTitle,
              width: 520,
              content: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxContentHeight),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IosFormField(
                        label: l10n.modNameLabel,
                        controller: nameController,
                        onChanged: (_) => setDialogState(() {}),
                        resetLabel: l10n.dialogActionResetToDefault,
                        canReset: canResetName,
                        onReset: () => setDialogState(
                          () => nameController.text = modInfo.displayName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      IosFormField(
                        label: l10n.authorLabel,
                        controller: authorController,
                        onChanged: (_) => setDialogState(() {}),
                        resetLabel: l10n.dialogActionResetToDefault,
                        canReset: canResetAuthor,
                        onReset: () => setDialogState(
                          () => authorController.text = modInfo.author ?? '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      IosFormField(
                        label: l10n.urlLabel,
                        controller: urlController,
                        onChanged: (_) => setDialogState(() {}),
                        resetLabel: l10n.dialogActionResetToDefault,
                        canReset: canResetUrl,
                        onReset: () => setDialogState(
                          () => urlController.text = defaultUrl,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (newCoverFile != null) ...[
                        Container(
                          height: 110,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0x1FFFFFFF),
                              width: 0.5,
                            ),
                          ),
                          child: Image.file(newCoverFile!, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 10),
                      ],
                      IosActionButton(
                        label: l10n.changeCoverButton,
                        style: IosButtonStyle.gray,
                        iconBuilder: (c) => HugeIcon(
                          icon: HugeIcons.strokeRoundedImageAdd02,
                          size: 18,
                          color: c,
                        ),
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'png',
                                  'jpg',
                                  'jpeg',
                                  'webp',
                                  'bmp',
                                  'pwebp',
                                  'tiff',
                                ],
                              );
                          if (result != null &&
                              result.files.single.path != null) {
                            final pickedFile = File(result.files.single.path!);
                            final alignment = await showCoverAlignmentDialog(
                              ctx,
                              pickedFile,
                            );
                            if (alignment != null) {
                              setDialogState(() {
                                newCoverFile = pickedFile;
                                newCoverAlignment = alignment;
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      IosActionButton(
                        label: l10n.adjustCoverTooltip,
                        style: IosButtonStyle.gray,
                        iconBuilder: (c) => HugeIcon(
                          icon: HugeIcons.strokeRoundedCrop,
                          size: 18,
                          color: c,
                        ),
                        onPressed: () async {
                          if (newCoverFile != null) {
                            // Portada elegida en este mismo diálogo (aún sin
                            // guardar): se reajusta esa.
                            final alignment = await showCoverAlignmentDialog(
                              ctx,
                              newCoverFile!,
                              initialAlignment: newCoverAlignment,
                            );
                            if (alignment != null) {
                              setDialogState(() => newCoverAlignment = alignment);
                            }
                          } else {
                            // Portada que ya tiene el mod (la de Nexus o una
                            // personalizada): se guardan los campos y se abre
                            // el ajuste al cerrar este diálogo.
                            Navigator.of(dialogContext)
                                .pop(buildData(adjustCover: true));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IosDialogButton(
                  label: l10n.dialogActionCancel,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                IosDialogButton(
                  label: l10n.dialogActionSave,
                  bold: true,
                  onPressed: () => Navigator.of(dialogContext).pop(buildData()),
                ),
              ],
            );
          },
        );
      },
    );

    _disposeLater([nameController, authorController, urlController]);

    return updatedData;
  }

  // Medidas de la tarjeta de la cuadrícula (mod_grid_card + SliverGridDelegate):
  // ancho máximo 220, relación 3:4.5 y ~67 px de pie (nombre, etiqueta e
  // interruptor). La portada es lo que queda: así el marco del recorte tiene la
  // MISMA proporción que la portada real y no la de la tarjeta entera.
  static const double _cardRefWidth = 220;
  static const double _cardRefHeight = _cardRefWidth * 4.5 / 3;
  static const double _cardFooterHeight = 67;
  static const double _cardRadius = 14;
  static const double _coverAspectRatio =
      _cardRefWidth / (_cardRefHeight - _cardFooterHeight);

  static Future<Alignment?> showCoverAlignmentDialog(
    BuildContext context,
    File imageFile, {
    Alignment? initialAlignment,
  }) async {
    final image = await decodeImageFromList(imageFile.readAsBytesSync());
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final l10n = AppLocalizations.of(context)!;

    // Estado que sobrevive a las reconstrucciones del diálogo.
    Offset offset = Offset.zero;
    Size? scaledImageSize;
    double? cropWidth;
    double? cropHeight;
    // Posición de partida (portada ya ajustada): se convierte en desplazamiento
    // la primera vez que se conoce el tamaño del recuadro.
    Alignment? pendingInitial = initialAlignment;
    // Encuadre actual; alimenta la vista previa en vivo.
    final ValueNotifier<Alignment> previewAlignment =
        ValueNotifier<Alignment>(initialAlignment ?? Alignment.center);

    // Inverso de la conversión alineación -> desplazamiento.
    Alignment alignmentFromOffset() {
      if (scaledImageSize == null || cropWidth == null || cropHeight == null) {
        return previewAlignment.value;
      }
      final extraWidth = scaledImageSize!.width - cropWidth!;
      final extraHeight = scaledImageSize!.height - cropHeight!;
      final ax = extraWidth > 0.01 ? -offset.dx / (extraWidth / 2) : 0.0;
      final ay = extraHeight > 0.01 ? -offset.dy / (extraHeight / 2) : 0.0;
      return Alignment(ax.clamp(-1.0, 1.0), ay.clamp(-1.0, 1.0));
    }

    // Tarjeta en miniatura: la portada se pinta igual que en la cuadrícula
    // (BoxFit.cover + alignment), así se ve el resultado final al arrastrar.
    Widget buildPreview(double width) {
      final double scale = width / _cardRefWidth;
      return Container(
        width: width,
        height: _cardRefHeight * scale,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: IosColors.card,
          borderRadius: BorderRadius.circular(_cardRadius * scale + 2),
          border: Border.all(color: const Color(0x1FFFFFFF), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ValueListenableBuilder<Alignment>(
                valueListenable: previewAlignment,
                builder: (_, a, __) => ColoredBox(
                  color: const Color(0x59000000),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    alignment: a,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: _cardFooterHeight * scale,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12 * scale,
                  10 * scale,
                  12 * scale,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 5 * scale + 2,
                      width: width * 0.62,
                      decoration: BoxDecoration(
                        color: IosColors.tertiaryLabel,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Container(
                      height: 4 * scale + 2,
                      width: width * 0.34,
                      decoration: BoxDecoration(
                        color: IosColors.chip,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final result = await showIosDialog<Alignment>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            // El recuadro se adapta al tamaño de la ventana.
            final Size screen = MediaQuery.of(ctx).size;
            const double previewWidth = 132;
            const double gap = 16;
            final double boxWidth =
                min(440.0, max(240.0, screen.width - 120 - previewWidth - gap));
            final double boxHeight = min(560.0, max(260.0, screen.height * 0.6));

            return IosDialogShell(
              title: l10n.setCoverText,
              width: boxWidth + previewWidth + gap + 40,
              content: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: boxWidth,
                      height: boxHeight,
                      decoration: const BoxDecoration(color: Color(0xFF1C1C1E)),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final containerSize =
                              Size(constraints.maxWidth, constraints.maxHeight);
                          final fitted = applyBoxFit(
                            BoxFit.contain,
                            imageSize,
                            containerSize,
                          );
                          scaledImageSize = fitted.destination;

                          // Marco con la proporción de la portada real: el
                          // mayor posible dentro de la imagen.
                          if ((scaledImageSize!.width / scaledImageSize!.height) >
                              _coverAspectRatio) {
                            cropHeight = scaledImageSize!.height;
                            cropWidth = cropHeight! * _coverAspectRatio;
                          } else {
                            cropWidth = scaledImageSize!.width;
                            cropHeight = cropWidth! / _coverAspectRatio;
                          }

                          final cropRect = Rect.fromCenter(
                            center: containerSize.center(Offset.zero),
                            width: cropWidth!,
                            height: cropHeight!,
                          );

                          final initialImageRect = Alignment.center.inscribe(
                            scaledImageSize!,
                            Rect.fromLTWH(
                              0,
                              0,
                              containerSize.width,
                              containerSize.height,
                            ),
                          );

                          if (pendingInitial != null) {
                            offset = Offset(
                              -pendingInitial!.x *
                                  (scaledImageSize!.width - cropWidth!) /
                                  2,
                              -pendingInitial!.y *
                                  (scaledImageSize!.height - cropHeight!) /
                                  2,
                            );
                            pendingInitial = null;
                          }

                          final minDx = cropRect.right -
                              (initialImageRect.left + scaledImageSize!.width);
                          final maxDx = cropRect.left - initialImageRect.left;
                          final minDy = cropRect.bottom -
                              (initialImageRect.top + scaledImageSize!.height);
                          final maxDy = cropRect.top - initialImageRect.top;

                          return MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                offset = Offset(
                                  (offset.dx + details.delta.dx).clamp(
                                    min(minDx, maxDx),
                                    max(minDx, maxDx),
                                  ),
                                  (offset.dy + details.delta.dy).clamp(
                                    min(minDy, maxDy),
                                    max(minDy, maxDy),
                                  ),
                                );
                                previewAlignment.value = alignmentFromOffset();
                                setDialogState(() {});
                              },
                              child: ClipRect(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      left: initialImageRect.left + offset.dx,
                                      top: initialImageRect.top + offset.dy,
                                      width: scaledImageSize!.width,
                                      height: scaledImageSize!.height,
                                      child: Image.file(
                                        imageFile,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    IgnorePointer(
                                      child: CustomPaint(
                                        size: containerSize,
                                        painter: CropOverlayPainter(
                                          cropRect: cropRect,
                                          // Esquinas superiores como las de la
                                          // tarjeta; abajo la portada es recta.
                                          topRadius: _cardRadius *
                                              cropWidth! /
                                              _cardRefWidth,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: gap),
                  buildPreview(previewWidth),
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
                  onPressed: () {
                    if (scaledImageSize == null ||
                        cropWidth == null ||
                        cropHeight == null) {
                      return;
                    }
                    Navigator.of(dialogContext).pop(alignmentFromOffset());
                  },
                ),
              ],
            );
          },
        );
      },
    );
    // El diálogo sigue en pantalla durante su animación de salida.
    Future.delayed(const Duration(milliseconds: 400), previewAlignment.dispose);
    return result;
  }
}