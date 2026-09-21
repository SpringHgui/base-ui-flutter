import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// 选框矩形变化回调:[rect] 为本组件局部坐标系下的选框(已归一化为正宽高)。
typedef MarqueeRectCallback = void Function(Rect rect);

/// 桌面风格的**框选**(rubber-band / marquee)行为层。
///
/// 在 [child] 区域内按住鼠标左键拖动、位移超过 [threshold] 后进入框选:
/// 期间每次指针移动回调 [onMarqueeUpdate](视口局部矩形)并绘制选框,
/// 起手回调 [onMarqueeStart]、松手或取消回调 [onMarqueeEnd]。
///
/// 本组件**不解释命中**:把矩形换算成选中项是宿主的职责——宿主通常自己
/// 掌握滚动偏移与条目几何(定行高的网格 / 列表可直接算,无需测量渲染对象)。
///
/// 指针事件走 [Listener] 而非手势竞技场:祖先 `Listener` 在 pointer down 时
/// 缓存命中路径,整段拖动都能收到 move/up,既不与子项自己的按下选中抢竞技场,
/// 也不会给子项单击引入约 300ms 的双击判定延迟。
///
/// 零动画、无 Material 水波纹;取色链
/// `tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm`。
class MarqueeSelector extends StatefulWidget {
  const MarqueeSelector({
    super.key,
    required this.child,
    this.enabled = true,
    this.threshold = 4.0,
    this.tokens,
    this.canStart,
    this.onMarqueeStart,
    this.onMarqueeUpdate,
    this.onMarqueeEnd,
  });

  /// 被框选覆盖的内容(通常是列表 / 网格的可视区)。
  final Widget child;

  /// 关闭后完全不注册指针回调,退化为透明的 [child] 容器。
  final bool enabled;

  /// 起手位移阈值(逻辑像素):小于它视为普通点击,不进入框选。
  final double threshold;

  /// Token 覆盖;回退到外层 [TokenScope],最后 [DesktopTokens.winForm]。
  final DesktopTokens? tokens;

  /// 是否允许从该按下点起手框选(默认允许)。宿主可用来排除不该触发框选的区域,
  /// 例如内容区右缘的滚动条命中带。
  final bool Function(PointerDownEvent event)? canStart;

  /// 进入框选(位移刚超过 [threshold])时回调一次。
  final VoidCallback? onMarqueeStart;

  /// 框选过程中每次选框变化时回调。
  final MarqueeRectCallback? onMarqueeUpdate;

  /// 结束框选(松手 / 指针取消)时回调一次。
  final VoidCallback? onMarqueeEnd;

  @override
  State<MarqueeSelector> createState() => _MarqueeSelectorState();
}

class _MarqueeSelectorState extends State<MarqueeSelector> {
  Offset? _start;
  Rect? _band;

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryMouseButton) return;
    if (widget.canStart?.call(event) == false) return;
    _start = event.localPosition;
    _band = null;
  }

  void _onPointerMove(PointerMoveEvent event) {
    final start = _start;
    if (start == null) return;
    final band = Rect.fromPoints(start, event.localPosition);
    if (_band == null) {
      // 未达阈值:仍是普通按下,不绘制也不通知宿主
      if (band.shortestSide < widget.threshold) return;
      widget.onMarqueeStart?.call();
    }
    setState(() => _band = band);
    widget.onMarqueeUpdate?.call(band);
  }

  void _onPointerEnd() {
    if (_start == null) return;
    final wasBand = _band != null;
    _start = null;
    if (wasBand) {
      widget.onMarqueeEnd?.call();
      setState(() => _band = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final band = _band;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: widget.enabled ? _onPointerDown : null,
      onPointerMove: widget.enabled ? _onPointerMove : null,
      onPointerUp: widget.enabled ? (_) => _onPointerEnd() : null,
      onPointerCancel: widget.enabled ? (_) => _onPointerEnd() : null,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          widget.child,
          if (band != null)
            Positioned(
              left: band.left,
              top: band.top,
              width: band.width,
              height: band.height,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.primaryColor.withValues(alpha: 0.18),
                    border: Border.all(color: t.primaryColor, width: t.borderWidth),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
