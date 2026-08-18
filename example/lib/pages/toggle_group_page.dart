import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class ToggleGroupPage extends StatefulWidget {
  const ToggleGroupPage({super.key});

  @override
  State<ToggleGroupPage> createState() => _ToggleGroupPageState();
}

class _ToggleGroupPageState extends State<ToggleGroupPage> {
  List<String> _single = const ['center'];
  List<String> _multi = const ['bold'];

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Single selection',
            children: [
              ToggleGroup<String>(
                values: _single,
                onChanged: (v) => setState(() => _single = v),
                children: const [
                  ToggleGroupItem(value: 'left', child: Icon(Icons.format_align_left, size: 16)),
                  ToggleGroupItem(value: 'center', child: Icon(Icons.format_align_center, size: 16)),
                  ToggleGroupItem(value: 'right', child: Icon(Icons.format_align_right, size: 16)),
                  ToggleGroupItem(value: 'justify', child: Icon(Icons.format_align_justify, size: 16)),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'Multiple selection',
            children: [
              ToggleGroup<String>(
                values: _multi,
                onChanged: (v) => setState(() => _multi = v),
                multiple: true,
                children: const [
                  ToggleGroupItem(value: 'bold', child: Icon(Icons.format_bold, size: 16)),
                  ToggleGroupItem(value: 'italic', child: Icon(Icons.format_italic, size: 16)),
                  ToggleGroupItem(value: 'underline', child: Icon(Icons.format_underline, size: 16)),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'Text items',
            children: [
              ToggleGroup<String>(
                values: _single,
                onChanged: (v) => setState(() => _single = v),
                children: const [
                  ToggleGroupItem(value: 'day', child: Text('Day')),
                  ToggleGroupItem(value: 'week', child: Text('Week')),
                  ToggleGroupItem(value: 'month', child: Text('Month')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
