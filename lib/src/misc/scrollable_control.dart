import 'package:flutter/widgets.dart';

import '../foundation/desktop_tokens.dart';

/// A headless scrollable control that provides virtual-scroll infrastructure.
///
/// Mirrors WinForms `ScrollableControl`: it wraps a child in a
/// [SingleChildScrollView] with token-driven scroll-bar styling and exposes
/// the underlying [ScrollController] for programmatic scrolling.
class ScrollableControl extends StatefulWidget {
  const ScrollableControl({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.tokens,
    this.padding,
  });

  /// The scrollable content.
  final Widget child;

  /// The scroll direction.
  final Axis scrollDirection;

  /// Optional external scroll controller.
  final ScrollController? controller;

  /// Token override.
  final DesktopTokens? tokens;

  /// Content padding.
  final EdgeInsetsGeometry? padding;

  @override
  State<ScrollableControl> createState() => _ScrollableControlState();
}

class _ScrollableControlState extends State<ScrollableControl> {
  late final ScrollController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  /// The scroll controller used by this widget.
  ScrollController get scrollController => _controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      child: widget.child,
    );
  }
}
