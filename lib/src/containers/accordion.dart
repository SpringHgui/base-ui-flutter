import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';

/// Selection behavior of an [Accordion].
enum AccordionType {
  /// At most one item open at a time (opening one closes the others).
  single,

  /// Any number of items may be open at once.
  multiple,
}

/// One expandable section of an [Accordion].
class AccordionItem extends StatelessWidget {
  const AccordionItem({
    super.key,
    required this.value,
    required this.title,
    this.icon,
    this.child,
  });

  /// Stable identifier used by the accordion state.
  final String value;

  /// Header title.
  final String title;

  /// Optional leading icon.
  final Widget? icon;

  /// Body shown when expanded.
  final Widget? child;

  @override
  Widget build(BuildContext context) => child ?? const SizedBox.shrink();
}

/// A vertically stacked list of expandable sections — the counterpart of the
/// shadcn "Accordion".
class Accordion extends StatefulWidget {
  const Accordion({
    super.key,
    this.type = AccordionType.single,
    this.initialOpen = const [],
    this.onOpenChanged,
    this.tokens,
    required this.items,
  });

  /// Whether one or many items may be open.
  final AccordionType type;

  /// Values of the items initially open.
  final List<String> initialOpen;

  /// Called with the open values whenever the set changes.
  final ValueChanged<List<String>>? onOpenChanged;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// The accordion sections.
  final List<AccordionItem> items;

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  late Set<String> _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen.toSet();
  }

  void _toggle(String value) {
    setState(() {
      if (_open.contains(value)) {
        _open.remove(value);
      } else if (widget.type == AccordionType.multiple) {
        _open.add(value);
      } else {
        _open
          ..clear()
          ..add(value);
      }
    });
    widget.onOpenChanged?.call(_open.toList());
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: t.borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0)
              Container(
                height: t.borderWidth,
                color: t.borderColor,
              ),
            _AccordionSection(
              item: widget.items[i],
              open: _open.contains(widget.items[i].value),
              tokens: t,
              onToggle: () => _toggle(widget.items[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccordionSection extends StatelessWidget {
  const _AccordionSection({
    required this.item,
    required this.open,
    required this.tokens,
    required this.onToggle,
  });

  final AccordionItem item;
  final bool open;
  final DesktopTokens tokens;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Surface(
          tokens: t,
          onTap: onToggle,
          hoverColor: t.mutedColor,
          borderRadius: BorderRadius.zero,
          padding: EdgeInsets.symmetric(
            horizontal: t.controlPaddingX,
            vertical: t.compactSpacing * 1.5,
          ),
          child: Row(
            children: [
              if (item.icon != null) ...[
                item.icon!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize,
                    fontWeight: FontWeight.w500,
                    color: t.foregroundColor,
                    height: 1.2,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: t.fontSize * 1.2,
                  color: t.mutedForegroundColor,
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: open
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    t.controlPaddingX,
                    0,
                    t.controlPaddingX,
                    t.compactSpacing * 2,
                  ),
                  child: item.child,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
