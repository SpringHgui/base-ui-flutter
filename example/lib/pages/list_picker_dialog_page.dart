import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

/// Demonstrates [ListPickerDialog]: a generic multi-select candidate picker
/// that returns the checked items in candidate order (or `null` on cancel).
class ListPickerDialogPage extends StatefulWidget {
  const ListPickerDialogPage({super.key});

  @override
  State<ListPickerDialogPage> createState() => _ListPickerDialogPageState();
}

class _ListPickerDialogPageState extends State<ListPickerDialogPage> {
  List<String> _parents = const [];
  List<int> _columns = const [];

  String _describe(List<Object>? picked) =>
      picked == null ? 'cancelled' : (picked.isEmpty ? '(none)' : picked.join(', '));

  Future<void> _pickParents() async {
    final picked = await ListPickerDialog.show<String>(
      context,
      title: 'Choose parent tables',
      items: const ['audit_log', 'customers', 'orders', 'products'],
      selected: _parents,
      okText: 'OK',
      cancelText: 'Cancel',
    );
    if (!mounted) return;
    setState(() => _parents = picked ?? _parents);
  }

  Future<void> _pickColumns() async {
    // Non-String items: `itemToString` labels the rows, results keep the
    // original objects.
    final picked = await ListPickerDialog.show<int>(
      context,
      title: 'Choose columns',
      items: const [1, 2, 3],
      itemToString: (id) => 'column_$id',
      selected: _columns,
    );
    if (!mounted) return;
    setState(() => _columns = picked ?? _columns);
  }

  Future<void> _pickFromEmpty() async {
    final picked = await ListPickerDialog.show<String>(
      context,
      title: 'No candidates yet',
      items: const [],
      emptyHint: 'Nothing to choose from — type the name instead.',
    );
    if (!mounted) return;
    setState(() => _parents = picked ?? _parents);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'String candidates',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Button(text: 'Pick parent tables…', onPressed: _pickParents),
                  Button(text: 'Pick columns…', onPressed: _pickColumns),
                  Button(text: 'Empty candidate list…', onPressed: _pickFromEmpty),
                ],
              ),
              const SizedBox(height: 8),
              Text('Parents: ${_describe(_parents)}'),
              Text('Columns: ${_describe(_columns)}'),
            ],
          ),
          DemoSection(
            title: 'Notes',
            children: const [
              Text('• Results are ordered by the candidate list, not by click order.'),
              Text('• Cancel / close returns null, so the host keeps its old value.'),
              Text('• Rows are rendered lazily, so thousands of collations are fine.'),
            ],
          ),
        ],
      ),
    );
  }
}
