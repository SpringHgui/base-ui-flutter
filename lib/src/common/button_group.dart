import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// Orientation of a [ButtonGroup].
enum ButtonGroupOrientation { horizontal, vertical }

/// Visually joins several buttons into one segmented control: the group
/// draws a hairline border and 1 px dividers between children (the container
/// background, which defaults to the token border color, shows through the
/// gaps). Works with any button-like children, including the WinForm
/// [Button].
class ButtonGroup extends StatelessWidget {
  const ButtonGroup({
    super.key,
    required this.children,
    this.orientation = ButtonGroupOrientation.horizontal,
    this.connected = true,
    this.tokens,
  });

  /// The buttons to join.
  final List<Widget> children;

  /// Layout direction of the group.
  final ButtonGroupOrientation orientation;

  /// When `false`, children are laid out with a plain gap and no joining.
  final bool connected;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    // Overlap neighbours by the border width so the inner borders coincide
    // into a single hairline instead of stacking into thick dividers.
    final overlap = t.borderWidth;
    final joined = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        joined.add(orientation == ButtonGroupOrientation.horizontal
            ? Transform.translate(
                offset: Offset(-overlap, 0),
                child: children[i],
              )
            : Transform.translate(
                offset: Offset(0, -overlap),
                child: children[i],
              ));
      } else {
        joined.add(children[i]);
      }
    }

    final flex = orientation == ButtonGroupOrientation.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: joined)
        : Column(mainAxisSize: MainAxisSize.min, children: joined);

    if (!connected) return flex;

    return ClipRRect(
      borderRadius: BorderRadius.circular(t.cornerRadius),
      child: flex,
    );
  }
}
