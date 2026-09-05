import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A wizard-style horizontal step indicator.
///
/// Shows the step sequence with the current step highlighted, so a
/// multi-page dialog (import / export wizard) can tell the user where they
/// are. Purely visual: navigation stays with the host dialog's buttons.
///
/// Rendered with zero animation and no Material ink, matching the desktop
/// fast-response rules used across this library.
class StepBar extends StatelessWidget {
  const StepBar({
    super.key,
    required this.steps,
    required this.currentIndex,
    this.tokens,
  });

  /// Step captions, in order.
  final List<String> steps;

  /// Zero-based index of the active step. Steps before it render as done.
  final int currentIndex;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    if (steps.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Container(
              width: t.compactSpacing * 2,
              height: 1,
              color: i <= currentIndex ? t.primaryColor : t.borderColor,
            ),
          _StepItem(
            caption: steps[i],
            number: i + 1,
            state: i < currentIndex
                ? _StepState.done
                : (i == currentIndex ? _StepState.current : _StepState.upcoming),
            tokens: t,
          ),
        ],
      ],
    );
  }
}

enum _StepState { done, current, upcoming }

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.caption,
    required this.number,
    required this.state,
    required this.tokens,
  });

  final String caption;
  final int number;
  final _StepState state;
  final DesktopTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final isUpcoming = state == _StepState.upcoming;
    final badgeColor = isUpcoming ? t.borderColor : t.primaryColor;
    final textColor = isUpcoming ? t.mutedForegroundColor : t.foregroundColor;
    const badgeSize = 18.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: badgeSize,
          height: badgeSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: state == _StepState.current ? badgeColor : Colors.transparent,
            border: Border.all(color: badgeColor),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize - 1,
              color: state == _StepState.current
                  ? t.accentForegroundColor
                  : textColor,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        SizedBox(width: t.compactSpacing),
        Text(
          caption,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize - 1,
            color: textColor,
            fontWeight:
                state == _StepState.current ? FontWeight.w600 : FontWeight.w400,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
