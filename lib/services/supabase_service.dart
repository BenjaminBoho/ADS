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
      PostgrestFilterBuilder query = _client
          .from('Accidents')
          .select('*, Stakeholders(*)') as PostgrestFilterBuilder;

      query = applyFilters(query, filters ?? {});
      PostgrestTransformBuilder sortedQuery =
          applySorting(query, sortBy, isAscending);

      final response = await sortedQuery;

      if (response == null) {
        throw Exception('No data returned from Supabase.');
      }
      final data = response as List<dynamic>;

      final accidentsList = data.map((item) {
        return Accident.fromMap(item as Map<String, dynamic>);
      }).toList();

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

  Future<void> addAccident(Accident accidentData) async {
    try {
      await _client.from('Accidents').insert(accidentData.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding accident: $e');
      }
    }
  }

  Future<void> updateAccident(int accidentId, Accident accidentData) async {
    try {
      if (kDebugMode) {
        print('Updating Accident ID: $accidentId');
        print('Update Data: $accidentData');
      }

      final response = await _client
          .from('Accidents')
          .update(accidentData.toMap())
          .eq('AccidentId', accidentId)
          .select();

      if (kDebugMode) {
        print('Response: $response');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating accident: $e');
      }
      rethrow;
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

  Future<void> addStakeholder(Stakeholder stakeholderData) async {
    try {
      await _client.from('Stakeholders').insert(stakeholderData.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding stakeholders: $e');
      }
    }
  }

  Future<int> addAccidentWithStakeholders(
      Accident accidentData, List<Stakeholder> stakeholders) async {
    try {
      // Insert the accident and return the created accidentId
      final response =
          await _client.from('Accidents').insert(accidentData.toMap()).select();
      if (response.isNotEmpty) {
        final accidentId = response.first['AccidentId'] as int;

        // Assign accidentId to each stakeholder
        final updatedStakeholders = stakeholders.map((stakeholder) {
        return stakeholder.withAccidentId(accidentId);
      }).toList();

      // Insert stakeholders
      if (updatedStakeholders.isNotEmpty) {
        await _client.from('Stakeholders').insert(
            updatedStakeholders.map((s) => s.toMap()).toList());
      }

        return accidentId;
      }
      throw Exception('Failed to create accident');
    } catch (e) {
      debugPrint('Error adding accident with stakeholders: $e');
      rethrow;
    }
  }

  Future<void> updateStakeholder(int stakeholderId, Stakeholder data) async {
    try {
      debugPrint(
          'Executing update query for stakeholder ID: $stakeholderId with data: $data');
      await _client
          .from('Stakeholders')
          .update(data.toMap())
          .eq('StakeholderId', stakeholderId);
      debugPrint('Update query executed for stakeholder ID: $stakeholderId');
    } catch (e) {
      debugPrint(
          'Error during update query for stakeholder ID: $stakeholderId: $e');
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

  /// Fetch all stakeholders from the database
  Future<List<Stakeholder>> fetchAllStakeholders() async {
    try {
      // Query all stakeholders
      final response = await _client.from('Stakeholders').select();

      // Ensure response is in the correct format
      final data = response as List<dynamic>;

      if (kDebugMode) {
        debugPrint('Fetched all stakeholders: $data');
      }

      // Map data to Stakeholder objects
      return data.map((item) {
        return Stakeholder.fromMap(item as Map<String, dynamic>);
      }).toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error fetching all stakeholders: $e');
        debugPrint('Stack Trace: $stackTrace');
      }

      // Return an empty list in case of error
      return [];
    }
  }

  /// Fetch stakeholders for a specific accident by AccidentId
  Future<List<Stakeholder>> fetchStakeholders(int accidentId) async {
    try {
      // Query stakeholders for the given accidentId
      final response = await _client
          .from('Stakeholders')
          .select('*')
          .eq('AccidentId', accidentId);

      // Ensure response is in the correct format
      final data = response as List<dynamic>;

      // Map data to Stakeholder objects
      return data.map((item) {
        return Stakeholder.fromMap(item as Map<String, dynamic>);
      }).toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'Error fetching stakeholders for accidentId(service error) $accidentId: $e');
        debugPrint('Stack Trace: $stackTrace');
      }

      // Return an empty list in case of error
      return [];
    }
  }

  Future<String?> fetchUserEmail(String userId) async {
    try {
      final response = await _client
          .from('Profiles')
          .select('email')
          .eq('id', userId)
          .single();

      return response['email'] as String?;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user email for userId $userId: $e');
      }
      return "Unknown User";
    }
  }

  Future<Accident> fetchAccidentById(int accidentId) async {
    try {
      final response = await _client
          .from('Accidents')
          .select('*, Stakeholders(*)')
          .eq('AccidentId', accidentId)
          .single();

      return Accident.fromMap(response);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch Accident By ID error: $e');
        print('Stack Trace: $stackTrace');
      }
      rethrow;
    }
  }
}
