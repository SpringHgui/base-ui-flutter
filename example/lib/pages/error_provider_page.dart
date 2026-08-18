import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [ErrorProvider] widget.
class ErrorProviderPage extends StatefulWidget {
  const ErrorProviderPage({super.key});

  @override
  State<ErrorProviderPage> createState() => _ErrorProviderPageState();
}

class _ErrorProviderPageState extends State<ErrorProviderPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Email validation
          Label(l10n.t('error.emailValidation')),
          const SizedBox(height: 6),
          const SizedBox(
            width: 300,
            child: _EmailInput(),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('error.emailHint')),
          const SizedBox(height: 16),

          // 2. Name length validation
          Label(l10n.t('error.nameValidation')),
          const SizedBox(height: 6),
          const SizedBox(
            width: 300,
            child: _NameInput(),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('error.nameHint')),
          const SizedBox(height: 16),

          // 3. Always-visible error
          Label(l10n.t('error.alwaysVisible')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: ErrorProvider(
              error: l10n.t('error.requiredField'),
              child: Input(hint: l10n.t('error.requiredHint')),
            ),
          ),
          const SizedBox(height: 16),

          // 4. No error (error is null)
          Label(l10n.t('error.noError')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: ErrorProvider(
              error: null,
              child: Input(hint: l10n.t('error.noErrorHint')),
            ),
          ),
          const SizedBox(height: 16),

          Label(l10n.t('error.features')),
          const SizedBox(height: 6),
          Label(l10n.t('error.feat1')),
          Label(l10n.t('error.feat2')),
          Label(l10n.t('error.feat3')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Email input with its own state, so focus is preserved across rebuilds.
class _EmailInput extends StatefulWidget {
  const _EmailInput();

  @override
  State<_EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<_EmailInput> {
  String _email = '';

  String? get _error {
    if (_email.isEmpty) return null;
    if (!_email.contains('@')) return AppLocalizations.of(context).t('error.invalidEmail');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ErrorProvider(
      error: _error,
      child: Input(
        hint: AppLocalizations.of(context).t('error.emailInputHint'),
        onChanged: (v) => setState(() => _email = v),
      ),
    );
  }
}

/// Name input with its own state, so focus is preserved across rebuilds.
class _NameInput extends StatefulWidget {
  const _NameInput();

  @override
  State<_NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<_NameInput> {
  String _name = '';

  String? get _error {
    if (_name.isEmpty) return null;
    if (_name.length < 3) return AppLocalizations.of(context).t('error.nameTooShort');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ErrorProvider(
      error: _error,
      child: Input(
        hint: AppLocalizations.of(context).t('error.nameInputHint'),
        onChanged: (v) => setState(() => _name = v),
      ),
    );
  }
}
