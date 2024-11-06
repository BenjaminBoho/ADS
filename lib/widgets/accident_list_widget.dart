import 'package:accident_data_storage/models/accident_display.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/widgets/accident_card.dart';

class AccidentListWidget extends StatelessWidget {
  final Future<List<AccidentDisplayModel>> accidentData;
  final Function(AccidentDisplayModel) onAccidentTap;

  const AccidentListWidget({
    super.key,
    required this.accidentData,
    required this.onAccidentTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AccidentDisplayModel>>(
      future: accidentData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data found'));
        }

        final accidents = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: accidents.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 2.5,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            final accident = accidents[index];
            return InkWell(
              onTap: () => onAccidentTap(accident),
              child: AccidentCard(accident: accident),
            );
          },
        );
      },
    );
  }
}