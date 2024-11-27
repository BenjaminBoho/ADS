import 'package:flutter/material.dart';
import '../models/accident.dart';
import '../models/stakeholder.dart';
import '../pages/accident_page.dart';

Future<void> navigateToAccidentPage({
  required BuildContext context,
  required Accident? accident,
  required bool isEditing,
  required Function onPageReturn,
  required List<Stakeholder> stakeholders,
}) async {
  debugPrint('Navigating to AccidentPage with accident: $accident, isEditing: $isEditing');
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AccidentPage(
        accident: accident,
        isEditing: isEditing,
        stakeholders: stakeholders, // Pass stakeholders directly
      ),
    ),
  );

  if (result == true) {
    onPageReturn();
  }
}