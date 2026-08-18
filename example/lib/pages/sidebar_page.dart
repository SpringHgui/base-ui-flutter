import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SidebarPage extends StatefulWidget {
  const SidebarPage({super.key});

  @override
  State<SidebarPage> createState() => _SidebarPageState();
}

class _SidebarPageState extends State<SidebarPage> {
  int _selected = 0;
  final _items = const [
    (Icons.dashboard, 'Dashboard'),
    (Icons.receipt_long, 'Orders'),
    (Icons.people, 'Customers'),
    (Icons.inventory_2, 'Products'),
    (Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'App sidebar',
            children: [
              SizedBox(
                height: 320,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ColoredBox(
                        color: Color(0xFFFAFAFA),
                        child: Center(child: Text('Main content area')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DemoSection(
            title: 'Standalone Sidebar',
            children: [
              SizedBox(
                height: 300,
                child: Sidebar(
                  header: const Text('My App', style: TextStyle(fontWeight: FontWeight.w700)),
                  footer: const SidebarItem(label: 'Log out', icon: Icon(Icons.logout)),
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      SidebarItem(
                        label: _items[i].$2,
                        icon: Icon(_items[i].$1),
                        selected: i == _selected,
                        onTap: () => setState(() => _selected = i),
                      ),
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
