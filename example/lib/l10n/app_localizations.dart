import 'package:flutter/material.dart';

import 'translations_en.dart';
import 'translations_zh.dart';
import 'translations_ja.dart';

/// Supported locales in the example app.
const List<Locale> kSupportedLocales = [
  Locale('en'),
  Locale('zh'),
  Locale('ja'),
];

/// Display names for each locale (shown in the language switcher).
final Map<Locale, String> kLocaleNames = {
  const Locale('en'): 'English',
  const Locale('zh'): '中文',
  const Locale('ja'): '日本語',
};

/// Simple InheritedWidget-based localisation system.
///
/// Usage:
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// Text(l10n.t('gallery.title'));
/// ```
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)
        ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<Locale, Map<String, String>> _translations = {
    const Locale('en'): enTranslations,
    const Locale('zh'): zhTranslations,
    const Locale('ja'): jaTranslations,
  };

  /// Look up a translated string by [key].
  /// Falls back to English, then returns the key itself.
  String t(String key) {
    return _translations[locale]?[key]
        ?? _translations[const Locale('en')]?[key]
        ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      kSupportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Convenience extension for translating strings with parameter substitution.
extension L10n on BuildContext {
  /// Shorthand for `AppLocalizations.of(this).t(key)`.
  String tr(String key) => AppLocalizations.of(this).t(key);
}
