import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [WinToolTip] widget.
class ToolTipPage extends StatelessWidget {
  const ToolTipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = DesktopTokens.winForm;
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic tooltip
          Label(l10n.t('tooltip.onLabel')),
          const SizedBox(height: 6),
          WinToolTip(
            message: l10n.t('tooltip.labelMsg'),
            child: Label(l10n.t('tooltip.labelHover')),
          ),
          const SizedBox(height: 16),

          // 2. Tooltip on a button
          Label(l10n.t('tooltip.onButton')),
          const SizedBox(height: 6),
          WinToolTip(
            message: l10n.t('tooltip.buttonMsg'),
            child: Button(text: l10n.t('tooltip.hoverMe'), onPressed: () {}),
          ),
          const SizedBox(height: 16),

          // 3. Tooltip on a container
          Label(l10n.t('tooltip.onContainer')),
          const SizedBox(height: 6),
          WinToolTip(
            message: l10n.t('tooltip.containerMsg'),
            child: Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                color: t.primaryColor.withValues(alpha: 0.2),
                border: Border.all(color: t.primaryColor),
                borderRadius: BorderRadius.circular(t.cornerRadius),
              ),
              alignment: Alignment.center,
              child: Label(l10n.t('tooltip.boxHover')),
            ),
          ),
          const SizedBox(height: 16),

          Label(l10n.t('tooltip.features')),
          const SizedBox(height: 6),
          Label(l10n.t('tooltip.feat1')),
          Label(l10n.t('tooltip.feat2')),
          Label(l10n.t('tooltip.feat3')),
          Label(l10n.t('tooltip.feat4')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
