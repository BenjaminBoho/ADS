import 'package:flutter/material.dart';
import '../models/accident.dart';
import '../models/item.dart';
import '../services/supabase_service.dart';

class AccidentProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

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
}
