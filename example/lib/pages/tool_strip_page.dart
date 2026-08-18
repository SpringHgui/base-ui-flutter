import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [ToolStrip] widget.
class ToolStripPage extends StatefulWidget {
  const ToolStripPage({super.key});

  @override
  State<ToolStripPage> createState() => _ToolStripPageState();
}

class _ToolStripPageState extends State<ToolStripPage> {
  String _lastAction = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(l10n.t('toolstrip.demo')),
          const SizedBox(height: 6),
          ToolStrip(
            items: [
              ToolStripButton(
                text: l10n.t('toolstrip.new'),
                icon: Icons.note_add,
                tooltip: l10n.t('toolstrip.newFile'),
                onPressed: () => setState(() => _lastAction = l10n.t('toolstrip.new')),
              ),
              ToolStripButton(
                text: l10n.t('toolstrip.open'),
                icon: Icons.folder_open,
                tooltip: l10n.t('toolstrip.openFile'),
                onPressed: () => setState(() => _lastAction = l10n.t('toolstrip.open')),
              ),
              ToolStripButton(
                text: l10n.t('toolstrip.save'),
                icon: Icons.save,
                tooltip: l10n.t('toolstrip.saveTip'),
                onPressed: () => setState(() => _lastAction = l10n.t('toolstrip.save')),
              ),
              const ToolStripSeparator(),
              ToolStripButton(
                text: l10n.t('toolstrip.cut'),
                icon: Icons.cut,
                onPressed: () => setState(() => _lastAction = l10n.t('toolstrip.cut')),
              ),
              ToolStripButton(
                text: l10n.t('toolstrip.copy'),
                icon: Icons.copy,
                onPressed: () => setState(() => _lastAction = l10n.t('toolstrip.copy')),
              ),
              ToolStripButton(
                text: l10n.t('toolstrip.paste'),
                icon: Icons.paste,
                onPressed: () => setState(() => _lastAction = l10n.t('toolstrip.paste')),
              ),
              const ToolStripSeparator(),
              ToolStripLabel(text: l10n.t('toolstrip.status')),
              ToolStripLabel(text: l10n.t('toolstrip.ready'), enabled: true),
              const ToolStripSeparator(),
              ToolStripDropDownButton(
                text: l10n.t('toolstrip.theme'),
                icon: Icons.palette,
                tooltip: l10n.t('toolstrip.selectTheme'),
                items: [
                  ToolStripDropDownEntry(
                    text: l10n.t('toolstrip.light'),
                    onPressed: () => setState(() => _lastAction = '${l10n.t('toolstrip.theme')}: ${l10n.t('toolstrip.light')}'),
                  ),
                  ToolStripDropDownEntry(
                    text: l10n.t('toolstrip.dark'),
                    onPressed: () => setState(() => _lastAction = '${l10n.t('toolstrip.theme')}: ${l10n.t('toolstrip.dark')}'),
                  ),
                ],
              ),
              const ToolStripSeparator(),
              ToolStripButton(
                text: l10n.t('toolstrip.disabled'),
                icon: Icons.block,
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Label(_lastAction.isEmpty ? l10n.t('toolstrip.lastAction') : l10n.t('toolstrip.lastActionValue').replaceAll('{value}', _lastAction)),
          const SizedBox(height: 16),

          Label(l10n.t('toolstrip.features')),
          const SizedBox(height: 6),
          Label(l10n.t('toolstrip.feat1')),
          Label(l10n.t('toolstrip.feat2')),
          Label(l10n.t('toolstrip.feat3')),
          Label(l10n.t('toolstrip.feat4')),
          Label(l10n.t('toolstrip.feat5')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
