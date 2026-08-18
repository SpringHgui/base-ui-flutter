import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [ListBox] widget.
class ListBoxPage extends StatefulWidget {
  const ListBoxPage({super.key});

  @override
  State<ListBoxPage> createState() => _ListBoxPageState();
}

class _ListBoxPageState extends State<ListBoxPage> {
  Set<int> _singleSel = {0};
  Set<int> _multiSel = {0, 2};
  Set<int> _customSel = {1};

  static const _fruits = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry', 'Fig', 'Grape'];
  static const _colors = ['Red', 'Green', 'Blue', 'Yellow', 'Purple'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Single selection
          Label(l10n.t('listbox.singleSel')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                height: 150,
                child: ListBox<String>(
                  items: _fruits,
                  selectedIndices: _singleSel,
                  onSelectionChanged: (s) => setState(() => _singleSel = s),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('listbox.selected')),
                  for (final idx in _singleSel)
                    Label('  ${_fruits[idx]}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Multi selection
          Label(l10n.t('listbox.multiSel')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                height: 150,
                child: ListBox<String>(
                  items: _colors,
                  multiSelect: true,
                  selectedIndices: _multiSel,
                  onSelectionChanged: (s) => setState(() => _multiSel = s),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('listbox.selected')),
                  for (final idx in _multiSel)
                    Label('  ${_colors[idx]}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Disabled
          Label(l10n.t('listbox.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            height: 100,
            child: ListBox<String>(
              items: _fruits.take(4).toList(),
              selectedIndices: const {0},
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // 4. Custom item height
          Label(l10n.t('listbox.customHeight')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            height: 120,
            child: ListBox<String>(
              items: _colors,
              selectedIndices: _customSel,
              onSelectionChanged: (s) => setState(() => _customSel = s),
              itemHeight: 36,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
