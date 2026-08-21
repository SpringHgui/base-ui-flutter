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
  bool _selectableSelected = false;
  int? _listItemSelected = 0;
  bool _toggleBold = false;
  bool _toggleItalic = false;
  List<String> _toggleGroupSingle = const ['center'];
  bool _wifiSwitch = true;
  bool _bluetoothSwitch = false;
  bool _collapsibleOpen = false;
  bool _sidePanelOpen = false;
  int _paginationPage = 2;

  static const _chartData = [
    ChartDatum('Jan', 42),
    ChartDatum('Feb', 78),
    ChartDatum('Mar', 55),
  ];

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
        _box(220, 300, MonthCalendar(selectedDate: _monthCalValue, onDateSelected: (d) => setState(() => _monthCalValue = d))),
      ),
      _Demo(
        'ColorDialog',
        _box(240, 170, ColorDialog(selectedColor: _colorValue, onConfirm: (c) => setState(() => _colorValue = c))),
      ),
      _Demo(
        'BindingNavigator',
        _box(280, 36, BindingNavigator(
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
      _Demo(
        'FieldRow',
        _box(240, 100, SizedBox(
          width: 220,
          child: Column(children: [
            FieldRow(label: 'Host:', child: Input(hint: 'localhost')),
            const SizedBox(height: 6),
            FieldRow(label: 'Port:', child: Input(hint: '3306')),
          ]),
        )),
      ),
      _Demo(
        'IconBtn',
        _box(180, 36, Row(mainAxisSize: MainAxisSize.min, children: [
          IconBtn(icon: Icons.add, onTap: () {}),
          IconBtn(icon: Icons.save, onTap: () {}),
          IconBtn(icon: Icons.delete, onTap: () {}),
          IconBtn(icon: Icons.edit, onTap: () {}),
        ])),
      ),
      _Demo(
        'Surface',
        _box(180, 40, Surface(
          color: const Color(0xFFE0E0E0),
          borderColor: const Color(0xFFB0B0B0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () {},
          child: const Label('Hover / press me'),
        )),
      ),
      _Demo(
        'SearchInput',
        _box(200, 36, SizedBox(width: 180, child: SearchInput(hintText: 'Search...'))),
      ),
      _Demo(
        'CheckRow',
        _box(200, 90, SizedBox(
          width: 180,
          child: Column(children: [
            CheckRow(option: CheckOption(id: 'a', label: 'MySQL', selected: true, onToggle: () {})),
            CheckRow(option: CheckOption(id: 'b', label: 'PostgreSQL', selected: false, onToggle: () {})),
            CheckRow(option: CheckOption(id: 'c', label: 'SQLite', selected: true, onToggle: () {})),
          ]),
        )),
      ),
      // ── New / previously missing components ──────────────────────────────
      _Demo('SelectableCard', _box(200, 96, SelectableCard(
        width: 180,
        height: 80,
        selected: _selectableSelected,
        onSelect: () => setState(() => _selectableSelected = !_selectableSelected),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storage, size: 22),
              SizedBox(height: 4),
              Text('Click to select'),
            ],
          ),
        ),
      ))),
      _Demo('ListItem', _box(200, 96, Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListItem(title: 'Documents', leading: const Icon(Icons.folder, size: 16), selected: _listItemSelected == 0, onSelect: () => setState(() => _listItemSelected = 0)),
          ListItem(title: 'Images', leading: const Icon(Icons.image, size: 16), selected: _listItemSelected == 1, onSelect: () => setState(() => _listItemSelected = 1)),
          ListItem(title: 'Videos', leading: const Icon(Icons.video_library, size: 16), selected: _listItemSelected == 2, onSelect: () => setState(() => _listItemSelected = 2)),
        ],
      ))),
      _Demo('ToolbarButton', _box(240, 36, Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToolbarButton(icon: Icons.play_arrow, iconColor: const Color(0xFF0F6CBD), tooltip: 'Run', onTap: () {}),
          ToolbarButton(icon: Icons.stop, iconColor: const Color(0xFFC62828), tooltip: 'Stop', onTap: () {}),
          ToolbarButton(icon: Icons.save, text: 'Save', onTap: () {}),
          ToolbarButton(text: 'Sort', outlined: true, showCaret: true, onTap: () {}),
        ],
      ))),
      _Demo('InlineEditor', _box(220, 40, InlineEditor(
        initialValue: 'untitled.sql',
        onCommit: (_) {},
        onCancel: () {},
      ))),
      _Demo('DialogBox', _box(200, 40, Builder(
        builder: (context) => Button(
          text: 'Open dialog',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (ctx) => DialogBox(
              title: 'Options',
              width: 320,
              onClose: () => Navigator.of(ctx).pop(),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button(text: 'OK', onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              child: const Padding(padding: EdgeInsets.all(16), child: Text('Dialog body content')),
            ),
          ),
        ),
      ))),
      // ── Supplements ──────────────────────────────────────────────────────
      _Demo('Typography', _box(220, 150, const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TypeStyle.h3('Typography scale'),
          TypeStyle.p('Body text with the token-driven type ramp.'),
          TypeStyle.muted('Muted secondary text.'),
        ],
      ))),
      _Demo('Kbd', _box(200, 36, const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Save:'),
          SizedBox(width: 4),
          Kbd('Ctrl'),
          Text('+'),
          Kbd('S'),
        ],
      ))),
      _Demo('Separator', _box(200, 90, const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Above the separator'),
          Separator(),
          Text('Below the separator'),
        ],
      ))),
      _Demo('Tag', _box(240, 50, const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Tag('Primary'),
          Tag('Beta', variant: TagVariant.secondary),
          Tag('Failed', variant: TagVariant.destructive),
          Tag('Outline', variant: TagVariant.outline),
        ],
      ))),
      _Demo('Field', _box(220, 90, const Field(
        label: 'Username',
        description: 'How others see you.',
        children: [Input(hint: 'Enter username')],
      ))),
      _Demo('Marker', _box(240, 60, const Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'The '),
            WidgetSpan(child: Marker('quick brown fox')),
            TextSpan(text: ' jumps over the lazy dog.'),
          ],
        ),
      ))),
      _Demo('ButtonGroup', _box(280, 50, const ButtonGroup(
        children: [
          Button(text: 'Left', onPressed: null),
          Button(text: 'Center', onPressed: null),
          Button(text: 'Right', onPressed: null),
        ],
      ))),
      _Demo('InputGroup', _box(220, 40, const InputGroup(
        leading: InputGroupAddon(Icon(Icons.search, size: 16)),
        child: Input(hint: 'Search…'),
      ))),
      _Demo('Textarea', _box(220, 70, const Textarea(hint: 'Type here…', minLines: 3))),
      _Demo('Toggle', _box(180, 44, Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Toggle(selected: _toggleBold, onChanged: (v) => setState(() => _toggleBold = v), child: const Icon(Icons.format_bold, size: 16)),
          const SizedBox(width: 8),
          Toggle(selected: _toggleItalic, onChanged: (v) => setState(() => _toggleItalic = v), variant: ToggleVariant.outline, child: const Icon(Icons.format_italic, size: 16)),
        ],
      ))),
      _Demo('ToggleGroup', _box(220, 44, ToggleGroup<String>(
        values: _toggleGroupSingle,
        onChanged: (v) => setState(() => _toggleGroupSingle = v),
        children: const [
          ToggleGroupItem(value: 'left', child: Icon(Icons.format_align_left, size: 16)),
          ToggleGroupItem(value: 'center', child: Icon(Icons.format_align_center, size: 16)),
          ToggleGroupItem(value: 'right', child: Icon(Icons.format_align_right, size: 16)),
        ],
      ))),
      _Demo('ToggleSwitch', _box(180, 80, Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const Expanded(child: Text('Wi-Fi')),
            ToggleSwitch(value: _wifiSwitch, onChanged: (v) => setState(() => _wifiSwitch = v)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Expanded(child: Text('Bluetooth')),
            ToggleSwitch(value: _bluetoothSwitch, onChanged: (v) => setState(() => _bluetoothSwitch = v)),
          ]),
        ],
      ))),
      _Demo('InputOtp', _box(220, 44, const InputOtp(length: 4))),
      // ── Containers ───────────────────────────────────────────────────────
      _Demo('GroupBox', _box(240, 160, const GroupBox(
        title: 'Settings',
        child: Text('Grouped content here.'),
      ))),
      _Demo('TabControl', _box(240, 100, const TabControl(
        initialIndex: 0,
        tabs: [
          TabItem(label: 'Overview', child: Text('Overview content')),
          TabItem(label: 'Details', child: Text('Details content')),
        ],
      ))),
      _Demo('SplitContainer', _box(240, 110, const SplitContainer(
        initialRatio: 0.5,
        first: ColoredBox(color: Color(0x33FFC107), child: Center(child: Text('First pane'))),
        second: ColoredBox(color: Color(0x332196F3), child: Center(child: Text('Second pane'))),
      ))),
      _Demo('Accordion', _box(220, 120, const Accordion(
        items: [
          AccordionItem(value: 'one', title: 'Is it accessible?', child: Text('Yes. Keyboard-first and labeled.')),
          AccordionItem(value: 'two', title: 'Is it token-driven?', child: Text('Every visual comes from DesktopTokens.')),
        ],
      ))),
      _Demo('Collapsible', _box(220, 100, Collapsible(
        open: _collapsibleOpen,
        onOpenChanged: (v) => setState(() => _collapsibleOpen = v),
        trigger: Text(_collapsibleOpen ? 'Hide details' : 'Show details'),
        child: const Text('Collapsible details appear here.'),
      ))),
      _Demo('Sheet', _box(200, 40, const Sheet(
        trigger: Button(text: 'Open sheet', onPressed: null),
        side: OverlaySide.bottom,
        width: 200,
        content: Padding(padding: EdgeInsets.all(16), child: Text('Bottom sheet content')),
      ))),
      _Demo('SidePanel', _box(220, 40, Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(text: 'Open side panel', onPressed: () => setState(() => _sidePanelOpen = true)),
            SidePanel(
              open: _sidePanelOpen,
              onClose: () => setState(() => _sidePanelOpen = false),
              content: const Padding(padding: EdgeInsets.all(16), child: Text('Panel content')),
            ),
          ],
        ),
      ))),
      _Demo('Sidebar', _box(200, 150, const Sidebar(
        header: Text('My App', style: TextStyle(fontWeight: FontWeight.w700)),
        children: [
          SidebarItem(label: 'Dashboard', icon: Icon(Icons.dashboard), selected: true),
          SidebarItem(label: 'Orders', icon: Icon(Icons.receipt_long)),
          SidebarItem(label: 'Settings', icon: Icon(Icons.settings)),
        ],
      ))),
      _Demo('Carousel', _box(240, 120, const Carousel(
        height: 100,
        children: [
          ColoredBox(color: Color(0xFF4FC3F7), child: Center(child: Text('1'))),
          ColoredBox(color: Color(0xFF81C784), child: Center(child: Text('2'))),
          ColoredBox(color: Color(0xFFFFB74D), child: Center(child: Text('3'))),
        ],
      ))),
      // ── Overlay ──────────────────────────────────────────────────────────
      _Demo('Popover', _box(200, 40, const Popover(
        trigger: Button(text: 'Open popover', onPressed: null),
        content: Padding(padding: EdgeInsets.all(12), child: Text('Popover content')),
      ))),
      _Demo('HoverCard', _box(220, 40, const HoverCard(
        trigger: Text('@johndoe', style: TextStyle(color: Color(0xFF0F6CBD), decoration: TextDecoration.underline)),
        width: 200,
        content: Padding(padding: EdgeInsets.all(12), child: Text('John Doe — product designer')),
      ))),
      _Demo('DropDownButton', _box(200, 40, const DropDownButton(
        trigger: Button(text: 'Actions ▾', onPressed: null),
        items: [
          ListItem(title: 'Edit', onSelect: null),
          ListItem(title: 'Duplicate', onSelect: null),
          ListItem(title: 'Delete', enabled: false, onSelect: null),
        ],
      ))),
      _Demo('MessageBox', _box(200, 40, const MessageBox(
        trigger: Button(text: 'Open message box', onPressed: null),
        title: 'Welcome',
        message: 'Message box body content.',
        type: MessageBoxType.info,
        buttons: MessageBoxButtons.ok,
      ))),
      _Demo('Command', _box(200, 40, const Command(
        trigger: Button(text: 'Open palette', onPressed: null),
        children: [
          CommandItem(text: 'New file', leading: Icon(Icons.note_add), onSelect: null),
          CommandItem(text: 'Search docs', leading: Icon(Icons.search), onSelect: null),
        ],
      ))),
      _Demo('Toast', _box(220, 200, const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Toast(title: 'Saved', description: 'Your changes have been saved.', icon: Icon(Icons.check_circle)),
          SizedBox(height: 8),
          Toast(title: 'Update available', description: 'Version 0.5.0 is ready.', icon: Icon(Icons.info_outline)),
        ],
      ))),
      _Demo('Direction', _box(220, 70, const Direction(
        textDirection: TextDirection.rtl,
        child: Align(alignment: Alignment.centerRight, child: Text('Right-to-left text')),
      ))),
      _Demo('Empty', _box(240, 160, const Empty(
        icon: Icon(Icons.inbox_outlined),
        title: 'No messages',
        description: 'Messages will appear here.',
      ))),
      // ── Dialogs & Data ───────────────────────────────────────────────────
      _Demo('ThemeDesigner', _box(620, 480, ThemeDesigner(
        tokens: DesktopTokens.winForm,
        onTokensChanged: (_) {},
        onConfirm: (_) {},
      ))),
      _Demo('Chart', _box(220, 100, const Chart(
        type: ChartType.bar,
        data: _chartData,
        showValues: false,
      ))),
      _Demo('Pagination', _box(320, 40, Pagination(
        pageCount: 8,
        currentPage: _paginationPage,
        onPageChanged: (p) => setState(() => _paginationPage = p),
      ))),
      // ── Misc — modern ────────────────────────────────────────────────────
      _Demo('Alert', _box(240, 90, const Alert(
        icon: Icon(Icons.info_outline),
        title: 'Heads up!',
        description: 'An informational alert.',
      ))),
      _Demo('Attachment', _box(240, 50, const Wrap(
        spacing: 8,
        children: [
          Attachment(name: 'report.pdf', sizeText: '2.4 MB', onRemove: null),
          Attachment(name: 'logo.png', sizeText: '18 KB', onRemove: null),
        ],
      ))),
      _Demo('Avatar', _box(200, 56, const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(fallback: 'JD'),
          SizedBox(width: 12),
          Avatar(fallback: 'AL', size: 48),
          Avatar(fallback: 'MK', size: 32),
        ],
      ))),
      _Demo('Breadcrumb', _box(240, 36, const Breadcrumb(
        items: [
          BreadcrumbItem('Home'),
          BreadcrumbItem('Docs'),
          BreadcrumbItem('Guide'),
        ],
      ))),
      _Demo('Bubble', _box(240, 130, const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Bubble(text: 'Hey! Did you review the mockups?'),
          SizedBox(height: 8),
          Bubble(text: 'Yes — looks great!', isMine: true),
        ],
      ))),
      _Demo('Message', _box(240, 150, const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Message(sender: 'Alice', time: '09:41', text: 'Did you get my email?'),
          Message(sender: 'You', time: '09:43', text: 'Yes! Looks solid.', isMine: true),
        ],
      ))),
      _Demo('MessageScroller', _box(220, 150, const MessageScroller(
        height: 150,
        children: [
          Message(sender: 'Alice', time: '09:00', text: 'Morning! Ready for the sync?'),
          Message(sender: 'You', time: '09:02', text: 'Morning! Yes.', isMine: true),
          Message(sender: 'Bob', time: '09:05', text: 'I can join at 10:00.'),
        ],
      ))),
      _Demo('Questionnaire', _box(240, 210, Questionnaire(
        questions: const [
          QuestionnaireQuestion(id: 'q1', title: 'How satisfied are you?', type: QuestionType.single, options: ['Good', 'Average', 'Poor']),
        ],
        onSubmit: (_) {},
      ))),
      _Demo('Skeleton', _box(220, 80, const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Skeleton(width: 180, height: 14),
          SizedBox(height: 8),
          Skeleton(height: 12),
          SizedBox(height: 8),
          Skeleton(width: 120, height: 12),
        ],
      ))),
      _Demo('Spinner', _box(200, 48, const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spinner(size: 20),
          SizedBox(width: 10),
          Text('Loading…'),
        ],
      ))),
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
  ///
  /// The child stays inside a fixed-size box (bounded constraints), which some
  /// demos need (internal scrollables like [CheckedListBox], flex in both
  /// directions). Each demo's box must therefore be at least the content's
  /// natural size; oversized boxes are scaled down by the [FittedBox].
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
