class AccidentData {
  final String constructionField;
  final String constructionType;
  final String workType;
  final String constructionMethod;
  final String disasterCategory;
  final String accidentCategory;
  final String? weather;
  final int accidentYear;
  final int accidentMonth;
  final int accidentTime;
  final String accidentLocationPref;
  final String? accidentBackground;
  final String? accidentCause;
  final String? accidentCountermeasure;
  final int? zipcode;
  final String? addressDetail;

  AccidentData({
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
  });

  Map<String, dynamic> toMap() {
    return {
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
      'AddressDetail': addressDetail,
    };
  }
}
