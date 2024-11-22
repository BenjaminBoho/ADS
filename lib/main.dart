import 'package:accident_data_storage/app/app_initializer.dart';
import 'package:accident_data_storage/app/app_material.dart';
import 'package:accident_data_storage/providers/accident_provider.dart';
import 'package:accident_data_storage/providers/auth_provider.dart';
import 'package:accident_data_storage/providers/dropdown_provider.dart';
import 'package:accident_data_storage/providers/stakeholder_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/supabase_service.dart';

Future<void> main() async {
  await initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccidentProvider()),
        ChangeNotifierProvider(create: (_) => DropdownProvider()),
        ChangeNotifierProvider(create: (_) => StakeholderProvider()),
        Provider(create: (_) => SupabaseService()),
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