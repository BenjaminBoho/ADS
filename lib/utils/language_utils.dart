import 'package:flutter/foundation.dart';

String getDeviceLanguage() {
  String locale = PlatformDispatcher.instance.locale.toString();
  
  return locale.split('_').first;
}

Language getLanguageEnum() {
  switch (getDeviceLanguage()) {
    case 'en':
      return Language.en;
    case 'ja':
    default:
      return Language.ja;
  }
}

enum Language { ja, en }

String formatDate(int accidentYear, String formattedMonth, String formattedHour) {
  switch (getLanguageEnum()) {
    case Language.en:
      return '$formattedMonth/$accidentYear $formattedHour:00';
    case Language.ja:
    return '$accidentYear年$formattedMonth月 $formattedHour時';
  }
}