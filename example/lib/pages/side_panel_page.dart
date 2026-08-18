import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SidePanelPage extends StatefulWidget {
  const SidePanelPage({super.key});

  @override
  State<SidePanelPage> createState() => _SidePanelPageState();
}

class _SidePanelPageState extends State<SidePanelPage> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Left panel (drawer)',
            children: [
              Button(text: 'Open side panel', onPressed: () => setState(() => _open = true)),
              SidePanel(
                open: _open,
                onClose: () => setState(() => _open = false),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Navigation',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: const [
                          SidebarItem(label: 'Dashboard', icon: Icon(Icons.dashboard), selected: true),
                          SidebarItem(label: 'Orders', icon: Icon(Icons.receipt_long)),
                          SidebarItem(label: 'Customers', icon: Icon(Icons.people)),
                          SidebarItem(label: 'Settings', icon: Icon(Icons.settings)),
                        ],
                      ),
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
