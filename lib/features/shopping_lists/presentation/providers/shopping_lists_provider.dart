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
