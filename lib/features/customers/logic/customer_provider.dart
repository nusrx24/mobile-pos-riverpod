import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/customer_service.dart';
import '../models/customer.dart';

final customerServiceProvider =
    Provider<CustomerService>((ref) => CustomerService());

class CustomerState {
  const CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  final List<Customer> customers;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  List<Customer> get filtered {
    if (searchQuery.isEmpty) return customers;
    final q = searchQuery.toLowerCase();
    return customers
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phone.contains(q) ||
            c.email.toLowerCase().contains(q))
        .toList();
  }

  CustomerState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  CustomerNotifier(this._service) : super(const CustomerState()) {
    loadCustomers();
  }

  final CustomerService _service;

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final customers = await _service.fetchAll();
      state = state.copyWith(customers: customers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      final created = await _service.create(customer);
      state = state.copyWith(customers: [...state.customers, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      final updated = await _service.update(customer);
      state = state.copyWith(
        customers: state.customers
            .map((c) => c.id == updated.id ? updated : c)
            .toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await _service.delete(id);
      state = state.copyWith(
        customers: state.customers.where((c) => c.id != id).toList(),
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

final customerProvider =
    StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  return CustomerNotifier(ref.read(customerServiceProvider));
});
