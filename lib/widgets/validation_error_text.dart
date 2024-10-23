import 'package:flutter/material.dart';

class ValidationErrorText extends StatelessWidget {
  final String message;

  const ValidationErrorText({super.key, this.message = '*必須項目'});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(color: Colors.red),
    );
  }
}