import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onPressed;

  const SaveButton({super.key, required this.isEditing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, // Set the desired width
      height: 40, // Set the desired height
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(isEditing ? '更新' : '追加'),
      ),
    );
  }
}