// lib/ui/widgets/ui_scale_settings.dart
//
// Secciones de Ajustes → Apariencia para ajustar:
//   * Tamaño de letra de la interfaz.
//   * Tamaño de las tarjetas de mods (cuadrícula y lista).
//
// El valor se aplica al soltar el deslizador (así la página no cambia de
// tamaño bajo el cursor mientras se arrastra); mientras tanto se muestra el
// porcentaje. Los textos van aquí (10 idiomas), igual que en
// window_chrome_settings.dart.
import 'package:flutter/material.dart';

import '../../services/ui_scale_service.dart';
import '../theme/ios_theme.dart';
import 'ios_settings_widgets.dart';

/// Devuelve las secciones listas para añadir a la lista de Apariencia.
List<Widget> uiScaleSections(BuildContext context) {
  final t = _UiScaleText.of(context);
  return [
    IosSettingsSection(
      title: t.textSection,
      footer: t.textFooter,
      children: [
        _ScaleSliderTile(
          notifier: UiScale.text,
          min: UiScale.textMin,
          max: UiScale.textMax,
          icon: Icons.text_fields_rounded,
          color: IosColors.blue,
          title: t.textSection,
          onApply: UiScale.setText,
        ),
      ],
    ),
    IosSettingsSection(
      title: t.cardsSection,
      footer: t.cardsFooter,
      children: [
        _ScaleSliderTile(
          notifier: UiScale.cards,
          min: UiScale.cardsMin,
          max: UiScale.cardsMax,
          icon: Icons.grid_view_rounded,
          color: IosColors.purple,
          title: t.cardsSection,
          onApply: UiScale.setCards,
        ),
        IosSettingsTile(
          leading: IosIconBadge(
            color: IosColors.gray,
            child: const Icon(Icons.restart_alt_rounded,
                color: Colors.white, size: 16),
          ),
          title: t.reset,
          onTap: UiScale.reset,
        ),
      ],
    ),
  ];
}

class _ScaleSliderTile extends StatefulWidget {
  const _ScaleSliderTile({
    required this.notifier,
    required this.min,
    required this.max,
    required this.icon,
    required this.color,
    required this.title,
    required this.onApply,
  });

  final ValueNotifier<double> notifier;
  final double min;
  final double max;
  final IconData icon;
  final Color color;
  final String title;
  final Future<void> Function(double) onApply;

  @override
  State<_ScaleSliderTile> createState() => _ScaleSliderTileState();
}

class _ScaleSliderTileState extends State<_ScaleSliderTile> {
  /// Valor mostrado mientras se arrastra (null = el valor aplicado).
  double? _drag;

  @override
  void initState() {
    super.initState();
    // Si cambia desde fuera (botón Restablecer) se refleja aquí.
    widget.notifier.addListener(_onExternal);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onExternal);
    super.dispose();
  }

  void _onExternal() {
    if (mounted) setState(() => _drag = null);
  }

  @override
  Widget build(BuildContext context) {
    final double value = _drag ?? widget.notifier.value;
    final int divisions =
        ((widget.max - widget.min) / UiScale.step).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        children: [
          IosIconBadge(
            color: widget.color,
            child: Icon(widget.icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            'A',
            style: TextStyle(fontSize: 11, color: IosColors.secondaryLabel),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: IosColors.blue,
                inactiveTrackColor: IosColors.overlay(0x33),
                thumbColor: Colors.white,
                overlayColor: IosColors.blue.withOpacity(0.15),
                showValueIndicator: ShowValueIndicator.never,
              ),
              child: Slider(
                value: value.clamp(widget.min, widget.max).toDouble(),
                min: widget.min,
                max: widget.max,
                divisions: divisions,
                onChanged: (v) => setState(() => _drag = v),
                onChangeEnd: (v) async {
                  await widget.onApply(v);
                  if (mounted) setState(() => _drag = null);
                },
              ),
            ),
          ),
          Text(
            'A',
            style: TextStyle(fontSize: 18, color: IosColors.secondaryLabel),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 46,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: IosColors.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UiScaleText {
  const _UiScaleText._(this._m);

  final Map<String, String> _m;

  static _UiScaleText of(BuildContext context) {
    final String code = Localizations.localeOf(context).languageCode;
    return _UiScaleText._(_all[code] ?? _all['en']!);
  }

  String get textSection => _m['ts']!;
  String get textFooter => _m['tf']!;
  String get cardsSection => _m['cs']!;
  String get cardsFooter => _m['cf']!;
  String get reset => _m['r']!;

  static const Map<String, Map<String, String>> _all = {
    'es': {
      'ts': 'Tamaño de letra',
      'tf': 'Cambia el tamaño del texto de toda la interfaz.',
      'cs': 'Tamaño de las tarjetas',
      'cf': 'Cambia el tamaño de las tarjetas de mods en la cuadrícula y el alto de las filas de la lista.',
      'r': 'Restablecer tamaños',
    },
    'en': {
      'ts': 'Font size',
      'tf': 'Changes the text size across the whole interface.',
      'cs': 'Card size',
      'cf': 'Changes the size of the mod cards in the grid and the row height in the list.',
      'r': 'Reset sizes',
    },
    'de': {
      'ts': 'Schriftgröße',
      'tf': 'Ändert die Textgröße der gesamten Oberfläche.',
      'cs': 'Kartengröße',
      'cf': 'Ändert die Größe der Mod-Karten im Raster und die Zeilenhöhe in der Liste.',
      'r': 'Größen zurücksetzen',
    },
    'fr': {
      'ts': 'Taille de police',
      'tf': 'Modifie la taille du texte dans toute l’interface.',
      'cs': 'Taille des cartes',
      'cf': 'Modifie la taille des cartes de mods dans la grille et la hauteur des lignes de la liste.',
      'r': 'Réinitialiser les tailles',
    },
    'it': {
      'ts': 'Dimensione del testo',
      'tf': 'Cambia la dimensione del testo in tutta l’interfaccia.',
      'cs': 'Dimensione delle schede',
      'cf': 'Cambia la dimensione delle schede dei mod nella griglia e l’altezza delle righe nell’elenco.',
      'r': 'Ripristina dimensioni',
    },
    'pt': {
      'ts': 'Tamanho da fonte',
      'tf': 'Altera o tamanho do texto em toda a interface.',
      'cs': 'Tamanho dos cartões',
      'cf': 'Altera o tamanho dos cartões de mods na grade e a altura das linhas da lista.',
      'r': 'Redefinir tamanhos',
    },
    'ru': {
      'ts': 'Размер шрифта',
      'tf': 'Меняет размер текста во всём интерфейсе.',
      'cs': 'Размер карточек',
      'cf': 'Меняет размер карточек модов в сетке и высоту строк в списке.',
      'r': 'Сбросить размеры',
    },
    'ja': {
      'ts': '文字サイズ',
      'tf': 'インターフェース全体の文字サイズを変更します。',
      'cs': 'カードのサイズ',
      'cf': 'グリッド表示のModカードのサイズと、リスト表示の行の高さを変更します。',
      'r': 'サイズをリセット',
    },
    'ko': {
      'ts': '글꼴 크기',
      'tf': '인터페이스 전체의 글자 크기를 변경합니다.',
      'cs': '카드 크기',
      'cf': '그리드의 모드 카드 크기와 목록의 행 높이를 변경합니다.',
      'r': '크기 초기화',
    },
    'zh': {
      'ts': '字体大小',
      'tf': '更改整个界面的文字大小。',
      'cs': '卡片大小',
      'cf': '更改网格中模组卡片的大小以及列表中行的高度。',
      'r': '重置大小',
    },
  };
}
