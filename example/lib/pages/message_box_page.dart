import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class MessageBoxPage extends StatefulWidget {
  const MessageBoxPage({super.key});

  @override
  State<MessageBoxPage> createState() => _MessageBoxPageState();
}

class _MessageBoxPageState extends State<MessageBoxPage> {
  String _result = '—';

  Future<void> _confirm() async {
    final result = await MessageBox.show(
      context,
      title: 'Delete file?',
      message: 'This action cannot be undone. The file will be permanently '
          'removed from the server.',
      type: MessageBoxType.warning,
      buttons: MessageBoxButtons.okCancel,
    );
    if (!mounted) return;
    setState(() => _result = result.name);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Static show (async)',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Button(text: 'Info', onPressed: () => _demo(MessageBoxType.info)),
                  Button(text: 'Question', onPressed: () => _demo(MessageBoxType.question)),
                  Button(text: 'Warning', onPressed: () => _demo(MessageBoxType.warning)),
                  Button(text: 'Error', onPressed: () => _demo(MessageBoxType.error)),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'Confirm with result',
            children: [
              Button(text: 'Delete file…', onPressed: _confirm),
              const SizedBox(height: 8),
              Text('Result: $_result'),
            ],
          ),
          const DemoSection(
            title: 'Trigger-based',
            children: [
              MessageBox(
                trigger: Button(text: 'Open via trigger', onPressed: null),
                title: 'Welcome',
                message: 'This message box is opened by its trigger widget.',
                type: MessageBoxType.info,
                buttons: MessageBoxButtons.ok,
              ),
            ],
          ),
          const DemoSection(
            title: 'Custom content',
            children: [
              MessageBox(
                trigger: Button(text: 'Custom content', onPressed: null),
                title: 'Sign in',
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Input(hint: 'Username'),
                    SizedBox(height: 8),
                    Input(hint: 'Password'),
                  ],
                ),
                buttons: MessageBoxButtons.okCancel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _demo(MessageBoxType type) {
    MessageBox.show(
      context,
      title: 'Message box',
      message: 'This is a ${type.name} message box.',
      type: type,
    );
  }
}
