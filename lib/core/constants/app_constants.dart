class AppConstants {
  AppConstants._();

  static const String appName = 'Mobile POS';
  static const String appVersion = '1.0.0';

  // Mock credentials
  static const Map<String, String> mockCredentials = {
    'admin': 'admin123',
    'cashier': 'cash123',
    'manager': 'mgr123',
  };

  static const Map<String, String> mockRoles = {
    'admin': 'Admin',
    'cashier': 'Cashier',
    'manager': 'Manager',
  };

  // Tax rate
  static const double taxRate = 0.05;

  // Currency
  static const String currencySymbol = '\$';

  // Pagination
  static const int pageSize = 20;
}
