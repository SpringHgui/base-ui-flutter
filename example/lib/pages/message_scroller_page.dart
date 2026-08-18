import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class MessageScrollerPage extends StatelessWidget {
  const MessageScrollerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(
            title: 'Chat thread (auto-scrolls to newest)',
            children: [
              MessageScroller(
                height: 360,
                children: [
                  Message(
                    sender: 'Alice',
                    time: '09:00',
                    text: 'Morning! Ready for the sync?',
                  ),
                  Message(
                    sender: 'You',
                    time: '09:02',
                    text: 'Morning! Yes, give me 5 minutes.',
                    isMine: true,
                  ),
                  Message(
                    sender: 'Alice',
                    time: '09:05',
                    text: 'Great — I pushed the updated design tokens.',
                  ),
                  Message(
                    sender: 'Bob',
                    time: '09:07',
                    text: 'Nice, I will rebase my branch on top.',
                  ),
                  Message(
                    sender: 'You',
                    time: '09:10',
                    text: 'Perfect. Charts look way better with the new palette.',
                    isMine: true,
                  ),
                  Message(
                    sender: 'Alice',
                    time: '09:12',
                    text: 'Agreed. Let us review at 10:00.',
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
