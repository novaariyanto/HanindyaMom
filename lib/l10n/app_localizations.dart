import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _strings;

  AppLocalizations(this.locale, this._strings);

  static const List<Locale> supportedLocales = [
    Locale('id', 'ID'),
    Locale('en', 'US'),
  ];

  static Future<AppLocalizations> load(Locale locale) async {
    // Fallback ke 'id' jika tidak didukung
    final languageCode = supportedLocales.any((l) => l.languageCode == locale.languageCode)
        ? locale.languageCode
        : 'id';

    final path = 'assets/lang/' + languageCode + '.json';
    final data = await rootBundle.loadString(path);
    final Map<String, dynamic> map = json.decode(data) as Map<String, dynamic>;
    final flat = map.map((key, value) => MapEntry(key, value.toString()));
    return AppLocalizations(Locale(languageCode), flat);
  }

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(loc != null, 'No AppLocalizations found in context');
    return loc!;
  }

  String tr(String key, [Map<String, String>? params]) {
    String s = _strings[key] ?? key;
    if (params != null && params.isNotEmpty) {
      params.forEach((k, v) {
        s = s.replaceAll('{$k}', v);
      });
    }
    return s;
  }

  String get dateLocaleTag {
    // Intl membutuhkan format xx_XX
    if (locale.languageCode == 'en') return 'en_US';
    return 'id_ID';
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension BuildContextLocalizationX on BuildContext {
  String tr(String key, [Map<String, String>? params]) => AppLocalizations.of(this).tr(key, params);
}


