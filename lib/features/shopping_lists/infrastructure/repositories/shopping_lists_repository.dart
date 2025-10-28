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

  Future<void> addItemToShoppingList(
    String shoppingListId,
    ShoppingItem item,
  ) async {
    // Get current shopping list
    final snapshot = await shoppingListsRef.child(shoppingListId).get();
    if (!snapshot.exists) return;

    final data = snapshot.value as Map<dynamic, dynamic>;
    final shoppingList = ShoppingList.fromJson(
      json.encode({
        'id': shoppingListId,
        ...Map<String, dynamic>.from(data),
      }),
    );

    // Add the new item to the list
    final updatedItems = List<ShoppingItem>.from(shoppingList.items)..add(item);
    final updatedShoppingList = shoppingList.copyWith(
      items: updatedItems,
      allItemsChecked: false, // New item added, so list is not completed
    );

    // Update the shopping list
    await updateShoppingList(updatedShoppingList);
  }

  Future<void> removeItemFromShoppingList(
    String shoppingListId,
    String itemName,
  ) async {
    // Get current shopping list
    final snapshot = await shoppingListsRef.child(shoppingListId).get();
    if (!snapshot.exists) return;

    final data = snapshot.value as Map<dynamic, dynamic>;
    final shoppingList = ShoppingList.fromJson(
      json.encode({
        'id': shoppingListId,
        ...Map<String, dynamic>.from(data),
      }),
    );

    // Remove the item from the list
    final updatedItems =
        shoppingList.items.where((item) => item.name != itemName).toList();

    // Check if all remaining items are checked
    final allItemsChecked =
        updatedItems.isNotEmpty && updatedItems.every((item) => item.isChecked);

    final updatedShoppingList = shoppingList.copyWith(
      items: updatedItems,
      allItemsChecked: allItemsChecked,
    );

    // Update the shopping list
    await updateShoppingList(updatedShoppingList);
  }

  Future<ShoppingList> createShoppingList(String name) async {
    // Generate a new ID for the shopping list
    final newRef = shoppingListsRef.push();
    final id = newRef.key!;

    final newShoppingList = ShoppingList(
      id: id,
      name: name,
      allItemsChecked: false,
      items: [],
    );

    // Save the new shopping list to Firebase with explicit empty array
    final dataToSave = newShoppingList.toMap();
    // Ensure items is explicitly saved as an empty array, not null
    dataToSave['items'] = <Map<String, dynamic>>[];

    await newRef.set(dataToSave);

    return newShoppingList;
  }

  Future<void> deleteShoppingList(String shoppingListId) async {
    await shoppingListsRef.child(shoppingListId).remove();
  }

  Future<ShoppingList> duplicateShoppingList(
    String originalListId,
    String newName,
  ) async {
    // Get the original shopping list
    final snapshot = await shoppingListsRef.child(originalListId).get();
    if (!snapshot.exists) {
      throw Exception('Original shopping list not found');
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    final originalList = ShoppingList.fromJson(
      json.encode({
        'id': originalListId,
        ...Map<String, dynamic>.from(data),
      }),
    );

    // Create a new list with the same items but reset all items to unchecked
    final newRef = shoppingListsRef.push();
    final newId = newRef.key!;

    // Reset all items to unchecked state for the duplicate
    final duplicatedItems =
        originalList.items
            .map((item) => item.copyWith(isChecked: false))
            .toList();

    final duplicatedList = ShoppingList(
      id: newId,
      name: newName,
      allItemsChecked: false,
      items: duplicatedItems,
    );

    final dataToSave = duplicatedList.toMap();
    // Ensure items array is properly handled
    dataToSave['items'] = duplicatedItems.map((item) => item.toMap()).toList();

    await newRef.set(dataToSave);

    return duplicatedList;
  }

  Future<ShoppingList> exportPendingItemsToNewList(
    String originalListId,
    String newName,
  ) async {
    // Get the original shopping list
    final snapshot = await shoppingListsRef.child(originalListId).get();
    if (!snapshot.exists) {
      throw Exception('Original shopping list not found');
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    final originalList = ShoppingList.fromJson(
      json.encode({
        'id': originalListId,
        ...Map<String, dynamic>.from(data),
      }),
    );

    // Filter only unchecked (pending) items for the new list
    final pendingItems =
        originalList.items
            .where((item) => !item.isChecked)
            .map((item) => item.copyWith(isChecked: false))
            .toList();

    // Keep only checked items in the original list
    final checkedItems =
        originalList.items.where((item) => item.isChecked).toList();

    // Create a new list with only pending items
    final newRef = shoppingListsRef.push();
    final newId = newRef.key!;

    final newList = ShoppingList(
      id: newId,
      name: newName,
      allItemsChecked: false,
      items: pendingItems,
    );

    final newListDataToSave = newList.toMap();
    // Ensure items array is properly handled
    newListDataToSave['items'] =
        pendingItems.map((item) => item.toMap()).toList();

    // Update the original list to keep only checked items
    final updatedOriginalList = originalList.copyWith(
      items: checkedItems,
      allItemsChecked:
          checkedItems.isNotEmpty &&
          checkedItems.every((item) => item.isChecked),
    );

    // Perform both operations
    await newRef.set(newListDataToSave);
    await updateShoppingList(updatedOriginalList);

    return newList;
  }
}
