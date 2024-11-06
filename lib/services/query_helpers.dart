import 'package:supabase_flutter/supabase_flutter.dart';

PostgrestFilterBuilder applyFilters(
    PostgrestFilterBuilder query, Map<String, dynamic> filters) {
  if (filters.isEmpty) {
    return query;
  }

  if (filters['constructionField'] != null) {
    query = query.eq('ConstructionField', filters['constructionField']);
  }
  if (filters['constructionType'] != null) {
    query = query.eq('ConstructionType', filters['constructionType']);
  }
  if (filters['accidentBackground'] != null &&
      filters['accidentBackground'] != '') {
    query = query.ilike('AccidentBackground', '%${filters['accidentBackground']}%');
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

  return query;
}

PostgrestTransformBuilder applySorting(
    PostgrestTransformBuilder query, String? sortBy, bool isAscending) {
  if (sortBy != null) {
    if (sortBy == '事故発生年・月・時間') {
      query = query
          .order('AccidentYear', ascending: isAscending)
          .order('AccidentMonth', ascending: isAscending)
          .order('AccidentTime', ascending: isAscending);
    } else {
      String dbColumn = _getDbColumnName(sortBy);
      query = query.order(dbColumn, ascending: isAscending);
    }
  }
  return query;
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