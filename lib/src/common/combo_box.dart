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

  /// Whether the read-only drop-down is currently open.
  bool _dropDownOpen = false;

  /// Layer link used to position the drop-down popup below the control.
  final LayerLink _layerLink = LayerLink();

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
      final newText = widget.value != null
          ? _itemString(widget.value as T)
          : '';
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
    _overlayEntry?.remove();
    _overlayEntry = null;
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
        .map(
          (item) => DropdownMenuItem<T>(
            value: item,
            child: Text(
              _itemString(item),
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: t.foregroundColor,
              ),
            ),
          ),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        _lastBoxWidth = constraints.maxWidth;
        return CompositedTransformTarget(
          link: _layerLink,
          child: SizedBox(
            height: t.controlHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fillColor,
                border: Border.all(color: borderColor, width: t.borderWidth),
                borderRadius: BorderRadius.circular(t.cornerRadius),
              ),
              child: widget.editable
                  ? _buildEditable(t, dropdownItems)
                  : _buildReadOnly(t),
            ),
          ),
        );
      },
    );
  }

  /// Read-only drop-down: custom WinForm-style, no Material animation.
  /// Click instantly opens the item list; selecting or clicking outside closes.
  Widget _buildReadOnly(DesktopTokens t) {
    final displayText = widget.value != null
        ? _itemString(widget.value as T)
        : (widget.hint ?? '');
    final isHint = widget.value == null && widget.hint != null;

    return Listener(
      onPointerDown: (_) {
        if (!widget.enabled || widget.items.isEmpty) return;
        _toggleDropDown(t);
      },
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
                child: Text(
                  displayText,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize,
                    color: isHint
                        ? t.disabledForegroundColor
                        : (widget.enabled
                              ? t.foregroundColor
                              : t.disabledForegroundColor),
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            // Drop-down arrow button area
            SizedBox(
              width: 20,
              child: Center(
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: widget.enabled
                      ? t.foregroundColor
                      : t.disabledForegroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleDropDown(DesktopTokens t) {
    if (_dropDownOpen) {
      _closeDropDown();
    } else {
      _openDropDown(t);
    }
  }

  void _openDropDown(DesktopTokens t) {
    setState(() => _dropDownOpen = true);
    // Use overlay: insert an OverlayEntry so the popup floats above siblings.
    _overlayEntry = _buildOverlayEntry(t);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropDown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _dropDownOpen = false);
  }

  OverlayEntry? _overlayEntry;

  OverlayEntry _buildOverlayEntry(DesktopTokens t) {
    final selectedIndex = widget.items.indexOf(widget.value as T);
    final itemHeight = t.controlHeight;
    final maxItems = widget.items.length;
    final visibleItems = maxItems > 10 ? 10 : maxItems;
    final panelHeight = visibleItems * itemHeight;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Full-screen dismiss barrier (translucent, no child → pass-through)
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _closeDropDown(),
              ),
            ),
            // The actual drop-down panel
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, t.controlHeight),
              child: Container(
                width: _lastBoxWidth,
                constraints: BoxConstraints(maxHeight: panelHeight.toDouble()),
                decoration: BoxDecoration(
                  color: t.surfaceColor,
                  border: Border.all(
                    color: t.borderColor,
                    width: t.borderWidth,
                  ),
                ),
                child: ListView.builder(
                  physics: widget.items.length <= 10
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemExtent: itemHeight,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = index == selectedIndex;
                    final isHovered = _hoverIndex == index;
                    return MouseRegion(
                      onEnter: (_) => setState(() => _hoverIndex = index),
                      onExit: (_) => setState(() {
                        if (_hoverIndex == index) _hoverIndex = -1;
                      }),
                      child: Listener(
                        onPointerDown: (_) {
                          widget.onChanged?.call(item);
                          _closeDropDown();
                        },
                        child: Container(
                          color: isSelected
                              ? t.primaryColor
                              : (isHovered ? t.controlHoverColor : null),
                          padding: EdgeInsets.symmetric(
                            horizontal: t.controlPaddingX,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _itemString(item),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: t.fontFamily,
                              fontSize: t.fontSize,
                              color: isSelected
                                  ? t.accentForegroundColor
                                  : t.foregroundColor,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _hoverIndex = -1;
  double _lastBoxWidth = 200;

  Widget _buildEditable(
    DesktopTokens t,
    List<DropdownMenuItem<T>> dropdownItems,
  ) {
    // RawAutocomplete (unlike Autocomplete) accepts an external
    // focusNode and textEditingController, so the caller-supplied
    // focusNode actually drives focus and the focused border state.
    return RawAutocomplete<T>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return widget.items;
        return widget.items.where(
          (item) => _itemString(
            item,
          ).toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      displayStringForOption: _itemString,
      onSelected: widget.onChanged,
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: _lastBoxWidth,
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: t.surfaceColor,
              border: Border.all(color: t.borderColor, width: t.borderWidth),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: options
                  .map(
                    (option) => _EditableOption(
                      text: _itemString(option),
                      tokens: t,
                      onSelected: () => onSelected(option),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Material(
          type: MaterialType.transparency,
          child: TextField(
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
              contentPadding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
            ),
          ),
        );
      },
    );
  }
}

/// 可编辑下拉候选项:Listener 按下即选中(零延迟) + MouseRegion hover 高亮,
/// 不依赖 Material InkWell(与只读下拉面板一致的交互约定)。
class _EditableOption extends StatefulWidget {
  const _EditableOption({
    required this.text,
    required this.tokens,
    required this.onSelected,
  });

  final String text;
  final DesktopTokens tokens;
  final VoidCallback onSelected;

  @override
  State<_EditableOption> createState() => _EditableOptionState();
}

class _EditableOptionState extends State<_EditableOption> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Listener(
        onPointerDown: (_) => widget.onSelected(),
        child: Container(
          color: _hover ? t.controlHoverColor : null,
          padding: EdgeInsets.symmetric(
            horizontal: t.controlPaddingX,
            vertical: t.compactSpacing,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize,
              color: t.foregroundColor,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
