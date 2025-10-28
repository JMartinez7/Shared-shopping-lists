import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_shopping_lists/features/shopping_lists/shopping_lists.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context, ref),
        tooltip: 'Create New List'.tr(),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 150,
                child: Image.asset('assets/img/app_brand_img.png'),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ShoppingListsView()],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController listNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New List'.tr()),
          content: TextField(
            controller: listNameController,
            decoration: InputDecoration(
              labelText: 'List name'.tr(),
              hintText: 'Enter list name'.tr(),
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
                final listName = listNameController.text.trim();
                if (listName.isNotEmpty) {
                  try {
                    final shoppingListsActions = ref.read(
                      shoppingListsActionsProvider,
                    );
                    final newList = await shoppingListsActions.createNewList(
                      listName,
                    );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      // Navigate directly to the new shopping list screen
                      context.push('/shopping-list', extra: newList);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating list: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text('Create'.tr()),
            ),
          ],
        );
      },
    );
  }
}
