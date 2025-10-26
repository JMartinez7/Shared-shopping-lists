import 'package:flutter/material.dart';

import '../../shopping_lists.dart';

class PendingShoppingListsCard extends StatelessWidget {
  const PendingShoppingListsCard({super.key, required this.shoppingList});

  final ShoppingList shoppingList;

  @override
  Widget build(BuildContext context) {
    final cardColor =
        shoppingList.allItemsChecked ? Colors.green : Colors.orange[700];
    return Container(
      width: 150,
      height: 75,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          shoppingList.name,
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}
