import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class MarkerPage extends StatelessWidget {
  const MarkerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(title: 'Highlight in text', children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'The '),
                  WidgetSpan(child: Marker('quick brown fox')),
                  TextSpan(text: ' jumps over the lazy dog.'),
                ],
              ),
            ),
          ]),
          DemoSection(title: 'Custom color', children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Marker('Default accent'),
                Marker('Blue highlight', color: Color(0xFFDBEAFE)),
                Marker('Green highlight', color: Color(0xFFD1FAE5)),
                Marker('Red highlight', color: Color(0xFFFEE2E2)),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
