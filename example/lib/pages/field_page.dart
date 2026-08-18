import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class FieldPage extends StatelessWidget {
  const FieldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Label + description',
            children: [
              Field(
                label: 'Username',
                description: 'This is how others see you.',
                children: [Input(hint: 'Enter username')],
              ),
            ],
          ),
          DemoSection(
            title: 'Required + error',
            children: [
              Field(
                label: 'Email',
                required: true,
                error: 'Please enter a valid email address.',
                children: [Input(hint: 'you@example.com')],
              ),
            ],
          ),
          const DemoSection(
            title: 'Standalone parts',
            children: [
              FieldLabel('FieldLabel — plain label'),
              FieldDescription('FieldDescription — helper text'),
              FieldMessage('FieldMessage — neutral message'),
              FieldError('FieldError — error text'),
            ],
          ),
        ],
      ),
    );
  }
}
