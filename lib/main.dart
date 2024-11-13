import 'package:accident_data_storage/app/app_initializer.dart';
import 'package:accident_data_storage/app/app_material.dart';
import 'package:accident_data_storage/providers/accident_provider.dart';
import 'package:accident_data_storage/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccidentProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppMaterial();
  }
}