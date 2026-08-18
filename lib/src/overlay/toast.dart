import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A transient notification card (the counterpart of the shadcn "Toast").
///
/// Render one directly, or use a [ToastHost] + [ToastHost.of] to stack
/// auto-dismissing toasts above the app.
class Toast extends StatelessWidget {
  const Toast({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.action,
    this.onDismiss,
    this.tokens,
  });

  final String? title;
  final String? description;
  final Widget? icon;

  /// Optional action button (label + callback).
  final ToastAction? action;

  /// Called when the toast's close button is tapped.
  final VoidCallback? onDismiss;

  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Container(
      width: 320,
      padding: EdgeInsets.all(t.controlPaddingX),
      decoration: BoxDecoration(
        color: t.popoverColor,
        border: Border.all(color: t.borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius),
        boxShadow: [
          BoxShadow(
            color: t.shadowColor,
            blurRadius: t.shadowBlur,
            offset: Offset(0, t.shadowOffsetY),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: t.fontSize * 1.3, color: t.primaryColor),
              child: icon!,
            ),
            SizedBox(width: t.controlPaddingX * 0.6),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize,
                      fontWeight: FontWeight.w600,
                      color: t.foregroundColor,
                      height: 1.3,
                    ),
                  ),
                if (description != null) ...[
                  if (title != null) SizedBox(height: t.compactSpacing * 0.5),
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
                if (action != null) ...[
                  SizedBox(height: t.compactSpacing),
                  GestureDetector(
                    onTap: action!.onTap,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        action!.label,
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: t.fontSize * 0.875,
                          fontWeight: FontWeight.w600,
                          color: t.primaryColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: EdgeInsets.only(left: t.compactSpacing),
                  child: Icon(
                    Icons.close,
                    size: t.fontSize * 1.1,
                    color: t.mutedForegroundColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// An action shown inside a [Toast].
class ToastAction {
  const ToastAction(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
}

/// Data for a toast queued by a [ToastHost].
class ToastData {
  const ToastData({
    this.title,
    this.description,
    this.icon,
    this.action,
    this.duration = const Duration(seconds: 4),
  });

  final String? title;
  final String? description;
  final Widget? icon;
  final ToastAction? action;

  /// How long the toast stays visible before auto-dismissing.
  final Duration duration;
}

/// Hosts a stack of auto-dismissing toasts above its child (the counterpart
/// of shadcn's toast provider).
///
/// ```dart
/// ToastHost(
///   child: MyApp(),
/// )
/// // anywhere below:
/// ToastHost.of(context).show(ToastData(title: 'Saved', description: '…'));
/// ```
class ToastHost extends StatefulWidget {
  const ToastHost({
    super.key,
    this.alignment = Alignment.topRight,
    this.tokens,
    required this.child,
  });

  /// Where the toast stack is anchored (top-right by default).
  final Alignment alignment;

  final DesktopTokens? tokens;
  final Widget child;

  /// Returns the nearest [ToastHostState] (to call `show`).
  static ToastHostState of(BuildContext context) {
    final state =
        context.findAncestorStateOfType<ToastHostState>();
    assert(state != null, 'ToastHost.of() called without a ToastHost ancestor');
    return state!;
  }

  @override
  State<ToastHost> createState() => ToastHostState();
}

class ToastHostState extends State<ToastHost> {
  final List<ToastData> _toasts = [];

  /// Queues a toast; it auto-dismisses after [ToastData.duration].
  void show(ToastData data) {
    setState(() => _toasts.add(data));
    Future.delayed(data.duration, () {
      if (!mounted) return;
      setState(() => _toasts.remove(data));
    });
  }

  void _dismiss(ToastData data) {
    setState(() => _toasts.remove(data));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    return Stack(
      children: [
        widget.child,
        if (_toasts.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: widget.alignment,
                child: Padding(
                  padding: EdgeInsets.all(t.controlPaddingX * 1.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final data in _toasts.reversed) ...[
                        IgnorePointer(
                          ignoring: false,
                          child: _ToastEntry(
                            key: ObjectKey(data),
                            data: data,
                            tokens: t,
                            onDismiss: () => _dismiss(data),
                          ),
                        ),
                        SizedBox(height: t.compactSpacing),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToastEntry extends StatelessWidget {
  const _ToastEntry({
    super.key,
    required this.data,
    required this.tokens,
    required this.onDismiss,
  });

  final ToastData data;
  final DesktopTokens tokens;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * -12),
          child: child,
        ),
      ),
      child: Toast(
        title: data.title,
        description: data.description,
        icon: data.icon,
        action: data.action,
        onDismiss: onDismiss,
        tokens: tokens,
      ),
    );
  }
}
