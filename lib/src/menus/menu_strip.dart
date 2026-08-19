import 'dart:async';

import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

/// A single entry inside a [MenuStrip] or [ContextMenuStrip].
///
/// Use [MenuItem] for actionable entries and [MenuSeparator] for visual
/// dividers.
sealed class MenuModel {
  const MenuModel();
}

/// An actionable menu entry.
class MenuItem extends MenuModel {
  const MenuItem({
    required this.text,
    this.shortcut,
    this.onPressed,
    this.children = const [],
    this.enabled = true,
  });

  /// Display text.
  final String text;

  /// Optional keyboard shortcut label (e.g. `Ctrl+S`). Shown on the right.
  final String? shortcut;

  /// Called when the item is activated. When `null` **and** [enabled] is
  /// `true`, the item is rendered but inert.
  final VoidCallback? onPressed;

  /// Sub-items. When non-empty the entry opens a sub-menu on hover / tap.
  final List<MenuModel> children;

  /// Whether the entry is interactive.
  final bool enabled;
}

/// A thin horizontal line that separates groups of menu items.
class MenuSeparator extends MenuModel {
  const MenuSeparator();
}

// ---------------------------------------------------------------------------
// MenuStrip
// ---------------------------------------------------------------------------

/// A WinForm-style main menu bar.
///
/// Renders a horizontal strip of top-level menu items. Tapping (or
/// hovering once opened) an item reveals a floating drop-down panel.
class MenuStrip extends StatefulWidget {
  const MenuStrip({
    super.key,
    required this.items,
    this.tokens,
  });

  /// Top-level menu entries.
  final List<MenuItem> items;

  /// Token override.
  final DesktopTokens? tokens;

  @override
  State<MenuStrip> createState() => _MenuStripState();
}

class _MenuStripState extends State<MenuStrip> {
  /// Index of the currently-open top-level menu, or -1 when none is open.
  int _openIndex = -1;

  /// Overlay entry for the currently-visible drop-down.
  OverlayEntry? _overlayEntry;

  /// Stable per-item keys. Creating a fresh [GlobalKey] inside `build`
  /// would destroy every top-level item's State (and its hover tracking)
  /// on each rebuild — keys must outlive the build.
  final List<GlobalKey> _itemKeys = [];

  GlobalKey _keyFor(int index) {
    while (_itemKeys.length <= index) {
      _itemKeys.add(GlobalKey());
    }
    return _itemKeys[index];
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _openIndex = -1);
  }

  void _openMenu(int index, GlobalKey key) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _openIndex = index);

    final overlay = Overlay.of(context);
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => _MenuDropDown(
        items: widget.items[index].children,
        position: Offset(offset.dx, offset.dy + renderBox.size.height),
        tokens: t,
        onDismiss: _closeMenu,
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.controlColor,
        border: Border(
          bottom: BorderSide(color: t.borderColor, width: t.borderWidth),
        ),
      ),
      child: SizedBox(
        height: t.controlHeight,
        // A bar-level [Listener] with [HitTestBehavior.opaque] reliably
        // catches pointer-hover over the menu strip. It only *switches*
        // the open menu to the hovered item (_onBarHover early-returns
        // when nothing is open), so a plain hover never opens a menu on
        // its own — the bar must be opened by a click first. This is more
        // robust than relying on per-item [MouseRegion.onEnter], whose
        // onEnter can fail to fire on the initial hover when nothing is
        // open yet.
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerHover: (event) => _onBarHover(event.position.dx),
          // stretch:让每个顶层菜单项的背景填满整行高度,
          // 避免 hover 高亮只包住文字形成一条窄带(看起来像菜单项上的"横线")
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(widget.items.length, (i) {
              final key = _keyFor(i);
              final item = widget.items[i];
              final isOpen = _openIndex == i;

              return _MenuTopItem(
                key: key,
                text: item.text,
                tokens: t,
                isOpen: isOpen,
                onTap: () {
                  if (isOpen) {
                    _closeMenu();
                  } else {
                    _openMenu(i, key);
                  }
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Switches the open top-level menu to the item under the given global
  /// x-coordinate. This only runs **after a menu has been opened** (by a
  /// click) — hover never opens a menu on its own. This matches WinForm
  /// desktop behavior: click to open, then hover to switch between menus.
  /// No-op when nothing is open, or when the pointer isn't over an item,
  /// or when that item is already the open one.
  void _onBarHover(double globalDx) {
    if (_openIndex == -1) return; // 未打开任何菜单时,悬停不自动展开
    int? hit;
    for (int i = 0; i < widget.items.length; i++) {
      final rb =
          _keyFor(i).currentContext?.findRenderObject() as RenderBox?;
      if (rb == null) continue;
      final left = rb.localToGlobal(Offset.zero).dx;
      if (globalDx >= left && globalDx <= left + rb.size.width) {
        hit = i;
        break;
      }
    }
    if (hit != null && hit != _openIndex) {
      _openMenu(hit, _keyFor(hit));
    }
  }
}

// ---------------------------------------------------------------------------
// Top-level menu item (in the bar)
// ---------------------------------------------------------------------------

class _MenuTopItem extends StatefulWidget {
  const _MenuTopItem({
    super.key,
    required this.text,
    required this.tokens,
    required this.isOpen,
    required this.onTap,
  });

  final String text;
  final DesktopTokens tokens;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  State<_MenuTopItem> createState() => _MenuTopItemState();
}

class _MenuTopItemState extends State<_MenuTopItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final bg = widget.isOpen
        ? t.controlPressedColor
        : (_hovered ? t.controlHoverColor : t.controlColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
          color: bg,
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize,
              color: t.foregroundColor,
              height: 1.0,
              decoration: TextDecoration.none,
              // 显式常规字重:防止继承应用级 DefaultTextStyle 的 bold
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating drop-down panel
// ---------------------------------------------------------------------------

class _MenuDropDown extends StatefulWidget {
  const _MenuDropDown({
    required this.items,
    required this.position,
    required this.tokens,
    required this.onDismiss,
    this.onHoverEnter,
  });

  final List<MenuModel> items;
  final Offset position;
  final DesktopTokens tokens;
  final VoidCallback onDismiss;

  /// Invoked when the pointer enters this panel. Used by parent items to
  /// cancel their delayed sub-menu close.
  final VoidCallback? onHoverEnter;

  @override
  State<_MenuDropDown> createState() => _MenuDropDownState();
}

class _MenuDropDownState extends State<_MenuDropDown> {
  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final minWidth = 180.0;

    return Stack(
      children: [
        // Transparent scrim to capture pointer-downs outside the menu.
        // IMPORTANT: the scrim must NOT cover the menu bar strip
        // (0 .. position.dy). If it did, the full-screen overlay would
        // intercept pointer events over the top items and their
        // `MouseRegion.onEnter` would never fire — breaking the
        // "hover another top item to switch the open menu" behavior.
        // So the scrim starts below the menu bar and only spans the
        // area under it.
        // The scrim is a childless translucent Listener: its hit test
        // returns false so widgets underneath keep the hit — the same
        // click both dismisses the menu and lands on the widget below
        // (no wasted "close-only" click).
        Positioned(
          left: 0,
          right: 0,
          top: widget.position.dy,
          bottom: 0,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => widget.onDismiss(),
          ),
        ),
        // The actual drop-down.
        // 不用 Material(elevation):阴影的首次计算 / shader 编译是"首次展开慢、
        // 之后快"的主要来源,且 WinForm 菜单本来就是扁平的。用纯 Container。
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: MouseRegion(
            onEnter: (_) => widget.onHoverEnter?.call(),
            child: Container(
              constraints: BoxConstraints(minWidth: minWidth),
              padding: EdgeInsets.symmetric(vertical: t.compactSpacing),
              decoration: BoxDecoration(
                color: t.surfaceColor,
                border: Border.all(
                    color: t.borderColor, width: t.borderWidth),
              ),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: widget.items
                      .map((m) => _buildEntry(m, t, 0))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntry(MenuModel model, DesktopTokens t, int depth) {
    return switch (model) {
      MenuSeparator() => Padding(
          padding: EdgeInsets.symmetric(
              vertical: t.compactSpacing, horizontal: t.controlPaddingX),
          child: Container(
            height: t.borderWidth,
            color: t.borderColor,
          ),
        ),
      MenuItem() => _MenuDropDownItem(
          item: model,
          tokens: t,
          depth: depth,
          onDismiss: widget.onDismiss,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Single row inside a drop-down
// ---------------------------------------------------------------------------

class _MenuDropDownItem extends StatefulWidget {
  const _MenuDropDownItem({
    required this.item,
    required this.tokens,
    required this.depth,
    required this.onDismiss,
  });

  final MenuItem item;
  final DesktopTokens tokens;
  final int depth;
  final VoidCallback onDismiss;

  @override
  State<_MenuDropDownItem> createState() => _MenuDropDownItemState();
}

class _MenuDropDownItemState extends State<_MenuDropDownItem> {
  OverlayEntry? _subEntry;
  Timer? _closeTimer;
  bool _hovered = false;

  void _openSub() {
    _closeTimer?.cancel();
    _closeSub();
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final t = widget.tokens;

    _subEntry = OverlayEntry(
      builder: (ctx) => _MenuDropDown(
        items: widget.item.children,
        position:
            Offset(offset.dx + renderBox.size.width, offset.dy),
        tokens: t,
        onDismiss: widget.onDismiss,
        // Moving from the parent row into the sub-menu panel cancels
        // the delayed close scheduled by the parent's onExit.
        onHoverEnter: () => _closeTimer?.cancel(),
      ),
    );
    Overlay.of(context).insert(_subEntry!);
  }

  void _closeSub() {
    _subEntry?.remove();
    _subEntry = null;
  }

  /// Closing the sub-menu immediately on mouse-exit makes it impossible
  /// to reach: the pointer has to cross the gap between the parent row
  /// and the sub-menu. A short delay lets the pointer land on the
  /// sub-menu (whose onHoverEnter cancels this timer) before it closes.
  void _scheduleCloseSub() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _closeSub();
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _closeSub();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final hasSub = widget.item.children.isNotEmpty;
    final canActivate = widget.item.enabled && !hasSub;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        if (hasSub) _openSub();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        if (hasSub) _scheduleCloseSub();
      },
      child: GestureDetector(
        onTap: () {
          if (!canActivate) return;
          widget.item.onPressed?.call();
          widget.onDismiss();
        },
        child: Container(
          height: t.controlHeight,
          padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
          color: _hovered ? t.primaryColor : Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.text,
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize,
                    color: _hovered
                        ? t.surfaceColor
                        : (widget.item.enabled
                            ? t.foregroundColor
                            : t.disabledForegroundColor),
                    height: 1.0,
                    // 显式关闭下划线 / 常规字重:去掉 Material 后 Text 不再有
                    // Material 的 DefaultTextStyle 兜底,会继承应用级某个带
                    // decoration: underline / double / yellow 或 bold 的样式
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (widget.item.shortcut != null)
                Padding(
                  padding: EdgeInsets.only(left: t.controlPaddingX * 3),
                  child: Text(
                  widget.item.shortcut!,
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize,
                    color: _hovered
                        ? t.surfaceColor
                        : t.disabledForegroundColor,
                    height: 1.0,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                ),
              if (hasSub)
                Padding(
                  padding: EdgeInsets.only(left: t.compactSpacing),
                  child: Icon(
                    Icons.arrow_right,
                    size: t.fontSize + 2,
                    color: _hovered
                        ? t.surfaceColor
                        : t.foregroundColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
