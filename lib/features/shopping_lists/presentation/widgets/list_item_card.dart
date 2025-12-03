import 'package:flutter/material.dart';
import 'package:shared_shopping_lists/features/shopping_lists/shopping_lists.dart';

class ListItemCard extends StatelessWidget {
  const ListItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onLongPress,
    required this.onCheckItemPressed,
  });

  final VoidCallback onLongPress;
  final ValueChanged<bool?> onCheckItemPressed;
  final ShoppingItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 0,
      minLeadingWidth: 50,
      contentPadding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
      minVerticalPadding: 20,
      title: GestureDetector(
        onLongPress: onLongPress,

        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 0,
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
        onChanged: onCheckItemPressed,
      ),
      trailing: ReorderableDragStartListener(
        index: index,
        child: Icon(
          Icons.drag_handle,
          color: Colors.grey.shade600,
          size: 18,
        ),
      ),
    );
  }
}
