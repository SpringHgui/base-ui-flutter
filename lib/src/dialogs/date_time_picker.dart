import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/numeric_up_down.dart';
import 'month_calendar.dart';

/// The mode of a [DateTimePicker].
enum DateTimePickerMode { date, time, dateTime }

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
    final fmt = widget.format ?? _defaultFormat(widget.mode);
    return _formatDate(widget.value!, fmt);
  }

  String _defaultFormat(DateTimePickerMode mode) {
    switch (mode) {
      case DateTimePickerMode.date:
        return 'yyyy-MM-dd';
      case DateTimePickerMode.time:
        return 'HH:mm:ss';
      case DateTimePickerMode.dateTime:
        return 'yyyy-MM-dd HH:mm:ss';
    }
  }

  String _formatDate(DateTime dt, String fmt) {
    String pad(int n, [int w = 2]) => n.toString().padLeft(w, '0');
    return fmt
        .replaceAll('yyyy', pad(dt.year, 4))
        .replaceAll('MM', pad(dt.month))
        .replaceAll('dd', pad(dt.day))
        .replaceAll('HH', pad(dt.hour))
        .replaceAll('mm', pad(dt.minute))
        .replaceAll('ss', pad(dt.second));
  }

  // ── Custom WinForm-style picker dialogs ───────────────────────────────

  Future<void> _pickDate() async {
    final now = widget.value ?? DateTime.now();
    // null until the user confirms. Initialising with `now` would make
    // a Cancel commit the current time as if it were a real selection.
    DateTime? tempDate;

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return _DatePickDialog(
          initialDate: now,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          onDateChanged: (d) => tempDate = d,
        );
      },
    );

    if (tempDate != null && tempDate != widget.value) {
      final current = widget.value ?? DateTime.now();
      final merged = DateTime(
        tempDate!.year,
        tempDate!.month,
        tempDate!.day,
        current.hour,
        current.minute,
        current.second,
      );
      widget.onChanged?.call(merged);
    }
  }

  Future<void> _pickTime() async {
    final now = widget.value ?? DateTime.now();
    int? hour, minute, second;

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return _TimePickDialog(
          initialTime: TimeOfDay.fromDateTime(now),
          onTimeChanged: (h, m, s) {
            hour = h;
            minute = m;
            second = s;
          },
        );
      },
    );

    if (hour != null && minute != null && second != null) {
      final current = widget.value ?? DateTime.now();
      final merged = DateTime(
        current.year,
        current.month,
        current.day,
        hour!,
        minute!,
        second!,
      );
      widget.onChanged?.call(merged);
    }
  }

  Future<void> _pickDateTime() async {
    final now = widget.value ?? DateTime.now();
    DateTime? result;

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return _DateTimePickDialog(
          initialDateTime: now,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          onConfirmed: (dt) => result = dt,
        );
      },
    );

    if (result != null && result != widget.value) {
      widget.onChanged?.call(result);
    }
  }

  Future<void> _openPicker() async {
    if (!widget.enabled) return;
    switch (widget.mode) {
      case DateTimePickerMode.date:
        await _pickDate();
      case DateTimePickerMode.time:
        await _pickTime();
      case DateTimePickerMode.dateTime:
        await _pickDateTime();
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
    required this.initialDate,
    this.minDate,
    this.maxDate,
    required this.onDateChanged,
  });

  final DateTime initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final ValueChanged<DateTime> onDateChanged;

  @override
  State<_DatePickDialog> createState() => _DatePickDialogState();
}

class _DatePickDialogState extends State<_DatePickDialog> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return Center(
      child: SizedBox(
        width: 240,
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
                children: [
                  MonthCalendar(
                    selectedDate: _selected,
                    onDateSelected: (d) => setState(() => _selected = d),
                    minDate: widget.minDate,
                    maxDate: widget.maxDate,
                    tokens: t,
                  ),
                  SizedBox(height: t.compactSpacing * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _DialogButton(
                        text: 'OK',
                        tokens: t,
                        onPressed: () {
                          widget.onDateChanged(_selected);
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(width: t.compactSpacing),
                      _DialogButton(
                        text: 'Cancel',
                        tokens: t,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// _DateTimePickDialog — combined date + time picker in one dialog
// ===========================================================================

class _DateTimePickDialog extends StatefulWidget {
  const _DateTimePickDialog({
    required this.initialDateTime,
    this.minDate,
    this.maxDate,
    required this.onConfirmed,
  });

  final DateTime initialDateTime;
  final DateTime? minDate;
  final DateTime? maxDate;
  final ValueChanged<DateTime> onConfirmed;

  @override
  State<_DateTimePickDialog> createState() => _DateTimePickDialogState();
}

class _DateTimePickDialogState extends State<_DateTimePickDialog> {
  late DateTime _selectedDate;
  late double _hour;
  late double _minute;
  late double _second;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime;
    _hour = widget.initialDateTime.hour.toDouble();
    _minute = widget.initialDateTime.minute.toDouble();
    _second = widget.initialDateTime.second.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final labelStyle = TextStyle(
      fontFamily: t.fontFamily,
      fontSize: t.fontSize,
      color: t.foregroundColor,
    );

    return Center(
      child: SizedBox(
        width: 260,
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
                children: [
                  MonthCalendar(
                    selectedDate: _selectedDate,
                    onDateSelected: (d) => setState(() => _selectedDate = d),
                    minDate: widget.minDate,
                    maxDate: widget.maxDate,
                    tokens: t,
                  ),
                  SizedBox(height: t.compactSpacing * 2),
                  // ── Time section ──
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Time',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: t.fontSize + 1,
                        fontWeight: FontWeight.w600,
                        color: t.foregroundColor,
                      ),
                    ),
                  ),
                  SizedBox(height: t.compactSpacing),
                  Row(children: [
                    SizedBox(width: 50, child: Text('Hour', style: labelStyle)),
                    Expanded(
                      child: NumericUpDown(
                        value: _hour,
                        min: 0,
                        max: 23,
                        step: 1,
                        decimals: 0,
                        tokens: t,
                        onChanged: (v) => setState(() => _hour = v),
                      ),
                    ),
                  ]),
                  SizedBox(height: t.compactSpacing),
                  Row(children: [
                    SizedBox(width: 50, child: Text('Minute', style: labelStyle)),
                    Expanded(
                      child: NumericUpDown(
                        value: _minute,
                        min: 0,
                        max: 59,
                        step: 1,
                        decimals: 0,
                        tokens: t,
                        onChanged: (v) => setState(() => _minute = v),
                      ),
                    ),
                  ]),
                  SizedBox(height: t.compactSpacing),
                  Row(children: [
                    SizedBox(width: 50, child: Text('Second', style: labelStyle)),
                    Expanded(
                      child: NumericUpDown(
                        value: _second,
                        min: 0,
                        max: 59,
                        step: 1,
                        decimals: 0,
                        tokens: t,
                        onChanged: (v) => setState(() => _second = v),
                      ),
                    ),
                  ]),
                  SizedBox(height: t.compactSpacing * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _DialogButton(
                        text: 'OK',
                        tokens: t,
                        onPressed: () {
                          final merged = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _hour.toInt(),
                            _minute.toInt(),
                            _second.toInt(),
                          );
                          widget.onConfirmed(merged);
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(width: t.compactSpacing),
                      _DialogButton(
                        text: 'Cancel',
                        tokens: t,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// _TimePickDialog — WinForm-style time picker using NumericUpDown
// ===========================================================================

class _TimePickDialog extends StatefulWidget {
  const _TimePickDialog({
    required this.initialTime,
    required this.onTimeChanged,
  });

  final TimeOfDay initialTime;
  final void Function(int hour, int minute, int second) onTimeChanged;

  @override
  State<_TimePickDialog> createState() => _TimePickDialogState();
}

class _TimePickDialogState extends State<_TimePickDialog> {
  late double _hour;
  late double _minute;
  late double _second;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour.toDouble();
    _minute = widget.initialTime.minute.toDouble();
    _second = 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final labelStyle = TextStyle(
      fontFamily: t.fontFamily,
      fontSize: t.fontSize,
      color: t.foregroundColor,
    );

    return Center(
      child: SizedBox(
        width: 200,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Time',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: t.fontSize + 1,
                        fontWeight: FontWeight.w600,
                        color: t.foregroundColor,
                      )),
                  SizedBox(height: t.compactSpacing * 2),
                  Row(children: [
                    SizedBox(width: 50, child: Text('Hour', style: labelStyle)),
                    Expanded(
                      child: NumericUpDown(
                        value: _hour,
                        min: 0,
                        max: 23,
                        step: 1,
                        decimals: 0,
                        tokens: t,
                        onChanged: (v) => setState(() => _hour = v),
                      ),
                    ),
                  ]),
                  SizedBox(height: t.compactSpacing),
                  Row(children: [
                    SizedBox(width: 50, child: Text('Minute', style: labelStyle)),
                    Expanded(
                      child: NumericUpDown(
                        value: _minute,
                        min: 0,
                        max: 59,
                        step: 1,
                        decimals: 0,
                        tokens: t,
                        onChanged: (v) => setState(() => _minute = v),
                      ),
                    ),
                  ]),
                  SizedBox(height: t.compactSpacing),
                  Row(children: [
                    SizedBox(width: 50, child: Text('Second', style: labelStyle)),
                    Expanded(
                      child: NumericUpDown(
                        value: _second,
                        min: 0,
                        max: 59,
                        step: 1,
                        decimals: 0,
                        tokens: t,
                        onChanged: (v) => setState(() => _second = v),
                      ),
                    ),
                  ]),
                  SizedBox(height: t.compactSpacing * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _DialogButton(
                        text: 'OK',
                        tokens: t,
                        onPressed: () {
                          widget.onTimeChanged(
                            _hour.toInt(),
                            _minute.toInt(),
                            _second.toInt(),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(width: t.compactSpacing),
                      _DialogButton(
                        text: 'Cancel',
                        tokens: t,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
