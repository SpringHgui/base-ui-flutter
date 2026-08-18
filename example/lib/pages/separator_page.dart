import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SeparatorPage extends StatelessWidget {
  const SeparatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(title: 'Horizontal', children: [
            Text('Above the separator'),
            Separator(),
            Text('Below the separator'),
          ]),
          DemoSection(title: 'Vertical (toolbars)', children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Left'),
                SizedBox(height: 40, child: Separator(orientation: Axis.vertical)),
                Text('Right'),
              ],
            ),
          ]),
          DemoSection(title: 'With margin', children: [
            Text('A'),
            Separator(margin: EdgeInsets.symmetric(vertical: 12)),
            Text('B'),
          ]),
        ],
      ),
    );
  }
}
