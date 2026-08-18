import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style domain up/down control.
///
/// Displays a string value from a predefined list with up/down buttons to
/// cycle through items.
class DomainUpDown<T> extends StatefulWidget {
  const DomainUpDown({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onSelectedIndexChanged,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.itemToString,
  });

  /// The list of selectable items.
  final List<T> items;

  /// The currently selected index.
  final int selectedIndex;

  /// Called when the index changes.
  final ValueChanged<int>? onSelectedIndexChanged;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the control should focus itself when first built.
  final bool autofocus;

  /// Whether the control is interactive.
  final bool enabled;

  /// Converts an item to its string representation.
  final String Function(T)? itemToString;

  @override
  State<DomainUpDown<T>> createState() => _DomainUpDownState<T>();
}

class _DomainUpDownState<T> extends State<DomainUpDown<T>> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  String _itemString(T item) =>
      widget.itemToString?.call(item) ?? item.toString();

  void _increment() {
    if (!widget.enabled || widget.items.isEmpty) return;
    final next = (widget.selectedIndex + 1) % widget.items.length;
    widget.onSelectedIndexChanged?.call(next);
  }

  void _decrement() {
    if (!widget.enabled || widget.items.isEmpty) return;
    final next =
        (widget.selectedIndex - 1 + widget.items.length) % widget.items.length;
    widget.onSelectedIndexChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    final buttonWidth = t.controlHeight * 0.75;
    final displayText = widget.items.isNotEmpty
        ? _itemString(widget.items[widget.selectedIndex])
        : '';

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: SizedBox(
        height: t.controlHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.enabled ? t.surfaceColor : t.controlDisabledColor,
            border: Border.all(color: t.borderColor, width: t.borderWidth),
            borderRadius: BorderRadius.circular(t.cornerRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: t.controlPaddingX),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize,
                      color: widget.enabled
                          ? t.foregroundColor
                          : t.disabledForegroundColor,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: buttonWidth,
                child: InkWell(
                  onTap: widget.enabled ? _increment : null,
                  child: Icon(Icons.arrow_drop_up,
                      size: t.fontSize + 4,
                      color: widget.enabled
                          ? t.foregroundColor
                          : t.disabledForegroundColor),
                ),
              ),
              SizedBox(
                width: buttonWidth,
                child: InkWell(
                  onTap: widget.enabled ? _decrement : null,
                  child: Icon(Icons.arrow_drop_down,
                      size: t.fontSize + 4,
                      color: widget.enabled
                          ? t.foregroundColor
                          : t.disabledForegroundColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
