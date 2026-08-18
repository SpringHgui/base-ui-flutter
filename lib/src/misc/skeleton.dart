import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A pulsing placeholder box shown while content loads — the counterpart of
/// the shadcn "Skeleton". Color and radius come from [DesktopTokens].
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.radius,
    this.tokens,
  });

  final double width;
  final double height;

  /// Corner radius; defaults to the token corner radius.
  final double? radius;

  final DesktopTokens? tokens;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.45).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: t.mutedColor,
          borderRadius:
              BorderRadius.circular(widget.radius ?? t.cornerRadius),
        ),
      ),
    );
  }
}
