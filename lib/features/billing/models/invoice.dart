import 'cart_item.dart';

enum PaymentType { cash, card, transfer }

class Invoice {
  const Invoice({
    required this.id,
    required this.items,
    required this.paymentType,
    required this.createdAt,
    this.customerName,
    this.discount = 0,
    this.taxRate = 0.05,
  });

  final String id;
  final List<CartItem> items;
  final PaymentType paymentType;
  final DateTime createdAt;
  final String? customerName;
  final double discount;
  final double taxRate;

  double get subtotal => items.fold(0, (sum, i) => sum + i.total);
  double get discountAmount => subtotal * (discount / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * taxRate;
  double get grandTotal => taxableAmount + taxAmount;

  String get paymentLabel {
    switch (paymentType) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.card:
        return 'Card';
      case PaymentType.transfer:
        return 'Transfer';
    }
  }
}
