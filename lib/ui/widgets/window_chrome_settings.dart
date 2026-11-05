// lib/ui/widgets/window_chrome_settings.dart
//
// Secciones de Ajustes → Apariencia para la barra de la ventana:
//   * Botones de la ventana: Automático / Estilo semáforo / Estilo Windows.
//   * Barra superior: fusionar (o no) con la barra de herramientas.
//
// Los textos están aquí (10 idiomas) para no tocar los ARB; si prefieres,
// pásalos a los ARB y sustituye [_WindowChromeText] por AppLocalizations.
import 'package:flutter/material.dart';

import '../theme/ios_theme.dart';
import 'app_title_bar.dart';
import 'ios_settings_widgets.dart';

/// Devuelve las dos secciones listas para añadir a la lista de Apariencia.
List<Widget> windowChromeSections(BuildContext context) {
  final t = _WindowChromeText.of(context);
  final WindowButtonsPref current = WindowChrome.buttons.value;

  Widget option({
    required WindowButtonsPref value,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return IosSettingsTile(
      leading: IosIconBadge(
        color: color,
        child: Icon(icon, color: Colors.white, size: 16),
      ),
      title: title,
      subtitle: subtitle,
      onTap: () => WindowChrome.setButtons(value),
      trailing: current == value
          ? Icon(Icons.check_rounded, color: IosColors.blue, size: 20)
          : null,
    );
  }

  return [
    IosSettingsSection(
      title: t.buttonsSection,
      footer: t.buttonsFooter,
      children: [
        option(
          value: WindowButtonsPref.auto,
          icon: Icons.auto_awesome_rounded,
          color: IosColors.gray,
          title: t.auto,
          subtitle: t.autoDesc,
        ),
        option(
          value: WindowButtonsPref.mac,
          icon: Icons.laptop_mac_rounded,
          color: IosColors.red,
          title: t.mac,
          subtitle: t.macDesc,
        ),
        option(
          value: WindowButtonsPref.windows,
          icon: Icons.window_rounded,
          color: IosColors.blue,
          title: t.win,
          subtitle: t.winDesc,
        ),
      ],
    ),
    IosSettingsSection(
      title: t.barSection,
      children: [
        IosSettingsSwitchTile(
          leading: IosIconBadge(
            color: IosColors.teal,
            child: const Icon(Icons.web_asset_rounded,
                color: Colors.white, size: 16),
          ),
          title: t.merge,
          subtitle: t.mergeDesc,
          value: WindowChrome.merged.value,
          onChanged: (bool v) => WindowChrome.setMerged(v),
        ),
      ],
    ),
  ];
}

class _WindowChromeText {
  const _WindowChromeText._(this._m);

  final Map<String, String> _m;

  static _WindowChromeText of(BuildContext context) {
    final String code = Localizations.localeOf(context).languageCode;
    return _WindowChromeText._(_all[code] ?? _all['en']!);
  }

  String get buttonsSection => _m['bs']!;
  String get buttonsFooter => _m['bf']!;
  String get auto => _m['a']!;
  String get autoDesc => _m['ad']!;
  String get mac => _m['m']!;
  String get macDesc => _m['md']!;
  String get win => _m['w']!;
  String get winDesc => _m['wd']!;
  String get barSection => _m['ts']!;
  String get merge => _m['mg']!;
  String get mergeDesc => _m['mgd']!;

  static const Map<String, Map<String, String>> _all = {
    'es': {
      'bs': 'Botones de la ventana',
      'bf': 'Dónde van los botones de cerrar, minimizar y maximizar.',
      'a': 'Automático',
      'ad': 'Estilo macOS a la izquierda; Material y Plano a la derecha',
      'm': 'Estilo semáforo',
      'md': 'Botones de colores a la izquierda',
      'w': 'Estilo Windows',
      'wd': 'Botones a la derecha',
      'ts': 'Barra superior',
      'mg': 'Fusionar con la barra de herramientas',
      'mgd': 'Une la barra de la ventana con la de abajo y oculta el nombre de la app',
    },
    'en': {
      'bs': 'Window buttons',
      'bf': 'Where the close, minimize and maximize buttons go.',
      'a': 'Automatic',
      'ad': 'macOS style on the left; Material and Flat on the right',
      'm': 'Traffic-light style',
      'md': 'Colored buttons on the left',
      'w': 'Windows style',
      'wd': 'Buttons on the right',
      'ts': 'Top bar',
      'mg': 'Merge with the toolbar',
      'mgd': 'Joins the window bar with the toolbar below and hides the app name',
    },
    'de': {
      'bs': 'Fensterschaltflächen',
      'bf': 'Wo die Schaltflächen zum Schließen, Minimieren und Maximieren stehen.',
      'a': 'Automatisch',
      'ad': 'macOS-Stil links; Material und Flach rechts',
      'm': 'Ampel-Stil',
      'md': 'Farbige Schaltflächen links',
      'w': 'Windows-Stil',
      'wd': 'Schaltflächen rechts',
      'ts': 'Obere Leiste',
      'mg': 'Mit der Symbolleiste verbinden',
      'mgd': 'Verbindet die Fensterleiste mit der Symbolleiste darunter und blendet den App-Namen aus',
    },
    'fr': {
      'bs': 'Boutons de la fenêtre',
      'bf': 'Emplacement des boutons fermer, réduire et agrandir.',
      'a': 'Automatique',
      'ad': 'Style macOS à gauche ; Material et Plat à droite',
      'm': 'Style feux tricolores',
      'md': 'Boutons colorés à gauche',
      'w': 'Style Windows',
      'wd': 'Boutons à droite',
      'ts': 'Barre supérieure',
      'mg': 'Fusionner avec la barre d’outils',
      'mgd': 'Réunit la barre de la fenêtre et la barre d’outils, et masque le nom de l’app',
    },
    'it': {
      'bs': 'Pulsanti della finestra',
      'bf': 'Dove si trovano i pulsanti chiudi, riduci a icona e ingrandisci.',
      'a': 'Automatico',
      'ad': 'Stile macOS a sinistra; Material e Piatto a destra',
      'm': 'Stile semaforo',
      'md': 'Pulsanti colorati a sinistra',
      'w': 'Stile Windows',
      'wd': 'Pulsanti a destra',
      'ts': 'Barra superiore',
      'mg': 'Unisci alla barra degli strumenti',
      'mgd': 'Unisce la barra della finestra a quella sotto e nasconde il nome dell’app',
    },
    'pt': {
      'bs': 'Botões da janela',
      'bf': 'Onde ficam os botões de fechar, minimizar e maximizar.',
      'a': 'Automático',
      'ad': 'Estilo macOS à esquerda; Material e Plano à direita',
      'm': 'Estilo semáforo',
      'md': 'Botões coloridos à esquerda',
      'w': 'Estilo Windows',
      'wd': 'Botões à direita',
      'ts': 'Barra superior',
      'mg': 'Mesclar com a barra de ferramentas',
      'mgd': 'Une a barra da janela com a de baixo e oculta o nome do app',
    },
    'ru': {
      'bs': 'Кнопки окна',
      'bf': 'Где находятся кнопки закрытия, сворачивания и разворачивания.',
      'a': 'Автоматически',
      'ad': 'Стиль macOS слева; Material и Плоский справа',
      'm': 'Стиль светофора',
      'md': 'Цветные кнопки слева',
      'w': 'Стиль Windows',
      'wd': 'Кнопки справа',
      'ts': 'Верхняя панель',
      'mg': 'Объединить с панелью инструментов',
      'mgd': 'Соединяет панель окна с панелью инструментов ниже и скрывает название приложения',
    },
    'ja': {
      'bs': 'ウィンドウボタン',
      'bf': '閉じる・最小化・最大化ボタンの位置です。',
      'a': '自動',
      'ad': 'macOSスタイルは左、Materialとフラットは右',
      'm': '信号スタイル',
      'md': '左側にカラーボタン',
      'w': 'Windowsスタイル',
      'wd': '右側にボタン',
      'ts': 'トップバー',
      'mg': 'ツールバーと統合',
      'mgd': 'ウィンドウバーを下のツールバーと一体化し、アプリ名を非表示にします',
    },
    'ko': {
      'bs': '창 버튼',
      'bf': '닫기, 최소화, 최대화 버튼의 위치입니다.',
      'a': '자동',
      'ad': 'macOS 스타일은 왼쪽, Material과 플랫은 오른쪽',
      'm': '신호등 스타일',
      'md': '왼쪽에 색상 버튼',
      'w': 'Windows 스타일',
      'wd': '오른쪽에 버튼',
      'ts': '상단 바',
      'mg': '도구 모음과 통합',
      'mgd': '창 막대를 아래 도구 모음과 합치고 앱 이름을 숨깁니다',
    },
    'zh': {
      'bs': '窗口按钮',
      'bf': '关闭、最小化和最大化按钮的位置。',
      'a': '自动',
      'ad': 'macOS 风格在左侧；Material 和扁平在右侧',
      'm': '红绿灯样式',
      'md': '左侧彩色按钮',
      'w': 'Windows 样式',
      'wd': '右侧按钮',
      'ts': '顶部栏',
      'mg': '与工具栏合并',
      'mgd': '将窗口栏与下方工具栏合并，并隐藏应用名称',
    },
  };
}