import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final Function(String) onChanged;

  const CustomTextField({super.key, 
    required this.label,
    required this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: TextInputType.multiline,
      maxLines: null, 
      minLines: 1,
    );
  }
}
