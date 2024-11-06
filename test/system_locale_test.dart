import 'package:intl/intl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

void main() async {
  test('Check system locale value', () {
    String systemLocale = Intl.systemLocale;

    // Check that the system locale is not empty
    expect(systemLocale, isNotEmpty,
        reason: 'System locale should not be empty');

    // Optional: Check the format of the system locale (e.g., en_US)
    expect(systemLocale, matches(RegExp(r'^[a-z]{2}(_[A-Z]{2})?$')),
        reason:
            'System locale should follow the pattern "xx_XX" (e.g., en_US)');

    // Print the system locale for debugging
    if (kDebugMode) {
      print('System locale: $systemLocale');
    }
  });
}