import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/providers/repository_providers.dart';
import '../models/revenue.dart';
import '../repositories/revenue_repository.dart';

final revenueNotifierProvider =
    StateNotifierProvider<RevenueNotifier, Revenue?>((ref) {
  final repo = ref.watch(revenueRepositoryProvider);
  return RevenueNotifier(repo);
});

// Provider for selected date in revenue screen
final selectedRevenueDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

// Provider for total revenue data (single summary)
final totalRevenueProvider = StateProvider<Revenue?>((ref) => null);

// Notifier for managing revenue screen state - now returns single DailyRevenue
class RevenueNotifier extends StateNotifier<Revenue?> {
  final RevenueRepository repository;

  RevenueNotifier(this.repository) : super(null);

  void loadDailyRevenue(DateTime date) {
    final dailyRevenue = repository.getDailyRevenue(date);
    state = dailyRevenue;
  }

  void loadRevenueForDateRange(DateTime fromDate, DateTime toDate) {
    final dateRangeData = repository.getRevenueForDateRange(fromDate, toDate);

    // Aggregate all days into a single total
    if (dateRangeData.isNotEmpty) {
      state = _aggregateRevenue(dateRangeData, fromDate, toDate);
    } else {
      state = null;
    }
  }

  void loadMonthlyRevenue(int year, int month) {
    final monthlyRevenue = repository.getMonthlyRevenue(year, month);
    state = monthlyRevenue;
  }

  // Helper method to aggregate multiple DailyRevenue into one total
  Revenue _aggregateRevenue(
      List<Revenue> revenueList, DateTime fromDate, DateTime toDate) {
    int totalServiceItemCount =
        revenueList.fold(0, (sum, day) => sum + day.totalServiceItemCount);
    int doneCount = revenueList.fold(0, (sum, day) => sum + day.doneCount);
    int inProgressCount =
        revenueList.fold(0, (sum, day) => sum + day.inProgressCount);
    int returnCount = revenueList.fold(0, (sum, day) => sum + day.returnCount);
    int freeCount = revenueList.fold(0, (sum, day) => sum + day.freeCount);
    int inStoreCount =
        revenueList.fold(0, (sum, day) => sum + day.inStoreCount);
    int deliveredCount =
        revenueList.fold(0, (sum, day) => sum + day.deliveredCount);
    int priceTotal = revenueList.fold(0, (sum, day) => sum + day.priceTotal);
    int expenseTotal =
        revenueList.fold(0, (sum, day) => sum + day.expenseTotal);
    int profit = priceTotal - expenseTotal;

    return Revenue(
      date: fromDate, // Use fromDate as the reference date
      totalServiceItemCount: totalServiceItemCount,
      doneCount: doneCount,
      inProgressCount: inProgressCount,
      returnCount: returnCount,
      freeCount: freeCount,
      inStoreCount: inStoreCount,
      deliveredCount: deliveredCount,
      priceTotal: priceTotal,
      expenseTotal: expenseTotal,
      profit: profit,
    );
  }
}
