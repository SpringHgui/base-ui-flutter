import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style check box.
///
/// Renders a square indicator with a label. All visual values are driven by
/// [DesktopTokens]; no color or spacing is hard-coded.
///
/// The indicator is hand-drawn (no [Checkbox] animation): checked state
/// switches instantly, matching the snappy WinForms feel.
class CheckBox extends StatelessWidget {
  const CheckBox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  /// Whether the box is currently checked.
  final bool value;

  /// Called when the user toggles the check box. Receives the new value.
  ///
  /// `null` renders a passive indicator (same visuals, no tap / keyboard
  /// handling) for hosts that drive the toggle themselves — e.g. a box inside
  /// a [DataGridView] cell, where the cell's double-tap recognizer would hold
  /// this widget's own tap until the 300 ms judgement window closes.
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

  void _toggle() {
    onChanged?.call(!value);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !enabled) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      _toggle();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final interactive = enabled && onChanged != null;

    // 实心勾选框:选中态为强调色底 + 白色勾号,未选中保持描边空框
    final boxSize = t.controlHeight * 0.5;
    final fillColor = !enabled
        ? t.controlDisabledColor
        : value
            ? t.primaryColor
            : Colors.transparent;
    final boxBorderColor = !enabled
        ? t.disabledForegroundColor
        : value
            ? t.primaryColor
            : t.foregroundColor;
    final checkColor = enabled ? t.accentForegroundColor : t.disabledForegroundColor;

    final indicator = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: interactive ? _toggle : null,
      child: Container(
        width: boxSize,
        height: boxSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: boxBorderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(3),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: boxSize * 0.8,
                color: checkColor,
              )
            : null,
      ),
    );

    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onKeyEvent: interactive ? _handleKeyEvent : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          if (label != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: interactive ? _toggle : null,
              child: Text(
                label!,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: enabled
                      ? t.foregroundColor
                      : t.disabledForegroundColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
