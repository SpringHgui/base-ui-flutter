import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [Input] widget.
class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _controller1 = TextEditingController(text: 'Hello World');
  final _controller2 = TextEditingController();
  final _focusController = TextEditingController();
  final _externalFocusNode = FocusNode();
  final _nextFocusNode = FocusNode();
  String _lastChanged = '';
  String _lastSubmitted = '';

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _focusController.dispose();
    _externalFocusNode.dispose();
    _nextFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic input with controller
          Label(l10n.t('input.basic')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: Input(controller: _controller1),
          ),
          const SizedBox(height: 16),

          // 2. Input with hint
          Label(l10n.t('input.hint')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: Input(
              controller: _controller2,
              hint: l10n.t('input.hintText'),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Disabled input
          Label(l10n.t('input.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: Input(enabled: false, hint: l10n.t('input.disabledHint')),
          ),
          const SizedBox(height: 16),

          // 4. onChanged callback
          Label(l10n.t('input.onChanged')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: Input(
              hint: l10n.t('input.onChangedHint'),
              onChanged: (v) => setState(() => _lastChanged = v),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('input.lastChanged').replaceAll('{value}', _lastChanged)),
          const SizedBox(height: 16),

          // 5. onSubmitted callback
          Label(l10n.t('input.onSubmitted')),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: Input(
              hint: l10n.t('input.onSubmittedHint'),
              textInputAction: TextInputAction.done,
              onSubmitted: (v) => setState(() => _lastSubmitted = v),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('input.lastSubmitted').replaceAll('{value}', _lastSubmitted)),
          const SizedBox(height: 16),

          // 6. Focus management with external FocusNode
          Label(l10n.t('input.focusMgmt')),
          const SizedBox(height: 6),
          Label(l10n.t('input.focusDesc')),
          const SizedBox(height: 4),
          SizedBox(
            width: 300,
            child: Input(
              controller: _focusController,
              focusNode: _externalFocusNode,
              hint: l10n.t('input.focusHint'),
            ),
          ),
          const SizedBox(height: 4),
          Button(
            text: l10n.t('input.focusBtn'),
            onPressed: () => _externalFocusNode.requestFocus(),
          ),
          const SizedBox(height: 16),

          // 7. TextInputAction examples
          Label(l10n.t('input.action')),
          const SizedBox(height: 6),
          Label(l10n.t('input.actionNext')),
          const SizedBox(height: 4),
          SizedBox(
            width: 300,
            child: Input(
              hint: l10n.t('input.pressTab'),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _nextFocusNode.requestFocus(),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 300,
            child: Input(
              hint: l10n.t('input.secondField'),
              focusNode: _nextFocusNode,
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
