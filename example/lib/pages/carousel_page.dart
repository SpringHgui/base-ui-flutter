import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class CarouselPage extends StatelessWidget {
  const CarouselPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = const [
      Color(0xFF4FC3F7),
      Color(0xFF81C784),
      Color(0xFFFFB74D),
      Color(0xFFBA68C8),
    ];
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoSection(
            title: 'Carousel with arrows + dots',
            children: [
              Carousel(
                children: [
                  _SlideCard(color: Color(0xFF4FC3F7), label: 'Slide 1'),
                  _SlideCard(color: Color(0xFF81C784), label: 'Slide 2'),
                  _SlideCard(color: Color(0xFFFFB74D), label: 'Slide 3'),
                  _SlideCard(color: Color(0xFFBA68C8), label: 'Slide 4'),
                ],
              ),
            ],
          ),
          DemoSection(
            title: 'Full-width pages',
            children: [
              Carousel(
                viewportFraction: 1.0,
                showDots: false,
                height: 160,
                children: [
                  for (var i = 0; i < colors.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: colors[i],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('Page ${i + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 18)),
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

class _SlideCard extends StatelessWidget {
  const _SlideCard({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 20)),
    );
  }
}
