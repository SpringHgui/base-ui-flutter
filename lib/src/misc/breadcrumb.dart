import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';

/// One segment of a [Breadcrumb].
class BreadcrumbItem {
  const BreadcrumbItem(this.label, {this.onTap, this.icon});

  final String label;

  /// Called when the segment is activated; `null` renders it as plain text
  /// (typically the current page).
  final VoidCallback? onTap;

  final Widget? icon;
}

/// A navigation trail of parent pages — the counterpart of the shadcn
/// "Breadcrumb". Segments are separated by chevrons; the last segment is
/// rendered as the current (non-interactive) page.
class Breadcrumb extends StatelessWidget {
  const Breadcrumb({
    super.key,
    required this.items,
    this.tokens,
  });

  /// The trail, from root to current page.
  final List<BreadcrumbItem> items;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: t.compactSpacing,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Icon(
              Icons.chevron_right,
              size: t.fontSize * 1.1,
              color: t.mutedForegroundColor,
            ),
          _BreadcrumbSegment(
            item: items[i],
            isLast: i == items.length - 1,
            tokens: t,
          ),
        ],
      ],
    );
  }
}

class _BreadcrumbSegment extends StatelessWidget {
  const _BreadcrumbSegment({
    required this.item,
    required this.isLast,
    required this.tokens,
  });

  final BreadcrumbItem item;
  final bool isLast;
  final DesktopTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final label = Text(
      item.label,
      style: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: t.fontSize * 0.875,
        fontWeight: isLast ? FontWeight.w500 : FontWeight.w400,
        color: isLast ? t.foregroundColor : t.mutedForegroundColor,
        height: 1.2,
      ),
    );
    if (isLast || item.onTap == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[item.icon!, const SizedBox(width: 4)],
          label,
        ],
      );
    }
    return Surface(
      tokens: t,
      onTap: item.onTap,
      hoverColor: t.mutedColor,
      padding: EdgeInsets.symmetric(
        horizontal: t.compactSpacing,
        vertical: t.compactSpacing * 0.5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[item.icon!, const SizedBox(width: 4)],
          label,
        ],
      ),
    );
  }
}
