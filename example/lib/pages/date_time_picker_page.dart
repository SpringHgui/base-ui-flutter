import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [DateTimePicker] widget.
class DateTimePickerPage extends StatefulWidget {
  const DateTimePickerPage({super.key});

  @override
  State<DateTimePickerPage> createState() => _DateTimePickerPageState();
}

class _DateTimePickerPageState extends State<DateTimePickerPage> {
  DateTime? _date = DateTime.now();
  DateTime? _time = DateTime.now();
  DateTime? _dateTime = DateTime.now();
  DateTime? _empty;
  DateTime? _restricted = DateTime(2025, 6, 15);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(l10n.t('datetime.dateMode')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: DateTimePicker(
              value: _date,
              onChanged: (d) => setState(() => _date = d),
              mode: DateTimePickerMode.date,
            ),
          ),
          const SizedBox(height: 4),
          Label(_date != null ? l10n.t('datetime.selected').replaceAll('{value}', _date.toString().substring(0, 10)) : l10n.t('datetime.selectedNone')),
          const SizedBox(height: 16),

          Label(l10n.t('datetime.timeMode')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: DateTimePicker(
              value: _time,
              onChanged: (d) => setState(() => _time = d),
              mode: DateTimePickerMode.time,
            ),
          ),
          const SizedBox(height: 4),
          Label(_time != null ? l10n.t('datetime.selected').replaceAll('{value}', _time.toString().substring(11, 19)) : l10n.t('datetime.selectedNone')),
          const SizedBox(height: 16),

          Label(l10n.t('datetime.dateTimeMode')),
          const SizedBox(height: 6),
          SizedBox(
            width: 280,
            child: DateTimePicker(
              value: _dateTime,
              onChanged: (d) => setState(() => _dateTime = d),
              mode: DateTimePickerMode.dateTime,
            ),
          ),
          const SizedBox(height: 4),
          Label(_dateTime != null ? l10n.t('datetime.selected').replaceAll('{value}', _dateTime.toString()) : l10n.t('datetime.selectedNone')),
          const SizedBox(height: 16),

          Label(l10n.t('datetime.withHint')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: DateTimePicker(
              value: _empty,
              onChanged: (d) => setState(() => _empty = d),
              mode: DateTimePickerMode.date,
              hint: l10n.t('datetime.pickDate'),
            ),
          ),
          const SizedBox(height: 16),

          Label(l10n.t('datetime.minMax')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: DateTimePicker(
              value: _restricted,
              onChanged: (d) => setState(() => _restricted = d),
              mode: DateTimePickerMode.date,
              minDate: DateTime(2025, 1, 1),
              maxDate: DateTime(2025, 12, 31),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('datetime.restricted')),
          const SizedBox(height: 16),

          Label(l10n.t('datetime.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: DateTimePicker(
              value: DateTime.now(),
              mode: DateTimePickerMode.date,
              enabled: false,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
