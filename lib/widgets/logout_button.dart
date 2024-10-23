import 'package:flutter/material.dart';
import 'package:accident_data_storage/services/supabase_service.dart';

class LogoutButton extends StatelessWidget {
  final SupabaseService supabaseService;

  const LogoutButton({super.key, required this.supabaseService});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        bool? confirmLogout = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Center(child: Text('ログアウト')),
            content: const Text('ログアウトしてもよろしいですか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('ログアウト'),
              ),
            ],
          ),
        );

        if (confirmLogout == true) {
          // Call the logout function
          await supabaseService.logout();
          // Navigate back to the login page
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      tooltip: 'Logout', // Optional: Adds a tooltip when long-pressed
    );
  }
}
