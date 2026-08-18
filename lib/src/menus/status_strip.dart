import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

/// A single panel inside a [StatusStrip].
class StatusStripPanel {
  const StatusStripPanel({
    required this.text,
    this.width,
    this.flex,
    this.alignment = Alignment.centerLeft,
    this.border = true,
  });

  /// Text displayed in the panel.
  final String text;

  /// Fixed width in logical pixels. When set, [flex] is ignored.
  final double? width;

  /// Flex factor for proportional sizing. Ignored when [width] is set.
  final int? flex;

  /// Text alignment within the panel.
  final Alignment alignment;

  /// Whether to draw a right-side separator border.
  final bool border;
}

// ---------------------------------------------------------------------------
// StatusStrip
// ---------------------------------------------------------------------------

/// A WinForm-style status bar.
///
/// Renders a horizontal strip of [StatusStripPanel]s at the bottom of a
/// layout. All visual values are driven by [DesktopTokens].
class StatusStrip extends StatelessWidget {
  const StatusStrip({
    super.key,
    required this.panels,
    this.tokens,
  });

  /// The panels displayed left-to-right.
  final List<StatusStripPanel> panels;

  /// Token override.
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.controlColor,
        border: Border(
          top: BorderSide(color: t.borderColor, width: t.borderWidth),
        ),
      ),
      child: SizedBox(
        height: t.controlHeight,
        child: Row(
          children: _buildPanels(t),
        ),
      ),
    );
  }

  List<Widget> _buildPanels(DesktopTokens t) {
    final widgets = <Widget>[];
    for (var i = 0; i < panels.length; i++) {
      final panel = panels[i];
      final isLast = i == panels.length - 1;

      Widget child = Container(
        padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
        alignment: panel.alignment,
        decoration: BoxDecoration(
          border: panel.border && !isLast
              ? Border(
                  right: BorderSide(
                      color: t.borderColor, width: t.borderWidth),
                )
              : null,
        ),
        child: Text(
          panel.text,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: t.foregroundColor,
            height: 1.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );

      if (panel.width != null) {
        child = SizedBox(width: panel.width, child: child);
      } else {
        child = Expanded(flex: panel.flex ?? 1, child: child);
      }

      widgets.add(child);
    }
    return widgets;
  }
}
