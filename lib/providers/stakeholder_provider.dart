import 'package:flutter/material.dart';
import '../models/stakeholder.dart';
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
      // Fetch data from Supabase
      final fetchedData = await _supabaseService.fetchStakeholders(accidentId);

      // If fetchedData contains Stakeholder objects, directly assign
      if (fetchedData.isNotEmpty) {
        _stakeholders = fetchedData.cast<Stakeholder>();
      } else {
        // Otherwise, map the raw data into Stakeholder objects
        _stakeholders = fetchedData.map((data) {
          debugPrint('Mapping stakeholder data: $data');
          return Stakeholder.fromMap(data as Map<String, dynamic>);
        }).toList();
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching stakeholders: $e");
      debugPrint("Stack trace: $stackTrace");
      _stakeholders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _stakeholders;
  }

  /// Add stakeholders during accident creation
  Future<void> addStakeholdersForAccident(
      int accidentId, List<Stakeholder> stakeholderList) async {
    try {
      // Map stakeholders to assign the accidentId
      final updatedStakeholders = stakeholderList.map((stakeholder) {
        return stakeholder.withAccidentId(accidentId);
      }).toList();
      // Insert each stakeholder individually
      for (var stakeholder in updatedStakeholders) {
        await _supabaseService.addStakeholder(stakeholder);
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

      final stakeholderId = stakeholder.stakeholderId;
      if (stakeholderId == null) {
        debugPrint("Stakeholder ID cannot be null when updating");
        return;
      }

      await _supabaseService.updateStakeholder(
        stakeholderId,
        stakeholder,
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
}
