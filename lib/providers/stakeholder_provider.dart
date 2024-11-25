import 'package:flutter/material.dart';
import '../models/stakeholder.dart';
import '../models/stakeholder_data.dart';
import '../services/supabase_service.dart';

class StakeholderProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  // State variables
  List<Stakeholder> _stakeholders = [];
  bool _isLoading = false;

  // Getters for stakeholders and loading state
  List<Stakeholder> get stakeholders => _stakeholders;
  bool get isLoading => _isLoading;

  /// Fetch stakeholders for a specific accident
  Future<List<Stakeholder>> fetchStakeholders(int accidentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedStakeholders =
          await _supabaseService.fetchStakeholders(accidentId);

      _stakeholders = fetchedStakeholders;
    } catch (e) {
      debugPrint("Error fetching stakeholders: $e");
      _stakeholders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _stakeholders;
  }

  /// Add stakeholders during accident creation
  Future<void> addStakeholdersForAccident(
      int accidentId, List<StakeholderData> stakeholderDataList) async {
    try {
      for (var stakeholderData in stakeholderDataList) {
        // Use withAccidentId helper method
        final updatedStakeholderData =
            stakeholderData.withAccidentId(accidentId);

        await _supabaseService.addStakeholder(updatedStakeholderData.toMap());
      }

      await fetchStakeholders(accidentId);
    } catch (e) {
      debugPrint("Error adding stakeholders: $e");
    }
  }

  /// Update an existing stakeholder
  Future<void> updateStakeholder(Stakeholder stakeholder) async {
  try {
    debugPrint('Updating stakeholder with data: ${stakeholder.toMap()}');
    await _supabaseService.updateStakeholder(
      stakeholder.stakeholderId,
      stakeholder.toMap(),
    );
    await fetchStakeholders(stakeholder.accidentId);
  } catch (e) {
    debugPrint("Error updating stakeholder: $e");
  }
}


  /// Delete a stakeholder
  Future<void> deleteStakeholder(int stakeholderId, int accidentId) async {
    try {
      await _supabaseService.deleteStakeholder(stakeholderId);

      // Refresh the stakeholder list after deletion
      await fetchStakeholders(accidentId);
    } catch (e) {
      debugPrint('Error deleting stakeholder with ID: $stakeholderId: $e');
    }
  }

  /// Clear the stakeholders list (e.g., when changing accidents)
  void clearStakeholders() {
    _stakeholders = [];
    notifyListeners();
  }
}
