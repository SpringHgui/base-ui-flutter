import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates the [ThemeDesigner] widget.
class ThemeDesignerPage extends StatefulWidget {
  const ThemeDesignerPage({super.key});

  @override
  State<ThemeDesignerPage> createState() => _ThemeDesignerPageState();
}

class _ThemeDesignerPageState extends State<ThemeDesignerPage> {
  DesktopTokens _tokens = DesktopTokens.winForm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(l10n.t('themedesigner.inline')),
          const SizedBox(height: 6),
          Label(l10n.t('themedesigner.desc')),
          const SizedBox(height: 12),
          SizedBox(
            width: 640,
            height: 480,
            child: ThemeDesigner(
              tokens: _tokens,
              onTokensChanged: (next) => setState(() => _tokens = next),
              onConfirm: (next) => setState(() => _tokens = next),
            ),
          ),
          const SizedBox(height: 16),
          Label(l10n.t('themedesigner.features')),
          const SizedBox(height: 6),
          Label(l10n.t('themedesigner.feat1')),
          Label(l10n.t('themedesigner.feat2')),
          Label(l10n.t('themedesigner.feat3')),
          Label(l10n.t('themedesigner.feat4')),
          Label(l10n.t('themedesigner.feat5')),
          Label(l10n.t('themedesigner.feat6')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
