import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:accident_data_storage/models/accident.dart';
import 'package:accident_data_storage/models/item.dart';

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

  Future<List<Accident>> fetchAccidents(
      {Map<String, dynamic>? filters,
      String? sortBy,
      bool isAscending = true}) async {
    try {
      var query = _client.from('Accidents').select('*');

      // Apply filters if provided
      if (filters != null && filters.isNotEmpty) {
        if (filters['constructionField'] != null) {
          query = query.eq('ConstructionField', filters['constructionField']);
        }
        if (filters['constructionType'] != null) {
          query = query.eq('ConstructionType', filters['constructionType']);
        }
        if (filters['accidentBackground'] != null &&
            filters['accidentBackground'] != '') {
          query = query.ilike(
              'AccidentBackground', '%${filters['accidentBackground']}%');
        }

        // Time range filters
        int? fromYear = filters['fromYear'];
        int? toYear = filters['toYear'];
        int? fromMonth = filters['fromMonth'];
        int? toMonth = filters['toMonth'];
        int? fromTime = filters['fromTime'];
        int? toTime = filters['toTime'];

        if (fromYear != null) query = query.gte('AccidentYear', fromYear);
        if (toYear != null) query = query.lte('AccidentYear', toYear);
        if (fromMonth != null) query = query.gte('AccidentMonth', fromMonth);
        if (toMonth != null) query = query.lte('AccidentMonth', toMonth);
        if (fromTime != null) query = query.gte('AccidentTime', fromTime);
        if (toTime != null) query = query.lte('AccidentTime', toTime);
      }

      // ソートを適用するためにTransformBuilderに変換する
      PostgrestTransformBuilder<dynamic> sortedQuery = query;
      if (sortBy != null) {
        if (sortBy == '事故発生年・月・時間') {
          sortedQuery = sortedQuery
              .order('AccidentYear', ascending: isAscending)
              .order('AccidentMonth', ascending: isAscending)
              .order('AccidentTime', ascending: isAscending);
        } else {
          String dbColumn = _getDbColumnName(sortBy);
          sortedQuery = sortedQuery.order(dbColumn, ascending: isAscending);
        }
      }

      // Execute the query and get the data
      final data = await sortedQuery;

      if (kDebugMode) {
        print('Data received: $data');
      }

      final accidentsList = (data as List<dynamic>).map((accidentMap) {
        return Accident.fromMap(accidentMap as Map<String, dynamic>);
      }).toList();

      return accidentsList;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch Accidents error: $e');
        print('Stack Trace: $stackTrace');
      }
      return [];
    }
  }

  String _getDbColumnName(String sortBy) {
    switch (sortBy) {
      case 'ID':
        return 'AccidentId';
      case '工事分野':
        return 'ConstructionField';
      case '工事の種類':
        return 'ConstructionType';
      case '工種':
        return 'WorkType';
      case '工法・形式名':
        return 'ConstructionMethod';
      case '災害分類':
        return 'DisasterCategory';
      case '事故分類':
        return 'AccidentCategory';
      case '天候':
        return 'Weather';
      case '事故発生場所（都道府県）':
        return 'AccidentLocationPref';
      default:
        return sortBy;
    }
  }

  Future<List<Item>> fetchItems(String itemGenre) async {
    try {
      final data =
          await _client.from('ItemList').select().eq('ItemGenre', itemGenre);

      if (kDebugMode) {
        print('Data received: $data');
      }

      final itemsList = (data as List<dynamic>).map((itemMap) {
        return Item.fromMap(itemMap as Map<String, dynamic>);
      }).toList();

      return itemsList;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch Items error: $e');
        print('Stack Trace: $stackTrace');
      }
      return [];
    }
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

  Future<void> updateAccident(int accidentId, Map<String, dynamic> accidentData) async {
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
      await _client
          .from('Accidents')
          .delete()
          .eq('AccidentId', accidentId);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting accident: $e');
      }
    }
  }
}
