import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/supabase_service.dart';

class DropdownProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  // Item lists for dropdowns
  List<Item> constructionFieldItems = [];
  List<Item> constructionTypeItems = [];
  List<Item> workTypeItems = [];
  List<Item> constructionMethodItems = [];
  List<Item> disasterCategoryItems = [];
  List<Item> accidentCategoryItems = [];
  List<Item> weatherItems = [];
  List<Item> accidentLocationPrefItems = [];

  // Method to fetch all items
  Future<void> fetchAllDropdownItems() async {
    constructionFieldItems = await _supabaseService.fetchItems('ConstructionField');
    constructionTypeItems = await _supabaseService.fetchItems('ConstructionType');
    workTypeItems = await _supabaseService.fetchItems('WorkType');
    constructionMethodItems = await _supabaseService.fetchItems('ConstructionMethod');
    disasterCategoryItems = await _supabaseService.fetchItems('DisasterCategory');
    accidentCategoryItems = await _supabaseService.fetchItems('AccidentCategory');
    weatherItems = await _supabaseService.fetchItems('Weather');
    accidentLocationPrefItems = await _supabaseService.fetchItems('AccidentLocationPref');

    notifyListeners(); // Notify listeners when data is fetched
  }
}
