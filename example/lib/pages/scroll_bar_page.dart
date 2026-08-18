import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [ScrollBar] widget.
class ScrollBarPage extends StatelessWidget {
  const ScrollBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ScrollBar wrapping content
          Label(l10n.t('scrollbar.wrapping')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            height: 120,
            child: ScrollBar(
              controller: ScrollController(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Label(
                    l10n.t('scrollbar.scrollContent'),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. StandaloneScrollBar (vertical)
          Label(l10n.t('scrollbar.standaloneV')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 200,
                child: StandaloneScrollBar(
                  orientation: ScrollBarOrientation.vertical,
                  value: 0,
                  min: 0,
                  max: 100,
                  extent: 20,
                ),
              ),
              const SizedBox(width: 16),
              Label(l10n.t('scrollbar.standaloneDesc')),
            ],
          ),
          const SizedBox(height: 16),

          // 3. StandaloneScrollBar (horizontal)
          Label(l10n.t('scrollbar.standaloneH')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            height: 20,
            child: StandaloneScrollBar(
              orientation: ScrollBarOrientation.horizontal,
              value: 0,
              min: 0,
              max: 100,
              extent: 30,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
