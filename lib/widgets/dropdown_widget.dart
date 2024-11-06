import 'package:accident_data_storage/models/item.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<Item> items;
  final Function(String?) onChanged;

  const CustomDropdown({super.key, 
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Create a temporary list that includes the current value if it's missing
    List<Item> dropdownItems = List.from(items);

    // Check if the selected value is in the list; if not, add it temporarily
    if (value != null && !items.any((item) => item.itemValue == value)) {
      dropdownItems.add(Item(itemGenre: label, itemValue: value!, itemName: value!));
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: dropdownItems.map((item) {
        return DropdownMenuItem<String>(
          value: item.itemValue,
          child: Text(item.itemName),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
