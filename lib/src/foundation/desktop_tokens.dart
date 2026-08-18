import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/painting.dart' show Color;

/// Immutable design tokens that own every visual decision in base_ui_flutter.
///
/// The component core is headless: it never hard-codes colors, fonts, or
/// spacing. All visual values flow in through [DesktopTokens], so re-theming
/// an entire application is just a matter of swapping the token set (or
/// wrapping a subtree in a `TokenScope`).
///
/// The default values reproduce the classic WinForms "Control" palette:
///
/// | Role                | Value    |
/// |---------------------|----------|
/// | accent / focus      | `#0F6CBD`|
/// | form background     | `#F0F0F0`|
/// | control text        | `#000000`|
/// | control border      | `#ACACAC`|
/// | editable surface    | `#FFFFFF`|
/// | button face         | `#F0F0F0`|
/// | disabled text       | `#A0A0A0`|
///
/// ## shadcn supplement
///
/// Since 0.5.0 the token set also carries the semantic roles used by the
/// shadcn-referenced supplement components (`TypeStyle`, `Popover`,
/// `ToggleSwitch`, `GroupBox` … in `lib/src/{common,containers,overlay,…}`):
/// muted, secondary, accent, destructive, card, popover, ring, radius scale,
/// shadows and chart colors. The WinForm defaults keep those roles
/// WinForm-compatible, and the built-in [DesktopTokens.shadcn] preset
/// reproduces the shadcn "neutral" light theme so both design languages can
/// coexist in one app and be switched with a single `TokenScope`.
class DesktopTokens {
  const DesktopTokens({
    // ── Core / WinForm roles ──────────────────────────────────────────────
    this.primaryColor = const Color(0xFF0F6CBD),
    this.backgroundColor = const Color(0xFFF0F0F0),
    this.foregroundColor = const Color(0xFF000000),
    this.borderColor = const Color(0xFFACACAC),
    this.surfaceColor = const Color(0xFFFFFFFF),
    this.controlColor = const Color(0xFFF0F0F0),
    this.controlHoverColor = const Color(0xFFE1E1E1),
    this.controlPressedColor = const Color(0xFFCCCCCC),
    this.controlDisabledColor = const Color(0xFFF0F0F0),
    this.disabledForegroundColor = const Color(0xFFA0A0A0),
    this.fontFamily = 'Segoe UI',
    this.fontSize = 12.0,
    this.compactSpacing = 4.0,
    this.controlHeight = 24.0,
    this.borderWidth = 1.0,
    this.cornerRadius = 0.0,
    this.controlPaddingX = 8.0,
    // ── shadcn semantic roles ─────────────────────────────────────────────
    this.mutedColor = const Color(0xFFF0F0F0),
    this.mutedForegroundColor = const Color(0xFFA0A0A0),
    this.secondaryColor = const Color(0xFFF0F0F0),
    this.secondaryForegroundColor = const Color(0xFF000000),
    this.accentColor = const Color(0xFFE1E1E1),
    this.accentForegroundColor = const Color(0xFF000000),
    this.destructiveColor = const Color(0xFFDC2626),
    this.destructiveForegroundColor = const Color(0xFFFFFFFF),
    this.cardColor = const Color(0xFFFFFFFF),
    this.cardForegroundColor = const Color(0xFF000000),
    this.popoverColor = const Color(0xFFFFFFFF),
    this.popoverForegroundColor = const Color(0xFF000000),
    this.ringColor = const Color(0xFF0F6CBD),
    this.ringWidth = 1.0,
    this.ringOffset = 0.0,
    this.radiusLg = 0.0,
    this.radiusXl = 0.0,
    this.radiusFull = 999.0,
    this.monoFontFamily = 'Consolas',
    this.shadowColor = const Color(0x14000000),
    this.shadowBlur = 8.0,
    this.shadowOffsetY = 4.0,
    this.hoverOverlayColor = const Color(0x14000000),
    this.pressedOverlayColor = const Color(0x1F000000),
    this.disabledOpacity = 0.5,
    this.barrierColor = const Color(0x80000000),
    this.chartColors = const [
      Color(0xFF2563EB), // blue 600
      Color(0xFF10B981), // emerald 500
      Color(0xFFF59E0B), // amber 500
      Color(0xFF8B5CF6), // violet 500
      Color(0xFFEC4899), // pink 500
      Color(0xFF06B6D4), // cyan 500
      Color(0xFFF43F5E), // rose 500
    ],
  });

  /// The compact, high-density, keyboard-friendly WinForm-like preset.
  static const DesktopTokens winForm = DesktopTokens();

  /// The modern, rounded, shadcn-style "neutral" light preset.
  ///
  /// Mirrors the shadcn/ui default theme: neutral gray scale, 6 px base
  /// radius (12 px for cards), subtle shadows and a 36 px control height.
  /// Used as the fallback default by the `Sh*` components in
  /// `lib/src/shadcn/`.
  static const DesktopTokens shadcn = DesktopTokens(
    primaryColor: Color(0xFF18181B), // neutral-900
    backgroundColor: Color(0xFFFAFAFA), // neutral-50
    foregroundColor: Color(0xFF18181B), // neutral-900
    borderColor: Color(0xFFE4E4E7), // neutral-200
    surfaceColor: Color(0xFFFFFFFF),
    controlColor: Color(0xFFF4F4F5), // neutral-100
    controlHoverColor: Color(0xFFE4E4E7), // neutral-200
    controlPressedColor: Color(0xFFD4D4D8), // neutral-300
    controlDisabledColor: Color(0xFFF4F4F5),
    disabledForegroundColor: Color(0xFFA1A1AA), // neutral-400
    fontFamily: 'Segoe UI',
    fontSize: 14.0,
    compactSpacing: 4.0,
    controlHeight: 36.0,
    borderWidth: 1.0,
    cornerRadius: 6.0,
    controlPaddingX: 12.0,
    mutedColor: Color(0xFFF4F4F5),
    mutedForegroundColor: Color(0xFF71717A), // neutral-500
    secondaryColor: Color(0xFFF4F4F5),
    secondaryForegroundColor: Color(0xFF18181B),
    accentColor: Color(0xFFF4F4F5),
    accentForegroundColor: Color(0xFF18181B),
    destructiveColor: Color(0xFFEF4444), // red-500
    destructiveForegroundColor: Color(0xFFFAFAFA),
    cardColor: Color(0xFFFFFFFF),
    cardForegroundColor: Color(0xFF18181B),
    popoverColor: Color(0xFFFFFFFF),
    popoverForegroundColor: Color(0xFF18181B),
    ringColor: Color(0xFF18181B),
    ringWidth: 2.0,
    ringOffset: 2.0,
    radiusLg: 8.0,
    radiusXl: 12.0,
    radiusFull: 999.0,
    monoFontFamily: 'Consolas',
    shadowColor: Color(0x1A000000),
    shadowBlur: 16.0,
    shadowOffsetY: 4.0,
    hoverOverlayColor: Color(0x0A000000), // ~4% black
    pressedOverlayColor: Color(0x14000000), // ~8% black
    disabledOpacity: 0.5,
  );

  // ── Core / WinForm roles ────────────────────────────────────────────────

  /// Accent color: focus ring, selection, text cursor.
  final Color primaryColor;

  /// Window / form background color.
  final Color backgroundColor;

  /// Default text color.
  final Color foregroundColor;

  /// Hairline border color of controls.
  final Color borderColor;

  /// Editable surface (text box) background color.
  final Color surfaceColor;

  /// Button face color.
  final Color controlColor;

  /// Button face color while hovered.
  final Color controlHoverColor;

  /// Button face color while pressed.
  final Color controlPressedColor;

  /// Button / input face color while disabled.
  final Color controlDisabledColor;

  /// Text color while disabled.
  final Color disabledForegroundColor;

  /// Font family used by all controls. WinForms default is `Segoe UI`.
  final String fontFamily;

  /// Base font size in logical pixels (~9 pt).
  final double fontSize;

  /// Base spacing unit for compact layouts.
  final double compactSpacing;

  /// Standard height of a button or single-line input.
  final double controlHeight;

  /// Hairline border width of controls.
  final double borderWidth;

  /// Corner radius of controls (0 = square, WinForm-style).
  final double cornerRadius;

  /// Horizontal padding inside a button or input.
  final double controlPaddingX;

  // ── shadcn semantic roles ───────────────────────────────────────────────

  /// Muted surface (shadcn `muted`): subtle backgrounds, hover fills.
  final Color mutedColor;

  /// Foreground color used on [mutedColor] surfaces / secondary text.
  final Color mutedForegroundColor;

  /// Secondary surface (shadcn `secondary`): lower-emphasis buttons.
  final Color secondaryColor;

  /// Foreground color used on [secondaryColor] surfaces.
  final Color secondaryForegroundColor;

  /// Accent surface (shadcn `accent`): menu / command item highlights.
  final Color accentColor;

  /// Foreground color used on [accentColor] surfaces.
  final Color accentForegroundColor;

  /// Destructive / danger surface (shadcn `destructive`).
  final Color destructiveColor;

  /// Foreground color used on [destructiveColor] surfaces.
  final Color destructiveForegroundColor;

  /// Card surface background (shadcn `card`).
  final Color cardColor;

  /// Foreground color used on [cardColor] surfaces.
  final Color cardForegroundColor;

  /// Popover / dropdown surface background (shadcn `popover`).
  final Color popoverColor;

  /// Foreground color used on [popoverColor] surfaces.
  final Color popoverForegroundColor;

  /// Focus ring color (shadcn `ring`).
  final Color ringColor;

  /// Focus ring stroke width.
  final double ringWidth;

  /// Gap between the focused widget's edge and the focus ring.
  final double ringOffset;

  /// Large radius: dialogs, menus (shadcn `rounded-lg`).
  final double radiusLg;

  /// Extra-large radius: cards, sheets (shadcn `rounded-xl`).
  final double radiusXl;

  /// Fully-rounded radius used for pills, badges, avatars.
  final double radiusFull;

  /// Monospace font family for code, `Kbd`, and numeric fields.
  final String monoFontFamily;

  /// Drop shadow color used by popovers, menus, dialogs.
  final Color shadowColor;

  /// Drop shadow blur radius.
  final double shadowBlur;

  /// Drop shadow vertical offset.
  final double shadowOffsetY;

  /// Overlay tint applied on top of a surface while hovered. The component
  /// core blends this over the base color, so hover states stay token-driven.
  final Color hoverOverlayColor;

  /// Overlay tint applied on top of a surface while pressed.
  final Color pressedOverlayColor;

  /// Opacity applied to disabled components.
  final double disabledOpacity;

  /// Dimmed barrier behind modal overlays (dialogs / sheets / drawers).
  final Color barrierColor;

  /// Default categorical palette used by `ShChart` series.
  final List<Color> chartColors;

  /// Returns a copy of these tokens with the given fields replaced.
  DesktopTokens copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    Color? surfaceColor,
    Color? controlColor,
    Color? controlHoverColor,
    Color? controlPressedColor,
    Color? controlDisabledColor,
    Color? disabledForegroundColor,
    String? fontFamily,
    double? fontSize,
    double? compactSpacing,
    double? controlHeight,
    double? borderWidth,
    double? cornerRadius,
    double? controlPaddingX,
    Color? mutedColor,
    Color? mutedForegroundColor,
    Color? secondaryColor,
    Color? secondaryForegroundColor,
    Color? accentColor,
    Color? accentForegroundColor,
    Color? destructiveColor,
    Color? destructiveForegroundColor,
    Color? cardColor,
    Color? cardForegroundColor,
    Color? popoverColor,
    Color? popoverForegroundColor,
    Color? ringColor,
    double? ringWidth,
    double? ringOffset,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
    String? monoFontFamily,
    Color? shadowColor,
    double? shadowBlur,
    double? shadowOffsetY,
    Color? hoverOverlayColor,
    Color? pressedOverlayColor,
    double? disabledOpacity,
    Color? barrierColor,
    List<Color>? chartColors,
  }) {
    return DesktopTokens(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      controlColor: controlColor ?? this.controlColor,
      controlHoverColor: controlHoverColor ?? this.controlHoverColor,
      controlPressedColor: controlPressedColor ?? this.controlPressedColor,
      controlDisabledColor: controlDisabledColor ?? this.controlDisabledColor,
      disabledForegroundColor:
          disabledForegroundColor ?? this.disabledForegroundColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      compactSpacing: compactSpacing ?? this.compactSpacing,
      controlHeight: controlHeight ?? this.controlHeight,
      borderWidth: borderWidth ?? this.borderWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      controlPaddingX: controlPaddingX ?? this.controlPaddingX,
      mutedColor: mutedColor ?? this.mutedColor,
      mutedForegroundColor: mutedForegroundColor ?? this.mutedForegroundColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      secondaryForegroundColor:
          secondaryForegroundColor ?? this.secondaryForegroundColor,
      accentColor: accentColor ?? this.accentColor,
      accentForegroundColor: accentForegroundColor ?? this.accentForegroundColor,
      destructiveColor: destructiveColor ?? this.destructiveColor,
      destructiveForegroundColor:
          destructiveForegroundColor ?? this.destructiveForegroundColor,
      cardColor: cardColor ?? this.cardColor,
      cardForegroundColor: cardForegroundColor ?? this.cardForegroundColor,
      popoverColor: popoverColor ?? this.popoverColor,
      popoverForegroundColor:
          popoverForegroundColor ?? this.popoverForegroundColor,
      ringColor: ringColor ?? this.ringColor,
      ringWidth: ringWidth ?? this.ringWidth,
      ringOffset: ringOffset ?? this.ringOffset,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusFull: radiusFull ?? this.radiusFull,
      monoFontFamily: monoFontFamily ?? this.monoFontFamily,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
      hoverOverlayColor: hoverOverlayColor ?? this.hoverOverlayColor,
      pressedOverlayColor: pressedOverlayColor ?? this.pressedOverlayColor,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      barrierColor: barrierColor ?? this.barrierColor,
      chartColors: chartColors ?? this.chartColors,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DesktopTokens &&
          other.primaryColor == primaryColor &&
          other.backgroundColor == backgroundColor &&
          other.foregroundColor == foregroundColor &&
          other.borderColor == borderColor &&
          other.surfaceColor == surfaceColor &&
          other.controlColor == controlColor &&
          other.controlHoverColor == controlHoverColor &&
          other.controlPressedColor == controlPressedColor &&
          other.controlDisabledColor == controlDisabledColor &&
          other.disabledForegroundColor == disabledForegroundColor &&
          other.fontFamily == fontFamily &&
          other.fontSize == fontSize &&
          other.compactSpacing == compactSpacing &&
          other.controlHeight == controlHeight &&
          other.borderWidth == borderWidth &&
          other.cornerRadius == cornerRadius &&
          other.controlPaddingX == controlPaddingX &&
          other.mutedColor == mutedColor &&
          other.mutedForegroundColor == mutedForegroundColor &&
          other.secondaryColor == secondaryColor &&
          other.secondaryForegroundColor == secondaryForegroundColor &&
          other.accentColor == accentColor &&
          other.accentForegroundColor == accentForegroundColor &&
          other.destructiveColor == destructiveColor &&
          other.destructiveForegroundColor == destructiveForegroundColor &&
          other.cardColor == cardColor &&
          other.cardForegroundColor == cardForegroundColor &&
          other.popoverColor == popoverColor &&
          other.popoverForegroundColor == popoverForegroundColor &&
          other.ringColor == ringColor &&
          other.ringWidth == ringWidth &&
          other.ringOffset == ringOffset &&
          other.radiusLg == radiusLg &&
          other.radiusXl == radiusXl &&
          other.radiusFull == radiusFull &&
          other.monoFontFamily == monoFontFamily &&
          other.shadowColor == shadowColor &&
          other.shadowBlur == shadowBlur &&
          other.shadowOffsetY == shadowOffsetY &&
          other.hoverOverlayColor == hoverOverlayColor &&
          other.pressedOverlayColor == pressedOverlayColor &&
          other.disabledOpacity == disabledOpacity &&
          other.barrierColor == barrierColor &&
          listEquals(other.chartColors, chartColors);

  @override
  int get hashCode => Object.hashAll([
        primaryColor,
        backgroundColor,
        foregroundColor,
        borderColor,
        surfaceColor,
        controlColor,
        controlHoverColor,
        controlPressedColor,
        controlDisabledColor,
        disabledForegroundColor,
        fontFamily,
        fontSize,
        compactSpacing,
        controlHeight,
        borderWidth,
        cornerRadius,
        controlPaddingX,
        mutedColor,
        mutedForegroundColor,
        secondaryColor,
        secondaryForegroundColor,
        accentColor,
        accentForegroundColor,
        destructiveColor,
        destructiveForegroundColor,
        cardColor,
        cardForegroundColor,
        popoverColor,
        popoverForegroundColor,
        ringColor,
        ringWidth,
        ringOffset,
        radiusLg,
        radiusXl,
        radiusFull,
        monoFontFamily,
        shadowColor,
        shadowBlur,
        shadowOffsetY,
        hoverOverlayColor,
        pressedOverlayColor,
        disabledOpacity,
        barrierColor,
        Object.hashAll(chartColors),
      ]);
}
