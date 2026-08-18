import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [ComboBox] widget.
class ComboBoxPage extends StatefulWidget {
  const ComboBoxPage({super.key});

  @override
  State<ComboBoxPage> createState() => _ComboBoxPageState();
}

class _ComboBoxPageState extends State<ComboBoxPage> {
  String? _readOnly = 'Item 1';
  String? _editable;
  final String _disabled = 'Item 1';
  String? _withHint;
  String? _customDisplay;

  static const _fruits = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];
  static const _items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];
  static const _countries = [
    {'code': 'US', 'name': 'United States'},
    {'code': 'UK', 'name': 'United Kingdom'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'CN', 'name': 'China'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Read-only combo box
          Label(l10n.t('combo.readOnly')),
          const SizedBox(height: 6),
          SizedBox(
            width: 250,
            child: ComboBox<String>(
              items: _items,
              value: _readOnly,
              onChanged: (v) => setState(() => _readOnly = v),
            ),
          ),
          const SizedBox(height: 4),
          Label(_readOnly != null
              ? l10n.t('combo.selectedValue').replaceAll('{value}', _readOnly!)
              : l10n.t('combo.selectedNone')),
          const SizedBox(height: 16),

          // 2. Editable combo box (autocomplete)
          Label(l10n.t('combo.editable')),
          const SizedBox(height: 6),
          SizedBox(
            width: 250,
            child: ComboBox<String>(
              items: _fruits,
              value: _editable,
              onChanged: (v) => setState(() => _editable = v),
              editable: true,
              hint: l10n.t('combo.fruitHint'),
            ),
          ),
          const SizedBox(height: 4),
          Label(_editable != null
              ? l10n.t('combo.selectedValue').replaceAll('{value}', _editable!)
              : l10n.t('combo.customOrNone')),
          const SizedBox(height: 16),

          // 3. With hint
          Label(l10n.t('combo.withHint')),
          const SizedBox(height: 6),
          SizedBox(
            width: 250,
            child: ComboBox<String>(
              items: _items,
              value: _withHint,
              onChanged: (v) => setState(() => _withHint = v),
              hint: l10n.t('combo.selectItem'),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Disabled
          Label(l10n.t('combo.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 250,
            child: ComboBox<String>(
              items: _items,
              value: _disabled,
              onChanged: null,
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // 5. Custom itemToString
          Label(l10n.t('combo.customToString')),
          const SizedBox(height: 6),
          SizedBox(
            width: 250,
            child: ComboBox<Map<String, String>>(
              items: _countries,
              value: _customDisplay != null
                  ? _countries.firstWhere((m) => m['code'] == _customDisplay)
                  : null,
              onChanged: (v) => setState(() => _customDisplay = v?['code']),
              itemToString: (m) => '${m['code']} - ${m['name']}',
              hint: l10n.t('combo.selectCountry'),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('combo.selectedCode').replaceAll('{value}', _customDisplay ?? 'None')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
