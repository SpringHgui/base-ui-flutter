import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [MenuStrip] widget.
class MenuStripPage extends StatefulWidget {
  const MenuStripPage({super.key});

  @override
  State<MenuStripPage> createState() => _MenuStripPageState();
}

class _MenuStripPageState extends State<MenuStripPage> {
  String _lastAction = '';

  List<MenuItem> _buildMenuItems(AppLocalizations l10n) => [
    MenuItem(text: l10n.t('menustrip.file'), children: [
      MenuItem(text: l10n.t('menustrip.new'), shortcut: 'Ctrl+N'),
      MenuItem(text: l10n.t('menustrip.open'), shortcut: 'Ctrl+O'),
      MenuItem(text: l10n.t('menustrip.save'), shortcut: 'Ctrl+S'),
      MenuSeparator(),
      MenuItem(text: l10n.t('menustrip.recent'), children: [
        MenuItem(text: 'file1.dart'),
        MenuItem(text: 'file2.dart'),
        MenuItem(text: 'file3.dart'),
      ]),
      MenuSeparator(),
      MenuItem(text: l10n.t('menustrip.exit')),
    ]),
    MenuItem(text: l10n.t('menustrip.edit'), children: [
      MenuItem(text: l10n.t('menustrip.undo'), shortcut: 'Ctrl+Z'),
      MenuItem(text: l10n.t('menustrip.redo'), shortcut: 'Ctrl+Y'),
      MenuSeparator(),
      MenuItem(text: l10n.t('menustrip.cut'), shortcut: 'Ctrl+X'),
      MenuItem(text: l10n.t('menustrip.copy'), shortcut: 'Ctrl+C'),
      MenuItem(text: l10n.t('menustrip.paste'), shortcut: 'Ctrl+V'),
      MenuSeparator(),
      MenuItem(text: l10n.t('menustrip.selectAll'), shortcut: 'Ctrl+A'),
    ]),
    MenuItem(text: l10n.t('menustrip.view'), children: [
      MenuItem(text: l10n.t('menustrip.zoomIn')),
      MenuItem(text: l10n.t('menustrip.zoomOut')),
      MenuSeparator(),
      MenuItem(text: l10n.t('menustrip.fullScreen')),
    ]),
    MenuItem(text: l10n.t('menustrip.help'), children: [
      MenuItem(text: l10n.t('menustrip.documentation')),
      MenuItem(text: l10n.t('menustrip.about')),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(l10n.t('menustrip.demo')),
          const SizedBox(height: 6),
          Label(l10n.t('menustrip.instruction')),
          const SizedBox(height: 8),
          MenuStrip(
            items: _buildMenuItems(l10n).map((item) {
              return MenuItem(
                text: item.text,
                children: item.children.map((child) {
                  if (child is MenuSeparator) return child;
                  final mi = child as MenuItem;
                  return MenuItem(
                    text: mi.text,
                    shortcut: mi.shortcut,
                    children: mi.children,
                    onPressed: () => setState(() => _lastAction = mi.text),
                  );
                }).toList(),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Label(_lastAction.isEmpty ? l10n.t('menustrip.lastAction') : l10n.t('menustrip.lastActionValue').replaceAll('{value}', _lastAction)),
          const SizedBox(height: 16),

          Label(l10n.t('menustrip.features')),
          const SizedBox(height: 6),
          Label(l10n.t('menustrip.feat1')),
          Label(l10n.t('menustrip.feat2')),
          Label(l10n.t('menustrip.feat3')),
          Label(l10n.t('menustrip.feat4')),
          Label(l10n.t('menustrip.feat5')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
