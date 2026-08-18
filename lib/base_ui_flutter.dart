// base_ui_flutter — The Radix of Flutter Desktop.
//
// Headless, atomic, token-driven UI infrastructure for desktop-class Flutter
// applications such as HIS, ERP, and industrial HMI systems.
//
// ## Architecture contract
//
// - **Headless** — component cores carry zero visual code (no colors, fonts,
//   or spacing); they provide interaction logic, state, and keyboard
//   navigation only.
// - **Atomic** — styles are resolved at build time, so the runtime keeps a
//   plain widget tree with no style-parsing overhead.
// - **Token-driven** — every visual decision is owned by `DesktopTokens`;
//   swap the token set (or wrap a subtree in a `TokenScope`) to re-theme.
//
// ## Namespaces
//
// - `foundation` — Design tokens, token scope, control base class, focus,
//   overlay primitives.
// - `common`     — Basic input controls (button, input, label, check, combo…)
//   plus the modern supplements (typography, toggle, tag, field…).
// - `lists`      — List / grid / tree / property controls.
// - `containers` — GroupBox, TabControl, SplitContainer, Accordion, Sheet…
// - `menus`      — Menu bar, context menu, toolbar, status bar.
// - `overlay`    — Popover, MessageBox, Command, Toast, HoverCard…
// - `dialogs`    — Colour picker, date/time picker, month calendar.
// - `data`       — Data-binding navigator, charts, pagination.
// - `scroll`     — Scroll bars, track bar.
// - `misc`       — Progress bar, rich text, tool tip, chat, questionnaire…

// ── Foundation ──────────────────────────────────────────────────────────────
export 'src/foundation/desktop_tokens.dart';
export 'src/foundation/token_scope.dart';
export 'src/foundation/responsive_token_scope.dart';
export 'src/foundation/control.dart';
export 'src/foundation/roving_tabindex.dart';
export 'src/foundation/token_extensions.dart';
export 'src/foundation/overlay.dart';

// ── Common Controls ─────────────────────────────────────────────────────────
export 'src/common/button.dart';
export 'src/common/input.dart';
export 'src/common/label.dart';
export 'src/common/check_box.dart';
export 'src/common/radio_button.dart';
export 'src/common/combo_box.dart';
export 'src/common/link_label.dart';
export 'src/common/masked_text_box.dart';
export 'src/common/numeric_up_down.dart';
export 'src/common/domain_up_down.dart';

// ── Common — modern supplements ─────────────────────────────────────────────
export 'src/common/surface.dart';
export 'src/common/typography.dart';
export 'src/common/kbd.dart';
export 'src/common/separator.dart';
export 'src/common/tag.dart';
export 'src/common/field.dart';
export 'src/common/item.dart';
export 'src/common/marker.dart';
export 'src/common/button_group.dart';
export 'src/common/input_group.dart';
export 'src/common/textarea.dart';
export 'src/common/toggle.dart';
export 'src/common/toggle_group.dart';
export 'src/common/toggle_switch.dart';
export 'src/common/input_otp.dart';

// ── Lists & Data Display ────────────────────────────────────────────────────
export 'src/lists/list_box.dart';
export 'src/lists/checked_list_box.dart';
export 'src/lists/list_view.dart';
export 'src/lists/tree_view.dart';
export 'src/lists/data_grid_view.dart';
export 'src/lists/property_grid.dart';

// ── Containers ──────────────────────────────────────────────────────────────
export 'src/containers/group_box.dart';
export 'src/containers/tab_control.dart';
export 'src/containers/split_container.dart';
export 'src/containers/accordion.dart';
export 'src/containers/collapsible.dart';
export 'src/containers/sheet.dart';
export 'src/containers/side_panel.dart';
export 'src/containers/sidebar.dart';
export 'src/containers/carousel.dart';

// ── Menus & Toolbars ────────────────────────────────────────────────────────
export 'src/menus/menu_strip.dart';
export 'src/menus/context_menu_strip.dart';
export 'src/menus/tool_strip.dart';
export 'src/menus/status_strip.dart';

// ── Overlay components ──────────────────────────────────────────────────────
export 'src/overlay/popover.dart';
export 'src/overlay/hover_card.dart';
export 'src/overlay/drop_down_button.dart';
export 'src/overlay/message_box.dart';
export 'src/overlay/command.dart';
export 'src/overlay/toast.dart';
export 'src/overlay/direction.dart';
export 'src/overlay/empty.dart';

// ── Dialogs ─────────────────────────────────────────────────────────────────
export 'src/dialogs/color_dialog.dart';
export 'src/dialogs/date_time_picker.dart';
export 'src/dialogs/month_calendar.dart';
export 'src/dialogs/theme_designer.dart';

// ── Data Components ─────────────────────────────────────────────────────────
export 'src/data/binding_navigator.dart';
export 'src/data/chart.dart';
export 'src/data/pagination.dart';

// ── Scroll Bars & Sliders ───────────────────────────────────────────────────
export 'src/scroll/scroll_bar.dart';
export 'src/scroll/track_bar.dart';

// ── Miscellaneous ───────────────────────────────────────────────────────────
export 'src/misc/progress_bar.dart';
export 'src/misc/rich_text_box.dart';
export 'src/misc/scrollable_control.dart';
export 'src/misc/tool_tip.dart';
export 'src/misc/error_provider.dart';
export 'src/misc/alert.dart';
export 'src/misc/attachment.dart';
export 'src/misc/avatar.dart';
export 'src/misc/breadcrumb.dart';
export 'src/misc/bubble.dart';
export 'src/misc/message.dart';
export 'src/misc/message_scroller.dart';
export 'src/misc/questionnaire.dart';
export 'src/misc/skeleton.dart';
export 'src/misc/spinner.dart';
