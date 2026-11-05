import 'package:flutter/material.dart';
import '../theme/description_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class BBCodeRenderer extends StatefulWidget {
  final String data;
  final TextStyle? defaultStyle;
  final Color? readabilityBackground;

  /// Si es true, los bloques se montan por tandas (unos cuantos por fotograma,
  /// de arriba abajo) en vez de todos de golpe. Una descripción larga con
  /// muchas imágenes y texto deja de bloquear el fotograma en que aparece.
  final bool progressive;

  const BBCodeRenderer({
    super.key, required this.data, this.defaultStyle,
    this.readabilityBackground,
    this.progressive = false,
  });

  @override
  State<BBCodeRenderer> createState() => _BBCodeRendererState();
}

class _BBCodeRendererState extends State<BBCodeRenderer> {
  // El análisis del BBCode (regex + construcción de widgets) es costoso. Antes
  // se repetía en CADA rebuild del panel (cada setState, cada cambio del
  // scroll...). Ahora se hace una vez y solo se repite si cambian el texto, el
  // estilo o el tema.
  List<Widget> _children = const [];
  bool _dirty = true;
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dirty = true;
  }

  @override
  void didUpdateWidget(covariant BBCodeRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.defaultStyle != widget.defaultStyle ||
        oldWidget.readabilityBackground != widget.readabilityBackground) {
      _dirty = true;
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  void _rebuildChildren() {
    _disposeRecognizers();

    final defaultTextStyle =
        widget.defaultStyle ??
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle();
    final decodedData = widget.data
        .replaceAll('&#92;', r'\')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&amp;', '&');

    final widgets = _parseBBCode(context, decodedData);

    _children = widgets.map((w) {
      if (w is RichText) {
        return DefaultTextStyle(style: defaultTextStyle, child: w);
      }
      return w;
    }).toList();
    _dirty = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_dirty) _rebuildChildren();
    return _ProgressiveColumn(
      enabled: widget.progressive,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _children,
    );
  }

  List<Widget> _parseBBCode(BuildContext context, String text) {
    final List<Widget> widgets = [];
    final regex = RegExp(
      r'(\[center\][\s\S]*?\[/center\]|\[left\][\s\S]*?\[/left\]|\[list(?:=1)?\][\s\S]*?\[/list\]|\[img\][\s\S]*?\[/img\])',
      caseSensitive: false,
    );

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final String matchText = match.group(0)!;
        final String lowerCaseMatch = matchText.toLowerCase();

        if (lowerCaseMatch.startsWith('[center]')) {
          final content = matchText.substring(8, matchText.length - 9);
          widgets.add(
            Center(
              child: _ProgressiveColumn(
                enabled: widget.progressive,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _parseBBCode(context, content),
              ),
            ),
          );
        } else if (lowerCaseMatch.startsWith('[left]')) {
          final content = matchText.substring(6, matchText.length - 7);
          widgets.add(
            Align(
              alignment: Alignment.centerLeft,
              child: _ProgressiveColumn(
                enabled: widget.progressive,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _parseBBCode(context, content),
              ),
            ),
          );
        } else if (lowerCaseMatch.startsWith('[list')) {
          final bool isOrdered = lowerCaseMatch.startsWith('[list=1]');
          final int startIndex = matchText.indexOf(']') + 1;
          final content = matchText.substring(startIndex, matchText.length - 7);
          widgets.add(_buildList(context, content, isOrdered: isOrdered));
        } else if (lowerCaseMatch.startsWith('[img]')) {
          final url = matchText.substring(5, matchText.length - 6).trim();
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.network(
                url,
                // Las imágenes de las descripciones suelen ser enormes: se
                // decodifican como mucho a 1280 px de ancho.
                cacheWidth: 1280,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                // Hueco reservado mientras carga, para que el texto de debajo
                // no salte de golpe al llegar la imagen.
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const SizedBox(height: 120),
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
          );
        }
        return '';
      },
      onNonMatch: (String text) {
        if (text.trim().isEmpty) return '';

        final itemParts = text.split(RegExp(r'\[\*\]', caseSensitive: false));

        if (itemParts.first.trim().isNotEmpty) {
          widgets.add(_buildRichText(context, itemParts.first));
        }

        if (itemParts.length > 1) {
          for (final itemText in itemParts.skip(1)) {
            if (itemText.trim().isNotEmpty) {
              widgets.add(_buildStandaloneListItem(context, itemText.trim()));
            }
          }
        }
        return '';
      },
    );

    return widgets;
  }

  Widget _buildList(BuildContext context, String content, {bool isOrdered = false}) {
    final items = content.split(RegExp(r'\[\*\]', caseSensitive: false));
    if (items.isEmpty) return const SizedBox.shrink();

    final validItems = items.where((item) => item.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: validItems.asMap().entries.map((entry) {
        final index = entry.key;
        final itemText = entry.value;
        final String bullet = isOrdered ? "${index + 1}." : "•";

        return Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                child: Text(
                  bullet,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _parseBBCode(context, itemText.trim()),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStandaloneListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0, top: 2.0),
            child: Text("•", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: _buildRichText(context, text)),
        ],
      ),
    );
  }

  Widget _buildRichText(BuildContext context, String text) {
    final List<TextSpan> spans = [];
    final List<TextStyle> styleStack = [const TextStyle()];
    final List<GestureRecognizer?> recognizerStack = [null];

    final regex = RegExp(
      r'\[\/?(b|u|i|s|color|size|url|font)(?:=([^\]]*))?\]',
      caseSensitive: false,
    );

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final tagName = match.group(1)?.toLowerCase();
        final tagValue = match.group(2);
        final isClosingTag = match.group(0)!.startsWith('[/');

        if (isClosingTag) {
          if (styleStack.length > 1) styleStack.removeLast();
          if (recognizerStack.length > 1) recognizerStack.removeLast();
        } else {
          TextStyle currentStyle = styleStack.last;
          GestureRecognizer? currentRecognizer = recognizerStack.last;

          switch (tagName) {
            case 'b':
              currentStyle = currentStyle.copyWith(fontWeight: FontWeight.bold);
              break;
            case 'u':
              currentStyle = currentStyle.copyWith(
                decoration: TextDecoration.underline,
              );
              break;
            case 'i':
              currentStyle = currentStyle.copyWith(fontStyle: FontStyle.italic);
              break;
            case 's':
              currentStyle = currentStyle.copyWith(
                decoration: TextDecoration.lineThrough,
              );
              break;
            case 'color':
              final color = _hexToColor(tagValue);
              if (color != null) {
                currentStyle = currentStyle.copyWith(
                  color: readableDescriptionColor(color, widget.readabilityBackground),
                );
              }
              break;
            case 'size':
              final fontSize = _sizeToFontSize(tagValue);
              if (fontSize != null) {
                currentStyle = currentStyle.copyWith(fontSize: fontSize);
              }
              break;
            case 'url':
              if (tagValue != null) {
                final recognizer = TapGestureRecognizer()
                  ..onTap = () async {
                    try {
                      final url = Uri.parse(tagValue);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    } catch (e) {
                      print('Could not launch URL $tagValue: $e');
                    }
                  };
                _recognizers.add(recognizer);
                currentRecognizer = recognizer;
                currentStyle = currentStyle.copyWith(
                  color: readableDescriptionColor(
                    Colors.lightBlueAccent, widget.readabilityBackground,
                  ),
                  decoration: TextDecoration.underline,
                );
              }
              break;
            case 'font':
              if (tagValue != null) {
                currentStyle = currentStyle.copyWith(
                  fontFamily: tagValue.replaceAll("'", "").replaceAll('"', ""),
                );
              }
              break;
          }
          styleStack.add(currentStyle);
          recognizerStack.add(currentRecognizer);
        }
        return '';
      },
      onNonMatch: (String text) {
        if (text.isNotEmpty) {
          spans.add(
            TextSpan(
              text: text,
              style: styleStack.last,
              recognizer: recognizerStack.last,
            ),
          );
        }
        return '';
      },
    );

    return RichText(
      text: TextSpan(
        children: spans,
        style: widget.defaultStyle ?? Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Color? _hexToColor(String? value) {
    if (value == null) return null;
    final text = value.trim().replaceAll('"', '').replaceAll("'", '').toLowerCase();
    const named = <String, Color>{
      'white': Colors.white,
      'black': Colors.black,
      'gray': Color(0xFF808080),
      'grey': Color(0xFF808080),
      'silver': Color(0xFFC0C0C0),
      'lightgray': Color(0xFFD3D3D3),
      'lightgrey': Color(0xFFD3D3D3),
      'whitesmoke': Color(0xFFF5F5F5),
      'ivory': Color(0xFFFFFFF0),
      'yellow': Color(0xFFFFFF00),
      'orange': Color(0xFFFFA500),
      'red': Color(0xFFFF0000),
      'green': Color(0xFF008000),
      'blue': Color(0xFF0000FF),
      'cyan': Color(0xFF00FFFF),
      'lightblue': Color(0xFFADD8E6),
      'pink': Color(0xFFFFC0CB),
      'purple': Color(0xFF800080),
    };
    if (named.containsKey(text)) return named[text];
    var hex = text.startsWith('#') ? text.substring(1) : text;
    if (hex.length == 3) hex = hex.split('').map((c) => c + c).join();
    if (!RegExp(r'^[0-9a-f]{6}$').hasMatch(hex)) return null;
    final rgb = int.tryParse(hex, radix: 16);
    return rgb == null ? null : Color(0xFF000000 | rgb);
  }

  double? _sizeToFontSize(String? size) {
    if (size == null) return null;
    final sizeNum = int.tryParse(size);
    if (sizeNum == null) return null;
    switch (sizeNum) {
      case 1: return 10.0;
      case 2: return 12.0;
      case 3: return 14.0;
      case 4: return 16.0;
      case 5: return 20.0;
      case 6: return 24.0;
      case 7: return 32.0;
      default: return 14.0;
    }
  }
}

/// Columna que, con [enabled], va añadiendo sus hijos por tandas: los primeros
/// al instante y el resto unos pocos por fotograma. Los hijos ya mostrados no
/// se tocan (se añade siempre por el final), así que el contenido de arriba
/// no se mueve mientras llega el de abajo.
class _ProgressiveColumn extends StatefulWidget {
  const _ProgressiveColumn({
    required this.children,
    required this.crossAxisAlignment,
    this.enabled = true,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final bool enabled;

  @override
  State<_ProgressiveColumn> createState() => _ProgressiveColumnState();
}

class _ProgressiveColumnState extends State<_ProgressiveColumn> {
  static const int _firstBatch = 3;
  static const int _batchSize = 3;

  late int _visible = widget.enabled
      ? (widget.children.length < _firstBatch
            ? widget.children.length
            : _firstBatch)
      : widget.children.length;
  bool _scheduled = false;

  void _scheduleMore() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final int total = widget.children.length;
      setState(() {
        final int next = _visible + _batchSize;
        _visible = next > total ? total : next;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final int total = widget.children.length;
    if (!widget.enabled || _visible >= total) {
      return Column(
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children,
      );
    }
    _scheduleMore();
    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: widget.children.sublist(0, _visible),
    );
  }
}