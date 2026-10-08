import 'dart:math' as math;

import '../foundation/desktop_tokens.dart';

/// 表格 / 属性面板单元格的紧凑尺寸令牌。
///
/// 通用控件档([DesktopTokens.winForm])是「按钮的量」:`controlHeight 28 /
/// fontSize 13 / controlPaddingX 12`。设计器网格与属性面板要的是另一档 ——
/// 参考工具(Navicat 表设计器,200% 缩放下按设备像素实测再折半)的真实值是
/// **行高 20.5 / 字号 12 / 单元格水平留白 5 / 属性字段高 19.5 / 属性行距 26**,
/// 沿用通用档会让每格都鼓出一个框,整页像表单而不像表格。
///
/// 与 menuPanelTokens(菜单档)同一条约定:用 **min 上限**而非「减一档」,
/// 因此幂等(宿主重复套一次不会越缩越小),且用户把主题字号调得更小时
/// 保持用户的更小值,不会被「补大」。只收紧尺寸类令牌,**不碰颜色**。
///
/// 用法:把整块区域包进 `TokenScope(tokens: gridCellTokens(t))`,
/// 区域内的 `Input` / `ComboBox` 自动落到这一档;勾选框方框不随行高缩放,
/// 由宿主用 `CheckBox.size` 钉死。
DesktopTokens gridCellTokens(DesktopTokens t) => t.copyWith(
      fontSize: math.min(t.fontSize, 12.0),
      controlHeight: math.min(t.controlHeight, 20.0),
      controlPaddingX: math.min(t.controlPaddingX, 5.0),
    );
