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
        return ShoppingList.fromMap(
          entry.key as String,
          entry.value as Map<dynamic, dynamic>,
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
        return ShoppingList.fromMap(
          entry.key as String,
          entry.value as Map<dynamic, dynamic>,
        );
      }).toList();
    });
  }
}
