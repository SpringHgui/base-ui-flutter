import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Implements a declarative focus state machine (Roving Tabindex) for
/// keyboard-first navigation.
///
/// In a roving-tabindex pattern, only one element in a group has
/// `tabIndex=0` at any time; the rest have `tabIndex=-1`. Arrow keys move
/// the "active" focus within the group without leaving it.
///
/// Usage:
/// ```dart
/// RovingTabindex(
///   axis: Axis.horizontal,
///   children: [
///     FocusableItem(...),
///     FocusableItem(...),
///   ],
/// )
/// ```
class RovingTabindex extends StatefulWidget {
  const RovingTabindex({
    super.key,
    required this.children,
    this.axis = Axis.horizontal,
    this.initialIndex = 0,
    this.wrap = true,
  });

  /// The focusable children.
  final List<Widget> children;

  /// Navigation axis.
  final Axis axis;

  /// Index of the initially-focused child.
  final int initialIndex;

  /// Whether focus wraps around at the ends.
  final bool wrap;

  @override
  State<RovingTabindex> createState() => _RovingTabindexState();
}

class _RovingTabindexState extends State<RovingTabindex> {
  late int _activeIndex;
  final List<FocusNode> _nodes = [];

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.children.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.children.length - 1);
    _initNodes();
  }

  void _initNodes() {
    for (final n in _nodes) {
      n.dispose();
    }
    _nodes.clear();
    for (int i = 0; i < widget.children.length; i++) {
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus && mounted && _activeIndex != i) {
          setState(() => _activeIndex = i);
        }
      });
      _nodes.add(node);
    }
  }

  @override
  void didUpdateWidget(covariant RovingTabindex oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _initNodes();
      _activeIndex = widget.children.isEmpty
          ? 0
          : _activeIndex.clamp(0, widget.children.length - 1);
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _moveFocus(int delta) {
    final len = _nodes.length;
    if (len == 0) return;
    int next = _activeIndex + delta;
    if (widget.wrap) {
      next = (next % len + len) % len;
    } else {
      next = next.clamp(0, len - 1);
    }
    _nodes[next].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        final isHorizontal = widget.axis == Axis.horizontal;
        if (event is KeyDownEvent) {
          if (isHorizontal) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _moveFocus(-1);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _moveFocus(1);
              return KeyEventResult.handled;
            }
          } else {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _moveFocus(-1);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _moveFocus(1);
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: widget.axis == Axis.horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.children.length,
                (i) => Focus(
                  focusNode: _nodes[i],
                  canRequestFocus: true,
                  child: widget.children[i],
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.children.length,
                (i) => Focus(
                  focusNode: _nodes[i],
                  canRequestFocus: true,
                  child: widget.children[i],
                ),
              ),
            ),
    );
  }
}
