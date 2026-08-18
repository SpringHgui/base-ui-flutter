import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class SkeletonPage extends StatelessWidget {
  const SkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Card skeleton',
            children: [
              GroupBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Skeleton(width: 40, height: 40, radius: 999),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Skeleton(width: 180, height: 14),
                              SizedBox(height: 8),
                              Skeleton(width: 120, height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Skeleton(height: 14),
                    SizedBox(height: 8),
                    Skeleton(height: 14),
                    SizedBox(height: 8),
                    Skeleton(width: 240, height: 14),
                  ],
                ),
              ),
            ],
          ),
          DemoSection(
            title: 'List skeleton',
            children: [
              Column(
                children: [
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Skeleton(width: 36, height: 36, radius: 999),
                          SizedBox(width: 12),
                          Expanded(
                            child: Skeleton(
                              height: 12,
                              width: 120 + (i % 3) * 60.0,
                            ),
                          ),
                        ],
                      ),
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
