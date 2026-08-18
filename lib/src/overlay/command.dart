import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/overlay.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';

/// One selectable row of a [Command] palette.
class CommandItem extends StatelessWidget {
  const CommandItem({
    super.key,
    required this.text,
    this.keywords,
    this.leading,
    this.trailing,
    this.onSelect,
    this.tokens,
  });

  /// Display text (also used for filtering).
  final String text;

  /// Extra search keywords (not displayed).
  final List<String>? keywords;

  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onSelect;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// A hairline separator between [CommandItem]s.
class CommandSeparator extends StatelessWidget {
  const CommandSeparator({super.key, this.tokens});

  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Container(
      height: t.borderWidth,
      margin: EdgeInsets.symmetric(vertical: t.compactSpacing),
      color: t.borderColor,
    );
  }
}

/// A searchable command palette modal — the counterpart of the shadcn
/// "Command". Type to filter [CommandItem]s; arrow keys move the highlight,
/// Enter activates, Escape closes.
class Command extends StatefulWidget {
  const Command({
    super.key,
    this.controller,
    this.trigger,
    this.open,
    this.onClose,
    this.placeholder = 'Type a command or search…',
    this.width = 480,
    this.maxHeight = 420,
    required this.children,
    this.onOpenChanged,
    this.tokens,
  });

  final OverlayController? controller;
  final Widget? trigger;
  final bool? open;
  final VoidCallback? onClose;
  final String placeholder;
  final double width;
  final double maxHeight;
  final List<Widget> children;
  final ValueChanged<bool>? onOpenChanged;
  final DesktopTokens? tokens;

  @override
  State<Command> createState() => _CommandState();
}

class _CommandState extends State<Command> {
  OverlayController? _internal;
  late OverlayController _controller;
  final TextEditingController _search = TextEditingController();
  int _highlight = 0;

  OverlayController get _effective =>
      widget.controller ?? (_internal ??= OverlayController());

  @override
  void initState() {
    super.initState();
    _controller = _effective;
    if (widget.open == true) _controller.open();
  }

  @override
  void didUpdateWidget(Command oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = _effective;
    }
    if (widget.open != null && widget.open != _controller.isOpen) {
      widget.open! ? _controller.open() : _controller.close();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _internal?.dispose();
    super.dispose();
  }

  /// The visible items (children flattened, filtering out `CommandItem`s
  /// that do not match the query).
  List<CommandItem> get _visibleItems {
    final query = _search.text.trim().toLowerCase();
    final items = <CommandItem>[];
    for (final child in widget.children) {
      if (child is CommandItem) {
        final haystack = [
          child.text.toLowerCase(),
          ...?(child.keywords?.map((k) => k.toLowerCase())),
        ].join(' ');
        if (query.isEmpty || haystack.contains(query)) {
          items.add(child);
        }
      }
    }
    return items;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final items = _visibleItems;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (items.isNotEmpty) {
          setState(() => _highlight = (_highlight + 1) % items.length);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        if (items.isNotEmpty) {
          setState(() =>
              _highlight = (_highlight - 1 + items.length) % items.length);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
        if (items.isNotEmpty && _highlight < items.length) {
          final item = items[_highlight];
          item.onSelect?.call();
          _controller.close();
          widget.onClose?.call();
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        _controller.close();
        widget.onClose?.call();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    final overlay = ModalOverlay(
      controller: _controller,
      closeOnBarrierTap: true,
      closeOnEscape: false, // Escape is handled by the palette itself.
      onOpenChanged: (open) {
        widget.onOpenChanged?.call(open);
        if (open) _highlight = 0;
      },
      content: Container(
        width: widget.width,
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        decoration: BoxDecoration(
          color: t.popoverColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.radiusLg),
          boxShadow: [
            BoxShadow(
              color: t.shadowColor,
              blurRadius: t.shadowBlur,
              offset: Offset(0, t.shadowOffsetY),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: t.controlPaddingX,
                vertical: t.compactSpacing * 1.25,
              ),
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
                  Icon(
                    Icons.search,
                    size: t.fontSize * 1.2,
                    color: t.mutedForegroundColor,
                  ),
                  SizedBox(width: t.compactSpacing),
                  Expanded(
                    child: Focus(
                      onKeyEvent: (node, event) => _handleKey(node, event),
                      child: TextField(
                        controller: _search,
                        autofocus: true,
                        onChanged: (_) => setState(() => _highlight = 0),
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: t.fontSize,
                          color: t.foregroundColor,
                        ),
                        cursorColor: t.primaryColor,
                        decoration: InputDecoration(
                          hintText: widget.placeholder,
                          hintStyle: TextStyle(
                            fontFamily: t.fontFamily,
                            fontSize: t.fontSize,
                            color: t.mutedForegroundColor,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: t.compactSpacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildRows(t),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.trigger == null) return overlay;
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _controller.open(),
          child: widget.trigger,
        ),
        overlay,
      ],
    );
  }

  List<Widget> _buildRows(DesktopTokens t) {
    final query = _search.text.trim().toLowerCase();
    final rows = <Widget>[];
    var itemIndex = 0;
    for (final child in widget.children) {
      if (child is CommandSeparator) {
        rows.add(child);
        continue;
      }
      if (child is! CommandItem) {
        rows.add(child);
        continue;
      }
      final haystack = [
        child.text.toLowerCase(),
        ...?(child.keywords?.map((k) => k.toLowerCase())),
      ].join(' ');
      if (query.isNotEmpty && !haystack.contains(query)) continue;
      final highlighted = itemIndex == _highlight;
      rows.add(
        Surface(
          tokens: t,
          onTap: () {
            child.onSelect?.call();
            _controller.close();
            widget.onClose?.call();
          },
          color: highlighted ? t.accentColor : Colors.transparent,
          hoverColor: highlighted ? null : t.accentColor,
          semanticLabel: child.text,
          constraints: BoxConstraints(minHeight: t.controlHeight),
          padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
          child: Row(
            children: [
              if (child.leading != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: t.fontSize * 1.2,
                    color: highlighted
                        ? t.accentForegroundColor
                        : t.mutedForegroundColor,
                  ),
                  child: child.leading!,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  child.text,
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize * 0.875,
                    color: highlighted
                        ? t.accentForegroundColor
                        : t.foregroundColor,
                    height: 1.2,
                  ),
                ),
              ),
              if (child.trailing != null) child.trailing!,
            ],
          ),
        ),
      );
      itemIndex++;
    }
    if (rows.isEmpty) {
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: t.controlPaddingX,
            vertical: t.compactSpacing * 2,
          ),
          child: Text(
            'No results found',
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize * 0.875,
              color: t.mutedForegroundColor,
              height: 1.2,
            ),
          ),
        ),
      );
    }
    return rows;
  }
}
