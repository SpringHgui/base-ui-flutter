import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [PropertyGrid] widget.
class PropertyGridPage extends StatefulWidget {
  const PropertyGridPage({super.key});

  @override
  State<PropertyGridPage> createState() => _PropertyGridPageState();
}

class _PropertyGridPageState extends State<PropertyGridPage> {
  late List<PropertyItem> _props;
  late List<PropertyItem> _props2;

  @override
  void initState() {
    super.initState();
    _props = [
      PropertyItem(name: 'Name', category: 'Appearance', value: 'MyControl', description: 'The control name'),
      PropertyItem(name: 'BackColor', category: 'Appearance', value: '#F0F0F0', description: 'Background colour'),
      PropertyItem(name: 'ForeColor', category: 'Appearance', value: '#333333', description: 'Foreground colour'),
      PropertyItem(name: 'Font', category: 'Appearance', value: 'Microsoft YaHei, 9pt', description: 'Font settings'),
      PropertyItem(name: 'Enabled', category: 'Behaviour', value: 'true', description: 'Whether interactive'),
      PropertyItem(name: 'Visible', category: 'Behaviour', value: 'true', description: 'Whether visible'),
      PropertyItem(name: 'Text', category: 'Behaviour', value: 'Click me', readOnly: true, description: 'Display text (read-only)'),
      PropertyItem(name: 'Tag', category: 'Data', value: '', description: 'User-defined data'),
    ];

    _props2 = [
      PropertyItem(name: 'Width', category: 'Layout', value: '800', description: 'Control width'),
      PropertyItem(name: 'Height', category: 'Layout', value: '600', description: 'Control height'),
      PropertyItem(name: 'Dock', category: 'Layout', value: 'Fill', readOnly: true, description: 'Dock mode'),
      PropertyItem(name: 'Anchor', category: 'Layout', value: 'Top, Left', description: 'Anchor edges'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Full property grid
          Label(l10n.t('propgrid.controlProps')),
          const SizedBox(height: 6),
          SizedBox(
            width: 450,
            height: 250,
            child: PropertyGrid(
              properties: _props,
              onValueChanged: (prop, val) {
                setState(() => prop.value = val);
              },
            ),
          ),
          const SizedBox(height: 16),

          // 2. Layout properties
          Label(l10n.t('propgrid.layoutProps')),
          const SizedBox(height: 6),
          SizedBox(
            width: 400,
            height: 180,
            child: PropertyGrid(
              properties: _props2,
              onValueChanged: (prop, val) {
                setState(() => prop.value = val);
              },
            ),
          ),
          const SizedBox(height: 16),

          // 3. Disabled
          Label(l10n.t('propgrid.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 400,
            height: 140,
            child: PropertyGrid(
              properties: _props2,
              enabled: false,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
