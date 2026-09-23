import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// 单行时间微调框：`HH:MM:SS` + 右缘竖排上下按钮，与日历弹窗的时间区同构。
///
/// 三段各自可点选，**当前段**用强调色底标出；上下按钮 / 滚轮 / ↑↓ 键只作用于
/// 当前段并在各自的 24 / 60 进制上回环（23 → 00、59 → 00）。左右键切段，数字键
/// 累加（先按下的数字当作十位，装不下时自动前进到下一段），Backspace 退回上一段
/// 并清零。
///
/// 没有用 [TextField]：IME 与选区会把「哪一段是当前段」这套状态搅乱，而这里
/// 的取值永远是定宽的三段数字，自绘反而更准。
class TimeField extends StatefulWidget {
  const TimeField({
    super.key,
    required this.value,
    this.onChanged,
    this.tokens,
    this.height,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  /// 当前时间（只取时 / 分 / 秒，日期部分原样带回给 [onChanged]）。
  final DateTime value;

  /// 任一段变化时回调。
  final ValueChanged<DateTime>? onChanged;

  /// Token 覆盖；回退到外层 [TokenScope]，最后 [DesktopTokens.winForm]。
  final DesktopTokens? tokens;

  /// 控件高度，缺省取 [DesktopTokens.controlHeight]。
  final double? height;

  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  static const _hour = 0, _minute = 1, _second = 2;

  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  /// 当前编辑的段：0 时 / 1 分 / 2 秒。
  int _active = _hour;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  static int _maxOf(int segment) => segment == _hour ? 23 : 59;

  int _valueOf(int segment) => switch (segment) {
        _hour => widget.value.hour,
        _minute => widget.value.minute,
        _ => widget.value.second,
      };

  void _emit(int h, int m, int s) {
    final v = widget.value;
    widget.onChanged
        ?.call(DateTime(v.year, v.month, v.day, h, m, s));
  }

  void _setSegment(int segment, int next) {
    final max = _maxOf(segment);
    final wrapped = ((next % (max + 1)) + (max + 1)) % (max + 1);
    _emit(
      segment == _hour ? wrapped : _valueOf(_hour),
      segment == _minute ? wrapped : _valueOf(_minute),
      segment == _second ? wrapped : _valueOf(_second),
    );
  }

  void _step(int direction) {
    if (!widget.enabled) return;
    _focusNode.requestFocus();
    _setSegment(_active, _valueOf(_active) + direction);
  }

  void _moveActive(int direction) {
    if (!widget.enabled) return;
    setState(() => _active = (_active + direction).clamp(0, 2));
  }

  /// 数字键累加：`1` → `7` 得到 17；装不下时（小时已有 2 再按 9）改从该位重起。
  void _typeDigit(int d) {
    if (!widget.enabled) return;
    final max = _maxOf(_active);
    final cur = _valueOf(_active);
    final appended = cur * 10 + d;
    final next = appended <= max ? appended : d;
    _setSegment(_active, next);
    // 该段再也吃不下第二位数字就前进（时 / 分 / 秒都是两位定宽）
    if (next * 10 > max) _moveActive(1);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !widget.enabled) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _step(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _step(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveActive(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _moveActive(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      setState(() => _active = _hour);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      setState(() => _active = _second);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      _moveActive(-1);
      _setSegment(_active, 0);
      return KeyEventResult.handled;
    }
    final digit = _digitOf(key);
    if (digit != null) {
      _typeDigit(digit);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  static int? _digitOf(LogicalKeyboardKey key) {
    final main = key.keyLabel;
    if (main.length == 1 && main.codeUnitAt(0) >= 0x30 && main.codeUnitAt(0) <= 0x39) {
      return main.codeUnitAt(0) - 0x30;
    }
    final numpad = <LogicalKeyboardKey, int>{
      LogicalKeyboardKey.numpad0: 0,
      LogicalKeyboardKey.numpad1: 1,
      LogicalKeyboardKey.numpad2: 2,
      LogicalKeyboardKey.numpad3: 3,
      LogicalKeyboardKey.numpad4: 4,
      LogicalKeyboardKey.numpad5: 5,
      LogicalKeyboardKey.numpad6: 6,
      LogicalKeyboardKey.numpad7: 7,
      LogicalKeyboardKey.numpad8: 8,
      LogicalKeyboardKey.numpad9: 9,
    };
    return numpad[key];
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final h = widget.height ?? t.controlHeight;
    final focused = _focusNode.hasFocus;

    return Listener(
      onPointerSignal: (signal) {
        if (signal is! PointerScrollEvent) return;
        _step(signal.scrollDelta.dy > 0 ? -1 : 1);
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: widget.enabled,
        onKeyEvent: _handleKey,
        child: SizedBox(
          height: h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.enabled
                  ? t.surfaceColor
                  : t.controlDisabledColor,
              border: Border.all(
                color: widget.enabled && focused
                    ? t.primaryColor
                    : t.borderColor,
                width: t.borderWidth,
              ),
              borderRadius: BorderRadius.circular(t.cornerRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: t.controlPaddingX / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _segment(t, _hour),
                        _colon(t),
                        _segment(t, _minute),
                        _colon(t),
                        _segment(t, _second),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: h * 0.75,
                  height: h,
                  child: Column(
                    children: [
                      Expanded(
                        child: _SpinButton(
                          up: true,
                          tokens: t,
                          enabled: widget.enabled,
                          onTap: () => _step(1),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: t.borderWidth,
                        child: ColoredBox(color: t.borderColor),
                      ),
                      Expanded(
                        child: _SpinButton(
                          up: false,
                          tokens: t,
                          enabled: widget.enabled,
                          onTap: () => _step(-1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _colon(DesktopTokens t) => Text(
        ':',
        style: TextStyle(
          fontFamily: t.monoFontFamily,
          fontSize: t.fontSize,
          color: widget.enabled ? t.foregroundColor : t.disabledForegroundColor,
        ),
      );

  Widget _segment(DesktopTokens t, int segment) {
    final active = _active == segment && widget.enabled;
    final label = _valueOf(segment).toString().padLeft(2, '0');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!widget.enabled) return;
        setState(() => _active = segment);
        _focusNode.requestFocus();
      },
      child: Container(
        height: t.controlHeight - 8,
        padding: EdgeInsets.symmetric(horizontal: t.compactSpacing / 2),
        decoration: BoxDecoration(
          color: active ? t.primaryColor : null,
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: t.monoFontFamily,
            fontSize: t.fontSize,
            color: active
                ? t.accentForegroundColor
                : (widget.enabled
                    ? t.foregroundColor
                    : t.disabledForegroundColor),
          ),
        ),
      ),
    );
  }
}

/// 上下微调的一半按钮：无动画，hover / pressed 用叠加色（明暗自适应）。
class _SpinButton extends StatefulWidget {
  const _SpinButton({
    required this.up,
    required this.tokens,
    required this.enabled,
    required this.onTap,
  });

  final bool up;
  final DesktopTokens tokens;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<_SpinButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    Color? bg;
    if (widget.enabled && _pressed) {
      bg = t.pressedOverlayColor;
    } else if (widget.enabled && _hover) {
      bg = t.hoverOverlayColor;
    }
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.enabled ? widget.onTap : null,
        child: Container(
          color: bg,
          alignment: Alignment.center,
          child: Icon(
            widget.up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: t.fontSize + 6,
            color: widget.enabled
                ? t.foregroundColor
                : t.disabledForegroundColor,
          ),
        ),
      ),
    );
  }
}
