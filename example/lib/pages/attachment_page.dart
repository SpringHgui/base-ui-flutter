import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class AttachmentPage extends StatefulWidget {
  const AttachmentPage({super.key});

  @override
  State<AttachmentPage> createState() => _AttachmentPageState();
}

class _AttachmentPageState extends State<AttachmentPage> {
  final List<String> _files = ['report-q3.pdf', 'budget.xlsx', 'logo.png'];

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'File chips (removable)',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final file in _files)
                    Attachment(
                      name: file,
                      sizeText: '${file.length * 37} KB',
                      onRemove: () => setState(() => _files.remove(file)),
                    ),
                ],
              ),
            ],
          ),
          const DemoSection(
            title: 'Custom icon',
            children: [
              Wrap(
                spacing: 8,
                children: [
                  Attachment(
                    name: 'interview.mp4',
                    icon: Icon(Icons.movie),
                    onRemove: null,
                  ),
                  Attachment(
                    name: 'notes.txt',
                    icon: Icon(Icons.description),
                    onRemove: null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
