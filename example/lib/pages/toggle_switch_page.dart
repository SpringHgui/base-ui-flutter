import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class ToggleSwitchPage extends StatefulWidget {
  const ToggleSwitchPage({super.key});

  @override
  State<ToggleSwitchPage> createState() => _ToggleSwitchPageState();
}

class _ToggleSwitchPageState extends State<ToggleSwitchPage> {
  bool _wifi = true;
  bool _bluetooth = false;
  bool _airplane = false;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Settings switches',
            children: [
              _row('Wi-Fi', _wifi, (v) => setState(() => _wifi = v)),
              _row('Bluetooth', _bluetooth, (v) => setState(() => _bluetooth = v)),
              _row('Airplane mode', _airplane, (v) => setState(() => _airplane = v)),
            ],
          ),
          const DemoSection(
            title: 'Disabled',
            children: [
              Row(
                children: [
                  Text('Locked'),
                  SizedBox(width: 12),
                  ToggleSwitch(value: true, onChanged: _noop, enabled: false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _row(String label, bool value, ValueChanged<bool> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        ToggleSwitch(value: value, onChanged: onChanged),
      ],
    ),
  );
}

void _noop(bool _) {}

