import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/icon_button.dart';

/// A dialog window shell: title bar (title + close button) + body + optional
/// footer. The WinForm/WinUI-semantic counterpart of a fixed-border modal
/// `Form` shown via `ShowDialog()`.
///
/// Renders only the dialog chrome; modal behaviour (barrier, Escape, typed
/// result) stays with the caller, e.g. Flutter's `showDialog`:
///
/// ```dart
/// showDialog<void>(
///   context: context,
///   builder: (_) => DialogBox(
///     title: 'Options',
///     onClose: () => Navigator.of(context).pop(),
///     footer: Row(...buttons...),
///     child: ...body...,
///   ),
/// );
/// ```
///
/// The shell shrink-wraps to its content (like Material's [Dialog] via
/// [IntrinsicWidth] / [IntrinsicHeight]), while the [child] is laid out
/// loose-fit inside the shell column — an `Expanded` / scrollable body
/// fills the remaining height instead of stretching the dialog. All
/// visuals flow from [DesktopTokens]: the title bar uses the surface
/// color, the body the window background, and no outer border is drawn
/// (flat WinForm style, no `Material` shadow).
class DialogBox extends StatelessWidget {
  const DialogBox({
    super.key,
    required this.title,
    this.child,
    this.footer,
    this.onClose,
    this.width,
    this.height,
    this.insetPadding = 40.0,
    this.tokens,
  });

  /// Title text shown in the title bar.
  final String title;

  /// Body content.
  final Widget? child;

  /// Optional bottom area, usually a row of buttons. Rendered under the
  /// body without extra chrome (no background / separator line).
  final Widget? footer;

  /// When non-null, a close icon button is shown at the title bar's end.
  final VoidCallback? onClose;

  /// Surface width.
  final double? width;

  /// Fixed body height; when null the body sizes to its content.
  final double? height;

  /// Empty space kept between the dialog and the screen edges (like
  /// Material `Dialog.insetPadding`). Also caps the dialog size so it never
  /// fills the whole screen.
  final double insetPadding;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    // Size of the enclosing route/screen; a raw showDialog route bounds
    // the builder's widget by the full screen.
    final screenSize = MediaQuery.sizeOf(context);

    final titleBar = Container(
      height: t.controlHeight + t.compactSpacing * 2,
      color: t.surfaceColor,
      padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize,
              fontWeight: FontWeight.w600,
              color: t.foregroundColor,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          if (onClose != null)
            IconBtn(
              icon: Icons.close,
              iconSize: t.fontSize + 2,
              onTap: onClose,
              tokens: t,
            ),
        ],
      ),
    );

    Widget? body = child;
    if (body != null) {
      if (height != null) body = SizedBox(height: height, child: body);
      // Loose fit: content shorter than the route keeps the dialog tight,
      // while Expanded / scrollable bodies can fill the remaining height.
      body = Flexible(child: body);
    }

    // Shrink-wrap like Material's Dialog: IntrinsicHeight lets the shell
    // size to its content while Flexible children still receive the bounded
    // remaining height during layout. Without it a raw showDialog route
    // (bounded only by the screen) would stretch the dialog to full size.
    //
    // Center + ConstrainedBox mirror Material's `Dialog`: a raw showDialog
    // route imposes TIGHT full-screen constraints on the builder's widget,
    // which would force this shell (IntrinsicWidth included) to fill the
    // whole screen. Center re-loosens the constraints, and the margin keeps
    // the dialog from hugging the screen edges.
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenSize.width - 2 * insetPadding,
          maxHeight: screenSize.height - 2 * insetPadding,
        ),
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            // Outside any Material (e.g. a raw showDialog route) text would
            // inherit app-level decorations; give the dialog a clean baseline.
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: t.foregroundColor,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
              // Transparent Material host: base-ui inputs embed Material
              // primitives (TextField) that require a Material ancestor; a
              // raw showDialog route has none (same as overlay.dart).
              child: Material(
                type: MaterialType.transparency,
                child: SizedBox(
                  width: width,
                  child: Container(
                    color: t.backgroundColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        titleBar,
                        if (body != null) body,
                        if (footer != null)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: t.controlPaddingX,
                              vertical: t.compactSpacing * 2,
                            ),
                            child: footer!,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
