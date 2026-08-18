# base_ui_flutter

> **生产力优先的 Flutter 桌面 UI 组件库**
> 无头核心 · 基于 Token 的主题驱动
> 默认 WinForms 组件样式，可自由全局定制主题

---

## 简介

**base_ui_flutter 定位为生产力优先的 Flutter 桌面 UI 组件库**——不是"又一套好看的组件"，而是围绕一个目标构建：**让你用更少的时间，交付更快、更密、更耐用的桌面业务软件**。每一个设计决策都服务于生产力：

| 生产力维度 | 库内支撑 |
|---|---|
| **高信息密度** | WinForm 级紧凑排版，一屏承载更多业务信息，减少滚动与页面切换 |
| **零样式内核** | 组件内核不硬编码任何颜色 / 字体 / 间距，一套 `DesktopTokens` 换肤整个应用，主题维护成本趋近于零 |
| **性能可预期** | 细粒度脏追踪（`CellDirtyTracker`）+ 虚拟滚动，10 万行网格保持 60 FPS |
| **开箱即用** | 28 个 WinForm 风格控件，按 WinForms 分类法组织，桌面业务开发无需重复造轮子 |

**适用场景**：医疗 HIS、企业 ERP / CRM、工业 HMI、政企 OA 等高密度、长生命周期的桌面应用。

---

## 为什么选择 base_ui_flutter

base_ui_flutter 是一个**生产力优先**的 UI 组件库，面向桌面级 Flutter 应用——HIS、ERP、工业 HMI 以及其他高密度生产力软件。它提供了一整套**WinForm 风格的桌面控件**——按钮、输入框、数据网格、树形视图、菜单、工具栏、对话框等——且组件内核中**没有任何硬编码样式**。每一个视觉决策都由一个 `DesktopTokens` 对象统一管理，只需替换一组值即可重新定制整个应用的视觉风格。

一切优化都服务于同一个目标：更快地交付密集、长生命周期的业务界面——并在多年的维护中保持一致性和可重新定制性。

| 设计原则 | 含义 |
|---|---|
| **零样式，完全由你掌控** | 组件内核不硬编码任何颜色、字体或间距。默认外观——一种紧凑、高信息密度的 WinForm 风格预设——完全由 Token 提供。通过覆盖值来换肤，而非修改控件代码。 |
| **Token 驱动** | 一组 `DesktopTokens` 掌控所有视觉决策——颜色、间距、圆角、字体、控件高度。替换 Token 集（或在子树外包裹 `TokenScope`）即可即时换肤。 |
| **细粒度重建** | 细粒度脏追踪（`CellDirtyTracker`），仅重绘发生变化的单元格——专为 10 万行网格 60 FPS 而设计。 |

> **架构约定：** "零样式"是*组件*层面的约定；"开箱即用即像 WinForm"是*默认 Token 预设*。两者互不冲突。

---

## 快速开始

### 1. 添加依赖

```yaml
dependencies:
  base_ui_flutter: ^0.1.0
```

需要 **Dart SDK ^3.9.0** 和 **Flutter ≥ 3.35.0**。

### 2. 用 `TokenScope` 包裹你的应用

```dart
import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  runApp(
    TokenScope(
      tokens: DesktopTokens.winForm,
      child: MyApp(),
    ),
  );
}
```

### 3. 直接使用控件

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Label('Name:'),
    const Input(hint: 'Type your name'),
    const CheckBox(label: 'Remember me'),
    const Button(text: 'OK'),
  ],
);
```

每个控件都从最近的 `TokenScope` 读取其视觉属性，因此在调用处无需任何样式配置。

---

## 主题定制

整个外观由一个 `DesktopTokens` 实例统一控制。内置的 `DesktopTokens.winForm` 预设提供紧凑、高信息密度的 WinForm 外观。`DesktopTokens.shadcn` 预设提供现代、圆角的 shadcn 风格外观（语义化的 muted/secondary/destructive 颜色、12px 圆角卡片、柔和阴影），用于补充组件。你可以通过覆盖单个值来创建自己的主题：

```dart
// 现代 shadcn 风格预设
final modern = DesktopTokens.shadcn;

// 受 Fluent 启发的主题
final fluent = DesktopTokens.winForm.copyWith(
  cornerRadius: 4.0,
  primaryColor: const Color(0xFF0078D7),
  fontFamily: 'Microsoft YaHei UI',
  controlHeight: 32.0,
);

// 应用到子树
TokenScope(
  tokens: fluent,
  child: MySettingsPanel(),
);
```

对于响应式场景，`ResponsiveTokenScope` 会根据窗口大小自动切换 Token 集（支持媒体查询感知）。

还内置了一个交互式**主题设计器**（`ThemeDesigner` 控件）——参见示例应用以获取实时预览。

---

## 组件

base_ui_flutter 提供**80+ 开箱即用的控件**——WinForm 级桌面控件加上 shadcn 参考的补充组件家族——按十个命名空间组织：

| 命名空间 | 控件 | 描述 |
|---|---|---|
| **Foundation** | `Control`、`TokenScope`、`ResponsiveTokenScope`、`OverlayController`、`AnchoredOverlay`、`ModalOverlay`、`FocusTrap` | Token 基础设施、无头基类、覆盖层原语 |
| **Common** | `Button`、`Input`、`Label`、`CheckBox`、`RadioButton`、`ComboBox`、`LinkLabel`、`MaskedTextBox`、`NumericUpDown`、`DomainUpDown` | WinForm 日常输入控件 |
| **Supplements** | `TypeStyle`、`Kbd`、`Separator`、`Tag`、`Field`、`Item`、`Marker`、`ButtonGroup`、`InputGroup`、`Textarea`、`Toggle`、`ToggleGroup`、`ToggleSwitch`、`InputOtp` | 现代 Token 驱动输入补充组件 |
| **Lists & Data** | `ListBox`、`CheckedListBox`、`WinListView`、`TreeView`、`DataGridView`、`PropertyGrid` | 列表/网格/树形展示，支持虚拟滚动 |
| **Containers** | `GroupBox`、`TabControl`、`SplitContainer`、`Accordion`、`Collapsible`、`Sheet`、`SidePanel`、`Sidebar`、`Carousel` | 分组与布局容器 |
| **Menus & Toolbars** | `MenuStrip`、`ContextMenuStrip`、`ToolStrip`、`StatusStrip` | 应用程序外壳 |
| **Overlay** | `Popover`、`HoverCard`、`DropDownButton`、`MessageBox`、`Command`、`Toast`/`ToastHost`、`Direction`、`Empty` | 浮动/模态组件 |
| **Dialogs** | `ColorDialog`、`DateTimePicker`、`MonthCalendar`、`ThemeDesigner` | 选择器对话框 |
| **Data** | `BindingNavigator`、`Chart`、`Pagination` | 数据绑定、图表、分页 |
| **Scroll** | `ScrollBar`、`TrackBar` | 滚动条和滑块 |
| **Misc** | `ProgressBar`、`RichTextBox`、`ScrollableControl`、`WinToolTip`、`ErrorProvider`、`Alert`、`Attachment`、`Avatar`、`Breadcrumb`、`Bubble`、`Message`、`MessageScroller`、`Questionnaire`、`Skeleton`、`Spinner` | 进度条、聊天、反馈、加载状态 |
...

---

## 示例应用

`example/` 目录中包含一个**组件画廊**——每个控件的交互式展示，带有侧边栏导航和实时主题设计器面板。

```bash
cd example
flutter run -d windows   # 或 -d linux / -d macos
```

---

## 项目结构

```
lib/
├── base_ui_flutter.dart        # 单一入口 —— 重新导出所有内容
└── src/
    ├── foundation/             # Token、TokenScope、Control 基类、覆盖层原语
    ├── common/                 # Button、Input、Label、CheckBox、ComboBox、+ 补充组件
    ├── lists/                  # ListBox、TreeView、DataGridView、PropertyGrid、…
    ├── containers/             # GroupBox、TabControl、SplitContainer、Accordion、Sheet、…
    ├── menus/                  # MenuStrip、ToolStrip、StatusStrip、ContextMenuStrip
    ├── overlay/                # Popover、MessageBox、Command、Toast、HoverCard、…
    ├── dialogs/                # ColorDialog、DateTimePicker、MonthCalendar、ThemeDesigner
    ├── data/                   # BindingNavigator、Chart、Pagination
    ├── scroll/                 # ScrollBar、TrackBar
    └── misc/                   # ProgressBar、RichTextBox、聊天、骨架屏、旋转加载、…
```

所有公开 API 均从 `base_ui_flutter.dart` 导出——使用者只需一个 import 即可。

---

## 参与贡献

欢迎贡献！在添加新控件时：

1. 在相应的 `lib/src/<命名空间>/` 目录中实现
2. 从 `lib/base_ui_flutter.dart` 导出
3. 在 `test/` 中添加控件测试
4. 在 `example/lib/pages/` 中添加演示页面

所有控件**必须**遵循 Token 驱动约定——控件代码中不允许硬编码颜色、字体或间距。

---
