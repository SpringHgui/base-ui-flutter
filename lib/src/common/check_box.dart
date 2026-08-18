import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style check box.
///
/// Renders a square indicator with a label. All visual values are driven by
/// [DesktopTokens]; no color or spacing is hard-coded.
class CheckBox extends StatelessWidget {
  const CheckBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  /// Whether the box is currently checked.
  final bool value;

  /// Called when the user toggles the check box. Receives the new value.
  final ValueChanged<bool?>? onChanged;

  /// Optional text shown beside the indicator.
  final String? label;

  /// Token override. Falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the check box should focus itself when first built.
  final bool autofocus;

  /// Whether the check box is interactive. When `false`, renders disabled.
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
          child: Checkbox(
            value: value,
            onChanged: handler,
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
            checkColor: t.surfaceColor,
            side: BorderSide(
              color: t.borderColor,
              width: t.borderWidth,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(t.cornerRadius),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: handler != null ? () => handler(!value) : null,
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
