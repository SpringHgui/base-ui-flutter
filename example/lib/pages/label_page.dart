import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [Label] widget.
class LabelPage extends StatelessWidget {
  const LabelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DesktopTokens.winForm;
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic label
          Label(l10n.t('label.basic')),
          const SizedBox(height: 6),
          Label(l10n.t('label.basicDesc')),
          const SizedBox(height: 16),

          // 2. Text alignment
          Label(l10n.t('label.alignment')),
          const SizedBox(height: 6),
          Container(
            width: 300,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: t.borderColor),
            ),
            child: Column(
              children: [
                Label(l10n.t('label.leftAligned'), textAlign: TextAlign.left),
                const SizedBox(height: 4),
                Label(l10n.t('label.centerAligned'), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Label(l10n.t('label.rightAligned'), textAlign: TextAlign.right),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Overflow handling
          Label(l10n.t('label.overflow')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: Label(
              l10n.t('label.overflowDesc'),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('label.overflowNote')),
          const SizedBox(height: 16),

          // 4. Multi-line with maxLines
          Label(l10n.t('label.multiline')),
          const SizedBox(height: 6),
          const SizedBox(
            width: 250,
            child: Label(
              'Line 1: Lorem ipsum dolor sit amet.\n'
              'Line 2: Consectetur adipiscing elit.\n'
              'Line 3: Sed do eiusmod tempor.\n'
              'Line 4: Ut labore et dolore magna.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),

          // 5. Soft wrap
          Label(l10n.t('label.softwrap')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('label.softwrapTrue')),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 150,
                    child: Label(
                      l10n.t('label.wrapText'),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('label.softwrapFalse')),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 150,
                    child: Label(
                      l10n.t('label.noWrapText'),
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
