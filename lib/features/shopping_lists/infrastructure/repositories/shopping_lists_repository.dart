import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

import '../../shopping_lists.dart';

class ShoppingListsRepository {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  DatabaseReference get shoppingListsRef => _database.child('shoppingLists');

  Stream<List<ShoppingList>> watchCompletedShoppingLists() {
    final query = shoppingListsRef
        .orderByChild('allItemsChecked')
        .equalTo(true);

    return query.onValue.map((event) {
      if (event.snapshot.value == null) {
        return <ShoppingList>[];
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;

      return data.entries.map((entry) {
        return ShoppingList.fromJson(
          json.encode({
            'id': entry.key,
            ...Map<String, dynamic>.from(entry.value as Map),
          }),
        );
      }).toList();
    });
  }

  Stream<List<ShoppingList>> watchPendingShoppingLists() {
    final query = shoppingListsRef
        .orderByChild('allItemsChecked')
        .equalTo(false);
    return query.onValue.map((event) {
      if (event.snapshot.value == null) {
        return <ShoppingList>[];
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;

      return data.entries.map((entry) {
        return ShoppingList.fromJson(
          json.encode({
            'id': entry.key,
            ...Map<String, dynamic>.from(entry.value as Map),
          }),
        );
      }).toList();
    });
  }

  Stream<ShoppingList?> watchShoppingList(String id) {
    final query = shoppingListsRef.child(id);
    return query.onValue.map((event) {
      if (event.snapshot.value == null) {
        return null;
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      print({'data': data});
      final entries = data.entries.toList();
      if (entries.isEmpty) {
        return null;
      }

      return ShoppingList.fromJson(
        json.encode({
          'id': id,
          ...Map<String, dynamic>.from(data),
        }),
      );
    });
  }

  Future<void> updateShoppingList(ShoppingList shoppingList) async {
    await shoppingListsRef.child(shoppingList.id).update(shoppingList.toMap());
  }

  Future<void> updateShoppingItem(
    String shoppingListId,
    String itemName,
    bool isChecked,
  ) async {
    await shoppingListsRef
        .child(shoppingListId)
        .child('items')
        .child(itemName)
        .update({'isChecked': isChecked});
  }

  Future<void> updateAllItemsCheckedStatus(
    String shoppingListId,
    bool allItemsChecked,
  ) async {
    await shoppingListsRef.child(shoppingListId).update({
      'allItemsChecked': allItemsChecked,
    });
  }
}
