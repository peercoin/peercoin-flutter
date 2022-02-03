import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_logs/flutter_logs.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale fallbackLocale = Locale('en');

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static late AppLocalizations instance;

  AppLocalizations._init(Locale locale) {
    instance = this;
    this.locale = locale;
  }

  static const Map<String, String> availableLocales = {
    'en': 'English',
    'hr': 'Croatian',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'nl': 'Nederlands',
    'nb': 'Norsk Bokmål',
    'pl': 'Polski',
    'pt': 'Português',
    'ro': 'Română',
    'ru': 'Русский',
    'zh': '中文 (Zhōngwén)'
  };

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Locale? locale;
  late Map<String, String> _localizedStrings;
  late Map<String, String> _fallbackLocalizedStrings;

  Future<void> load() async {
    _localizedStrings = await _loadLocalizedStrings(locale!);
    _fallbackLocalizedStrings = {};

    if (locale != fallbackLocale) {
      _fallbackLocalizedStrings = await _loadLocalizedStrings(fallbackLocale);
    }
  }

  Future<Map<String, String>> _loadLocalizedStrings(
      Locale localeToBeLoaded) async {
    String jsonString;
    var localizedStrings = <String, String>{};

    try {
      jsonString = await rootBundle.loadString(
          'assets/translations/${localeToBeLoaded.languageCode}.json');
    } catch (e) {
      FlutterLogs.logError(
        'AppLocalizations',
        '_loadLocalizedStrings',
        e.toString(),
      );
      return localizedStrings;
    }

    Map<String, dynamic> jsonMap = json.decode(jsonString);

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return localizedStrings;
  }

  String translate(String key, [Map<String, String?>? arguments]) {
    var translation = _localizedStrings[key];
    translation = translation ?? _fallbackLocalizedStrings[key];
    translation = translation ?? '';

    if (arguments == null || arguments.isEmpty) {
      return translation;
    }

    arguments.forEach((argumentKey, value) {
      if (value == null) {
        FlutterLogs.logWarn(
          'AppLocalizations',
          'translate',
          'Value for "$argumentKey" is null in call of translate(\'$key\')',
        );
        value = '';
      }
      translation = translation!.replaceAll('\$$argumentKey', value);
    });

    return translation ?? '';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var localizations = AppLocalizations._init(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
