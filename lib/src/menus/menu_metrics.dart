import 'dart:math' as math;

import '../foundation/desktop_tokens.dart';

/// 菜单 / 浮层面板的紧凑尺寸令牌。
///
/// 菜单类浮层(右键菜单、顶部菜单下拉、工具条下拉、命令面板…)在视觉上要比
/// 通用控件紧凑一档 —— 对齐 Win10 / Navicat 菜单:行高约 22px、字号约 12px、
/// 左右内边距约 8px、面板上下留白约 3px,而不是沿用工具栏按钮那套偏大的档位
/// ([DesktopTokens] 默认 `controlHeight 28 / fontSize 13 / controlPaddingX 12 /
/// compactSpacing 4`)。
///
/// 取法用 **min 上限** 而非"相对减一档",有两个好处:
/// 1. **幂等**:菜单可以嵌套(子菜单会再取一次本函数),`min` 保证二级子菜单
///    不会比一级再小一档 —— 老的"减一档 + clamp"写法会让层级越深越袖珍;
/// 2. 语义直白:菜单尺寸**永不超过**这个紧凑档;用户若把主题字号 / 行高调得
///    更小(如字号 11),菜单保持用户的更小值、不会被"补大"。
///
/// 只收紧尺寸类令牌(字号 / 行高 / 内边距 / 间距),**不碰任何颜色令牌** ——
/// 菜单面色(secondaryColor)、边框色都由调用方 / 主题决定。
DesktopTokens menuPanelTokens(DesktopTokens t) => t.copyWith(
      fontSize: math.min(t.fontSize, 12.0),
      controlHeight: math.min(t.controlHeight, 22.0),
      controlPaddingX: math.min(t.controlPaddingX, 8.0),
      compactSpacing: math.min(t.compactSpacing, 3.0),
    );
