import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A chat-thread scroller — the counterpart of the shadcn
/// "MessageScroller". The list is reversed (newest at the bottom, stuck to
/// it) and fires [onLoadMore] when the user scrolls near the oldest end.
class MessageScroller extends StatelessWidget {
  const MessageScroller({
    super.key,
    required this.children,
    this.height = 420,
    this.controller,
    this.onLoadMore,
    this.tokens,
  });

  /// The messages, newest last.
  final List<Widget> children;

  /// Viewport height.
  final double height;

  /// External scroll controller (optional).
  final ScrollController? controller;

  /// Called when the user scrolls close to the oldest message (load-more
  /// hook).
  final VoidCallback? onLoadMore;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: t.borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (onLoadMore != null &&
              notification.metrics.pixels >
                  notification.metrics.maxScrollExtent - 80) {
            onLoadMore!();
          }
          return false;
        },
        child: ListView.builder(
          controller: controller,
          reverse: true,
          padding: EdgeInsets.all(t.controlPaddingX),
          itemCount: children.length,
          itemBuilder: (context, index) =>
              children[children.length - 1 - index],
        ),
      ),
    );
  }
}
