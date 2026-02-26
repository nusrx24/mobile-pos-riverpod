import '../models/dashboard_stats.dart';

class DashboardService {
  Future<DashboardStats> fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const DashboardStats(
      todaySales: 4250.00,
      monthlySales: 87430.50,
      lowStockCount: 5,
      pendingInstallments: 12500.00,
      weeklySalesData: [
        DailySales(day: 'Mon', amount: 3200),
        DailySales(day: 'Tue', amount: 4800),
        DailySales(day: 'Wed', amount: 3600),
        DailySales(day: 'Thu', amount: 5100),
        DailySales(day: 'Fri', amount: 6200),
        DailySales(day: 'Sat', amount: 7800),
        DailySales(day: 'Sun', amount: 4250),
      ],
    );
  }
}
