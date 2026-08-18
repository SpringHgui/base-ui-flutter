import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A single add-on (icon or text) attached to the side of an [InputGroup].
class InputGroupAddon extends StatelessWidget {
  const InputGroupAddon(
    this.child, {
    super.key,
    this.tokens,
  });

  final Widget child;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Container(
      constraints: BoxConstraints(minHeight: t.controlHeight),
      padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX * 0.8),
      color: t.mutedColor,
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: t.fontFamily,
          fontSize: t.fontSize * 0.875,
          color: t.mutedForegroundColor,
          height: 1.2,
        ),
        child: child,
      ),
    );
  }
}

/// Groups an input together with leading / trailing add-ons (icons, units,
/// buttons) inside one control — the shadcn "InputGroup" pattern.
///
/// The group draws no outer border of its own: the child input's own hairline
/// border doubles as the group outline and the inner dividers, so there are
/// never doubled lines. The add-ons only paint borders on their outer and
/// top / bottom edges.
class InputGroup extends StatelessWidget {
  const InputGroup({
    super.key,
    this.leading,
    this.trailing,
    required this.child,
    this.tokens,
  });

  /// Add-on(s) shown before the input.
  final Widget? leading;

  /// Add-on(s) shown after the input.
  final Widget? trailing;

  /// The input control itself (typically [Input] or [Textarea]).
  final Widget child;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    BorderSide side() =>
        BorderSide(color: t.borderColor, width: t.borderWidth);

    return ClipRRect(
      borderRadius: BorderRadius.circular(t.cornerRadius),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (leading != null)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: side(),
                  bottom: side(),
                  left: side(),
                ),
              ),
              child: leading,
            ),
          Expanded(child: child),
          if (trailing != null)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: side(),
                  bottom: side(),
                  right: side(),
                ),
              ),
              child: trailing,
            ),
        ],
      ),
    );
  }
}
