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
