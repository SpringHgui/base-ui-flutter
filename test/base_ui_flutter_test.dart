import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  group('DesktopTokens', () {
    test('ships a WinForm-style default preset', () {
      const t = DesktopTokens.winForm;

      expect(t.primaryColor, const Color(0xFF0F6CBD));
      expect(t.backgroundColor, const Color(0xFFF0F0F0));
      expect(t.foregroundColor, const Color(0xFF000000));
      expect(t.borderColor, const Color(0xFFACACAC));
      expect(t.surfaceColor, const Color(0xFFFFFFFF));
      expect(t.controlColor, const Color(0xFFF0F0F0));
      expect(t.fontFamily, 'Microsoft YaHei');
      expect(t.fontSize, 13.0);
      expect(t.controlHeight, 28.0);
      expect(t.cornerRadius, 0.0);
    });

    test('copyWith overrides individual values', () {
      const t = DesktopTokens.winForm;
      final rounded = t.copyWith(
        cornerRadius: 6.0,
        primaryColor: const Color(0xFF0078D7),
      );

      expect(rounded.cornerRadius, 6.0);
      expect(rounded.primaryColor, const Color(0xFF0078D7));
      expect(rounded.backgroundColor, t.backgroundColor);
    });

    test('implements value equality', () {
      expect(const DesktopTokens(), DesktopTokens.winForm);
      expect(DesktopTokens.winForm.copyWith(), DesktopTokens.winForm);
      expect(
        const DesktopTokens(cornerRadius: 6.0),
        isNot(const DesktopTokens()),
      );
    });
  });
}
