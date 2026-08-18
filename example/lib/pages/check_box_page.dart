import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [CheckBox] widget.
class CheckBoxPage extends StatefulWidget {
  const CheckBoxPage({super.key});

  @override
  State<CheckBoxPage> createState() => _CheckBoxPageState();
}

class _CheckBoxPageState extends State<CheckBoxPage> {
  bool _checkA = true;
  bool _checkB = false;
  bool _checkC = true;
  bool _noLabel = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic checked/unchecked
          Label(l10n.t('checkbox.basic')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckBox(
                value: _checkA,
                onChanged: (v) => setState(() => _checkA = v ?? false),
                label: l10n.t('checkbox.optionA'),
              ),
              const SizedBox(width: 16),
              CheckBox(
                value: _checkB,
                onChanged: (v) => setState(() => _checkB = v ?? false),
                label: l10n.t('checkbox.optionB'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Without label
          Label(l10n.t('checkbox.noLabel')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckBox(
                value: _noLabel,
                onChanged: (v) => setState(() => _noLabel = v ?? false),
              ),
              const SizedBox(width: 8),
              Label(l10n.t('checkbox.noLabelDesc').replaceAll('{value}', '$_noLabel')),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Disabled states
          Label(l10n.t('checkbox.disabledStates')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckBox(
                value: true,
                onChanged: null,
                label: l10n.t('checkbox.disabledChecked'),
                enabled: false,
              ),
              const SizedBox(width: 16),
              CheckBox(
                value: false,
                onChanged: null,
                label: l10n.t('checkbox.disabledUnchecked'),
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. onChanged callback
          Label(l10n.t('checkbox.onChanged')),
          const SizedBox(height: 6),
          CheckBox(
            value: _checkC,
            onChanged: (v) => setState(() => _checkC = v ?? false),
            label: l10n.t('checkbox.toggleMe'),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('checkbox.currentValue').replaceAll('{value}', '$_checkC')),
          const SizedBox(height: 16),

          // 5. Multiple checkboxes group
          Label(l10n.t('checkbox.group')),
          const SizedBox(height: 6),
          ...[l10n.t('checkbox.read'), l10n.t('checkbox.write'), l10n.t('checkbox.execute')].map(
            (perm) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: CheckBox(
                value: perm == l10n.t('checkbox.read') || perm == l10n.t('checkbox.write'),
                onChanged: (_) {},
                label: perm,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
