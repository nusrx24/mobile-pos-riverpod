import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_service.dart';
import '../models/dashboard_stats.dart';

final dashboardServiceProvider =
    Provider<DashboardService>((ref) => DashboardService());

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  return ref.read(dashboardServiceProvider).fetchStats();
});
