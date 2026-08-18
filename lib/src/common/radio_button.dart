import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style radio button.
///
/// Renders a circular indicator with a label. Multiple [RadioButton] widgets
/// sharing the same [groupValue] form a mutually-exclusive group.
class RadioButton<T> extends StatelessWidget {
  const RadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  /// The value represented by this radio button.
  final T value;

  /// The currently selected value for the group. This radio button is
  /// considered selected when [value] == [groupValue].
  final T? groupValue;

  /// Called when the user selects this radio button.
  final ValueChanged<T?>? onChanged;

  /// Optional text shown beside the indicator.
  final String? label;

  /// Token override. Falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the radio button should focus itself when first built.
  final bool autofocus;

  /// Whether the radio button is interactive.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final handler = enabled ? onChanged : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: t.controlHeight,
          height: t.controlHeight,
          child: RadioGroup<T>(
            groupValue: groupValue,
            onChanged: handler ?? (_) {},
            child: Radio<T>(
              value: value,
              focusNode: focusNode,
              autofocus: autofocus,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return t.controlDisabledColor;
                }
                if (states.contains(WidgetState.selected)) {
                  return t.primaryColor;
                }
                return t.surfaceColor;
              }),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: handler != null ? () => handler(value) : null,
            child: Text(
              label!,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color:
                    enabled ? t.foregroundColor : t.disabledForegroundColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
