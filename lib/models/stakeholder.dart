class Stakeholder {
  final int? stakeholderId;
  final int accidentId;
  final String role;
  final String name;

  Stakeholder({
    this.stakeholderId,
    required this.accidentId,
    this.role = '',
    this.name = '',
  });

  Stakeholder withAccidentId(int newAccidentId) {
    return Stakeholder(
      stakeholderId: stakeholderId,
      accidentId: newAccidentId,
      role: role,
      name: name,
    );
  }

  Stakeholder copyWith({
    int? stakeholderId,
    int? accidentId,
    String? role,
    String? name,
  }) {
    return Stakeholder(
      stakeholderId: stakeholderId ?? this.stakeholderId,
      accidentId: accidentId ?? this.accidentId,
      role: role ?? this.role,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (stakeholderId != null) 'StakeholderId': stakeholderId,
      'AccidentId': accidentId,
      'StakeholderRole': role,
      'StakeholderName': name,
    };
  }

  factory Stakeholder.fromMap(Map<String, dynamic> map) {
    return Stakeholder(
      stakeholderId: map['StakeholderId'] as int?,
      accidentId: map['AccidentId'] as int,
      role: map['StakeholderRole'] as String? ?? '',
      name: map['StakeholderName'] as String? ?? '',
    );
  }
}
