import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [MaskedTextBox] widget.
class MaskedTextBoxPage extends StatefulWidget {
  const MaskedTextBoxPage({super.key});

  @override
  State<MaskedTextBoxPage> createState() => _MaskedTextBoxPageState();
}

class _MaskedTextBoxPageState extends State<MaskedTextBoxPage> {
  String _phoneValue = '';
  String _dateValue = '';
  String _plateValue = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Phone number mask
          Label(l10n.t('mask.phone')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: MaskedTextBox(
              mask: '(000) 000-0000',
              hint: '(___) ___-____',
              onChanged: (v) => setState(() => _phoneValue = v),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('mask.value').replaceAll('{value}', _phoneValue)),
          const SizedBox(height: 16),

          // 2. Date mask
          Label(l10n.t('mask.date')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: MaskedTextBox(
              mask: '0000-00-00',
              hint: 'YYYY-MM-DD',
              onChanged: (v) => setState(() => _dateValue = v),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('mask.value').replaceAll('{value}', _dateValue)),
          const SizedBox(height: 16),

          // 3. License plate mask (letters + digits)
          Label(l10n.t('mask.plate')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: MaskedTextBox(
              mask: 'AAA-0000',
              hint: 'ABC-1234',
              onChanged: (v) => setState(() => _plateValue = v),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('mask.value').replaceAll('{value}', _plateValue)),
          const SizedBox(height: 16),

          // 4. Optional digit mask
          Label(l10n.t('mask.optional')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: MaskedTextBox(
              mask: '00-99',
              hint: l10n.t('mask.optionalHint'),
            ),
          ),
          const SizedBox(height: 16),

          // 5. Disabled
          Label(l10n.t('mask.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: MaskedTextBox(
              mask: '(000) 000-0000',
              enabled: false,
              hint: l10n.t('mask.disabledHint'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
