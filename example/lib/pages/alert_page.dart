import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class AlertPage extends StatelessWidget {
  const AlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(
            title: 'Info',
            children: [
              Alert(
                icon: Icon(Icons.info_outline),
                title: 'Heads up!',
                description:
                    'You can add components to your app using the CLI.',
              ),
            ],
          ),
          DemoSection(
            title: 'Destructive',
            children: [
              Alert(
                variant: AlertVariant.destructive,
                icon: Icon(Icons.error_outline),
                title: 'Error',
                description:
                    'Your session has expired. Please sign in again.',
              ),
            ],
          ),
          DemoSection(
            title: 'Title only',
            children: [
              Alert(
                icon: Icon(Icons.verified_outlined),
                title: 'All systems operational',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
