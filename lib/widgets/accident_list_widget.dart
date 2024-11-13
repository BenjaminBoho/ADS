import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/models/item.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/widgets/accident_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccidentListWidget extends StatelessWidget {
  final Future<List<Accident>> accidentData;
  final Function(Accident) onAccidentTap;
  final List<Item> itemList;
  final Future<String> Function(List<Item>, String, String) fetchItemName;

  const AccidentListWidget({
    super.key,
    required this.accidentData,
    required this.onAccidentTap,
    required this.itemList,
    required this.fetchItemName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Accident>>(
      future: accidentData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noDataFound));
        }

        final accidents = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: accidents.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 2.4,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            final accident = accidents[index];
            return InkWell(
              onTap: () => onAccidentTap(accident),
              child: AccidentCard(
                accident: accident,
                fetchItemName: fetchItemName,
                itemList: itemList,
              ),
            );
          },
        );
      },
    );
  }
}
