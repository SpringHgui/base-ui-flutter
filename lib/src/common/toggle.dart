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

  /// Borderless like [default_], but the selected state uses the light accent
  /// tint instead of a solid accent fill — for toggles whose child carries its
  /// own colours (icon + label) that a solid fill would swallow.
  ghost,
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

    final isOutline = widget.variant == ToggleVariant.outline;
    final isGhost = widget.variant == ToggleVariant.ghost;
    // outline / ghost:选中态用淡蓝染色 + 强调描边(outline 才有描边)，而不是实心蓝——
    // 保持前景仍是主文字色，图标里的蓝色线稿不会被底色吞掉
    final Color baseFill = !widget.selected
        ? Colors.transparent
        : (isOutline || isGhost
            ? Color.alphaBlend(
                t.accentColor.withValues(alpha: 0.16), t.controlColor)
            : t.accentColor);
    // 悬浮用控件悬浮面而不是 mutedColor：后者是行号槽那类近白底色，
    // 悬停在白底工具条上几乎看不出来
    final Color? hoverFill = widget.selected ? null : t.controlHoverColor;

    return Surface(
      tokens: t,
      onTap: widget.enabled && widget.onChanged != null
          ? () => widget.onChanged!(!widget.selected)
          : null,
      color: baseFill,
      hoverColor: hoverFill,
      borderColor: isOutline
          ? (widget.selected ? t.accentColor : t.borderColor)
          : null,
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
          color: widget.selected && !isOutline && !isGhost
              ? t.accentForegroundColor
              : t.foregroundColor,
          height: 1.2,
        ),
        child: widget.child,
      ),
    );
  }
}
