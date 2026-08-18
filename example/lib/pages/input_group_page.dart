import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class InputGroupPage extends StatelessWidget {
  const InputGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'Leading add-on',
            children: [
              InputGroup(
                leading: InputGroupAddon(Icon(Icons.search, size: 16)),
                child: Input(hint: 'Search…'),
              ),
            ],
          ),
          const DemoSection(
            title: 'Trailing unit',
            children: [
              InputGroup(
                trailing: InputGroupAddon(Text('USD')),
                child: Input(hint: 'Amount'),
              ),
            ],
          ),
          const DemoSection(
            title: 'Both sides',
            children: [
              InputGroup(
                leading: InputGroupAddon(Icon(Icons.person, size: 16)),
                trailing: InputGroupAddon(Text('@example.com')),
                child: Input(hint: 'Username'),
              ),
            ],
          ),
          const DemoSection(
            title: 'With textarea',
            children: [
              InputGroup(
                trailing: InputGroupAddon(Text('Markdown')),
                child: Textarea(hint: 'Write your notes…', minLines: 3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
