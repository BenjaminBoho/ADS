import 'package:intl/intl.dart';

String getDeviceLanguage() {
  String locale = Intl.systemLocale;
  return locale.split('_').first;
}