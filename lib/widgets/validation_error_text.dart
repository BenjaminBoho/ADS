import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ValidationErrorText extends StatelessWidget {
  final String? message;

  const ValidationErrorText({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final String displayMessage = message ?? AppLocalizations.of(context)!.requiredField;
    
    return Text(
      displayMessage,
      style: const TextStyle(color: Colors.red),
    );
  }
}