import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/overlay.dart';
import '../foundation/token_scope.dart';
import 'check_row.dart';
import 'popover.dart';

/// A popover-based filter panel with a header, scrollable checkbox list,
/// and a "clear all" action.
///
/// The trigger button toggles between neutral (empty filter) and accent
/// (active filter) styling. All visuals are token-driven.
class FilterPopover extends StatelessWidget {
  const FilterPopover({
    super.key,
    required this.options,
    this.title = '筛选',
    this.icon = Icons.filter_list,
    this.width = 240,
    this.maxListHeight = 220,
    this.side = OverlaySide.top,
    this.align = OverlayAlign.end,
    this.gap = 4,
    this.hasActiveFilter = false,
    this.onClear,
    this.tokens,
  });

  final List<FilterOption> options;
  final String title;
  final IconData icon;
  final double width;
  final double maxListHeight;
  final OverlaySide side;
  final OverlayAlign align;
  final double gap;
  final bool hasActiveFilter;
  final VoidCallback? onClear;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return Popover(
      side: side,
      align: align,
      gap: gap,
      width: width,
      padding: const EdgeInsets.all(10),
      trigger: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: Icon(
          icon,
          size: 15,
          color: hasActiveFilter ? t.primaryColor : t.mutedForegroundColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 15, color: t.mutedForegroundColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  fontWeight: FontWeight.w600,
                  color: t.popoverForegroundColor,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: maxListHeight,
            child: SingleChildScrollView(
              child: Column(
                children: options
                    .map((opt) => CheckRow(option: opt, tokens: t))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClear,
            child: Text(
              '全部清除',
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: t.primaryColor,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
