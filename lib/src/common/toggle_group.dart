import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'toggle.dart';

/// Manages a group of [ToggleGroupItem]s with single or multiple selection.
///
/// Selection state lives in the group; each item reads it through an
/// inherited scope, so items can be nested anywhere inside the group.
class ToggleGroup<T> extends StatefulWidget {
  const ToggleGroup({
    super.key,
    required this.values,
    required this.onChanged,
    this.multiple = false,
    this.orientation = Axis.horizontal,
    this.tokens,
    required this.children,
  });

  /// Currently selected values (single- or multi-select per [multiple]).
  final List<T> values;

  /// Called with the new selection whenever it changes.
  final ValueChanged<List<T>> onChanged;

  /// When `true`, multiple items may be selected at once.
  final bool multiple;

  /// Layout direction of the items.
  final Axis orientation;

  /// Token override for the whole group.
  final DesktopTokens? tokens;

  /// The items ([ToggleGroupItem] widgets).
  final List<Widget> children;

  @override
  State<ToggleGroup<T>> createState() => _ToggleGroupState<T>();
}

class _ToggleGroupState<T> extends State<ToggleGroup<T>> {
  void _toggle(T value) {
    final values = List<T>.of(widget.values);
    if (widget.multiple) {
      if (values.contains(value)) {
        values.remove(value);
      } else {
        values.add(value);
      }
    } else {
      // Single mode (Radix semantics): the selection cannot be emptied —
      // clicking the selected item keeps it selected.
      values
        ..clear()
        ..add(value);
    }
    widget.onChanged(values);
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final scope = _ToggleGroupScope<T>(
      state: this,
      child: Wrap(
        spacing: t.compactSpacing,
        runSpacing: t.compactSpacing,
        direction: widget.orientation,
        children: widget.children,
      ),
    );
    return scope;
  }
}

class _ToggleGroupScope<T> extends InheritedWidget {
  const _ToggleGroupScope({required this.state, required super.child});

  final _ToggleGroupState<T> state;

  @override
  bool updateShouldNotify(_ToggleGroupScope<T> oldWidget) =>
      state != oldWidget.state;
}

/// An item inside a [ToggleGroup]; renders a [Toggle] bound to [value].
class ToggleGroupItem<T> extends StatelessWidget {
  const ToggleGroupItem({
    super.key,
    required this.value,
    required this.child,
    this.variant = ToggleVariant.default_,
    this.size = ToggleSize.medium,
    this.enabled = true,
    this.semanticLabel,
    this.tokens,
  });

  /// The value this item selects.
  final T value;

  /// The item content.
  final Widget child;

  final ToggleVariant variant;
  final ToggleSize size;
  final bool enabled;
  final String? semanticLabel;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ToggleGroupScope<T>>();
    assert(scope != null, 'ToggleGroupItem must be used inside a ToggleGroup');
    final group = scope!.state;
    return Toggle(
      selected: group.widget.values.contains(value),
      onChanged: (_) => group._toggle(value),
      variant: variant,
      size: size,
      enabled: enabled,
      semanticLabel: semanticLabel,
      tokens: tokens,
      child: child,
    );
  }
}
