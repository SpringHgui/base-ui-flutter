import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/button.dart';
import '../common/check_box.dart';
import '../common/input.dart';
import '../common/label.dart';
import '../common/numeric_up_down.dart';
import '../common/radio_button.dart';
import '../misc/progress_bar.dart';
import '../misc/scrollable_control.dart';
import 'color_dialog.dart';

// ===========================================================================
// ThemeDesigner
// ===========================================================================

/// A WinForm-style theme designer panel.
///
/// Provides a floating, non-modal panel that lets the user edit every
/// [DesktopTokens] property with real-time preview. Supports built-in preset
/// themes, Dart code export, and JSON import / export.
class ThemeDesigner extends StatefulWidget {
  const ThemeDesigner({
    super.key,
    required this.tokens,
    this.onTokensChanged,
    this.onConfirm,
    this.onCancel,
    this.width = 600,
    this.height = 460,
  });

  /// The current token set being edited.
  final DesktopTokens tokens;

  /// Called whenever any token property changes (live preview).
  final ValueChanged<DesktopTokens>? onTokensChanged;

  /// Called when the user clicks OK.
  final ValueChanged<DesktopTokens>? onConfirm;

  /// Called when the user closes the panel.
  final VoidCallback? onCancel;

  /// Panel width in logical pixels.
  final double width;

  /// Panel height in logical pixels.
  final double height;

  @override
  State<ThemeDesigner> createState() => _ThemeDesignerState();
}

class _ThemeDesignerState extends State<ThemeDesigner> {
  late DesktopTokens _tokens;
  DesktopTokens? _originalTokens;
  String? _editingColorProp;

  static const _tabNames = [
    'Colors',
    'Typography',
    'Size',
    'Presets',
    'Export / Import',
  ];
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tokens = widget.tokens;
  }

  @override
  void didUpdateWidget(covariant ThemeDesigner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tokens != oldWidget.tokens && _originalTokens == null) {
      _tokens = widget.tokens;
    }
  }

  void _updateTokens(DesktopTokens next) {
    setState(() => _tokens = next);
    widget.onTokensChanged?.call(next);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = _tokens;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TokenScope(
        tokens: t,
        child: Container(
          decoration: BoxDecoration(
            color: t.backgroundColor,
            border: Border.all(color: t.borderColor, width: t.borderWidth),
            borderRadius: BorderRadius.circular(t.cornerRadius),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(children: [_buildHeader(t), Expanded(child: _buildBody(t))]),
        ),
      ),
    );
  }

  // ── Header bar ──────────────────────────────────────────────────────────

  Widget _buildHeader(DesktopTokens t) {
    return Container(
      height: t.controlHeight,
      decoration: BoxDecoration(
        color: t.controlColor,
        border: Border(bottom: BorderSide(color: t.borderColor, width: t.borderWidth)),
      ),
      padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
      child: Row(children: [
        const Expanded(child: Label('Theme Designer')),
        GestureDetector(
          onTap: widget.onCancel,
          child: Icon(Icons.close, size: t.fontSize + 2, color: t.foregroundColor),
        ),
      ]),
    );
  }

  // ── Body (tabs + editor + preview) ──────────────────────────────────────

  Widget _buildBody(DesktopTokens t) {
    return Column(children: [
      // Tab bar
      Container(
        height: t.controlHeight,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.borderColor, width: t.borderWidth)),
        ),
        child: LayoutBuilder(builder: (context, bc) {
          final tabWidth = bc.maxWidth / _tabNames.length;
          return Row(children: [
            for (int i = 0; i < _tabNames.length; i++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _tab = i;
                    _editingColorProp = null;
                  });
                },
                child: Container(
                  width: tabWidth,
                  height: t.controlHeight,
                  decoration: BoxDecoration(
                    color: _tab == i ? t.surfaceColor : t.controlColor,
                    border: Border(
                      bottom: BorderSide(
                        color: _tab == i ? t.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _tabNames[i],
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize,
                      color: _tab == i ? t.primaryColor : t.foregroundColor,
                    ),
                  ),
                ),
              ),
          ]);
        }),
      ),
      // Content
      Expanded(
        child: Row(children: [
          SizedBox(width: widget.width * 0.48, child: _buildEditor(t)),
          Expanded(child: _PreviewPanel(tokens: _tokens)),
        ]),
      ),
      // Footer
      Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.borderColor, width: t.borderWidth)),
        ),
        padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX, vertical: t.compactSpacing),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Button(
            text: 'OK',
            tokens: t,
            onPressed: () => widget.onConfirm?.call(_tokens),
          ),
          SizedBox(width: t.compactSpacing),
          Button(
            text: 'Cancel',
            tokens: t,
            onPressed: widget.onCancel,
          ),
        ]),
      ),
    ]);
  }

  // ── Editor panel (switches per tab) ─────────────────────────────────────

  Widget _buildEditor(DesktopTokens t) {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: t.borderColor, width: t.borderWidth)),
      ),
      child: ScrollableControl(
        child: Padding(
          padding: EdgeInsets.all(t.controlPaddingX),
          child: _editingColorProp != null
              ? _buildColorEditor(t)
              : switch (_tab) {
                  0 => _buildColorSwatches(t),
                  1 => _buildTypographyEditor(t),
                  2 => _buildSizeEditor(t),
                  3 => _buildPresetsTab(t),
                  4 => _buildExportImportTab(t),
                  _ => const SizedBox.shrink(),
                },
        ),
      ),
    );
  }

  // ── Colors tab: swatch grid ─────────────────────────────────────────────

  Widget _buildColorSwatches(DesktopTokens t) {
    final colors = <String, Color>{
      'Primary': t.primaryColor,
      'Background': t.backgroundColor,
      'Foreground': t.foregroundColor,
      'Border': t.borderColor,
      'Surface': t.surfaceColor,
      'Control BG': t.controlColor,
      'Ctrl Hover': t.controlHoverColor,
      'Ctrl Pressed': t.controlPressedColor,
      'Ctrl Disabled': t.controlDisabledColor,
      'Disabled FG': t.disabledForegroundColor,
    };
    final swatchSize = 36.0;
    final gap = t.compactSpacing;
    final labelStyle = TextStyle(
      fontFamily: t.fontFamily,
      fontSize: t.fontSize - 1,
      color: t.foregroundColor,
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Label('Click a colour swatch to edit'),
      SizedBox(height: gap),
      Wrap(
        spacing: gap * 2,
        runSpacing: gap * 2,
        children: [
          for (final entry in colors.entries)
            GestureDetector(
              onTap: () {
                setState(() {
                  _originalTokens = _tokens;
                  _editingColorProp = entry.key;
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Tooltip(
                  message: '${entry.key}: ${_ThemeCodecs.colorToHex(entry.value)}',
                  child: SizedBox(
                    width: 68,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: swatchSize,
                          height: swatchSize,
                          decoration: BoxDecoration(
                            color: entry.value,
                            border: Border.all(color: t.borderColor, width: t.borderWidth),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(entry.key, style: labelStyle, textAlign: TextAlign.center, maxLines: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ]);
  }

  // ── Color editor (shown when a swatch is clicked) ───────────────────────

  Widget _buildColorEditor(DesktopTokens t) {
    final prop = _editingColorProp!;
    final current = _colorForProp(prop);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        GestureDetector(
          onTap: () => setState(() => _editingColorProp = null),
          child: Icon(Icons.arrow_back, size: t.fontSize + 2, color: t.primaryColor),
        ),
        SizedBox(width: t.compactSpacing),
        Label('Edit $prop'),
      ]),
      SizedBox(height: t.compactSpacing),
      SizedBox(
        width: double.infinity,
        child: ColorDialog(
          // Rebuild the dialog for each property so its internal preview
          // state starts from the correct colour.
          key: ValueKey(prop),
          selectedColor: current,
          onConfirm: (c) {
            _setColorProp(prop, c);
            _originalTokens = null;
            setState(() => _editingColorProp = null);
          },
          onCancel: () {
            if (_originalTokens != null) _updateTokens(_originalTokens!);
            _originalTokens = null;
            setState(() => _editingColorProp = null);
          },
        ),
      ),
    ]);
  }

  // ── Typography tab ──────────────────────────────────────────────────────

  Widget _buildTypographyEditor(DesktopTokens t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Label('Font Family'),
      SizedBox(height: t.compactSpacing),
      Input(
        tokens: t,
        hint: t.fontFamily,
        onChanged: (v) => _updateTokens(t.copyWith(fontFamily: v)),
      ),
      SizedBox(height: t.controlHeight),
      const Label('Font Size'),
      SizedBox(height: t.compactSpacing),
      SizedBox(
        width: 120,
        child: NumericUpDown(
          value: t.fontSize,
          min: 6,
          max: 32,
          step: 1,
          decimals: 0,
          tokens: t,
          onChanged: (v) => _updateTokens(t.copyWith(fontSize: v)),
        ),
      ),
      SizedBox(height: t.controlHeight),
      const Label('Preview'),
      SizedBox(height: t.compactSpacing),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(t.compactSpacing),
        decoration: BoxDecoration(
          color: t.surfaceColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
        ),
        child: Text(
          'The quick brown fox jumps over the lazy dog',
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: t.foregroundColor,
          ),
        ),
      ),
    ]);
  }

  // ── Size tab ────────────────────────────────────────────────────────────

  Widget _buildSizeEditor(DesktopTokens t) {
    Widget row(String label, double value, double min, double max, double step,
        int decimals, DesktopTokens Function(double) builder) {
      return Padding(
        padding: EdgeInsets.only(bottom: t.controlHeight),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Label(label),
          SizedBox(height: t.compactSpacing),
          SizedBox(
            width: 120,
            child: NumericUpDown(
              value: value,
              min: min,
              max: max,
              step: step,
              decimals: decimals,
              tokens: t,
              onChanged: (v) => _updateTokens(builder(v)),
            ),
          ),
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      row('Control Height', t.controlHeight, 16, 48, 1, 0, (v) => t.copyWith(controlHeight: v)),
      row('Compact Spacing', t.compactSpacing, 0, 16, 1, 0, (v) => t.copyWith(compactSpacing: v)),
      row('Border Width', t.borderWidth, 0, 4, 0.5, 1, (v) => t.copyWith(borderWidth: v)),
      row('Corner Radius', t.cornerRadius, 0, 24, 1, 0, (v) => t.copyWith(cornerRadius: v)),
      row('Control Padding X', t.controlPaddingX, 0, 24, 1, 0, (v) => t.copyWith(controlPaddingX: v)),
    ]);
  }

  // ── Presets tab ─────────────────────────────────────────────────────────

  Widget _buildPresetsTab(DesktopTokens t) {
    final presets = _ThemePresets.all;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Label('Select a preset theme'),
      SizedBox(height: t.compactSpacing * 2),
      for (final preset in presets)
        Padding(
          padding: EdgeInsets.only(bottom: t.compactSpacing),
          child: GestureDetector(
            onTap: () => _updateTokens(preset.tokens),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(t.compactSpacing * 2),
                decoration: BoxDecoration(
                  color: preset.tokens.backgroundColor,
                  border: Border.all(color: t.borderColor, width: t.borderWidth),
                  borderRadius: BorderRadius.circular(t.cornerRadius),
                ),
                child: Row(children: [
                  // Colour preview dots
                  for (final c in [
                    preset.tokens.primaryColor,
                    preset.tokens.foregroundColor,
                    preset.tokens.controlColor,
                    preset.tokens.borderColor,
                  ])
                    Padding(
                      padding: EdgeInsets.only(right: t.compactSpacing),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: c,
                          border: Border.all(color: const Color(0xFF808080)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  SizedBox(width: t.controlPaddingX),
                  Text(
                    preset.name,
                    style: TextStyle(
                      fontFamily: preset.tokens.fontFamily,
                      fontSize: preset.tokens.fontSize,
                      color: preset.tokens.foregroundColor,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }

  // ── Export / Import tab ─────────────────────────────────────────────────

  Widget _buildExportImportTab(DesktopTokens t) {
    return _ExportImportTab(tokens: _tokens, onImport: _updateTokens);
  }

  // ── Token property helpers ──────────────────────────────────────────────

  Color _colorForProp(String prop) => switch (prop) {
        'Primary' => _tokens.primaryColor,
        'Background' => _tokens.backgroundColor,
        'Foreground' => _tokens.foregroundColor,
        'Border' => _tokens.borderColor,
        'Surface' => _tokens.surfaceColor,
        'Control BG' => _tokens.controlColor,
        'Ctrl Hover' => _tokens.controlHoverColor,
        'Ctrl Pressed' => _tokens.controlPressedColor,
        'Ctrl Disabled' => _tokens.controlDisabledColor,
        'Disabled FG' => _tokens.disabledForegroundColor,
        _ => const Color(0xFF000000),
      };

  void _setColorProp(String prop, Color c) {
    _updateTokens(switch (prop) {
      'Primary' => _tokens.copyWith(primaryColor: c),
      'Background' => _tokens.copyWith(backgroundColor: c),
      'Foreground' => _tokens.copyWith(foregroundColor: c),
      'Border' => _tokens.copyWith(borderColor: c),
      'Surface' => _tokens.copyWith(surfaceColor: c),
      'Control BG' => _tokens.copyWith(controlColor: c),
      'Ctrl Hover' => _tokens.copyWith(controlHoverColor: c),
      'Ctrl Pressed' => _tokens.copyWith(controlPressedColor: c),
      'Ctrl Disabled' => _tokens.copyWith(controlDisabledColor: c),
      'Disabled FG' => _tokens.copyWith(disabledForegroundColor: c),
      _ => _tokens,
    });
  }
}

// ===========================================================================
// _PreviewPanel
// ===========================================================================

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.tokens});
  final DesktopTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return TokenScope(
      tokens: t,
      child: Container(
        color: t.backgroundColor,
        padding: EdgeInsets.all(t.controlPaddingX * 2),
        child: ScrollableControl(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Label('Preview'),
            SizedBox(height: t.controlHeight),
            // Buttons
            const Label('Buttons'),
            SizedBox(height: t.compactSpacing),
            Wrap(spacing: t.compactSpacing, children: [
              Button(text: 'Normal', tokens: t),
              Button(text: 'Disabled', tokens: t, onPressed: null),
            ]),
            SizedBox(height: t.controlHeight),
            // Input
            const Label('Input'),
            SizedBox(height: t.compactSpacing),
            SizedBox(width: 200, child: Input(hint: 'Sample text', tokens: t)),
            SizedBox(height: t.controlHeight),
            // Check & Radio
            Row(mainAxisSize: MainAxisSize.min, children: [
              CheckBox(value: true, onChanged: (_) {}, label: 'Check', tokens: t),
              SizedBox(width: t.controlPaddingX * 2),
              RadioButton<bool>(value: true, groupValue: true, onChanged: (_) {}, label: 'Radio', tokens: t),
            ]),
            SizedBox(height: t.controlHeight),
            // ProgressBar
            const Label('ProgressBar'),
            SizedBox(height: t.compactSpacing),
            SizedBox(width: 200, child: ProgressBar(value: 65, tokens: t)),
            SizedBox(height: t.controlHeight * 2),
          ]),
        ),
      ),
    );
  }
}

// ===========================================================================
// _ExportImportTab
// ===========================================================================

class _ExportImportTab extends StatefulWidget {
  const _ExportImportTab({required this.tokens, required this.onImport});
  final DesktopTokens tokens;
  final ValueChanged<DesktopTokens> onImport;

  @override
  State<_ExportImportTab> createState() => _ExportImportTabState();
}

class _ExportImportTabState extends State<_ExportImportTab> {
  final _jsonController = TextEditingController();
  String _generatedCode = '';
  String _generatedJson = '';
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  @override
  void didUpdateWidget(covariant _ExportImportTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tokens != oldWidget.tokens) _regenerate();
  }

  void _regenerate() {
    _generatedCode = _ThemeCodecs.generateDartCode(widget.tokens);
    _generatedJson = _ThemeCodecs.generateJson(widget.tokens);
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t =
        TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Dart code ──
      const Label('Dart Code'),
      SizedBox(height: t.compactSpacing),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(t.compactSpacing),
        decoration: BoxDecoration(
          color: t.surfaceColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
        ),
        child: SelectableText(
          _generatedCode,
          style: TextStyle(
            fontFamily: 'Consolas',
            fontSize: t.fontSize - 1,
            color: t.foregroundColor,
          ),
        ),
      ),
      SizedBox(height: t.compactSpacing),
      Button(
        text: 'Copy Code',
        tokens: t,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: _generatedCode));
          setState(() => _feedback = 'Code copied!');
        },
      ),
      SizedBox(height: t.controlHeight),
      // ── JSON ──
      const Label('JSON'),
      SizedBox(height: t.compactSpacing),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(t.compactSpacing),
        decoration: BoxDecoration(
          color: t.surfaceColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
        ),
        child: SelectableText(
          _generatedJson,
          style: TextStyle(
            fontFamily: 'Consolas',
            fontSize: t.fontSize - 1,
            color: t.foregroundColor,
          ),
        ),
      ),
      SizedBox(height: t.compactSpacing),
      Row(mainAxisSize: MainAxisSize.min, children: [
        Button(
          text: 'Copy JSON',
          tokens: t,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _generatedJson));
            setState(() => _feedback = 'JSON copied!');
          },
        ),
        SizedBox(width: t.compactSpacing),
        Button(
          text: 'Import JSON',
          tokens: t,
          onPressed: () {
            final text = _jsonController.text.trim();
            if (text.isNotEmpty) {
              final parsed = _ThemeCodecs.fromJson(text);
              if (parsed != null) {
                widget.onImport(parsed);
                setState(() => _feedback = 'Imported!');
              } else {
                setState(() => _feedback = 'Invalid JSON!');
              }
            }
          },
        ),
      ]),
      SizedBox(height: t.compactSpacing),
      const Label('Paste JSON to import:'),
      SizedBox(height: t.compactSpacing),
      SizedBox(
        width: double.infinity,
        child: TextField(
          controller: _jsonController,
          maxLines: 4,
          cursorColor: t.primaryColor,
          style: TextStyle(
            fontFamily: 'Consolas',
            fontSize: t.fontSize - 1,
            color: t.foregroundColor,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(t.compactSpacing),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: t.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: t.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: t.primaryColor),
            ),
          ),
        ),
      ),
      if (_feedback != null) ...[
        SizedBox(height: t.compactSpacing),
        Label(_feedback!),
      ],
    ]);
  }
}

// ===========================================================================
// _ThemeCodecs — colour helpers & serialisation
// ===========================================================================

class _ThemeCodecs {
  static String colorToHex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

  static Color _colorFromHex(String hex) {
    var h = hex.replaceAll('#', '').replaceAll('0x', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  // ── Dart code generation ──────────────────────────────────────────────

  static String generateDartCode(DesktopTokens t) {
    String c(Color color) => 'Color(0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()})';
    return 'DesktopTokens(\n'
        '  primaryColor: ${c(t.primaryColor)},\n'
        '  backgroundColor: ${c(t.backgroundColor)},\n'
        '  foregroundColor: ${c(t.foregroundColor)},\n'
        '  borderColor: ${c(t.borderColor)},\n'
        '  surfaceColor: ${c(t.surfaceColor)},\n'
        '  controlColor: ${c(t.controlColor)},\n'
        '  controlHoverColor: ${c(t.controlHoverColor)},\n'
        '  controlPressedColor: ${c(t.controlPressedColor)},\n'
        '  controlDisabledColor: ${c(t.controlDisabledColor)},\n'
        '  disabledForegroundColor: ${c(t.disabledForegroundColor)},\n'
        "  fontFamily: '${t.fontFamily}',\n"
        '  fontSize: ${t.fontSize},\n'
        '  compactSpacing: ${t.compactSpacing},\n'
        '  controlHeight: ${t.controlHeight},\n'
        '  borderWidth: ${t.borderWidth},\n'
        '  cornerRadius: ${t.cornerRadius},\n'
        '  controlPaddingX: ${t.controlPaddingX},\n'
        ')';
  }

  // ── JSON ──────────────────────────────────────────────────────────────

  static String generateJson(DesktopTokens t) {
    final map = {
      'primaryColor': colorToHex(t.primaryColor),
      'backgroundColor': colorToHex(t.backgroundColor),
      'foregroundColor': colorToHex(t.foregroundColor),
      'borderColor': colorToHex(t.borderColor),
      'surfaceColor': colorToHex(t.surfaceColor),
      'controlColor': colorToHex(t.controlColor),
      'controlHoverColor': colorToHex(t.controlHoverColor),
      'controlPressedColor': colorToHex(t.controlPressedColor),
      'controlDisabledColor': colorToHex(t.controlDisabledColor),
      'disabledForegroundColor': colorToHex(t.disabledForegroundColor),
      'fontFamily': t.fontFamily,
      'fontSize': t.fontSize,
      'compactSpacing': t.compactSpacing,
      'controlHeight': t.controlHeight,
      'borderWidth': t.borderWidth,
      'cornerRadius': t.cornerRadius,
      'controlPaddingX': t.controlPaddingX,
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static DesktopTokens? fromJson(String jsonStr) {
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      Color c(String key) => _colorFromHex(map[key] as String);
      return DesktopTokens(
        primaryColor: c('primaryColor'),
        backgroundColor: c('backgroundColor'),
        foregroundColor: c('foregroundColor'),
        borderColor: c('borderColor'),
        surfaceColor: c('surfaceColor'),
        controlColor: c('controlColor'),
        controlHoverColor: c('controlHoverColor'),
        controlPressedColor: c('controlPressedColor'),
        controlDisabledColor: c('controlDisabledColor'),
        disabledForegroundColor: c('disabledForegroundColor'),
        fontFamily: map['fontFamily'] as String,
        fontSize: (map['fontSize'] as num).toDouble(),
        compactSpacing: (map['compactSpacing'] as num).toDouble(),
        controlHeight: (map['controlHeight'] as num).toDouble(),
        borderWidth: (map['borderWidth'] as num).toDouble(),
        cornerRadius: (map['cornerRadius'] as num).toDouble(),
        controlPaddingX: (map['controlPaddingX'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }
}

// ===========================================================================
// Preset themes
// ===========================================================================

class _ThemePreset {
  const _ThemePreset(this.name, this.tokens);
  final String name;
  final DesktopTokens tokens;
}

class _ThemePresets {
  static const all = <_ThemePreset>[
    _ThemePreset('WinForm (Default)', DesktopTokens.winForm),
    _ThemePreset('Light', _light),
    _ThemePreset('Dark', _dark),
    _ThemePreset('High Contrast', _highContrast),
    _ThemePreset('Ant Design 6.0', _antd),
    _ThemePreset('shadcn/ui', _shadcn),
    _ThemePreset('VS Code', _vscode),
  ];

  static const _light = DesktopTokens(
    primaryColor: Color(0xFF0078D4),
    backgroundColor: Color(0xFFFAFAFA),
    foregroundColor: Color(0xFF1A1A1A),
    borderColor: Color(0xFFD1D1D1),
    surfaceColor: Color(0xFFFFFFFF),
    controlColor: Color(0xFFF5F5F5),
    controlHoverColor: Color(0xFFEBEBEB),
    controlPressedColor: Color(0xFFE0E0E0),
    controlDisabledColor: Color(0xFFF5F5F5),
    disabledForegroundColor: Color(0xFFA6A6A6),
    cornerRadius: 4.0,
  );

  static const _dark = DesktopTokens(
    primaryColor: Color(0xFF4CC2FF),
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Color(0xFFD4D4D4),
    borderColor: Color(0xFF3F3F3F),
    surfaceColor: Color(0xFF2D2D2D),
    controlColor: Color(0xFF333333),
    controlHoverColor: Color(0xFF3C3C3C),
    controlPressedColor: Color(0xFF484848),
    controlDisabledColor: Color(0xFF2D2D2D),
    disabledForegroundColor: Color(0xFF666666),
  );

  static const _highContrast = DesktopTokens(
    primaryColor: Color(0xFFFFFF00),
    backgroundColor: Color(0xFF000000),
    foregroundColor: Color(0xFFFFFFFF),
    borderColor: Color(0xFFFFFFFF),
    surfaceColor: Color(0xFF000000),
    controlColor: Color(0xFF000000),
    controlHoverColor: Color(0xFF1C1C1C),
    controlPressedColor: Color(0xFF333333),
    controlDisabledColor: Color(0xFF000000),
    disabledForegroundColor: Color(0xFF808080),
    borderWidth: 2.0,
  );

  // Ant Design 6.0 default seed tokens (colorPrimary/colorBorder/borderRadius…).
  static const _antd = DesktopTokens(
    primaryColor: Color(0xFF1677FF),
    backgroundColor: Color(0xFFF5F5F5),
    foregroundColor: Color(0xFF262626),
    borderColor: Color(0xFFD9D9D9),
    surfaceColor: Color(0xFFFFFFFF),
    controlColor: Color(0xFFFFFFFF),
    controlHoverColor: Color(0xFFE6F4FF),
    controlPressedColor: Color(0xFFBAE0FF),
    controlDisabledColor: Color(0xFFF5F5F5),
    disabledForegroundColor: Color(0xFFBFBFBF),
    fontSize: 14.0,
    compactSpacing: 8.0,
    controlHeight: 32.0,
    cornerRadius: 6.0,
    controlPaddingX: 15.0,
  );

  // shadcn/ui default (zinc) theme seed tokens.
  static const _shadcn = DesktopTokens(
    primaryColor: Color(0xFF18181B),
    backgroundColor: Color(0xFFFFFFFF),
    foregroundColor: Color(0xFF09090B),
    borderColor: Color(0xFFE4E4E7),
    surfaceColor: Color(0xFFFFFFFF),
    controlColor: Color(0xFFF4F4F5),
    controlHoverColor: Color(0xFFE4E4E7),
    controlPressedColor: Color(0xFFD4D4D8),
    controlDisabledColor: Color(0xFFF4F4F5),
    disabledForegroundColor: Color(0xFF71717A),
    fontFamily: 'Microsoft YaHei',
    fontSize: 14.0,
    compactSpacing: 8.0,
    controlHeight: 36.0,
    cornerRadius: 6.0,
    controlPaddingX: 16.0,
  );

  // VS Code default (Dark+) theme seed tokens.
  static const _vscode = DesktopTokens(
    primaryColor: Color(0xFF007ACC),
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Color(0xFFD4D4D4),
    borderColor: Color(0xFF454545),
    surfaceColor: Color(0xFF3C3C3C),
    controlColor: Color(0xFF0E639C),
    controlHoverColor: Color(0xFF1177BB),
    controlPressedColor: Color(0xFF0D5789),
    controlDisabledColor: Color(0xFF2D2D2D),
    disabledForegroundColor: Color(0xFF6A6A6A),
    fontSize: 13.0,
    controlHeight: 28.0,
    cornerRadius: 2.0,
    controlPaddingX: 14.0,
  );
}
