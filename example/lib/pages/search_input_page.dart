import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SearchInputPage extends StatefulWidget {
  const SearchInputPage({super.key});

  @override
  State<SearchInputPage> createState() => _SearchInputPageState();
}

class _SearchInputPageState extends State<SearchInputPage> {
  String _lastQuery = '';
  String _submitted = '';

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(title: 'Basic', children: [
            SizedBox(
              width: 260,
              child: SearchInput(
                hintText: 'Search...',
                onChanged: (v) => setState(() => _lastQuery = v),
                onSubmitted: (v) => setState(() => _submitted = v),
              ),
            ),
            const SizedBox(height: 8),
            Label('Current: "$_lastQuery"'),
            Label('Submitted: "$_submitted"'),
          ]),
          DemoSection(title: 'Custom hint & icon', children: [
            SizedBox(
              width: 260,
              child: SearchInput(
                hintText: 'Filter tables...',
                icon: Icons.filter_list,
              ),
            ),
          ]),
          DemoSection(title: 'With clear callback', children: [
            SizedBox(
              width: 260,
              child: SearchInput(
                hintText: 'Type then clear...',
                onCleared: () => setState(() => _lastQuery = ''),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
