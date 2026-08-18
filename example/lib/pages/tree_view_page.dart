import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../l10n/app_localizations.dart';

/// Demonstrates all features of the [TreeView] widget.
class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  int? _selectedKey;
  int? _selectedKey2;

  late final List<TreeNode<String>> _projectNodes;
  late final List<TreeNode<String>> _fileNodes;

  @override
  void initState() {
    super.initState();
    _projectNodes = [
      TreeNode<String>(
        data: 'root',
        label: 'Project',
        expanded: true,
        children: [
          TreeNode<String>(
            data: 'src',
            label: 'src',
            expanded: true,
            children: [
              TreeNode(data: 'main.dart', label: 'main.dart'),
              TreeNode(data: 'utils.dart', label: 'utils.dart'),
              TreeNode<String>(
                data: 'widgets',
                label: 'widgets',
                children: [
                  TreeNode(data: 'button.dart', label: 'button.dart'),
                  TreeNode(data: 'input.dart', label: 'input.dart'),
                ],
              ),
            ],
          ),
          TreeNode<String>(
            data: 'lib',
            label: 'lib',
            expanded: true,
            children: [
              TreeNode(data: 'base_ui.dart', label: 'base_ui.dart'),
            ],
          ),
          TreeNode(data: 'README.md', label: 'README.md'),
          TreeNode(data: 'pubspec.yaml', label: 'pubspec.yaml'),
        ],
      ),
    ];

    _fileNodes = [
      TreeNode<String>(
        data: 'documents',
        label: 'Documents',
        expanded: true,
        children: [
          TreeNode<String>(
            data: 'work',
            label: 'Work',
            children: [
              TreeNode(data: 'report.pdf', label: 'report.pdf'),
              TreeNode(data: 'presentation.pptx', label: 'presentation.pptx'),
            ],
          ),
          TreeNode<String>(
            data: 'personal',
            label: 'Personal',
            expanded: true,
            children: [
              TreeNode(data: 'notes.txt', label: 'notes.txt'),
              TreeNode(data: 'todo.md', label: 'todo.md'),
            ],
          ),
        ],
      ),
      TreeNode<String>(
        data: 'downloads',
        label: 'Downloads',
        children: [
          TreeNode(data: 'image.png', label: 'image.png'),
          TreeNode(data: 'archive.zip', label: 'archive.zip'),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Project tree
          Label(l10n.t('treeview.project')),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                height: 200,
                child: TreeView<String>(
                  nodes: _projectNodes,
                  selectedKey: _selectedKey,
                  onSelectionChanged: (k) => setState(() => _selectedKey = k),
                  onNodeExpanded: (node) {},
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(l10n.t('treeview.selectedNode')),
                  Label('  ${_selectedKey ?? l10n.t('treeview.none')}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. File explorer tree
          Label(l10n.t('treeview.fileExplorer')),
          const SizedBox(height: 6),
          SizedBox(
            width: 250,
            height: 200,
            child: TreeView<String>(
              nodes: _fileNodes,
              selectedKey: _selectedKey2,
              onSelectionChanged: (k) => setState(() => _selectedKey2 = k),
              onNodeExpanded: (node) {},
              indent: 20.0,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Disabled
          Label(l10n.t('treeview.disabled')),
          const SizedBox(height: 6),
          SizedBox(
            width: 250,
            height: 120,
            child: TreeView<String>(
              nodes: _projectNodes,
              enabled: false,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
