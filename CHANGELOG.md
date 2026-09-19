## Unreleased

* 新增 `TabStrip`（containers）：扁平**下划线**标签条（浏览器 / Navicat 面板内子标签样式，如设计器「更改 / DDL」切换），`TabControl` 的轻量对应物。受控组件：宿主持有 `index`、响应 `onChanged`；选中项 = `primaryColor` 文字 + 2px 下划线 + 内容底色衬底，未选中项 hover 淡底。切换走 `onTapDown`（按下即触发，零延迟，不注册双击手势），零动画、无 Material 水波纹，取色链 `tokens ?? TokenScope.maybeOf ?? DesktopTokens.winForm`。

* 新增 `InputDialog`（dialogs）：单行文本 / 密码录入弹窗（「连接需要密码」这类打开前补录凭据的 WinForm 对应物）。由 `DialogBox` + `Input` + `Button` 组合，`show` 回传输入文本，取消 / 关闭 / Escape 回传 `null`。`password: true` 时输入框走 `obscureText` + 眼睛切换，且**空输入禁用确定**——调用方可契约式假定非 null 结果必非空；`message` 为输入框上方的提示文本，`initialValue` 预填，`okText` / `cancelText` 缺省 `OK` / `Cancel`（中文由宿主传入）。Enter 提交、零动画、无 Material 水波纹，取色链 `tokens ?? TokenScope.maybeOf ?? DesktopTokens.winForm`。

* `MessageBox`（overlay）底部按钮区调整：**去掉正文与按钮之间的 `Separator` 分割线**，按钮行由右对齐改为**居中**。按钮顺序、自动聚焦（主按钮）、间距均不变。

* 滚动条改为**静止窄条、悬浮加宽**：`ScrollBar` 由无状态改为自绘热区检测——`MouseRegion` 监听滚动条贴边一带（宽度 = 悬浮态宽度 + 4px），鼠标进入即把传给 `Scrollbar.thickness` 的宽度从 5px（`kScrollBarSlimThickness`）切回 8px（`kScrollBarExpandedThickness`，可用 `thumbThickness` 覆写，零动画即时切换）。不再依赖 Material 内部的悬浮 `WidgetState`（实测其在部分场景不可达）。同时新增 `scrollbarHoverThickness()`：按 `WidgetState.hovered / dragged` 切换厚度的 `WidgetStateProperty`，供宿主写入全局 `ThemeData.scrollbarTheme.thickness`，让 Flutter 默认滚动行为为普通 `ListView` / `ScrollView` 生成的滚动条也走同一策略。`thumbThickness` 语义变为「悬浮态宽度」。回归测试见 `test/scroll_bar_test.dart`（纵向/横向悬浮、自定义宽度、状态解析器）。

* `CheckBox` 的 `onChanged` 改为**可选**（common）：字段本就是 `ValueChanged<bool?>?`，仅构造器标了 `required`。传 `null` 即渲染一个被动的勾选指示器——视觉与可交互态**完全一致**（边框仍取 `foregroundColor`，禁用仍走 `enabled`），只是不注册 tap / 键盘处理。用途：勾选框位于 `DataGridView` 单元格里时，外层单元格的 `GestureDetector(onDoubleTap)` 会把勾选框自身的 `onTap` 扣在约 300ms 的双击判定窗口里，单击看起来「没反应」；宿主改用 `Listener.onPointerDown` 在按下瞬间结算勾选，`CheckBox` 只负责显示状态。既有调用全部不受影响。

* `Toggle` **`outline` 变体的选中态改浅**：不再填充实心 `accentColor`，改为 `accentColor`（16% alpha）叠加在 `controlColor` 上的淡色染色 + `accentColor` 描边，文字 / 图标前景保持 `foregroundColor`（不再换成 `accentForegroundColor`）。原因：宿主工具面板标签是「黑色线稿 + 蓝色强调」的自绘图标，实心蓝底会把图标里的蓝色部分整个吞掉。`default_` 变体（加粗 / 斜体这类纯色图标工具栏按钮）仍是实心 accent 填充 + 反色前景，行为不变；`outline` 未选中态也完全不变。

* `Button` 新增 `ButtonVariant.primary`（common）：对话框 / 面板里**唯一主操作**的实心强调色按钮（确定、应用、保存）。底色 `primaryColor`、文字 `accentForegroundColor`，禁用时两者各降不透明度（0.45 / 0.6）而非换成灰色面；描边与底色同色（纯色块无边界感），仅在聚焦时换成 `foregroundColor` 描边。hover / pressed 仍走叠加色，但因 `hoverOverlayColor` 在实心色底上几乎不可见（约 4% 黑），两级都改用 `pressedOverlayColor` 叠加——hover 一层、按下两层，保证快节奏下反馈可辨。零动画、无 Material 水波纹，按下不抢焦点、完整点击才聚焦（与 `solid` 同一套焦点时机）。默认值不变，既有调用零影响。

* `DataGridView` 表头支持**两行标题**：`DataGridViewColumn` 新增 `subtitle`（第二行文本，如列数据类型）与 `subtitleGlyph`（副标题前的 accent 色小字形，如 `#` / `abc`）。任一列带副标题时表头整体加高 14px 并切换为两行布局（标题行 + 14px 副标题行，无副标题的列第二行留空保持对齐）；副标题字号比 `headerFontSize` 小 1.5px、取 `mutedForegroundColor`。全部列都不带副标题时高度与渲染与旧版完全一致，既有调用零影响。排序箭头仍位于标题行右侧。
* 修复 `DataGridView`(lists) 数据行**缺横向分隔线、最后一行没有下边框**：此前每行的 `Container` 只画背景色，竖线来自单元格的 `right` 边框，但整表唯一的横线只有表头下边框与最外层 `Border.all`；当行数不满可视区（末行下方是空白）时末行像是悬空、没有收口线。现给 `_DataGridRow` 的行容器改用 `BoxDecoration`，保留原背景色的同时补上 `bottom` 边框（颜色 `gridLineColor`、宽度 `borderWidth`，与竖线一致），使每行都有下边线、最后一行自然收口，符合 WinForms DataGridView 的行网格语义。

* 修复 `ComboBox`（common）下拉**点击热区塌成文字大小**：必须精确点到候选项/触发框的文字才能选中或展开，点行内空白或左右内边距无响应。根因是带 `alignment` 的 `Container` 内部走 `Align`、其命中测试为 `deferToChild`，背景虽铺满整行但空白区不参与命中；外层 `Listener` 默认同为 `deferToChild`，于是整行热区缩到子节点尺寸。现给只读触发框、只读候选项与可编辑候选项（`_EditableOption`）三处 `Listener` 补上 `behavior: HitTestBehavior.opaque`，使整行（含内边距与 Expanded 空白区）均可按下选中，零延迟交互与视觉保持不变。

* 新增 `MarqueeSelector`(lists)：桌面风格的**框选**（rubber-band / marquee）行为层。在 `child` 区域内按住左键拖动、位移超过 `threshold`（默认 4px，低于它视为普通点击）后进入框选，期间以 `onMarqueeUpdate(Rect)` 回调视口局部选框并绘制 accent 半透明填充 + 1px 描边浮层，起手触发 `onMarqueeStart`、松手 / 取消触发 `onMarqueeEnd`；`enabled` 可整体关闭，`canStart` 让宿主排除不该起手的地方（如内容区右缘滚动条命中带）。**它不解释命中**：把矩形换算成选中项交给宿主——定行高的网格 / 列表由宿主自己按几何算（配合 `ScrollController.offset`），无需测量渲染对象。指针事件走 `Listener` 而非手势竞技场：祖先 `Listener` 在 pointer down 时缓存命中路径，整段拖动都收得到 move/up，既不与子项自己的 `onPointerDown` 选中抢竞技场，也不会给子项单击引入约 300ms 的双击判定延迟（本项目「零视觉延迟」约束）。零动画、无 Material 水波纹，取色链 `tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm`。

* `ComboBox` 新增 `iconBuilder`（common）：为候选项绘制**前置图标**（WinForms owner-draw 下拉的对应能力，如下拉项名前画一个引擎 / 实体图标）。同一个回调同时作用于**收起态的当前值**与**展开态的每一行**，图标盒子边长由 `controlHeight - 8` 推导并夹在 12~18px，与文本之间留 `compactSpacing`；返回 `null` 表示该项不画图，缺省不传则完全保持既有纯文本外观。只读与可编辑两种模式都已接入（可编辑模式下图标置于文本框左侧、吃掉一份 `controlPaddingX` 以与只读模式对齐），零动画、无 Material 水波纹。

* 新增 `ListPickerDialog`（dialogs）：泛型多选候选对话框——勾选任意个候选项后确定，`show` 按**候选原顺序**回传选中项（取消 / 关闭回传 `null`），自身不写回任何模型。由 daro 表设计器的 `StringPickerDialog`（选择继承的父表）上收泛化而来，满足「无业务依赖 + Token 驱动 + 可独立复用」的入库条件。由 `DialogBox` + `CheckedListBox` + `Button` 组合，零动画、无 Material 水波纹；`okText` / `cancelText` 缺省 `OK` / `Cancel`（与 `MessageBox` 一致，中文由宿主传入）；`itemToString` 自定义行标签而回传的仍是原对象；`emptyHint` 用于无候选时的引导（宿主可同时保留手输入口）。取色链 `tokens ?? TokenScope.maybeOf ?? DesktopTokens.winForm`，与其它浮层一样默认走根导航器，故 `TokenScope` 需位于 `Navigator` 之上才跟随主题。**泛型陷阱**：`selected` 的默认值 `const []` 在泛型声明处拿不到 `T`，运行时实际是 `List<Never>`，直接 `toSet()` 会让首次勾选的 `addAll` 抛 `Iterable<Never>` 类型错误——内部已改为 `Set<T>.from(...)`。回归测试见 `test/list_picker_dialog_test.dart`（按候选顺序回传、预勾选可取消、取消回传 null、空候选提示、`T=int` 且不传 `selected` 的组合）。示例画廊 Dialogs 分类新增 `ListPickerDialog` 页，并计入 `example/test/smoke_test.dart`。

* `Popover` 新增 `scrollable` / `maxHeight`：内容过高时在**面板内部**滚动，而不是把整列铺出屏幕。修复前连接选择器这类下拉（db_lite 查询页「选择连接」有几十个连接）会把全部条目一次性渲染出来——面板高过视口顶部/底部被裁掉，且后面的条目根本选不到。`scrollable: true` 时滚动视图位于带边框的面板**内部**（背景与边框固定不动，只有行在动），`maxHeight` 缺省表示「最多占满视口、绝不超出」，显式给值则按值封顶（仍会与视口取小）。列表用 `ListItem`、`crossAxisAlignment: stretch` 的 `Column` 直接放即可，滚动条沿用控件库 token 化 `ScrollBar`；零动画、无 Material 水波纹。回归测试见 `test/modern_components_test.dart`（「Popover 内容过高时在面板内滚动」+ 未开启时的无界行为各一条），示例页新增 Scrollable 分组。
* `AnchoredOverlay` 新增 `maxHeight`（`Popover` 的底层实现）：在**布局之前**用 `MediaQuery` 把上限与视口高度取小（`double.infinity` = 只受视口约束），并把 `ConstrainedBox` 套在被 `_contentKey` 测量的那层 `Container` 上——这样 `_remeasure` 量到的就是封顶后的尺寸，贴边夹取与 `OverlaySide.auto` 选边都能基于真实高度正确计算。`null`（默认）保持既有「无界、可溢出视口」行为，既有调用外观不变。

* 修复 `AnchoredOverlay` **测量帧的无限宽崩溃**：浮层内容在算出位置前挂在 `Offstage(offstage: true)` 下，而 `RenderOffstage` 对隐藏子节点用的是**空约束**（`maxWidth = ∞`）。任何依赖有界宽度的内容——`DropDownButton` 的 `Column(crossAxisAlignment: stretch)`、`ListView` 等——在这一帧直接抛 `BoxConstraints forces an infinite width`，调试模式下弹层根本打不开。现给被测量的那层套 `ConstrainedBox(maxWidth: 视口宽 - 2×8)`（视口宽取自 `MediaQuery`，取不到则不设限），使测量帧与定位后的约束一致。修复 `DropDownButton` 两条既有测试（opens menu / closes after selecting an item）与宿主「导出向导」底部三个下拉。

* 修复 `DataGridView` 在 `rowCount == 0`（仅表头）时的越界行号：拖拽多选经 `Listener` 命中空白数据区时，`_rowAtY` 原会返回 `rowCount - 1`（即 `-1`），使宿主收到 `(-1, col)` 这类不存在的单元格。现在 `rowCount <= 0` 时直接返回 `null`，空白区不再产生任何选中回调。宿主可放心用「`rowCount: 0` + 只有表头」表示空结果集（如 db_lite 查询页 0 行结果、表数据页空表）。

* `Empty`(overlay) 新增 `maxWidth` 参数：把内容列限制在给定宽度内，长文本（例如数据库返回的错误原文）在该宽度内换行并保持居中，`action` 按钮紧随其下。此前宿主若用「`Row(mainAxisSize.min)` + `Flexible(Text)` + 按钮」手绘居中提示，`Flexible` 会把整行撑到容器全宽——文字被挤成一行省略号、按钮贴到容器最右缘甚至被裁掉。默认 `null` 不限制，既有调用行为不变。
* 修复 `TabControl` 页面面板拿到**无界高度**导致整帧布局中断:自 Flutter 3.47 起,竖向 `Column` 的非 flex 子项不再被夹到剩余空间,而是拿到 `maxHeight = infinity`(旧版本在有界时夹逼到剩余高度)。标签页内容只要要求显式高度就必然在 `performLayout` 断言——例如放 re_editor 代码编辑器的页签会抛 `CodeLineNumber should have an explicit height`;断言中断布局后渲染树半残,之后每次鼠标移动都命中未布局的盒子,`MouseTracker` 的 `_debugDuringDeviceUpdate` 因异常跳出而永久置位 → 控制台无限刷屏 `!_debugDuringDeviceUpdate` + `RenderBox was not laid out`,界面表现为彻底卡死。现将页面面板包进 `Flexible(fit: FlexFit.loose)`:控件自身高度有界时面板填满剩余高度(即 WinForms `DisplayRectangle` 语义,与 3.47 之前的观感一致,页面底色/边框不再塌陷),置于 `DialogBox` 的 `IntrinsicHeight`、滚动容器等无界场景时仍按内容自适应且不触发 flex 断言。回归测试见 `test/tab_control_body_test.dart`。
* `DataGridView` 表头新增拖拽排序：`onHeaderSort`（按住列头标题横向拖动、松手即按该列排序，向右=升序、向左=降序）、`sortColumn` / `sortAscending`（在当前排序列标题右侧渲染 accent 色 ▲/▼ 箭头）。判定用「按下点 → 松开点」的横向总距离，不与起手阈值叠加，不足 8px 视为按住抖动不触发。拖动过程中箭头实时预示松手后将应用的方向；标题区光标为 `click`、列头右缘内侧 8px 为 `resizeColumn`（沿用 `columnWidths` / `onColumnResize` 改列宽），两者互不干扰。零动画、无 Material 水波纹。
* `DataGridView` 表头两种拖拽（拖标题排序 / 拖边框改列宽）改由 `Listener` 直接跟指针结算，不再依赖 `GestureDetector` 的拖拽回调。原因：真机上「按住列头左右拖」没有任何反应，而同样的操作在 widget 测试里（斜拖、起手先纵向抖一下、拖出整个网格、按下停顿 300ms、1px 慢拖 60 步）全部能结算——差异只可能出在手势竞技场的归属上。`Listener` 的命中路径在 pointer down 时缓存，整段拖动都收得到事件，与谁赢竞技场无关。每个拖拽区仍保留一层只注册空 `onHorizontalDragStart` 的 `GestureDetector`，唯一作用是占住竞技场，使拖列头不会连带外层横向 `SingleChildScrollView` 一起滚。顺带把改列宽从「逐帧 `delta.dx` 累加」换成「按下时列宽 + 按下点起算的总位移」，事件被合并 / 丢弃时宽度不再漂移；预示箭头改为位移达到阈值时才出现，且仅在预示状态真的变化时 `setState`。
* 修复 `DataGridView` 列宽拖拽命中区过小：resize 手柄原先用 `Positioned(right: -3)` + 6px 让手柄探出列头单元格右缘，但 `RenderBox.hitTest` 要求触点先落在父盒子尺寸内，探出的半边永远点不到——实测只有紧贴边框内侧约 2px 能拖动。现改为贴右缘内侧 `right: 0` + 8px，整条命中区都可点。
* 修复 `ToolStrip` 在窄面板 / trailing 展开时 `RenderFlex overflowed ... on the right`（如 db_lite 对象面板把中间栏拖窄，工具栏按钮 + 右侧 `ExpandableSearch` 总宽超出容器）：左侧按钮组原与右锚 `trailing` 同处一个不换行 `Row`，靠 `Spacer` 撑开，空间不足即溢出被裁。现将左侧按钮组放进 `Flexible(child: 横向 SingleChildScrollView)`——`trailing` 仍保持自然宽度钉在右缘、按钮组撑满剩余空间（视觉上与旧的 `Spacer` 完全一致），空间不够时按钮组横向滚动而非溢出；滚动区用 `ScrollConfiguration(...copyWith(scrollbars: false))` 隐藏桌面滚动条，外观不变。

* 新增 `Splitter`(containers)：独立的可拖动分隔条（WinForm `Splitter` 对应物）。与自带比例状态、只管两栏的 `SplitContainer` 不同，它只上报沿分割轴的**像素增量**（`onDrag`）配合 `onDragStart` / `onDragEnd`，由宿主决定改哪一栏、改多少，因此可直接用于三栏外壳、停靠面板等宽度由外部状态掌控的布局。默认 5px 宽的命中区内居中画 1px 发丝线，静止用 `borderColor`、hover / 拖动时用 `primaryColor`，光标随方向为 `resizeLeftRight` / `resizeUpDown`；零动画、无 Material 水波纹，取色链 `tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm`。
* `Splitter` 新增两个正交的外观开关（默认 `true`，既有调用外观不变）：`showHairline` 管**静止态**是否画 1px 发丝线，`false` 供「面板贴合」布局使用——分隔条不再插进 `Row` / `Column` 里占掉 5px 布局宽度，而是由宿主以浮层（`Positioned`）压在两栏拼缝上且不画线，拼缝既不会被看成间隙，也不会让中间面板两侧多出一条像边框的线；`showHoverHighlight` 管**悬浮 / 拖动时**是否换成 `primaryColor` 高亮，`false` 时发丝线保持静止色（`showHairline: true`）或任何状态都不着色（`showHairline: false`），并且不注册鼠标进出回调 → 悬停零重建。手柄始终保留 `resizeLeftRight` / `resizeUpDown` 光标与完整命中区，照样能拖。回归测试见 `test/splitter_test.dart`（四种组合各一条）。

* 新增 `StepBar`(misc)：向导式横向步骤条（编号圆标 + 步骤标题 + 连接短线），三态渲染（已完成=描边、当前=accent 实心、未到达=灰化），供导入 / 导出向导一类多页对话框标示当前进度；纯展示组件，翻页仍由宿主对话框按钮控制。零动画、无 Material 水波纹，取色链 `tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm`。
* `ProgressBar` 新增 `barColor`（misc）：覆盖进度条**前景色**。用于长任务对话框需要按结果着色的场景（如导出向导完成时整条转成功绿、失败转红），缺省 `null` 时仍取 `DesktopTokens.primaryColor`，既有调用外观不变。色值由宿主作为构造参数传入，控件本身仍不硬编码任何颜色，marquee 模式同样生效。
* 新增 `PageNavigator`(data)：输入跳页型分页器——首页 / 上一页 / 页码输入框 / 下一页 / 尾页 + 可选「共 N 页」标签，仅一个输入框输入页码回车跳转，无页码按钮阵列；输入框自动过滤非数字字符，非法输入回弹当前页。页码输入框的垂直 padding 沿用 `Input` 默认居中算法（`(controlHeight - fontSize)/2`），避免 `isDense` 下 `textAlignVertical` 失效导致文字贴顶。`pageCount` 可为 `null`（总页数未知，按需 COUNT 模式）：「共 N 页」显示为「共 ? 页」，下一页/尾页保持可点，尾页按钮改触发 `onGoLast` 回调（由调用方执行 COUNT 后跳转）。与页码阵列型 `Pagination` 并存。
* `Input` 新增 `textAlign` 参数：文本对齐方式透传给文本域（如页码输入框居中显示），默认 `TextAlign.start` 保持原行为。

* **移除重复组件 `Item`(common)与 `ListBox`(lists)**：两者分别是 `ListItem` / `WinListView` 的功能子集，一并删除。
  - `Item` → `ListItem`：`DropDownButton.items` 公共类型改为 `List<ListItem>`（选中仍按下即触发，菜单关合逻辑不变）；`Item` 的 `text` 参数对应 `ListItem.title`，示例页 / quick_overview / 测试同步迁移；键盘激活回归测试改直接测 `Surface`。
  - `ListBox` → `WinListView`：list 模式参数完全一致，`WinListView` 额外提供 details/icon 模式、builder 模式、`onItemActivated` 双击激活与零延迟选中；删除 `list_box_page.dart` 示例页及其 main.dart / smoke_test 注册与三语 l10n 键；`CheckedListBox` 文档不再引用 `ListBox`。
* 修复 `FieldRow` 在 debug 下崩溃 / 示例页空白：`Row` 对非 flex 子项(非 stretch 对齐)不约束最大宽度，直接放 `Input`(TextField) 会触发 "InputDecorator cannot have an unbounded width" 断言。`FieldRow` 现将 child 包进松约束 `Flexible`，子项获得有界最大宽度且不被强制拉伸——固定宽度写法(如 `SizedBox(width: 280, child: Input(...))`)保持原布局。
* 修复 `InlineEditor` 进入编辑时全选文本:桌面平台(Win/Linux/macOS)`TextField.selectAllOnFocus` 默认 true,聚焦即全选,预设 collapsed 选区挡不住;`Input` 新增 `selectAllOnFocus` 参数透传(默认 null 跟随平台),`InlineEditor` 显式传 `false` 并保留 controller 预设末尾光标,首次单击进入编辑时光标直接置于内容末尾,再次点击编辑器内文本可将光标定位到点击位置。
* `TabControl` 可关闭标签(`TabItem.onClose`)的关闭按钮固定到标签**最右缘**:悬停时出现在右缘(不再跟在文字后面),图标+文字改为左对齐,`Expanded` 文字吸收宽度变化,按钮出现/消失时文字位置不跳动;非可关闭标签保持原有居中布局。
* `Input` 新增 `obscureToggle` 参数：配合 `obscureText` 时在输入框右缘渲染自绘眼睛按钮，点击在掩码点与明文之间切换（密码可见性）；hover / pressed 由 `hoverOverlayColor` / `pressedOverlayColor` 基于控件底色派生（明暗自适应），无 Material 水波纹与点击动画，点击不抢占输入框焦点；外部关闭 `obscureText` 时自动重置切换状态。
* `TabControl` 重绘为经典 WinForms 样式:控件色(control)标签条 + 底部发丝线;选中标签用 surface 底色、比未选中高 2px 且下探 1px 压住发丝线，与下方带边框的页面面板无缝连成一体(面板不画顶边，顶边由标签条底线 + 选中标签覆盖);未选中标签融入条底色，hover 由条底色派生(明暗自适应)。标签外形改自绘 `_TabChrome`(圆角顶 + 三边描边)，文本恢复常规字重，移除 accent 下划线。**移除 `showUnderline` 参数**(WinForms 无下划线语义);纯标签条场景(所有 `TabItem.child` 为 null)不再渲染页面面板与底线，仅保留标签条。
* 修复 `ComboBox` 嵌入 `DialogBox` 时崩溃：内部 `LayoutBuilder` 与 `DialogBox` 的 `IntrinsicHeight` 冲突（"LayoutBuilder does not support returning intrinsic dimensions"，如 db_lite 新建连接 SQL Server 表单）。改为 `GlobalKey` 按需测量实际渲染宽度（下拉面板只在布局完成后才会打开，测量安全），顺带修复无界宽度约束下弹层宽度变为无穷大的隐患。
* 新增 `ToolbarButton`（menus）：独立可用的工具栏按钮（图标 + 文本 / 仅图标），自绘 hover / pressed / 禁用态，支持 `iconColor` 功能强调色、`showCaret` 下拉箭头、`outlined` 边框触发器样式、`textMaxWidth` 窄条省略，无 Material 水波纹与点击动画。区别于数据模型 `ToolStripButton`，可挂在任意布局中。
* `IconBtn` 重写为自绘实现（不再委托 `Button`）：新增 `child`（任意内容，如 `CustomPaint` 图标）、`selected` / `selectedColor`（accent 淡底选中态）、`outline`（边框）、`size`（固定命中区）参数，保留原 API 兼容；含 Focus + Enter/Space 键盘激活。
* 新增 `ListItem`（lists）：高密度列表行（前置图标 + 标题 + 尾随），`selectedColor` 支持浅底选中（文字保持前景色，树形场景），选中由 `Listener.onPointerDown` 零延迟触发，双击单独挂 `GestureDetector`。
* 新增 `SelectableCard`（common）：可选卡片（内容 + 选中淡底 + 右上对勾圆标），禁用时整体降透明并显示 `disabledLabel` 角标，`PointerDown` 选中 + 双击动作。
* 新增 `ExpandableSearch`（form）：可展开搜索框（收起为放大镜按钮 → 展开输入框），失焦且内容为空自动收起。
* 新增 `InlineEditor`（form）：单元格内联编辑器（自动聚焦，Enter / 失焦提交，Esc 取消，防双触发）；新增 `onChanged` 回调，每次文本变化时触发（可用于实时标记 dirty）。
* `TabControl` 增强：`TabItem` 新增 `onClose`（悬浮显示关闭按钮）/ `width`（固定宽度）/ `contextMenuItems`（逐标签右键菜单）；`TabControl` 新增 `tabBarColor` / `selectedTabColor` / `hoverTabColor` / `showUnderline`（可关） / `barHeight` / `tabWidth` / `scrollStep`，标签溢出时两侧滚动箭头，选中下划线去掉 `AnimatedContainer` 动画。
* `DataGridView` 增强：新增 `showRowNumbers` / `rowNumberWidth` / `rowNumberBuilder`（行号列，按下选中整行）、`selectedCell` / `onCellSelected` / `onCellTap` / `onCellDoubleTap` / `onCellContext`（单元格选中 / 单击 / 双击 / 右键，选中与单击由 `Listener.onPointerDown` 零延迟触发）、`headerColor` / `gridLineColor` / `selectedTextColor` / `cellPaddingX` / `headerFontSize` / `rowHoverColor`（行 hover 自持，避免整页重建）。
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

* 新增 `FieldRow`：横向表单行（左 label 右对齐固定宽 + 右侧控件），经典桌面(WinForms)表单布局；`label` 缺省时渲染同宽占位保持对齐。
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
