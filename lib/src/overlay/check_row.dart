import 'package:flutter/material.dart';

import '../common/check_box.dart';
import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A single option displayed in a check list.
class CheckOption {
  const CheckOption({
    required this.id,
    required this.label,
    this.leading,
    this.selected = false,
    this.onToggle,
  });

  final String id;
  final String label;

  /// Optional leading widget (icon, avatar, etc.).
  final Widget? leading;

  final bool selected;
  final VoidCallback? onToggle;
}

/// A compact row with a [CheckBox], optional leading widget, and a label.
///
/// Used inside selection / multi-option lists. Token-driven, no hard-coded colors.
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.option,
    this.tokens,
    this.enabled = true,
  });

  final CheckOption option;
  final DesktopTokens? tokens;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? option.onToggle : null,
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CheckBox(
                value: option.selected,
                onChanged: enabled ? (_) => option.onToggle?.call() : null,
                tokens: t,
              ),
            ),
            const SizedBox(width: 6),
            if (option.leading != null) ...[
              SizedBox(width: 16, height: 16, child: option.leading!),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: enabled
                      ? t.popoverForegroundColor
                      : t.disabledForegroundColor,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}