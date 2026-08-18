import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';

/// A single expandable section with a custom trigger — the counterpart of
/// the shadcn "Collapsible".
class Collapsible extends StatefulWidget {
  const Collapsible({
    super.key,
    this.open = false,
    this.onOpenChanged,
    required this.trigger,
    required this.child,
    this.tokens,
  });

  /// Whether the content is expanded.
  final bool open;

  /// Called with the new state when the trigger is activated.
  final ValueChanged<bool>? onOpenChanged;

  /// The trigger widget (its taps toggle the content).
  final Widget trigger;

  /// The collapsible content.
  final Widget child;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Surface(
          tokens: t,
          onTap: () => widget.onOpenChanged?.call(!widget.open),
          hoverColor: t.mutedColor,
          padding: EdgeInsets.symmetric(
            horizontal: t.controlPaddingX,
            vertical: t.compactSpacing,
          ),
          child: widget.trigger,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: widget.open
              ? Padding(
                  padding: EdgeInsets.only(top: t.compactSpacing),
                  child: widget.child,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
