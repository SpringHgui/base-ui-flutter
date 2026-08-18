import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style colour picker dialog.
///
/// Shows a grid of colour swatches and lets the user pick one. Returns the
/// selected [Color] via [onConfirm].
class ColorDialog extends StatefulWidget {
  const ColorDialog({
    super.key,
    required this.selectedColor,
    this.onConfirm,
    this.onCancel,
    this.tokens,
    this.swatchSize = 24.0,
  });

  /// The currently selected colour.
  final Color selectedColor;

  /// Called when the user confirms a colour.
  final ValueChanged<Color>? onConfirm;

  /// Called when the user cancels.
  final VoidCallback? onCancel;

  /// Token override.
  final DesktopTokens? tokens;

  /// Size of each colour swatch.
  final double swatchSize;

  @override
  State<ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog> {
  late Color _selected;

  static const _palette = <Color>[
    Color(0xFF000000), Color(0xFF808080), Color(0xFFC0C0C0), Color(0xFFFFFFFF),
    Color(0xFF800000), Color(0xFFFF0000), Color(0xFFFF6600), Color(0xFFFFCC00),
    Color(0xFFFFFF00), Color(0xFF00FF00), Color(0xFF00CC66), Color(0xFF00FFFF),
    Color(0xFF0000FF), Color(0xFF0000CC), Color(0xFFCC00FF), Color(0xFFFF00FF),
    Color(0xFF800080), Color(0xFF008080), Color(0xFF008000), Color(0xFF808000),
    Color(0xFF996633), Color(0xFF336699), Color(0xFF339966), Color(0xFF993366),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedColor;
  }

  @override
  void didUpdateWidget(covariant ColorDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the preview in sync when the parent swaps in a new initial
    // colour (e.g. ThemeDesigner reusing this dialog for another swatch).
    if (widget.selectedColor != oldWidget.selectedColor) {
      _selected = widget.selectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.controlColor,
        border: Border.all(color: t.borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.compactSpacing * 2),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview
              Container(
                height: t.controlHeight,
                decoration: BoxDecoration(
                  color: _selected,
                  border:
                      Border.all(color: t.borderColor, width: t.borderWidth),
                ),
              ),
              SizedBox(height: t.compactSpacing * 2),
              // Swatch grid
              Wrap(
                spacing: t.compactSpacing,
                runSpacing: t.compactSpacing,
                children: _palette.map((c) {
                  final isSelected = c.toARGB32() == _selected.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() => _selected = c),
                    child: Container(
                      width: widget.swatchSize,
                      height: widget.swatchSize,
                      decoration: BoxDecoration(
                        color: c,
                        border: Border.all(
                          color: isSelected ? t.primaryColor : t.borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: t.compactSpacing * 2),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _DialogButton(
                    text: 'OK',
                    tokens: t,
                    onPressed: () => widget.onConfirm?.call(_selected),
                  ),
                  SizedBox(width: t.compactSpacing),
                  _DialogButton(
                    text: 'Cancel',
                    tokens: t,
                    onPressed: widget.onCancel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.text,
    required this.tokens,
    this.onPressed,
  });

  final String text;
  final DesktopTokens tokens;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: t.controlHeight,
        padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX * 2),
        decoration: BoxDecoration(
          color: t.controlColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: t.foregroundColor,
          ),
        ),
      ),
    );
  }
}
