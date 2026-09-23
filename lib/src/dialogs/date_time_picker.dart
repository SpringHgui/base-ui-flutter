import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../form/time_field.dart';
import 'month_calendar.dart';

/// The mode of a [DateTimePicker].
enum DateTimePickerMode { date, time, dateTime }

/// 日期 / 时间选择器内的全部文案与标题模板。
///
/// 库内默认英文（与 `ComboBox.searchHint` 同一约定）：宿主用自己的语言传一份，
/// 例如中文宿主传 `DateTimePickerLabels(ok: '确定', today: '今天', ...)`。
///
/// 标题是**模板**而不是格式化函数，好让 `const` 构造仍然成立：`{year}` /
/// `{month}` / `{monthName}` / `{from}` / `{to}` 会在渲染时被替换，
/// 于是中文写 `'{year}年{month}月'`、英文写 `'{monthName} {year}'` 都能表达。
@immutable
class DateTimePickerLabels {
  const DateTimePickerLabels({
    this.ok = 'OK',
    this.cancel = 'Cancel',
    this.selectTime = 'Select Time',
    this.today = 'Today',
    this.weekdayLabels = defaultWeekdayLabels,
    this.monthNames = defaultMonthNames,
    this.monthTitle = '{monthName} {year}',
    this.yearTitle = '{year}',
    this.yearRangeTitle = '{from} - {to}',
  });

  final String ok;
  final String cancel;

  /// 仅时间弹窗的标题。
  final String selectTime;

  /// 日历底部「今天: 2026/9/23」的前缀。
  final String today;

  /// 星期表头，**周一开头**共 7 项。
  final List<String> weekdayLabels;

  /// 12 个月名（月份快选视图与日视图标题共用）。
  final List<String> monthNames;

  /// 日视图顶栏标题模板。
  final String monthTitle;

  /// 月份快选视图顶栏标题模板。
  final String yearTitle;

  /// 年份快选视图顶栏标题模板（12 年一档的区间两端）。
  final String yearRangeTitle;

  /// 把 [template] 里的 `{key}` 换成 [values] 对应值。
  String fill(String template, Map<String, String> values) {
    var s = template;
    for (final e in values.entries) {
      s = s.replaceAll('{${e.key}}', e.value);
    }
    return s;
  }

  static const List<String> defaultWeekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> defaultMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

/// 打开日期 / 时间 / 日期时间选择弹窗，返回用户确认的值；取消返回 `null`。
///
/// [value] 为初始值：`date` 模式只换日期、保留其时间部分，`time` 模式只换时间、
/// 保留其日期部分，两者在 [value] 为 `null` 时都从当前时刻起算。
/// [DateTimePicker] 自身即走本入口，宿主想在自己的字段里挂一个「…」选择按钮时
/// 直接调用即可，无需复制弹窗结构。
Future<DateTime?> showDateTimePickerDialog(
  BuildContext context, {
  DateTimePickerMode mode = DateTimePickerMode.dateTime,
  DateTime? value,
  DateTime? minDate,
  DateTime? maxDate,
  DateTimePickerLabels labels = const DateTimePickerLabels(),
}) {
  final initial = value ?? DateTime.now();
  final dialog = switch (mode) {
    DateTimePickerMode.date => _DatePickDialog(
        initial: initial,
        minDate: minDate,
        maxDate: maxDate,
        labels: labels,
      ),
    DateTimePickerMode.time =>
      _TimePickDialog(initial: initial, labels: labels),
    DateTimePickerMode.dateTime => _DateTimePickDialog(
        initial: initial,
        minDate: minDate,
        maxDate: maxDate,
        labels: labels,
      ),
  };
  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (_) => dialog,
  );
}

/// 按 [mode] 的默认格式渲染日期时间值（`yyyy-MM-dd` / `HH:mm:ss` / 两者）。
String formatDateTimeByMode(DateTime dt, DateTimePickerMode mode) {
  return DateTimePicker._format(dt, DateTimePicker._defaultFormat(mode));
}

/// 解析行内文本为日期时间：接受 `2022-12-12 20:13:06` 这类带空格的库内格式，
/// 以及裸时间 `20:13:06`（`time` 列的取值，锚到今天）。
DateTime? parseDateTimeField(String text) {
  final s = text.trim();
  if (s.isEmpty) return null;
  final bareTime = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(s);
  if (bareTime != null) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(bareTime.group(1)!),
      int.parse(bareTime.group(2)!),
      int.parse(bareTime.group(3) ?? '0'),
    );
  }
  return DateTime.tryParse(s) ?? DateTime.tryParse(s.replaceFirst(' ', 'T'));
}

/// A WinForm-style date/time picker.
///
/// Displays a read-only text field with a drop-down calendar or time picker.
class DateTimePicker extends StatefulWidget {
  const DateTimePicker({
    super.key,
    required this.value,
    this.onChanged,
    this.mode = DateTimePickerMode.date,
    this.minDate,
    this.maxDate,
    this.format,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.hint,
    this.labels = const DateTimePickerLabels(),
  });

  /// The currently selected date/time, or `null` when nothing is selected.
  final DateTime? value;

  /// Called when the user picks a new date/time.
  final ValueChanged<DateTime?>? onChanged;

  /// Which picker mode to use: date only, time only, or both.
  final DateTimePickerMode mode;

  /// Earliest selectable date.
  final DateTime? minDate;

  /// Latest selectable date.
  final DateTime? maxDate;

  /// Custom format string. When `null`, a default is chosen based on [mode].
  final String? format;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the picker should focus itself when first built.
  final bool autofocus;

  /// Whether the picker is interactive.
  final bool enabled;

  /// Placeholder shown when nothing is selected.
  final String? hint;

  /// 选择弹窗内的文案；默认英文，宿主按自己的语言传一份。
  final DateTimePickerLabels labels;

  static String _defaultFormat(DateTimePickerMode mode) {
    switch (mode) {
      case DateTimePickerMode.date:
        return 'yyyy-MM-dd';
      case DateTimePickerMode.time:
        return 'HH:mm:ss';
      case DateTimePickerMode.dateTime:
        return 'yyyy-MM-dd HH:mm:ss';
    }
  }

  static String _format(DateTime dt, String fmt) {
    String pad(int n, [int w = 2]) => n.toString().padLeft(w, '0');
    return fmt
        .replaceAll('yyyy', pad(dt.year, 4))
        .replaceAll('MM', pad(dt.month))
        .replaceAll('dd', pad(dt.day))
        .replaceAll('HH', pad(dt.hour))
        .replaceAll('mm', pad(dt.minute))
        .replaceAll('ss', pad(dt.second));
  }

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

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

  String _displayText() {
    if (widget.value == null) return widget.hint ?? '';
    final fmt = widget.format ?? DateTimePicker._defaultFormat(widget.mode);
    return DateTimePicker._format(widget.value!, fmt);
  }

  Future<void> _openPicker() async {
    if (!widget.enabled) return;
    final picked = await showDateTimePickerDialog(
      context,
      mode: widget.mode,
      value: widget.value,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      labels: widget.labels,
    );
    if (picked != null && picked != widget.value) {
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final focused = _focusNode.hasFocus;

    final borderColor = !widget.enabled
        ? t.borderColor
        : (focused ? t.primaryColor : t.borderColor);
    final fillColor = widget.enabled ? t.surfaceColor : t.controlDisabledColor;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: GestureDetector(
        onTap: _openPicker,
        child: SizedBox(
          height: t.controlHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              border: Border.all(color: borderColor, width: t.borderWidth),
              borderRadius: BorderRadius.circular(t.cornerRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: t.controlPaddingX),
                    child: Text(
                      _displayText(),
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: t.fontSize,
                        color: widget.enabled
                            ? t.foregroundColor
                            : t.disabledForegroundColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: t.compactSpacing),
                  child: Icon(
                    widget.mode == DateTimePickerMode.time
                        ? Icons.access_time
                        : Icons.calendar_today,
                    size: t.fontSize,
                    color: widget.enabled
                        ? t.foregroundColor
                        : t.disabledForegroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// _DatePickDialog — WinForm-style date picker using MonthCalendar
// ===========================================================================

class _DatePickDialog extends StatefulWidget {
  const _DatePickDialog({
    required this.initial,
    this.minDate,
    this.maxDate,
    required this.labels,
  });

  final DateTime initial;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateTimePickerLabels labels;

  @override
  State<_DatePickDialog> createState() => _DatePickDialogState();
}

class _DatePickDialogState extends State<_DatePickDialog> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return _PickerShell(
      width: 264,
      tokens: t,
      children: [
        MonthCalendar(
          selectedDate: _selected,
          onDateSelected: (d) => setState(() => _selected = d),
          displayMonth: _selected,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          labels: widget.labels,
          tokens: t,
        ),
        _DialogButtonRow(
          labels: widget.labels,
          tokens: t,
          onOk: () {
            // 只换日期，时间部分沿用初始值
            Navigator.of(context).pop(DateTime(
              _selected.year,
              _selected.month,
              _selected.day,
              widget.initial.hour,
              widget.initial.minute,
              widget.initial.second,
            ));
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// ===========================================================================
// _DateTimePickDialog — combined date + time picker in one dialog
// ===========================================================================

class _DateTimePickDialog extends StatefulWidget {
  const _DateTimePickDialog({
    required this.initial,
    this.minDate,
    this.maxDate,
    required this.labels,
  });

  final DateTime initial;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateTimePickerLabels labels;

  @override
  State<_DateTimePickDialog> createState() => _DateTimePickDialogState();
}

class _DateTimePickDialogState extends State<_DateTimePickDialog> {
  late DateTime _selectedDate;
  late int _hour;
  late int _minute;
  late int _second;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initial;
    _hour = widget.initial.hour;
    _minute = widget.initial.minute;
    _second = widget.initial.second;
  }

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return _PickerShell(
      width: 264,
      tokens: t,
      children: [
        MonthCalendar(
          selectedDate: _selectedDate,
          onDateSelected: (d) => setState(() => _selectedDate = d),
          displayMonth: _selectedDate,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          labels: widget.labels,
          tokens: t,
        ),
        SizedBox(height: t.compactSpacing * 2),
        // 时间区:单行 HH:MM:SS + 右缘上下微调,选中哪段调哪段
        TimeField(
          value: DateTime(2000, 1, 1, _hour, _minute, _second),
          tokens: t,
          onChanged: (v) => setState(() {
            _hour = v.hour;
            _minute = v.minute;
            _second = v.second;
          }),
        ),
        _DialogButtonRow(
          labels: widget.labels,
          tokens: t,
          onOk: () {
            Navigator.of(context).pop(DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _hour,
              _minute,
              _second,
            ));
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// ===========================================================================
// _TimePickDialog — WinForm-style time picker using NumericUpDown
// ===========================================================================

class _TimePickDialog extends StatefulWidget {
  const _TimePickDialog({
    required this.initial,
    required this.labels,
  });

  final DateTime initial;
  final DateTimePickerLabels labels;

  @override
  State<_TimePickDialog> createState() => _TimePickDialogState();
}

class _TimePickDialogState extends State<_TimePickDialog> {
  late int _hour;
  late int _minute;
  late int _second;

  @override
  void initState() {
    super.initState();
    _hour = widget.initial.hour;
    _minute = widget.initial.minute;
    _second = widget.initial.second;
  }

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return _PickerShell(
      width: 200,
      tokens: t,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labels.selectTime,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize + 1,
            fontWeight: FontWeight.w600,
            color: t.foregroundColor,
          ),
        ),
        SizedBox(height: t.compactSpacing * 2),
        TimeField(
          value: DateTime(2000, 1, 1, _hour, _minute, _second),
          tokens: t,
          onChanged: (v) => setState(() {
            _hour = v.hour;
            _minute = v.minute;
            _second = v.second;
          }),
        ),
        _DialogButtonRow(
          labels: widget.labels,
          tokens: t,
          onOk: () {
            // 只换时间，日期部分沿用初始值
            Navigator.of(context).pop(DateTime(
              widget.initial.year,
              widget.initial.month,
              widget.initial.day,
              _hour,
              _minute,
              _second,
            ));
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// ===========================================================================
// _DialogButton — shared OK/Cancel button for picker dialogs
// ===========================================================================

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.text,
    required this.tokens,
    this.onPressed,
  });

  final String text;
  final DesktopTokens tokens;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: t.controlHeight,
        padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX * 2),
        decoration: BoxDecoration(
          color: t.controlColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: t.foregroundColor,
          ),
        ),
      ),
    );
  }
}

/// 三个选择弹窗共用的外壳：居中、定宽、带边框的浮层卡片。
///
/// `showDialog` 的 builder 挂在 Overlay 里，脱离 MaterialApp 的 Material 宿主，
/// 因此这里补一层透明 [Material] 给内部文本 / 输入控件当祖先。
class _PickerShell extends StatelessWidget {
  const _PickerShell({
    required this.width,
    required this.tokens,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final double width;
  final DesktopTokens tokens;
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Center(
      child: SizedBox(
        width: width,
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.controlColor,
              border: Border.all(color: t.borderColor, width: t.borderWidth),
              borderRadius: BorderRadius.circular(t.cornerRadius),
            ),
            child: Padding(
              padding: EdgeInsets.all(t.compactSpacing * 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: crossAxisAlignment,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 底部「确定 / 取消」：整组居中，与参考图一致。
class _DialogButtonRow extends StatelessWidget {
  const _DialogButtonRow({
    required this.labels,
    required this.tokens,
    required this.onOk,
    required this.onCancel,
  });

  final DateTimePickerLabels labels;
  final DesktopTokens tokens;
  final VoidCallback onOk;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Padding(
      padding: EdgeInsets.only(top: t.compactSpacing * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DialogButton(text: labels.ok, tokens: t, onPressed: onOk),
          SizedBox(width: t.compactSpacing * 2),
          _DialogButton(text: labels.cancel, tokens: t, onPressed: onCancel),
        ],
      ),
    );
  }
}
