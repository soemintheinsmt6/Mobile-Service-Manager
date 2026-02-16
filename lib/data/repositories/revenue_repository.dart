import '../database/object_box.dart';
import '../models/revenue.dart';
import '../models/service_item.dart';

class RevenueRepository {
  final ObjectBox _objectBox;

  RevenueRepository(this._objectBox);

  Revenue getDailyRevenue(DateTime selectedDate,
      {int? brandId,
      int? faultId,
      int? technicianId,
      required bool isIssueDate}) {
    // Get all service items for the selected date
    List<ServiceItem> dayItems = _getServiceItemsForDate(selectedDate,
        brandId: brandId,
        faultId: faultId,
        technicianId: technicianId,
        isIssueDate: isIssueDate);

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

    return Revenue(
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

  List<ServiceItem> _getServiceItemsForDate(DateTime date,
      {int? brandId,
      int? faultId,
      int? technicianId,
      required bool isIssueDate}) {
    final dateString =
        date.toString().split(' ')[0]; // Get only the date part (YYYY-MM-DD)

    // Get all non-trash service items
    List<ServiceItem> allItems = _objectBox.getAllServiceItems();

    // Filter by date
    List<ServiceItem> filtered = allItems.where((item) {
      if (isIssueDate) {
        final itemDateString =
            item.issueDate.split(' ')[0]; // Extract date part from stored item
        return itemDateString == dateString;
      } else {
        if (item.deliveryDate == null) return false;

        final deliveryDateString = item.deliveryDate!.split(' ')[0];
        return deliveryDateString == dateString;
      }
    }).toList();

    if (brandId != null) {
      filtered =
          filtered.where((item) => item.brand.target?.id == brandId).toList();
    }

    if (faultId != null) {
      filtered = filtered
          .where((item) => item.faults.any((fault) => fault.id == faultId))
          .toList();
    }

    if (technicianId != null) {
      filtered = filtered
          .where((item) => item.technician.target?.id == technicianId)
          .toList();
    }

    return filtered;
  }

  // Get revenue data for a date range with optional technician filter
  List<Revenue> getRevenueForDateRange(DateTime fromDate, DateTime toDate,
      {int? brandId,
      int? faultId,
      int? technicianId,
      required bool isIssueDate}) {
    List<Revenue> revenueList = [];
    DateTime currentDate = fromDate;

    while (currentDate.isBefore(toDate.add(const Duration(days: 1)))) {
      revenueList.add(getDailyRevenue(currentDate,
          brandId: brandId,
          faultId: faultId,
          technicianId: technicianId,
          isIssueDate: isIssueDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return revenueList;
  }
}
