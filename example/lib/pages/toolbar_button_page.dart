import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

/// Demonstrates the [ToolbarButton] widget: standalone toolbar buttons with
/// icon / text, hover / pressed states, caret and outlined trigger styles.
class ToolbarButtonPage extends StatefulWidget {
  const ToolbarButtonPage({super.key});

  @override
  State<ToolbarButtonPage> createState() => _ToolbarButtonPageState();
}

class _ToolbarButtonPageState extends State<ToolbarButtonPage> {
  String _lastAction = '—';

  void _run(String label) => setState(() => _lastAction = label);

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Icon + text toolbar',
            children: [
              Container(
                color: t.controlColor,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ToolbarButton(
                      icon: Icons.note_add,
                      text: 'New',
                      tooltip: 'Create a new file',
                      onTap: () => _run('New'),
                    ),
                    ToolbarButton(
                      icon: Icons.folder_open,
                      text: 'Open',
                      tooltip: 'Open a file',
                      onTap: () => _run('Open'),
                    ),
                    ToolbarButton(
                      icon: Icons.save,
                      text: 'Save',
                      tooltip: 'Save the file',
                      onTap: () => _run('Save'),
                    ),
                    const SizedBox(
                      height: 20,
                      child: Separator(orientation: Axis.vertical),
                    ),
                    ToolbarButton(
                      icon: Icons.cut,
                      text: 'Cut',
                      onTap: () => _run('Cut'),
                    ),
                    ToolbarButton(
                      icon: Icons.copy,
                      text: 'Copy',
                      onTap: () => _run('Copy'),
                    ),
                    ToolbarButton(
                      icon: Icons.paste,
                      text: 'Paste',
                      onTap: () => _run('Paste'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DemoSection(
            title: 'Icon-only with accent color',
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToolbarButton(
                    icon: Icons.play_arrow,
                    iconColor: const Color(0xFF0F6CBD),
                    tooltip: 'Run',
                    onTap: () => _run('Run'),
                  ),
                  ToolbarButton(
                    icon: Icons.stop,
                    iconColor: const Color(0xFFC62828),
                    tooltip: 'Stop',
                    onTap: () => _run('Stop'),
                  ),
                  ToolbarButton(
                    icon: Icons.refresh,
                    tooltip: 'Refresh',
                    onTap: () => _run('Refresh'),
                  ),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'Trigger style (outlined + caret)',
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToolbarButton(
                    text: 'Sort',
                    outlined: true,
                    showCaret: true,
                    onTap: () => _run('Sort'),
                  ),
                  const SizedBox(width: 8),
                  ToolbarButton(
                    icon: Icons.filter_list,
                    text: 'Filter',
                    outlined: true,
                    showCaret: true,
                    onTap: () => _run('Filter'),
                  ),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'Disabled',
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToolbarButton(
                    icon: Icons.delete,
                    text: 'Delete',
                    enabled: false,
                    onTap: () => _run('Delete'),
                  ),
                  const SizedBox(width: 8),
                  ToolbarButton(
                    icon: Icons.cloud_upload,
                    tooltip: 'Upload',
                    enabled: false,
                    onTap: () => _run('Upload'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Last action: $_lastAction'),
        ],
      ),
    );
  }
}
