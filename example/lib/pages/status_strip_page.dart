import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [StatusStrip] widget.
class StatusStripPage extends StatelessWidget {
  const StatusStripPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic status strip
          Label(l10n.t('statusstrip.basic')),
          const SizedBox(height: 6),
          StatusStrip(
            panels: [
              const StatusStripPanel(text: 'Ready', flex: 2),
              const StatusStripPanel(text: 'Line 42, Col 10', flex: 1),
              const StatusStripPanel(text: 'UTF-8', width: 80),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Multiple panels
          Label(l10n.t('statusstrip.multiPanel')),
          const SizedBox(height: 6),
          StatusStrip(
            panels: [
              const StatusStripPanel(text: 'Connected', flex: 1),
              const StatusStripPanel(text: 'main.dart', flex: 1),
              const StatusStripPanel(text: 'Ln 15', width: 60),
              const StatusStripPanel(text: 'Col 8', width: 60),
              const StatusStripPanel(text: 'Spaces: 4', width: 80),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Panel alignment
          Label(l10n.t('statusstrip.alignment')),
          const SizedBox(height: 6),
          StatusStrip(
            panels: [
              const StatusStripPanel(text: 'Left', flex: 1, alignment: Alignment.centerLeft),
              const StatusStripPanel(text: 'Center', flex: 1, alignment: Alignment.center),
              const StatusStripPanel(text: 'Right', flex: 1, alignment: Alignment.centerRight),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Without borders
          Label(l10n.t('statusstrip.noBorders')),
          const SizedBox(height: 6),
          StatusStrip(
            panels: [
              const StatusStripPanel(text: 'Panel 1', flex: 1, border: false),
              const StatusStripPanel(text: 'Panel 2', flex: 1, border: false),
              const StatusStripPanel(text: 'Panel 3', flex: 1, border: false),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Fixed widths
          Label(l10n.t('statusstrip.fixedWidth')),
          const SizedBox(height: 6),
          StatusStrip(
            panels: [
              const StatusStripPanel(text: 'Status', flex: 2),
              const StatusStripPanel(text: '100%', width: 60),
              const StatusStripPanel(text: 'v1.0.0', width: 80),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
