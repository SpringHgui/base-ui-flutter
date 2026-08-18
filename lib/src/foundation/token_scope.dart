import 'package:flutter/widgets.dart';

import 'desktop_tokens.dart';

/// Provides a [DesktopTokens] value to all descendant components.
///
/// Components resolve their tokens with
/// `tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm`, so
/// wrapping a subtree in a [TokenScope] is the app-level way to re-theme every
/// base_ui_flutter widget at once.
class TokenScope extends InheritedWidget {
  const TokenScope({
    super.key,
    required this.tokens,
    required super.child,
  });

  /// The token set provided to descendants.
  final DesktopTokens tokens;

  /// Returns the nearest [DesktopTokens] from an enclosing [TokenScope], or
  /// `null` when there is none.
  static DesktopTokens? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TokenScope>()?.tokens;

  @override
  bool updateShouldNotify(TokenScope oldWidget) => tokens != oldWidget.tokens;
}
