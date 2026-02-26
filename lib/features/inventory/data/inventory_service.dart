import '../models/product.dart';

class InventoryService {
  final List<Product> _products = [
    const Product(
      id: 'p1',
      name: 'iPhone 15 Pro Max',
      brand: 'Apple',
      retailPrice: 1299.99,
      wholesalePrice: 1100.00,
      quantity: 8,
      category: 'Smartphone',
      imeiList: ['351234567890123', '351234567890124'],
    ),
    const Product(
      id: 'p2',
      name: 'Galaxy S24 Ultra',
      brand: 'Samsung',
      retailPrice: 1199.99,
      wholesalePrice: 1000.00,
      quantity: 3,
      category: 'Smartphone',
      imeiList: ['352345678901234'],
    ),
    const Product(
      id: 'p3',
      name: 'Pixel 8 Pro',
      brand: 'Google',
      retailPrice: 899.99,
      wholesalePrice: 750.00,
      quantity: 12,
      category: 'Smartphone',
    ),
    const Product(
      id: 'p4',
      name: 'AirPods Pro 2',
      brand: 'Apple',
      retailPrice: 249.99,
      wholesalePrice: 190.00,
      quantity: 20,
      category: 'Accessories',
    ),
    const Product(
      id: 'p5',
      name: 'Galaxy Watch 6',
      brand: 'Samsung',
      retailPrice: 299.99,
      wholesalePrice: 240.00,
      quantity: 5,
      category: 'Wearables',
    ),
    const Product(
      id: 'p6',
      name: 'iPhone 14',
      brand: 'Apple',
      retailPrice: 799.99,
      wholesalePrice: 680.00,
      quantity: 2,
      category: 'Smartphone',
    ),
  ];

  Future<List<Product>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_products);
  }

  Future<Product?> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Product> create(Product product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _products.add(product);
    return product;
  }

  Future<Product> update(Product product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) _products[index] = product;
    return product;
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _products.removeWhere((p) => p.id == id);
  }
}
