import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [MonthCalendar] widget.
class MonthCalendarPage extends StatefulWidget {
  const MonthCalendarPage({super.key});

  @override
  State<MonthCalendarPage> createState() => _MonthCalendarPageState();
}

class _MonthCalendarPageState extends State<MonthCalendarPage> {
  DateTime? _selected = DateTime.now();
  DateTime? _restricted = DateTime(2025, 6, 15);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(l10n.t('calendar.basic')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 220,
                child: MonthCalendar(
                  selectedDate: _selected,
                  onDateSelected: (d) => setState(() => _selected = d),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('calendar.selectedDate')),
                  Label('  ${_selected?.toString().substring(0, 10) ?? "None"}'),
                  const SizedBox(height: 8),
                  Label(l10n.t('calendar.navigateHint')),
                  Label(l10n.t('calendar.clickHint')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Label(l10n.t('calendar.minMax')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 220,
                child: MonthCalendar(
                  selectedDate: _restricted,
                  onDateSelected: (d) => setState(() => _restricted = d),
                  minDate: DateTime(2025, 6, 1),
                  maxDate: DateTime(2025, 6, 30),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('calendar.restrictedHint')),
                  Label(l10n.t('calendar.outsideRange')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Label(l10n.t('calendar.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 220,
            child: MonthCalendar(
              selectedDate: DateTime.now(),
              enabled: false,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
