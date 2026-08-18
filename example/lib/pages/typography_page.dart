import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class TypographyPage extends StatelessWidget {
  const TypographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DemoSection(title: 'Headings', children: [
            TypeStyle.h1('h1 — The quick brown fox'),
            TypeStyle.h2('h2 — The quick brown fox'),
            TypeStyle.h3('h3 — The quick brown fox'),
            TypeStyle.h4('h4 — The quick brown fox'),
          ]),
          DemoSection(title: 'Body', children: [
            TypeStyle.p(
                'Paragraph: The quick brown fox jumps over the lazy dog. '
                'A token-driven typography scale keeps everything consistent.'),
            TypeStyle.lead('Lead — slightly larger, muted.'),
            TypeStyle.large('Large — bold-ish.'),
            TypeStyle.small('Small — 0.875 × base.'),
            TypeStyle.muted('Muted — secondary text.'),
          ]),
          DemoSection(title: 'Special', children: [
            TypeStyle.blockquote(
                'Blockquote: “To be, or not to be, that is the question.”'),
            TypeStyle.code('Inline code: final tokens = DesktopTokens.shadcn;'),
          ]),
        ],
      ),
    );
  }
}
