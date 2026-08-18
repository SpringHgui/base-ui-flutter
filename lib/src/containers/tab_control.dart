import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';

/// One page of a [TabControl].
class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.label,
    this.icon,
    this.child,
  });

  /// Tab header text.
  final String label;

  /// Optional leading icon.
  final Widget? icon;

  /// Page content shown while this tab is selected.
  final Widget? child;

  @override
  Widget build(BuildContext context) => child ?? const SizedBox.shrink();
}

/// A tabbed container (WinForm `TabControl`; the counterpart of the shadcn
/// "Tabs"). The header bar highlights the selected tab with the token accent
/// underline; hover and focus states are token-driven.
class TabControl extends StatefulWidget {
  const TabControl({
    super.key,
    this.initialIndex = 0,
    this.onChanged,
    this.tokens,
    required this.tabs,
  });

  /// Index of the initially selected tab.
  final int initialIndex;

  /// Called with the selected index whenever it changes.
  final ValueChanged<int>? onChanged;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// The tab pages.
  final List<TabItem> tabs;

  @override
  State<TabControl> createState() => _TabControlState();
}

class _TabControlState extends State<TabControl> {
  late int _index;
  final FocusNode _barFocus = FocusNode(debugLabel: 'TabControl');

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.tabs.length - 1);
  }

  @override
  void didUpdateWidget(TabControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _index = widget.initialIndex.clamp(0, widget.tabs.length - 1);
    }
  }

  void _select(int index) {
    if (index == _index || index < 0 || index >= widget.tabs.length) return;
    setState(() => _index = index);
    widget.onChanged?.call(index);
  }

  KeyEventResult _handleBarKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _select((_index + 1) % widget.tabs.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _select((_index - 1 + widget.tabs.length) % widget.tabs.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.home) {
      _select(0);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.end) {
      _select(widget.tabs.length - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _barFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    if (widget.tabs.isEmpty) return const SizedBox.shrink();
    final index = _index.clamp(0, widget.tabs.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Focus(
          focusNode: _barFocus,
          onKeyEvent: _handleBarKey,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: t.borderColor,
                  width: t.borderWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                for (var i = 0; i < widget.tabs.length; i++)
                  _TabHeader(
                    tab: widget.tabs[i],
                    selected: i == index,
                    tokens: t,
                    onTap: () => _select(i),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: t.compactSpacing * 2),
          child: widget.tabs[index].child ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TabHeader extends StatelessWidget {
  const _TabHeader({
    required this.tab,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  final TabItem tab;
  final bool selected;
  final DesktopTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final fg = selected ? t.foregroundColor : t.mutedForegroundColor;
    return Surface(
      tokens: t,
      onTap: onTap,
      color: selected ? t.mutedColor : Colors.transparent,
      hoverColor: selected ? null : t.mutedColor,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(t.cornerRadius),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: t.controlPaddingX,
        vertical: t.compactSpacing * 1.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.icon != null) ...[
                tab.icon!,
                const SizedBox(width: 6),
              ],
              Text(
                tab.label,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize * 0.875,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: fg,
                  height: 1.2,
                ),
              ),
            ],
          ),
          // Full-width selection underline at the bottom of the tab.
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.only(top: t.compactSpacing),
            height: 2,
            color: selected ? t.primaryColor : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
