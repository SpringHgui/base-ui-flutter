import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SpinnerPage extends StatelessWidget {
  const SpinnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(
            title: 'Sizes',
            children: [
              Row(
                children: [
                  Spinner(size: 16),
                  SizedBox(width: 16),
                  Spinner(size: 24),
                  SizedBox(width: 16),
                  Spinner(size: 36),
                  SizedBox(width: 16),
                  Spinner(size: 48),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'In context',
            children: [
              Row(
                children: [
                  Spinner(size: 18),
                  SizedBox(width: 10),
                  Text('Loading…'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
