import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kDefaultLanguage = "en";
String _kFallbackLanguage;

class GlobalTranslationsProvider extends ChangeNotifier {
  Locale _locale;
  Map<dynamic, dynamic> _localizedValues;
  Map<dynamic, dynamic> _fallbackValues;
  Map<String, String> _cache = {};
  List<String> _supportedLanguages = [];

  Iterable<Locale> supportedLocales() =>
      _supportedLanguages.map<Locale>((lang) => Locale(lang, ''));

  String text(String key, {Map<String, String> params}) {
    // Return the requested string
    String value = '** $key not found';

    if (_localizedValues != null) {
      value = _getLocalizedValue(key, _localizedValues);
      if (value == '** $key not found') {
        if (_fallbackValues != null) {
          value = _getLocalizedValue(key, _fallbackValues);
        }
      }
    }
    if (params != null) {
      value = mapParamsToTranslatedString(value, params);
    }
    return value;
  }

  String mapParamsToTranslatedString(String value, Map<String, String> params) {
    params.forEach((key, value1) {
      value = value.replaceAll('{{$key}}', value1);
    });
    return value;
  }

  _getLocalizedValue(key, Map<dynamic, dynamic> _values) {
    String string = '** $key not found';
    if (_cache[key] != null) {
      return _cache[key];
    }

    bool found = true;
    List<String> _keyParts = key.split('.');
    int _keyPartsLen = _keyParts.length;
    int index = 0;
    int lastIndex = _keyPartsLen - 1;

    while (index < _keyPartsLen && found) {
      var value = _values[_keyParts[index]];

      if (value == null) {
        found = false;
        break;
      }

      if (value is String && index == lastIndex) {
        string = value;

        _cache[key] = string;
        break;
      }

      _values = value;
      index++;
    }
    return string;
  }

  String get currentLanguage => _locale == null ? '' : _locale.languageCode;
  Locale get locale => _locale;

  Future<Null> init(List<String> supportedLanguages,
      {String fallbackLanguage}) async {
    if (supportedLanguages == null) {
      throw new Exception('You must provide supported languages');
    }
    _supportedLanguages = supportedLanguages;
    if (fallbackLanguage != null &&
        _supportedLanguages.indexOf(fallbackLanguage) >= 0) {
      _kFallbackLanguage = fallbackLanguage;
      String jsonContent = await rootBundle
          .loadString("assets/locale/$_kFallbackLanguage.json");
      _fallbackValues = json.decode(jsonContent);
    }
    if (_locale == null) {
      await setNewLanguage();
    }
    return null;
  }

  Future<Null> setNewLanguage([String newLanguage]) async {
    String language = newLanguage;
    var init = false;
    if (language == null) {
      language = await getPreferredLanguage();
      init = true;
    }

    if (language == '') {
      String currentLocale = Platform.localeName.toLowerCase();
      if (currentLocale.length > 2) {
        if (currentLocale[2] == "-" || currentLocale[2] == "_") {
          language = currentLocale.substring(0, 2);
        }
      }
    }

    if (!_supportedLanguages.contains(language)) {
      language = _kDefaultLanguage;
    }

    if (!init) {
      setPreferredLanguage(language);
    }

    _locale = Locale(language, "");

    String jsonContent = await rootBundle
        .loadString("assets/locale/${_locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);

    _cache = {};

    notifyListeners();

    return null;
  }

  Future<String> _getApplicationSavedInformation(String name) async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('lang')) {
      return '';
    }
    final preferedLang = prefs.getString('lang');
    return preferedLang;
  }

  Future<bool> _setApplicationSavedInformation(
      String name, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString('lang', value);
  }

  getPreferredLanguage() async {
    return _getApplicationSavedInformation('language');
  }

  setPreferredLanguage(String lang) async {
    final result = _setApplicationSavedInformation('language', lang);
    return result;
  }

  static final GlobalTranslationsProvider _translations =
      GlobalTranslationsProvider._internal();
  factory GlobalTranslationsProvider() {
    return _translations;
  }
  GlobalTranslationsProvider._internal();
}

GlobalTranslationsProvider translations = GlobalTranslationsProvider();
