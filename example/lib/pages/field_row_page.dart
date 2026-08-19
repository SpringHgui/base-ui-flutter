import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class FieldRowPage extends StatelessWidget {
  const FieldRowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(title: 'Basic', children: [
            SizedBox(
              width: 320,
              child: Column(
                children: [
                  FieldRow(label: 'Host:', child: Input(hint: 'localhost')),
                  const SizedBox(height: 8),
                  FieldRow(label: 'Port:', child: Input(hint: '3306')),
                  const SizedBox(height: 8),
                  FieldRow(label: 'User:', child: Input(hint: 'root')),
                ],
              ),
            ),
          ]),
          DemoSection(title: 'Without label (alignment spacer)', children: [
            SizedBox(
              width: 320,
              child: Column(
                children: [
                  const FieldRow(label: 'Name:', child: Input(hint: 'Database name')),
                  const SizedBox(height: 8),
                  FieldRow(child: Input(hint: 'No label — aligned')),
                ],
              ),
            ),
          ]),
          DemoSection(title: 'Custom label width', children: [
            SizedBox(
              width: 360,
              child: Column(
                children: [
                  FieldRow(label: 'Connection:', labelWidth: 100, child: Input(hint: 'My connection')),
                  const SizedBox(height: 8),
                  FieldRow(label: 'Password:', labelWidth: 100, child: Input(hint: '••••••')),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
