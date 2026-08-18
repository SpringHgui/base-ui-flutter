import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_extensions.dart';
import '../foundation/token_scope.dart';

/// An on/off switch with a sliding thumb (the shadcn "Switch", renamed
/// `ToggleSwitch` because `Switch` collides with the Material widget).
///
/// Track and thumb colors come from [DesktopTokens]; hover darkening, the
/// focus ring and disabled treatment are also token-derived.
class ToggleSwitch extends StatefulWidget {
  const ToggleSwitch({
    super.key,
    this.value = false,
    required this.onChanged,
    this.enabled = true,
    this.semanticLabel,
    this.tokens,
  });

  /// Current state.
  final bool value;

  /// Called with the new state when the switch is toggled.
  final ValueChanged<bool> onChanged;

  final bool enabled;
  final String? semanticLabel;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  State<ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  bool _hovered = false;
  bool _focused = false;
  final FocusNode _focusNode = FocusNode(debugLabel: 'ToggleSwitch');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    final height = t.controlHeight * 0.66;
    final width = height * 1.75;
    final thumb = height - t.borderWidth * 4;

    final trackColor = switch ((widget.enabled, widget.value, _hovered)) {
      (false, _, _) => t.controlDisabledColor,
      (true, true, true) => t.primaryColor.hoveredWith(t),
      (true, true, false) => t.primaryColor,
      (true, false, true) => t.mutedColor.hoveredWith(t),
      (true, false, false) => t.mutedColor,
    };
    final thumbColor =
        widget.enabled ? t.surfaceColor : t.disabledForegroundColor;

    return Semantics(
      label: widget.semanticLabel,
      toggled: widget.value,
      enabled: widget.enabled,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: widget.enabled ? (_) => setState(() => _hovered = true) : null,
        onExit: widget.enabled ? (_) => setState(() => _hovered = false) : null,
        child: GestureDetector(
          onTap: widget.enabled ? () => widget.onChanged(!widget.value) : null,
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: widget.enabled,
            onFocusChange: (v) => setState(() => _focused = v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: width,
              height: height,
              padding: EdgeInsets.all(t.borderWidth * 2),
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(t.radiusFull),
                border: _focused && widget.enabled
                    ? Border.all(
                        color: t.ringColor,
                        width: t.ringWidth,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: t.shadowColor,
                    blurRadius: t.shadowBlur * 0.5,
                    offset: Offset(0, t.shadowOffsetY * 0.5),
                  ),
                ],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                alignment:
                    widget.value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: thumb,
                  height: thumb,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: t.shadowColor,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
