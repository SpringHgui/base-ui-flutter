import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

/// Wraps an example page so the user can toggle between the live preview
/// and the page's Dart source code, with a one-click copy button.
class CodeExampleView extends StatefulWidget {
  const CodeExampleView({super.key, required this.assetPath, required this.child});

  /// Path of the source file within the asset bundle, e.g.
  /// `lib/pages/button_page.dart`.
  final String assetPath;
  final Widget child;

  @override
  State<CodeExampleView> createState() => _CodeExampleViewState();
}

class _CodeExampleViewState extends State<CodeExampleView> {
  bool _showCode = false;
  Future<String>? _sourceFuture;

  Future<String> _loadSource() {
    return _sourceFuture ??= rootBundle.loadString(widget.assetPath);
  }

  Future<void> _copySource(AppLocalizations l10n) async {
    final source = await _loadSource();
    await Clipboard.setData(ClipboardData(text: source));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('code.copied')), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_showCode)
              TextButton.icon(
                onPressed: () => _copySource(l10n),
                icon: const Icon(Icons.copy, size: 16),
                label: Text(l10n.t('code.copy')),
              ),
            TextButton.icon(
              onPressed: () => setState(() => _showCode = !_showCode),
              icon: Icon(_showCode ? Icons.visibility : Icons.code, size: 16),
              label: Text(_showCode ? l10n.t('code.viewPreview') : l10n.t('code.viewSource')),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(child: _showCode ? _buildCodeView() : widget.child),
      ],
    );
  }

  Widget _buildCodeView() {
    return FutureBuilder<String>(
      future: _loadSource(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              snapshot.data!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Color(0xFFD4D4D4),
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }
}
