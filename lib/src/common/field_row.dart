import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'label.dart';

/// A horizontal labeled form row: a right-aligned [label] (fixed width) on the
/// left and an arbitrary control on the right — the classic desktop (Navicat /
/// WinForms style) form layout.
///
/// When [label] is omitted, a fixed-width spacer keeps the control aligned
/// with sibling rows that do have labels (useful for composite rows).
class FieldRow extends StatelessWidget {
  const FieldRow({
    super.key,
    this.label,
    this.labelWidth = 80,
    this.tokens,
    required this.child,
  });

  /// Label text shown on the left. When `null`, a spacer of the same width is
  /// rendered so the control stays aligned with labeled rows.
  final String? label;

  /// Width of the label column (and the spacer when [label] is null).
  final double labelWidth;

  /// The form control(s) rendered on the right.
  final Widget child;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (label != null) ...[
          SizedBox(
            width: labelWidth,
            child: Label(
              label!,
              textAlign: TextAlign.right,
              tokens: t,
            ),
          ),
          const SizedBox(width: 10),
        ] else ...[
          SizedBox(width: labelWidth + 10),
        ],
        // Wrap in a loose [Flexible]: a Row lays out non-flex children with an
        // unbounded max width, which makes TextField-based children (Input)
        // assert "InputDecorator cannot have an unbounded width" in debug
        // builds. Flexible bounds the child to the remaining row width without
        // forcing it to stretch, so fixed-width children keep their width.
        Flexible(child: child),
      ],
    );
  }
}
