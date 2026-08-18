import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [BindingNavigator] widget.
class BindingNavigatorPage extends StatefulWidget {
  const BindingNavigatorPage({super.key});

  @override
  State<BindingNavigatorPage> createState() => _BindingNavigatorPageState();
}

class _BindingNavigatorPageState extends State<BindingNavigatorPage> {
  int _index = 0;
  final _data = <String>[];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final l10n = AppLocalizations.of(context);
    for (var i = 1; i <= 5; i++) {
      _data.add(l10n.t('binding.record').replaceAll('{n}', '$i'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic navigator
          Label(l10n.t('binding.demo')),
          const SizedBox(height: 6),
          BindingNavigator(
            currentIndex: _index,
            totalCount: _data.length,
            onFirst: () => setState(() => _index = 0),
            onPrevious: () => setState(() { if (_index > 0) _index--; }),
            onNext: () => setState(() { if (_index < _data.length - 1) _index++; }),
            onLast: () => setState(() => _index = _data.length - 1),
            onAdd: () => setState(() {
              _data.add(l10n.t('binding.record').replaceAll('{n}', '${_data.length + 1}'));
              _index = _data.length - 1;
            }),
            onDelete: () => setState(() {
              if (_data.length > 1) {
                _data.removeAt(_index);
                if (_index >= _data.length) _index = _data.length - 1;
              }
            }),
          ),
          const SizedBox(height: 8),
          Label(l10n.t('binding.current').replaceAll('{value}', _data[_index]).replaceAll('{index}', '${_index + 1}').replaceAll('{total}', '${_data.length}')),
          const SizedBox(height: 16),

          Label(l10n.t('binding.features')),
          const SizedBox(height: 6),
          Label(l10n.t('binding.feat1')),
          Label(l10n.t('binding.feat2')),
          Label(l10n.t('binding.feat3')),
          Label(l10n.t('binding.feat4')),
          Label(l10n.t('binding.feat5')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
