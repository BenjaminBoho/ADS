class Stakeholder {
  final int stakeholderId;
  final int accidentId;
  late final String role;
  final String name;

  Stakeholder(
      {required this.stakeholderId,
      required this.accidentId,
      required this.role,
      required this.name});

  Map<String, dynamic> toMap() {
    return {
      'StakeholderId': stakeholderId,
      'AccidentId': accidentId,
      'StakeholderRole': role,
      'StakeholderName': name,
    };
  }

  factory Stakeholder.fromMap(Map<String, dynamic> map) {
    return Stakeholder(
      stakeholderId: map['StakeholderId'] as int,
      accidentId: map['AccidentId'] as int,
      role: map['StakeholderRole'] as String,
      name: map['StakeholderName'] as String,
    );
  }
}
