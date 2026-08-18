import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';

/// A file-attachment chip: name + optional size + optional remove button —
/// the counterpart of the shadcn "Attachment".
class Attachment extends StatelessWidget {
  const Attachment({
    super.key,
    required this.name,
    this.sizeText,
    this.icon,
    this.onTap,
    this.onRemove,
    this.tokens,
  });

  /// File name.
  final String name;

  /// Optional size / meta text (e.g. `2.4 MB`).
  final String? sizeText;

  /// Optional leading icon (defaults to a paperclip).
  final Widget? icon;

  /// Called when the chip is activated.
  final VoidCallback? onTap;

  /// When provided, a close button is shown that invokes this callback.
  final VoidCallback? onRemove;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Surface(
      tokens: t,
      onTap: onTap,
      hoverColor: t.mutedColor,
      borderColor: t.borderColor,
      constraints: BoxConstraints(minHeight: t.controlHeight),
      padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX * 0.8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(
              size: t.fontSize * 1.2,
              color: t.mutedForegroundColor,
            ),
            child: icon ?? const Icon(Icons.attach_file),
          ),
          SizedBox(width: t.compactSpacing * 1.5),
          Text(
            name,
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize * 0.875,
              fontWeight: FontWeight.w500,
              color: t.foregroundColor,
              height: 1.2,
            ),
          ),
          if (sizeText != null) ...[
            SizedBox(width: t.compactSpacing),
            Text(
              sizeText!,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize * 0.75,
                color: t.mutedForegroundColor,
                height: 1.2,
              ),
            ),
          ],
          if (onRemove != null) ...[
            SizedBox(width: t.compactSpacing * 1.5),
            GestureDetector(
              onTap: onRemove,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Icon(
                  Icons.close,
                  size: t.fontSize * 1.1,
                  color: t.mutedForegroundColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
