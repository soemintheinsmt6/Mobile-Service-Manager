class DailyRevenue {
  final DateTime date;
  final int totalServiceItemCount;
  final int doneCount;
  final int inProgressCount;
  final int returnCount;
  final int inStoreCount;
  final int deliveredCount;
  final int priceTotal;
  final int expenseTotal;
  final int profit;

  DailyRevenue({
    required this.date,
    required this.totalServiceItemCount,
    required this.doneCount,
    required this.inProgressCount,
    required this.returnCount,
    required this.inStoreCount,
    required this.deliveredCount,
    required this.priceTotal,
    required this.expenseTotal,
    required this.profit,
  });

  // Helper method to format date for display
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}
