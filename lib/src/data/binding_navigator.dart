import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../menus/tool_strip.dart';

/// A WinForm-style binding navigator.
///
/// Provides first / previous / next / last navigation buttons plus a position
/// indicator, composed on top of [ToolStrip].
class BindingNavigator extends StatelessWidget {
  const BindingNavigator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    this.onFirst,
    this.onPrevious,
    this.onNext,
    this.onLast,
    this.onAdd,
    this.onDelete,
    this.tokens,
  });

  /// Zero-based index of the current item.
  final int currentIndex;

  /// Total number of items.
  final int totalCount;

  /// Navigate to the first item.
  final VoidCallback? onFirst;

  /// Navigate to the previous item.
  final VoidCallback? onPrevious;

  /// Navigate to the next item.
  final VoidCallback? onNext;

  /// Navigate to the last item.
  final VoidCallback? onLast;

  /// Add a new item.
  final VoidCallback? onAdd;

  /// Delete the current item.
  final VoidCallback? onDelete;

  /// Token override.
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final atStart = currentIndex <= 0;
    final atEnd = currentIndex >= totalCount - 1;

    return ToolStrip(
      tokens: t,
      items: [
        ToolStripButton(
          icon: Icons.first_page,
          tooltip: 'First',
          enabled: !atStart,
          onPressed: onFirst,
        ),
        ToolStripButton(
          icon: Icons.chevron_left,
          tooltip: 'Previous',
          enabled: !atStart,
          onPressed: onPrevious,
        ),
        ToolStripLabel(
          text: '${totalCount > 0 ? currentIndex + 1 : 0} / $totalCount',
        ),
        ToolStripButton(
          icon: Icons.chevron_right,
          tooltip: 'Next',
          enabled: !atEnd,
          onPressed: onNext,
        ),
        ToolStripButton(
          icon: Icons.last_page,
          tooltip: 'Last',
          enabled: !atEnd,
          onPressed: onLast,
        ),
        const ToolStripSeparator(),
        ToolStripButton(
          icon: Icons.add,
          tooltip: 'Add',
          onPressed: onAdd,
        ),
        ToolStripButton(
          icon: Icons.delete,
          tooltip: 'Delete',
          onPressed: onDelete,
        ),
      ],
    );
  }
}
