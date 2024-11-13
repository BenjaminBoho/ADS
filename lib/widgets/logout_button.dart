import 'package:flutter/material.dart';
import 'package:accident_data_storage/services/supabase_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LogoutButton extends StatelessWidget {
  final SupabaseService supabaseService;

  const LogoutButton({super.key, required this.supabaseService});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        bool? confirmLogout = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Center(child: Text(localizations.logout)),
            content: Text(localizations.logoutConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(localizations.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(localizations.logout),
              ),
            ],
          ),
        );

        if (confirmLogout == true) {
          // Call the logout function
          await supabaseService.logout();
          // Navigate back to the login page
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        }
      },
      tooltip: 'Logout',
    );
  }
}
