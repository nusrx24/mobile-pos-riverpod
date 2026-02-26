import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/billing_service.dart';
import '../models/cart_item.dart';
import '../models/invoice.dart';
import '../../inventory/models/product.dart';

final billingServiceProvider =
    Provider<BillingService>((ref) => BillingService());

class CartState {
  const CartState({
    this.items = const [],
    this.discount = 0,
    this.paymentType = PaymentType.cash,
    this.customerName,
    this.isLoading = false,
  });

  final List<CartItem> items;
  final double discount;
  final PaymentType paymentType;
  final String? customerName;
  final bool isLoading;

  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get discountAmount => subtotal * (discount / 100);
  double get taxAmount => (subtotal - discountAmount) * 0.05;
  double get grandTotal => subtotal - discountAmount + taxAmount;
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  CartState copyWith({
    List<CartItem>? items,
    double? discount,
    PaymentType? paymentType,
    String? customerName,
    bool? isLoading,
  }) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      paymentType: paymentType ?? this.paymentType,
      customerName: customerName ?? this.customerName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(this._service) : super(const CartState());

  final BillingService _service;

  void addProduct(Product product) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      final updated = state.items[existingIndex].copyWith(
        quantity: state.items[existingIndex].quantity + 1,
      );
      final items = [...state.items];
      items[existingIndex] = updated;
      state = state.copyWith(items: items);
    } else {
      state = state.copyWith(
        items: [...state.items, CartItem(product: product, quantity: 1)],
      );
    }
  }

  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((i) {
        if (i.product.id == productId) return i.copyWith(quantity: quantity);
        return i;
      }).toList(),
    );
  }

  void setDiscount(double discount) {
    state = state.copyWith(discount: discount.clamp(0, 100));
  }

  void setPaymentType(PaymentType type) {
    state = state.copyWith(paymentType: type);
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  Future<Invoice?> checkout() async {
    if (state.items.isEmpty) return null;
    state = state.copyWith(isLoading: true);
    try {
      final invoice = Invoice(
        id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        items: state.items,
        paymentType: state.paymentType,
        createdAt: DateTime.now(),
        customerName: state.customerName,
        discount: state.discount,
      );
      final saved = await _service.saveInvoice(invoice);
      state = const CartState(); // reset
      return saved;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  void clearCart() => state = const CartState();
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.read(billingServiceProvider));
});
