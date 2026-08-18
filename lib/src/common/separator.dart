import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A hairline divider between content sections — horizontal or vertical.
///
/// Color and thickness come from [DesktopTokens]; the widget carries no
/// hard-coded visual value.
class Separator extends StatelessWidget {
  const Separator({
    super.key,
    this.orientation = Axis.horizontal,
    this.thickness,
    this.color,
    this.margin,
    this.tokens,
  });

  /// Direction of the separator line.
  final Axis orientation;

  /// Line thickness; defaults to [DesktopTokens.borderWidth].
  final double? thickness;

  /// Line color; defaults to [DesktopTokens.borderColor].
  final Color? color;

  /// Spacing around the separator.
  final EdgeInsetsGeometry? margin;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final line = Container(
      width: orientation == Axis.horizontal ? double.infinity : (thickness ?? t.borderWidth),
      height: orientation == Axis.vertical ? double.infinity : (thickness ?? t.borderWidth),
      color: color ?? t.borderColor,
    );
    return margin == null ? line : Container(margin: margin, child: line);
  }
}
