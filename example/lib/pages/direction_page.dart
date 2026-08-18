import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class DirectionPage extends StatelessWidget {
  const DirectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'LTR (default)',
            children: [
              Text('Current direction: LTR'),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Left-aligned text'),
              ),
            ],
          ),
          DemoSection(
            title: 'RTL island',
            children: [
              Direction(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Current direction: RTL'),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Left-aligned becomes right in RTL'),
                    ),
                    SizedBox(height: 8),
                    Input(hint: 'RTL input'),
                  ],
                ),
              ),
            ],
          ),
          DemoSection(
            title: 'Query the direction',
            children: [
              Builder(
                builder: (context) => Text(
                  'Direction.maybeOf → '
                  '${Direction.maybeOf(context)?.name ?? 'null'}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
