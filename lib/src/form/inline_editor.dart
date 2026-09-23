import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/input.dart';
import '../common/icon_button.dart';
import '../dialogs/date_time_picker.dart';
import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// 单元格内联编辑器:构建后自动聚焦,Enter / 失焦提交,Esc 取消。
///
/// 防双触发:提交或取消后失焦回调不再二次提交。视觉完全由
/// [DesktopTokens] 驱动(内部复用 [Input])。
///
/// [datePickerMode] 非空时在字段右缘挂一个日历 / 时钟按钮,点击弹出
/// [showDateTimePickerDialog] 选值并写回文本(选值期间不会因失焦而提交)。
class InlineEditor extends StatefulWidget {
  const InlineEditor({
    super.key,
    required this.initialValue,
    required this.onCommit,
    this.onChanged,
    this.onCancel,
    this.height,
    this.tokens,
    this.contentPadding,
    this.selectAll = false,
    this.textAlign,
    this.datePickerMode,
    this.datePickerLabels,
  });

  /// 初始文本。
  final String initialValue;

  /// 提交回调(Enter / 失焦)。
  final ValueChanged<String> onCommit;

  /// 每次文本变化时回调(可用于实时标记 dirty 等)。
  final ValueChanged<String>? onChanged;

  /// 取消回调(Esc)。
  final VoidCallback? onCancel;

  /// 编辑框高度;默认 [DesktopTokens.controlHeight]。
  final double? height;

  /// Token 覆盖;回退到外层 [TokenScope],最后 [DesktopTokens.winForm]。
  final DesktopTokens? tokens;

  /// 内边距覆盖;传 [EdgeInsets.zero] 可消除与外层容器的双重间距。
  final EdgeInsetsGeometry? contentPadding;

  /// 进入编辑时是否全选初始文本(如节点改名,直接键入即覆盖)。
  /// 默认 false:光标置于文本末尾。
  final bool selectAll;

  /// 文本对齐。表格数值列右对齐时传入 [TextAlign.end],编辑态与显示态才不跳位。
  final TextAlign? textAlign;

  /// 非空时在字段右缘挂日期时间选择按钮,并决定弹窗模式与写回的格式。
  final DateTimePickerMode? datePickerMode;

  /// 选择弹窗内的文案(确定 / 取消 / 星期表头等);null 用组件默认(英文)。
  final DateTimePickerLabels? datePickerLabels;

  @override
  State<InlineEditor> createState() => _InlineEditorState();
}

class _InlineEditorState extends State<InlineEditor> {
  // 初始选区按 selectAll 决定:全选(改名即键入覆盖)或光标置于文本末尾。
  // 两层防护:
  // 1. controller 预设合法选区,挡掉 TextField 聚焦时"选区无效 → 兜底"的路径;
  // 2. 显式 selectAllOnFocus —— 桌面平台(Win/Linux/macOS)默认 true,
  //    聚焦时会无条件全选,预设选区挡不住,必须跟随 widget.selectAll。
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue)
        ..selection = widget.selectAll
            ? TextSelection(baseOffset: 0, extentOffset: widget.initialValue.length)
            : TextSelection.collapsed(offset: widget.initialValue.length);
  late final FocusNode _focusNode = FocusNode();

  /// 防止提交/取消后失焦回调二次触发。
  bool _finished = false;

  /// 是否已按 Esc 取消(取消后失焦不再提交)。
  bool _cancelled = false;

  /// 日期时间选择弹窗打开中:期间的失焦是弹窗抢走焦点，不是用户离开编辑器。
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    // 构建完成后主动聚焦输入框,直接进入可输入状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    if (_finished || _cancelled) return;
    _finished = true;
    widget.onCommit(_controller.text);
  }

  Future<void> _openDatePicker() async {
    final mode = widget.datePickerMode;
    if (mode == null || _picking || _finished || _cancelled) return;
    _picking = true;
    final picked = await showDateTimePickerDialog(
      context,
      mode: mode,
      value: parseDateTimeField(_controller.text),
      labels: widget.datePickerLabels ?? const DateTimePickerLabels(),
    );
    _picking = false;
    if (!mounted || _finished || _cancelled) return;
    if (picked != null) {
      final text = formatDateTimeByMode(picked, mode);
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    // 弹窗收走焦点后编辑器仍在编辑态,把光标还回去
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final h = widget.height ?? t.controlHeight;
    final mode = widget.datePickerMode;
    return Focus(
      // Esc 取消编辑(按键沿焦点链上冒,输入框聚焦时也能拦截)
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _cancelled = true;
          widget.onCancel?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      // 点击别处失焦 → 提交（选择弹窗打开期间的失焦不算离开）
      onFocusChange: (focused) {
        if (!focused && !_picking) _finish();
      },
      child: SizedBox(
        height: h,
        child: Input(
          controller: _controller,
          focusNode: _focusNode,
          tokens: t,
          height: h,
          textAlign: widget.textAlign,
          contentPadding: widget.contentPadding,
          // 聚焦全选行为跟随 widget.selectAll(桌面平台默认全选,不显式传会覆盖光标末尾模式)
          selectAllOnFocus: widget.selectAll,
          onSubmitted: (_) => _finish(),
          trailing: mode == null
              ? null
              : IconBtn(
                  icon: mode == DateTimePickerMode.time
                      ? Icons.access_time
                      : Icons.calendar_today,
                  iconSize: (h - 12).clamp(11.0, 15.0),
                  size: Size(h, h),
                  color: t.foregroundColor,
                  tokens: t,
                  onTap: _openDatePicker,
                ),
        ),
      ),
    );
  }
}
