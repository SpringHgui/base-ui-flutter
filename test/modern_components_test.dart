import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:base_ui_flutter/base_ui_flutter.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Supplements', () {
    testWidgets('TypeStyle renders all variants', (tester) async {
      await tester.pumpWidget(wrap(const Column(children: [
        TypeStyle.h1('H1'),
        TypeStyle.h2('H2'),
        TypeStyle.p('P'),
        TypeStyle.muted('Muted'),
        TypeStyle.code('Code'),
      ])));
      expect(find.text('H1'), findsOneWidget);
      expect(find.text('Code'), findsOneWidget);
    });

    testWidgets('Kbd renders key name', (tester) async {
      await tester.pumpWidget(wrap(const Kbd('Ctrl')));
      expect(find.text('Ctrl'), findsOneWidget);
    });

    testWidgets('Separator renders horizontal and vertical', (tester) async {
      await tester.pumpWidget(wrap(const Column(children: [
        Text('A'),
        Separator(),
        SizedBox(height: 40, child: Separator(orientation: Axis.vertical)),
      ])));
      expect(find.byType(Separator), findsNWidgets(2));
    });

    testWidgets('Tag renders variants', (tester) async {
      await tester.pumpWidget(wrap(const Wrap(children: [
        Tag('Primary'),
        Tag('Outline', variant: TagVariant.outline),
        Tag('Danger', variant: TagVariant.destructive),
      ])));
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Danger'), findsOneWidget);
    });

    testWidgets('Field shows label, description and error', (tester) async {
      await tester.pumpWidget(wrap(const Column(children: [
        Field(
          label: 'Email',
          description: 'Helper',
          children: [Input(hint: 'hint')],
        ),
        Field(
          label: 'Password',
          error: 'Too short',
          children: [Input(hint: 'hint')],
        ),
      ])));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Helper'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Too short'), findsOneWidget);
    });

    testWidgets('Item fires onSelect', (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        wrap(Item(text: 'Save', onSelect: () => selected++)),
      );
      await tester.tap(find.text('Save'));
      expect(selected, 1);
    });

    testWidgets('Marker highlights text', (tester) async {
      await tester.pumpWidget(wrap(const Marker('Highlighted')));
      expect(find.text('Highlighted'), findsOneWidget);
    });

    testWidgets('ButtonGroup joins children', (tester) async {
      await tester.pumpWidget(wrap(const ButtonGroup(children: [
        Button(text: 'A', onPressed: null),
        Button(text: 'B', onPressed: null),
      ])));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('InputGroup renders add-ons', (tester) async {
      await tester.pumpWidget(wrap(const InputGroup(
        leading: InputGroupAddon(Icon(Icons.search)),
        trailing: InputGroupAddon(Text('USD')),
        child: Input(hint: 'Amount'),
      )));
      expect(find.text('USD'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Textarea edits and reports onChanged', (tester) async {
      String? changed;
      await tester.pumpWidget(
        wrap(Textarea(hint: 'Notes', onChanged: (v) => changed = v)),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(changed, 'hello');
    });

    testWidgets('Toggle toggles on tap', (tester) async {
      var selected = false;
      await tester.pumpWidget(
        wrap(Toggle(
          selected: selected,
          onChanged: (v) => selected = v,
          child: const Icon(Icons.format_bold),
        )),
      );
      await tester.tap(find.byType(Toggle));
      expect(selected, isTrue);
    });

    testWidgets('ToggleGroup manages single selection', (tester) async {
      List<String> values = const ['a'];
      await tester.pumpWidget(
        wrap(ToggleGroup<String>(
          values: values,
          onChanged: (v) => values = v,
          children: const [
            ToggleGroupItem(value: 'a', child: Text('A')),
            ToggleGroupItem(value: 'b', child: Text('B')),
          ],
        )),
      );
      await tester.tap(find.text('B'));
      expect(values, ['b']);
    });

    testWidgets('ToggleGroup single mode cannot be deselected', (tester) async {
      List<String> values = const ['a'];
      await tester.pumpWidget(
        wrap(ToggleGroup<String>(
          values: values,
          onChanged: (v) => values = v,
          children: const [
            ToggleGroupItem(value: 'a', child: Text('A')),
            ToggleGroupItem(value: 'b', child: Text('B')),
          ],
        )),
      );
      await tester.tap(find.text('A'));
      expect(values, ['a']);
    });

    testWidgets('Surface activates via keyboard Enter', (tester) async {
      var activated = 0;
      await tester.pumpWidget(
        wrap(Item(text: 'Run', onSelect: () => activated++)),
      );
      // Focus the item through keyboard traversal, then activate.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(activated, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(activated, 2);
    });

    testWidgets('ToggleSwitch toggles on tap', (tester) async {
      var value = false;
      await tester.pumpWidget(
        wrap(ToggleSwitch(value: value, onChanged: (v) => value = v)),
      );
      await tester.tap(find.byType(ToggleSwitch));
      expect(value, isTrue);
    });

    testWidgets('InputOtp collects digits', (tester) async {
      String? completed;
      await tester.pumpWidget(
        wrap(InputOtp(length: 4, onCompleted: (v) => completed = v)),
      );
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();
      expect(completed, '1234');
      expect(find.text('1'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });
  });

  group('Containers', () {
    testWidgets('GroupBox renders title and content', (tester) async {
      await tester.pumpWidget(wrap(const GroupBox(
        title: 'Settings',
        footer: Text('Footer'),
        child: Text('Body'),
      )));
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('TabControl switches pages', (tester) async {
      await tester.pumpWidget(wrap(const TabControl(tabs: [
        TabItem(label: 'One', child: Text('Page one')),
        TabItem(label: 'Two', child: Text('Page two')),
      ])));
      expect(find.text('Page one'), findsOneWidget);
      await tester.tap(find.text('Two'));
      await tester.pump();
      expect(find.text('Page two'), findsOneWidget);
    });

    testWidgets('SplitContainer renders both panes', (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        width: 300,
        height: 200,
        child: SplitContainer(
          first: const Text('Left'),
          second: const Text('Right'),
        ),
      )));
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('SplitContainer survives tiny viewports', (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        width: 20,
        height: 10,
        child: SplitContainer(
          first: const Text('L'),
          second: const Text('R'),
        ),
      )));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Accordion expands on header tap', (tester) async {
      await tester.pumpWidget(wrap(const Accordion(items: [
        AccordionItem(value: 'a', title: 'Title', child: Text('Body')),
      ])));
      expect(find.text('Body'), findsNothing);
      await tester.tap(find.text('Title'));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('Collapsible expands on trigger tap', (tester) async {
      var open = false;
      await tester.pumpWidget(
        wrap(Collapsible(
          open: open,
          onOpenChanged: (v) => open = v,
          trigger: const Text('Toggle'),
          child: const Text('Secret'),
        )),
      );
      await tester.tap(find.text('Toggle'));
      expect(open, isTrue);
    });

    testWidgets('Sheet opens via controller', (tester) async {
      final controller = OverlayController();
      await tester.pumpWidget(wrap(Sheet(
        controller: controller,
        content: const Text('Sheet content'),
      )));
      controller.open();
      await tester.pumpAndSettle();
      expect(find.text('Sheet content'), findsOneWidget);
      controller.close();
      await tester.pumpAndSettle();
      expect(find.text('Sheet content'), findsNothing);
    });

    testWidgets('SidePanel opens via trigger', (tester) async {
      await tester.pumpWidget(wrap(SidePanel(
        trigger: const Button(text: 'Open', onPressed: null),
        content: const Text('Panel content'),
      )));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Panel content'), findsOneWidget);
    });

    testWidgets('Sidebar renders items', (tester) async {
      await tester.pumpWidget(wrap(const Sidebar(
        header: Text('App'),
        footer: SidebarItem(label: 'Logout'),
        children: [SidebarItem(label: 'Home'), SidebarItem(label: 'Docs')],
      )));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('Carousel renders pages and dots', (tester) async {
      await tester.pumpWidget(wrap(const Carousel(children: [
        Text('Page A'),
        Text('Page B'),
        Text('Page C'),
      ])));
      expect(find.text('Page A'), findsOneWidget);
    });
  });

  group('Overlay', () {
    testWidgets('Popover opens on trigger tap', (tester) async {
      await tester.pumpWidget(wrap(Popover(
        trigger: const Button(text: 'Trigger', onPressed: null),
        content: const Text('Popover content'),
      )));
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      expect(find.text('Popover content'), findsOneWidget);
    });

    testWidgets('HoverCard opens on hover', (tester) async {
      await tester.pumpWidget(wrap(HoverCard(
        trigger: const Text('Hover me'),
        content: const Text('Card content'),
      )));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: tester.getCenter(find.text('Hover me')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Card content'), findsOneWidget);
      await gesture.removePointer();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Card content'), findsNothing);
    });

    testWidgets('DropDownButton opens menu', (tester) async {
      await tester.pumpWidget(wrap(DropDownButton(
        trigger: const Button(text: 'Menu', onPressed: null),
        items: [Item(text: 'Edit', onSelect: null)],
      )));
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('DropDownButton closes after selecting an item', (tester) async {
      var selected = 0;
      await tester.pumpWidget(wrap(DropDownButton(
        trigger: const Button(text: 'Menu', onPressed: null),
        items: [Item(text: 'Edit', onSelect: () => selected++)],
      )));
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('MessageBox.show returns result', (tester) async {
      MessageBoxResult? result;
      await tester.pumpWidget(wrap(Builder(
        builder: (context) => Button(
          text: 'Confirm',
          onPressed: () async {
            result = await MessageBox.show(
              context,
              title: 'Delete?',
              message: 'Sure?',
              buttons: MessageBoxButtons.okCancel,
            );
          },
        ),
      )));
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(result, MessageBoxResult.ok);
    });

    testWidgets('Command filters items', (tester) async {
      await tester.pumpWidget(wrap(Command(
        trigger: const Button(text: 'Palette', onPressed: null),
        children: const [
          CommandItem(text: 'New file', onSelect: null),
          CommandItem(text: 'Open settings', onSelect: null),
        ],
      )));
      await tester.tap(find.text('Palette'));
      await tester.pumpAndSettle();
      expect(find.text('New file'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'settings');
      await tester.pumpAndSettle();
      expect(find.text('Open settings'), findsOneWidget);
      expect(find.text('New file'), findsNothing);
    });

    testWidgets('Command shows empty state for no matches', (tester) async {
      await tester.pumpWidget(wrap(Command(
        trigger: const Button(text: 'Palette', onPressed: null),
        children: const [CommandItem(text: 'New file', onSelect: null)],
      )));
      await tester.tap(find.text('Palette'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('ToastHost shows and dismisses toasts', (tester) async {
      await tester.pumpWidget(wrap(ToastHost(
        child: Builder(
          builder: (context) => Button(
            text: 'Show',
            onPressed: () => ToastHost.of(context)
                .show(const ToastData(title: 'Saved', description: 'OK')),
          ),
        ),
      )));
      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
      // Let the auto-dismiss timer fire before the test ends.
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('Direction applies RTL', (tester) async {
      await tester.pumpWidget(wrap(const Direction(
        textDirection: TextDirection.rtl,
        child: Text('مرحبا'),
      )));
      expect(find.text('مرحبا'), findsOneWidget);
    });

    testWidgets('Empty renders title', (tester) async {
      await tester.pumpWidget(wrap(const Empty(
        icon: Icon(Icons.inbox),
        title: 'No data',
        description: 'Nothing here yet',
      )));
      expect(find.text('No data'), findsOneWidget);
    });
  });

  group('Data', () {
    testWidgets('Chart renders all types', (tester) async {
      await tester.pumpWidget(wrap(const Column(children: [
        Chart(
          type: ChartType.bar,
          data: [ChartDatum('A', 10), ChartDatum('B', 20)],
        ),
        Chart(
          type: ChartType.line,
          data: [ChartDatum('A', 10), ChartDatum('B', 20)],
        ),
        Chart(
          type: ChartType.donut,
          data: [ChartDatum('X', 30), ChartDatum('Y', 70)],
          height: 120,
        ),
      ])));
      expect(find.byType(Chart), findsNWidgets(3));
    });

    testWidgets('Pagination navigates', (tester) async {
      int? page;
      await tester.pumpWidget(wrap(Pagination(
        pageCount: 10,
        currentPage: 0,
        onPageChanged: (p) => page = p,
      )));
      await tester.tap(find.byIcon(Icons.chevron_right));
      expect(page, 1);
    });
  });

  group('Misc', () {
    testWidgets('Alert renders info and destructive', (tester) async {
      await tester.pumpWidget(wrap(const Column(children: [
        Alert(title: 'Info', description: 'Text'),
        Alert(
          variant: AlertVariant.destructive,
          title: 'Error',
          description: 'Text',
        ),
      ])));
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('Attachment removes', (tester) async {
      var removed = 0;
      await tester.pumpWidget(wrap(Attachment(
        name: 'file.pdf',
        onRemove: () => removed++,
      )));
      expect(find.text('file.pdf'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      expect(removed, 1);
    });

    testWidgets('Avatar shows fallback initial', (tester) async {
      await tester.pumpWidget(wrap(const Avatar(fallback: 'JD')));
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('Breadcrumb renders trail', (tester) async {
      await tester.pumpWidget(wrap(const Breadcrumb(items: [
        BreadcrumbItem('Home', onTap: null),
        BreadcrumbItem('Docs'),
      ])));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Docs'), findsOneWidget);
    });

    testWidgets('Bubble renders and aligns mine', (tester) async {
      await tester.pumpWidget(wrap(const Column(children: [
        Bubble(text: 'Hello'),
        Bubble(text: 'Hi', isMine: true),
      ])));
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Hi'), findsOneWidget);
    });

    testWidgets('Message renders sender and bubble', (tester) async {
      await tester.pumpWidget(wrap(const Message(
        sender: 'Alice',
        time: '09:00',
        text: 'Hello there',
      )));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Hello there'), findsOneWidget);
    });

    testWidgets('MessageScroller renders messages', (tester) async {
      await tester.pumpWidget(wrap(const MessageScroller(
        height: 200,
        children: [
          Message(sender: 'A', text: 'One'),
          Message(sender: 'B', text: 'Two'),
        ],
      )));
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('Questionnaire submits answers', (tester) async {
      Map<String, Object?>? answers;
      await tester.pumpWidget(wrap(Questionnaire(
        questions: const [
          QuestionnaireQuestion(
            id: 'q1',
            title: 'Pick one',
            type: QuestionType.single,
            options: ['A', 'B'],
          ),
        ],
        onSubmit: (a) => answers = a,
      )));
      await tester.tap(find.text('A'));
      await tester.tap(find.text('Submit'));
      expect(answers?['q1'], 'A');
    });

    testWidgets('Skeleton renders and pulses', (tester) async {
      await tester.pumpWidget(wrap(const Skeleton(width: 100, height: 20)));
      expect(find.byType(Skeleton), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Spinner renders', (tester) async {
      await tester.pumpWidget(wrap(const Spinner()));
      expect(find.byType(Spinner), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  });
}
