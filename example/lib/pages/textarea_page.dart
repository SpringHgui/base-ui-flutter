import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class TextareaPage extends StatelessWidget {
  const TextareaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'Basic',
            children: [
              Textarea(hint: 'Type your message here…'),
            ],
          ),
          const DemoSection(
            title: 'Taller',
            children: [
              Textarea(hint: 'Notes…', minLines: 5),
            ],
          ),
          const DemoSection(
            title: 'Disabled',
            children: [
              Textarea(hint: 'Read-only area', enabled: false),
            ],
          ),
          const DemoSection(
            title: 'Inside InputGroup',
            children: [
              InputGroup(
                leading: InputGroupAddon(Icon(Icons.description, size: 16)),
                child: Textarea(hint: 'Description…', minLines: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
