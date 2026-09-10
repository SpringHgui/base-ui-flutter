import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  // 宿主(如 db_lite 对象面板)曾手绘 `Row(mainAxisSize.min)` + `Flexible(Text)`
  // + 按钮做居中提示:Flexible 会把整行撑到容器全宽,长错误文本被挤成一行
  // 省略号、重试按钮贴到容器右缘甚至被裁掉。Empty 的 maxWidth 用于替代该写法。
  const error =
      "MySQLServerException [1142]: SELECT command denied to user "
      "'prod_nd'@'10.0.0.8' for table 'user'";
  // 必然超过 520px 的长文本(用于对比 maxWidth 生效与否)
  final longError = '$error ${'详细原因说明,' * 40}';

  // 测试画布默认 800x600,容器中心即 (400, 300)
  const centerX = 400.0;

  Future<void> pumpEmpty(
    WidgetTester tester, {
    required String description,
    double? maxWidth,
  }) =>
      tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Empty(
            icon: const Icon(Icons.error_outline),
            title: '角色列表读取失败',
            description: description,
            action: Button(text: '重试', onPressed: () {}),
            compact: true,
            maxWidth: maxWidth,
          ),
        ),
      ));

  testWidgets('maxWidth 限制内容列宽度,重试按钮留在居中块内', (tester) async {
    await pumpEmpty(tester, description: longError, maxWidth: 520);

    // 长文本在 maxWidth 内换行,不再撑满整个容器
    expect(tester.getSize(find.text(longError)).width, lessThanOrEqualTo(520));
    // 整块水平居中:按钮中心 = 容器中心(旧写法会被推到容器右缘)
    final retry = tester.getCenter(find.text('重试'));
    expect(retry.dx, closeTo(centerX, 0.5));
    // 按钮在文本下方,不与文本抢同一行宽度
    expect(retry.dy, greaterThan(tester.getRect(find.text(longError)).bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('未指定 maxWidth 时不限制宽度(既有调用行为不变)', (tester) async {
    await pumpEmpty(tester, description: longError);

    expect(tester.getSize(find.text(longError)).width, greaterThan(520));
    expect(tester.takeException(), isNull);
  });

  testWidgets('短文本仍按内容自适应宽度', (tester) async {
    await pumpEmpty(tester, description: error, maxWidth: 520);

    expect(tester.getSize(find.text(error)).width, lessThanOrEqualTo(520));
    expect(tester.getCenter(find.text('重试')).dx, closeTo(centerX, 0.5));
    expect(tester.takeException(), isNull);
  });
}
