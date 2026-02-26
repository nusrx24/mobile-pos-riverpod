import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inventory_service.dart';
import '../models/product.dart';

final inventoryServiceProvider =
    Provider<InventoryService>((ref) => InventoryService());

class InventoryState {
  const InventoryState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  List<Product> get filtered {
    if (searchQuery.isEmpty) return products;
    final q = searchQuery.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  InventoryState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
  }) {
    return InventoryState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier(this._service) : super(const InventoryState()) {
    loadProducts();
  }

  final InventoryService _service;

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final products = await _service.fetchAll();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      final created = await _service.create(product);
      state = state.copyWith(products: [...state.products, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final updated = await _service.update(product);
      state = state.copyWith(
        products: state.products.map((p) => p.id == updated.id ? updated : p).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _service.delete(id);
      state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  return InventoryNotifier(ref.read(inventoryServiceProvider));
});
