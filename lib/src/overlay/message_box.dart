import 'dart:async';

import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/overlay.dart';
import '../foundation/token_scope.dart';
import '../common/button.dart';
import '../common/separator.dart';

/// Icons shown in a [MessageBox] (WinForm `MessageBoxIcon`).
enum MessageBoxType {
  /// No icon.
  none,

  /// Information.
  info,

  /// Question.
  question,

  /// Warning.
  warning,

  /// Error.
  error,
}

/// Button combinations of a [MessageBox] (WinForm `MessageBoxButtons`).
enum MessageBoxButtons {
  /// A single OK button.
  ok,

  /// OK and Cancel.
  okCancel,

  /// Yes and No.
  yesNo,

  /// Yes, No and Cancel.
  yesNoCancel,
}

/// Result of a [MessageBox] (WinForm `DialogResult`).
enum MessageBoxResult { ok, cancel, yes, no }

/// A modal message / confirmation dialog (WinForm `MessageBox`; the
/// WinForm-semantic counterpart of the shadcn "Dialog" + "AlertDialog").
///
/// Supports a generic [content] widget or a plain [message] string, an
/// optional [type] icon, and WinForm-style button sets. Use the static
/// [MessageBox.show] for a fire-and-forget alert, or the widget with
/// [trigger] / [controller] / [open] for full control.
class MessageBox extends StatefulWidget {
  const MessageBox({
    super.key,
    this.controller,
    this.trigger,
    this.open,
    this.onClose,
    this.title,
    this.message,
    this.content,
    this.type = MessageBoxType.none,
    this.buttons = MessageBoxButtons.ok,
    this.onResult,
    this.okText,
    this.cancelText,
    this.yesText,
    this.noText,
    this.width,
    this.closeOnBarrierTap = false,
    this.closeOnEscape = true,
    this.onOpenChanged,
    this.tokens,
  });

  final OverlayController? controller;
  final Widget? trigger;

  /// Controlled open state.
  final bool? open;

  /// Called when the box is dismissed without a button result
  /// (barrier / Escape).
  final VoidCallback? onClose;

  /// Title shown in the header.
  final String? title;

  /// Plain-text body.
  final String? message;

  /// Custom body widget (overrides [message]).
  final Widget? content;

  final MessageBoxType type;
  final MessageBoxButtons buttons;

  /// Called with the button result when the user activates one.
  final ValueChanged<MessageBoxResult>? onResult;

  /// Button labels; fall back to `OK` / `Cancel` / `Yes` / `No`.
  final String? okText;
  final String? cancelText;
  final String? yesText;
  final String? noText;

  /// Surface width; defaults to a token-derived size.
  final double? width;

  /// WinForm MessageBox cannot be dismissed by clicking outside.
  final bool closeOnBarrierTap;

  final bool closeOnEscape;
  final ValueChanged<bool>? onOpenChanged;
  final DesktopTokens? tokens;

  /// Shows a modal message box and completes with the result.
  static Future<MessageBoxResult> show(
    BuildContext context, {
    String? title,
    String? message,
    Widget? content,
    MessageBoxType type = MessageBoxType.none,
    MessageBoxButtons buttons = MessageBoxButtons.ok,
    String? okText,
    String? cancelText,
    String? yesText,
    String? noText,
    DesktopTokens? tokens,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final controller = OverlayController();
    final completer = Completer<MessageBoxResult>();
    late OverlayEntry entry;
    void finish(MessageBoxResult result) {
      if (completer.isCompleted) return;
      completer.complete(result);
      entry.remove();
      controller.dispose();
    }

    entry = OverlayEntry(
      builder: (ctx) => MessageBox(
        controller: controller,
        title: title,
        message: message,
        content: content,
        type: type,
        buttons: buttons,
        okText: okText,
        cancelText: cancelText,
        yesText: yesText,
        noText: noText,
        tokens: tokens,
        onResult: finish,
        onClose: () => finish(MessageBoxResult.cancel),
      ),
    );
    overlay.insert(entry);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isOpen) controller.open();
    });
    return completer.future;
  }

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  OverlayController? _internal;
  late OverlayController _controller;

  OverlayController get _effective =>
      widget.controller ?? (_internal ??= OverlayController());

  @override
  void initState() {
    super.initState();
    _controller = _effective;
    if (widget.open == true) _controller.open();
  }

  @override
  void didUpdateWidget(MessageBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = _effective;
    }
    if (widget.open != null && widget.open != _controller.isOpen) {
      widget.open! ? _controller.open() : _controller.close();
    }
  }

  @override
  void dispose() {
    _internal?.dispose();
    super.dispose();
  }

  void _choose(MessageBoxResult result) {
    // Close first: the onResult callback (e.g. the static show() completer)
    // may dispose the controller.
    _controller.close();
    widget.onResult?.call(result);
  }

  Widget _button(String text, MessageBoxResult result,
      {bool autofocus = false}) {
    return Button(
      text: text,
      autofocus: autofocus,
      onPressed: () => _choose(result),
    );
  }

  List<Widget> _buttons(DesktopTokens t) {
    final list = <Widget>[];
    void add(Widget button, {bool autofocus = false}) {
      if (list.isNotEmpty) list.add(SizedBox(width: t.compactSpacing * 2));
      list.add(button);
    }

    switch (widget.buttons) {
      case MessageBoxButtons.ok:
        // The primary (default) button receives initial focus so Enter
        // confirms without tabbing.
        add(_button(widget.okText ?? 'OK', MessageBoxResult.ok,
            autofocus: true));
      case MessageBoxButtons.okCancel:
        add(_button(widget.cancelText ?? 'Cancel', MessageBoxResult.cancel));
        add(_button(widget.okText ?? 'OK', MessageBoxResult.ok,
            autofocus: true));
      case MessageBoxButtons.yesNo:
        add(_button(widget.noText ?? 'No', MessageBoxResult.no));
        add(_button(widget.yesText ?? 'Yes', MessageBoxResult.yes,
            autofocus: true));
      case MessageBoxButtons.yesNoCancel:
        add(_button(widget.cancelText ?? 'Cancel', MessageBoxResult.cancel));
        add(_button(widget.noText ?? 'No', MessageBoxResult.no));
        add(_button(widget.yesText ?? 'Yes', MessageBoxResult.yes,
            autofocus: true));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    final icon = switch (widget.type) {
      MessageBoxType.none => null,
      MessageBoxType.info => Icons.info_outline,
      MessageBoxType.question => Icons.help_outline,
      MessageBoxType.warning => Icons.warning_amber_rounded,
      MessageBoxType.error => Icons.error_outline,
    };
    final iconColor = switch (widget.type) {
      MessageBoxType.error => t.destructiveColor,
      _ => t.primaryColor,
    };

    final overlay = ModalOverlay(
      controller: _controller,
      closeOnBarrierTap: widget.closeOnBarrierTap,
      closeOnEscape: widget.closeOnEscape,
      onOpenChanged: widget.onOpenChanged,
      content: Container(
        width: widget.width ?? t.controlHeight * 12,
        constraints: BoxConstraints(
          minWidth: t.controlHeight * 8,
          maxHeight: t.controlHeight * 16,
        ),
        decoration: BoxDecoration(
          color: t.popoverColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.radiusLg),
          boxShadow: [
            BoxShadow(
              color: t.shadowColor,
              blurRadius: t.shadowBlur,
              offset: Offset(0, t.shadowOffsetY),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(t.controlPaddingX * 1.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null || icon != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: t.fontSize * 1.6, color: iconColor),
                          SizedBox(width: t.controlPaddingX),
                        ],
                        Expanded(
                          child: Text(
                            widget.title ?? '',
                            style: TextStyle(
                              fontFamily: t.fontFamily,
                              fontSize: t.fontSize * 1.125,
                              fontWeight: FontWeight.w600,
                              color: t.foregroundColor,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if ((widget.title != null || icon != null) &&
                      (widget.message != null || widget.content != null))
                    SizedBox(height: t.compactSpacing * 1.5),
                  // Long messages scroll instead of overflowing the box.
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxHeight: t.controlHeight * 10),
                    child: SingleChildScrollView(
                      child: widget.message != null
                          ? Text(
                              widget.message!,
                              style: TextStyle(
                                fontFamily: t.fontFamily,
                                fontSize: t.fontSize,
                                color: t.mutedForegroundColor,
                                height: 1.5,
                              ),
                            )
                          : widget.content ?? const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            Separator(tokens: t),
            Padding(
              padding: EdgeInsets.all(t.controlPaddingX),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buttons(t),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.trigger == null) return overlay;
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _controller.open(),
          child: widget.trigger,
        ),
        overlay,
      ],
    );
  }
}
