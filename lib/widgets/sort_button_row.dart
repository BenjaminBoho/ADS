import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accident_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SortButtonRow extends StatelessWidget {
  final void Function(String) onSortItemPressed;

  const SortButtonRow({super.key, required this.onSortItemPressed});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final accidentProvider = Provider.of<AccidentProvider>(context);

    // List of sorting options
    final sortOptions = [
      {'label': 'ID', 'sortBy': 'ID'},
      {'label': localizations.constructionField, 'sortBy': 'ConstructionField'},
      {'label': localizations.constructionType, 'sortBy': '工事の種類'},
      {'label': localizations.workType, 'sortBy': '工種'},
      {'label': localizations.constructionMethod, 'sortBy': '工法・形式名'},
      {'label': localizations.disasterCategory, 'sortBy': '災害分類'},
      {'label': localizations.accidentCategory, 'sortBy': '事故分類'},
      {'label': localizations.weather, 'sortBy': '天候'},
      {'label': localizations.accidentYearMonthTime, 'sortBy': '事故発生年・月・時間'},
      {'label': localizations.accidentLocationPref, 'sortBy': '事故発生場所（都道府県）'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sortOptions.map((option) {
          final isCurrentSort =
              accidentProvider.currentSortBy == option['sortBy'];
          return TextButton(
            onPressed: () => onSortItemPressed(option['sortBy']!),
            child: Row(
              children: [
                Text(option['label']!),
                if (isCurrentSort)
                  Icon(
                    accidentProvider.isAscending
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
