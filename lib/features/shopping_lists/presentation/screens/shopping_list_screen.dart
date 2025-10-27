import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../shopping_lists.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key, required this.shoppingList});

  final ShoppingList shoppingList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
      ),
      body: Column(
        children: [
          _directLinks,
          _itemsList(shoppingList),
          // Add more widgets to display the shopping list details
        ],
      ),
    );
  }

  final _directLinks = Padding(
    padding: EdgeInsetsGeometry.all(8.0),
    child: Text('Direct Links'),
  );

  Widget _itemsList(ShoppingList shoppingList) {
    return Expanded(
      child: ListView.builder(
        itemCount: shoppingList.items.length,
        itemBuilder: (context, index) {
          final item = shoppingList.items[index];
          return ListTile(
            title: Text(item.name),
            trailing: Checkbox(
              value: item.isChecked,
              onChanged: (value) {
                // Handle checkbox state change
              },
            ),
          );
        },
      ),
    );
  }
}
