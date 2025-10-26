import 'dart:convert';

class ShoppingList {
  final String id;
  final String name;
  final bool allItemsChecked;
  // final DateTime createdAt;
  // final DateTime updatedAt;

  ShoppingList({
    required this.id,
    required this.name,
    required this.allItemsChecked,
  });

  ShoppingList copyWith({
    String? id,
    String? name,
    bool? allItemsChecked,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      allItemsChecked: allItemsChecked ?? this.allItemsChecked,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'allItemsChecked': allItemsChecked});

    return result;
  }

  factory ShoppingList.fromMap(String key, Map<dynamic, dynamic> map) {
    return ShoppingList(
      id: key,
      name: map['name'] ?? '',
      allItemsChecked: map['allItemsChecked'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingList.fromJson(String source) {
    final map = json.decode(source);
    return ShoppingList.fromMap(map['id'], map);
  }

  @override
  String toString() =>
      'ShoppingList(id: $id, name: $name, allItemsChecked: $allItemsChecked)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShoppingList &&
        other.id == id &&
        other.name == name &&
        other.allItemsChecked == allItemsChecked;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ allItemsChecked.hashCode;
}
