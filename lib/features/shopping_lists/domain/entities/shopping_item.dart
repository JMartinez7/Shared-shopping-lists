import 'dart:convert';

class ShoppingItem {
  final String name;
  final bool isChecked;

  ShoppingItem({
    required this.name,
    required this.isChecked,
  });

  ShoppingItem copyWith({
    String? name,
    bool? isChecked,
  }) {
    return ShoppingItem(
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'isChecked': isChecked});

    return result;
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      name: map['name'] ?? '',
      isChecked: map['isChecked'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingItem.fromJson(String source) =>
      ShoppingItem.fromMap(json.decode(source));

  @override
  String toString() => 'ShoppingItem(name: $name, isChecked: $isChecked)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShoppingItem &&
        other.name == name &&
        other.isChecked == isChecked;
  }

  @override
  int get hashCode => name.hashCode ^ isChecked.hashCode;
}
