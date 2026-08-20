import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// 可选中的卡片:内容块 + 选中淡底 + 右上角对勾圆标;禁用时整体降透明并
/// 显示 [disabledLabel] 角标。
///
/// 遵循桌面交互规范:选中由 [Listener.onPointerDown] 触发(零延迟),
/// 双击动作单独挂在 [GestureDetector.onDoubleTap] 上。无 Material
/// 水波纹、无点击动画;所有视觉值由 [DesktopTokens] 驱动。
///
/// 覆盖层(选中淡底 / 角标)用 [CustomPaint] 绘制而非 Stack:Stack 在
/// 无界约束下无法布局(如 DialogBox 的 IntrinsicHeight 尺寸计算),自绘
/// 让组件在任意约束下都能正常工作,且不引入额外渲染层级。
class SelectableCard extends StatefulWidget {
  const SelectableCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.selected = false,
    this.selectedColor,
    this.disabled = false,
    this.disabledLabel,
    this.onSelect,
    this.onDoubleTap,
    this.borderRadius,
    this.tokens,
  });

  /// 卡片内容(图标 + 文本等,由调用方组合)。
  final Widget child;

  /// 固定宽度;为 `null` 时由内容决定。
  final double? width;

  /// 固定高度;为 `null` 时由内容决定。
  final double? height;

  /// 是否选中:内容上层叠加选中淡底 + 右上角对勾圆标。
  final bool selected;

  /// 选中强调色;默认 [DesktopTokens.primaryColor]。
  final Color? selectedColor;

  /// 禁用:内容按 [DesktopTokens.disabledOpacity] 降透明,不响应手势。
  final bool disabled;

  /// 禁用角标文本(如"未实现");为 `null` 时不显示角标。
  final String? disabledLabel;

  /// 选中回调,由 [Listener.onPointerDown] 触发,零延迟。
  final VoidCallback? onSelect;

  /// 双击回调(打开动作),独立手势,不影响单击响应速度。
  final VoidCallback? onDoubleTap;

  /// 选中底 / 角标的圆角;默认 [DesktopTokens.cornerRadius]。
  final BorderRadius? borderRadius;

  /// Token 覆盖;回退到外层 [TokenScope],最后 [DesktopTokens.winForm]。
  final DesktopTokens? tokens;

  @override
  State<SelectableCard> createState() => _SelectableCardState();
}

class _SelectableCardState extends State<SelectableCard> {
  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final accent = widget.selectedColor ?? t.primaryColor;
    final radius = widget.borderRadius ?? BorderRadius.circular(t.cornerRadius);
    final showCheck = widget.selected && !widget.disabled;
    final showDisabledLabel = widget.disabled && widget.disabledLabel != null;

    final card = SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        // 选中淡底:内容下层(内容无背景时透出),整卡圆角填充
        painter: showCheck
            ? _CardOverlayPainter(
                color: accent.withValues(alpha: 0.15),
                radius: radius,
              )
            : null,
        // 右上角角标:内容上层(对勾圆标 / 禁用标签)
        foregroundPainter: showCheck
            ? _BadgePainter.check(
                accent: accent,
                checkColor: t.accentForegroundColor,
                radius: radius,
              )
            : (showDisabledLabel
                ? _BadgePainter.disabled(
                    label: widget.disabledLabel!,
                    t: t,
                    radius: radius,
                  )
                : null),
        // 内容:禁用时整体降透明
        child: Opacity(
          opacity: widget.disabled ? t.disabledOpacity : 1.0,
          child: widget.child,
        ),
      ),
    );

    return MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        // disabled 时不注册手势,避免误触
        onPointerDown: widget.disabled ? null : (_) => widget.onSelect?.call(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: widget.disabled ? null : widget.onDoubleTap,
          child: card,
        ),
      ),
    );
  }
}

/// 选中淡底:整卡区域按 [radius] 圆角填充半透明强调色。
class _CardOverlayPainter extends CustomPainter {
  const _CardOverlayPainter({required this.color, required this.radius});

  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: radius.topLeft,
        topRight: radius.topRight,
        bottomLeft: radius.bottomLeft,
        bottomRight: radius.bottomRight,
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CardOverlayPainter old) =>
      old.color != color || old.radius != radius;
}

/// 右上角角标:对勾圆标(选中)或禁用标签(禁用)。文本角标用 TextPainter
/// 绘制,无需任何布局节点,与卡片圆角保持一致。
class _BadgePainter extends CustomPainter {
  _BadgePainter.check({
    required Color accent,
    required Color checkColor,
    required BorderRadius radius,
  })  : _accent = accent,
        _checkColor = checkColor,
        _radius = radius,
        _label = null,
        _labelColor = null,
        _labelBg = null,
        _labelFontSize = null,
        _labelFontFamily = null,
        _padding = null;

  _BadgePainter.disabled({
    required String label,
    required DesktopTokens t,
    required BorderRadius radius,
  })  : _accent = null,
        _checkColor = null,
        _radius = radius,
        _label = label,
        _labelColor = t.mutedForegroundColor,
        _labelBg = t.mutedColor,
        _labelFontSize = t.fontSize * 0.7,
        _labelFontFamily = t.fontFamily,
        _padding = t.compactSpacing;

  final Color? _accent;
  final Color? _checkColor;
  final BorderRadius _radius;
  final String? _label;
  final Color? _labelColor;
  final Color? _labelBg;
  final double? _labelFontSize;
  final String? _labelFontFamily;
  final double? _padding;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 4.0; // 右上角外边距
    if (_accent != null) {
      // 对勾圆标:18x18 圆 + check 对勾
      const d = 18.0;
      final center = Offset(size.width - pad - d / 2, pad + d / 2);
      canvas.drawCircle(center, d / 2, Paint()..color = _accent);
      final paint = Paint()
        ..color = _checkColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path()
        ..moveTo(center.dx - 4, center.dy)
        ..lineTo(center.dx - 1.2, center.dy + 3)
        ..lineTo(center.dx + 4, center.dy - 3.5);
      canvas.drawPath(path, paint);
      return;
    }
    // 禁用标签:圆角矩形 + 文本(上下 padding 各 compactSpacing/2)
    final tp = TextPainter(
      text: TextSpan(
        text: _label,
        style: TextStyle(
          fontFamily: _labelFontFamily,
          fontSize: _labelFontSize,
          color: _labelColor,
          height: 1.0,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = tp.width + _padding! * 2;
    final h = tp.height + _padding;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - pad - w, pad, w, h),
      Radius.circular(_radius.topLeft.x),
    );
    canvas.drawRRect(rect, Paint()..color = _labelBg!);
    tp.paint(canvas, Offset(size.width - pad - w + _padding, pad + _padding / 2));
  }

  @override
  bool shouldRepaint(_BadgePainter old) =>
      old._accent != _accent ||
      old._checkColor != _checkColor ||
      old._radius != _radius ||
      old._label != _label ||
      old._labelColor != _labelColor ||
      old._labelBg != _labelBg ||
      old._labelFontSize != _labelFontSize ||
      old._labelFontFamily != _labelFontFamily ||
      old._padding != _padding;
}
