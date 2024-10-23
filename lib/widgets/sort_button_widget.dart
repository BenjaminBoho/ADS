import 'package:flutter/material.dart';

class SortButton extends StatelessWidget {
  final String label;
  final String sortBy;
  final String? currentSortBy;
  final bool isAscending;
  final Function(String) onSortItemPressed;

  const SortButton({
    super.key,
    required this.label,
    required this.sortBy,
    required this.currentSortBy,
    required this.isAscending,
    required this.onSortItemPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onSortItemPressed(sortBy),
      child: Row(
        children: [
          Text(label),
          if (currentSortBy == sortBy)
            Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
        ],
      ),
    );
  }
}
