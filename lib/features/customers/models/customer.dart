class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.creditBalance = 0,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt;

  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final double creditBalance;
  final String notes;
  final DateTime? createdAt;

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? creditBalance,
    String? notes,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      creditBalance: creditBalance ?? this.creditBalance,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
