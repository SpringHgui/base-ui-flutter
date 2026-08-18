import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class TabControlPage extends StatefulWidget {
  const TabControlPage({super.key});

  @override
  State<TabControlPage> createState() => _TabControlPageState();
}

class _TabControlPageState extends State<TabControlPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Basic tabs',
            children: [
              TabControl(
                onChanged: (i) => setState(() => _index = i),
                tabs: const [
                  TabItem(label: 'Overview', child: Text('Overview content')),
                  TabItem(label: 'Details', child: Text('Details content')),
                  TabItem(label: 'Activity', child: Text('Activity content')),
                ],
              ),
              const SizedBox(height: 8),
              Text('Selected tab: $_index'),
            ],
          ),
          const DemoSection(
            title: 'With icons',
            children: [
              TabControl(
                initialIndex: 1,
                tabs: [
                  TabItem(
                    label: 'Inbox',
                    icon: Icon(Icons.inbox, size: 16),
                    child: Text('Inbox content'),
                  ),
                  TabItem(
                    label: 'Sent',
                    icon: Icon(Icons.send, size: 16),
                    child: Text('Sent content'),
                  ),
                  TabItem(
                    label: 'Archive',
                    icon: Icon(Icons.archive, size: 16),
                    child: Text('Archive content'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
