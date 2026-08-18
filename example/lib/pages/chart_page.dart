import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  static const _data = [
    ChartDatum('Jan', 42),
    ChartDatum('Feb', 78),
    ChartDatum('Mar', 55),
    ChartDatum('Apr', 91),
    ChartDatum('May', 63),
    ChartDatum('Jun', 110),
  ];

  static const _donut = [
    ChartDatum('Desktop', 44),
    ChartDatum('Mobile', 30),
    ChartDatum('Tablet', 18),
    ChartDatum('Other', 8),
  ];

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(
            title: 'Bar chart',
            children: [
              Chart(type: ChartType.bar, data: _data, showValues: true),
            ],
          ),
          DemoSection(
            title: 'Line chart',
            children: [
              Chart(type: ChartType.line, data: _data, showValues: true),
            ],
          ),
          DemoSection(
            title: 'Donut chart',
            children: [
              Chart(type: ChartType.donut, data: _donut, height: 180),
            ],
          ),
        ],
      ),
    );
  }
}
