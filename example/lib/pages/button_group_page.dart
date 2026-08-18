import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class ButtonGroupPage extends StatelessWidget {
  const ButtonGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'Horizontal',
            children: [
              ButtonGroup(
                children: [
                  Button(text: 'Left', onPressed: null),
                  Button(text: 'Center', onPressed: null),
                  Button(text: 'Right', onPressed: null),
                ],
              ),
            ],
          ),
          const DemoSection(
            title: 'Vertical',
            children: [
              ButtonGroup(
                orientation: ButtonGroupOrientation.vertical,
                children: [
                  Button(text: 'Top', onPressed: null),
                  Button(text: 'Middle', onPressed: null),
                  Button(text: 'Bottom', onPressed: null),
                ],
              ),
            ],
          ),
          const DemoSection(
            title: 'With toggle buttons',
            children: [
              ButtonGroup(
                children: [
                  Toggle(selected: true, onChanged: null, child: Icon(Icons.format_bold, size: 16)),
                  Toggle(selected: false, onChanged: null, child: Icon(Icons.format_italic, size: 16)),
                  Toggle(selected: false, onChanged: null, child: Icon(Icons.format_underline, size: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
