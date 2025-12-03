import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shopping_lists.dart';

class PendingShoppingListsCard extends ConsumerWidget {
  const PendingShoppingListsCard({
    super.key,
    required this.shoppingList,
  });

  final ShoppingList shoppingList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardColor =
        shoppingList.allItemsChecked ? Colors.green : Colors.orange[700];
    return InkWell(
      onTap: () {
        context.push('/shopping-list', extra: shoppingList);
      },
      onLongPress: () {
        _showListOptionsMenu(context, ref);
      },
      child: Container(
        width: 150,
        height: 110,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shoppingList.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${shoppingList.items.where((item) => item.isChecked).length}/${shoppingList.items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showListOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                shoppingList.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.blue),
                title: Text('Duplicate List'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDuplicateDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: Text('Rename List'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  _showRenameDialog(context, ref);
                },
              ),
              if (shoppingList.items.any((item) => !item.isChecked))
                ListTile(
                  leading: const Icon(Icons.playlist_add, color: Colors.orange),
                  title: Text('Export Pending Items'.tr()),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showExportPendingDialog(context, ref);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('Delete List'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDuplicateDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = '${shoppingList.name} (Copy)';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate List'.tr()),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'New list name'.tr(),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    final shoppingListsActions = ref.read(
                      shoppingListsActionsProvider,
                    );
                    final duplicatedList = await shoppingListsActions
                        .duplicateList(
                          shoppingList.id,
                          newName,
                        );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('List duplicated successfully'),
                          backgroundColor: Colors.green,
                          action: SnackBarAction(
                            label: 'Open'.tr(),
                            onPressed: () {
                              context.push(
                                '/shopping-list',
                                extra: duplicatedList,
                              );
                            },
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error duplicating list: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text('Duplicate'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete List'.tr()),
          content: Text(
            'Are you sure you want to delete "${shoppingList.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final shoppingListsActions = ref.read(
                    shoppingListsActionsProvider,
                  );
                  await shoppingListsActions.deleteList(shoppingList.id);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('List "${shoppingList.name}" deleted'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting list: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
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

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = shoppingList.name;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename List'.tr()),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'List name'.tr(),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != shoppingList.name) {
                  try {
                    final shoppingListsActions = ref.read(
                      shoppingListsActionsProvider,
                    );
                    await shoppingListsActions.renameList(
                      shoppingList.id,
                      newName,
                    );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('List renamed successfully'.tr()),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${'Error renaming list'.tr()}: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text('Rename'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showExportPendingDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController();
    final pendingItemsCount =
        shoppingList.items.where((item) => !item.isChecked).length;

    nameController.text = '${shoppingList.name} (Pending)';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export Pending Items'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will create a new list with $pendingItemsCount pending items from "${shoppingList.name}" and remove them from the original list.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Only completed items will remain in the original list.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'New list name'.tr(),
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    final shoppingListsActions = ref.read(
                      shoppingListsActionsProvider,
                    );
                    final newList = await shoppingListsActions
                        .exportPendingItems(
                          shoppingList.id,
                          newName,
                        );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pending items exported and removed from original list',
                          ),
                          backgroundColor: Colors.green,
                          action: SnackBarAction(
                            label: 'Open'.tr(),
                            onPressed: () {
                              context.push('/shopping-list', extra: newList);
                            },
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error exporting items: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text('Export'.tr()),
            ),
          ],
        );
      },
    );
  }
}
