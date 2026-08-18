import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [ProgressBar] widget.
class ProgressBarPage extends StatefulWidget {
  const ProgressBarPage({super.key});

  @override
  State<ProgressBarPage> createState() => _ProgressBarPageState();
}

class _ProgressBarPageState extends State<ProgressBarPage> {
  double _value = 65;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Determinate
          Label(l10n.t('progressbar.determinate')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: ProgressBar(
              value: _value,
              min: 0,
              max: 100,
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('progressbar.value').replaceAll('{value}', _value.toStringAsFixed(0))),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(text: '-10', onPressed: () => setState(() => _value = (_value - 10).clamp(0, 100))),
              const SizedBox(width: 4),
              Button(text: '+10', onPressed: () => setState(() => _value = (_value + 10).clamp(0, 100))),
              const SizedBox(width: 4),
              Button(text: '0%', onPressed: () => setState(() => _value = 0)),
              const SizedBox(width: 4),
              Button(text: '100%', onPressed: () => setState(() => _value = 100)),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Marquee
          Label(l10n.t('progressbar.marquee')),
          const SizedBox(height: 6),
          const SizedBox(
            width: 300,
            child: ProgressBar(style: ProgressBarStyle.marquee),
          ),
          const SizedBox(height: 16),

          // 3. Different values
          Label(l10n.t('progressbar.fillLevels')),
          const SizedBox(height: 6),
          for (final v in [0.0, 25.0, 50.0, 75.0, 100.0]) ...[
            SizedBox(
              width: 300,
              child: ProgressBar(value: v, min: 0, max: 100),
            ),
            const SizedBox(height: 4),
            Label('  ${v.toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
