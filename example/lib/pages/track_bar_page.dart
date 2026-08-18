import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [TrackBar] widget.
class TrackBarPage extends StatefulWidget {
  const TrackBarPage({super.key});

  @override
  State<TrackBarPage> createState() => _TrackBarPageState();
}

class _TrackBarPageState extends State<TrackBarPage> {
  double _value1 = 50;
  double _value2 = 30;
  double _value3 = 70;
  final double _value4 = 50;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic track bar
          Label(l10n.t('trackbar.basic')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: TrackBar(
              value: _value1,
              onChanged: (v) => setState(() => _value1 = v),
              min: 0,
              max: 100,
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('trackbar.value').replaceAll('{value}', _value1.toStringAsFixed(1))),
          const SizedBox(height: 16),

          // 2. With divisions
          Label(l10n.t('trackbar.divisions')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: TrackBar(
              value: _value2,
              onChanged: (v) => setState(() => _value2 = v),
              min: 0,
              max: 100,
              divisions: 20,
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('trackbar.value').replaceAll('{value}', _value2.toStringAsFixed(0))),
          const SizedBox(height: 16),

          // 3. Custom range
          Label(l10n.t('trackbar.customRange')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: TrackBar(
              value: _value3,
              onChanged: (v) => setState(() => _value3 = v),
              min: -50,
              max: 50,
              divisions: 10,
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('trackbar.value').replaceAll('{value}', _value3.toStringAsFixed(0))),
          const SizedBox(height: 16),

          // 4. Disabled
          Label(l10n.t('trackbar.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: TrackBar(
              value: _value4,
              min: 0,
              max: 100,
              enabled: false,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
