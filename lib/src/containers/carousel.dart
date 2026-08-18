import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';

/// A swipeable / paged carousel with optional arrows and dot indicators —
/// the counterpart of the shadcn "Carousel".
class Carousel extends StatefulWidget {
  const Carousel({
    super.key,
    required this.children,
    this.viewportFraction = 0.9,
    this.height = 220,
    this.showArrows = true,
    this.showDots = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.onPageChanged,
    this.tokens,
  });

  /// The pages.
  final List<Widget> children;

  /// Fraction of the viewport each page occupies (0–1).
  final double viewportFraction;

  /// Viewport height.
  final double height;

  final bool showArrows;
  final bool showDots;

  /// When `true`, pages advance automatically every [autoPlayInterval].
  final bool autoPlay;

  final Duration autoPlayInterval;
  final ValueChanged<int>? onPageChanged;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.viewportFraction);
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (!mounted || !widget.autoPlay) return;
      _next();
      _startAutoPlay();
    });
  }

  void _next() => _go(_page + 1);
  void _prev() => _go(_page - 1);

  void _go(int index) {
    if (widget.children.isEmpty) return;
    final clamped = (index + widget.children.length) % widget.children.length;
    _controller.animateToPage(
      clamped,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

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
    if (widget.children.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: widget.height,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.children.length,
                onPageChanged: (i) {
                  setState(() => _page = i);
                  widget.onPageChanged?.call(i);
                },
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: widget.children[i],
                ),
              ),
            ),
            if (widget.showArrows) ...[
              Positioned(
                left: 0,
                child: _CarouselArrow(
                  icon: Icons.chevron_left,
                  onTap: _prev,
                  tokens: t,
                ),
              ),
              Positioned(
                right: 0,
                child: _CarouselArrow(
                  icon: Icons.chevron_right,
                  onTap: _next,
                  tokens: t,
                ),
              ),
            ],
          ],
        ),
        if (widget.showDots) ...[
          SizedBox(height: t.compactSpacing * 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.children.length; i++)
                GestureDetector(
                  onTap: () => _go(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? t.primaryColor
                          : t.mutedForegroundColor,
                      borderRadius: BorderRadius.circular(t.radiusFull),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({
    required this.icon,
    required this.onTap,
    required this.tokens,
  });

  final IconData icon;
  final VoidCallback onTap;
  final DesktopTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Surface(
      tokens: t,
      onTap: onTap,
      color: t.popoverColor,
      borderColor: t.borderColor,
      borderRadius: BorderRadius.circular(t.radiusFull),
      constraints: BoxConstraints(
        minWidth: t.controlHeight * 1.3,
        minHeight: t.controlHeight * 1.3,
      ),
      child: Icon(icon, size: t.fontSize * 1.2, color: t.foregroundColor),
    );
  }
}
