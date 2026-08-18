import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class PopoverPage extends StatelessWidget {
  const PopoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'Basic popover',
            children: [
              Popover(
                trigger: Button(text: 'Open popover', onPressed: null),
                content: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 220,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dimensions', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text('Set the dimensions of the element. Width and height can be set as fixed or relative to the parent.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const DemoSection(
            title: 'Alignments',
            children: [
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  Popover(
                    trigger: Button(text: 'Start', onPressed: null),
                    align: OverlayAlign.start,
                    content: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Aligned to start'),
                    ),
                  ),
                  Popover(
                    trigger: Button(text: 'Center', onPressed: null),
                    align: OverlayAlign.center,
                    content: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Aligned to center'),
                    ),
                  ),
                  Popover(
                    trigger: Button(text: 'End', onPressed: null),
                    align: OverlayAlign.end,
                    content: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Aligned to end'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const DemoSection(
            title: 'Sides',
            children: [
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  Popover(
                    trigger: Button(text: 'Top', onPressed: null),
                    side: OverlaySide.top,
                    content: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Opens upward'),
                    ),
                  ),
                  Popover(
                    trigger: Button(text: 'Right', onPressed: null),
                    side: OverlaySide.right,
                    content: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Opens right'),
                    ),
                  ),
                  Popover(
                    trigger: Button(text: 'Left', onPressed: null),
                    side: OverlaySide.left,
                    content: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Opens left'),
                    ),
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
