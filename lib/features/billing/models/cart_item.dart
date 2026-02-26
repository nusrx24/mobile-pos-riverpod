import '../../inventory/models/product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    this.discount = 0,
  });

  final Product product;
  final int quantity;
  final double discount;

  double get unitPrice => product.retailPrice;
  double get subtotal => unitPrice * quantity;
  double get discountAmount => subtotal * (discount / 100);
  double get total => subtotal - discountAmount;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? discount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }
}
