import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// The style of a [ProgressBar].
enum ProgressBarStyle {
  /// A fixed-value bar that fills based on [ProgressBar.value].
  determinate,

  /// An indeterminate / marquee animation.
  marquee,
}

/// A WinForm-style progress bar.
///
/// Supports both determinate (fixed value) and marquee (indeterminate) modes.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    this.value = 0.0,
    this.min = 0.0,
    this.max = 100.0,
    this.style = ProgressBarStyle.determinate,
    this.tokens,
  });

  /// Current progress value. Only used in [ProgressBarStyle.determinate].
  final double value;

  /// Minimum value of the progress range.
  final double min;

  /// Maximum value of the progress range.
  final double max;

  /// Whether the bar shows a fixed value or an indeterminate marquee.
  final ProgressBarStyle style;

  /// Token override.
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return SizedBox(
      height: t.controlHeight * 0.6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surfaceColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(t.cornerRadius),
          child: style == ProgressBarStyle.marquee
              ? _buildMarquee(t)
              : _buildDeterminate(t),
        ),
      ),
    );
  }

  Widget _buildDeterminate(DesktopTokens t) {
    final range = max - min;
    final fraction = range > 0 ? ((value - min) / range).clamp(0.0, 1.0) : 0.0;

    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: fraction,
      child: ColoredBox(color: t.primaryColor),
    );
  }

  Widget _buildMarquee(DesktopTokens t) {
    return _MarqueeBar(color: t.primaryColor);
  }
}

/// Continuous marquee animation. A plain [TweenAnimationBuilder] plays the
/// sweep exactly once and then freezes; WinForms marquee loops forever, so
/// drive it with a repeating [AnimationController].
class _MarqueeBar extends StatefulWidget {
  const _MarqueeBar({required this.color});

  final Color color;

  @override
  State<_MarqueeBar> createState() => _MarqueeBarState();
}

class _MarqueeBarState extends State<_MarqueeBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.3,
          child: FractionalTranslation(
            translation: Offset(_controller.value * 4.33 - 1.0, 0),
            child: child,
          ),
        );
      },
      child: ColoredBox(color: widget.color),
    );
  }
}
