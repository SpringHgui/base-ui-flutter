import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/separator.dart';

/// A bordered, titled container (the WinForm-semantic counterpart of the
/// shadcn "Card"; named `GroupBox` after `System.Windows.Forms.GroupBox`).
///
/// Renders an optional title / description header, a body and an optional
/// footer separated by a hairline. The surface color, border and radius come
/// from [DesktopTokens].
class GroupBox extends StatelessWidget {
  const GroupBox({
    super.key,
    this.title,
    this.description,
    this.header,
    this.footer,
    this.padding,
    required this.child,
    this.tokens,
  });

  /// Title shown in the header.
  final String? title;

  /// Description shown under the title.
  final String? description;

  /// Custom header widget (overrides [title] / [description]).
  final Widget? header;

  /// Footer widget (e.g. action buttons), separated by a hairline.
  final Widget? footer;

  /// Inner padding; defaults to a token-derived comfortable padding.
  final EdgeInsetsGeometry? padding;

  /// Body content.
  final Widget child;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final pad = padding ??
        EdgeInsets.all(t.controlPaddingX * 1.5);

    return Container(
      decoration: BoxDecoration(
        color: t.cardColor,
        border: Border.all(color: t.borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.radiusXl),
        boxShadow: [
          BoxShadow(
            color: t.shadowColor,
            blurRadius: t.shadowBlur * 0.5,
            offset: Offset(0, t.shadowOffsetY * 0.5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null || title != null || description != null)
            Padding(
              padding: pad,
              child: header ??
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: TextStyle(
                            fontFamily: t.fontFamily,
                            fontSize: t.fontSize * 1.125,
                            fontWeight: FontWeight.w600,
                            color: t.cardForegroundColor,
                            height: 1.3,
                          ),
                        ),
                      if (description != null) ...[
                        SizedBox(height: t.compactSpacing),
                        Text(
                          description!,
                          style: TextStyle(
                            fontFamily: t.fontFamily,
                            fontSize: t.fontSize * 0.875,
                            color: t.mutedForegroundColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
            ),
          Padding(padding: pad, child: child),
          if (footer != null) ...[
            Separator(tokens: t),
            Padding(padding: pad, child: footer),
          ],
        ],
      ),
    );
  }
}
