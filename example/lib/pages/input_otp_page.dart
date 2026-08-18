import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class InputOtpPage extends StatefulWidget {
  const InputOtpPage({super.key});

  @override
  State<InputOtpPage> createState() => _InputOtpPageState();
}

class _InputOtpPageState extends State<InputOtpPage> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: '6-digit code',
            children: [
              InputOtp(onChanged: (v) => setState(() => _code = v)),
              const SizedBox(height: 8),
              Text('Entered: ${_code.isEmpty ? '—' : _code}'),
            ],
          ),
          const DemoSection(
            title: '4-digit code',
            children: [
              InputOtp(length: 4),
            ],
          ),
          const DemoSection(
            title: 'Disabled',
            children: [
              InputOtp(enabled: false),
            ],
          ),
        ],
      ),
    );
  }
}
