import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 「1 设备像素」发丝边框的守护测试。
///
/// VCL / WinForms 的原生控件边框恒为 **1 物理像素**,与显示缩放无关。令牌里的
/// [DesktopTokens.borderWidth] 是逻辑像素,所以 200% 缩放下必须收成 0.5,
/// 否则会画成 2 个物理像素 —— 比参照的 Navicat 粗一倍。
void main() {
  Widget host(
    Widget child,
    DesktopTokens tokens, [
    void Function(BuildContext)? onCtx,
  ]) =>
      MaterialApp(
        home: TokenScope(
          tokens: tokens,
          child: Material(
            type: MaterialType.transparency,
            child: Builder(builder: (context) {
              onCtx?.call(context);
              return Align(alignment: Alignment.topLeft, child: child);
            }),
          ),
        ),
      );

  group('devicePixelHairlineOf', () {
    testWidgets('100% 下不变,高 DPI 下按比例收窄', (tester) async {
      addTearDown(tester.view.reset);
      late double value;

      Future<double> at(double dpr) async {
        tester.view.devicePixelRatio = dpr;
        await tester.pumpWidget(host(
          const SizedBox(),
          DesktopTokens.winForm,
          (c) => value = DesktopTokens.devicePixelHairlineOf(c),
        ));
        return value;
      }

      expect(await at(1.0), 1.0, reason: '100% 下 1 逻辑像素 == 1 物理像素,不该改');
      expect(await at(2.0), 0.5, reason: '200% 下要收到半个逻辑像素才是 1 物理像素');
      expect(await at(1.5), closeTo(2 / 3, 1e-9));
      expect(await at(8.0), 0.25, reason: '下限兜底,免得极端缩放下边框细到看不见');
    });

    testWidgets('withHairlineBorders 只替换 borderWidth', (tester) async {
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      late DesktopTokens out;

      await tester.pumpWidget(host(
        const SizedBox(),
        DesktopTokens.winForm,
        (c) => out = DesktopTokens.winForm
            .copyWith(borderColor: const Color(0xFF123456))
            .withHairlineBorders(c),
      ));

      expect(out.borderWidth, 0.5);
      expect(out.borderColor, const Color(0xFF123456), reason: '其余字段原样保留');
    });
  });

  group('组件统一读令牌,不再写死线宽', () {
    /// 收集子树里所有 BoxDecoration 边框的上边宽度。
    List<double> borderWidths(WidgetTester tester) {
      final out = <double>[];
      for (final element in find.byType(DecoratedBox).evaluate()) {
        final decoration = (element.widget as DecoratedBox).decoration;
        if (decoration is BoxDecoration && decoration.border != null) {
          out.add(decoration.border!.top.width);
        }
      }
      return out;
    }

    testWidgets('CheckBox 的方框跟着 borderWidth 走', (tester) async {
      const t = DesktopTokens.winForm;

      await tester.pumpWidget(host(
        const CheckBox(value: true, onChanged: null, label: '启用'),
        t.copyWith(borderWidth: 1.0),
        null,
      ));
      expect(borderWidths(tester), contains(1.0));

      await tester.pumpWidget(host(
        const CheckBox(value: true, onChanged: null, label: '启用'),
        t.copyWith(borderWidth: 3.0),
        null,
      ));
      expect(borderWidths(tester), contains(3.0),
          reason: '曾经写死 width: 1,发丝边框就落不到复选框上');
    });

    testWidgets('StepBar 的连接线跟着 borderWidth 走', (tester) async {
      const t = DesktopTokens.winForm;

      await tester.pumpWidget(host(
        const StepBar(steps: ['一', '二'], currentIndex: 0),
        t.copyWith(borderWidth: 4.0),
        null,
      ));
      final heights = find
          .descendant(of: find.byType(StepBar), matching: find.byType(Container))
          .evaluate()
          .map((e) => tester.getSize(find.byWidget(e.widget)).height)
          .toList();
      expect(heights, contains(4.0),
          reason: '曾经写死 height: 1,发丝边框就落不到连接线上');
    });
  });
}
