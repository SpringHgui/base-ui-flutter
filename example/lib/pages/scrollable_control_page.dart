import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [ScrollableControl] widget.
class ScrollableControlPage extends StatelessWidget {
  const ScrollableControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = DesktopTokens.winForm;
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic vertical scroll
          Label(l10n.t('scrollable.vertical')),
          const SizedBox(height: 6),
          Container(
            width: 300,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: t.borderColor),
              borderRadius: BorderRadius.circular(t.cornerRadius),
            ),
            child: ScrollableControl(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Label(
                  l10n.t('scrollable.content'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. With padding
          Label(l10n.t('scrollable.withPadding')),
          const SizedBox(height: 6),
          Container(
            width: 300,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: t.borderColor),
              borderRadius: BorderRadius.circular(t.cornerRadius),
            ),
            child: ScrollableControl(
              padding: const EdgeInsets.all(16),
              child: Label(
                l10n.t('scrollable.paddedContent'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Horizontal scroll
          Label(l10n.t('scrollable.horizontal')),
          const SizedBox(height: 6),
          Container(
            width: 300,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: t.borderColor),
              borderRadius: BorderRadius.circular(t.cornerRadius),
            ),
            child: ScrollableControl(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  20,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Label(l10n.t('scrollable.item').replaceAll('{n}', '$i')),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Label(l10n.t('scrollable.features')),
          const SizedBox(height: 6),
          Label(l10n.t('scrollable.feat1')),
          Label(l10n.t('scrollable.feat2')),
          Label(l10n.t('scrollable.feat3')),
          Label(l10n.t('scrollable.feat4')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
