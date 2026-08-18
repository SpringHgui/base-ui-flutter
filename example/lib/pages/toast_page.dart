import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class ToastPage extends StatelessWidget {
  const ToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'ToastHost demo',
            children: [
              Builder(
                builder: (context) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Button(
                      text: 'Show toast',
                      onPressed: () {
                        ToastHost.of(context).show(
                          const ToastData(
                            title: 'Saved',
                            description: 'Your changes have been saved.',
                          ),
                        );
                      },
                    ),
                    Button(
                      text: 'With action',
                      onPressed: () {
                        ToastHost.of(context).show(
                          ToastData(
                            title: 'File deleted',
                            description: 'It is now in the recycle bin.',
                            action: ToastAction('Undo', () {}),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const DemoSection(
            title: 'Standalone Toast widget',
            children: [
              Toast(
                title: 'Update available',
                description: 'Version 0.5.0 is ready to install.',
                icon: Icon(Icons.info_outline),
              ),
              SizedBox(height: 8),
              Toast(
                title: 'Upload complete',
                description: 'report-q3.pdf (2.4 MB)',
                icon: Icon(Icons.cloud_done),
                onDismiss: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
