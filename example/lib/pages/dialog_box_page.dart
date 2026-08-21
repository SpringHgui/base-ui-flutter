import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

/// Demonstrates the [DialogBox] widget: a dialog window shell with title
/// bar, body and optional footer, usually shown via `showDialog`.
class DialogBoxPage extends StatefulWidget {
  const DialogBoxPage({super.key});

  @override
  State<DialogBoxPage> createState() => _DialogBoxPageState();
}

class _DialogBoxPageState extends State<DialogBoxPage> {
  String _result = '—';

  Future<void> _openConfirm() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => DialogBox(
        title: 'Delete file?',
        width: 360,
        onClose: () => Navigator.of(ctx).pop('dismissed'),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              text: 'Cancel',
              onPressed: () => Navigator.of(ctx).pop('cancel'),
            ),
            const SizedBox(width: 8),
            Button(
              text: 'Delete',
              onPressed: () => Navigator.of(ctx).pop('delete'),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'This action cannot be undone. The file will be permanently '
            'removed from the server.',
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _result = result ?? 'dismissed');
  }

  Future<void> _openForm() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => DialogBox(
        title: 'Sign in',
        width: 340,
        onClose: () => Navigator.of(ctx).pop('dismissed'),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              text: 'OK',
              onPressed: () => Navigator.of(ctx).pop('ok'),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Input(hint: 'Username'),
              SizedBox(height: 8),
              Input(hint: 'Password'),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _result = result ?? 'dismissed');
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Open via showDialog',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Button(text: 'Confirm dialog…', onPressed: _openConfirm),
                  Button(text: 'Form dialog…', onPressed: _openForm),
                ],
              ),
              const SizedBox(height: 8),
              Text('Result: $_result'),
            ],
          ),
          DemoSection(
            title: 'Inline preview',
            children: [
              SizedBox(
                width: 420,
                height: 220,
                child: DialogBox(
                  title: 'Account settings',
                  onClose: () {},
                  footer: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(text: 'Save changes', onPressed: null),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: John Doe'),
                        SizedBox(height: 6),
                        Text('Email: john@example.com'),
                        SizedBox(height: 6),
                        Text('Role: Administrator'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
