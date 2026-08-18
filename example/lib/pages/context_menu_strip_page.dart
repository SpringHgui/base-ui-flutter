import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [ContextMenuStrip] widget.
class ContextMenuStripPage extends StatefulWidget {
  const ContextMenuStripPage({super.key});

  @override
  State<ContextMenuStripPage> createState() => _ContextMenuStripPageState();
}

class _ContextMenuStripPageState extends State<ContextMenuStripPage> {
  String _lastAction = '';

  List<MenuModel> _buildItems(AppLocalizations l10n) => [
    MenuItem(text: l10n.t('contextmenu.cut'), shortcut: 'Ctrl+X'),
    MenuItem(text: l10n.t('contextmenu.copy'), shortcut: 'Ctrl+C'),
    MenuItem(text: l10n.t('contextmenu.paste'), shortcut: 'Ctrl+V'),
    MenuSeparator(),
    MenuItem(text: l10n.t('contextmenu.selectAll'), shortcut: 'Ctrl+A'),
    MenuSeparator(),
    MenuItem(text: l10n.t('contextmenu.format'), children: [
      MenuItem(text: l10n.t('contextmenu.bold')),
      MenuItem(text: l10n.t('contextmenu.italic')),
      MenuItem(text: l10n.t('contextmenu.underline')),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = DesktopTokens.winForm;
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(l10n.t('contextmenu.demo')),
          const SizedBox(height: 6),
          Label(l10n.t('contextmenu.instruction')),
          const SizedBox(height: 8),
          ContextMenuStrip(
            items: _buildItems(l10n).map((item) {
              if (item is MenuSeparator) return item;
              final mi = item as MenuItem;
              return MenuItem(
                text: mi.text,
                shortcut: mi.shortcut,
                children: mi.children,
                onPressed: () => setState(() => _lastAction = mi.text),
              );
            }).toList(),
            child: Container(
              width: 400,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: t.borderColor),
                borderRadius: BorderRadius.circular(t.cornerRadius),
                color: t.surfaceColor,
              ),
              alignment: Alignment.center,
              child: Label(l10n.t('contextmenu.rightClickHere')),
            ),
          ),
          const SizedBox(height: 16),
          Label(_lastAction.isEmpty ? l10n.t('contextmenu.lastAction') : l10n.t('contextmenu.lastActionValue').replaceAll('{value}', _lastAction)),
          const SizedBox(height: 16),

          Label(l10n.t('contextmenu.features')),
          const SizedBox(height: 6),
          Label(l10n.t('contextmenu.feat1')),
          Label(l10n.t('contextmenu.feat2')),
          Label(l10n.t('contextmenu.feat3')),
          Label(l10n.t('contextmenu.feat4')),
          Label(l10n.t('contextmenu.feat5')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
