import 'package:accident_data_storage/services/address_services.dart';
import 'package:flutter/material.dart';
import '../models/accident.dart';
import '../models/item.dart';
import '../services/supabase_service.dart';

class AccidentProvider with ChangeNotifier {
  final SupabaseService _supabaseService;

  // Constructor with optional SupabaseService
  AccidentProvider({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  // State variables for filters and sorting
  Map<String, dynamic> _currentFilters = {};
  String _currentSortBy = 'ID';
  bool _isAscending = false;

  // Getters for the filters and sort state
  Map<String, dynamic> get currentFilters => _currentFilters;
  String get currentSortBy => _currentSortBy;
  bool get isAscending => _isAscending;

  Future<List<Accident>> fetchAccidentData() async {
    return await _supabaseService.fetchAccidentsData(
      filters: _currentFilters,
      sortBy: _currentSortBy,
      isAscending: _isAscending,
    );
  }

  Future<List<Item>> fetchAllItems() async {
    final futures = [
      _supabaseService.fetchItems('ConstructionField'),
      _supabaseService.fetchItems('ConstructionType'),
      _supabaseService.fetchItems('WorkType'),
      _supabaseService.fetchItems('ConstructionMethod'),
      _supabaseService.fetchItems('DisasterCategory'),
      _supabaseService.fetchItems('AccidentCategory'),
      _supabaseService.fetchItems('AccidentLocationPref'),
    ];

    final lists = await Future.wait(futures);
    return lists.expand((list) => list).toList();
  }

  // Method to update filters
  void updateFilters(Map<String, dynamic> filters) {
    _currentFilters = filters;
    notifyListeners();
  }

  // Method to update sorting
  void updateSorting(String sortBy) {
    if (_currentSortBy == sortBy) {
      _isAscending = !_isAscending;
    } else {
      _currentSortBy = sortBy;
      _isAscending = false;
    }
    notifyListeners();
  }

  // Add a new accident
  Future<bool> addAccident(Accident accidentData) async {
    try {
      await _supabaseService.addAccident(accidentData.toMap());
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding accident: $e');
      return false;
    }
  }

  // Update an existing accident
  Future<bool> updateAccident(Accident accidentData, {bool isOverwrite = false}) async {
    try {
      final accidentId = accidentData.accidentId;
      if (accidentId == null) {
        debugPrint('Error: Accident ID is null');
        return false;
      }

      // Prepare the updated accident data
      final updatedAccidentData = accidentData.toMap();

      await _supabaseService.updateAccident(
        accidentId,
        updatedAccidentData,
        isOverwrite: isOverwrite,
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating accident: $e');
      return false;
    }
  }

  Future<String?> handleZipCodeSubmit(
      String zipCode,
      TextEditingController addressController,
      List<Item> accidentLocationPrefItems) async {
    final address = await fetchAddressFromZipCode(zipCode);

    if (address != null) {
      addressController.text = '${address.address2} ${address.address3}';
      final prefItem = accidentLocationPrefItems.firstWhere(
        (item) => item.itemName == address.address1,
      );
      return prefItem.itemValue;
    } else {
      return null;
    }
  }

  Future<bool> deleteAccident(int accidentId) async {
    try {
      await _supabaseService.deleteAccident(accidentId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting accident: $e");
      return false;
    }
  }

  Future<String> getUpdatedByEmail(String userId) async {
    final email = await _supabaseService.fetchUserEmail(userId);
    return email ?? "Unknown User";
  }

  Future<Accident> fetchAccidentById(int accidentId) async {
    return await _supabaseService.fetchAccidentById(accidentId);
  }
}