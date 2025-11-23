import 'package:easy_localization/easy_localization.dart';
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
                _progressIndicator(currentShoppingList),
                if (currentShoppingList.items.isNotEmpty) _additionalInfo(),
                _itemsList(context, ref, currentShoppingList),
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
              'Tap item name or edit icon to modify • Swipe left to delete • Hold and drag to reorder'
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
                  return Dismissible(
                    key: Key('${shoppingList.id}_${item.name}_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmationDialog(
                        context,
                        item.name,
                      );
                    },
                    onDismissed: (direction) async {
                      try {
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
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: InkWell(
                          onTap:
                              () => _showEditItemDialog(
                                context,
                                ref,
                                item.name,
                                shoppingList,
                              ),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 2,
                            ),
                            child: Text(
                              item.name,
                              style:
                                  item.isChecked
                                      ? const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      )
                                      : null,
                            ),
                          ),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // IconButton(
                            //   icon: const Icon(
                            //     Icons.edit,
                            //     color: Colors.blue,
                            //     size: 20,
                            //   ),
                            //   onPressed:
                            //       () => _showEditItemDialog(
                            //         context,
                            //         ref,
                            //         item.name,
                            //         shoppingList,
                            //       ),
                            //   tooltip: 'Edit item'.tr(),
                            // ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.drag_handle,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            // const SizedBox(width: 8),
                            // item.isChecked
                            //     ? const Icon(
                            //       Icons.check_circle,
                            //       color: Colors.green,
                            //     )
                            //     : const Icon(
                            //       Icons.radio_button_unchecked,
                            //       color: Colors.grey,
                            //     ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
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
