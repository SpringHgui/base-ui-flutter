import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

/// Demonstrates the [SelectableCard] widget: selectable content cards with
/// a check badge, disabled badge and double-tap support.
class SelectableCardPage extends StatefulWidget {
  const SelectableCardPage({super.key});

  @override
  State<SelectableCardPage> createState() => _SelectableCardPageState();
}

class _SelectableCardPageState extends State<SelectableCardPage> {
  int _selected = 0;
  String _lastEvent = '—';

  void _pick(int index, String name) {
    setState(() {
      _selected = index;
      _lastEvent = 'Selected $name';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Single-select picker',
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _card(0, 'MySQL', Icons.storage),
                  _card(1, 'PostgreSQL', Icons.account_tree),
                  _card(2, 'SQLite', Icons.dns),
                ],
              ),
              const SizedBox(height: 8),
              Text('Last event: $_lastEvent'),
            ],
          ),
          DemoSection(
            title: 'Double-click to open',
            children: [
              SelectableCard(
                width: 240,
                height: 104,
                onSelect: () => setState(() => _lastEvent = 'Clicked'),
                onDoubleTap: () =>
                    setState(() => _lastEvent = 'Double-clicked (open)'),
                child: const _CardContent(
                  icon: Icons.folder_open,
                  title: 'Open project',
                  subtitle: 'Double-click to open',
                ),
              ),
            ],
          ),
          const DemoSection(
            title: 'Disabled with badge',
            children: [
              SelectableCard(
                width: 240,
                height: 104,
                disabled: true,
                disabledLabel: 'Not implemented',
                child: _CardContent(
                  icon: Icons.cloud_off,
                  title: 'Cloud sync',
                  subtitle: 'Coming soon',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(int index, String title, IconData icon) {
    return SelectableCard(
      width: 170,
      height: 88,
      selected: _selected == index,
      onSelect: () => _pick(index, title),
      child: _CardContent(icon: icon, title: title),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: t.primaryColor),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 11, color: t.mutedForegroundColor),
            ),
          ],
        ],
      ),
    );
  }
}
