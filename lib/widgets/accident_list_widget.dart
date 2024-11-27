import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/models/item.dart';
import 'package:accident_data_storage/models/stakeholder.dart';
import 'package:accident_data_storage/widgets/accident_card.dart';
import 'package:flutter/material.dart';

class AccidentListWidget extends StatelessWidget {
  final List<Accident> accidents;
  final List<Item> itemList;
  final Future<String> Function(List<Item>, String, String) fetchItemName;
  final Map<int, List<Stakeholder>> stakeholdersMap;
  final Function(Accident) onAccidentTap;

  const AccidentListWidget({
    super.key,
    required this.accidents,
    required this.itemList,
    required this.fetchItemName,
    required this.stakeholdersMap,
    required this.onAccidentTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: accidents.length,
      itemBuilder: (context, index) {
        final accident = accidents[index];

        return GestureDetector(
          onTap: () => onAccidentTap(accident),
          child: AccidentCard(
            accident: accident,
            itemList: itemList,
            fetchItemName: fetchItemName,
            stakeholders: accident.stakeholders, // Pass directly from accident
          ),
        );
      },
    );
  }
}
