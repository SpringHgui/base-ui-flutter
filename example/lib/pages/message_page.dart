import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(
            title: 'Incoming / outgoing',
            children: [
              Message(
                sender: 'Alice',
                time: '09:41',
                text: 'Did you get my email about the Q3 plan?',
              ),
              Message(
                sender: 'You',
                time: '09:43',
                text: 'Yes! Looks solid. I left a few comments.',
                isMine: true,
              ),
              Message(
                sender: 'Bob',
                time: '09:45',
                text: 'I can review the numbers this afternoon.',
              ),
            ],
          ),
          DemoSection(
            title: 'With actions',
            children: [
              Message(
                sender: 'Bot',
                time: 'now',
                avatar: Avatar(fallback: 'B'),
                text: 'Here is the summary of your account.',
                actions: [
                  Button(text: 'View details', onPressed: null),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
