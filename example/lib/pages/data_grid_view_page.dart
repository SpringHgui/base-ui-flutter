import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [DataGridView] widget.
class DataGridViewPage extends StatefulWidget {
  const DataGridViewPage({super.key});

  @override
  State<DataGridViewPage> createState() => _DataGridViewPageState();
}

class _DataGridViewPageState extends State<DataGridViewPage> {
  int? _selectedRow;
  int? _selectedRow2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = DesktopTokens.winForm;
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic data grid
          Label(l10n.t('datagrid.productTable')),
          const SizedBox(height: 6),
          SizedBox(
            width: 500,
            height: 200,
            child: DataGridView(
              columns: [
                DataGridViewColumn(title: l10n.t('datagrid.colId'), width: 50),
                DataGridViewColumn(title: l10n.t('datagrid.colProduct'), flex: 2),
                DataGridViewColumn(title: l10n.t('datagrid.colPrice'), width: 80, alignment: Alignment.centerRight),
                DataGridViewColumn(title: l10n.t('datagrid.colStock'), width: 70, alignment: Alignment.centerRight),
              ],
              rowCount: 50,
              selectedRow: _selectedRow,
              onRowSelected: (i) => setState(() => _selectedRow = i),
              cellBuilder: (row, col) {
                final data = [
                  '${row + 1}',
                  'Product ${row + 1}',
                  '\$${(row + 1) * 9.99}',
                  '${(row + 1) * 10}',
                ];
                return Text(
                  data[col],
                  style: TextStyle(fontSize: t.fontSize, fontFamily: t.fontFamily),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Label(_selectedRow != null ? l10n.t('datagrid.selectedRowValue').replaceAll('{value}', _selectedRow.toString()) : l10n.t('datagrid.selectedRow')),
          const SizedBox(height: 16),

          // 2. Grid without header
          Label(l10n.t('datagrid.noHeader')),
          const SizedBox(height: 6),
          SizedBox(
            width: 400,
            height: 140,
            child: DataGridView(
              columns: const [
                DataGridViewColumn(title: 'A', flex: 1),
                DataGridViewColumn(title: 'B', flex: 1),
                DataGridViewColumn(title: 'C', flex: 1),
              ],
              rowCount: 10,
              showHeader: false,
              selectedRow: _selectedRow2,
              onRowSelected: (i) => setState(() => _selectedRow2 = i),
              cellBuilder: (row, col) {
                return Text(
                  'R${row + 1}C${col + 1}',
                  style: TextStyle(fontSize: t.fontSize, fontFamily: t.fontFamily),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 3. Large dataset
          Label(l10n.t('datagrid.largeDataset')),
          const SizedBox(height: 6),
          SizedBox(
            width: 500,
            height: 200,
            child: DataGridView(
              columns: const [
                DataGridViewColumn(title: 'Index', width: 80),
                DataGridViewColumn(title: 'Value', flex: 2),
                DataGridViewColumn(title: 'Square', width: 100, alignment: Alignment.centerRight),
              ],
              rowCount: 100000,
              cellBuilder: (row, col) {
                final data = [
                  '$row',
                  'Item $row',
                  '${row * row}',
                ];
                return Text(
                  data[col],
                  style: TextStyle(fontSize: t.fontSize, fontFamily: t.fontFamily),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 4. Disabled
          Label(l10n.t('datagrid.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 400,
            height: 120,
            child: DataGridView(
              columns: const [
                DataGridViewColumn(title: 'Name', flex: 1),
                DataGridViewColumn(title: 'Value', flex: 1),
              ],
              rowCount: 5,
              enabled: false,
              cellBuilder: (row, col) {
                return Text(
                  col == 0 ? 'Field $row' : 'Value $row',
                  style: TextStyle(fontSize: t.fontSize, fontFamily: t.fontFamily),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
