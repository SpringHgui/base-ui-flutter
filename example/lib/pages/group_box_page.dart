import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class GroupBoxPage extends StatelessWidget {
  const GroupBoxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'Title + description + footer',
            children: [
              GroupBox(
                title: 'Account settings',
                description: 'Manage how your account looks and behaves.',
                footer: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button(text: 'Save changes', onPressed: null),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: John Doe'),
                    SizedBox(height: 6),
                    Text('Email: john@example.com'),
                  ],
                ),
              ),
            ],
          ),
          const DemoSection(
            title: 'Plain card',
            children: [
              GroupBox(
                child: Text(
                    'A simple bordered surface without a header — '
                    'useful for grouping related content.'),
              ),
            ],
          ),
          DemoSection(
            title: 'Custom header',
            children: [
              GroupBox(
                header: Row(
                  children: [
                    const Icon(Icons.star, size: 18),
                    const SizedBox(width: 8),
                    Text('Custom header slot'),
                  ],
                ),
                child: const Text('Body content here.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
