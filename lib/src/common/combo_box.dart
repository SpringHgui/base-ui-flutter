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
    this.iconBuilder,
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

  /// Builds a leading icon for an item (owner-draw style, e.g. an engine /
  /// entity glyph in front of the name). Applied to both the closed box's
  /// current value and every entry of the drop-down list. `null` (default)
  /// renders text only, exactly as before.
  final Widget? Function(T item)? iconBuilder;

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

  /// Key on the combo box surface, used to measure its width for the popup.
  final GlobalKey _boxKey = GlobalKey();

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

  /// Leading icon for [item] (sized from the tokens so it stays inside the
  /// control height); `null` when the caller passed no `iconBuilder` or the
  /// builder declined to draw one for this item.
  Widget? _iconOf(T item, DesktopTokens t) {
    final builder = widget.iconBuilder;
    if (builder == null) return null;
    final icon = builder(item);
    if (icon == null) return null;
    final edge = (t.controlHeight - 8).clamp(12.0, 18.0).toDouble();
    return SizedBox(width: edge, height: edge, child: icon);
  }

  /// Text + optional leading icon laid out in one row.
  Widget _labeled(Widget text, Widget? icon, DesktopTokens t) {
    if (icon == null) return text;
    return Row(
      children: [
        icon,
        SizedBox(width: t.compactSpacing),
        Expanded(child: text),
      ],
    );
  }

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
    // Read-only (non-editable) drop-downs use the control face color so they
    // stand out from editable inputs; editable combo boxes stay white like a
    // text box, and disabled keeps the disabled face color.
    final fillColor = !widget.enabled
        ? t.controlDisabledColor
        : (widget.editable ? t.surfaceColor : t.controlColor);

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

    // No LayoutBuilder: it conflicts with IntrinsicHeight when the combo box
    // is embedded inside a DialogBox ("LayoutBuilder does not support
    // returning intrinsic dimensions"). The popup width is measured on
    // demand via [_boxWidth] instead (popups only open after layout).
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        key: _boxKey,
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
  }

  /// Read-only drop-down: custom WinForm-style, no Material animation.
  /// Click instantly opens the item list; selecting or clicking outside closes.
  Widget _buildReadOnly(DesktopTokens t) {
    final displayText = widget.value != null
        ? _itemString(widget.value as T)
        : (widget.hint ?? '');
    final isHint = widget.value == null && widget.hint != null;
    final value = widget.value;
    final leading = value == null ? null : _iconOf(value, t);

    return Listener(
      behavior: HitTestBehavior.opaque,
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
                child: _labeled(
                  Text(
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
                  leading,
                  t,
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
    // Guard null value: `widget.value as T` would throw when nothing is
    // selected yet, which happens inside the overlay builder and prevents
    // the drop-down from ever appearing.
    final selectedIndex = widget.value == null
        ? -1
        : widget.items.indexOf(widget.value as T);
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
                width: _boxWidth(),
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
                        behavior: HitTestBehavior.opaque,
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
                          child: _labeled(
                            Text(
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
                            _iconOf(item, t),
                            t,
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

  /// Cached combo box width; refreshed from the render tree by [_boxWidth].
  double _lastBoxWidth = 200;

  /// Width of the combo box surface, measured on demand from the render
  /// tree (drop-downs only open after layout, so the box is always sized).
  double _boxWidth() {
    final box = _boxKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      _lastBoxWidth = box.size.width;
    }
    return _lastBoxWidth;
  }

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
            width: _boxWidth(),
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
                      icon: _iconOf(option, t),
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
        // isDense 会让 InputDecorator 容器塌缩到行高并贴顶,这里用精确的垂直
        // padding 把内容区垫到与控件等高,文字即垂直居中(style height:1.0 时
        // 行高恰好等于 fontSize)。
        final double padV = (t.controlHeight - t.fontSize) / 2;
        final value = widget.value;
        final field = Material(
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
              visualDensity: VisualDensity.standard,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: t.controlPaddingX,
                vertical: padV < 0 ? 0 : padV,
              ),
            ),
          ),
        );
        if (value == null) return field;
        final icon = _iconOf(value, t);
        // Leading icon eats into the text field's own horizontal padding so
        // the glyph lines up with the read-only mode's icon column.
        if (icon == null) return field;
        return Padding(
          padding: EdgeInsets.only(left: t.controlPaddingX),
          child: _labeled(field, icon, t),
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
    this.icon,
  });

  final String text;
  final DesktopTokens tokens;
  final VoidCallback onSelected;

  /// Optional leading glyph (owner-draw combo boxes); already size-constrained.
  final Widget? icon;

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
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => widget.onSelected(),
        child: Container(
          color: _hover ? t.controlHoverColor : null,
          padding: EdgeInsets.symmetric(
            horizontal: t.controlPaddingX,
            vertical: t.compactSpacing,
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                SizedBox(width: t.compactSpacing),
              ],
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }
}
