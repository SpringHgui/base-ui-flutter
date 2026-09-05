import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SplitterPage extends StatefulWidget {
  const SplitterPage({super.key});

  @override
  State<SplitterPage> createState() => _SplitterPageState();
}

class _SplitterPageState extends State<SplitterPage> {
  double _leftWidth = 180;
  double _topHeight = 120;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Horizontal handle (host-owned pixel width)',
            children: [
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    SizedBox(
                      width: _leftWidth,
                      child: const ColoredBox(
                        color: Color(0x33FFC107),
                        child: Center(child: Text('Pane')),
                      ),
                    ),
                    Splitter(
                      onDrag: (dx) => setState(
                          () => _leftWidth = (_leftWidth + dx).clamp(120.0, 400.0)),
                    ),
                    const Expanded(
                      child: ColoredBox(
                        color: Color(0x332196F3),
                        child: Center(child: Text('Content')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Left pane: ${_leftWidth.toStringAsFixed(0)} px'),
            ],
          ),
          DemoSection(
            title: 'Vertical handle (resizeUpDown cursor)',
            children: [
              SizedBox(
                height: 260,
                child: Column(
                  children: [
                    SizedBox(
                      height: _topHeight,
                      child: const ColoredBox(
                        color: Color(0x334CAF50),
                        child: Center(child: Text('Top')),
                      ),
                    ),
                    Splitter(
                      orientation: Axis.vertical,
                      onDrag: (dy) => setState(
                          () => _topHeight = (_topHeight + dy).clamp(60.0, 200.0)),
                    ),
                    const Expanded(
                      child: ColoredBox(
                        color: Color(0x33FF5722),
                        child: Center(child: Text('Bottom')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Top pane: ${_topHeight.toStringAsFixed(0)} px'),
            ],
          ),
        ],
      ),
    );
  }
}
