import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SplitContainerPage extends StatefulWidget {
  const SplitContainerPage({super.key});

  @override
  State<SplitContainerPage> createState() => _SplitContainerPageState();
}

class _SplitContainerPageState extends State<SplitContainerPage> {
  double _ratio = 0.5;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Horizontal split (left / right)',
            children: [
              SizedBox(
                height: 200,
                child: SplitContainer(
                  initialRatio: _ratio,
                  onChanged: (r) => setState(() => _ratio = r),
                  first: const ColoredBox(
                    color: Color(0x33FFC107),
                    child: Center(child: Text('First pane')),
                  ),
                  second: const ColoredBox(
                    color: Color(0x332196F3),
                    child: Center(child: Text('Second pane')),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Ratio: ${_ratio.toStringAsFixed(2)} — drag the divider'),
            ],
          ),
          const DemoSection(
            title: 'Vertical split (top / bottom)',
            children: [
              SizedBox(
                height: 180,
                child: SplitContainer(
                  orientation: Axis.vertical,
                  initialRatio: 0.6,
                  first: ColoredBox(
                    color: Color(0x334CAF50),
                    child: Center(child: Text('Top pane')),
                  ),
                  second: ColoredBox(
                    color: Color(0x33FF5722),
                    child: Center(child: Text('Bottom pane')),
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
