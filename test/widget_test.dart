import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/features/auth/data/auth_service.dart';
import 'package:mobile_pos/features/auth/logic/auth_provider.dart';
import 'package:mobile_pos/features/inventory/models/product.dart';
import 'package:mobile_pos/features/billing/models/cart_item.dart';
import 'package:mobile_pos/features/billing/models/invoice.dart';
import 'package:mobile_pos/features/billing/logic/cart_provider.dart';
import 'package:mobile_pos/features/customers/models/customer.dart';
import 'package:mobile_pos/features/repairs/models/repair_job.dart';

void main() {
  group('AuthService', () {
    final service = AuthService();

    test('returns user on valid credentials', () async {
      final user = await service.login('admin', 'admin123');
      expect(user, isNotNull);
      expect(user!.username, 'admin');
      expect(user.roleLabel, 'Admin');
    });

    test('returns null on invalid credentials', () async {
      final user = await service.login('admin', 'wrongpassword');
      expect(user, isNull);
    });

    test('returns cashier user', () async {
      final user = await service.login('cashier', 'cash123');
      expect(user, isNotNull);
      expect(user!.roleLabel, 'Cashier');
    });
  });

  group('Product model', () {
    const product = Product(
      id: 'test1',
      name: 'Test Phone',
      brand: 'TestBrand',
      retailPrice: 999.99,
      wholesalePrice: 800.00,
      quantity: 5,
    );

    test('isLowStock returns true when quantity <= 5', () {
      expect(product.isLowStock, isTrue);
    });

    test('isLowStock returns false when quantity > 5', () {
      const p = Product(
        id: 'test2',
        name: 'Test',
        brand: 'Brand',
        retailPrice: 100,
        wholesalePrice: 80,
        quantity: 10,
      );
      expect(p.isLowStock, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      final updated = product.copyWith(quantity: 20);
      expect(updated.id, product.id);
      expect(updated.name, product.name);
      expect(updated.quantity, 20);
    });
  });

  group('CartItem', () {
    const product = Product(
      id: 'p1',
      name: 'Phone',
      brand: 'Brand',
      retailPrice: 100.0,
      wholesalePrice: 80.0,
      quantity: 10,
    );

    test('calculates subtotal correctly', () {
      const item = CartItem(product: product, quantity: 3);
      expect(item.subtotal, 300.0);
    });

    test('calculates discount correctly', () {
      const item = CartItem(product: product, quantity: 2, discount: 10);
      expect(item.discountAmount, 20.0);
      expect(item.total, 180.0);
    });

    test('total equals subtotal when no discount', () {
      const item = CartItem(product: product, quantity: 2);
      expect(item.total, item.subtotal);
    });
  });

  group('CartNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts with empty cart', () {
      final state = container.read(cartProvider);
      expect(state.items, isEmpty);
      expect(state.grandTotal, 0);
    });

    test('adds product to cart', () {
      const product = Product(
        id: 'p1',
        name: 'Phone',
        brand: 'Brand',
        retailPrice: 200.0,
        wholesalePrice: 160.0,
        quantity: 5,
      );
      container.read(cartProvider.notifier).addProduct(product);
      final state = container.read(cartProvider);
      expect(state.items.length, 1);
      expect(state.items.first.quantity, 1);
    });

    test('increments quantity when adding same product', () {
      const product = Product(
        id: 'p1',
        name: 'Phone',
        brand: 'Brand',
        retailPrice: 200.0,
        wholesalePrice: 160.0,
        quantity: 5,
      );
      container.read(cartProvider.notifier).addProduct(product);
      container.read(cartProvider.notifier).addProduct(product);
      final state = container.read(cartProvider);
      expect(state.items.length, 1);
      expect(state.items.first.quantity, 2);
    });

    test('removes product from cart', () {
      const product = Product(
        id: 'p1',
        name: 'Phone',
        brand: 'Brand',
        retailPrice: 200.0,
        wholesalePrice: 160.0,
        quantity: 5,
      );
      container.read(cartProvider.notifier).addProduct(product);
      container.read(cartProvider.notifier).removeProduct('p1');
      final state = container.read(cartProvider);
      expect(state.items, isEmpty);
    });

    test('sets discount correctly', () {
      container.read(cartProvider.notifier).setDiscount(15);
      final state = container.read(cartProvider);
      expect(state.discount, 15);
    });

    test('clamps discount to 0-100', () {
      container.read(cartProvider.notifier).setDiscount(150);
      expect(container.read(cartProvider).discount, 100);
      container.read(cartProvider.notifier).setDiscount(-10);
      expect(container.read(cartProvider).discount, 0);
    });
  });

  group('Invoice', () {
    const product = Product(
      id: 'p1',
      name: 'Phone',
      brand: 'Brand',
      retailPrice: 200.0,
      wholesalePrice: 160.0,
      quantity: 5,
    );
    const item = CartItem(product: product, quantity: 2);

    test('calculates grand total with tax', () {
      final invoice = Invoice(
        id: 'INV-001',
        items: [item],
        paymentType: PaymentType.cash,
        createdAt: DateTime.now(),
        taxRate: 0.05,
      );
      expect(invoice.subtotal, 400.0);
      expect(invoice.taxAmount, 20.0);
      expect(invoice.grandTotal, 420.0);
    });

    test('applies discount', () {
      final invoice = Invoice(
        id: 'INV-002',
        items: [item],
        paymentType: PaymentType.card,
        createdAt: DateTime.now(),
        discount: 10,
        taxRate: 0.05,
      );
      expect(invoice.discountAmount, 40.0);
      expect(invoice.taxableAmount, 360.0);
      expect(invoice.grandTotal, closeTo(378.0, 0.01));
    });
  });

  group('Customer model', () {
    test('copyWith works correctly', () {
      final original = Customer(
        id: 'c1',
        name: 'John',
        phone: '+1 555-0001',
        creditBalance: 100,
      );
      final updated = original.copyWith(creditBalance: 200);
      expect(updated.id, original.id);
      expect(updated.creditBalance, 200);
    });
  });

  group('RepairJob model', () {
    test('statusLabel returns correct string', () {
      const job = RepairJob(
        id: 'r1',
        customerName: 'Test',
        deviceModel: 'iPhone',
        issue: 'Screen crack',
        status: RepairStatus.inProgress,
        createdAt: null,
      );
      expect(job.statusLabel, 'In Progress');
    });

    test('copyWith updates status', () {
      const job = RepairJob(
        id: 'r1',
        customerName: 'Test',
        deviceModel: 'iPhone',
        issue: 'Screen crack',
        status: RepairStatus.pending,
        createdAt: null,
      );
      final updated = job.copyWith(status: RepairStatus.completed);
      expect(updated.status, RepairStatus.completed);
      expect(updated.customerName, job.customerName);
    });
  });
}
