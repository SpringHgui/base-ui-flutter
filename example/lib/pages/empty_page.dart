import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'Basic empty state',
            children: [
              SizedBox(
                height: 220,
                child: GroupBox(
                  child: Empty(
                    icon: Icon(Icons.inbox_outlined),
                    title: 'No messages yet',
                    description:
                        'When you receive messages, they will show up here.',
                  ),
                ),
              ),
            ],
          ),
          const DemoSection(
            title: 'With action',
            children: [
              SizedBox(
                height: 240,
                child: GroupBox(
                  child: Empty(
                    icon: Icon(Icons.folder_open),
                    title: 'No projects',
                    description: 'Create a project to get started.',
                    action: Button(text: 'New project', onPressed: null),
                  ),
                ),
              ),
            ],
          ),
          const DemoSection(
            title: 'Compact inline',
            children: [
              GroupBox(
                child: Empty(
                  compact: true,
                  icon: Icon(Icons.filter_alt_outlined),
                  title: 'No filters applied',
                  description: 'Filters narrow down the visible rows.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
