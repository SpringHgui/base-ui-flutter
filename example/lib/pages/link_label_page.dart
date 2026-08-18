import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [LinkLabel] widget.
class LinkLabelPage extends StatefulWidget {
  const LinkLabelPage({super.key});

  @override
  State<LinkLabelPage> createState() => _LinkLabelPageState();
}

class _LinkLabelPageState extends State<LinkLabelPage> {
  int _tapCount = 0;
  String _lastLink = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic link
          Label(l10n.t('link.basic')),
          const SizedBox(height: 6),
          LinkLabel(
            text: l10n.t('link.clickThis'),
            onLinkTap: () => setState(() => _tapCount++),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('link.tapCount').replaceAll('{count}', '$_tapCount')),
          const SizedBox(height: 16),

          // 2. Disabled link
          Label(l10n.t('link.disabled')),
          const SizedBox(height: 6),
          LinkLabel(text: l10n.t('link.disabledText'), enabled: false),
          const SizedBox(height: 16),

          // 3. Multiple links
          Label(l10n.t('link.multiple')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinkLabel(
                text: l10n.t('link.home'),
                onLinkTap: () => setState(() => _lastLink = l10n.t('link.home')),
              ),
              const SizedBox(width: 8),
              const Label(' | '),
              LinkLabel(
                text: l10n.t('link.about'),
                onLinkTap: () => setState(() => _lastLink = l10n.t('link.about')),
              ),
              const SizedBox(width: 8),
              const Label(' | '),
              LinkLabel(
                text: l10n.t('link.contact'),
                onLinkTap: () => setState(() => _lastLink = l10n.t('link.contact')),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Label(_lastLink.isEmpty ? l10n.t('link.lastClicked') : l10n.t('link.lastClickedValue').replaceAll('{value}', _lastLink)),
          const SizedBox(height: 16),

          // 4. Text alignment
          Label(l10n.t('link.alignment')),
          const SizedBox(height: 6),
          Container(
            width: 300,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: DesktopTokens.winForm.borderColor),
            ),
            child: Column(
              children: [
                LinkLabel(
                  text: l10n.t('link.leftAligned'),
                  textAlign: TextAlign.left,
                  onLinkTap: () {},
                ),
                const SizedBox(height: 4),
                LinkLabel(
                  text: l10n.t('link.centerAligned'),
                  textAlign: TextAlign.center,
                  onLinkTap: () {},
                ),
                const SizedBox(height: 4),
                LinkLabel(
                  text: l10n.t('link.rightAligned'),
                  textAlign: TextAlign.right,
                  onLinkTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Overflow handling
          Label(l10n.t('link.overflow')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: LinkLabel(
              text: l10n.t('link.overflowText'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              enabled: false,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
