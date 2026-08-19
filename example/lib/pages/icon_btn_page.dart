import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class IconBtnPage extends StatelessWidget {
  const IconBtnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(title: 'Basic icons', children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBtn(icon: Icons.add, onTap: () {}),
                IconBtn(icon: Icons.save, onTap: () {}),
                IconBtn(icon: Icons.delete, onTap: () {}),
                IconBtn(icon: Icons.edit, onTap: () {}),
                IconBtn(icon: Icons.refresh, onTap: () {}),
              ],
            ),
          ]),
          DemoSection(title: 'With tooltip', children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBtn(icon: Icons.home, onTap: () {}, tooltip: 'Home'),
                IconBtn(icon: Icons.settings, onTap: () {}, tooltip: 'Settings'),
                IconBtn(icon: Icons.help_outline, onTap: () {}, tooltip: 'Help'),
              ],
            ),
          ]),
          DemoSection(title: 'Disabled', children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBtn(icon: Icons.add, onTap: null),
                IconBtn(icon: Icons.save, onTap: null),
                IconBtn(icon: Icons.delete, onTap: null),
              ],
            ),
          ]),
          DemoSection(title: 'Custom size & color', children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBtn(icon: Icons.star, onTap: () {}, iconSize: 20, color: Colors.amber),
                IconBtn(icon: Icons.favorite, onTap: () {}, iconSize: 20, color: Colors.red),
                IconBtn(icon: Icons.check_circle, onTap: () {}, iconSize: 20, color: Colors.green),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
