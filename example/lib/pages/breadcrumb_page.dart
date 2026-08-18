import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class BreadcrumbPage extends StatefulWidget {
  const BreadcrumbPage({super.key});

  @override
  State<BreadcrumbPage> createState() => _BreadcrumbPageState();
}

class _BreadcrumbPageState extends State<BreadcrumbPage> {
  final List<String> _trail = ['Home', 'Documents', 'Projects'];

  void _navigateTo(int index) {
    setState(() => _trail.removeRange(index + 1, _trail.length));
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Interactive trail',
            children: [
              Breadcrumb(
                items: [
                  for (var i = 0; i < _trail.length; i++)
                    BreadcrumbItem(
                      _trail[i],
                      onTap: i < _trail.length - 1 ? () => _navigateTo(i) : null,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Current: ${_trail.last} — click a parent to navigate back'),
            ],
          ),
          const DemoSection(
            title: 'With icons',
            children: [
              Breadcrumb(
                items: [
                  BreadcrumbItem('Home', icon: Icon(Icons.home, size: 16), onTap: null),
                  BreadcrumbItem('Components'),
                  BreadcrumbItem('Breadcrumb'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
