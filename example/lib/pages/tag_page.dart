import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class TagPage extends StatelessWidget {
  const TagPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(title: 'Variants', children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Tag('Primary'),
                Tag('Secondary', variant: TagVariant.secondary),
                Tag('Destructive', variant: TagVariant.destructive),
                Tag('Outline', variant: TagVariant.outline),
              ],
            ),
          ]),
          DemoSection(title: 'Statuses', children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Tag('Active'),
                Tag('Pending', variant: TagVariant.outline),
                Tag('Failed', variant: TagVariant.destructive),
                Tag('Beta', variant: TagVariant.secondary),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
