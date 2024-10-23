import 'package:flutter/material.dart';

class CustomPicker extends StatelessWidget {
  final String label;
  final int? value;

  const CustomPicker({super.key, 
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value != null ? value.toString() : ''),
    );
  }
}
