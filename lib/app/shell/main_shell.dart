import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem(icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard'),
    _TabItem(icon: Icons.inventory_2_rounded, label: 'Inventory', path: '/inventory'),
    _TabItem(icon: Icons.receipt_long_rounded, label: 'Billing', path: '/billing'),
    _TabItem(icon: Icons.people_rounded, label: 'Customers', path: '/customers'),
    _TabItem(icon: Icons.build_rounded, label: 'Repairs', path: '/repairs'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index != currentIndex) {
            context.go(_tabs[index].path);
          }
        },
        destinations: _tabs.map((tab) => NavigationDestination(
          icon: Icon(tab.icon),
          label: tab.label,
        )).toList(),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.path,
  });
  final IconData icon;
  final String label;
  final String path;
}
