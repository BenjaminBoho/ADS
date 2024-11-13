import 'package:accident_data_storage/utils/language_utils.dart';

class Accident {
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
  final int? zipcode;
  final String? addressDetail;

  Accident(
      {required this.accidentId,
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
      this.zipcode,
      this.addressDetail,
      this.weatherCondition});

  factory Accident.fromMap(Map<String, dynamic> map) {
    return Accident(
        accidentId: map['AccidentId'] as int,
        constructionField: map['ConstructionField'] as String,
        constructionType: map['ConstructionType'] as String,
        workType: map['WorkType'] as String,
        constructionMethod: map['ConstructionMethod'] as String,
        disasterCategory: map['DisasterCategory'] as String,
        accidentCategory: map['AccidentCategory'] as String,
        weather: map['Weather'] as String?,
        weatherCondition: map['Weather'] as String?,
        accidentYear: map['AccidentYear'] as int,
        accidentMonth: map['AccidentMonth'] as int,
        accidentTime: map['AccidentTime'] as int,
        accidentLocationPref: map['AccidentLocationPref'] as String,
        accidentBackground: map['AccidentBackground'] as String?,
        accidentCause: map['AccidentCause'] as String?,
        accidentCountermeasure: map['AccidentCountermeasure'] as String?,
        zipcode: map['Zipcode'] as int?,
        addressDetail: map['AddressDetail'] as String?);
  }

  String get formattedAccidentDateTime {
    String formattedMonth = accidentMonth.toString().padLeft(2, '0');
    String formattedHour = accidentTime.toString().padLeft(2, '0');
    return formatDate(accidentYear, formattedMonth, formattedHour);
  }

  @override
  String toString() {
    return 'Accident(accidentId: $accidentId, constructionField: $constructionField, constructionType: $constructionType, workType: $workType, '
           'constructionMethod: $constructionMethod, disasterCategory: $disasterCategory, accidentCategory: $accidentCategory, '
           'weather: $weather, accidentYear: $accidentYear, accidentMonth: $accidentMonth, accidentTime: $accidentTime, '
           'accidentLocationPref: $accidentLocationPref, accidentBackground: $accidentBackground, accidentCause: $accidentCause, '
           'accidentCountermeasure: $accidentCountermeasure, zipcode: $zipcode, addressDetail: $addressDetail)';
  }
}

extension AccidentExtension on Accident {
  Map<String, dynamic> toMap() {
    return {
      'AccidentId': accidentId,
      'ConstructionField': constructionField,
      'ConstructionType': constructionType,
      'WorkType': workType,
      'ConstructionMethod': constructionMethod,
      'DisasterCategory': disasterCategory,
      'AccidentCategory': accidentCategory,
      'Weather': weather,
      'AccidentYear': accidentYear,
      'AccidentMonth': accidentMonth,
      'AccidentTime': accidentTime,
      'AccidentLocationPref': accidentLocationPref,
      'AccidentBackground': accidentBackground,
      'AccidentCause': accidentCause,
      'AccidentCountermeasure': accidentCountermeasure,
      'Zipcode': zipcode,
      'AddressDetail': addressDetail
    };
  }
}
