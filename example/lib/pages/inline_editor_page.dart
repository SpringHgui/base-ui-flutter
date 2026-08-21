import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

/// Demonstrates the [InlineEditor] widget: an inline cell editor that
/// focuses on build, commits on Enter / blur and cancels on Esc.
class InlineEditorPage extends StatefulWidget {
  const InlineEditorPage({super.key});

  @override
  State<InlineEditorPage> createState() => _InlineEditorPageState();
}

class _InlineEditorPageState extends State<InlineEditorPage> {
  String _name = 'report-q3.pdf';
  bool _editing = false;
  String _lastEvent = '—';

  void _startEditing() {
    setState(() => _editing = true);
  }

  void _commit(String value) {
    setState(() {
      _name = value.isEmpty ? _name : value;
      _editing = false;
      _lastEvent = 'Committed: ${value.isEmpty ? '(empty, kept)' : value}';
    });
  }

  void _cancel() {
    setState(() {
      _editing = false;
      _lastEvent = 'Cancelled';
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Inline rename',
            children: [
              Container(
                width: 320,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: t.borderColor, width: t.borderWidth),
                  borderRadius: BorderRadius.circular(t.cornerRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _editing
                          ? InlineEditor(
                              initialValue: _name,
                              onCommit: _commit,
                              onChanged: (_) {},
                              onCancel: _cancel,
                            )
                          : Text(
                              _name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(height: 1.2),
                            ),
                    ),
                    if (!_editing)
                      IconBtn(
                        icon: Icons.edit,
                        iconSize: 14,
                        tooltip: 'Rename',
                        onTap: _startEditing,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Last event: $_lastEvent'),
            ],
          ),
          DemoSection(
            title: 'Behaviour',
            children: [
              _hint('Click the edit icon to start editing.'),
              _hint('Enter or clicking elsewhere commits the change.'),
              _hint('Esc cancels the edit and restores the previous value.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hint(String text) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(text, style: TextStyle(color: t.mutedForegroundColor)),
    );
  }
}
