class Address {
  final String zipcode;
  final String prefcode;
  /// 都道府県
  final String address1;
  /// 市区町村
  final String address2;
  final String address3;

  Address({
    required this.zipcode,
    required this.prefcode,
    required this.address1,
    required this.address2,
    required this.address3,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      zipcode: json['zipcode'],
      prefcode: json['prefcode'],
      address1: json['address1'],
      address2: json['address2'],
      address3: json['address3'],
    );
  }
}
