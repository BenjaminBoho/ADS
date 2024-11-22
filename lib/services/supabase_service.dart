import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/models/stakeholder.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:accident_data_storage/models/item.dart';
import 'package:accident_data_storage/utils/language_utils.dart';
import 'package:accident_data_storage/services/query_helpers.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }
  }

  Future<List<Accident>> fetchAccidentsData({
    Map<String, dynamic>? filters,
    String? sortBy = 'ID',
    bool isAscending = false,
  }) async {
    try {
      PostgrestFilterBuilder query =
          _client.from('Accidents').select('*') as PostgrestFilterBuilder;
      query = applyFilters(query, filters ?? {});
      PostgrestTransformBuilder sortedQuery =
          applySorting(query, sortBy, isAscending);

      final data = await sortedQuery;
      final accidentsList = (data as List<dynamic>).map((item) {
        return Accident.fromMap(item as Map<String, dynamic>);
      }).toList();

      if (kDebugMode) {
        print('Data received: $accidentsList');
      }

      return accidentsList;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch Accident Data error: $e');
        print('Stack Trace: $stackTrace');
      }
      return [];
    }
  }

  Future<List<Item>> fetchItems(String itemGenre) async {
    try {
      final selectedLanguage = getDeviceLanguage();

      final itemListData = await _client
          .from('ItemList')
          .select('*')
          .eq('ItemGenre', itemGenre)
          .eq('ItemLang', selectedLanguage);

      return (itemListData as List<dynamic>).map((itemMap) {
        return Item.fromMap(itemMap as Map<String, dynamic>);
      }).toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch Item List Data error: $e');
        print('Stack Trace: $stackTrace');
      }
      return [];
    }
  }

  Future<String> fetchItemName(
      List<Item> itemList, String itemValue, String itemGenre) async {
    // Find the matching item name for a given value and genre
    final item = itemList.firstWhere(
      (item) => item.itemValue == itemValue && item.itemGenre == itemGenre,
      orElse: () => Item(
          itemGenre: itemGenre,
          itemValue: itemValue,
          itemName: itemValue), // Return the value if not found
    );
    return Future.value(item
        .itemName); // Wrap the result in Future.value to match Future<String> type
  }

  Future<void> addAccident(Map<String, dynamic> accidentData) async {
    try {
      await _client.from('Accidents').insert(accidentData);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding accident: $e');
      }
    }
  }

  Future<void> updateAccident(
      int accidentId, Map<String, dynamic> accidentData) async {
    try {
      await _client
          .from('Accidents')
          .update(accidentData)
          .eq('AccidentId', accidentId);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating accident: $e');
      }
    }
  }

  Future<void> deleteAccident(int accidentId) async {
    try {
      await _client.from('Accidents').delete().eq('AccidentId', accidentId);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting accident: $e');
      }
    }
  }

  Future<void> addStakeholder(Map<String, dynamic> stakeholderData) async {
    try {
      await _client.from('Stakeholders').insert(stakeholderData);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding stakeholders: $e');
      }
    }
  }

  Future<int> addAccidentWithStakeholders(Map<String, dynamic> accidentData,
      List<Map<String, dynamic>> stakeholders) async {
    try {
      // Insert the accident and return the created accidentId
      final response =
          await _client.from('Accidents').insert(accidentData).select();
      if (response.isNotEmpty) {
        final accidentId = response.first['AccidentId'] as int;

        // If there are stakeholders, insert them
        if (stakeholders.isNotEmpty) {
          for (var stakeholder in stakeholders) {
            stakeholder['AccidentId'] = accidentId;
          }
          await _client.from('Stakeholders').insert(stakeholders);
        }

        return accidentId;
      }
      throw Exception('Failed to create accident');
    } catch (e) {
      debugPrint('Error adding accident with stakeholders: $e');
      rethrow;
    }
  }

  Future<void> updateStakeholder(
      int accidentId, Map<String, dynamic> stakeholderData) async {
    try {
      await _client
          .from('Stakeholders')
          .update(stakeholderData)
          .eq('AccidentId', accidentId);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating accident: $e');
      }
    }
  }

  Future<void> deleteStakeholder(int stakeholderId) async {
    try {
      debugPrint('Executing deletion query for stakeholder ID: $stakeholderId');
      await _client
          .from('Stakeholders')
          .delete()
          .eq('StakeholderId', stakeholderId);
      debugPrint('Deletion query executed for stakeholder ID: $stakeholderId');
    } catch (e) {
      debugPrint(
          'Error during deletion query for stakeholder ID: $stakeholderId: $e');
    }
  }

  Future<List<Stakeholder>> fetchStakeholders(int accidentId) async {
    try {
      // Query the Stakeholders table where AccidentId matches the given accidentId
      final data = await _client
          .from('Stakeholders')
          .select('*')
          .eq('AccidentId', accidentId);

      // Map the returned data into a list of Stakeholder objects
      final stakeholderList = (data as List<dynamic>).map((item) {
        return Stakeholder.fromMap(item as Map<String, dynamic>);
      }).toList();

      if (kDebugMode) {
        print('Stakeholders fetched: $stakeholderList');
      }

      return stakeholderList;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch Stakeholders error: $e');
        print('Stack Trace: $stackTrace');
      }
      return [];
    }
  }
}
