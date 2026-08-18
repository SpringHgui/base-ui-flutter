import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class CommandPage extends StatefulWidget {
  const CommandPage({super.key});

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  String _last = '—';

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Command palette',
            children: [
              Command(
                trigger: Button(text: 'Open command palette ⌘K', onPressed: null),
                onClose: () {},
                children: [
                  CommandItem(
                    text: 'Search documentation',
                    leading: const Icon(Icons.search),
                    keywords: const ['help', 'docs'],
                    onSelect: () => setState(() => _last = 'Search documentation'),
                  ),
                  CommandItem(
                    text: 'New file',
                    leading: const Icon(Icons.note_add),
                    trailing: const Kbd('Ctrl+N'),
                    onSelect: () => setState(() => _last = 'New file'),
                  ),
                  const CommandSeparator(),
                  CommandItem(
                    text: 'Open settings',
                    leading: const Icon(Icons.settings),
                    trailing: const Kbd('Ctrl+,'),
                    onSelect: () => setState(() => _last = 'Open settings'),
                  ),
                  CommandItem(
                    text: 'Deploy',
                    leading: const Icon(Icons.rocket_launch),
                    onSelect: () => setState(() => _last = 'Deploy'),
                  ),
                  CommandItem(
                    text: 'Log out',
                    leading: const Icon(Icons.logout),
                    onSelect: () => setState(() => _last = 'Log out'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Selected: $_last'),
            ],
          ),
        ],
      ),
    );
  }
}
