import 'package:flutter/material.dart';
import '../theme/ios_theme.dart';
import '../theme/minimal_style.dart';

/// Keyboard-operable flat primary action.
class MinimalButton extends StatelessWidget {
  const MinimalButton({super.key, required this.label, this.icon,
    this.onPressed, this.color});
  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MinimalStyle.controlHeight,
    child: FilledButton(
      onPressed: onPressed,
      style: MinimalStyle.interactionStyle(FilledButton.styleFrom(
        backgroundColor: color ?? IosColors.blue,
        foregroundColor: MinimalStyle.foregroundFor(color ?? IosColors.blue),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MinimalStyle.controlRadius)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      )).copyWith(
        side: WidgetStateProperty.resolveWith((states) => BorderSide(
          color: states.contains(WidgetState.focused)
              ? MinimalStyle.foregroundFor(color ?? IosColors.blue)
              : Colors.transparent, width: 2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[icon!, const SizedBox(width: 8)],
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    ),
  );
}

/// Underlined text navigation with horizontal scrolling for long translations.
class MinimalTabs<T extends Object> extends StatelessWidget {
  const MinimalTabs({super.key, required this.value, required this.labels,
    required this.onChanged});
  final T value;
  final Map<T, String> labels;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      for (final entry in labels.entries)
        Semantics(
          selected: entry.key == value,
          child: AnimatedContainer(
            duration: MinimalStyle.duration,
            decoration: MinimalStyle.tab(selected: entry.key == value),
            child: TextButton(
              onPressed: () => onChanged(entry.key),
              style: MinimalStyle.interactionStyle(TextButton.styleFrom(
                foregroundColor: entry.key == value
                    ? IosColors.label : IosColors.secondaryLabel,
                minimumSize: const Size(48, 34),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: const RoundedRectangleBorder(),
                textStyle: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w500),
              )),
              child: Text(entry.value, maxLines: 1),
            ),
          ),
        ),
    ]),
  );
}

class MinimalSwitch extends StatelessWidget {
  const MinimalSwitch({super.key, required this.value, this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 46, height: 28,
    child: FittedBox(
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: MinimalStyle.foregroundFor(IosColors.blue),
        activeTrackColor: IosColors.blue,
        inactiveThumbColor: IosColors.secondaryLabel,
        inactiveTrackColor: IosColors.background,
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.transparent : MinimalStyle.controlOutline),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
  );
}

/// TextField supplies native focus, selection, IME and keyboard behavior.
class MinimalSearchField extends StatelessWidget {
  const MinimalSearchField({super.key, required this.controller,
    required this.placeholder, this.onChanged, this.autofocus = false});
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder outline(Color color, {double width = 1}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(MinimalStyle.controlRadius),
      borderSide: BorderSide(color: color, width: width),
    );
    return SizedBox(
      height: MinimalStyle.controlHeight,
      child: TextField(
        controller: controller, onChanged: onChanged, autofocus: autofocus,
        cursorColor: IosColors.blue,
        style: TextStyle(fontSize: 13, color: IosColors.label),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: IosColors.secondaryLabel),
          filled: true, fillColor: MinimalStyle.mutedFill,
          isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          prefixIcon: Icon(Icons.search, size: 18, color: IosColors.secondaryLabel),
          prefixIconConstraints: const BoxConstraints(minWidth: 34),
          enabledBorder: outline(MinimalStyle.controlOutline),
          focusedBorder: outline(IosColors.blue, width: 2),
          suffixIconConstraints: const BoxConstraints(minWidth: 30, maxHeight: 30),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Icon(Icons.close),
                    onPressed: () { controller.clear(); onChanged?.call(''); },
                  ),
          ),
        ),
      ),
    );
  }
}

class MinimalSegmented<T extends Object> extends StatelessWidget {
  const MinimalSegmented({super.key, required this.value,
    required this.children, required this.onChanged});
  final T value;
  final Map<T, Widget> children;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: MinimalStyle.controlHeight,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: MinimalStyle.mutedFill,
      borderRadius: BorderRadius.circular(MinimalStyle.controlRadius),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      for (final entry in children.entries)
        Semantics(
          selected: entry.key == value,
          child: TextButton(
            onPressed: () => onChanged(entry.key),
            style: MinimalStyle.interactionStyle(TextButton.styleFrom(
              minimumSize: const Size(32, 28),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              foregroundColor: IosColors.label,
              backgroundColor: entry.key == value
                  ? IosColors.card : Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            )).copyWith(
              side: WidgetStateProperty.resolveWith((states) => BorderSide(
                color: states.contains(WidgetState.focused) ? IosColors.blue
                    : entry.key == value ? MinimalStyle.controlOutline
                    : Colors.transparent,
              )),
            ),
            child: entry.value,
          ),
        ),
    ]),
  );
}
