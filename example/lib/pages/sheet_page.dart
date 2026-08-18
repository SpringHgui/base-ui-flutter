import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SheetPage extends StatefulWidget {
  const SheetPage({super.key});

  @override
  State<SheetPage> createState() => _SheetPageState();
}

class _SheetPageState extends State<SheetPage> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Right sheet (controlled)',
            children: [
              Button(text: 'Open right sheet', onPressed: () => setState(() => _open = true)),
              Sheet(
                open: _open,
                onClose: () => setState(() => _open = false),
                content: _panel('Right sheet', 'Slides in from the right edge.'),
              ),
            ],
          ),
          DemoSection(
            title: 'Bottom sheet via trigger',
            children: [
              Sheet(
                trigger: Button(text: 'Open bottom sheet', onPressed: null),
                side: OverlaySide.bottom,
                width: 260,
                content: _panel('Bottom sheet', 'Slides up from the bottom.'),
              ),
            ],
          ),
          DemoSection(
            title: 'Top sheet via controller',
            children: [
              Builder(builder: (context) {
                final controller = OverlayController();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Button(text: 'Open top sheet', onPressed: controller.open),
                    Sheet(
                      controller: controller,
                      side: OverlaySide.top,
                      width: 200,
                      content: _panel('Top sheet', 'Slides down from the top.'),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _panel(String title, String description) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    );
  }
}
