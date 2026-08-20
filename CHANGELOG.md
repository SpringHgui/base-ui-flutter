## Unreleased

* 新增 `ToolbarButton`（menus）：独立可用的工具栏按钮（图标 + 文本 / 仅图标），自绘 hover / pressed / 禁用态，支持 `iconColor` 功能强调色、`showCaret` 下拉箭头、`outlined` 边框触发器样式、`textMaxWidth` 窄条省略，无 Material 水波纹与点击动画。区别于数据模型 `ToolStripButton`，可挂在任意布局中。
* `IconBtn` 重写为自绘实现（不再委托 `Button`）：新增 `child`（任意内容，如 `CustomPaint` 图标）、`selected` / `selectedColor`（accent 淡底选中态）、`outline`（边框）、`size`（固定命中区）参数，保留原 API 兼容；含 Focus + Enter/Space 键盘激活。
* 新增 `ListItem`（lists）：高密度列表行（前置图标 + 标题 + 尾随），`selectedColor` 支持浅底选中（文字保持前景色，树形场景），选中由 `Listener.onPointerDown` 零延迟触发，双击单独挂 `GestureDetector`。
* 新增 `SelectableCard`（common）：可选卡片（内容 + 选中淡底 + 右上对勾圆标），禁用时整体降透明并显示 `disabledLabel` 角标，`PointerDown` 选中 + 双击动作。
* 新增 `ExpandableSearch`（form）：可展开搜索框（收起为放大镜按钮 → 展开输入框），失焦且内容为空自动收起。
* 新增 `InlineEditor`（form）：单元格内联编辑器（自动聚焦，Enter / 失焦提交，Esc 取消，防双触发）。
* `TabControl` 增强：`TabItem` 新增 `onClose`（悬浮显示关闭按钮）/ `width`（固定宽度）/ `contextMenuItems`（逐标签右键菜单）；`TabControl` 新增 `tabBarColor` / `selectedTabColor` / `hoverTabColor` / `showUnderline`（可关） / `barHeight` / `tabWidth` / `scrollStep`，标签溢出时两侧滚动箭头，选中下划线去掉 `AnimatedContainer` 动画。
* `DataGridView` 增强：新增 `showRowNumbers` / `rowNumberWidth` / `rowNumberBuilder`（行号列，按下选中整行）、`selectedCell` / `onCellSelected` / `onCellDoubleTap` / `onCellContext`（单元格选中 / 双击 / 右键，选中由 `Listener.onPointerDown` 零延迟触发）、`headerColor` / `gridLineColor` / `selectedTextColor` / `cellPaddingX` / `headerFontSize` / `rowHoverColor`（行 hover 自持，避免整页重建）。
* `ListItem` 新增 `borderRadius` 参数（默认 `cornerRadius` 圆角，可传 `BorderRadius.zero` 用于高密度直角列表 / 对象面板）。
* `TabControl` 新增 `contentPadding` 参数（可关掉默认 8px 内容内边距，适配纯标签条场景，如 db_lite 对象视图标签栏）。
* `SelectableCard` 覆盖层（选中淡底 / 对勾圆标 / 禁用角标）由 `Stack` 改为 `CustomPaint` 自绘：Stack 在无界约束下无法布局（如 `DialogBox` 的 `IntrinsicHeight` 尺寸计算会崩溃），自绘让组件在任意约束下正常渲染，且不引入额外渲染层级。

* `Textarea` 新增 `expands`（填满可用空间，用于代码编辑器）、`style`（覆盖文本样式，如 monospace 字体）与 `showBorder`（关闭边框，供嵌入面板的编辑器使用）参数；`expands: true` 时自动置空 `minLines` / `maxLines` 并透传 `TextField.expands`。
* `ComboBox` 可编辑(editable)模式下拉面板移除 `Material(elevation)` 阴影与 `InkWell` 水波纹：改为纯 `Container` 边框面板 + `Listener.onPointerDown` 按下即选中 + `MouseRegion` hover 高亮（与只读模式下拉一致），消除阴影 shader 编译与墨水动画开销。

* 新增 `DialogBox`:通用对话框外壳(标题栏+正文+可选 footer),承载自定义内容的模态窗口;标题栏用 `surfaceColor` 底色 + `IconBtn` 关闭按钮,正文用窗口底色,扁平 WinForm 风格(无外边框、无 Material 阴影),自带 `DefaultTextStyle` 干净基线。命名避开 Flutter Material 的同名 `Dialog` 冲突。配合 `showDialog` 使用,模态行为(遮罩/Esc/返回值)仍由调用方掌控。

* `ToolStripButton` / `ToolStripDropDownButton` 新增可选 `iconColor` 参数,支持为工具条按钮图标指定语义强调色(如新建=绿、删除=红),默认仍使用 `DesktopTokens.foregroundColor`。
* `ToolStrip` 下拉面板移除 `Material(elevation)` 与冗余双重边框,改为纯 `Container` 扁平 WinForm 风格,避免首次展开阴影 shader 编译延迟。
* `ToolStripDropDownButton` 支持分离式(split)按钮:新增可选 `onPressed`,赋值时按钮主体(图标+文字)点击触发 `onPressed`,右侧独立箭头点击才打开下拉菜单,主体与箭头之间用细分隔线隔开;不赋值时行为与旧版一致(整钮打开下拉)。
* `ToolStripButton` / `ToolStripDropDownButton` 按钮体优化:内容容器由「仅水平 `compactSpacing` 且无固定高度」改为撑满 `controlHeight` 高度(垂直居中)并水平方向给到 `compactSpacing * 2` 内边距,hover/按下高亮带不再贴着文字、图标文字不再紧贴,整条观感更舒展。split 模式的下拉箭头容器同步撑满 `controlHeight`。
* 修复 `ToolStrip` 下拉菜单项文本继承应用级 `DefaultTextStyle` 的 `decoration: double/yellow` + `fontWeight: bold` 样式(去掉 `Material` 兜底后触发):`_ToolStripDropDownEntryWidget` 的文本显式声明 `decoration: TextDecoration.none` + `fontWeight: FontWeight.w400`,消除菜单项黄色双下划线与加粗。
* 优化 `ToolStripDropDownButton` 分离式(split)按钮的渲染:原先主体与下拉箭头是两颗独立 pill(各自 hover 背景 + 圆角),悬浮时整体观感"变宽"且中间分割线被同色 hover 底色淹没而不可见。现改为整颗做成"统一的一颗按钮"——悬浮时整体一个 hover 背景,主体与箭头之间用一条常驻 1px 占位(非悬浮时为透明)、仅悬浮时才着色的细分隔线隔开,既消除悬浮变宽、又让分割线在统一底色上清晰可见。
* 修复 split 按钮分割线在明亮主题下不可见:分割线颜色由固定 `borderColor`(亮色下与 hover 底色几乎同色)改为基于 hover 底色 `Color.alphaBlend` 的明暗自适应(暗底提亮叠白、亮底加深叠黑),符合项目"hover/选中色必须明暗自适应"规范,两套主题下均可见。

* `CheckRow` 新增 `trailing` 参数：行尾可渲染任意 widget（如状态标注），便于在选项列表中标示不可用/未实现的条目。

* `ContextMenuStrip` 新增静态入口 `showContextMenu(context, items, position)`：无需包裹子树，可在右键时刻动态构建菜单内容后直接弹出（如表格单元格右键菜单，命中哪格决定了菜单作用于哪格）。同时菜单弹出位置增加屏幕边界夹取，右键在屏幕右/下缘时面板自动收回屏幕内，不再溢出不可见。

* `ComboBox` 只读模式下拉重写：原实现基于 Flutter `DropdownButton`，弹出带 Material 淡入/滑动动画，不符合传统桌面习惯。现改为自绘 WinForm 风格即时展开下拉列表：`Listener.onPointerDown` 触发、`OverlayEntry` + `CompositedTransformFollower` 定位、无动画即时显示、hover 高亮、选中项主色填充、点击外部或选项后即时关闭。

* `ToolStrip` 增强：新增 `trailing`（右侧任意 widget，如 `Pagination`）与 `trailingItems`（右侧条目）支持左右分区布局；新增 `borderOnTop`（分隔线画在顶部，适配底部停靠）与 `openUpward`（下拉面板向上弹出，适配底部工具栏，并夹取面板位置避免溢出屏幕右缘）。`ToolStripDropDownButton.text` 改为可选，支持纯图标下拉按钮（隐藏下拉箭头）。
* `Pagination` 尺寸调整：页码/箭头按钮边长由 `controlHeight * 1.2` 改为 `controlHeight`，可直接嵌入 `ToolStrip` 等紧凑容器不溢出。

* `ContextMenuStrip` / `MenuStrip` 关闭遮罩修复：遮罩原为 `GestureDetector(translucent, onTap, ColoredBox)`，但 `ColoredBox` 的渲染对象是 opaque 命中，遮罩子树命中测试返回 true 后 Stack 即停止向下探测——底部控件完全收不到事件，菜单打开时第一次点击只被用来关菜单（浪费一次点击，右键换菜单同样被吃掉）。现改为**无子节点的半透明 `Listener` + `onPointerDown`**：命中测试返回 false（事件穿透到底部控件），但自身仍在命中列表中（按下瞬间即关菜单）——同一次点击既关菜单又落在下方控件上，与原生桌面行为一致。
* `ContextMenuStrip` 弹出位置修复：`PointerEvent.position` 本身就是全局坐标，旧代码又对它做了一次 `box.localToGlobal()` 转换，把触发控件自身的窗口偏移重复叠加，导致菜单向右下偏移。现直接传入 `event.position`，菜单精确出现在光标处。

* `ListView` 行选中延迟修复：`onTap` 与 `onDoubleTap` 同注册会让单击被双击判定窗口 hold 约 300ms。选中改为 `Listener.onPointerDown`（按下瞬间触发、零延迟），双击激活单独由 `GestureDetector.onDoubleTap` 处理。

* `MenuStrip` 显式关闭菜单项文字下划线并恢复常规字重:之前为优化首屏速度把下拉面板的 `Material` 替换为 `Container`,但 Text 不再有 Material 的 `DefaultTextStyle` 兜底,会继承应用级某个带 `decoration: underline / TextDecorationStyle.double / color: yellow` 且 `fontWeight: bold` 的样式,导致下拉菜单项文字下方出现两条黄线、字体加粗。已在 `_MenuTopItem` / `_MenuDropDownItem` 的 Text 显式 `decoration: TextDecoration.none` + `fontWeight: FontWeight.w400` 覆盖。

* `MenuStrip` 顶层菜单项高亮修复：行内 `crossAxisAlignment` 改为 `stretch`，hover/打开态背景**填满整行高度**（此前只包住文字形成一条窄横带，视觉上像菜单项上的"横线"）。

* `MenuStrip` 下拉面板性能优化：弃用 `Material(elevation)`（阴影首次计算 / shader 编译是"首次展开慢、之后快"的主因）与冗余的 `CompositedTransformTarget`，改纯 `Container`（扁平 WinForm 风格），首次展开更跟手。

* 新增 `FieldRow`：横向表单行（左 label 右对齐固定宽 + 右侧控件），经典桌面(Navicat/WinForms)表单布局；`label` 缺省时渲染同宽占位保持对齐。
* 新增 `IconBtn`：轻量无边框图标按钮（工具栏/标题栏），悬停 ghost 高亮，可选 tooltip。命名避开 Flutter Material 的同名 `IconButton` 冲突。
* `Input` 新增 `obscureText` 参数，支持密码框。

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
