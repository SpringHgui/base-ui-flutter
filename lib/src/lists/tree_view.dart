import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A node in a [TreeView].
class TreeNode<T> {
  TreeNode({
    required this.data,
    this.label,
    this.children = const [],
    this.expanded = false,
  });

  /// User data attached to this node.
  final T data;

  /// Display text. When `null`, `data.toString()` is used.
  final String? label;

  /// Child nodes.
  final List<TreeNode<T>> children;

  /// Whether this node is expanded.
  bool expanded;

  /// Whether this node has children.
  bool get hasChildren => children.isNotEmpty;
}

/// A WinForm-style tree view.
///
/// Displays a hierarchical list of [TreeNode]s with expand/collapse support.
class TreeView<T> extends StatefulWidget {
  const TreeView({
    super.key,
    required this.nodes,
    this.selectedKey,
    this.onSelectionChanged,
    this.onNodeExpanded,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.nodeToString,
    this.indent = 16.0,
    this.rowBuilder,
    this.framed = true,
  });

  /// Root-level nodes.
  final List<TreeNode<T>> nodes;

  /// The key of the currently selected node (based on `data.hashCode`).
  final int? selectedKey;

  /// Called when the user selects a node.
  final ValueChanged<int?>? onSelectionChanged;

  /// Called when a node is expanded or collapsed.
  final ValueChanged<TreeNode<T>>? onNodeExpanded;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the tree view should focus itself when first built.
  final bool autofocus;

  /// Whether the tree view is interactive.
  final bool enabled;

  /// Converts node data to a display string.
  final String Function(T)? nodeToString;

  /// Indentation per level in logical pixels.
  final double indent;

  /// Optional custom row renderer.
  ///
  /// When set, it owns the entire row content (icon, label, suffix, …) and is
  /// given the depth / selection / expand state through [TreeRowContext].
  /// The row box (height, indent, hit testing) still comes from [TreeView].
  ///
  /// A custom row also owns the **selection background**: the tree stops
  /// painting its solid primary fill, since a host that draws its own row
  /// (icon + secondary text) usually wants a tint + border instead.
  final TreeRowBuilder<T>? rowBuilder;

  /// Whether to paint the surrounding border and background.
  ///
  /// `false` lets the tree blend into a host panel that already frames it.
  final bool framed;

  @override
  State<TreeView<T>> createState() => _TreeViewState<T>();
}

/// Per-row state handed to [TreeView.rowBuilder].
class TreeRowContext<T> {
  const TreeRowContext({
    required this.node,
    required this.depth,
    required this.selected,
    required this.expanded,
    required this.hasChildren,
    required this.tokens,
    required this.toggleExpand,
  });

  /// The node being rendered.
  final TreeNode<T> node;

  /// 0-based nesting level; multiply by `TreeView.indent` to align children.
  final int depth;

  /// Whether this row is the selected one.
  final bool selected;

  /// Whether this node is currently expanded.
  final bool expanded;

  /// Whether the node has children (i.e. needs an expand affordance).
  final bool hasChildren;

  /// Design tokens, already resolved by the tree — use them instead of literals.
  final DesktopTokens tokens;

  /// Flips the node's expanded state and reports it through `onNodeExpanded`.
  final VoidCallback toggleExpand;
}

/// Renders one tree row.
typedef TreeRowBuilder<T> = Widget Function(TreeRowContext<T> context);

class _TreeViewState<T> extends State<TreeView<T>> {
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

  String _nodeLabel(TreeNode<T> node) =>
      node.label ?? widget.nodeToString?.call(node.data) ?? node.data.toString();

  void _toggleExpand(TreeNode<T> node) {
    if (!widget.enabled) return;
    setState(() {
      node.expanded = !node.expanded;
    });
    widget.onNodeExpanded?.call(node);
  }

  void _selectNode(TreeNode<T> node) {
    if (!widget.enabled) return;
    widget.onSelectionChanged?.call(node.data.hashCode);
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    // Flatten visible nodes once per build so rows can be virtualised
    // through ListView.builder (large trees no longer pay for building
    // every collapsed subtree).
    final flat = <(TreeNode<T>, int)>[];
    void visit(List<TreeNode<T>> nodes, int depth) {
      for (final node in nodes) {
        flat.add((node, depth));
        if (node.expanded && node.hasChildren) {
          visit(node.children, depth + 1);
        }
      }
    }

    visit(widget.nodes, 0);

    final tree = ListView.builder(
      itemExtent: t.controlHeight,
      padding: EdgeInsets.zero,
      itemCount: flat.length,
      itemBuilder: (context, index) {
        final (node, depth) = flat[index];
        return _buildNodeRow(node, depth, t);
      },
    );

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: !widget.framed
          ? tree
          : DecoratedBox(
              decoration: BoxDecoration(
                color: widget.enabled ? t.surfaceColor : t.controlDisabledColor,
                border: Border.all(color: t.borderColor, width: t.borderWidth),
                borderRadius: BorderRadius.circular(t.cornerRadius),
              ),
              child: tree,
            ),
    );
  }

  Widget _buildNodeRow(TreeNode<T> node, int depth, DesktopTokens t) {
    final isSelected = node.data.hashCode == widget.selectedKey;

    // GestureDetector instead of InkWell avoids per-row Material ink
    // overhead (animation controller + splash factory).
    return GestureDetector(
      onTap: () => _selectNode(node),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: t.controlHeight,
        padding: EdgeInsets.only(left: depth * widget.indent),
        color: isSelected && widget.rowBuilder == null
            ? t.primaryColor
            : Colors.transparent,
        child: widget.rowBuilder?.call(TreeRowContext(
              node: node,
              depth: depth,
              selected: isSelected,
              expanded: node.expanded,
              hasChildren: node.hasChildren,
              tokens: t,
              toggleExpand: () => _toggleExpand(node),
            )) ??
            _defaultRowContent(node, t, isSelected),
      ),
    );
  }

  Widget _defaultRowContent(TreeNode<T> node, DesktopTokens t, bool isSelected) {
    return Row(
      children: [
        if (node.hasChildren)
          GestureDetector(
            onTap: () => _toggleExpand(node),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: t.compactSpacing),
              child: Icon(
                node.expanded ? Icons.arrow_drop_down : Icons.arrow_right,
                size: t.fontSize + 4,
                color: isSelected ? t.surfaceColor : t.foregroundColor,
              ),
            ),
          )
        else
          SizedBox(width: t.fontSize + 4 + t.compactSpacing * 2),
        Expanded(
          child: Text(
            _nodeLabel(node),
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize,
              color: isSelected
                  ? t.surfaceColor
                  : (widget.enabled ? t.foregroundColor : t.disabledForegroundColor),
              height: 1.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
