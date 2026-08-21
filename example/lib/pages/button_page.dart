import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [Button] widget.
class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  int _clickCount = 0;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 监听焦点变化，让状态指示灯实时更新
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Normal button
          Label(l10n.t('button.normal')),
          const SizedBox(height: 6),
          Button(text: l10n.t('button.clickMe'), onPressed: () {}),
          const SizedBox(height: 16),

          // 2. Disabled button
          Label(l10n.t('button.disabled')),
          const SizedBox(height: 6),
          Button(text: l10n.t('button.disabledText')),
          const SizedBox(height: 16),

          // 3. Click counter
          Label(l10n.t('button.counter')),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(
                text: l10n.t('button.increment'),
                onPressed: () => setState(() => _clickCount++),
              ),
              const SizedBox(width: 8),
              Button(
                text: l10n.t('button.reset'),
                onPressed: () => setState(() => _clickCount = 0),
              ),
              const SizedBox(width: 16),
              Label(l10n.t('button.clicks').replaceAll('{count}', '$_clickCount')),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Button with tooltip
          Label(l10n.t('button.tooltip')),
          const SizedBox(height: 6),
          WinToolTip(
            message: l10n.t('button.tooltipMsg'),
            child: Button(text: l10n.t('button.hoverMe'), onPressed: () {}),
          ),
          const SizedBox(height: 16),

          // 5. Button focus — live status indicator
          Label(l10n.t('button.focusNode')),
          const SizedBox(height: 6),
          Label(l10n.t('button.focusDesc')),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(
                text: l10n.t('button.focusThis'),
                focusNode: _focusNode,
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              // 实时焦点状态指示灯：高亮色 = 已获得焦点，灰色 = 未获得
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _focusNode.hasFocus
                          ? tokens.primaryColor
                          : tokens.borderColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Label(
                    l10n.t('button.focusStatus').replaceAll(
                      '{status}',
                      _focusNode.hasFocus
                          ? l10n.t('button.focusStatusFocused')
                          : l10n.t('button.focusStatusUnfocused'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Button(
            text: l10n.t('button.focusProgrammatic'),
            onPressed: () => _focusNode.requestFocus(),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('button.focusTabHint')),
          const SizedBox(height: 16),

          // 6. Autofocus button
          Label(l10n.t('button.autofocus')),
          const SizedBox(height: 6),
          Label(l10n.t('button.autofocusDesc')),
          const SizedBox(height: 4),
          Button(text: l10n.t('button.autofocused'), autofocus: true, onPressed: () {}),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
