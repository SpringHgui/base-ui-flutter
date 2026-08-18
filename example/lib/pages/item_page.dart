import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(title: 'Basic items', children: [
            Item(text: 'New File', onSelect: null),
            Item(text: 'Open…', onSelect: null),
            Item(text: 'Save', onSelect: null),
          ]),
          DemoSection(title: 'With icons and selection', children: [
            Item(
              text: 'Copy',
              leading: Icon(Icons.copy),
              trailing: Icon(Icons.check),
              selected: true,
            ),
            Item(
              text: 'Paste',
              leading: Icon(Icons.content_paste),
              trailing: Kbd('Ctrl+V'),
            ),
            Item(text: 'Cut', leading: Icon(Icons.cut), trailing: Kbd('Ctrl+X')),
          ]),
          DemoSection(title: 'Disabled', children: [
            Item(text: 'Delete', enabled: false, onSelect: null),
          ]),
        ],
      ),
    );
  }
}
