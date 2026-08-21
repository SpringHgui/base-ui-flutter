import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

/// Demonstrates the [ListItem] widget: high-density selectable list rows
/// with leading icon, title and trailing content.
class ListItemPage extends StatefulWidget {
  const ListItemPage({super.key});

  @override
  State<ListItemPage> createState() => _ListItemPageState();
}

class _ListItemPageState extends State<ListItemPage> {
  int _selected = 0;
  String _lastEvent = '—';

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Selectable rows',
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: t.borderColor, width: t.borderWidth),
                  borderRadius: BorderRadius.circular(t.cornerRadius),
                ),
                child: Column(
                  children: [
                    _row(
                      0,
                      Icons.folder,
                      'Documents',
                      onDoubleTap: () => setState(() => _lastEvent = 'Open Documents'),
                    ),
                    _row(
                      1,
                      Icons.image,
                      'Images',
                      onDoubleTap: () => setState(() => _lastEvent = 'Open Images'),
                    ),
                    _row(
                      2,
                      Icons.video_library,
                      'Videos',
                      onDoubleTap: () => setState(() => _lastEvent = 'Open Videos'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Last event: $_lastEvent'),
            ],
          ),
          DemoSection(
            title: 'With trailing content',
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFB0B0B0)),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Column(
                  children: [
                    ListItem(
                      title: 'Inbox',
                      leading: Icon(Icons.inbox, size: 16),
                      trailing: Text('12'),
                    ),
                    ListItem(
                      title: 'Sent',
                      leading: Icon(Icons.send, size: 16),
                      trailing: Text('4'),
                    ),
                    ListItem(
                      title: 'Archive',
                      leading: Icon(Icons.archive, size: 16),
                      trailing: Icon(Icons.chevron_right, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DemoSection(
            title: 'Disabled',
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFB0B0B0)),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Column(
                  children: [
                    ListItem(
                      title: 'Connected drives',
                      leading: Icon(Icons.drive_folder_upload, size: 16),
                      trailing: Icon(Icons.lock, size: 16),
                      enabled: false,
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

  Widget _row(int index, IconData icon, String title,
      {VoidCallback? onDoubleTap}) {
    return ListItem(
      title: title,
      leading: Icon(icon, size: 16),
      trailing: const Icon(Icons.chevron_right, size: 16),
      selected: _selected == index,
      onSelect: () => setState(() => _selected = index),
      onDoubleTap: onDoubleTap,
    );
  }
}
