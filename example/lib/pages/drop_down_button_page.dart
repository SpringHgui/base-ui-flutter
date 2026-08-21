import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class DropDownButtonPage extends StatefulWidget {
  const DropDownButtonPage({super.key});

  @override
  State<DropDownButtonPage> createState() => _DropDownButtonPageState();
}

class _DropDownButtonPageState extends State<DropDownButtonPage> {
  String _lastAction = '—';

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Menu button',
            children: [
              DropDownButton(
                trigger: Button(text: 'Actions ▾', onPressed: null),
                items: [
                  ListItem(
                    title: 'Edit',
                    leading: const Icon(Icons.edit, size: 16),
                    onSelect: () => setState(() => _lastAction = 'Edit'),
                  ),
                  ListItem(
                    title: 'Duplicate',
                    leading: const Icon(Icons.copy, size: 16),
                    onSelect: () => setState(() => _lastAction = 'Duplicate'),
                  ),
                  ListItem(
                    title: 'Archive',
                    leading: const Icon(Icons.archive, size: 16),
                    onSelect: () => setState(() => _lastAction = 'Archive'),
                  ),
                  ListItem(
                    title: 'Delete',
                    leading: const Icon(Icons.delete, size: 16),
                    enabled: false,
                    onSelect: null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Last action: $_lastAction'),
            ],
          ),
          const DemoSection(
            title: 'With header',
            children: [
              DropDownButton(
                trigger: Button(text: 'Sort by ▾', onPressed: null),
                header: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text('Sort options', style: TextStyle(fontSize: 12)),
                ),
                items: [
                  ListItem(title: 'Name', onSelect: null),
                  ListItem(title: 'Date', selected: true, onSelect: null),
                  ListItem(title: 'Size', onSelect: null),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
