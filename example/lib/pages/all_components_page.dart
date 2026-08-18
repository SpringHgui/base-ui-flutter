import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

import '../l10n/app_localizations.dart';

/// A single component demo shown on the [AllComponentsPage] overview.
class ComponentShowcaseEntry {
  const ComponentShowcaseEntry({
    required this.categoryKey,
    required this.name,
    required this.builder,
  });

  final String categoryKey;
  final String name;
  final WidgetBuilder builder;
}

/// Renders every registered component demo on a single scrollable page,
/// grouped by category, so the whole gallery can be previewed at a glance.
class AllComponentsPage extends StatelessWidget {
  const AllComponentsPage({super.key, required this.entries});

  final List<ComponentShowcaseEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final l10n = AppLocalizations.of(context);

    final categories = <String>[];
    for (final entry in entries) {
      if (!categories.contains(entry.categoryKey)) {
        categories.add(entry.categoryKey);
      }
    }

    return ScrollableControl(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final catKey in categories) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Label(l10n.t(catKey)),
              ),
              for (final entry in entries.where((e) => e.categoryKey == catKey))
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: TextStyle(
                          fontFamily: tokens.fontFamily,
                          fontSize: tokens.fontSize,
                          fontWeight: FontWeight.bold,
                          color: tokens.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 360,
                        width: double.infinity,
                        padding: EdgeInsets.all(tokens.controlPaddingX),
                        decoration: BoxDecoration(
                          border: Border.all(color: tokens.borderColor, width: tokens.borderWidth),
                        ),
                        child: entry.builder(context),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
