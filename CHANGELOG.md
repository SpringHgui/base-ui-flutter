## Unreleased

* `CheckBox` 重写：弃用 Flutter `Checkbox`（自带勾选动画、无法关闭），改为自绘方框 + 勾号，**勾选状态瞬间切换、无动画**（对齐 WinForms 快节奏手感）。API 不变，保留 label 点击切换、Focus/键盘（Enter/Space）切换与 disabled 视觉。

* `Button` 重写聚焦行为：弃用 `TextButton`（其 `InkWell.canRequestFocus` 会在**按下瞬间**请求焦点，导致长按/按住移走鼠标也显示焦点边框），改为 `GestureDetector + MouseRegion + Focus` 手绘实现——**按下只显示 pressed 视觉**，**完整点击(松开)才 `requestFocus()`** 显示焦点边框，长按移走(tap 取消)不聚焦；Tab 导航聚焦正常，焦点在按钮上按 Enter/Space 可激活。视觉逻辑(hover/pressed/disabled/ghost)与 token 取色全部保留。

* `DesktopTokens` 默认(WinForm)控件密度调整：`controlHeight` 24→28、`fontSize` 12→13、`controlPaddingX` 8→12，使按钮/输入框/复选框等统一变大，更贴合桌面应用的舒适点击尺寸。

* `MenuStrip` 悬停行为修正：bar 级 `Listener` 现在仅**在已有菜单打开时**才随悬停切换顶层菜单（`_onBarHover` 在 `_openIndex == -1` 时直接返回）。即 WinForm 经典行为——必须先点击打开菜单，之后悬停才切换；**未打开任何菜单时，单纯悬停不会自动展开**。单项的 `MouseRegion` 仅保留悬停高亮，点击仍由 `GestureDetector.onTap` 开关。

* `MenuStrip` 悬停展开改为 bar 级 `Listener` 驱动：原先依赖每个顶层项的 `MouseRegion.onEnter` 来悬停打开/切换，但该回调在"尚未打开过任何菜单"的首次悬停时可能不触发（默认 `deferToChild` 命中问题），表现为悬停不展开。现改为在菜单栏包裹一层 `Listener(behavior: HitTestBehavior.opaque, onPointerHover)`，按指针全局 x 坐标命中对应顶层项并打开，首次悬停与已展开后切换都稳定生效；单项的 `MouseRegion` 仅保留悬停高亮。

* `MenuStrip` 修复：下拉遮罩（`_MenuDropDown` 的 dismiss scrim）原本为全屏 `Positioned.fill`，
  会拦截覆盖在菜单栏顶部区域的指针事件，导致"菜单展开后悬停其它顶层菜单不会自动切换"的行为失效。
  现改为从菜单栏底边（`position.dy`）开始向下覆盖，顶部菜单栏区域保持裸露，
  悬停切换恢复正常工作（点击空白处关闭的行为不受影响）。

* `Button` 增强：新增 [ButtonVariant]（`solid` 默认 / `ghost` 无边框），并将内容参数化——
  新增 `child`（`Widget?`）以支持任意内容（如图标 + 文字列），`text` 变为可选语义标签。
  `ghost` 变体使用透明背景，悬停 / 按下态以 `hoverOverlayColor` / `pressedOverlayColor`
  混合 `controlColor`，适合工具栏 / ribbon 的无边框按钮组。

## 0.5.0

* 以 shadcn/ui 组件清单为参考，原生补充 43 个缺失组件（不做 shadcn 风格化集合，
  沿用 headless + `DesktopTokens` 架构；命名用 WinForm 语义名 / 裸名）。
* 新增 `DesktopTokens.shadcn` 现代预设，并扩展语义色 token：
  `muted/secondary/accent/destructive/card/popover/ring/barrier`、圆角刻度、
  阴影与图表色板（`TokenColor` 扩展提供 hover/pressed/disabled 派生色）。
* 新增浮层基础设施：`OverlayController`、`AnchoredOverlay`、`ModalOverlay`、
  `FocusTrap`（锚定定位 / 模态遮罩 / 焦点圈闭），以及 `Surface` 交互表面基元。
* 新增通用补充组件：`TypeStyle`、`Kbd`、`Separator`、`Tag`、`Field`、`Item`、
  `Marker`、`ButtonGroup`、`InputGroup`、`Textarea`、`Toggle`、`ToggleGroup`、
  `ToggleSwitch`、`InputOtp`。
* 新增容器组件：`GroupBox`（Card）、`TabControl`（Tabs）、`SplitContainer`
  （Resizable）、`Accordion`、`Collapsible`、`Sheet`、`SidePanel`（Drawer）、
  `Sidebar`、`Carousel`。
* 新增浮层组件：`Popover`、`HoverCard`、`DropDownButton`（DropdownMenu）、
  `MessageBox`（Dialog / AlertDialog，含 `MessageBox.show` 与 WinForm 按钮组合）、
  `Command`、`Toast`/`ToastHost`、`Direction`、`Empty`。
* 新增数据与杂项组件：`Chart`（柱/折线/环图，无第三方依赖）、`Pagination`、
  `Alert`、`Attachment`、`Avatar`、`Breadcrumb`、`Bubble`、`Message`、
  `MessageScroller`、`Questionnaire`、`Skeleton`、`Spinner`。
* 组件画廊新增 Supplements / Containers / Overlay 分类与 43 个演示页。
* 更新 [components.md](components.md) 第八节（shadcn 参考映射：新增 43 / 已覆盖 21）。

## 0.1.0

* Initial scaffold: `DesktopTokens` with a WinForm-style default preset.
* Added `TokenScope` for app-level token theming.
* Added WinForm-style `Button`, `Input`, and `Label` widgets.
* Added `CheckBox` — WinForm-style check box with label support.
* Added `RadioButton<T>` — WinForm-style radio button with mutual exclusion group.
* Added `ComboBox<T>` — WinForm-style drop-down combo box (editable / read-only).
* Added `ListBox<T>` — WinForm-style list box with single / multi-select.
* Added `WinListView<T>` — WinForm-style list view with Details / icon / multi-select modes.
* Added `TreeView<T>` — WinForm-style tree view with expand / collapse / select.
* Added `NumericUpDown` — WinForm-style numeric up/down control.
* Added `DateTimePicker` — WinForm-style date / time picker.
* Added `ProgressBar` — WinForm-style progress bar (determinate / marquee).
* Added `MenuStrip` — WinForm-style main menu bar with drop-down sub-menus.
* Added `ContextMenuStrip` — WinForm-style right-click context menu (reuses `MenuModel`).
* Added `ToolStrip` — WinForm-style toolbar (buttons / separators / labels / drop-downs).
* Added `StatusStrip` — WinForm-style status bar with panels.
* Added `Control` — headless control base class (focus / disabled / semantics contract).
* Added `ControlSemantics` — accessibility wrapper for custom controls.
* Added `DataGridView` — WinForm-style data grid with virtual scrolling & `CellDirtyTracker`.
* Added `ScrollBar` / `StandaloneScrollBar` — WinForm-style scroll bars (H/V).
* Added `TrackBar` — WinForm-style track bar / slider.
* Added `ScrollableControl` — headless scrollable container.
* Added `LinkLabel` — WinForm-style hyperlink label.
* Added `MaskedTextBox` — WinForm-style masked text input.
* Added `RichTextBox` — WinForm-style multi-line text editor.
* Added `MonthCalendar` — WinForm-style month calendar.
* Added `CheckedListBox<T>` — WinForm-style checked list box.
* Added `DomainUpDown<T>` — WinForm-style domain up/down.
* Added `PropertyGrid` — WinForm-style property grid with categories.
* Added `ColorDialog` — WinForm-style colour picker dialog.
* Added `BindingNavigator` — WinForm-style data binding navigator.
* Added `WinToolTip` — WinForm-style tool tip.
* Added `ErrorProvider` — WinForm-style form validation indicator.
* Added `RovingTabindex` — declarative keyboard focus state machine.
* Added `ResponsiveTokenScope` — media-query-aware token switching.
