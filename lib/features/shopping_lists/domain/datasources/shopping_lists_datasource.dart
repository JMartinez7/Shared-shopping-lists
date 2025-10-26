import '../../shopping_lists.dart';

abstract class ShoppingListsDatasource {
  Stream<List<ShoppingList>> fetchShoppingLists();
}
