import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'context_menu_strip.dart';
import 'menu_strip.dart';

/// Win10 风格的输入框右键菜单。
///
/// Flutter 自带的选择工具条在 Windows 上仍画 Material 那套(圆角浮层、图标按钮),
/// 与本库的菜单不是一种风格。把它作为 `TextField.contextMenuBuilder` 传进去,
/// 就用 [ContextMenuPanel] 重绘一遍,动作仍由 [EditableTextState] 自己执行。
///
/// 与 Win10 一致的地方:剪切 / 复制 / 粘贴 / 全选恒定列出,当前做不了的置灰而
/// 不是隐藏;菜单出现在光标按下处,贴到屏幕边缘时折回。
Widget buildTextBoxContextMenu(
  BuildContext context,
  EditableTextState editable, {
  DesktopTokens? tokens,
}) {
  final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
  return CustomSingleChildLayout(
    delegate: _TextBoxMenuLayout(anchor: editable.contextMenuAnchors.primaryAnchor),
    // 粘贴项的可用性取决于剪贴板状态,而它是异步查询回来的:不重建就会一直
    // 停在「粘贴」置灰上
    child: ValueListenableBuilder<ClipboardStatus>(
      valueListenable: editable.clipboardStatus,
      builder: (menuContext, _, _) => ContextMenuPanel(
        items: textBoxContextMenuItems(menuContext, editable),
        tokens: t,
        onDismiss: editable.hideToolbar,
      ),
    ),
  );
}

/// 标准四项:当前用不了也照样列出(置灰),顺序与 Win10 的记事本一致
const List<(ContextMenuButtonType, String)> _standardItems = [
  (ContextMenuButtonType.cut, 'Ctrl+X'),
  (ContextMenuButtonType.copy, 'Ctrl+C'),
  (ContextMenuButtonType.paste, 'Ctrl+V'),
  (ContextMenuButtonType.selectAll, 'Ctrl+A'),
];

/// 无 Material 本地化时的兜底文案(测试环境或缺 delegate 时不至于渲染空行)
const Map<ContextMenuButtonType, String> _fallbackLabels = {
  ContextMenuButtonType.cut: 'Cut',
  ContextMenuButtonType.copy: 'Copy',
  ContextMenuButtonType.paste: 'Paste',
  ContextMenuButtonType.selectAll: 'Select All',
};

/// 把 [EditableTextState] 给出的按钮翻译成菜单条目。
///
/// 可见项与回调都由 `contextMenuButtonItems` 决定(它才知道只读框不能粘贴、
/// 无选区不能复制),这里只补上标签与快捷键。
@visibleForTesting
List<MenuModel> textBoxContextMenuItems(
  BuildContext context,
  EditableTextState editable,
) {
  final buttons = editable.contextMenuButtonItems;
  ContextMenuButtonItem? buttonOf(ContextMenuButtonType type) {
    for (final b in buttons) {
      if (b.type == type) return b;
    }
    return null;
  }

  final types = _standardItems.map((e) => e.$1).toSet();
  return <MenuModel>[
    for (final (type, shortcut) in _standardItems)
      MenuItem(
        text: _labelOf(context, buttonOf(type), type),
        shortcut: shortcut,
        enabled: buttonOf(type)?.onPressed != null,
        onPressed: () => buttonOf(type)?.onPressed?.call(),
      ),
    const MenuSeparator(),
    // 平台特有的其它动作(查找 / 分享 / 实时文本输入…),有标签才列出
    for (final b in buttons)
      if (!types.contains(b.type) && b.onPressed != null)
        MenuItem(
          text: _labelOf(context, b, b.type),
          onPressed: () => b.onPressed?.call(),
        ),
  ];
}

String _labelOf(
  BuildContext context,
  ContextMenuButtonItem? item,
  ContextMenuButtonType type,
) {
  if (item?.label != null) return item!.label!;
  final m = Localizations.of<MaterialLocalizations>(
      context, MaterialLocalizations);
  if (m != null) {
    switch (type) {
      case ContextMenuButtonType.cut:
        return m.cutButtonLabel;
      case ContextMenuButtonType.copy:
        return m.copyButtonLabel;
      case ContextMenuButtonType.paste:
        return m.pasteButtonLabel;
      case ContextMenuButtonType.selectAll:
        return m.selectAllButtonLabel;
      case ContextMenuButtonType.lookUp:
        return m.lookUpButtonLabel;
      case ContextMenuButtonType.searchWeb:
        return m.searchWebButtonLabel;
      case ContextMenuButtonType.share:
        return m.shareButtonLabel;
      case ContextMenuButtonType.liveTextInput:
        return m.scanTextButtonLabel;
      case ContextMenuButtonType.delete:
      case ContextMenuButtonType.custom:
        break;
    }
  }
  return _fallbackLabels[type] ?? type.name;
}

/// 左上角落在鼠标按下处,贴到屏幕右 / 下缘时折回(与 [showContextMenu] 一致)
class _TextBoxMenuLayout extends SingleChildLayoutDelegate {
  const _TextBoxMenuLayout({required this.anchor});

  final Offset anchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
        math.min(anchor.dx, math.max(0.0, size.width - childSize.width)),
        math.min(anchor.dy, math.max(0.0, size.height - childSize.height)),
      );

  @override
  bool shouldRelayout(_TextBoxMenuLayout oldDelegate) =>
      oldDelegate.anchor != anchor;
}
