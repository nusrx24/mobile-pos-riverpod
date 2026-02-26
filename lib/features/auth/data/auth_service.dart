import '../models/user.dart';

class AuthService {
  static const _users = [
    AppUser(
      id: '1',
      username: 'admin',
      displayName: 'Admin User',
      role: UserRole.admin,
    ),
    AppUser(
      id: '2',
      username: 'cashier',
      displayName: 'Cashier User',
      role: UserRole.cashier,
    ),
    AppUser(
      id: '3',
      username: 'manager',
      displayName: 'Manager User',
      role: UserRole.manager,
    ),
  ];

  static const _passwords = {
    'admin': 'admin123',
    'cashier': 'cash123',
    'manager': 'mgr123',
  };

  Future<AppUser?> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final expected = _passwords[username.toLowerCase().trim()];
    if (expected == null || expected != password) return null;

    return _users.firstWhere(
      (u) => u.username == username.toLowerCase().trim(),
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
