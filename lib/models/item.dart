class Item {
  final String itemGenre;
  final String itemName;
  final String itemValue;

  Item({
    required this.itemGenre,
    required this.itemName,
    required this.itemValue,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemGenre: map['ItemGenre'] as String,
      itemName: map['ItemName'] as String,
      itemValue: map['ItemValue'] as String
    );
  }
}