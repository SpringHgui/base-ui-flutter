import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style month calendar.
///
/// Displays a single month grid with selectable dates. Navigation between
/// months is provided via header arrows.
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

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _displayMonth;
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  static const _weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  void initState() {
    super.initState();
    _displayMonth = widget.displayMonth ?? DateTime.now();
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
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  bool _isInRange(DateTime date) {
    if (widget.minDate != null && date.isBefore(widget.minDate!)) return false;
    if (widget.maxDate != null && date.isAfter(widget.maxDate!)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    // Monday = 0
    final startWeekday = (firstDay.weekday - 1) % 7;
    // Only render the weeks this month actually occupies (4-6) instead
    // of a fixed 6-row grid with empty trailing rows.
    final weekCount = ((startWeekday + daysInMonth + 6) ~/ 7).clamp(4, 6);

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.enabled ? _prevMonth : null,
                    child: Icon(Icons.chevron_left,
                        size: t.fontSize + 4, color: t.foregroundColor),
                  ),
                  Text(
                    '${_displayMonth.year}-${_displayMonth.month.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize,
                      fontWeight: FontWeight.w600,
                      color: t.foregroundColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.enabled ? _nextMonth : null,
                    child: Icon(Icons.chevron_right,
                        size: t.fontSize + 4, color: t.foregroundColor),
                  ),
                ],
              ),
              SizedBox(height: t.compactSpacing),
              // Weekday headers
              Row(
                children: _weekdays
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: TextStyle(
                                  fontFamily: t.fontFamily,
                                  fontSize: t.fontSize - 1,
                                  color: t.disabledForegroundColor,
                                )),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: t.compactSpacing),
              // Day grid
              ...List.generate(weekCount, (week) {
                return Row(
                  children: List.generate(7, (day) {
                    final idx = week * 7 + day - startWeekday;
                    final isValid = idx >= 0 && idx < daysInMonth;
                    final date = isValid
                        ? DateTime(
                            _displayMonth.year, _displayMonth.month, idx + 1)
                        : null;
                    final isSelected = date != null &&
                        widget.selectedDate != null &&
                        date.year == widget.selectedDate!.year &&
                        date.month == widget.selectedDate!.month &&
                        date.day == widget.selectedDate!.day;
                    final inRange = date != null && _isInRange(date);

                    return Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: isValid
                            ? GestureDetector(
                                onTap: widget.enabled && inRange
                                    ? () =>
                                        widget.onDateSelected?.call(date)
                                    : null,
                                child: Container(
                                  margin: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? t.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        t.cornerRadius),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${date!.day}',
                                    style: TextStyle(
                                      fontFamily: t.fontFamily,
                                      fontSize: t.fontSize,
                                      color: !inRange
                                          ? t.disabledForegroundColor
                                          : isSelected
                                              ? t.surfaceColor
                                              : t.foregroundColor,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
