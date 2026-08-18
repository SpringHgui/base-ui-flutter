import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A labeled form control: [FieldLabel] + control + optional description /
/// error message, laid out as one vertical unit.
///
/// Mirrors the shadcn "Field" composition, but named to fit this library's
/// taxonomy (no Material collision). Everything is token-driven.
class Field extends StatelessWidget {
  const Field({
    super.key,
    this.label,
    this.description,
    this.error,
    this.required = false,
    this.requiredLabel,
    this.children,
    this.tokens,
  });

  /// Label text shown above the control.
  final String? label;

  /// Helper text shown below the control.
  final String? description;

  /// Error text shown below the control (overrides [description] visually).
  final String? error;

  /// Marks the label with an asterisk when `true`.
  final bool required;

  /// Screen-reader text for the required marker; defaults to `*`.
  final String? requiredLabel;

  /// The form control(s).
  final List<Widget>? children;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          FieldLabel(
            label!,
            required: required,
            requiredLabel: requiredLabel,
            tokens: t,
          ),
          SizedBox(height: t.compactSpacing * 1.25),
        ],
        ...?children,
        if (error != null) ...[
          SizedBox(height: t.compactSpacing),
          FieldError(error!, tokens: t),
        ] else if (description != null) ...[
          SizedBox(height: t.compactSpacing),
          FieldDescription(description!, tokens: t),
        ],
      ],
    );
  }
}

/// Label text of a [Field].
class FieldLabel extends StatelessWidget {
  const FieldLabel(
    this.text, {
    super.key,
    this.required = false,
    this.requiredLabel,
    this.tokens,
  });

  final String text;
  final bool required;

  /// Screen-reader text for the required marker; defaults to `*`.
  final String? requiredLabel;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize * 0.875,
            fontWeight: FontWeight.w500,
            color: t.foregroundColor,
            height: 1.2,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          Semantics(
            label: requiredLabel ?? '*',
            child: Text(
              '*',
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize * 0.875,
                fontWeight: FontWeight.w500,
                color: t.destructiveColor,
                height: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Helper text below a form control.
class FieldDescription extends StatelessWidget {
  const FieldDescription(this.text, {super.key, this.tokens});

  final String text;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Text(
      text,
      style: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: t.fontSize * 0.875,
        color: t.mutedForegroundColor,
        height: 1.3,
      ),
    );
  }
}

/// Neutral message text below a form control.
class FieldMessage extends StatelessWidget {
  const FieldMessage(this.text, {super.key, this.tokens});

  final String text;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Text(
      text,
      style: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: t.fontSize * 0.875,
        color: t.foregroundColor,
        height: 1.3,
      ),
    );
  }
}

/// Error text below a form control, in the destructive color.
class FieldError extends StatelessWidget {
  const FieldError(this.text, {super.key, this.tokens});

  final String text;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Text(
      text,
      style: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: t.fontSize * 0.875,
        color: t.destructiveColor,
        height: 1.3,
      ),
    );
  }
}
