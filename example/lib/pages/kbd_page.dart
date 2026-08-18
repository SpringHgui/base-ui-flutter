import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class KbdPage extends StatelessWidget {
  const KbdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(title: 'Shortcut hints', children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Save:'),
                Kbd('Ctrl'),
                Text('+'),
                Kbd('S'),
              ],
            ),
          ]),
          const DemoSection(title: 'Common key names', children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Kbd('Ctrl'),
                Kbd('Alt'),
                Kbd('Shift'),
                Kbd('Enter'),
                Kbd('Esc'),
                Kbd('Tab'),
                Kbd('F5'),
                Kbd('Space'),
              ],
            ),
          ]),
          const DemoSection(title: 'Combo', children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Copy:'),
                Kbd('Ctrl'),
                Text('+'),
                Kbd('C'),
                Text('  Paste:'),
                Kbd('Ctrl'),
                Text('+'),
                Kbd('V'),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
