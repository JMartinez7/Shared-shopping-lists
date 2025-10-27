import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shopping_lists.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key, required this.shoppingList});

  final ShoppingList shoppingList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListStream = ref.watch(listProvider(shoppingList.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(listProvider(shoppingList.id)),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: shoppingListStream.when(
        data: (currentShoppingList) {
          if (currentShoppingList == null) {
            return const Center(child: Text('Shopping list not found'));
          }
          return Column(
            children: [
              // _progressIndicator(currentShoppingList),
              _itemsList(context, ref, currentShoppingList),
              // Add more widgets to display the shopping list details
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: () => ref.refresh(listProvider(shoppingList.id)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _progressIndicator(ShoppingList shoppingList) {
    final checkedItems =
        shoppingList.items.where((item) => item.isChecked).length;
    final totalItems = shoppingList.items.length;
    final progress = totalItems > 0 ? checkedItems / totalItems : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            shoppingList.allItemsChecked
                ? Colors.green.shade50
                : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              shoppingList.allItemsChecked
                  ? Colors.green.shade200
                  : Colors.blue.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      shoppingList.allItemsChecked
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                ),
              ),
              Text(
                '$checkedItems / $totalItems items',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      shoppingList.allItemsChecked
                          ? Colors.green.shade600
                          : Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              shoppingList.allItemsChecked ? Colors.green : Colors.blue,
            ),
          ),
          if (shoppingList.allItemsChecked)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Shopping list completed!',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _itemsList(
    BuildContext context,
    WidgetRef ref,
    ShoppingList shoppingList,
  ) {
    final shoppingListActions = ref.watch(shoppingListActionsProvider);

    return Expanded(
      child:
          shoppingList.items.isEmpty
              ? const Center(
                child: Text(
                  'No items in this shopping list',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: shoppingList.items.length,
                itemBuilder: (context, index) {
                  final item = shoppingList.items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        item.name,
                        style:
                            item.isChecked
                                ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                      leading: Checkbox(
                        value: item.isChecked,
                        onChanged: (value) async {
                          if (value != null) {
                            try {
                              await shoppingListActions.toggleItemChecked(
                                shoppingList.id,
                                item.name,
                                value,
                                shoppingList.items,
                              );
                            } catch (e) {
                              // Show error to user
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error updating item: $e'),
                                    backgroundColor: Colors.red,
                                    action: SnackBarAction(
                                      label: 'Dismiss',
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                      trailing:
                          item.isChecked
                              ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                              : const Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.grey,
                              ),
                    ),
                  );
                },
              ),
    );
  }
}
