import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shopping_lists.dart';

final shoppingListsDataSourceProvider = Provider<ShoppingListsRepository>((
  ref,
) {
  return ShoppingListsRepository();
});

final completedListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  final dataSource = ref.watch(shoppingListsDataSourceProvider);
  return dataSource.watchCompletedShoppingLists();
});

final pendingListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  final dataSource = ref.watch(shoppingListsDataSourceProvider);
  return dataSource.watchPendingShoppingLists();
});

final shoppingListsActionsProvider = Provider<ShoppingListsActions>((ref) {
  final repository = ref.watch(shoppingListsDataSourceProvider);
  return ShoppingListsActions(repository);
});

class ShoppingListsActions {
  final ShoppingListsRepository _repository;

  ShoppingListsActions(this._repository);

  Future<ShoppingList> createNewList(String name) async {
    return await _repository.createShoppingList(name);
  }

  Future<void> deleteList(String shoppingListId) async {
    await _repository.deleteShoppingList(shoppingListId);
  }

  Future<ShoppingList> duplicateList(
    String originalListId,
    String newName,
  ) async {
    return await _repository.duplicateShoppingList(originalListId, newName);
  }

  Future<ShoppingList> exportPendingItems(
    String originalListId,
    String newName,
  ) async {
    return await _repository.exportPendingItemsToNewList(
      originalListId,
      newName,
    );
  }
}
