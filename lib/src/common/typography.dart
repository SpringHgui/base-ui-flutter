import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// Typographic building blocks (h1–h4, paragraphs, lead, muted, code…).
///
/// Renamed from the shadcn "Typography" to `TypeStyle` because `Typography`
/// collides with the Material widget of the same name — consistent with the
/// library's `WinListView` / `WinToolTip` precedent.
///
/// All sizes and colors are derived from [DesktopTokens] — the base
/// [DesktopTokens.fontSize] scales the whole hierarchy, so switching token
/// sets re-typesets every heading at once. No font, size or color is
/// hard-coded in this widget.
class TypeStyle extends StatelessWidget {
  const TypeStyle.h1(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.h1;

  const TypeStyle.h2(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.h2;

  const TypeStyle.h3(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.h3;

  const TypeStyle.h4(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.h4;

  const TypeStyle.p(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.paragraph;

  const TypeStyle.lead(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.lead;

  const TypeStyle.large(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.large;

  const TypeStyle.small(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.small;

  const TypeStyle.muted(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.muted;

  const TypeStyle.blockquote(
    this.text, {
    super.key,
    this.textAlign,
    this.tokens,
  }) : variant = TypeStyleVariant.blockquote;

  const TypeStyle.code(this.text, {super.key, this.textAlign, this.tokens})
      : variant = TypeStyleVariant.code;

  /// The text to display.
  final String text;

  final TextAlign? textAlign;

  /// The variant of this typographic element.
  final TypeStyleVariant variant;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final base = t.fontSize;
    final fg = t.foregroundColor;

    TextStyle style() {
      switch (variant) {
        case TypeStyleVariant.h1:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base * 2.0,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: fg,
          );
        case TypeStyleVariant.h2:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base * 1.5,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: fg,
          );
        case TypeStyleVariant.h3:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base * 1.25,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: fg,
          );
        case TypeStyleVariant.h4:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base * 1.125,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: fg,
          );
        case TypeStyleVariant.paragraph:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: fg,
          );
        case TypeStyleVariant.lead:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base * 1.25,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: t.mutedForegroundColor,
          );
        case TypeStyleVariant.large:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base * 1.125,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: fg,
          );
        case TypeStyleVariant.small:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base * 0.875,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: fg,
          );
        case TypeStyleVariant.muted:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base * 0.875,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: t.mutedForegroundColor,
          );
        case TypeStyleVariant.blockquote:
          return TextStyle(
            fontFamily: t.fontFamily,
            fontSize: base,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: fg,
          );
        case TypeStyleVariant.code:
          return TextStyle(
            fontFamily: t.monoFontFamily,
            fontSize: base * 0.875,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: fg,
          );
      }
    }

    if (variant == TypeStyleVariant.blockquote) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: t.borderColor, width: t.borderWidth * 3),
          ),
        ),
        padding: EdgeInsets.only(left: t.compactSpacing * 2),
        child: Text(text, textAlign: textAlign, style: style()),
      );
    }

    if (variant == TypeStyleVariant.code) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.compactSpacing,
          vertical: t.compactSpacing * 0.5,
        ),
        decoration: BoxDecoration(
          color: t.mutedColor,
          borderRadius: BorderRadius.circular(t.cornerRadius * 0.75),
        ),
        child: Text(text, textAlign: textAlign, style: style()),
      );
    }

    return Text(text, textAlign: textAlign, style: style());
  }
}

/// Variants of [TypeStyle].
enum TypeStyleVariant {
  h1,
  h2,
  h3,
  h4,
  paragraph,
  lead,
  large,
  small,
  muted,
  blockquote,
  code,
}
