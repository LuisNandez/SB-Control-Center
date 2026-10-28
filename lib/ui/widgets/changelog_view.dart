// lib/ui/widgets/changelog_view.dart
//
// Muestra el texto de un release de GitHub (Markdown de GitHub + HTML común)
// con el estilo de la app. Sin dependencias externas.
//
// Soporta: títulos (# y setext), negrita / cursiva / tachado, `código` y
// bloques de código, enlaces y URLs sueltas, imágenes (Markdown y <img>),
// listas anidadas y de tareas, citas y alertas ([!NOTE]...), tablas,
// separadores, <details>/<summary>, <br>, emojis :shortcode: y entidades HTML.
// Lo que no entiende se muestra como texto plano: nunca falla ni oculta nada.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/ios_theme.dart';

// ============================================================================
// 1) Normalización: convierte el HTML/emojis del release en Markdown limpio.
// ============================================================================

class ChangelogText {
  ChangelogText._();

  static const String _htmlTags =
      'p|div|span|a|img|b|i|u|s|em|strong|small|sup|sub|center|table|thead|'
      'tbody|tfoot|tr|td|th|ul|ol|li|details|summary|br|hr|h[1-6]|pre|code|'
      'kbd|blockquote|font|picture|source|video|section|article|figure|'
      'figcaption|mark|del|ins|strike|abbr|dl|dt|dd|tt|samp|var|cite|q|'
      'input|svg|path|g|iframe';

  static const Map<String, String> _emoji = {
    'sparkles': '✨', 'bug': '🐛', 'rocket': '🚀', 'tada': '🎉', 'fire': '🔥',
    'warning': '⚠️', 'white_check_mark': '✅', 'heavy_check_mark': '✔️',
    'x': '❌', 'memo': '📝', 'wrench': '🔧', 'hammer': '🔨', 'zap': '⚡',
    'lock': '🔒', 'package': '📦', 'art': '🎨', 'books': '📚', 'star': '⭐',
    'construction': '🚧', 'boom': '💥', 'lipstick': '💄', 'recycle': '♻️',
    'gear': '⚙️', 'arrow_up': '⬆️', 'arrow_down': '⬇️', 'bulb': '💡',
    'information_source': 'ℹ️', 'point_right': '👉', 'pushpin': '📌',
    'link': '🔗', 'globe_with_meridians': '🌐', 'speech_balloon': '💬',
    '+1': '👍', 'thumbsup': '👍', '-1': '👎', 'heart': '❤️', 'eyes': '👀',
    'mag': '🔍', 'hourglass': '⏳', 'wave': '👋', 'clap': '👏', 'pray': '🙏',
    'smile': '😄', 'tools': '🛠️', 'hammer_and_wrench': '🛠️', 'trophy': '🏆',
    'new': '🆕', 'lady_beetle': '🐞', 'chart_with_upwards_trend': '📈',
    'checkered_flag': '🏁', 'game_die': '🎲',
    'video_game': '🎮', 'file_folder': '📁', 'inbox_tray': '📥',
    'outbox_tray': '📤', 'twisted_rightwards_arrows': '🔀', 'fix': '🔧',
  };

  static String? _attr(String tag, String name) {
    final m = RegExp(
      '\\s$name\\s*=\\s*(?:"([^"]*)"|\'([^\']*)\'|([^\\s>]+))',
      caseSensitive: false,
    ).firstMatch(tag);
    if (m == null) return null;
    return m.group(1) ?? m.group(2) ?? m.group(3);
  }

  static String _inlineTag(String s, String tags, String mark) {
    return s.replaceAllMapped(
      RegExp('<($tags)\\b[^>]*>(.*?)</\\1>', caseSensitive: false, dotAll: true),
      (m) => '$mark${m.group(2)}$mark',
    );
  }

  static String normalize(String raw) {
    var s = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Lo que hay dentro de bloques o fragmentos de código no se toca.
    final protected = <String>[];
    String protect(String v) {
      protected.add(v);
      return '\uE000${protected.length - 1}\uE001';
    }

    s = s.replaceAllMapped(
      RegExp(r'^[ \t]*(```|~~~)[^\n]*\n.*?^[ \t]*\1[ \t]*$',
          multiLine: true, dotAll: true),
      (m) => protect(m.group(0)!),
    );
    s = s.replaceAllMapped(RegExp(r'`[^`\n]+`'), (m) => protect(m.group(0)!));

    // Comentarios HTML.
    s = s.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');

    // <img ...>  ->  ![alt](src)
    s = s.replaceAllMapped(RegExp(r'<img\b[^>]*>', caseSensitive: false), (m) {
      final tag = m.group(0)!;
      var src = (_attr(tag, 'src') ?? '').trim();
      if (src.isEmpty) return '';
      src = src.replaceAll(' ', '%20').replaceAll(')', '%29');
      final alt = (_attr(tag, 'alt') ?? '').replaceAll(RegExp(r'[\[\]]'), '');
      return '\n![$alt]($src)\n';
    });

    // <a href="...">texto</a>  ->  [texto](url)
    s = s.replaceAllMapped(
      RegExp(r'''<a\b[^>]*?href\s*=\s*["']([^"']*)["'][^>]*>(.*?)</a>''',
          caseSensitive: false, dotAll: true),
      (m) {
        final href = m.group(1)!.trim();
        final text = m.group(2)!.trim();
        if (text.contains('![')) return text;
        return '[${text.isEmpty ? href : text}]($href)';
      },
    );

    // [![alt](img)](enlace)  ->  ![alt](img)   (insignias)
    s = s.replaceAllMapped(
      RegExp(r'\[\s*(!\[[^\]]*\]\([^)]*\))\s*\]\([^)]*\)'),
      (m) => m.group(1)!,
    );

    // Títulos, <summary>, saltos, listas y bloques.
    s = s.replaceAllMapped(
      RegExp(r'<h([1-6])\b[^>]*>(.*?)</h\1>', caseSensitive: false, dotAll: true),
      (m) => '\n${'#' * int.parse(m.group(1)!)} ${m.group(2)!.trim()}\n',
    );
    s = s.replaceAllMapped(
      RegExp(r'<summary\b[^>]*>(.*?)</summary>',
          caseSensitive: false, dotAll: true),
      (m) => '\n**${m.group(1)!.trim()}**\n',
    );
    s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'<hr\s*/?>', caseSensitive: false), '\n---\n');
    s = s.replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '\n- ');
    s = s.replaceAll(RegExp(r'</t[dh]>', caseSensitive: false), '   ');
    s = s.replaceAll(
      RegExp(
        r'</(?:p|div|details|ul|ol|li|table|tr|blockquote|center|section|article|figure)>',
        caseSensitive: false,
      ),
      '\n',
    );

    // Formato en línea.
    s = _inlineTag(s, 'b|strong', '**');
    s = _inlineTag(s, 'i|em', '*');
    s = _inlineTag(s, 's|strike|del', '~~');
    s = _inlineTag(s, 'code|kbd|tt', '`');

    // Cualquier otra etiqueta HTML conocida se descarta (el texto se conserva).
    s = s.replaceAll(
      RegExp('</?(?:$_htmlTags)\\b[^<>]*>', caseSensitive: false),
      '',
    );

    // Entidades HTML.
    s = s.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      final code = int.tryParse(m.group(1)!);
      return code == null ? m.group(0)! : String.fromCharCode(code);
    });
    s = s.replaceAllMapped(RegExp(r'&#[xX]([0-9a-fA-F]+);'), (m) {
      final code = int.tryParse(m.group(1)!, radix: 16);
      return code == null ? m.group(0)! : String.fromCharCode(code);
    });
    s = s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');

    // Emojis :shortcode:
    s = s.replaceAllMapped(
      RegExp(r':([a-z0-9_+\-]+):'),
      (m) => _emoji[m.group(1)!] ?? m.group(0)!,
    );

    // Devuelve el código protegido.
    s = s.replaceAllMapped(
      RegExp('\uE000(\\d+)\uE001'),
      (m) => protected[int.parse(m.group(1)!)],
    );
    return s.trim();
  }
}

// ============================================================================
// 2) Widget
// ============================================================================

class ChangelogView extends StatefulWidget {
  const ChangelogView({
    super.key,
    required this.markdown,
    this.emptyText = '',
  });

  final String markdown;
  final String emptyText;

  @override
  State<ChangelogView> createState() => _ChangelogViewState();
}

class _ChangelogViewState extends State<ChangelogView> {
  _ChangelogBuilder? _builder;
  List<Widget> _blocks = const <Widget>[];

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void didUpdateWidget(covariant ChangelogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markdown != widget.markdown) _rebuild();
  }

  void _rebuild() {
    _builder?.dispose();
    final b = _ChangelogBuilder();
    List<Widget> blocks;
    try {
      blocks = b.build(widget.markdown);
    } catch (_) {
      // Si algo inesperado rompe el análisis, se muestra el texto tal cual.
      blocks = <Widget>[
        Text(widget.markdown, style: _ChangelogBuilder._body),
      ];
    }
    _builder = b;
    _blocks = blocks;
  }

  @override
  void dispose() {
    _builder?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_blocks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          widget.emptyText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: IosColors.secondaryLabel),
        ),
      );
    }
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _blocks,
      ),
    );
  }
}

// ============================================================================
// 3) Análisis y construcción de widgets
// ============================================================================

class _ListItem {
  _ListItem(this.indent, this.ordered, this.marker, this.text, this.task);
  final int indent;
  final bool ordered;
  final String marker;
  String text;
  final bool? task;
  int level = 0;
}

class _ChangelogBuilder {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  static const TextStyle _body =
      TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFFE5E5EA));
  static const TextStyle _mono = TextStyle(
    fontSize: 12.5,
    height: 1.4,
    color: Color(0xFFE5E5EA),
    fontFamily: 'Consolas',
    fontFamilyFallback: <String>['Cascadia Mono', 'Courier New', 'monospace'],
  );
  static const List<String> _bullets = <String>['•', '◦', '▪'];

  static final RegExp _fenceRe = RegExp(r'^\s*(```+|~~~+)');
  static final RegExp _setextRe = RegExp(r'^\s{0,3}(=+|-{2,})\s*$');
  static final RegExp _headingRe =
      RegExp(r'^\s{0,3}(#{1,6})\s+(.+?)(?:\s+#+)?\s*$');
  static final RegExp _hrRe = RegExp(r'^\s{0,3}([-*_])(?:\s*\1){2,}\s*$');
  static final RegExp _tableSepRe =
      RegExp(r'^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?\s*$');
  static final RegExp _itemRe =
      RegExp(r'^([ \t]*)([-*+]|\d{1,9}[.)])[ \t]+(.*)$');
  static final RegExp _taskRe = RegExp(r'^\[([ xX])\][ \t]+(.*)$', dotAll: true);
  static final RegExp _alertRe = RegExp(
    r'^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*$',
    caseSensitive: false,
  );
  static final RegExp _imgRe =
      RegExp(r'!\[([^\]]*)\]\(\s*<?([^)\s>]+)>?(?:\s+"[^"]*")?\s*\)');
  static final RegExp _linkRe = RegExp(
    r'\[((?:[^\[\]]|\[[^\]]*\])*)\]\(\s*<?([^)\s>]+)>?(?:\s+"[^"]*")?\s*\)',
  );
  static final RegExp _autoRe = RegExp(r'<(https?://[^>\s]+)>');
  static final RegExp _urlRe = RegExp(r'https?://[^\s<>\])"]+');
  static final RegExp _wordRe = RegExp(r'[A-Za-z0-9]');
  static const String _escapable = '\\`*_{}[]()#+-.!|~<>';

  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  List<Widget> build(String markdown) {
    final text = ChangelogText.normalize(markdown);
    if (text.isEmpty) return <Widget>[];
    return _blocks(text.split('\n'));
  }

  bool _isWord(String ch) => _wordRe.hasMatch(ch);

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    if (uri.scheme != 'http' && uri.scheme != 'https' && uri.scheme != 'mailto') {
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // ------------------------------------------------------------------ bloques

  List<Widget> _blocks(List<String> lines) {
    final out = <Widget>[];
    final para = <String>[];
    var i = 0;

    void flushPara() {
      if (para.isEmpty) return;
      out.add(_paragraph(para));
      para.clear();
    }

    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        flushPara();
        i++;
        continue;
      }

      // Bloque de código.
      final fence = _fenceRe.firstMatch(line);
      if (fence != null) {
        flushPara();
        final marker = fence.group(1)!;
        final code = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith(marker)) {
          code.add(lines[i]);
          i++;
        }
        i++; // línea de cierre
        out.add(_codeBlock(code.join('\n')));
        continue;
      }

      // Título con subrayado (Título\n=====  /  Título\n-----).
      if (para.isNotEmpty) {
        final sm = _setextRe.firstMatch(line);
        if (sm != null) {
          final level = sm.group(1)!.startsWith('=') ? 1 : 2;
          final text = para.map((e) => e.trim()).join(' ');
          para.clear();
          out.add(_heading(level, text));
          i++;
          continue;
        }
      }

      // Título #.
      final hm = _headingRe.firstMatch(line);
      if (hm != null) {
        flushPara();
        out.add(_heading(hm.group(1)!.length, hm.group(2)!));
        i++;
        continue;
      }

      // Separador.
      if (_hrRe.hasMatch(line)) {
        flushPara();
        out.add(_rule());
        i++;
        continue;
      }

      // Cita / alerta.
      if (trimmed.startsWith('>')) {
        flushPara();
        final q = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('>')) {
          q.add(lines[i].trim().replaceFirst(RegExp(r'^>\s?'), ''));
          i++;
        }
        out.add(_quote(q));
        continue;
      }

      // Tabla.
      if (trimmed.contains('|') &&
          i + 1 < lines.length &&
          lines[i + 1].contains('|') &&
          _tableSepRe.hasMatch(lines[i + 1])) {
        flushPara();
        final header = _cells(line);
        final sep = _cells(lines[i + 1]);
        final aligns = <TextAlign>[
          for (int c = 0; c < header.length; c++)
            c < sep.length ? _alignOf(sep[c]) : TextAlign.start,
        ];
        i += 2;
        final rows = <List<String>>[];
        while (i < lines.length &&
            lines[i].trim().isNotEmpty &&
            lines[i].contains('|')) {
          rows.add(_cells(lines[i]));
          i++;
        }
        out.add(_table(header, rows, aligns));
        continue;
      }

      // Lista.
      if (_parseItem(line) != null) {
        flushPara();
        final items = <_ListItem>[];
        while (i < lines.length) {
          final l = lines[i];
          if (l.trim().isEmpty) {
            var j = i + 1;
            while (j < lines.length && lines[j].trim().isEmpty) {
              j++;
            }
            if (j < lines.length &&
                (_parseItem(lines[j]) != null ||
                    (items.isNotEmpty &&
                        (lines[j].startsWith('  ') ||
                            lines[j].startsWith('\t'))))) {
              i = j;
              continue;
            }
            break;
          }
          final it = _parseItem(l);
          if (it != null) {
            items.add(it);
            i++;
            continue;
          }
          if (items.isNotEmpty && (l.startsWith('  ') || l.startsWith('\t'))) {
            items.last.text = '${items.last.text}\n${l.trim()}';
            i++;
            continue;
          }
          break;
        }
        out.add(_list(items));
        continue;
      }

      // Párrafo.
      para.add(line);
      i++;
    }
    flushPara();
    return out;
  }

  _ListItem? _parseItem(String line) {
    final m = _itemRe.firstMatch(line);
    if (m == null) return null;
    var indent = 0;
    for (final ch in m.group(1)!.split('')) {
      indent += ch == '\t' ? 4 : 1;
    }
    final marker = m.group(2)!;
    var text = m.group(3)!;
    bool? task;
    final t = _taskRe.firstMatch(text);
    if (t != null) {
      task = t.group(1) != ' ';
      text = t.group(2)!;
    }
    return _ListItem(indent, RegExp(r'\d').hasMatch(marker), marker, text, task);
  }

  List<String> _cells(String line) {
    var t = line.trim().replaceAll(r'\|', '\uE002');
    if (t.startsWith('|')) t = t.substring(1);
    if (t.endsWith('|')) t = t.substring(0, t.length - 1);
    return t.split('|').map((c) => c.replaceAll('\uE002', '|').trim()).toList();
  }

  TextAlign _alignOf(String sepCell) {
    final c = sepCell.trim();
    if (c.startsWith(':') && c.endsWith(':')) return TextAlign.center;
    if (c.endsWith(':')) return TextAlign.end;
    return TextAlign.start;
  }

  // ------------------------------------------------------------------ widgets

  Widget _rich(String text, TextStyle style, {TextAlign align = TextAlign.start}) {
    return Text.rich(
      TextSpan(style: style, children: _inline(text, style)),
      textAlign: align,
    );
  }

  Widget _heading(int level, String text) {
    const sizes = <double>[0, 20, 17, 15, 14, 13.5, 13.5];
    final style = TextStyle(
      fontSize: sizes[level],
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: level >= 5 ? IosColors.secondaryLabel : IosColors.label,
    );
    return Padding(
      padding: EdgeInsets.only(top: level <= 2 ? 12 : 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rich(text, style),
          if (level <= 2) ...[
            const SizedBox(height: 6),
            Container(height: 0.5, color: IosColors.separator),
          ],
        ],
      ),
    );
  }

  Widget _rule() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(height: 0.5, color: IosColors.separator),
      );

  Widget _paragraph(List<String> lines) {
    final children = <Widget>[];
    final buf = <String>[];

    void flush() {
      if (buf.isEmpty) return;
      children.add(_rich(buf.join('\n'), _body));
      buf.clear();
    }

    for (final raw in lines) {
      final line = raw.trim();
      final imgs = _imageOnly(line);
      if (imgs != null) {
        flush();
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final im in imgs) _networkImage(im[1], im[0])],
            ),
          ),
        );
      } else {
        buf.add(line);
      }
    }
    flush();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  List<List<String>>? _imageOnly(String line) {
    final matches = _imgRe.allMatches(line).toList();
    if (matches.isEmpty) return null;
    if (line.replaceAll(_imgRe, '').trim().isNotEmpty) return null;
    return [
      for (final m in matches) [m.group(1)!, m.group(2)!],
    ];
  }

  Widget _codeBlock(String code) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0x4D000000),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: IosColors.separator, width: 0.8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(code, style: _mono),
        ),
      ),
    );
  }

  Widget _quote(List<String> q) {
    var color = IosColors.gray;
    String? label;
    var lines = q;
    if (q.isNotEmpty) {
      final m = _alertRe.firstMatch(q.first.trim());
      if (m != null) {
        final kind = m.group(1)!.toUpperCase();
        label = kind[0] + kind.substring(1).toLowerCase();
        switch (kind) {
          case 'NOTE':
            color = IosColors.blue;
            break;
          case 'TIP':
            color = IosColors.green;
            break;
          case 'IMPORTANT':
            color = IosColors.purple;
            break;
          case 'WARNING':
            color = IosColors.orange;
            break;
          default:
            color = IosColors.red;
        }
        lines = q.sublist(1);
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 0),
        decoration: BoxDecoration(
          color: color.withAlpha(22),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ..._blocks(lines),
          ],
        ),
      ),
    );
  }

  Widget _table(
    List<String> header,
    List<List<String>> rows,
    List<TextAlign> aligns,
  ) {
    final cols = header.length;
    TableRow row(List<String> cells, {bool head = false}) {
      return TableRow(
        decoration: head ? const BoxDecoration(color: Color(0x14FFFFFF)) : null,
        children: [
          for (int c = 0; c < cols; c++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: _rich(
                c < cells.length ? cells[c] : '',
                head ? _body.copyWith(fontWeight: FontWeight.w700) : _body,
                align: aligns[c],
              ),
            ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Table(
        border: TableBorder.all(color: IosColors.separator, width: 0.8),
        defaultColumnWidth: const FlexColumnWidth(),
        children: [
          row(header, head: true),
          for (final r in rows) row(r),
        ],
      ),
    );
  }

  Widget _list(List<_ListItem> items) {
    final stack = <int>[];
    for (final it in items) {
      while (stack.isNotEmpty && stack.last > it.indent) {
        stack.removeLast();
      }
      if (stack.isEmpty || stack.last < it.indent) stack.add(it.indent);
      it.level = stack.length - 1;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final it in items) _listRow(it)],
      ),
    );
  }

  Widget _listRow(_ListItem it) {
    final Widget marker;
    if (it.task != null) {
      marker = Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(
          it.task! ? Icons.check_box : Icons.check_box_outline_blank,
          size: 16,
          color: it.task! ? IosColors.blue : IosColors.secondaryLabel,
        ),
      );
    } else if (it.ordered) {
      marker = Text(
        it.marker,
        style: _body.copyWith(color: IosColors.secondaryLabel),
      );
    } else {
      marker = Text(
        _bullets[it.level % _bullets.length],
        style: _body.copyWith(color: IosColors.secondaryLabel),
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: 4.0 + it.level * 20, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: it.ordered ? 26 : 18, child: marker),
          Expanded(child: _rich(it.text, _body)),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- imágenes

  Widget _fallbackLink(String label, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _open(url),
        child: Text(label, style: _body.copyWith(color: IosColors.blue)),
      ),
    );
  }

  Widget _networkImage(String url, String alt, {bool inline = false}) {
    final uri = Uri.tryParse(url);
    final okScheme =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!okScheme) {
      return Text(
        alt.isEmpty ? url : alt,
        style: _body.copyWith(color: IosColors.secondaryLabel),
      );
    }
    final image = Image.network(
      url,
      fit: BoxFit.contain,
      height: inline ? 18 : null,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: inline ? 24 : 160,
          height: inline ? 18 : 90,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (ctx, err, stack) =>
          _fallbackLink(alt.isEmpty ? url : alt, url),
    );
    if (inline) return image;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _open(url),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: image,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- inline

  InlineSpan _linkSpan(String label, String url, TextStyle style) {
    final r = TapGestureRecognizer()..onTap = () => _open(url);
    _recognizers.add(r);
    return TextSpan(
      text: label,
      recognizer: r,
      mouseCursor: SystemMouseCursors.click,
      style: style.copyWith(color: IosColors.blue),
    );
  }

  int _findClose(String s, String d, int from) {
    var idx = s.indexOf(d, from);
    while (idx != -1) {
      final before = idx > 0 ? s[idx - 1] : ' ';
      final afterIdx = idx + d.length;
      final after = afterIdx < s.length ? s[afterIdx] : ' ';
      var ok = before != ' ' && before != '\n';
      if (ok && d.startsWith('_')) ok = !_isWord(after);
      if (ok && d == '*') ok = before != '*' && after != '*';
      if (ok) return idx;
      idx = s.indexOf(d, idx + 1);
    }
    return -1;
  }

  List<InlineSpan> _inline(String s, TextStyle style, {GestureRecognizer? rec}) {
    final spans = <InlineSpan>[];
    final buf = StringBuffer();

    void flush() {
      if (buf.isEmpty) return;
      spans.add(TextSpan(text: buf.toString(), style: style, recognizer: rec));
      buf.clear();
    }

    var i = 0;
    while (i < s.length) {
      final c = s[i];

      // Escape con barra invertida.
      if (c == '\\' && i + 1 < s.length && _escapable.contains(s[i + 1])) {
        buf.write(s[i + 1]);
        i += 2;
        continue;
      }

      // `código`
      if (c == '`') {
        final end = s.indexOf('`', i + 1);
        if (end > i + 1) {
          flush();
          spans.add(
            TextSpan(
              text: s.substring(i + 1, end),
              recognizer: rec,
              style: style.copyWith(
                fontFamily: 'Consolas',
                fontFamilyFallback: const <String>[
                  'Cascadia Mono',
                  'Courier New',
                  'monospace',
                ],
                fontSize: (style.fontSize ?? 13.5) - 0.5,
                backgroundColor: const Color(0x2EFFFFFF),
                color: const Color(0xFFF2C07B),
              ),
            ),
          );
          i = end + 1;
          continue;
        }
      }

      // ![alt](url)
      if (c == '!' && i + 1 < s.length && s[i + 1] == '[') {
        final m = _imgRe.matchAsPrefix(s, i);
        if (m != null) {
          flush();
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _networkImage(m.group(2)!, m.group(1)!, inline: true),
            ),
          );
          i = m.end;
          continue;
        }
      }

      // [texto](url)
      if (c == '[') {
        final m = _linkRe.matchAsPrefix(s, i);
        if (m != null) {
          flush();
          final url = m.group(2)!;
          final r = TapGestureRecognizer()..onTap = () => _open(url);
          _recognizers.add(r);
          spans.addAll(
            _inline(
              m.group(1)!,
              style.copyWith(color: IosColors.blue),
              rec: r,
            ),
          );
          i = m.end;
          continue;
        }
      }

      // <https://...>
      if (c == '<') {
        final m = _autoRe.matchAsPrefix(s, i);
        if (m != null) {
          flush();
          spans.add(_linkSpan(m.group(1)!, m.group(1)!, style));
          i = m.end;
          continue;
        }
      }

      // URL suelta.
      if (c == 'h' &&
          (i == 0 || !_isWord(s[i - 1])) &&
          (s.startsWith('http://', i) || s.startsWith('https://', i))) {
        final m = _urlRe.matchAsPrefix(s, i);
        if (m != null) {
          var url = m.group(0)!;
          while (url.isNotEmpty && '.,;:!?'.contains(url[url.length - 1])) {
            url = url.substring(0, url.length - 1);
          }
          if (url.length > 8) {
            flush();
            spans.add(_linkSpan(url, url, style));
            i += url.length;
            continue;
          }
        }
      }

      // Negrita / cursiva / tachado.
      if (c == '*' || c == '_' || c == '~') {
        var d = '';
        if (s.startsWith('***', i)) {
          d = '***';
        } else if (s.startsWith('**', i)) {
          d = '**';
        } else if (s.startsWith('__', i)) {
          d = '__';
        } else if (s.startsWith('~~', i)) {
          d = '~~';
        } else if (c == '*' || c == '_') {
          d = c;
        }
        if (d.isNotEmpty) {
          final afterOpen = i + d.length;
          final openOk = afterOpen < s.length &&
              s[afterOpen] != ' ' &&
              s[afterOpen] != '\n' &&
              (!d.startsWith('_') || i == 0 || !_isWord(s[i - 1]));
          if (openOk) {
            final end = _findClose(s, d, afterOpen);
            if (end > afterOpen) {
              flush();
              final inner = s.substring(afterOpen, end);
              TextStyle st;
              if (d == '***') {
                st = style.copyWith(
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                );
              } else if (d == '**' || d == '__') {
                st = style.copyWith(fontWeight: FontWeight.w700);
              } else if (d == '~~') {
                st = style.copyWith(decoration: TextDecoration.lineThrough);
              } else {
                st = style.copyWith(fontStyle: FontStyle.italic);
              }
              spans.addAll(_inline(inner, st, rec: rec));
              i = end + d.length;
              continue;
            }
          }
        }
      }

      buf.write(c);
      i++;
    }
    flush();
    return spans;
  }
}
