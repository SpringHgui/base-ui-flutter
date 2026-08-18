import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [RichTextBox] widget.
class RichTextBoxPage extends StatelessWidget {
  const RichTextBoxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic rich text box
          Label(l10n.t('richtext.multiline')),
          const SizedBox(height: 6),
          const SizedBox(
            width: 400,
            child: RichTextBox(
              minLines: 4,
              maxLines: 8,
            ),
          ),
          const SizedBox(height: 16),

          // 2. With initial content via controller
          Label(l10n.t('richtext.initialText')),
          const SizedBox(height: 6),
          SizedBox(
            width: 400,
            child: RichTextBox(
              minLines: 3,
              maxLines: 6,
              controller: TextEditingController(
                text: l10n.t('richtext.initialContent'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Disabled
          Label(l10n.t('richtext.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 400,
            child: RichTextBox(
              minLines: 2,
              maxLines: 4,
              enabled: false,
              controller: TextEditingController(text: l10n.t('richtext.disabledText')),
            ),
          ),
          const SizedBox(height: 16),

          Label(l10n.t('richtext.features')),
          const SizedBox(height: 6),
          Label(l10n.t('richtext.feat1')),
          Label(l10n.t('richtext.feat2')),
          Label(l10n.t('richtext.feat3')),
          Label(l10n.t('richtext.feat4')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
