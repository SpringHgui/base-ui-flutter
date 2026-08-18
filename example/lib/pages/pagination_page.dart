import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class PaginationPage extends StatefulWidget {
  const PaginationPage({super.key});

  @override
  State<PaginationPage> createState() => _PaginationPageState();
}

class _PaginationPageState extends State<PaginationPage> {
  int _page = 4;
  int _page2 = 0;

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Many pages (ellipsis)',
            children: [
              Pagination(
                pageCount: 50,
                currentPage: _page,
                onPageChanged: (p) => setState(() => _page = p),
              ),
              const SizedBox(height: 8),
              Text('Current page (0-based): $_page'),
            ],
          ),
          DemoSection(
            title: 'Few pages',
            children: [
              Pagination(
                pageCount: 5,
                currentPage: _page2,
                onPageChanged: (p) => setState(() => _page2 = p),
                showFirstLast: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
