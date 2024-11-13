import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  Future<bool> login(String email, String password) async {
    return await _supabaseService.login(email, password);
  }
}