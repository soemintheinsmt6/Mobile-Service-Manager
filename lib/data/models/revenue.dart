import 'package:mobile_service_manager/core/utils/extension.dart';

class Revenue {
  final DateTime date;
  final int totalServiceItemCount;
  final int doneCount;
  final int inProgressCount;
  final int returnCount;
  final int freeCount;
  final int inStoreCount;
  final int deliveredCount;
  final int priceTotal;
  final int expenseTotal;
  final int profit;

  Revenue({
    required this.date,
    required this.totalServiceItemCount,
    required this.doneCount,
    required this.inProgressCount,
    required this.returnCount,
    required this.freeCount,
    required this.inStoreCount,
    required this.deliveredCount,
    required this.priceTotal,
    required this.expenseTotal,
    required this.profit,
  });

  String get formattedDate => date.toString().formattedDate;
}
