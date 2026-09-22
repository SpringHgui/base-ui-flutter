import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style combo box (drop-down list).
///
/// Three flavours:
/// * read-only (default) — the drop-down list is the only way to pick a value;
/// * [searchable] — same as read-only, but the drop-down panel carries a search
///   row so long item lists can be narrowed down by typing;
/// * [editable] — the field itself accepts free text, i.e. a value that is not
///   in [items] may be submitted.
class ComboBox<T extends Object> extends StatefulWidget {
  const ComboBox({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.editable = false,
    this.searchable = false,
    this.searchHint,
    this.noMatchText = 'No matches',
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

  /// When `true`, the drop-down panel opens with a search row: typing a query
  /// narrows the list down (case-insensitive substring match on
  /// [itemToString]).
  ///
  /// The typed text is a **filter, never a value** — unlike [editable], a query
  /// that matches nothing cannot be committed, so pickers whose value must come
  /// from the list (connection / database / schema names) get type-to-search
  /// without the risk of a fabricated value. Ignored when [editable] is `true`
  /// (the field itself already filters there).
  final bool searchable;

  /// Placeholder of the search row ([searchable]). Defaults to English like the
  /// rest of the library; hosts with other locales pass their own.
  final String? searchHint;

  /// Shown in the panel when the search query matches no item ([searchable]).
  final String noMatchText;

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

  /// Search row state ([ComboBox.searchable]). The query is a *filter*: it
  /// lives here and never leaks into [widget.value].
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();
  String _query = '';

  /// Whether the open panel shows the search row ([searchable] wins only in
  /// read-only mode; an editable field is its own filter).
  bool get _showSearchRow => widget.searchable && !widget.editable;

  /// [widget.items] narrowed by the current query.
  List<T> get _matchingItems {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items
        .where((item) => _itemString(item).toLowerCase().contains(query))
        .toList(growable: false);
  }

  /// Panel content lives in an [OverlayEntry] with its own builder — an outer
  /// `setState` does not rebuild it, so it has to be marked dirty explicitly.
  void _refreshPanel() => _overlayEntry?.markNeedsBuild();

  void _onQueryChanged(String value) {
    _query = value;
    _hoverIndex = -1;
    _refreshPanel();
  }

  /// Enter in the search row commits the first match: the list is already
  /// filtered, so its first row is the best candidate.
  void _selectFirstMatch() {
    final items = _matchingItems;
    if (items.isEmpty) return;
    widget.onChanged?.call(items.first);
    _closeDropDown();
  }

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
    _queryController.dispose();
    _queryFocusNode.dispose();
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
    // 每次打开都从「无筛选」开始:上一次的查询不该影响这一次的选择。
    _query = '';
    _queryController.clear();
    _hoverIndex = -1;
    setState(() => _dropDownOpen = true);
    // Use overlay: insert an OverlayEntry so the popup floats above siblings.
    _overlayEntry = _buildOverlayEntry(t);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropDown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    // 搜索行随面板一起消失,焦点留在它上面会指向一个已卸载的节点。
    if (_queryFocusNode.hasFocus) _queryFocusNode.unfocus();
    if (mounted) setState(() => _dropDownOpen = false);
  }

  OverlayEntry? _overlayEntry;

  OverlayEntry _buildOverlayEntry(DesktopTokens t) {
    return OverlayEntry(
      builder: (context) {
        // 面板内容**必须在这里现算**:本方法只在打开时跑一次,之后的刷新(输入
        // 筛选、hover 高亮)都只是重跑这个 builder。把候选列表捕获在外层作用域
        // 里的话,过滤与高亮都会拿着打开那一刻的旧值,看起来就是「没反应」。
        final items = _matchingItems;
        // Guard null value: `widget.value as T` would throw when nothing is
        // selected yet, which happens inside the overlay builder and prevents
        // the drop-down from ever appearing.
        final selectedIndex = widget.value == null
            ? -1
            : items.indexOf(widget.value as T);
        final itemHeight = t.controlHeight;
        final visibleItems = items.length > 10 ? 10 : items.length;
        // 无匹配时留一行放占位文案,面板不会塌成一条线。
        final listHeight = (visibleItems == 0 ? 1 : visibleItems) * itemHeight;

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
              // 不加 `constraints`:各行高度都已算死,再压一个 maxHeight 反而会与
              // `decoration` 的边框打架 —— `Container` 把 `Border.all` 当内边距用,
              // 子项可用的高度会比 maxHeight 少掉两条边框,固定高度的列表就溢出。
              child: Container(
                width: _boxWidth(),
                decoration: BoxDecoration(
                  color: t.surfaceColor,
                  border: Border.all(
                    color: t.borderColor,
                    width: t.borderWidth,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // 分隔线要铺满面板宽度;Column 默认 center,横向会被压成 0。
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_showSearchRow) ...[
                      _searchRow(t),
                      // 分隔线独立一层:Container 的 decoration 边框会挤掉子项高度,
                      // 挂在搜索行上会让它比 `controlHeight` 矮一个边框。
                      Container(height: t.borderWidth, color: t.borderColor),
                    ],
                    SizedBox(
                      height: listHeight,
                      child: items.isEmpty
                          ? _emptyRow(t)
                          : ListView.builder(
                              physics: items.length <= 10
                                  ? const NeverScrollableScrollPhysics()
                                  : null,
                              padding: EdgeInsets.zero,
                              itemCount: items.length,
                              itemExtent: itemHeight,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final isSelected = index == selectedIndex;
                                final isHovered = _hoverIndex == index;
                                return MouseRegion(
                                  onEnter: (_) => _setHoverIndex(index),
                                  onExit: (_) {
                                    if (_hoverIndex == index) {
                                      _setHoverIndex(-1);
                                    }
                                  },
                                  child: Listener(
                                    behavior: HitTestBehavior.opaque,
                                    onPointerDown: (_) {
                                      widget.onChanged?.call(item);
                                      _closeDropDown();
                                    },
                                    child: Container(
                                      color: isSelected
                                          ? t.primaryColor
                                          : (isHovered
                                                ? t.controlHoverColor
                                                : null),
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
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _hoverIndex = -1;

  /// hover 高亮同样画在 [OverlayEntry] 里,只 `setState` 不会重绘面板 —— 必须
  /// 显式把入口标脏(与 [_onQueryChanged] 同一原因)。
  void _setHoverIndex(int index) {
    if (_hoverIndex == index) return;
    _hoverIndex = index;
    _refreshPanel();
  }

  /// 面板顶部的搜索行([ComboBox.searchable]):放大镜 + 单行输入框。
  ///
  /// 高度严格等于 `controlHeight`(与闭合态控件等高),所以**不能**用带
  /// `decoration` 的 `Container` 包它 —— `Container` 会把 `Border` 的宽度当作
  /// 内边距挤掉子项高度,搜索框就会被压矮;分隔线由调用方另起一层画。
  Widget _searchRow(DesktopTokens t) {
    final double padV = (t.controlHeight - t.fontSize) / 2;
    return SizedBox(
      height: t.controlHeight,
      child: Listener(
        // 点行内空白 / 放大镜也能开始输入。
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          if (!_queryFocusNode.hasFocus) _queryFocusNode.requestFocus();
        },
        child: Row(
          children: [
            SizedBox(width: t.controlPaddingX),
            Icon(
              Icons.search,
              size: t.fontSize + 2,
              color: t.mutedForegroundColor,
            ),
            SizedBox(width: t.compactSpacing),
            Expanded(
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape):
                      _closeDropDown,
                },
                child: Material(
                  type: MaterialType.transparency,
                  child: TextField(
                    controller: _queryController,
                    focusNode: _queryFocusNode,
                    autofocus: true,
                    cursorColor: t.primaryColor,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize,
                      color: t.foregroundColor,
                      height: 1.0,
                    ),
                    // Enter = 取第一个匹配项;列表已按查询过滤过,首行即最佳候选。
                    onSubmitted: (_) => _selectFirstMatch(),
                    onChanged: _onQueryChanged,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
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
                        vertical: padV < 0 ? 0 : padV,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: t.compactSpacing),
          ],
        ),
      ),
    );
  }

  /// 查询无匹配时的占位行(高度与候选项一致,面板不塌)。
  Widget _emptyRow(DesktopTokens t) => Padding(
    padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget.noMatchText,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontFamily: t.fontFamily,
          fontSize: t.fontSize,
          color: t.mutedForegroundColor,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );

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
