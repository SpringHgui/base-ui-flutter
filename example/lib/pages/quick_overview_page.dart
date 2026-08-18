import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

import '../l10n/app_localizations.dart';

/// Shows every component with exactly one representative example, laid out
/// in a compact grid so the whole gallery can be scanned at a glance.
class QuickOverviewPage extends StatefulWidget {
  const QuickOverviewPage({super.key});

  @override
  State<QuickOverviewPage> createState() => _QuickOverviewPageState();
}

class _QuickOverviewPageState extends State<QuickOverviewPage> {
  bool _checkValue = true;
  String? _radioValue = 'A';
  String? _comboValue = 'Apple';
  double _numericValue = 42;
  int _domainIndex = 0;
  Set<int> _listSelected = {0};
  Set<int> _checkedListChecked = {0, 1};
  int? _treeSelectedKey;
  int? _gridSelectedRow;
  late List<PropertyItem> _propItems;
  DateTime? _dateTimeValue = DateTime.now();
  DateTime? _monthCalValue = DateTime.now();
  Color _colorValue = const Color(0xFF1E90FF);
  int _bindingIndex = 0;
  double _trackBarValue = 50;

  late final List<TreeNode<String>> _treeNodes;

  @override
  void initState() {
    super.initState();
    _propItems = [
      PropertyItem(name: 'Name', category: 'Appearance', value: 'MyControl'),
      PropertyItem(name: 'Enabled', category: 'Behaviour', value: 'true'),
    ];
    _treeNodes = [
      TreeNode<String>(
        data: 'root',
        label: 'Project',
        expanded: true,
        children: [
          TreeNode(data: 'main.dart', label: 'main.dart'),
          TreeNode(data: 'utils.dart', label: 'utils.dart'),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final demos = <_Demo>[
      _Demo('Label', const Label('Hello, WinForms!')),
      _Demo('Input', _box(160, 36, Input(hint: 'Type something...'))),
      _Demo('Button', _box(120, 32, Button(text: 'Click Me', onPressed: () {}))),
      _Demo(
        'CheckBox',
        _box(120, 30, CheckBox(value: _checkValue, label: 'Enabled', onChanged: (v) => setState(() => _checkValue = v ?? false))),
      ),
      _Demo(
        'RadioButton',
        _box(180, 30, Row(mainAxisSize: MainAxisSize.min, children: [
          RadioButton<String>(value: 'A', groupValue: _radioValue, label: 'A', onChanged: (v) => setState(() => _radioValue = v)),
          const SizedBox(width: 8),
          RadioButton<String>(value: 'B', groupValue: _radioValue, label: 'B', onChanged: (v) => setState(() => _radioValue = v)),
        ])),
      ),
      _Demo(
        'ComboBox',
        _box(160, 36, ComboBox<String>(
          items: const ['Apple', 'Banana', 'Cherry'],
          value: _comboValue,
          onChanged: (v) => setState(() => _comboValue = v),
        )),
      ),
      _Demo('LinkLabel', _box(160, 26, LinkLabel(text: 'Click this link', onLinkTap: () {}))),
      _Demo('MaskedTextBox', _box(200, 40, MaskedTextBox(mask: '(000) 000-0000', hint: '(___) ___-____'))),
      _Demo(
        'NumericUpDown',
        _box(140, 36, NumericUpDown(value: _numericValue, min: 0, max: 100, step: 1, onChanged: (v) => setState(() => _numericValue = v))),
      ),
      _Demo(
        'DomainUpDown',
        _box(160, 36, DomainUpDown<String>(
          items: const ['Spring', 'Summer', 'Autumn', 'Winter'],
          selectedIndex: _domainIndex,
          onSelectedIndexChanged: (i) => setState(() => _domainIndex = i),
        )),
      ),
      _Demo(
        'ListBox',
        _box(160, 100, ListBox<String>(
          items: const ['Apple', 'Banana', 'Cherry', 'Date'],
          selectedIndices: _listSelected,
          onSelectionChanged: (s) => setState(() => _listSelected = s),
        )),
      ),
      _Demo(
        'CheckedListBox',
        _box(180, 100, CheckedListBox<String>(
          items: const ['Read', 'Write', 'Execute'],
          checkedIndices: _checkedListChecked,
          onItemCheckChanged: (s) => setState(() => _checkedListChecked = s),
        )),
      ),
      _Demo(
        'WinListView',
        _box(180, 110, WinListView<String>(
          items: const ['Alice', 'Bob', 'Charlie'],
          mode: ListViewMode.list,
          selectedIndices: _listSelected,
          onSelectionChanged: (s) => setState(() => _listSelected = s),
        )),
      ),
      _Demo(
        'TreeView',
        _box(180, 120, TreeView<String>(
          nodes: _treeNodes,
          selectedKey: _treeSelectedKey,
          onSelectionChanged: (k) => setState(() => _treeSelectedKey = k),
        )),
      ),
      _Demo(
        'DataGridView',
        _box(260, 140, DataGridView(
          columns: [
            DataGridViewColumn(title: 'Id', width: 40),
            DataGridViewColumn(title: 'Product', flex: 1),
          ],
          rowCount: 20,
          selectedRow: _gridSelectedRow,
          onRowSelected: (i) => setState(() => _gridSelectedRow = i),
          cellBuilder: (row, col) => Text(col == 0 ? '${row + 1}' : 'Product ${row + 1}'),
        )),
      ),
      _Demo(
        'PropertyGrid',
        _box(260, 140, PropertyGrid(
          properties: _propItems,
          onValueChanged: (prop, val) => setState(() => prop.value = val),
        )),
      ),
      _Demo(
        'MenuStrip',
        _box(220, 36, MenuStrip(items: [
          MenuItem(text: 'File', children: [MenuItem(text: 'New'), MenuItem(text: 'Open')]),
          MenuItem(text: 'Edit', children: [MenuItem(text: 'Undo'), MenuItem(text: 'Redo')]),
        ])),
      ),
      _Demo(
        'ToolStrip',
        _box(200, 36, ToolStrip(items: [
          ToolStripButton(text: 'New', icon: Icons.note_add, onPressed: () {}),
          ToolStripButton(text: 'Save', icon: Icons.save, onPressed: () {}),
        ])),
      ),
      _Demo(
        'ContextMenuStrip',
        _box(200, 50, ContextMenuStrip(
          items: [MenuItem(text: 'Copy'), MenuItem(text: 'Paste')],
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFB0B0B0))),
            child: const Text('Right-click here'),
          ),
        )),
      ),
      _Demo(
        'StatusStrip',
        _box(240, 28, const StatusStrip(panels: [
          StatusStripPanel(text: 'Ready', flex: 2),
          StatusStripPanel(text: 'UTF-8', width: 70),
        ])),
      ),
      _Demo(
        'DateTimePicker',
        _box(180, 36, DateTimePicker(value: _dateTimeValue, onChanged: (d) => setState(() => _dateTimeValue = d))),
      ),
      _Demo(
        'MonthCalendar',
        _box(220, 190, MonthCalendar(selectedDate: _monthCalValue, onDateSelected: (d) => setState(() => _monthCalValue = d))),
      ),
      _Demo(
        'ColorDialog',
        _box(240, 170, ColorDialog(selectedColor: _colorValue, onConfirm: (c) => setState(() => _colorValue = c))),
      ),
      _Demo(
        'BindingNavigator',
        _box(220, 36, BindingNavigator(
          currentIndex: _bindingIndex,
          totalCount: 5,
          onFirst: () => setState(() => _bindingIndex = 0),
          onPrevious: () => setState(() { if (_bindingIndex > 0) _bindingIndex--; }),
          onNext: () => setState(() { if (_bindingIndex < 4) _bindingIndex++; }),
          onLast: () => setState(() => _bindingIndex = 4),
        )),
      ),
      _Demo(
        'ScrollBar',
        _box(160, 120, ScrollBar(
          controller: ScrollController(),
          child: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(8), child: Label(l10n.t('scrollbar.scrollContent'))),
          ),
        )),
      ),
      _Demo('TrackBar', _box(200, 40, TrackBar(value: _trackBarValue, min: 0, max: 100, onChanged: (v) => setState(() => _trackBarValue = v)))),
      _Demo('ProgressBar', _box(200, 30, const ProgressBar(value: 65, min: 0, max: 100))),
      _Demo('RichTextBox', _box(220, 80, const RichTextBox(minLines: 3, maxLines: 6))),
      _Demo('WinToolTip', _box(160, 30, WinToolTip(message: 'Hover me', child: const Label('Hover for a tip')))),
      _Demo('ErrorProvider', _box(220, 50, ErrorProvider(error: 'Required field', child: Input(hint: 'Email')))),
      _Demo(
        'ScrollableControl',
        _box(200, 120, Container(
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFB0B0B0))),
          child: ScrollableControl(
            child: Padding(padding: const EdgeInsets.all(8), child: Label(l10n.t('scrollable.content'))),
          ),
        )),
      ),
    ];

    return ScrollableControl(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            mainAxisExtent: 210,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: demos.length,
          itemBuilder: (context, index) => _DemoCard(demo: demos[index]),
        ),
      ),
    );
  }

  /// Scales [child] down to fit the given card content area, never enlarging.
  Widget _box(double naturalWidth, double naturalHeight, Widget child) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: SizedBox(width: naturalWidth, height: naturalHeight, child: child),
    );
  }
}

class _Demo {
  const _Demo(this.name, this.child);
  final String name;
  final Widget child;
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.demo});
  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: tokens.borderColor, width: tokens.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            demo.name,
            style: TextStyle(fontFamily: tokens.fontFamily, fontSize: tokens.fontSize, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Expanded(child: Center(child: demo.child)),
        ],
      ),
    );
  }
}
