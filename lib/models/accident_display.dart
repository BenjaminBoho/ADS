import 'package:accident_data_storage/models/accident_data.dart';

class AccidentDisplayModel {
  final int accidentId;
  final String constructionField;
  final String constructionType;
  final String workType;
  final String constructionMethod;
  final String disasterCategory;
  final String accidentCategory;
  final String? weather;
  final String? weatherCondition;
  final int accidentYear;
  final int accidentMonth;
  final int accidentTime;
  final String accidentLocationPref;
  final String? accidentBackground;
  final String? accidentCause;
  final String? accidentCountermeasure;
  final int? postalCode;
  final String? addressDetail;

  AccidentDisplayModel({
    required this.accidentId,
    required this.constructionField,
    required this.constructionType,
    required this.workType,
    required this.constructionMethod,
    required this.disasterCategory,
    required this.accidentCategory,
    this.weather,
    required this.accidentYear,
    required this.accidentMonth,
    required this.accidentTime,
    required this.accidentLocationPref,
    this.accidentBackground,
    this.accidentCause,
    this.accidentCountermeasure,
    this.postalCode,
    this.addressDetail,
    this.weatherCondition
  });

  factory AccidentDisplayModel.fromMap(Map<String, dynamic> map) {
    return AccidentDisplayModel(
      accidentId: map['AccidentId'] as int,
      constructionField: map['ConstructionField'] as String,
      constructionType: map['ConstructionType'] as String,
      workType: map['WorkType'] as String,
      constructionMethod: map['ConstructionMethod'] as String,
      disasterCategory: map['DisasterCategory'] as String,
      accidentCategory: map['AccidentCategory'] as String,
      weather: map['Weather'] as String?,
      accidentYear: map['AccidentYear'] as int,
      accidentMonth: map['AccidentMonth'] as int,
      accidentTime: map['AccidentTime'] as int,
      accidentLocationPref: map['AccidentLocationPref'] as String,
      accidentBackground: map['AccidentBackground'] as String?,
      accidentCause: map['AccidentCause'] as String?,
      accidentCountermeasure: map['AccidentCountermeasure'] as String?,
      postalCode: map['postalCode'] as int?,
      addressDetail: map['addressDetail'] as String?,
    );
  }

  String get formattedAccidentDateTime {
    String formattedMonth = accidentMonth.toString().padLeft(2, '0');
    String formattedHour = accidentTime.toString().padLeft(2, '0');

    return '$accidentYear年$formattedMonth月 $formattedHour時';
  }

  static Future<AccidentDisplayModel> fromDataModel(
    AccidentDataModel dataModel,
    Future<String> Function(String, String) fetchItemName,
  ) async {
    return AccidentDisplayModel(
      accidentId: dataModel.accidentId,
      constructionField:
          await fetchItemName(dataModel.constructionField, 'ConstructionField'),
      constructionType:
          await fetchItemName(dataModel.constructionType, 'ConstructionType'),
      workType:
          await fetchItemName(dataModel.workType, 'WorkType'),
      constructionMethod:
          await fetchItemName(dataModel.constructionMethod, 'ConstructionMethod'),
      disasterCategory:
          await fetchItemName(dataModel.disasterCategory, 'DisasterCategory'),
      accidentCategory:
          await fetchItemName(dataModel.accidentCategory, 'AccidentCategory'),
      weather:
          dataModel.weather != null ? await fetchItemName(dataModel.weather!, 'Weather') : null,
      accidentYear: dataModel.accidentYear,
      accidentMonth: dataModel.accidentMonth,
      accidentTime: dataModel.accidentTime,
      accidentLocationPref: 
      await fetchItemName(dataModel.accidentLocationPref!, 'AccidentLocationPref'),
      accidentBackground: dataModel.accidentBackground,
      accidentCause: dataModel.accidentCause,
      accidentCountermeasure: dataModel.accidentCountermeasure,
      postalCode: dataModel.postalCode,
      addressDetail: dataModel.addressDetail,
      weatherCondition: dataModel.weather,
    );
  }
}
