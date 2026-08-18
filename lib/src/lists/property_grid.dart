import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// Describes a single editable property in a [PropertyGrid].
class PropertyItem {
  PropertyItem({
    required this.name,
    required this.category,
    required this.value,
    this.description = '',
    this.readOnly = false,
  });

  /// Property name (left column).
  final String name;

  /// Category for grouping.
  final String category;

  /// Current value (right column, editable unless [readOnly]).
  String value;

  /// Help text shown in a description panel.
  final String description;

  /// When `true`, the value cell is not editable.
  final bool readOnly;
}

/// A WinForm-style property grid.
///
/// Displays a two-column list of property names and values, grouped by
/// category. Values can be edited in-place.
class PropertyGrid extends StatefulWidget {
  const PropertyGrid({
    super.key,
    required this.properties,
    this.onValueChanged,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  /// The list of properties to display.
  final List<PropertyItem> properties;

  /// Called when a property value changes. Receives the property and the new
  /// string value.
  final void Function(PropertyItem property, String newValue)? onValueChanged;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the grid should focus itself when first built.
  final bool autofocus;

  /// Whether the grid is interactive.
  final bool enabled;

  @override
  State<PropertyGrid> createState() => _PropertyGridState();
}

class _PropertyGridState extends State<PropertyGrid> {
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

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    // Group by category
    final categories = <String, List<PropertyItem>>{};
    for (final p in widget.properties) {
      categories.putIfAbsent(p.category, () => []).add(p);
    }

    final rows = <Widget>[];
    for (final entry in categories.entries) {
      // Category header
      rows.add(Container(
        height: t.controlHeight,
        color: t.controlColor,
        padding: EdgeInsets.symmetric(horizontal: t.compactSpacing),
        alignment: Alignment.centerLeft,
        child: Text(
          entry.key,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            fontWeight: FontWeight.w600,
            color: t.foregroundColor,
          ),
        ),
      ));
      // Properties
      for (final prop in entry.value) {
        rows.add(_PropertyRow(
          // Stable identity so reordering the properties list does not
          // mis-associate row State (and their text controllers).
          key: ObjectKey(prop),
          property: prop,
          tokens: t,
          enabled: widget.enabled,
          onChanged: (newVal) {
            setState(() => prop.value = newVal);
            widget.onValueChanged?.call(prop, newVal);
          },
        ));
      }
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.enabled ? t.surfaceColor : t.controlDisabledColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: rows,
        ),
      ),
    );
  }
}

class _PropertyRow extends StatefulWidget {
  const _PropertyRow({
    super.key,
    required this.property,
    required this.tokens,
    required this.enabled,
    required this.onChanged,
  });

  final PropertyItem property;
  final DesktopTokens tokens;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  State<_PropertyRow> createState() => _PropertyRowState();
}

class _PropertyRowState extends State<_PropertyRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.property.value);
  }

  @override
  void didUpdateWidget(covariant _PropertyRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property.value != widget.property.value) {
      _controller.text = widget.property.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;

    return Container(
      height: t.controlHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: t.borderColor, width: t.borderWidth * 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
              child: Text(
                widget.property.name,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: t.foregroundColor,
                  height: 1.0,
                ),
              ),
            ),
          ),
          Container(
            width: t.borderWidth,
            color: t.borderColor,
          ),
          Expanded(
            flex: 1,
            child: widget.property.readOnly || !widget.enabled
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: t.controlPaddingX),
                    child: Text(
                      widget.property.value,
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: t.fontSize,
                        color: t.disabledForegroundColor,
                        height: 1.0,
                      ),
                    ),
                  )
                : TextField(
                    controller: _controller,
                    enabled: widget.enabled,
                    onSubmitted: widget.onChanged,
                    cursorColor: t.primaryColor,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize,
                      color: t.foregroundColor,
                      height: 1.0,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: t.controlPaddingX),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
