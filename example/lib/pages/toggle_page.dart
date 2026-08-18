import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class TogglePage extends StatefulWidget {
  const TogglePage({super.key});

  @override
  State<TogglePage> createState() => _TogglePageState();
}

class _TogglePageState extends State<TogglePage> {
  bool _bold = false;
  bool _italic = false;
  bool _outline = false;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Icon toggles (default variant)',
            children: [
              Wrap(
                spacing: 8,
                children: [
                  Toggle(
                    selected: _bold,
                    onChanged: (v) => setState(() => _bold = v),
                    child: const Icon(Icons.format_bold, size: 16),
                  ),
                  Toggle(
                    selected: _italic,
                    onChanged: (v) => setState(() => _italic = v),
                    child: const Icon(Icons.format_italic, size: 16),
                  ),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'Outline variant + sizes',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Toggle(
                    selected: _outline,
                    onChanged: (v) => setState(() => _outline = v),
                    variant: ToggleVariant.outline,
                    size: ToggleSize.small,
                    child: const Text('Small'),
                  ),
                  Toggle(
                    selected: _outline,
                    onChanged: (v) => setState(() => _outline = v),
                    variant: ToggleVariant.outline,
                    child: const Text('Medium'),
                  ),
                  Toggle(
                    selected: _outline,
                    onChanged: (v) => setState(() => _outline = v),
                    variant: ToggleVariant.outline,
                    size: ToggleSize.large,
                    child: const Text('Large'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
