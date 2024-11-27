import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/models/item.dart';
import 'package:accident_data_storage/models/stakeholder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/widgets/weather_icon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccidentCard extends StatelessWidget {
  final Accident accident;
  final List<Item> itemList;
  final Future<String> Function(List<Item>, String, String) fetchItemName;
  final List<Stakeholder> stakeholders; // Add stakeholders to the card

  const AccidentCard({
    super.key,
    required this.accident,
    required this.itemList,
    required this.fetchItemName,
    required this.stakeholders,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Weather Condition: ${accident.weatherCondition}');
    }
    IconData? weatherIcon = getWeatherIcon(accident.weatherCondition);

    final Stakeholder builder = stakeholders.firstWhere(
      (stakeholder) => stakeholder.role == 'Builder',
      orElse: () => Stakeholder(
        accidentId: accident.accidentId!
      ),
    );

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ID and Weather Row
              Row(
                children: [
                  Text(
                    'ID: ${accident.accidentId}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        weatherIcon,
                        size: 20,
                      ),
                      const SizedBox(width: 10.0),
                      FutureBuilder<String>(
                        future: fetchItemName(
                            itemList,
                            accident.accidentLocationPref,
                            'AccidentLocationPref'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          return Text(
                            snapshot.data ?? accident.accidentLocationPref,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        ' ${accident.formattedAccidentDateTime}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10.0),

              // Construction Field and Type
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: fetchItemName(itemList,
                          accident.constructionField, 'ConstructionField'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return Text(
                          snapshot.data ?? accident.constructionField,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: fetchItemName(itemList, accident.constructionType,
                          'ConstructionType'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return Text(
                          snapshot.data ?? accident.constructionType,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),

              // Work Type and Construction Method
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: fetchItemName(
                          itemList, accident.workType, 'WorkType'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return Text(
                          snapshot.data ?? accident.workType,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: fetchItemName(itemList,
                          accident.constructionMethod, 'ConstructionMethod'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return Text(
                          snapshot.data ?? accident.constructionMethod,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),

              // Disaster Category and Accident Category
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: fetchItemName(itemList, accident.disasterCategory,
                          'DisasterCategory'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return Text(
                          snapshot.data ?? accident.disasterCategory,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: fetchItemName(itemList, accident.accidentCategory,
                          'AccidentCategory'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return Text(
                          snapshot.data ?? accident.accidentCategory,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              if (builder.role == 'Builder' && builder.name.isNotEmpty)
                Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.builder}:',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        builder.name,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
    );
  }
}
