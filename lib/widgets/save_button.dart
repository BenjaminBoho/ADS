import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SaveButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onPressed;

  const SaveButton({super.key, required this.isEditing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(isEditing ? localizations.update : localizations.save),
      ),
    );
  }
}