import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [NumericUpDown] widget.
class NumericUpDownPage extends StatefulWidget {
  const NumericUpDownPage({super.key});

  @override
  State<NumericUpDownPage> createState() => _NumericUpDownPageState();
}

class _NumericUpDownPageState extends State<NumericUpDownPage> {
  double _intVal = 42;
  double _decVal = 3.14;
  double _rangeVal = 0;
  double _stepVal = 50;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Integer up/down
          Label(l10n.t('numeric.integer')),
          const SizedBox(height: 6),
          SizedBox(
            width: 150,
            child: NumericUpDown(
              value: _intVal,
              onChanged: (v) => setState(() => _intVal = v),
              min: 0,
              max: 100,
              step: 1,
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('numeric.value').replaceAll('{value}', _intVal.toStringAsFixed(0))),
          const SizedBox(height: 16),

          // 2. Decimal up/down
          Label(l10n.t('numeric.decimal')),
          const SizedBox(height: 6),
          SizedBox(
            width: 150,
            child: NumericUpDown(
              value: _decVal,
              onChanged: (v) => setState(() => _decVal = v),
              min: 0,
              max: 10,
              step: 0.01,
              decimals: 2,
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('numeric.value').replaceAll('{value}', _decVal.toStringAsFixed(2))),
          const SizedBox(height: 16),

          // 3. Custom range and step
          Label(l10n.t('numeric.customRange')),
          const SizedBox(height: 6),
          SizedBox(
            width: 150,
            child: NumericUpDown(
              value: _rangeVal,
              onChanged: (v) => setState(() => _rangeVal = v),
              min: -50,
              max: 50,
              step: 5,
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('numeric.value').replaceAll('{value}', _rangeVal.toStringAsFixed(0))),
          const SizedBox(height: 16),

          // 4. Large step
          Label(l10n.t('numeric.largeStep')),
          const SizedBox(height: 6),
          SizedBox(
            width: 150,
            child: NumericUpDown(
              value: _stepVal,
              onChanged: (v) => setState(() => _stepVal = v),
              min: 0,
              max: 1000,
              step: 100,
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('numeric.value').replaceAll('{value}', _stepVal.toStringAsFixed(0))),
          const SizedBox(height: 16),

          // 5. Disabled
          Label(l10n.t('numeric.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 150,
            child: NumericUpDown(
              value: 99,
              min: 0,
              max: 100,
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // 6. Direct text editing
          Label(l10n.t('numeric.directEdit')),
          const SizedBox(height: 6),
          Label(l10n.t('numeric.directEditDesc')),
          const SizedBox(height: 4),
          Label(l10n.t('numeric.invalidRevert')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
