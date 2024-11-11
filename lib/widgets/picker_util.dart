import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PickerUtil {
  static void showPicker({
    required BuildContext context,
    required List<int> items,
    required String title,
    required Function(int) onSelected,
  }) {
    BottomPicker(
      items: items.map((item) => Center(child: Text(item.toString()))).toList(),
      pickerTitle: Text(title),
      pickerTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.blue,
      ),
      onSubmit: (index) {
        onSelected(items[index]);
      },
      bottomPickerTheme: BottomPickerTheme.blue,
      buttonContent: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                  AppLocalizations.of(context)!.select,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).show(context);
  }
}
