import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SurfacePage extends StatefulWidget {
  const SurfacePage({super.key});

  @override
  State<SurfacePage> createState() => _SurfacePageState();
}

class _SurfacePageState extends State<SurfacePage> {
  int _tapCount = 0;
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(title: 'Interactive (hover / press)', children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Surface(
                  color: const Color(0xFFE0E0E0),
                  borderColor: const Color(0xFFB0B0B0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () => setState(() => _tapCount++),
                  child: Label('Tapped $_tapCount times'),
                ),
                const SizedBox(width: 16),
                Surface(
                  color: const Color(0xFFD0E8FF),
                  borderColor: const Color(0xFF80B0E0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () {},
                  child: const Label('Hover me'),
                ),
              ],
            ),
          ]),
          DemoSection(title: 'Selected state', children: [
            Surface(
              color: _selected ? const Color(0xFF0078D4) : const Color(0xFFE0E0E0),
              borderColor: const Color(0xFFB0B0B0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              selected: _selected,
              onTap: () => setState(() => _selected = !_selected),
              child: Label(_selected ? 'Selected' : 'Click to select'),
            ),
          ]),
          DemoSection(title: 'Disabled', children: [
            Surface(
              color: const Color(0xFFE0E0E0),
              borderColor: const Color(0xFFB0B0B0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              enabled: false,
              onTap: () {},
              child: const Label('Disabled (no interaction)'),
            ),
          ]),
          DemoSection(title: 'Non-interactive (no onTap)', children: [
            Surface(
              color: const Color(0xFFF0F0F0),
              borderColor: const Color(0xFFD0D0D0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Label('Static surface — no hover effect'),
            ),
          ]),
        ],
      ),
    );
  }
}
