// lib/services/translation_service.dart
//
// Traducción de resumen y descripción de mods para TODOS los idiomas de la app
// (de, en, es, fr, it, ja, ko, pt, ru, zh) y cualquiera que se añada después.
//
// La descripción de Nexus está en BBCode ([img], [url=..], [list], [b]...).
// Si se manda tal cual a Google Translate, las etiquetas y las URLs salen
// rotas o traducidas. Por eso aquí se hace así:
//   1. El BBCode se parte en segmentos: etiquetas / bloques protegidos
//      ([img], [url]..[/url], [code], [youtube]...) / URLs sueltas (se dejan
//      intactos) y texto (lo único que se traduce).
//   2. Los textos se agrupan en lotes con un separador para minimizar
//      peticiones; si el separador no sobrevive, ese lote se traduce uno a uno.
//   3. Se vuelve a ensamblar respetando espacios y saltos de línea originales.

import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:translator/translator.dart';

class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  final GoogleTranslator _translator = GoogleTranslator();

  /// Máximo de caracteres por petición (el endpoint gratuito rechaza ~5000).
  static const int _maxChunkChars = 3500;
  static const String _sep = '\n§§§\n';
  static final RegExp _sepSplit = RegExp(r'\s*§\s*§\s*§\s*');
  static final RegExp _hasLetter = RegExp(r'\p{L}', unicode: true);

  // ---------------------------------------------------------------------------
  //  Códigos de idioma
  // ---------------------------------------------------------------------------

  /// Código que entiende Google Translate para el idioma de la app.
  static String googleCode(Locale locale) {
    final lang = locale.languageCode.toLowerCase();
    switch (lang) {
      case 'zh':
        final script = locale.scriptCode?.toLowerCase();
        final country = locale.countryCode?.toUpperCase();
        if (script == 'hant' ||
            country == 'TW' ||
            country == 'HK' ||
            country == 'MO') {
          return 'zh-tw';
        }
        return 'zh-cn';
      case 'he':
        return 'iw';
      case 'jv':
        return 'jw';
      case 'nb':
      case 'nn':
        return 'no';
      case 'fil':
        return 'tl';
      default:
        return lang;
    }
  }

  /// Idioma "base" comparable: 'zh-CN' → 'zh', 'pt_BR' → 'pt', 'iw' → 'he'.
  static String baseLanguage(String code) {
    final base = code.toLowerCase().split(RegExp(r'[-_]')).first;
    switch (base) {
      case 'iw':
        return 'he';
      case 'jw':
        return 'jv';
      case 'nb':
      case 'nn':
        return 'no';
      case 'fil':
        return 'tl';
      default:
        return base;
    }
  }

  // ---------------------------------------------------------------------------
  //  Detección
  // ---------------------------------------------------------------------------

  /// true si el texto está en un idioma distinto al de la app.
  /// Acepta texto plano o BBCode/HTML (se limpia antes de detectar).
  Future<bool> needsTranslation(String? text, Locale appLocale) async {
    if (text == null) return false;
    final sample = _detectionSample(text);
    if (sample == null) return false;

    final appBase = baseLanguage(appLocale.languageCode);
    // Google solo informa el idioma de origen cuando el destino es otro: si
    // el texto ya está en el idioma pivote devuelve 'auto'. Por eso se prueba
    // con 'de' y, si no concluye, con 'en'.
    for (final pivot in const ['de', 'en']) {
      try {
        final t = await _translateRaw(sample, to: pivot);
        final detected = baseLanguage(t.sourceLanguage.code);
        if (detected == 'auto' || detected == 'und' || detected.isEmpty) {
          continue;
        }
        return detected != appBase;
      } catch (e) {
        debugPrint('Error detectando el idioma (pivote $pivot): $e');
      }
    }
    return false;
  }

  /// Fragmento de texto "humano" (sin etiquetas ni URLs) para detectar idioma.
  static String? _detectionSample(String text) {
    var plain = _normalize(text)
        .replaceAll(_protectedPattern, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (_hasLetter.allMatches(plain).length < 8) return null;
    if (plain.length > 300) plain = plain.substring(0, 300);
    return plain;
  }

  // ---------------------------------------------------------------------------
  //  Traducción
  // ---------------------------------------------------------------------------

  /// Traduce texto plano (resumen). Conserva los saltos de línea.
  Future<String> translatePlain(String text, Locale target) async {
    final normalized = _normalize(text).trim();
    if (normalized.isEmpty) return normalized;
    final out = await _translateParts([normalized], googleCode(target));
    return _requireResult(out.first, normalized);
  }

  /// Traduce una descripción BBCode manteniendo intactas las etiquetas,
  /// imágenes, enlaces y URLs. Solo se traduce el texto.
  Future<String> translateBBCode(String text, Locale target) async {
    final normalized = _normalize(text);
    if (normalized.trim().isEmpty) return normalized;

    final segments = _tokenize(normalized);

    // Textos traducibles: se traduce solo el "núcleo" (sin espacios de los
    // bordes) y se reponen los espacios después.
    final cores = <String>[];
    final coreOwner = <int>[];
    final lead = <int, String>{};
    final trail = <int, String>{};
    for (var i = 0; i < segments.length; i++) {
      final s = segments[i];
      if (!s.translatable) continue;
      final m = RegExp(r'^(\s*)([\s\S]*?)(\s*)$').firstMatch(s.text)!;
      lead[i] = m.group(1)!;
      trail[i] = m.group(3)!;
      cores.add(m.group(2)!);
      coreOwner.add(i);
    }

    final translated = await _translateParts(cores, googleCode(target));

    final buf = StringBuffer();
    var k = 0;
    for (var i = 0; i < segments.length; i++) {
      final s = segments[i];
      if (s.translatable) {
        buf
          ..write(lead[i])
          ..write(translated[k++])
          ..write(trail[i]);
      } else {
        buf.write(s.text);
      }
    }
    return _requireResult(buf.toString(), normalized);
  }

  static String _requireResult(String result, String original) {
    if (result.trim().isEmpty) {
      throw StateError('Empty translation result');
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  //  BBCode: segmentación
  // ---------------------------------------------------------------------------

  /// Lo que NUNCA se traduce: bloques con contenido técnico, etiquetas sueltas
  /// y URLs.
  static final RegExp _protectedPattern = RegExp(
    r'\[(img|url|youtube|video|code|noparse|email|attachment)\][\s\S]*?\[/\1\]'
    r'|\[/?(?:b|i|u|s|strike|color|size|font|center|left|right|justify|list|'
    r'quote|spoiler|hr|line|heading|url|email|table|tr|td|th|indent|sub|sup|'
    r'highlight|\*)(?:=[^\]]*)?\]'
    r'|(?:https?://|www\.)[^\s\[\]<>"]+',
    caseSensitive: false,
  );

  static List<_Segment> _tokenize(String text) {
    final out = <_Segment>[];
    var last = 0;
    for (final m in _protectedPattern.allMatches(text)) {
      if (m.start > last) {
        out.add(_textSegment(text.substring(last, m.start)));
      }
      out.add(_Segment(m.group(0)!, false));
      last = m.end;
    }
    if (last < text.length) out.add(_textSegment(text.substring(last)));
    return out;
  }

  static _Segment _textSegment(String s) =>
      _Segment(s, _hasLetter.hasMatch(s));

  /// <br> → salto de línea, se quitan etiquetas HTML y se decodifican las
  /// entidades más comunes (igual que hace luego el BBCodeRenderer).
  static String _normalize(String s) {
    return s
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</?[a-zA-Z][^>]*>'), '')
        .replaceAll('&#92;', r'\')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&amp;', '&')
        .replaceAll('\r\n', '\n');
  }

  // ---------------------------------------------------------------------------
  //  Traducción por lotes
  // ---------------------------------------------------------------------------

  Future<List<String>> _translateParts(List<String> parts, String to) async {
    final result = List<String>.filled(parts.length, '');
    var i = 0;
    while (i < parts.length) {
      // Parte demasiado larga: se trocea por sí sola.
      if (parts[i].length > _maxChunkChars) {
        result[i] = await _translateLong(parts[i], to);
        i++;
        continue;
      }

      final batch = <int>[];
      var len = 0;
      while (i < parts.length && parts[i].length <= _maxChunkChars) {
        final l = parts[i].length + _sep.length;
        if (batch.isNotEmpty && len + l > _maxChunkChars) break;
        batch.add(i);
        len += l;
        i++;
      }

      if (batch.length == 1) {
        result[batch.first] = await _safeTranslate(parts[batch.first], to);
        continue;
      }

      String? joinedOut;
      try {
        joinedOut = (await _translateRaw(
          batch.map((b) => parts[b]).join(_sep),
          to: to,
        )).text;
      } catch (_) {
        joinedOut = null;
      }
      final pieces = joinedOut?.split(_sepSplit);
      if (pieces != null && pieces.length == batch.length) {
        for (var j = 0; j < batch.length; j++) {
          final p = pieces[j].trim();
          result[batch[j]] = p.isEmpty ? parts[batch[j]] : p;
        }
      } else {
        // El separador no sobrevivió: uno a uno.
        for (final b in batch) {
          result[b] = await _safeTranslate(parts[b], to);
        }
      }
    }
    return result;
  }

  /// Traduce un texto largo troceándolo por líneas (y por palabras si una
  /// línea sola supera el límite).
  Future<String> _translateLong(String text, String to) async {
    final chunks = <String>[];
    var current = StringBuffer();
    void flush() {
      if (current.isNotEmpty) chunks.add(current.toString());
      current = StringBuffer();
    }

    for (final line in text.split('\n')) {
      var rest = line;
      while (rest.length > _maxChunkChars) {
        var cut = rest.lastIndexOf(' ', _maxChunkChars);
        if (cut <= 0) cut = _maxChunkChars;
        flush();
        chunks.add(rest.substring(0, cut));
        rest = rest.substring(cut);
      }
      if (current.length + rest.length + 1 > _maxChunkChars) flush();
      if (current.isNotEmpty) current.write('\n');
      current.write(rest);
    }
    flush();

    final out = <String>[];
    for (final c in chunks) {
      out.add(await _safeTranslate(c, to));
    }
    return out.join('\n');
  }

  /// Si un trozo falla tras los reintentos, se lanza el error (no se guarda
  /// una traducción a medias).
  Future<String> _safeTranslate(String text, String to) async {
    if (text.trim().isEmpty) return text;
    return (await _translateRaw(text, to: to)).text;
  }

  Future<Translation> _translateRaw(String text, {required String to}) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await _translator
            .translate(text, from: 'auto', to: to)
            .timeout(const Duration(seconds: 20));
      } catch (e) {
        lastError = e;
        await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }
    }
    throw lastError ?? StateError('Translation failed');
  }
}

class _Segment {
  final String text;
  final bool translatable;
  const _Segment(this.text, this.translatable);
}