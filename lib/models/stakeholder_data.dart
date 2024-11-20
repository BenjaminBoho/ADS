class StakeholderData {
  final int accidentId;
  final String role;
  final String name;

  StakeholderData({
    required this.accidentId,
    required this.role,
    required this.name,
  });

  StakeholderData withAccidentId(int accidentId) {
    return StakeholderData(
      accidentId: accidentId,
      role: role,
      name: name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'AccidentId': accidentId,
      'StakeholderRole': role,
      'StakeholderName': name,
    };
  }
}
