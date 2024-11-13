// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:accident_data_storage/services/supabase_service.dart';

void main() async {
  // Initialize Supabase before running any tests
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  group('.env file and Supabase tests', () {
    // Test for loading .env file successfully
    test('Load .env file', () async {
      try {
        // Load the .env file
        await dotenv.load(fileName: ".env");

        // Retrieve environment variables
        final supabaseUrl = dotenv.env['SUPABASE_URL'];
        final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

        // Check if the variables are loaded and not null
        expect(supabaseUrl, isNotNull,
            reason: 'SUPABASE_URL should not be null');
        expect(supabaseAnonKey, isNotNull,
            reason: 'SUPABASE_ANON_KEY should not be null');

        // Print success message
        if (kDebugMode) {
          print('Environment variables loaded successfully');
        }
      } catch (e) {
        // If the file fails to load, throw an error
        fail('Failed to load .env file: $e');
      }
    });
  });
}
