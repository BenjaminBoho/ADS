import 'package:accident_data_storage/models/stakeholder.dart';
import 'package:accident_data_storage/providers/stakeholder_provider.dart';

class StakeholderHelper {
  static List<Stakeholder> prepareStakeholdersForUpdate(List<Stakeholder> stakeholders) {
    return stakeholders.where((s) => _isValidStakeholder(s)).toList();
  }

  // Handles the process of adding, updating, and deleting stakeholders.
  static Future<void> handleStakeholdersUpdate({
    required int accidentId,
    required List<Stakeholder> stakeholders,
    required List<int> stakeholdersToDelete,
    required StakeholderProvider stakeholderProvider,
  }) async {
    final validStakeholders = _getValidStakeholders(stakeholders);
    await _addOrUpdateStakeholders(accidentId, validStakeholders, stakeholderProvider);
    await _deleteStakeholders(accidentId, stakeholdersToDelete, stakeholderProvider);
  }

  // Adds or updates stakeholders in the database.
  static Future<void> _addOrUpdateStakeholders(
    int accidentId,
    List<Stakeholder> stakeholders,
    StakeholderProvider stakeholderProvider,
  ) async {
    for (var stakeholder in stakeholders) {
      if (stakeholder.stakeholderId == null) {
        await stakeholderProvider.addStakeholdersForAccident(accidentId, [stakeholder]);
      } else {
        await stakeholderProvider.updateStakeholder(stakeholder);
      }
    }
  }

  // Deletes stakeholders by stakeholderIds.
  static Future<void> _deleteStakeholders(
    int accidentId,
    List<int> stakeholdersToDelete,
    StakeholderProvider stakeholderProvider,
  ) async {
    for (var id in stakeholdersToDelete) {
      await stakeholderProvider.deleteStakeholder(id, accidentId);
    }
  }

  // Filters stakeholders that are valid for processing.
  static List<Stakeholder> _getValidStakeholders(List<Stakeholder> stakeholders) {
    return stakeholders.where((s) => _isValidStakeholder(s)).toList();
  }

  // Checks if a stakeholder is valid (has a role and a name).
  static bool _isValidStakeholder(Stakeholder stakeholder) {
    return stakeholder.role.isNotEmpty && stakeholder.name.isNotEmpty;
  }
}
