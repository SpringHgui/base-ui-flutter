import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [DomainUpDown] widget.
class DomainUpDownPage extends StatefulWidget {
  const DomainUpDownPage({super.key});

  @override
  State<DomainUpDownPage> createState() => _DomainUpDownPageState();
}

class _DomainUpDownPageState extends State<DomainUpDownPage> {
  int _seasonIdx = 0;
  int _dayIdx = 0;
  int _customIdx = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seasons = [l10n.t('domain.spring'), l10n.t('domain.summer'), l10n.t('domain.autumn'), l10n.t('domain.winter')];
    final days = [l10n.t('domain.monday'), l10n.t('domain.tuesday'), l10n.t('domain.wednesday'), l10n.t('domain.thursday'), l10n.t('domain.friday'), l10n.t('domain.saturday'), l10n.t('domain.sunday')];
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Basic string items
          Label(l10n.t('domain.season')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: DomainUpDown<String>(
              items: seasons,
              selectedIndex: _seasonIdx,
              onSelectedIndexChanged: (i) => setState(() => _seasonIdx = i),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('domain.seasonSelected').replaceAll('{value}', seasons[_seasonIdx]).replaceAll('{index}', '$_seasonIdx')),
          const SizedBox(height: 16),

          // 2. Days of week
          Label(l10n.t('domain.days')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: DomainUpDown<String>(
              items: days,
              selectedIndex: _dayIdx,
              onSelectedIndexChanged: (i) => setState(() => _dayIdx = i),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('domain.seasonSelected').replaceAll('{value}', days[_dayIdx]).replaceAll('{index}', '$_dayIdx')),
          const SizedBox(height: 16),

          // 3. Custom itemToString
          Label(l10n.t('domain.customToString')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: DomainUpDown<int>(
              items: List.generate(12, (i) => i + 1),
              selectedIndex: _customIdx,
              onSelectedIndexChanged: (i) => setState(() => _customIdx = i),
              itemToString: (n) => l10n.t('domain.month').replaceAll('{n}', '$n'),
            ),
          ),
          const SizedBox(height: 4),
          Label(l10n.t('domain.month').replaceAll('{n}', '${_customIdx + 1}')),
          const SizedBox(height: 16),

          // 4. Disabled
          Label(l10n.t('domain.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: DomainUpDown<String>(
              items: seasons,
              selectedIndex: 0,
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // 5. Wrapping behaviour
          Label(l10n.t('domain.wrapping')),
          const SizedBox(height: 6),
          Label(l10n.t('domain.wrappingDesc')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
