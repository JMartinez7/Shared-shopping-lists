import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shopping_lists.dart';
import '../widgets/shopping_list_card.dart';

class ShoppingListsView extends ConsumerWidget {
  const ShoppingListsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingShoppingLists = ref.watch(pendingListsProvider);

    final pendingLists = pendingShoppingLists.when(
      data: (shoppingLists) {
        return shoppingLists
            .map(
              (shoppingList) => ShoppingListsCard(
                shoppingList: shoppingList,
              ),
            )
            .toList();
      },
      loading: () => [const CircularProgressIndicator()],
      error:
          (error, stackTrace) => [
            Text('Error: $error'),
          ],
    );

    final completedShoppingLists = ref.watch(completedListsProvider);
    final completedLists = completedShoppingLists.when(
      data: (shoppingLists) {
        return shoppingLists
            .map(
              (shoppingList) => ShoppingListsCard(
                shoppingList: shoppingList,
              ),
            )
            .toList();
      },
      loading: () => [const CircularProgressIndicator()],
      error:
          (error, stackTrace) => [
            Text('Error: $error'),
          ],
    );

    return Container(
      margin: const EdgeInsets.only(left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Pending shopping lists'),
            style: const TextStyle(fontSize: 18),
          ),
          SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: pendingLists,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Completed shopping lists'.tr(),
            style: const TextStyle(fontSize: 16),
          ),
          SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: completedLists,
            ),
          ),
        ],
      ),
    );
  }
}
