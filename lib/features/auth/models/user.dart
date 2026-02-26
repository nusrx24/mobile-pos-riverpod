enum UserRole { admin, cashier, manager }

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String username;
  final String displayName;
  final UserRole role;

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.cashier:
        return 'Cashier';
      case UserRole.manager:
        return 'Manager';
    }
  }
}
