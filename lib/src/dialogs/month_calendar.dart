import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'date_time_picker.dart';

/// 日历的三段视图：日格 / 月份快选 / 年份快选。
enum CalendarView { day, month, year }

/// A WinForm / Navicat-style month calendar.
///
/// 顶栏 `◀ 标题 ▶`：**点标题**进入月份快选（4×3），在月份视图里再点标题进入
/// 年份快选（12 年一档）。左右箭头在当前视图上步进一档（月 / 年 / 12 年）。
///
/// 日格固定 6 周，月外日子按参考图画成灰显而不是留白——点它会选中该日并翻到
/// 所属月份。底部「今天: yyyy/m/d」带一枚选中色图例方块。
///
/// 文案全部来自 [labels]（库内默认英文），范围由 [minDate] / [maxDate] 限定：
/// 越界的月 / 年 / 日一律灰显且不可点。
class MonthCalendar extends StatefulWidget {
  const MonthCalendar({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.displayMonth,
    this.minDate,
    this.maxDate,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.labels = const DateTimePickerLabels(),
    this.view = CalendarView.day,
  });

  /// The currently selected date, or `null`.
  final DateTime? selectedDate;

  /// Called when the user taps a date.
  final ValueChanged<DateTime>? onDateSelected;

  /// The month being displayed. Defaults to the current month.
  final DateTime? displayMonth;

  /// Earliest selectable date.
  final DateTime? minDate;

  /// Latest selectable date.
  final DateTime? maxDate;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the calendar should focus itself when first built.
  final bool autofocus;

  /// Whether the calendar is interactive.
  final bool enabled;

  /// 日历内的全部字面量（星期表头 / 月名 / 顶栏标题模板 / 今天行）。
  final DateTimePickerLabels labels;

  /// 初始视图。组件自身持有切换状态，宿主只在需要外部复位时改这个值。
  final CalendarView view;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _displayMonth;
  late CalendarView _view;
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _displayMonth = widget.displayMonth ?? DateTime.now();
    _view = widget.view;
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(covariant MonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayMonth != null &&
        widget.displayMonth != oldWidget.displayMonth) {
      _displayMonth = widget.displayMonth!;
    }
    if (widget.view != oldWidget.view) _view = widget.view;
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  /// 左右箭头：日视图步进一个月，月 / 年视图步进一年 / 12 年。
  void _step(int direction) {
    setState(() {
      switch (_view) {
        case CalendarView.day:
          _displayMonth =
              DateTime(_displayMonth.year, _displayMonth.month + direction);
        case CalendarView.month:
          _displayMonth =
              DateTime(_displayMonth.year + direction, _displayMonth.month);
        case CalendarView.year:
          _displayMonth = DateTime(
              _displayMonth.year + direction * _yearBlockSize,
              _displayMonth.month);
      }
    });
  }

  static const int _yearBlockSize = 12;

  /// 年份视图那一档的起始年（12 年一档，按档取整，故 2026 → 2016..2027）。
  int get _yearBlockStart {
    final y = _displayMonth.year;
    return y - _mod(y, _yearBlockSize);
  }

  static int _mod(int a, int b) => ((a % b) + b) % b;

  void _pickMonth(int month) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, month);
      _view = CalendarView.day;
    });
  }

  void _pickYear(int year) {
    setState(() {
      _displayMonth = DateTime(year, _displayMonth.month);
      _view = CalendarView.month;
    });
  }

  /// 点顶栏标题：日 → 月快选，月 → 年快选，年 → 回日视图。
  void _cycleView() {
    if (!widget.enabled) return;
    setState(() {
      _view = switch (_view) {
        CalendarView.day => CalendarView.month,
        CalendarView.month => CalendarView.year,
        CalendarView.year => CalendarView.day,
      };
    });
  }

  bool _dayInRange(DateTime date) {
    if (widget.minDate != null && date.isBefore(widget.minDate!)) return false;
    if (widget.maxDate != null && date.isAfter(widget.maxDate!)) return false;
    return true;
  }

  bool _monthInRange(int year, int month) {
    final first = DateTime(year, month);
    final last = DateTime(year, month + 1, 0);
    if (widget.minDate != null && last.isBefore(widget.minDate!)) return false;
    if (widget.maxDate != null && first.isAfter(widget.maxDate!)) return false;
    return true;
  }

  bool _yearInRange(int year) {
    final first = DateTime(year);
    final last = DateTime(year, 12, 31);
    if (widget.minDate != null && last.isBefore(widget.minDate!)) return false;
    if (widget.maxDate != null && first.isAfter(widget.maxDate!)) return false;
    return true;
  }

  void _selectDate(DateTime date) {
    if (!widget.enabled || !_dayInRange(date)) return;
    widget.onDateSelected?.call(date);
    // 点邻月日子时跟着翻到那个月，与参考实现一致
    if (date.month != _displayMonth.month ||
        date.year != _displayMonth.year) {
      setState(() => _displayMonth = DateTime(date.year, date.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.enabled ? t.surfaceColor : t.controlDisabledColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(t.compactSpacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(t),
              SizedBox(height: t.compactSpacing),
              switch (_view) {
                CalendarView.day => _dayGrid(t),
                CalendarView.month => _monthGrid(t),
                CalendarView.year => _yearGrid(t),
              },
              if (_view == CalendarView.day) ...[
                SizedBox(height: t.compactSpacing),
                _todayRow(t),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 顶栏：`◀ 标题 ▶`，标题可点进入下一级快选。
  Widget _header(DesktopTokens t) {
    final l = widget.labels;
    final title = switch (_view) {
      CalendarView.day => l.fill(l.monthTitle, {
          'year': '${_displayMonth.year}',
          'month': '${_displayMonth.month}',
          'monthName': l.monthNames[_displayMonth.month - 1],
        }),
      CalendarView.month =>
        l.fill(l.yearTitle, {'year': '${_displayMonth.year}'}),
      CalendarView.year => l.fill(l.yearRangeTitle, {
          'from': '$_yearBlockStart',
          'to': '${_yearBlockStart + _yearBlockSize - 1}',
        }),
    };
    return Row(
      children: [
        _navArrow(t, Icons.arrow_left, () => _step(-1)),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? _cycleView : null,
            child: SizedBox(
              height: t.controlHeight,
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize,
                    fontWeight: FontWeight.w600,
                    color: widget.enabled
                        ? t.foregroundColor
                        : t.disabledForegroundColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        _navArrow(t, Icons.arrow_right, () => _step(1)),
      ],
    );
  }

  Widget _navArrow(DesktopTokens t, IconData icon, VoidCallback onTap) {
    final enabled = widget.enabled;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: t.controlHeight,
        height: t.controlHeight,
        child: Icon(
          icon,
          size: t.fontSize + 8,
          color: enabled ? t.foregroundColor : t.disabledForegroundColor,
        ),
      ),
    );
  }

  /// 日格：固定 6 周，月外日子灰显。
  Widget _dayGrid(DesktopTokens t) {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    // 网格从本月 1 号所在周的周一起，共 42 格
    final gridStart =
        firstDay.subtract(Duration(days: firstDay.weekday - 1));
    final today = _dateOnly(DateTime.now());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 星期表头
        Row(
          children: List.generate(7, (i) {
            return Expanded(
              child: Center(
                child: SizedBox(
                  height: t.fontSize + 6,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.labels.weekdayLabels[i],
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: t.fontSize - 1,
                        fontWeight: FontWeight.w600,
                        color: t.foregroundColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: t.compactSpacing / 2),
        ...List.generate(6, (week) {
          return Row(
            children: List.generate(7, (dow) {
              final date =
                  gridStart.add(Duration(days: week * 7 + dow));
              return Expanded(
                child: _dayCell(
                  t,
                  date,
                  inMonth: date.month == _displayMonth.month,
                  isToday: date == today,
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Widget _dayCell(DesktopTokens t, DateTime date,
      {required bool inMonth, required bool isToday}) {
    final selected = widget.selectedDate != null &&
        _dateOnly(widget.selectedDate!) == date;
    final enabled = widget.enabled && _dayInRange(date);

    final Color fg;
    if (!enabled) {
      fg = t.disabledForegroundColor;
    } else if (selected) {
      fg = t.foregroundColor;
    } else if (!inMonth) {
      fg = t.disabledForegroundColor;
    } else if (isToday) {
      fg = t.primaryColor;
    } else {
      fg = t.foregroundColor;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => _selectDate(date) : null,
      child: Center(
        child: Container(
          width: t.fontSize * 2 + 8,
          height: t.fontSize * 2 + 4,
          decoration: BoxDecoration(
            color: selected ? t.secondaryColor : null,
            borderRadius: BorderRadius.circular(t.cornerRadius),
            border: selected
                ? Border.all(color: t.borderColor, width: t.borderWidth)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  /// 月份快选：本年的 12 个月，4 行 3 列。
  Widget _monthGrid(DesktopTokens t) {
    return _pickGrid(
      t,
      count: 12,
      labelOf: (i) => widget.labels.monthNames[i],
      enabledOf: (i) => _monthInRange(_displayMonth.year, i + 1),
      selectedOf: (i) =>
          widget.selectedDate != null &&
          widget.selectedDate!.year == _displayMonth.year &&
          widget.selectedDate!.month == i + 1,
      onPick: (i) => _pickMonth(i + 1),
    );
  }

  /// 年份快选：12 年一档。
  Widget _yearGrid(DesktopTokens t) {
    final start = _yearBlockStart;
    return _pickGrid(
      t,
      count: 12,
      labelOf: (i) => '${start + i}',
      enabledOf: (i) => _yearInRange(start + i),
      selectedOf: (i) =>
          widget.selectedDate != null &&
          widget.selectedDate!.year == start + i,
      onPick: (i) => _pickYear(start + i),
    );
  }

  Widget _pickGrid(
    DesktopTokens t, {
    required int count,
    required String Function(int index) labelOf,
    required bool Function(int index) enabledOf,
    required bool Function(int index) selectedOf,
    required ValueChanged<int> onPick,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row * 3 < count; row++)
          Row(
            children: [
              for (var col = 0; col < 3; col++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(t.compactSpacing / 2),
                    child: _pickCell(
                      t,
                      labelOf(row * 3 + col),
                      enabled: widget.enabled && enabledOf(row * 3 + col),
                      selected: selectedOf(row * 3 + col),
                      onTap: () => onPick(row * 3 + col),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _pickCell(DesktopTokens t, String label,
      {required bool enabled,
      required bool selected,
      required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Container(
        height: t.controlHeight,
        decoration: BoxDecoration(
          color: selected ? t.secondaryColor : null,
          borderRadius: BorderRadius.circular(t.cornerRadius),
          border: Border.all(
            color: selected ? t.borderColor : Colors.transparent,
            width: t.borderWidth,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: !enabled
                ? t.disabledForegroundColor
                : t.foregroundColor,
          ),
        ),
      ),
    );
  }

  /// 底部「今天」行：左侧一枚选中色图例方块。
  Widget _todayRow(DesktopTokens t) {
    final today = DateTime.now();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: t.compactSpacing / 2),
      child: Row(
        children: [
          Container(
            width: t.fontSize,
            height: t.fontSize - 4,
            decoration: BoxDecoration(
              color: t.secondaryColor,
              border: Border.all(color: t.borderColor, width: t.borderWidth),
            ),
          ),
          SizedBox(width: t.compactSpacing),
          Text(
            '${widget.labels.today}: ${today.year}/${today.month}/${today.day}',
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize - 1,
              color: t.foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
