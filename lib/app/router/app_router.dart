import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/logic/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inventory/presentation/product_list_screen.dart';
import '../../features/inventory/presentation/add_edit_product_screen.dart';
import '../../features/billing/presentation/billing_screen.dart';
import '../../features/billing/presentation/invoice_screen.dart';
import '../../features/billing/models/invoice.dart';
import '../../features/customers/presentation/customer_list_screen.dart';
import '../../features/customers/presentation/add_customer_screen.dart';
import '../../features/customers/presentation/customer_detail_screen.dart';
import '../../features/customers/models/customer.dart';
import '../../features/repairs/presentation/repair_list_screen.dart';
import '../../features/repairs/presentation/add_repair_screen.dart';
import '../shell/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final onLoginPage = state.matchedLocation == '/login';
      if (!isLoggedIn && !onLoginPage) return '/login';
      if (isLoggedIn && onLoginPage) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const ProductListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) =>
                    const AddEditProductScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => AddEditProductScreen(
                  productId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/billing',
            builder: (context, state) => const BillingScreen(),
            routes: [
              GoRoute(
                path: 'invoice',
                builder: (context, state) => InvoiceScreen(
                  invoice: state.extra as Invoice,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomerListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddCustomerScreen(),
              ),
              GoRoute(
                path: 'detail',
                builder: (context, state) => CustomerDetailScreen(
                  customer: state.extra as Customer,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/repairs',
            builder: (context, state) => const RepairListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddRepairScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
