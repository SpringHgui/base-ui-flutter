import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class CheckRowPage extends StatefulWidget {
  const CheckRowPage({super.key});

  @override
  State<CheckRowPage> createState() => _CheckRowPageState();
}

class _CheckRowPageState extends State<CheckRowPage> {
  late List<CheckOption> _options;

  @override
  void initState() {
    super.initState();
    _options = [
      CheckOption(id: 'mysql', label: 'MySQL', selected: true, leading: const Icon(Icons.storage, size: 14), onToggle: () => _toggle('mysql')),
      CheckOption(id: 'pg', label: 'PostgreSQL', selected: false, leading: const Icon(Icons.storage, size: 14), onToggle: () => _toggle('pg')),
      CheckOption(id: 'sqlite', label: 'SQLite', selected: true, leading: const Icon(Icons.storage, size: 14), onToggle: () => _toggle('sqlite')),
      CheckOption(id: 'mssql', label: 'SQL Server', selected: false, leading: const Icon(Icons.storage, size: 14), onToggle: () => _toggle('mssql')),
    ];
  }

  void _toggle(String id) {
    setState(() {
      final i = _options.indexWhere((o) => o.id == id);
      if (i >= 0) {
        _options[i] = CheckOption(
          id: _options[i].id,
          label: _options[i].label,
          leading: _options[i].leading,
          selected: !_options[i].selected,
          onToggle: _options[i].onToggle,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(title: 'Basic list', children: [
            SizedBox(
              width: 220,
              child: Column(
                children: [
                  for (final opt in _options) CheckRow(option: opt),
                ],
              ),
            ),
          ]),
          DemoSection(title: 'With trailing widget', children: [
            SizedBox(
              width: 260,
              child: Column(
                children: [
                  CheckRow(
                    option: CheckOption(id: 'a', label: 'MySQL', selected: true, onToggle: () {}),
                    trailing: Tag('Connected'),
                  ),
                  CheckRow(
                    option: CheckOption(id: 'b', label: 'Oracle', selected: false, onToggle: () {}),
                    trailing: Tag('Not implemented', variant: TagVariant.outline),
                  ),
                  CheckRow(
                    option: CheckOption(id: 'c', label: 'MongoDB', selected: false, onToggle: () {}),
                    trailing: Tag('Beta', variant: TagVariant.secondary),
                  ),
                ],
              ),
            ),
          ]),
          DemoSection(title: 'Disabled', children: [
            SizedBox(
              width: 220,
              child: CheckRow(
                option: CheckOption(id: 'd', label: 'Unavailable option', selected: false, onToggle: () {}),
                enabled: false,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
