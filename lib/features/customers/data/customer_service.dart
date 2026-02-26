import '../models/customer.dart';

class CustomerService {
  final List<Customer> _customers = [
    Customer(
      id: 'c1',
      name: 'John Smith',
      phone: '+1 555-0101',
      email: 'john.smith@email.com',
      address: '123 Main St, New York',
      creditBalance: 250.00,
      createdAt: DateTime(2024, 1, 15),
    ),
    Customer(
      id: 'c2',
      name: 'Sarah Johnson',
      phone: '+1 555-0102',
      email: 'sarah.j@email.com',
      address: '456 Oak Ave, Los Angeles',
      creditBalance: 0,
      createdAt: DateTime(2024, 2, 20),
    ),
    Customer(
      id: 'c3',
      name: 'Mike Davis',
      phone: '+1 555-0103',
      email: 'mike.davis@email.com',
      address: '789 Pine Rd, Chicago',
      creditBalance: 1200.00,
      createdAt: DateTime(2024, 3, 5),
    ),
  ];

  Future<List<Customer>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_customers);
  }

  Future<Customer> create(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _customers.add(customer);
    return customer;
  }

  Future<Customer> update(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) _customers[index] = customer;
    return customer;
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _customers.removeWhere((c) => c.id == id);
  }
}
