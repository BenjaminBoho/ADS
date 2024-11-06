import 'package:flutter/foundation.dart';

String getDeviceLanguage() {
  String locale = PlatformDispatcher.instance.locale.toString();
  
  return locale.split('_').first;
}