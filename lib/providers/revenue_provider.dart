import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/providers/repository_providers.dart';
import '../models/daily_revenue.dart';
import '../repositories/revenue_repository.dart';

final revenueNotifierProvider =
    StateNotifierProvider<RevenueNotifier, List<DailyRevenue>>((ref) {
  final repo = ref.watch(revenueRepositoryProvider);
  return RevenueNotifier(repo);
});

// Provider for selected date in revenue screen
final selectedRevenueDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

// Provider for daily revenue data
final dailyRevenueProvider = Provider<DailyRevenue>((ref) {
  final revenueRepo = ref.watch(revenueRepositoryProvider);
  final selectedDate = ref.watch(selectedRevenueDateProvider);
  return revenueRepo.getDailyRevenue(selectedDate);
});

// Provider for date range revenue data
final dateRangeRevenueProvider = StateProvider<List<DailyRevenue>>((ref) => []);

// Notifier for managing revenue screen state
class RevenueNotifier extends StateNotifier<List<DailyRevenue>> {
  final RevenueRepository repository;

  RevenueNotifier(this.repository) : super([]);

  void loadDailyRevenue(DateTime date) {
    final dailyRevenue = repository.getDailyRevenue(date);
    state = [dailyRevenue];
  }

  void loadRevenueForDateRange(DateTime fromDate, DateTime toDate) {
    state = repository.getRevenueForDateRange(fromDate, toDate);
  }

  void loadMonthlyRevenue(int year, int month) {
    final monthlyRevenue = repository.getMonthlyRevenue(year, month);
    state = [monthlyRevenue];
  }
}
