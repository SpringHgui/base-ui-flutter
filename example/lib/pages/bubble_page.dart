import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class BubblePage extends StatelessWidget {
  const BubblePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'Chat bubbles',
            children: [
              Bubble(text: 'Hey! Did you review the mockups I sent?'),
              SizedBox(height: 8),
              Bubble(
                text: 'Yes — the dashboard looks great. Ship it 🚀',
                isMine: true,
              ),
              SizedBox(height: 8),
              Bubble(text: 'Perfect, I will push the changes today.'),
              SizedBox(height: 8),
              Bubble(
                text: 'Awesome. Ping me when the build is ready.',
                isMine: true,
              ),
            ],
          ),
          const DemoSection(
            title: 'Custom content',
            children: [
              Bubble(
                isMine: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thumb_up, size: 16),
                    SizedBox(width: 6),
                    Text('+1'),
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
