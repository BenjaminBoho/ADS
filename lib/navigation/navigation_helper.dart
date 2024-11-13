import 'package:flutter/material.dart';
import '../models/accident.dart';
import '../pages/accident_page.dart';

Future<void> navigateToAccidentPage({
  required BuildContext context,
  Accident? accident,
  required bool isEditing,
  required Function onPageReturn,
}) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AccidentPage(
        accident: accident,
        isEditing: isEditing,
      ),
    ),
  );

  if (result == true) {
    onPageReturn();
  }
}
