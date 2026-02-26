class DashboardStats {
  const DashboardStats({
    required this.todaySales,
    required this.monthlySales,
    required this.lowStockCount,
    required this.pendingInstallments,
    required this.weeklySalesData,
  });

  final double todaySales;
  final double monthlySales;
  final int lowStockCount;
  final double pendingInstallments;
  final List<DailySales> weeklySalesData;
}

class DailySales {
  const DailySales({required this.day, required this.amount});

  final String day;
  final double amount;
}
