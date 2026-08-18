import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'surface.dart';

/// Visual variants of [Toggle].
enum ToggleVariant {
  /// Borderless; hover uses the muted surface.
  default_,

  /// Bordered (hairline border on all states).
  outline,
}

/// Size presets of [Toggle] (relative to [DesktopTokens.controlHeight]).
enum ToggleSize { small, medium, large }

/// A two-state pressable button (italic / bold toolbars, filters, …).
///
/// The selected state fills with the token accent surface; hover, pressed,
/// focus and disabled visuals are all resolved from [DesktopTokens].
class Toggle extends StatefulWidget {
  const Toggle({
    super.key,
    this.selected = false,
    this.onChanged,
    this.variant = ToggleVariant.default_,
    this.size = ToggleSize.medium,
    this.enabled = true,
    this.semanticLabel,
    this.tokens,
    required this.child,
  });

  /// Whether the toggle is in its "on" state.
  final bool selected;

  /// Called with the new state when the toggle is activated.
  final ValueChanged<bool>? onChanged;

  /// Visual treatment.
  final ToggleVariant variant;

  /// Height preset.
  final ToggleSize size;

  final bool enabled;
  final String? semanticLabel;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// The toggle content (icon or label).
  final Widget child;

  @override
  State<Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    final heightFactor = switch (widget.size) {
      ToggleSize.small => 0.9,
      ToggleSize.medium => 1.0,
      ToggleSize.large => 1.15,
    };

    final Color baseFill = widget.selected
        ? t.accentColor
        : Colors.transparent;
    final Color? hoverFill = widget.selected ? null : t.mutedColor;

    return Surface(
      tokens: t,
      onTap: widget.enabled && widget.onChanged != null
          ? () => widget.onChanged!(!widget.selected)
          : null,
      color: baseFill,
      hoverColor: hoverFill,
      borderColor: widget.variant == ToggleVariant.outline ? t.borderColor : null,
      semanticLabel: widget.semanticLabel,
      selected: widget.selected,
      constraints: BoxConstraints(
        minHeight: t.controlHeight * heightFactor,
        minWidth: t.controlHeight * heightFactor,
      ),
      padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX * 0.75),
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: t.fontFamily,
          fontSize: t.fontSize * 0.875,
          fontWeight: FontWeight.w500,
          color: widget.selected
              ? t.accentForegroundColor
              : t.foregroundColor,
          height: 1.2,
        ),
        child: widget.child,
      ),
    );
  }
}
