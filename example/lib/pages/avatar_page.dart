import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(
            title: 'Initials',
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Avatar(fallback: 'JD'),
                  Avatar(fallback: 'AL', size: 48),
                  Avatar(fallback: 'MK', size: 56),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'Sizes',
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Avatar(fallback: 'S', size: 24),
                  Avatar(fallback: 'M', size: 32),
                  Avatar(fallback: 'L', size: 40),
                  Avatar(fallback: 'XL', size: 56),
                  Avatar(fallback: 'XXL', size: 72),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'Empty',
            children: [
              Avatar(fallback: ''),
            ],
          ),
        ],
      ),
    );
  }
}
