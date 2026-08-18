import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [CheckedListBox] widget.
class CheckedListBoxPage extends StatefulWidget {
  const CheckedListBoxPage({super.key});

  @override
  State<CheckedListBoxPage> createState() => _CheckedListBoxPageState();
}

class _CheckedListBoxPageState extends State<CheckedListBoxPage> {
  Set<int> _permissions = {0, 1};
  Set<int> _featureChecked = {0, 1, 2};
  final Set<int> _disabled = {0};

  static const _perms = ['Read', 'Write', 'Execute', 'Admin', 'Guest'];
  static const _featureItems = ['Dark Mode', 'Notifications', 'Auto-save', 'Sync', 'Backup'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic checked list
          Label(l10n.t('checkedlb.permissions')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                height: 150,
                child: CheckedListBox<String>(
                  items: _perms,
                  checkedIndices: _permissions,
                  onItemCheckChanged: (s) => setState(() => _permissions = s),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('checkedlb.checked')),
                  for (final idx in _permissions)
                    Label('  ${_perms[idx]}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Feature toggle
          Label(l10n.t('checkedlb.featureToggle')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                height: 160,
                child: CheckedListBox<String>(
                  items: _featureItems,
                  checkedIndices: _featureChecked,
                  onItemCheckChanged: (s) => setState(() => _featureChecked = s),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('checkedlb.enabledFeatures')),
                  for (final idx in _featureChecked)
                    Label('  ${_featureItems[idx]}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Disabled
          Label(l10n.t('checkedlb.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 250,
            height: 100,
            child: CheckedListBox<String>(
              items: _perms.take(3).toList(),
              checkedIndices: _disabled,
              enabled: false,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
