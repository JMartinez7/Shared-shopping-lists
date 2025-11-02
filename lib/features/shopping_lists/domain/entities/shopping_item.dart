import 'dart:convert';

class ShoppingItem {
  final String name;
  final bool isChecked;
  final int order;

  ShoppingItem({
    required this.name,
    required this.isChecked,
    required this.order,
  });

  ShoppingItem copyWith({
    String? name,
    bool? isChecked,
    int? order,
  }) {
    return ShoppingItem(
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'isChecked': isChecked});
    result.addAll({'order': order});

    return result;
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      name: map['name'] ?? '',
      isChecked: map['isChecked'] ?? false,
      order: map['order'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingItem.fromJson(String source) =>
      ShoppingItem.fromMap(json.decode(source));

  @override
  String toString() =>
      'ShoppingItem(name: $name, isChecked: $isChecked, order: $order)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShoppingItem &&
        other.name == name &&
        other.isChecked == isChecked &&
        other.order == order;
  }

  @override
  int get hashCode => name.hashCode ^ isChecked.hashCode ^ order.hashCode;
}
