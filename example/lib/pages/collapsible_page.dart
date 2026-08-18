import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class CollapsiblePage extends StatefulWidget {
  const CollapsiblePage({super.key});

  @override
  State<CollapsiblePage> createState() => _CollapsiblePageState();
}

class _CollapsiblePageState extends State<CollapsiblePage> {
  bool _open = false;
  bool _open2 = true;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Controlled collapsible',
            children: [
              Collapsible(
                open: _open,
                onOpenChanged: (v) => setState(() => _open = v),
                trigger: Row(
                  children: [
                    Icon(
                      _open ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Show/hide details'),
                  ],
                ),
                child: const Text(
                    'These are the collapsible details. They animate '
                    'open and closed smoothly.'),
              ),
            ],
          ),
          DemoSection(
            title: 'Open by default',
            children: [
              Collapsible(
                open: _open2,
                onOpenChanged: (v) => setState(() => _open2 = v),
                trigger: const Text('Advanced options'),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Input(hint: 'Option A'),
                    SizedBox(height: 8),
                    Input(hint: 'Option B'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
