import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/auth/logic/auth_provider.dart';
import '../logic/dashboard_provider.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'widgets/summary_card.dart';
import 'widgets/sales_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Dashboard'),
            if (authState.user != null)
              Text(
                authState.user!.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => ref.read(themeModeProvider.notifier).state =
                isDark ? ThemeMode.light : ThemeMode.dark,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardStatsProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Greeting
              Text(
                'Good ${_greeting()}, ${authState.user?.displayName ?? ''}!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppFormatters.date(DateTime.now()),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Summary cards grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SummaryCardFromAmount(
                    title: "Today's Sales",
                    amount: stats.todaySales,
                    icon: Icons.point_of_sale_rounded,
                    colors: AppTheme.gradientPrimary,
                    subtitle: 'Revenue today',
                  ),
                  SummaryCardFromAmount(
                    title: 'Monthly Sales',
                    amount: stats.monthlySales,
                    icon: Icons.trending_up_rounded,
                    colors: AppTheme.gradientSuccess,
                    subtitle: 'This month',
                  ),
                  SummaryCard(
                    title: 'Low Stock',
                    value: '${stats.lowStockCount} items',
                    icon: Icons.warning_amber_rounded,
                    colors: AppTheme.gradientWarning,
                    subtitle: 'Need restock',
                  ),
                  SummaryCardFromAmount(
                    title: 'Pending',
                    amount: stats.pendingInstallments,
                    icon: Icons.schedule_rounded,
                    colors: AppTheme.gradientInfo,
                    subtitle: 'Installments',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sales chart
              SalesChart(data: stats.weeklySalesData),
              const SizedBox(height: 20),

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuickActionButton(
                    icon: Icons.add_shopping_cart_rounded,
                    label: 'New Sale',
                    onTap: () => context.go('/billing'),
                  ),
                  const SizedBox(width: 12),
                  _QuickActionButton(
                    icon: Icons.inventory_2_rounded,
                    label: 'Inventory',
                    onTap: () => context.go('/inventory'),
                  ),
                  const SizedBox(width: 12),
                  _QuickActionButton(
                    icon: Icons.people_rounded,
                    label: 'Customers',
                    onTap: () => context.go('/customers'),
                  ),
                  const SizedBox(width: 12),
                  _QuickActionButton(
                    icon: Icons.build_rounded,
                    label: 'Repairs',
                    onTap: () => context.go('/repairs'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
