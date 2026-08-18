import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// Chart type rendered by [Chart].
enum ChartType { bar, line, donut }

/// One data point / slice of a [Chart].
class ChartDatum {
  const ChartDatum(this.label, this.value, {this.color});

  /// Category label (x axis / legend).
  final String label;

  /// Numeric value.
  final double value;

  /// Optional series color; defaults to the token chart palette.
  final Color? color;
}

/// A dependency-free chart (bar / line / donut) — the counterpart of the
/// shadcn "Chart". Series colors cycle through
/// [DesktopTokens.chartColors]; no color is hard-coded.
class Chart extends StatelessWidget {
  const Chart({
    super.key,
    this.type = ChartType.bar,
    required this.data,
    this.height = 200,
    this.showValues = false,
    this.tokens,
  });

  final ChartType type;
  final List<ChartDatum> data;
  final double height;

  /// Annotate bar / line points with their values.
  final bool showValues;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    if (data.isEmpty) return const SizedBox.shrink();
    return Semantics(
      label: 'Chart',
      child: switch (type) {
        ChartType.bar => SizedBox(
            height: height,
            child: CustomPaint(
              painter: _BarPainter(data, t, showValues),
            ),
          ),
        ChartType.line => SizedBox(
            height: height,
            child: CustomPaint(
              painter: _LinePainter(data, t, showValues),
            ),
          ),
        ChartType.donut => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: height,
                height: height,
                child: CustomPaint(
                  painter: _DonutPainter(data, t),
                ),
              ),
              const SizedBox(height: 8),
              _Legend(data, t),
            ],
          ),
      },
    );
  }
}

Color _seriesColor(List<ChartDatum> data, int index, DesktopTokens t) =>
    data[index].color ?? t.chartColors[index % t.chartColors.length];

class _BarPainter extends CustomPainter {
  _BarPainter(this.data, this.t, this.showValues);

  final List<ChartDatum> data;
  final DesktopTokens t;
  final bool showValues;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue =
        data.map((d) => d.value).fold<double>(0, (a, b) => math.max(a, b));
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final gap = size.width / data.length * 0.25;
    final barWidth = size.width / data.length - gap;
    final chartBottom = size.height - 16;

    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final h = chartBottom * (d.value / safeMax);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * (size.width / data.length) + gap / 2,
          chartBottom - h,
          barWidth,
          h,
        ),
        Radius.circular(t.cornerRadius),
      );
      canvas.drawRRect(rect, Paint()..color = _seriesColor(data, i, t));
      _drawLabel(canvas, d.label, Offset(rect.center.dx, chartBottom + 2), t);
      if (showValues && h > 14) {
        _drawLabel(
          canvas,
          d.value.toStringAsFixed(0),
          Offset(rect.center.dx, chartBottom - h - 2),
          t,
          bold: true,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.data != data || old.t != t || old.showValues != showValues;
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.data, this.t, this.showValues);

  final List<ChartDatum> data;
  final DesktopTokens t;
  final bool showValues;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxValue =
        data.map((d) => d.value).fold<double>(0, (a, b) => math.max(a, b));
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final topPad = showValues ? 16.0 : 6.0;
    final chartBottom = size.height - 16;

    Offset point(int i) {
      final x = i * (size.width / (data.length - 1));
      final y = topPad + (chartBottom - topPad) * (1 - data[i].value / safeMax);
      return Offset(x, y);
    }

    final color = _seriesColor(data, 0, t);
    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < data.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(point(i), 3.5, Paint()..color = t.popoverColor);
      canvas.drawCircle(point(i), 3.5, Paint()..color = color);
      if (showValues) {
        _drawLabel(
          canvas,
          data[i].value.toStringAsFixed(0),
          point(i) + const Offset(0, -10),
          t,
          bold: true,
        );
      }
      _drawLabel(canvas, data[i].label, Offset(point(i).dx, chartBottom + 2), t);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.data != data || old.t != t || old.showValues != showValues;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.data, this.t);

  final List<ChartDatum> data;
  final DesktopTokens t;

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<double>(0, (a, b) => a + b.value);
    if (total <= 0) return;
    final rect = Offset.zero & size;
    final stroke = size.width * 0.14;
    final arc = rect.deflate(stroke / 2);
    var start = -math.pi / 2;
    for (var i = 0; i < data.length; i++) {
      final sweep = data[i].value / total * 2 * math.pi;
      canvas.drawArc(
        arc,
        start,
        sweep - 0.02,
        false,
        Paint()
          ..color = _seriesColor(data, i, t)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.data != data || old.t != t;
}

class _Legend extends StatelessWidget {
  const _Legend(this.data, this.t);

  final List<ChartDatum> data;
  final DesktopTokens t;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: t.controlPaddingX,
      runSpacing: t.compactSpacing,
      children: [
        for (var i = 0; i < data.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _seriesColor(data, i, t),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${data[i].label} (${data[i].value.toStringAsFixed(0)})',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize * 0.75,
                  color: t.mutedForegroundColor,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

void _drawLabel(
  Canvas canvas,
  String text,
  Offset offset,
  DesktopTokens t, {
  bool bold = false,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: t.fontSize * 0.7,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: bold ? t.foregroundColor : t.mutedForegroundColor,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, offset - Offset(painter.width / 2, 0));
}
