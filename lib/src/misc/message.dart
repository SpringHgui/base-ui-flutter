import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'avatar.dart';
import 'bubble.dart';

/// A single chat message: avatar + sender / time meta + [Bubble] +
/// optional action buttons — the counterpart of the shadcn "Message".
class Message extends StatelessWidget {
  const Message({
    super.key,
    this.sender,
    this.time,
    this.avatar,
    this.text,
    this.bubble,
    this.isMine = false,
    this.actions,
    this.maxWidth = 320,
    this.tokens,
  });

  /// Sender name shown above the bubble.
  final String? sender;

  /// Timestamp text shown next to the sender.
  final String? time;

  /// Leading avatar; defaults to an [Avatar] with the sender's initial.
  final Widget? avatar;

  /// Bubble text (ignored when [bubble] is provided).
  final String? text;

  /// Custom bubble content.
  final Widget? bubble;

  final bool isMine;
  final List<Widget>? actions;
  final double maxWidth;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final avatar = this.avatar ??
        Avatar(
          fallback: sender == null || sender!.isEmpty ? '?' : sender![0],
          size: t.controlHeight * 1.4,
          tokens: t,
        );

    final column = Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sender != null || time != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: t.compactSpacing),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sender != null)
                  Text(
                    sender!,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize * 0.75,
                      fontWeight: FontWeight.w600,
                      color: t.mutedForegroundColor,
                    ),
                  ),
                if (time != null) ...[
                  SizedBox(width: t.compactSpacing),
                  Text(
                    time!,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize * 0.7,
                      color: t.mutedForegroundColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        SizedBox(height: t.compactSpacing * 0.5),
        bubble ??
            Bubble(
              text: text,
              isMine: isMine,
              maxWidth: maxWidth,
              tokens: t,
            ),
        if (actions != null && actions!.isNotEmpty) ...[
          SizedBox(height: t.compactSpacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!,
          ),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.compactSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isMine ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Padding(
            padding: EdgeInsets.only(right: t.compactSpacing),
            child: avatar,
          ),
          Expanded(child: column),
        ],
      ),
    );
  }
}
