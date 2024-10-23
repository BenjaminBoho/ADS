class Item {
  final String itemGenre;
  final String itemName;

  Item({
    required this.itemGenre,
    required this.itemName,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemGenre: map['ItemGenre'] as String,
      itemName: map['ItemName'] as String,
    );
  }
}