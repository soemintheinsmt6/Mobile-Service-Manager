import '../database/object_box.dart';
import '../models/daily_revenue.dart';
import '../models/service_item.dart';

class RevenueRepository {
  final ObjectBox _objectBox;

  RevenueRepository(this._objectBox);

  DailyRevenue getDailyRevenue(DateTime selectedDate) {
    // Get all service items for the selected date
    List<ServiceItem> dayItems = _getServiceItemsForDate(selectedDate);

    // Calculate counts by status
    int doneCount = dayItems.where((item) => item.status == 'done').length;
    int inProgressCount =
        dayItems.where((item) => item.status == 'in_progress').length;
    int returnCount = dayItems.where((item) => item.status == 'return').length;
    int freeCount = dayItems.where((item) => item.status == 'free').length;

    // Calculate counts by location
    int inStoreCount =
        dayItems.where((item) => item.location == 'in_store').length;
    int deliveredCount =
        dayItems.where((item) => item.location == 'delivered').length;

    // Calculate financial totals
    int priceTotal =
        dayItems.fold(0, (sum, item) => sum + (item.servicePrice ?? 0));
    int expenseTotal =
        dayItems.fold(0, (sum, item) => sum + (item.expense ?? 0));
    int profit = priceTotal - expenseTotal;

    return DailyRevenue(
      date: selectedDate,
      totalServiceItemCount: dayItems.length,
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

  List<ServiceItem> _getServiceItemsForDate(DateTime date) {
    final dateString =
        date.toString().split(' ')[0]; // Get only the date part (YYYY-MM-DD)

    // Get all non-trash service items
    List<ServiceItem> allItems = _objectBox.getAllServiceItems();

    // Filter by date
    return allItems.where((item) {
      final itemDateString =
          item.issueDate.split(' ')[0]; // Extract date part from stored item
      return itemDateString == dateString;
    }).toList();
  }

  // Get revenue data for a date range
  List<DailyRevenue> getRevenueForDateRange(
      DateTime fromDate, DateTime toDate) {
    List<DailyRevenue> revenueList = [];
    DateTime currentDate = fromDate;

    while (currentDate.isBefore(toDate.add(const Duration(days: 1)))) {
      revenueList.add(getDailyRevenue(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return revenueList;
  }

  // Get monthly revenue summary
  DailyRevenue getMonthlyRevenue(int year, int month) {
    DateTime firstDay = DateTime(year, month, 1);
    DateTime lastDay = DateTime(year, month + 1, 0);

    List<DailyRevenue> monthlyData = getRevenueForDateRange(firstDay, lastDay);

    // Aggregate all daily data into monthly summary
    int totalServiceItemCount =
        monthlyData.fold(0, (sum, day) => sum + day.totalServiceItemCount);
    int doneCount = monthlyData.fold(0, (sum, day) => sum + day.doneCount);
    int inProgressCount =
        monthlyData.fold(0, (sum, day) => sum + day.inProgressCount);
    int returnCount = monthlyData.fold(0, (sum, day) => sum + day.returnCount);
    int freeCount = monthlyData.fold(0, (sum, day) => sum + day.freeCount);
    int inStoreCount =
        monthlyData.fold(0, (sum, day) => sum + day.inStoreCount);
    int deliveredCount =
        monthlyData.fold(0, (sum, day) => sum + day.deliveredCount);
    int priceTotal = monthlyData.fold(0, (sum, day) => sum + day.priceTotal);
    int expenseTotal =
        monthlyData.fold(0, (sum, day) => sum + day.expenseTotal);
    int profit = priceTotal - expenseTotal;

    return DailyRevenue(
      date: firstDay,
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
