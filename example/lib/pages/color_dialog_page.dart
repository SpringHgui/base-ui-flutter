import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [ColorDialog] widget.
class ColorDialogPage extends StatefulWidget {
  const ColorDialogPage({super.key});

  @override
  State<ColorDialogPage> createState() => _ColorDialogPageState();
}

class _ColorDialogPageState extends State<ColorDialogPage> {
  Color _selected1 = const Color(0xFF1E90FF);
  Color _selected2 = const Color(0xFFFF0000);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = DesktopTokens.winForm;
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic color dialog
          Label(l10n.t('color.inline')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 240,
                child: ColorDialog(
                  selectedColor: _selected1,
                  onConfirm: (c) => setState(() => _selected1 = c),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('color.selectedColor')),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selected1,
                      border: Border.all(color: t.borderColor),
                      borderRadius: BorderRadius.circular(t.cornerRadius),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Label('R:${(_selected1.r * 255).round()} G:${(_selected1.g * 255).round()} B:${(_selected1.b * 255).round()}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Different initial colour
          Label(l10n.t('color.different')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 240,
                child: ColorDialog(
                  selectedColor: _selected2,
                  onConfirm: (c) => setState(() => _selected2 = c),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('color.selectedColor')),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selected2,
                      border: Border.all(color: t.borderColor),
                      borderRadius: BorderRadius.circular(t.cornerRadius),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Label('R:${(_selected2.r * 255).round()} G:${(_selected2.g * 255).round()} B:${(_selected2.b * 255).round()}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Label(l10n.t('color.features')),
          const SizedBox(height: 6),
          Label(l10n.t('color.feat1')),
          Label(l10n.t('color.feat2')),
          Label(l10n.t('color.feat3')),
          Label(l10n.t('color.feat4')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
