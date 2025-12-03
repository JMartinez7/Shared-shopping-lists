import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_shopping_lists/features/shopping_lists/presentation/widgets/list_item_card.dart';

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
          _refreshAction(ref),
        ],
      ),
      floatingActionButton: _addItemFab(context, ref),
      body: shoppingListStream.when(
        data: (currentShoppingList) {
          if (currentShoppingList == null) {
            return const Center(child: Text('Shopping list not found'));
          }
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _progressIndicator(currentShoppingList),
                      _itemsList(context, ref, currentShoppingList),
                      if (currentShoppingList.items.isNotEmpty)
                        _additionalInfo(),
                    ],
                  ),
                ),
              ],
            ),
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

  Container _additionalInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Long press item to edit or delete • Hold and drag to reorder'
                  .tr(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  FloatingActionButton _addItemFab(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showAddItemDialog(context, ref),
      tooltip: 'Add Item'.tr(),
      child: const Icon(Icons.add),
    );
  }

  IconButton _refreshAction(WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () => ref.refresh(listProvider(shoppingList.id)),
      tooltip: 'Refresh',
    );
  }

  Widget _progressIndicator(ShoppingList shoppingList) {
    final checkedItems =
        shoppingList.items.where((item) => item.isChecked).length;
    final totalItems = shoppingList.items.length;
    final progress = totalItems > 0 ? checkedItems / totalItems : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.all(4),
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
                'Progress'.tr(),
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
                '$checkedItems / $totalItems ${'items'.tr()}',
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
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              shoppingList.allItemsChecked ? Colors.green : Colors.blue,
            ),
          ),
          if (shoppingList.allItemsChecked)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Shopping list completed!'.tr(),
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
              : ReorderableListView.builder(
                itemExtent: 50,
                onReorder: (oldIndex, newIndex) async {
                  // Handle reordering
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }

                  final items = List<ShoppingItem>.from(shoppingList.items);
                  final item = items.removeAt(oldIndex);
                  items.insert(newIndex, item);

                  try {
                    await shoppingListActions.reorderItems(
                      shoppingList.id,
                      items,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error reordering item: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                itemCount: shoppingList.items.length,
                itemBuilder: (context, index) {
                  final item = shoppingList.items[index];

                  return ListItemCard(
                    key: Key('${shoppingList.id}_${item.name}_$index'),
                    item: item,
                    index: index,
                    onLongPress:
                        () => _showItemContextMenu(
                          context,
                          ref,
                          item,
                          shoppingList,
                        ),
                    onCheckItemPressed: (value) async {
                      if (value != null) {
                        try {
                          await shoppingListActions.toggleItemChecked(
                            shoppingList.id,
                            item.name,
                            value,
                            shoppingList
                                .items, // Always pass the original unsorted items
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
                  );
                },
              ),
    );
  }

  void _showItemContextMenu(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem item,
    ShoppingList shoppingList,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: Text('Rename'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditItemDialog(
                    context,
                    ref,
                    item.name,
                    shoppingList,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'.tr()),
                onTap: () async {
                  Navigator.of(context).pop();
                  final confirmed = await _showDeleteConfirmationDialog(
                    context,
                    item.name,
                  );
                  if (confirmed == true) {
                    try {
                      final shoppingListActions = ref.read(
                        shoppingListActionsProvider,
                      );
                      await shoppingListActions.removeItemFromList(
                        shoppingList.id,
                        item.name,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Item "${item.name}" deleted'),
                            backgroundColor: Colors.orange,
                            action: SnackBarAction(
                              label: 'Dismiss',
                              onPressed: () {},
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting item: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController itemController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Item'.tr()),
          content: TextField(
            controller: itemController,
            decoration: InputDecoration(
              labelText: 'Item name'.tr(),
              hintText: 'Enter item name'.tr(),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                final itemName = itemController.text.trim();

                if (itemName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item name cannot be empty'.tr()),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Check for duplicate names
                final duplicateExists = shoppingList.items.any(
                  (item) => item.name.toLowerCase() == itemName.toLowerCase(),
                );

                if (duplicateExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item with this name already exists'.tr()),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  final shoppingListActions = ref.read(
                    shoppingListActionsProvider,
                  );
                  await shoppingListActions.addItemToList(
                    shoppingList.id,
                    itemName,
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Item "$itemName" added successfully',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding item: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('Add'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    WidgetRef ref,
    String currentItemName,
    ShoppingList shoppingList,
  ) {
    final TextEditingController itemController = TextEditingController(
      text: currentItemName,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Item'.tr()),
          content: TextField(
            controller: itemController,
            decoration: InputDecoration(
              labelText: 'Item name'.tr(),
              hintText: 'Enter item name'.tr(),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                final newItemName = itemController.text.trim();

                if (newItemName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item name cannot be empty'.tr()),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (newItemName == currentItemName) {
                  // No change, just close the dialog
                  Navigator.of(context).pop();
                  return;
                }

                // Check for duplicate names
                final duplicateExists = shoppingList.items.any(
                  (item) =>
                      item.name.toLowerCase() == newItemName.toLowerCase() &&
                      item.name != currentItemName,
                );

                if (duplicateExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item with this name already exists'.tr()),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  final shoppingListActions = ref.read(
                    shoppingListActionsProvider,
                  );
                  await shoppingListActions.editItemInList(
                    shoppingList.id,
                    currentItemName,
                    newItemName,
                    shoppingList.items,
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Item updated successfully'.tr(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating item: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('Save'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    String itemName,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'.tr()),
          content: Text('Are you sure you want to delete "$itemName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'.tr()),
            ),
          ],
        );
      },
    );
  }
}
