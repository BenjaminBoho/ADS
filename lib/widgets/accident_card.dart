import 'package:accident_data_storage/models/accident_display.dart';
import 'package:flutter/material.dart';
import 'package:accident_data_storage/widgets/weather_icon.dart';

class AccidentCard extends StatelessWidget {
  final AccidentDisplayModel accident;

  const AccidentCard({super.key, required this.accident});

  @override
  Widget build(BuildContext context) {
    IconData? weatherIcon = getWeatherIcon(accident.weatherCondition);

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
                    Text(
                      '${accident.accidentLocationPref}',
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    accident.constructionField,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    accident.constructionType,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    accident.workType,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    accident.constructionMethod,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    accident.disasterCategory,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    accident.accidentCategory,
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
