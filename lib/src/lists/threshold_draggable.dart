import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// 拖拽**起手**位移阈值(逻辑像素):位移未超过它不算拖动。
///
/// 取 4px 与 Windows 系统的拖拽容差(`SM_CXDRAG`,即双击时允许的手抖量)
/// 以及本库 [MarqueeSelector.threshold] 的默认值同一量级——
/// 小于它的是"手抖",不是"拖"。
const double kDragStartSlop = 4.0;

/// 起手带**位移阈值**的 [Draggable]:位移超过 [startSlop] 才算拖动,不拖不起手。
///
/// ## 为什么需要它
///
/// 框架 [Draggable] 有两条"没拖就先起手"的路径,桌面端单击 / 双击可见拖拽特效:
///
/// 1. **竞技场默认接受**:本识别器是竞技场唯一成员时(桌面端鼠标点一个拖拽源
///    通常就是这种情况——`Scrollable` 的拖拽识别器默认不接受鼠标),
///    `GestureArenaManager.close()` 会直接把这一手判给它,
///    [Draggable.onDragStarted] 在 pointer down 的微任务里就触发了,
///    指针一寸没动,浮层预览、[Draggable.childWhenDragging] 与宿主据此点亮的
///    放置区已经全部出现,松手再收回。
/// 2. **鼠标起手容差只有 1px**:框架对鼠标硬编码 `kPrecisePointerHitSlop`(1px,
///    只有触屏 / 触控板才读 `MediaQuery.gestureSettings.touchSlop`),
///    于是单击 / 双击时几像素的手抖就够判定成拖动。
///
/// 两者叠加的典型症状:**双击打开一行,却闪出拖拽浮层**。
///
/// ## 做法
///
/// * [startSlop] 把起手容差从 1px 提高到 4px(`kDragStartSlop`,与 Windows 的
///   `SM_CXDRAG` 同量级);
/// * 竞技场"判给本识别器"只代表**赢了手势竞争**,不再等同于"起手"——
///   位移没到阈值就先挂起,到了才真正起手,没到就作罢(不闪浮层)。
///
/// 因此按下即拖的手感不变(不引入 `LongPressDraggable` 那种"按住才拖"的时间延迟),
/// 只是不再把"按"当成"拖"。位移累计值会在真正起手时一次性补报给浮层,拖起来不跳。
///
/// 构造函数逐字段对齐 [Draggable],可直接替换。
class ThresholdDraggable<T extends Object> extends Draggable<T> {
  /// 创建一个起手带位移阈值的拖拽源,参数语义与 [Draggable] 完全相同。
  const ThresholdDraggable({
    super.key,
    required super.child,
    required super.feedback,
    super.data,
    super.axis,
    super.childWhenDragging,
    super.feedbackOffset,
    super.dragAnchorStrategy,
    super.affinity,
    super.maxSimultaneousDrags,
    super.onDragStarted,
    super.onDragUpdate,
    super.onDraggableCanceled,
    super.onDragEnd,
    super.onDragCompleted,
    super.ignoringFeedbackSemantics,
    super.ignoringFeedbackPointer,
    super.rootOverlay,
    super.hitTestBehavior,
    super.allowedButtonsFilter,
    this.startSlop = kDragStartSlop,
  }) : assert(startSlop >= 0, 'startSlop 不能为负');

  /// 起手阈值(逻辑像素):指针位移未超过它时**不会**进入拖动。
  ///
  /// 传 0 时退化为"按下即起手"(即框架 [Draggable] 在鼠标下的行为)。
  /// 调大会更"稳重",但过大会让拖动起手显得发黏;桌面端 4~6px 是合适区间。
  final double startSlop;

  @override
  MultiDragGestureRecognizer createRecognizer(GestureMultiDragStartCallback onStart) {
    return ThresholdMultiDragGestureRecognizer(
      affinity: affinity,
      slop: startSlop,
      allowedButtonsFilter: allowedButtonsFilter,
    )..onStart = onStart;
  }
}

/// 起手需要超过 [slop] 位移的多指针拖拽识别器。
///
/// 与 [ImmediateMultiDragGestureRecognizer] /
/// [HorizontalMultiDragGestureRecognizer] / [VerticalMultiDragGestureRecognizer]
/// 的两处差别:
///
/// * 位移未超过 [slop] 不判为拖动(框架用 1px / 18px 的固定容差);
/// * 被竞技场判定接受时若位移还不够,先挂起起手回调而不是立刻起手。
///
/// [ThresholdDraggable] 内部使用;宿主一般不需要直接构造它,
/// 除非用自己的 `RawGestureDetector` 接管拖拽。
class ThresholdMultiDragGestureRecognizer extends MultiDragGestureRecognizer {
  /// 创建一个起手带位移阈值的拖拽识别器。
  ThresholdMultiDragGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    this.affinity,
    this.slop = kDragStartSlop,
  }) : assert(slop >= 0, 'slop 不能为负');

  /// 限定起手方向:为 null 时任意方向的位移都算。
  final Axis? affinity;

  /// 起手阈值(逻辑像素)。
  final double slop;

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    return _ThresholdPointerState(
      event.position,
      event.kind,
      gestureSettings,
      affinity: affinity,
      slop: slop,
    );
  }

  @override
  String get debugDescription => 'threshold-multidrag';
}

/// 逐指针状态:把"多少位移算拖动"从框架常量换成调用方给的 [slop],
/// 并且把"竞技场接受了"与"真正起手"分开。
class _ThresholdPointerState extends MultiDragPointerState {
  _ThresholdPointerState(
    super.initialPosition,
    super.kind,
    super.gestureSettings, {
    required this.affinity,
    required this.slop,
  });

  final Axis? affinity;
  final double slop;

  /// 竞技场已把这一手判给本识别器,但位移还没到阈值——先把起手回调挂起。
  GestureMultiDragStartCallback? _deferredStart;

  /// 已经起手(或已把胜负交给竞技场),不再重复判定。
  bool _settled = false;

  /// 当前累计位移是否已超过阈值(只看 [affinity] 指定的轴)。
  bool get _movedEnough {
    final delta = pendingDelta;
    // 起手后框架会把 pendingDelta 置 null,此时不再有"位移不够"的判断
    if (delta == null) return false;
    final moved = switch (affinity) {
      Axis.horizontal => delta.dx.abs(),
      Axis.vertical => delta.dy.abs(),
      null => delta.distance,
    };
    return moved > slop;
  }

  @override
  void checkForResolutionAfterMove() {
    if (_settled || !_movedEnough) return;
    _settled = true;
    final deferred = _deferredStart;
    if (deferred != null) {
      // 竞技场早已判给本识别器(见 [accepted]),现在位移够了才真正起手
      _deferredStart = null;
      deferred(initialPosition);
    } else {
      // 还在竞技场里:位移够了,判本识别器胜出
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    if (_movedEnough) {
      _settled = true;
      starter(initialPosition);
      return;
    }
    // "竞技场接受了"≠"用户拖了":本识别器是唯一成员时 pointer down 就会被默认
    // 判给它。此处不立刻起手,等 checkForResolutionAfterMove 看到位移够阈值。
    // 指针抬起前始终没到阈值的话,回调就此作废——不闪浮层、不触发 onDragStarted。
    _deferredStart = starter;
  }

  @override
  void rejected() {
    _deferredStart = null;
    super.rejected();
  }
}
