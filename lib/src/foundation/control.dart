import 'package:flutter/widgets.dart';

import 'desktop_tokens.dart';
import 'token_scope.dart';

/// The headless base class for all base_ui_flutter controls.
///
/// Mirrors the role of WinForms `Control`: every interactive widget inherits
/// from [Control] to get a unified contract for **focus**, **disabled state**,
/// **semantic labelling**, and **token resolution**.
///
/// [Control] is *not* a widget itself — it is a mixin-style base class that
/// concrete widgets compose with. The key responsibilities are:
///
/// 1. **Token resolution** — `resolveTokens(context)` walks the standard
///    `tokens → TokenScope → DesktopTokens.winForm` chain.
/// 2. **Focus ownership** — helpers to lazily create / dispose a [FocusNode].
/// 3. **Disabled semantics** — a single [enabled] flag that feeds into
///    `Semantics` so screen-readers announce the correct state.
///
/// Subclasses are still fully headless: they never hard-code colours, fonts,
/// or spacing.
abstract class Control {
  /// Token override provided by the concrete widget. When `null`, the
  /// nearest [TokenScope] (or the default preset) is used.
  DesktopTokens? get tokens;

  /// Whether the control is interactive. When `false`, the control renders
  /// in its disabled visual state and ignores pointer / keyboard input.
  bool get enabled;

  /// Focus node for keyboard navigation. When `null`, the concrete widget
  /// should lazily create one in `initState`.
  FocusNode? get focusNode;

  /// Semantic label announced by screen-readers.
  String? get semanticLabel;

  /// Resolves the [DesktopTokens] for this control using the standard chain:
  /// explicit override → enclosing [TokenScope] → default WinForm preset.
  DesktopTokens resolveTokens(BuildContext context) =>
      tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

  /// Returns `true` when the control should respond to user input.
  bool get isInteractive => enabled;
}

/// A convenience widget wrapper that wraps [child] with the standard
/// [Semantics] annotation derived from a [Control]'s state.
///
/// Use this when building a custom control to ensure accessibility is
/// consistently applied.
class ControlSemantics extends StatelessWidget {
  const ControlSemantics({
    super.key,
    required this.enabled,
    required this.focusNode,
    this.label,
    this.child,
  });

  /// Whether the wrapped control is enabled.
  final bool enabled;

  /// The focus node of the wrapped control.
  final FocusNode? focusNode;

  /// Semantic label.
  final String? label;

  /// The child widget to wrap.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      enabled: enabled,
      // A disabled control must not be announced as focusable.
      focusable: enabled,
      child: child,
    );
  }
}
