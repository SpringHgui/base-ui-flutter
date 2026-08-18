import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class AccordionPage extends StatelessWidget {
  const AccordionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'Single open',
            children: [
              Accordion(
                items: [
                  AccordionItem(
                    value: 'one',
                    title: 'Is it accessible?',
                    child: Text(
                        'Yes. It adheres to keyboard-first interaction '
                        'and semantic labeling.'),
                  ),
                  AccordionItem(
                    value: 'two',
                    title: 'Is it token-driven?',
                    child: Text(
                        'Yes. Every visual value comes from DesktopTokens.'),
                  ),
                  AccordionItem(
                    value: 'three',
                    title: 'Can I re-theme it?',
                    child: Text(
                        'Yes. Swap the token set or wrap a TokenScope.'),
                  ),
                ],
              ),
            ],
          ),
          const DemoSection(
            title: 'Multiple open',
            children: [
              Accordion(
                type: AccordionType.multiple,
                initialOpen: ['a'],
                items: [
                  AccordionItem(value: 'a', title: 'First', child: Text('First body')),
                  AccordionItem(value: 'b', title: 'Second', child: Text('Second body')),
                  AccordionItem(value: 'c', title: 'Third', child: Text('Third body')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
