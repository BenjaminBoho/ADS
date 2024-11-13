import 'package:accident_data_storage/app/app_initializer.dart';
import 'package:accident_data_storage/app/app_material.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppMaterial();
  }
}