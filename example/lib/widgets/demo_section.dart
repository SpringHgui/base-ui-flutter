import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// A titled demo block used by the component gallery pages.
class DemoSection extends StatelessWidget {
  const DemoSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize * 1.15,
            fontWeight: FontWeight.w600,
            color: t.primaryColor,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
}
