import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shopping_lists.dart';

final shoppingListDataSourceProvider = Provider<ShoppingListsRepository>((
  ref,
) {
  return ShoppingListsRepository();
});

final listProvider = StreamProvider.family<ShoppingList?, String>((ref, id) {
  final dataSource = ref.watch(shoppingListDataSourceProvider);
  return dataSource.watchShoppingList(id);
});

final shoppingListActionsProvider = Provider<ShoppingListActions>((ref) {
  final repository = ref.watch(shoppingListDataSourceProvider);
  return ShoppingListActions(repository);
});

class ShoppingListActions {
  final ShoppingListsRepository _repository;

  ShoppingListActions(this._repository);

  Future<void> toggleItemChecked(
    String shoppingListId,
    String itemName,
    bool isChecked,
    List<ShoppingItem> allItems,
  ) async {
    final itemNumber = allItems.indexWhere((item) => item.name == itemName);
    // Update the individual item
    await _repository.updateShoppingItem(
      shoppingListId,
      itemNumber.toString(),
      isChecked,
    );

    // Check if all items are now checked and update the list status accordingly
    final updatedItems =
        allItems.map((item) {
          if (item.name == itemName) {
            return item.copyWith(isChecked: isChecked);
          }
          return item;
        }).toList();

    final allItemsChecked = updatedItems.every((item) => item.isChecked);
    await _repository.updateAllItemsCheckedStatus(
      shoppingListId,
      allItemsChecked,
    );
  }

  Future<void> updateShoppingList(ShoppingList shoppingList) async {
    await _repository.updateShoppingList(shoppingList);
  }

  Future<void> addItemToList(String shoppingListId, String itemName) async {
    if (itemName.trim().isEmpty) return;

    await _repository.addItemToShoppingList(shoppingListId, itemName.trim());
  }

  Future<void> removeItemFromList(
    String shoppingListId,
    String itemName,
  ) async {
    await _repository.removeItemFromShoppingList(shoppingListId, itemName);
  }

  Future<void> editItemInList(
    String shoppingListId,
    String oldItemName,
    String newItemName,
    List<ShoppingItem> allItems,
  ) async {
    if (newItemName.trim().isEmpty) return;

    // Find the item to edit
    final itemToEdit = allItems.firstWhere(
      (item) => item.name == oldItemName,
      orElse: () => throw Exception('Item not found'),
    );

    // Create updated item with new name but same checked status and order
    final updatedItem = ShoppingItem(
      name: newItemName.trim(),
      isChecked: itemToEdit.isChecked,
      order: itemToEdit.order,
    );

    await _repository.editItemInShoppingList(
      shoppingListId,
      oldItemName,
      updatedItem,
    );
  }

  Future<void> reorderItems(
    String shoppingListId,
    List<ShoppingItem> reorderedItems,
  ) async {
    await _repository.reorderShoppingListItems(shoppingListId, reorderedItems);
  }
}
