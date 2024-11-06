import 'package:accident_data_storage/models/accident_data.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:accident_data_storage/models/item.dart';
import 'package:accident_data_storage/utils/language_utils.dart';
import 'package:accident_data_storage/services/query_helpers.dart';
import 'package:accident_data_storage/models/accident_display.dart';

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

  Future<List<Map<String, dynamic>>> fetchAccidentsData({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool isAscending = true,
  }) async {
    try {
      PostgrestFilterBuilder query =
          _client.from('Accidents').select('*') as PostgrestFilterBuilder;
      query = applyFilters(query, filters ?? {});
      PostgrestTransformBuilder sortedQuery =
          applySorting(query, sortBy, isAscending);

      final accidentsData = await sortedQuery;
      if (accidentsData == null) throw Exception("No accidents data received");

      return accidentsData as List<Map<String, dynamic>>;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch Accident Data error: $e');
        print('Stack Trace: $stackTrace');
      }
      return [];
    }
  }

  Future<List<Item>> fetchItems(String itemGenre, String? language) async {
    try {
      final itemListData = await _client
          .from('ItemList')
          .select('*')
          .eq('ItemGenre', itemGenre)
          .eq('ItemLang', language ?? getDeviceLanguage());

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

  Future<List<AccidentDisplayModel>> mapAccidentsToDisplayModel(
    List<Map<String, dynamic>> accidentsData,
    List<Item> itemList,
  ) async {
    return await Future.wait(
      accidentsData.map((accidentMap) async {
        final accidentDataModel = AccidentDataModel.fromMap(accidentMap);
        return AccidentDisplayModel.fromDataModel(
          accidentDataModel,
          (itemValue, itemGenre) =>
              _fetchItemName(itemList, itemValue, itemGenre),
        );
      }).toList(),
    );
  }

  // Future<List<AccidentDisplayModel>> fetchAccidentsData({
  //   Map<String, dynamic>? filters,
  //   String? sortBy,
  //   bool isAscending = true,
  //   String? language,
  // }) async {
  //   try {
  //     // Step 1: Fetch accidents data from the Accidents table
  //     PostgrestFilterBuilder query =
  //         _client.from('Accidents').select('*') as PostgrestFilterBuilder;

  //     query = applyFilters(query, filters ?? {});
  //     PostgrestTransformBuilder sortedQuery =
  //         applySorting(query, sortBy, isAscending);

  //     final accidentsData = await sortedQuery;
  //     if (accidentsData == null) throw Exception("No accidents data received");

  //     // Step 2: Fetch item list data for mapping
  //     final itemListData = await _client
  //         .from('ItemList')
  //         .select('*')
  //         .eq('ItemLang', language ?? getDeviceLanguage());
  //     final itemList = (itemListData as List<dynamic>).map((itemMap) {
  //       return Item.fromMap(itemMap as Map<String, dynamic>);
  //     }).toList();

  //     // Step 3: Convert accidents data to AccidentDisplayModel using item names
  //     final accidentsList = await Future.wait(
  //       (accidentsData as List<dynamic>).map((accidentMap) async {
  //         final accidentDataModel =
  //             AccidentDataModel.fromMap(accidentMap as Map<String, dynamic>);
  //         return AccidentDisplayModel.fromDataModel(
  //           accidentDataModel,
  //           (itemValue, itemGenre) =>
  //               _fetchItemName(itemList, itemValue, itemGenre),
  //         );
  //       }),
  //     );
  //     return accidentsList;
  //   } catch (e, stackTrace) {
  //     if (kDebugMode) {
  //       print('Fetch Accidents error: $e');
  //       print('Stack Trace: $stackTrace');
  //     }
  //     return [];
  //   }
  // }

  // Future<List<Item>> fetchItems(String itemGenre, String language) async {
  //   final language = getDeviceLanguage();
  //   try {
  //     final data = await _client
  //         .from('ItemList')
  //         .select()
  //         .eq('ItemGenre', itemGenre)
  //         .eq('ItemLang', language);

  //     if (kDebugMode) {
  //       print('Data received: $data');
  //     }

  //     final itemsList = (data as List<dynamic>).map((itemMap) {
  //       return Item.fromMap(itemMap as Map<String, dynamic>);
  //     }).toList();

  //     return itemsList;
  //   } catch (e, stackTrace) {
  //     if (kDebugMode) {
  //       print('Fetch Items error: $e');
  //       print('Stack Trace: $stackTrace');
  //     }
  //     return [];
  //   }
  // }

  Future<String> _fetchItemName(
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
}
