import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [RadioButton] widget.
class RadioButtonPage extends StatefulWidget {
  const RadioButtonPage({super.key});

  @override
  State<RadioButtonPage> createState() => _RadioButtonPageState();
}

class _RadioButtonPageState extends State<RadioButtonPage> {
  String _size = 'Medium';
  String? _color = 'Red';
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sizes = [l10n.t('radio.small'), l10n.t('radio.medium'), l10n.t('radio.large'), l10n.t('radio.extraLarge')];
    final colors = [l10n.t('radio.red'), l10n.t('radio.green'), l10n.t('radio.blue'), l10n.t('radio.yellow')];
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic radio group
          Label(l10n.t('radio.basic')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final size in sizes)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: RadioButton<String>(
                    value: size,
                    groupValue: _size,
                    onChanged: (v) => setState(() => _size = v ?? size),
                    label: size,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Label(l10n.t('radio.selected').replaceAll('{value}', _size)),
          const SizedBox(height: 16),

          // 2. Another group
          Label(l10n.t('radio.another')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final color in colors)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: RadioButton<String>(
                    value: color,
                    groupValue: _color,
                    onChanged: (v) => setState(() => _color = v),
                    label: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Label(l10n.t('radio.selected').replaceAll('{value}', _color ?? l10n.t('treeview.none'))),
          const SizedBox(height: 16),

          // 3. Integer value radio
          Label(l10n.t('radio.integer')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 1; i <= 5; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: RadioButton<int>(
                    value: i,
                    groupValue: _rating,
                    onChanged: (v) => setState(() => _rating = v ?? i),
                    label: '$i',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Label(l10n.t('radio.rating').replaceAll('{value}', '$_rating')),
          const SizedBox(height: 16),

          // 4. Disabled states
          Label(l10n.t('radio.disabledStates')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioButton<String>(
                value: 'A',
                groupValue: 'A',
                onChanged: (_) {},
                label: l10n.t('radio.disabledSelected'),
                enabled: false,
              ),
              const SizedBox(width: 16),
              RadioButton<String>(
                value: 'B',
                groupValue: 'A',
                onChanged: (_) {},
                label: l10n.t('radio.disabledUnselected'),
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Without label
          Label(l10n.t('radio.noLabel')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: RadioButton<int>(
                    value: i,
                    groupValue: 0,
                    onChanged: (_) {},
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
