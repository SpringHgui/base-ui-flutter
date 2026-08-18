import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A spinning progress indicator — the counterpart of the shadcn "Spinner".
/// The ring color comes from [DesktopTokens]; no color is hard-coded.
class Spinner extends StatefulWidget {
  const Spinner({
    super.key,
    this.size = 20,
    this.strokeWidth = 2,
    this.tokens,
  });

  /// Ring diameter in logical pixels.
  final double size;

  /// Ring stroke width.
  final double strokeWidth;

  final DesktopTokens? tokens;

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

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
    return Semantics(
      label: 'Loading',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _SpinnerPainter(
              color: t.primaryColor,
              trackColor: t.mutedColor,
              strokeWidth: widget.strokeWidth,
              progress: _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.progress,
  });

  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(arc.center, arc.width / 2, paint..color = trackColor);

    const gap = math.pi / 6;
    final start = progress * 2 * math.pi;
    canvas.drawArc(
      arc,
      start,
      2 * math.pi - gap * 2,
      false,
      paint..color = color..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
