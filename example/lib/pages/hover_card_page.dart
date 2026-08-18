import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class HoverCardPage extends StatelessWidget {
  const HoverCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(
            title: 'Hover to preview',
            children: [
              HoverCard(
                trigger: Text(
                  '@johndoe',
                  style: TextStyle(
                    color: Color(0xFF0F6CBD),
                    decoration: TextDecoration.underline,
                  ),
                ),
                width: 260,
                content: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Avatar(fallback: 'J', size: 36),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('John Doe', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('@johndoe', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text('Product designer at Acme. Building delightful desktop tools.'),
                    ],
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
