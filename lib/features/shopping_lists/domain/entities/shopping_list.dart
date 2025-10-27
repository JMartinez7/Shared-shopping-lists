import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../shopping_lists.dart';

class ShoppingList {
  final String id;
  final String name;
  final bool allItemsChecked;
  // final DateTime createdAt;
  // final DateTime updatedAt;
  final List<ShoppingItem> items;

  ShoppingList({
    required this.id,
    required this.name,
    required this.allItemsChecked,
    required this.items,
  });

  ShoppingList copyWith({
    String? id,
    String? name,
    bool? allItemsChecked,
    List<ShoppingItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      allItemsChecked: allItemsChecked ?? this.allItemsChecked,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'allItemsChecked': allItemsChecked});
    result.addAll({'items': items.map((x) => x.toMap()).toList()});

    return result;
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      allItemsChecked: map['allItemsChecked'] ?? false,
      items: List<ShoppingItem>.from(
        map['items']?.map((x) => ShoppingItem.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingList.fromJson(String source) =>
      ShoppingList.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ShoppingList(id: $id, name: $name, allItemsChecked: $allItemsChecked, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShoppingList &&
        other.id == id &&
        other.name == name &&
        other.allItemsChecked == allItemsChecked &&
        listEquals(other.items, items);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        allItemsChecked.hashCode ^
        items.hashCode;
  }
}
