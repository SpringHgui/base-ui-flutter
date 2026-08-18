import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style combo box (drop-down list).
///
/// Supports both read-only and editable modes. When [editable] is `true` the
/// user can type a custom value; otherwise only items from [items] may be
/// selected.
class ComboBox<T extends Object> extends StatefulWidget {
  const ComboBox({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.editable = false,
    this.hint,
    this.tokens,
    this.focusNode,
    this.enabled = true,
    this.itemToString,
  });

  /// The list of selectable items.
  final List<T> items;

  /// The currently selected item, or `null` when nothing is selected.
  final T? value;

  /// Called when the user picks a different item.
  final ValueChanged<T?>? onChanged;

  /// When `true`, the user can type a custom value.
  final bool editable;

  /// Placeholder shown when nothing is selected.
  final String? hint;

  /// Token override. Falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the combo box is interactive.
  final bool enabled;

  /// Converts an item to its string representation for display.
  final String Function(T)? itemToString;

  @override
  State<ComboBox<T>> createState() => _ComboBoxState<T>();
}

class _ComboBoxState<T extends Object> extends State<ComboBox<T>> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  /// Controller used by [RawAutocomplete] in editable mode. Kept in the
  /// State so [didUpdateWidget] can sync the text when [widget.value]
  /// changes externally.
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = TextEditingController(
      text: widget.value != null ? _itemString(widget.value as T) : '',
    );
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant ComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final newText =
          widget.value != null ? _itemString(widget.value as T) : '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  String _itemString(T item) =>
      widget.itemToString?.call(item) ?? item.toString();

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final focused = _focusNode.hasFocus;

    final borderColor = !widget.enabled
        ? t.borderColor
        : (focused ? t.primaryColor : t.borderColor);
    final fillColor = widget.enabled ? t.surfaceColor : t.controlDisabledColor;

    final dropdownItems = widget.items
        .map((item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                _itemString(item),
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: t.foregroundColor,
                ),
              ),
            ))
        .toList();

    return SizedBox(
      height: t.controlHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: widget.editable
            ? _buildEditable(t, dropdownItems)
            : _buildReadOnly(t, dropdownItems),
      ),
    );
  }

  Widget _buildReadOnly(
      DesktopTokens t, List<DropdownMenuItem<T>> dropdownItems) {
    // DropdownButton asserts that value exists exactly once in items.
    // Fall back to null when the caller-supplied value is not present
    // to avoid a hard crash in debug builds.
    final effectiveValue =
        widget.items.contains(widget.value) ? widget.value : null;

    return DropdownButton<T>(
      value: effectiveValue,
      onChanged: widget.enabled ? widget.onChanged : null,
      focusNode: _focusNode,
      isExpanded: true,
      isDense: true,
      underline: const SizedBox.shrink(),
      dropdownColor: t.surfaceColor,
      style: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: t.fontSize,
        color:
            widget.enabled ? t.foregroundColor : t.disabledForegroundColor,
      ),
      hint: widget.hint != null
          ? Text(
              widget.hint!,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: t.disabledForegroundColor,
              ),
            )
          : null,
      items: dropdownItems,
    );
  }

  Widget _buildEditable(
      DesktopTokens t, List<DropdownMenuItem<T>> dropdownItems) {
    // RawAutocomplete (unlike Autocomplete) accepts an external
    // focusNode and textEditingController, so the caller-supplied
    // focusNode actually drives focus and the focused border state.
    return RawAutocomplete<T>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return widget.items;
        return widget.items.where((item) =>
            _itemString(item)
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
      },
      displayStringForOption: _itemString,
      onSelected: widget.onChanged,
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 2,
            color: t.surfaceColor,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: options
                    .map((option) => InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: t.controlPaddingX,
                              vertical: t.compactSpacing,
                            ),
                            child: Text(
                              _itemString(option),
                              style: TextStyle(
                                fontFamily: t.fontFamily,
                                fontSize: t.fontSize,
                                color: t.foregroundColor,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        );
      },
      fieldViewBuilder:
          (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: widget.enabled,
          cursorColor: t.primaryColor,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: widget.enabled
                ? t.foregroundColor
                : t.disabledForegroundColor,
            height: 1.0,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize,
              color: t.disabledForegroundColor,
            ),
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: t.controlPaddingX),
          ),
        );
      },
    );
  }
}
