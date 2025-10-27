class ShoppingItem {
  final String id;
  final String name;
  final bool isChecked;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.isChecked,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isChecked,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
