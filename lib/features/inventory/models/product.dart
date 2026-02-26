class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.retailPrice,
    required this.wholesalePrice,
    required this.quantity,
    this.imeiList = const [],
    this.category = '',
    this.description = '',
  });

  final String id;
  final String name;
  final String brand;
  final double retailPrice;
  final double wholesalePrice;
  final int quantity;
  final List<String> imeiList;
  final String category;
  final String description;

  bool get isLowStock => quantity <= 5;

  Product copyWith({
    String? id,
    String? name,
    String? brand,
    double? retailPrice,
    double? wholesalePrice,
    int? quantity,
    List<String>? imeiList,
    String? category,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      retailPrice: retailPrice ?? this.retailPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      quantity: quantity ?? this.quantity,
      imeiList: imeiList ?? this.imeiList,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}
