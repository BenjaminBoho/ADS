import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/utils/time_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConflictHelper {
  static Future<bool?> handleConflict(
      BuildContext context, Accident accident) async {
    final formattedUpdatedAt = formatUpdatedAt(accident.updatedAt);
    final localizations = AppLocalizations.of(context)!;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.conflictDetected),
          content: Text(localizations.dataConflictMessage(formattedUpdatedAt)),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(localizations.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(localizations.overwrite),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
