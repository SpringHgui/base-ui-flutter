import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [WinListView] widget.
class ListViewPage extends StatefulWidget {
  const ListViewPage({super.key});

  @override
  State<ListViewPage> createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  Set<int> _listSel = {0};
  Set<int> _detailSel = {0};
  Set<int> _multiSel = {0, 2};
  Set<int> _builderSel = {0};
  String _activated = '';

  static const _items = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank'];

  static const _data = [
    {'name': 'Alice', 'age': '30', 'city': 'New York'},
    {'name': 'Bob', 'age': '25', 'city': 'London'},
    {'name': 'Charlie', 'age': '35', 'city': 'Tokyo'},
    {'name': 'Diana', 'age': '28', 'city': 'Paris'},
    {'name': 'Eve', 'age': '32', 'city': 'Berlin'},
  ];

  /// Large dataset for builder-mode demo (10 000 rows, generated lazily).
  static final List<String> _largeItems =
      List.generate(10000, (i) => 'Item #$i');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. List mode
          Label(l10n.t('listview.listMode')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            height: 150,
            child: WinListView<String>(
              items: _items,
              mode: ListViewMode.list,
              selectedIndices: _listSel,
              onSelectionChanged: (s) => setState(() => _listSel = s),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Details mode
          Label(l10n.t('listview.detailsMode')),
          const SizedBox(height: 6),
          SizedBox(
            width: 400,
            height: 160,
            child: WinListView<Map<String, String>>(
              items: _data,
              columns: [
                ListViewColumn(title: l10n.t('listview.colName'), flex: 2),
                ListViewColumn(title: l10n.t('listview.colAge'), width: 60),
                ListViewColumn(title: l10n.t('listview.colCity'), flex: 2),
              ],
              mode: ListViewMode.details,
              selectedIndices: _detailSel,
              onSelectionChanged: (s) => setState(() => _detailSel = s),
              itemToString: (m) => m['name'] ?? '',
            ),
          ),
          const SizedBox(height: 16),

          // 3. Multi-select
          Label(l10n.t('listview.multiSel')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            height: 120,
            child: WinListView<String>(
              items: _items,
              mode: ListViewMode.list,
              multiSelect: true,
              selectedIndices: _multiSel,
              onSelectionChanged: (s) => setState(() => _multiSel = s),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Double-click activation
          Label(l10n.t('listview.doubleClick')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            height: 120,
            child: WinListView<String>(
              items: _items,
              mode: ListViewMode.list,
              selectedIndices: _listSel,
              onSelectionChanged: (s) => setState(() => _listSel = s),
              onItemActivated: (idx) => setState(() => _activated = _items[idx]),
            ),
          ),
          const SizedBox(height: 4),
          Label(_activated.isEmpty ? l10n.t('listview.lastActivated') : l10n.t('listview.lastActivatedValue').replaceAll('{value}', _activated)),
          const SizedBox(height: 16),

          // 5. Builder mode
          Label(l10n.t('listview.builderMode')),
          const SizedBox(height: 6),
          SizedBox(
            width: 250,
            height: 180,
            child: WinListView<String>(
              items: _largeItems,
              mode: ListViewMode.list,
              selectedIndices: _builderSel,
              onSelectionChanged: (s) => setState(() => _builderSel = s),
              itemBuilder: (context, item, index, isSelected) {
                final tokens =
                    TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: tokens.controlPaddingX),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontFamily: tokens.fontFamily,
                        fontSize: tokens.fontSize,
                        color: isSelected
                            ? tokens.surfaceColor
                            : tokens.foregroundColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 6. Disabled
          Label(l10n.t('listview.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            height: 100,
            child: WinListView<String>(
              items: _items.take(4).toList(),
              mode: ListViewMode.list,
              enabled: false,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
