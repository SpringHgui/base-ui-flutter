import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

// Common
import 'pages/label_page.dart';
import 'pages/input_page.dart';
import 'pages/button_page.dart';
import 'pages/check_box_page.dart';
import 'pages/radio_button_page.dart';
import 'pages/combo_box_page.dart';
import 'pages/link_label_page.dart';
import 'pages/masked_text_box_page.dart';
import 'pages/numeric_up_down_page.dart';
import 'pages/domain_up_down_page.dart';

// Lists
import 'pages/list_box_page.dart';
import 'pages/checked_list_box_page.dart';
import 'pages/list_view_page.dart';
import 'pages/tree_view_page.dart';
import 'pages/data_grid_view_page.dart';
import 'pages/property_grid_page.dart';

// Menus
import 'pages/menu_strip_page.dart';
import 'pages/tool_strip_page.dart';
import 'pages/context_menu_strip_page.dart';
import 'pages/status_strip_page.dart';

// Dialogs
import 'pages/date_time_picker_page.dart';
import 'pages/month_calendar_page.dart';
import 'pages/color_dialog_page.dart';
import 'pages/theme_designer_page.dart';

// Data
import 'pages/binding_navigator_page.dart';

// Scroll
import 'pages/scroll_bar_page.dart';
import 'pages/track_bar_page.dart';

// Misc
import 'pages/progress_bar_page.dart';
import 'pages/rich_text_box_page.dart';
import 'pages/tool_tip_page.dart';
import 'pages/error_provider_page.dart';
import 'pages/scrollable_control_page.dart';

// Supplements
import 'pages/typography_page.dart';
import 'pages/kbd_page.dart';
import 'pages/separator_page.dart';
import 'pages/tag_page.dart';
import 'pages/field_page.dart';
import 'pages/item_page.dart';
import 'pages/marker_page.dart';
import 'pages/button_group_page.dart';
import 'pages/input_group_page.dart';
import 'pages/textarea_page.dart';
import 'pages/toggle_page.dart';
import 'pages/toggle_group_page.dart';
import 'pages/toggle_switch_page.dart';
import 'pages/input_otp_page.dart';

// Containers
import 'pages/group_box_page.dart';
import 'pages/tab_control_page.dart';
import 'pages/split_container_page.dart';
import 'pages/accordion_page.dart';
import 'pages/collapsible_page.dart';
import 'pages/sheet_page.dart';
import 'pages/side_panel_page.dart';
import 'pages/sidebar_page.dart';
import 'pages/carousel_page.dart';

// Overlay
import 'pages/popover_page.dart';
import 'pages/hover_card_page.dart';
import 'pages/drop_down_button_page.dart';
import 'pages/message_box_page.dart';
import 'pages/command_page.dart';
import 'pages/toast_page.dart';
import 'pages/direction_page.dart';
import 'pages/empty_page.dart';

// Data
import 'pages/chart_page.dart';
import 'pages/pagination_page.dart';

// Misc — modern
import 'pages/alert_page.dart';
import 'pages/attachment_page.dart';
import 'pages/avatar_page.dart';
import 'pages/breadcrumb_page.dart';
import 'pages/bubble_page.dart';
import 'pages/message_page.dart';
import 'pages/message_scroller_page.dart';
import 'pages/questionnaire_page.dart';
import 'pages/skeleton_page.dart';
import 'pages/spinner_page.dart';

// Overview
// Hidden for now: shows every full example per component (very tall).
// import 'pages/all_components_page.dart';
import 'pages/quick_overview_page.dart';

import 'widgets/code_example_view.dart';

void main() {
  runApp(const ExampleApp());
}

/// Root of the example application.
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  DesktopTokens _tokens = DesktopTokens.winForm;
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'base_ui_flutter — Component Gallery',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _tokens.primaryColor,
        ),
      ),
      home: ComponentGallery(
        tokens: _tokens,
        locale: _locale,
        onTokensChanged: (t) => setState(() => _tokens = t),
        onLocaleChanged: (l) => setState(() => _locale = l),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page registry
// ---------------------------------------------------------------------------

class _PageEntry {
  const _PageEntry(this.categoryKey, this.name, this.assetPath, this.builder);
  final String categoryKey;
  final String name;

  /// Path of this page's source file within the asset bundle.
  final String assetPath;
  final WidgetBuilder builder;
}

const _pagesDir = 'lib/pages';

final List<_PageEntry> _componentPages = [
  // Common Controls
  _PageEntry('cat.common', 'Label', '$_pagesDir/label_page.dart', (context) => const LabelPage()),
  _PageEntry('cat.common', 'Input', '$_pagesDir/input_page.dart', (context) => const InputPage()),
  _PageEntry('cat.common', 'Button', '$_pagesDir/button_page.dart', (context) => const ButtonPage()),
  _PageEntry('cat.common', 'CheckBox', '$_pagesDir/check_box_page.dart', (context) => const CheckBoxPage()),
  _PageEntry('cat.common', 'RadioButton', '$_pagesDir/radio_button_page.dart', (context) => const RadioButtonPage()),
  _PageEntry('cat.common', 'ComboBox', '$_pagesDir/combo_box_page.dart', (context) => const ComboBoxPage()),
  _PageEntry('cat.common', 'LinkLabel', '$_pagesDir/link_label_page.dart', (context) => const LinkLabelPage()),
  _PageEntry('cat.common', 'MaskedTextBox', '$_pagesDir/masked_text_box_page.dart', (context) => const MaskedTextBoxPage()),
  _PageEntry('cat.common', 'NumericUpDown', '$_pagesDir/numeric_up_down_page.dart', (context) => const NumericUpDownPage()),
  _PageEntry('cat.common', 'DomainUpDown', '$_pagesDir/domain_up_down_page.dart', (context) => const DomainUpDownPage()),
  // Lists & Data
  _PageEntry('cat.lists', 'ListBox', '$_pagesDir/list_box_page.dart', (context) => const ListBoxPage()),
  _PageEntry('cat.lists', 'CheckedListBox', '$_pagesDir/checked_list_box_page.dart', (context) => const CheckedListBoxPage()),
  _PageEntry('cat.lists', 'ListView', '$_pagesDir/list_view_page.dart', (context) => const ListViewPage()),
  _PageEntry('cat.lists', 'TreeView', '$_pagesDir/tree_view_page.dart', (context) => const TreeViewPage()),
  _PageEntry('cat.lists', 'DataGridView', '$_pagesDir/data_grid_view_page.dart', (context) => const DataGridViewPage()),
  _PageEntry('cat.lists', 'PropertyGrid', '$_pagesDir/property_grid_page.dart', (context) => const PropertyGridPage()),
  // Menus & Toolbars
  _PageEntry('cat.menus', 'MenuStrip', '$_pagesDir/menu_strip_page.dart', (context) => const MenuStripPage()),
  _PageEntry('cat.menus', 'ToolStrip', '$_pagesDir/tool_strip_page.dart', (context) => const ToolStripPage()),
  _PageEntry('cat.menus', 'ContextMenuStrip', '$_pagesDir/context_menu_strip_page.dart', (context) => const ContextMenuStripPage()),
  _PageEntry('cat.menus', 'StatusStrip', '$_pagesDir/status_strip_page.dart', (context) => const StatusStripPage()),
  // Dialogs
  _PageEntry('cat.dialogs', 'DateTimePicker', '$_pagesDir/date_time_picker_page.dart', (context) => const DateTimePickerPage()),
  _PageEntry('cat.dialogs', 'MonthCalendar', '$_pagesDir/month_calendar_page.dart', (context) => const MonthCalendarPage()),
  _PageEntry('cat.dialogs', 'ColorDialog', '$_pagesDir/color_dialog_page.dart', (context) => const ColorDialogPage()),
  _PageEntry('cat.dialogs', 'ThemeDesigner', '$_pagesDir/theme_designer_page.dart', (context) => const ThemeDesignerPage()),
  // Data
  _PageEntry('cat.data', 'BindingNavigator', '$_pagesDir/binding_navigator_page.dart', (context) => const BindingNavigatorPage()),
  // Scroll
  _PageEntry('cat.scroll', 'ScrollBar', '$_pagesDir/scroll_bar_page.dart', (context) => const ScrollBarPage()),
  _PageEntry('cat.scroll', 'TrackBar', '$_pagesDir/track_bar_page.dart', (context) => const TrackBarPage()),
  // Misc
  _PageEntry('cat.misc', 'ProgressBar', '$_pagesDir/progress_bar_page.dart', (context) => const ProgressBarPage()),
  _PageEntry('cat.misc', 'RichTextBox', '$_pagesDir/rich_text_box_page.dart', (context) => const RichTextBoxPage()),
  _PageEntry('cat.misc', 'WinToolTip', '$_pagesDir/tool_tip_page.dart', (context) => const ToolTipPage()),
  _PageEntry('cat.misc', 'ErrorProvider', '$_pagesDir/error_provider_page.dart', (context) => const ErrorProviderPage()),
  _PageEntry('cat.misc', 'ScrollableControl', '$_pagesDir/scrollable_control_page.dart', (context) => const ScrollableControlPage()),
  // Supplements
  _PageEntry('cat.supplements', 'Typography', '$_pagesDir/typography_page.dart', (context) => const TypographyPage()),
  _PageEntry('cat.supplements', 'Kbd', '$_pagesDir/kbd_page.dart', (context) => const KbdPage()),
  _PageEntry('cat.supplements', 'Separator', '$_pagesDir/separator_page.dart', (context) => const SeparatorPage()),
  _PageEntry('cat.supplements', 'Tag', '$_pagesDir/tag_page.dart', (context) => const TagPage()),
  _PageEntry('cat.supplements', 'Field', '$_pagesDir/field_page.dart', (context) => const FieldPage()),
  _PageEntry('cat.supplements', 'Item', '$_pagesDir/item_page.dart', (context) => const ItemPage()),
  _PageEntry('cat.supplements', 'Marker', '$_pagesDir/marker_page.dart', (context) => const MarkerPage()),
  _PageEntry('cat.supplements', 'ButtonGroup', '$_pagesDir/button_group_page.dart', (context) => const ButtonGroupPage()),
  _PageEntry('cat.supplements', 'InputGroup', '$_pagesDir/input_group_page.dart', (context) => const InputGroupPage()),
  _PageEntry('cat.supplements', 'Textarea', '$_pagesDir/textarea_page.dart', (context) => const TextareaPage()),
  _PageEntry('cat.supplements', 'Toggle', '$_pagesDir/toggle_page.dart', (context) => const TogglePage()),
  _PageEntry('cat.supplements', 'ToggleGroup', '$_pagesDir/toggle_group_page.dart', (context) => const ToggleGroupPage()),
  _PageEntry('cat.supplements', 'ToggleSwitch', '$_pagesDir/toggle_switch_page.dart', (context) => const ToggleSwitchPage()),
  _PageEntry('cat.supplements', 'InputOtp', '$_pagesDir/input_otp_page.dart', (context) => const InputOtpPage()),
  // Containers
  _PageEntry('cat.containers', 'GroupBox', '$_pagesDir/group_box_page.dart', (context) => const GroupBoxPage()),
  _PageEntry('cat.containers', 'TabControl', '$_pagesDir/tab_control_page.dart', (context) => const TabControlPage()),
  _PageEntry('cat.containers', 'SplitContainer', '$_pagesDir/split_container_page.dart', (context) => const SplitContainerPage()),
  _PageEntry('cat.containers', 'Accordion', '$_pagesDir/accordion_page.dart', (context) => const AccordionPage()),
  _PageEntry('cat.containers', 'Collapsible', '$_pagesDir/collapsible_page.dart', (context) => const CollapsiblePage()),
  _PageEntry('cat.containers', 'Sheet', '$_pagesDir/sheet_page.dart', (context) => const SheetPage()),
  _PageEntry('cat.containers', 'SidePanel', '$_pagesDir/side_panel_page.dart', (context) => const SidePanelPage()),
  _PageEntry('cat.containers', 'Sidebar', '$_pagesDir/sidebar_page.dart', (context) => const SidebarPage()),
  _PageEntry('cat.containers', 'Carousel', '$_pagesDir/carousel_page.dart', (context) => const CarouselPage()),
  // Overlay
  _PageEntry('cat.overlay', 'Popover', '$_pagesDir/popover_page.dart', (context) => const PopoverPage()),
  _PageEntry('cat.overlay', 'HoverCard', '$_pagesDir/hover_card_page.dart', (context) => const HoverCardPage()),
  _PageEntry('cat.overlay', 'DropDownButton', '$_pagesDir/drop_down_button_page.dart', (context) => const DropDownButtonPage()),
  _PageEntry('cat.overlay', 'MessageBox', '$_pagesDir/message_box_page.dart', (context) => const MessageBoxPage()),
  _PageEntry('cat.overlay', 'Command', '$_pagesDir/command_page.dart', (context) => const CommandPage()),
  _PageEntry('cat.overlay', 'Toast', '$_pagesDir/toast_page.dart', (context) => const ToastPage()),
  _PageEntry('cat.overlay', 'Direction', '$_pagesDir/direction_page.dart', (context) => const DirectionPage()),
  _PageEntry('cat.overlay', 'Empty', '$_pagesDir/empty_page.dart', (context) => const EmptyPage()),
  // Data
  _PageEntry('cat.data', 'Chart', '$_pagesDir/chart_page.dart', (context) => const ChartPage()),
  _PageEntry('cat.data', 'Pagination', '$_pagesDir/pagination_page.dart', (context) => const PaginationPage()),
  // Misc — modern
  _PageEntry('cat.misc', 'Alert', '$_pagesDir/alert_page.dart', (context) => const AlertPage()),
  _PageEntry('cat.misc', 'Attachment', '$_pagesDir/attachment_page.dart', (context) => const AttachmentPage()),
  _PageEntry('cat.misc', 'Avatar', '$_pagesDir/avatar_page.dart', (context) => const AvatarPage()),
  _PageEntry('cat.misc', 'Breadcrumb', '$_pagesDir/breadcrumb_page.dart', (context) => const BreadcrumbPage()),
  _PageEntry('cat.misc', 'Bubble', '$_pagesDir/bubble_page.dart', (context) => const BubblePage()),
  _PageEntry('cat.misc', 'Message', '$_pagesDir/message_page.dart', (context) => const MessagePage()),
  _PageEntry('cat.misc', 'MessageScroller', '$_pagesDir/message_scroller_page.dart', (context) => const MessageScrollerPage()),
  _PageEntry('cat.misc', 'Questionnaire', '$_pagesDir/questionnaire_page.dart', (context) => const QuestionnairePage()),
  _PageEntry('cat.misc', 'Skeleton', '$_pagesDir/skeleton_page.dart', (context) => const SkeletonPage()),
  _PageEntry('cat.misc', 'Spinner', '$_pagesDir/spinner_page.dart', (context) => const SpinnerPage()),
];

// Hidden for now, along with the AllComponentsPage import above.
// final List<ComponentShowcaseEntry> _componentShowcaseEntries = _componentPages
//     .map((p) => ComponentShowcaseEntry(categoryKey: p.categoryKey, name: p.name, builder: p.builder))
//     .toList();

final List<_PageEntry> _pages = [
  // Overview: one example per component, all on a single screen.
  _PageEntry(
    'cat.overview',
    'Quick Overview',
    '$_pagesDir/quick_overview_page.dart',
    (context) => const QuickOverviewPage(),
  ),
  ..._componentPages,
];

// ---------------------------------------------------------------------------
// Gallery shell
// ---------------------------------------------------------------------------

class ComponentGallery extends StatefulWidget {
  const ComponentGallery({
    super.key,
    required this.tokens,
    required this.locale,
    required this.onTokensChanged,
    required this.onLocaleChanged,
  });

  final DesktopTokens tokens;
  final Locale locale;
  final ValueChanged<DesktopTokens> onTokensChanged;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: tokens.backgroundColor,
      endDrawer: SizedBox(
        width: 640,
        child: ThemeDesigner(
          tokens: tokens,
          width: 640,
          height: MediaQuery.of(context).size.height,
          onTokensChanged: widget.onTokensChanged,
          onConfirm: (t) {
            widget.onTokensChanged(t);
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
      body: TokenScope(
        tokens: tokens,
        child: Stack(
          children: [
            Column(
              children: [
                // Title bar
                Container(
                  height: tokens.controlHeight,
                  color: tokens.controlColor,
                  padding: EdgeInsets.symmetric(horizontal: tokens.controlPaddingX),
                  child: Row(
                    children: [
                      Expanded(
                        child: Label(l10n.t('gallery.title')),
                      ),
                      _LanguageSwitcher(
                        currentLocale: widget.locale,
                        onLocaleChanged: widget.onLocaleChanged,
                        tokens: tokens,
                      ),
                    ],
                  ),
                ),
                // Body
                Expanded(
                  child: Row(
                    children: [
                      // Sidebar
                      SizedBox(
                        width: 200,
                        child: _buildSidebar(tokens),
                      ),
                      // Content
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: tokens.borderColor,
                                width: tokens.borderWidth,
                              ),
                            ),
                          ),
                          child: CodeExampleView(
                            key: ValueKey(_pages[_selectedIndex].assetPath),
                            assetPath: _pages[_selectedIndex].assetPath,
                            child: _pages[_selectedIndex].builder(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Floating theme designer button
            Positioned(
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: tokens.controlHeight * 2,
                    height: tokens.controlHeight * 2,
                    decoration: BoxDecoration(
                      color: tokens.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.palette,
                      color: tokens.surfaceColor,
                      size: tokens.fontSize * 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(DesktopTokens tokens) {
    final l10n = AppLocalizations.of(context);

    // Build sidebar grouped by category
    final categories = <String>[];
    for (final page in _pages) {
      if (!categories.contains(page.categoryKey)) {
        categories.add(page.categoryKey);
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: tokens.borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Label(l10n.t('gallery.components')),
          ),
          Expanded(
            child: ScrollableControl(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final catKey in categories) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.controlPaddingX,
                        vertical: tokens.compactSpacing,
                      ),
                      child: Label(l10n.t(catKey),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis),
                    ),
                    for (int i = 0; i < _pages.length; i++)
                      if (_pages[i].categoryKey == catKey)
                        _SidebarItem(
                          text: _pages[i].name,
                          isSelected: i == _selectedIndex,
                          tokens: tokens,
                          onTap: () => setState(() => _selectedIndex = i),
                        ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.text,
    required this.isSelected,
    required this.tokens,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final DesktopTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: tokens.controlHeight * 0.9,
          padding: EdgeInsets.symmetric(horizontal: tokens.controlPaddingX * 2),
          color: isSelected ? tokens.primaryColor : Colors.transparent,
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: tokens.fontFamily,
              fontSize: tokens.fontSize,
              color: isSelected ? tokens.surfaceColor : tokens.foregroundColor,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language switcher
// ---------------------------------------------------------------------------

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher({
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.tokens,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final DesktopTokens tokens;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      offset: const Offset(0, 32),
      color: tokens.surfaceColor,
      onSelected: onLocaleChanged,
      itemBuilder: (context) => kSupportedLocales.map((locale) {
        return PopupMenuItem<Locale>(
          value: locale,
          child: Text(
            '${kLocaleNames[locale] ?? locale.languageCode}'
            '${locale == currentLocale ? " ✓" : ""}',
            style: TextStyle(
              fontFamily: tokens.fontFamily,
              fontSize: tokens.fontSize,
              color: tokens.foregroundColor,
            ),
          ),
        );
      }).toList(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, size: tokens.fontSize * 1.2,
                color: tokens.foregroundColor),
            const SizedBox(width: 4),
            Text(
              kLocaleNames[currentLocale] ?? currentLocale.languageCode,
              style: TextStyle(
                fontFamily: tokens.fontFamily,
                fontSize: tokens.fontSize,
                color: tokens.foregroundColor,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: tokens.fontSize * 1.2,
                color: tokens.foregroundColor),
          ],
        ),
      ),
    );
  }
}
