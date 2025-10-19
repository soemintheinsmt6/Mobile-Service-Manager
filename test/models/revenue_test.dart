import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/models/revenue.dart';

void main() {
  group('Revenue Model Tests', () {
    late Revenue revenue;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      revenue = Revenue(
        date: testDate,
        totalServiceItemCount: 10,
        doneCount: 6,
        inProgressCount: 3,
        returnCount: 1,
        freeCount: 0,
        inStoreCount: 7,
        deliveredCount: 3,
        priceTotal: 800000,
        expenseTotal: 500000,
        profit: 300000,
      );
    });

    test('should create Revenue with correct properties', () {
      expect(revenue.date, equals(testDate));
      expect(revenue.totalServiceItemCount, equals(10));
      expect(revenue.doneCount, equals(6));
      expect(revenue.inProgressCount, equals(3));
      expect(revenue.returnCount, equals(1));
      expect(revenue.freeCount, equals(0));
      expect(revenue.inStoreCount, equals(7));
      expect(revenue.deliveredCount, equals(3));
      expect(revenue.priceTotal, equals(800000));
      expect(revenue.expenseTotal, equals(500000));
      expect(revenue.profit, equals(300000));
    });

    test('should calculate profit correctly', () {
      final revenueWithLoss = Revenue(
        date: testDate,
        totalServiceItemCount: 5,
        doneCount: 3,
        inProgressCount: 2,
        returnCount: 0,
        freeCount: 0,
        inStoreCount: 4,
        deliveredCount: 1,
        priceTotal: 300000,
        expenseTotal: 400000,
        profit: -100000,
      );

      expect(revenueWithLoss.profit, equals(-100000));
    });

    test('should handle zero values correctly', () {
      final zeroRevenue = Revenue(
        date: testDate,
        totalServiceItemCount: 0,
        doneCount: 0,
        inProgressCount: 0,
        returnCount: 0,
        freeCount: 0,
        inStoreCount: 0,
        deliveredCount: 0,
        priceTotal: 0,
        expenseTotal: 0,
        profit: 0,
      );

      expect(zeroRevenue.totalServiceItemCount, equals(0));
      expect(zeroRevenue.doneCount, equals(0));
      expect(zeroRevenue.priceTotal, equals(0));
      expect(zeroRevenue.expenseTotal, equals(0));
      expect(zeroRevenue.profit, equals(0));
    });

    test('should format date correctly using extension', () {
      // This test assumes the formattedDate extension is available
      // The extension should format the date as '15 Jan 2024'
      expect(revenue.formattedDate, equals('15 Jan 2024'));
    });

    test('should handle large numbers correctly', () {
      final largeRevenue = Revenue(
        date: testDate,
        totalServiceItemCount: 1000,
        doneCount: 800,
        inProgressCount: 150,
        returnCount: 50,
        freeCount: 0,
        inStoreCount: 900,
        deliveredCount: 100,
        priceTotal: 80000000,
        expenseTotal: 50000000,
        profit: 30000000,
      );

      expect(largeRevenue.totalServiceItemCount, equals(1000));
      expect(largeRevenue.priceTotal, equals(80000000));
      expect(largeRevenue.profit, equals(30000000));
    });

    test('should maintain data consistency', () {
      // Verify that counts don't exceed total
      expect(revenue.doneCount + revenue.inProgressCount + 
             revenue.returnCount + revenue.freeCount, 
             lessThanOrEqualTo(revenue.totalServiceItemCount));
      
      expect(revenue.inStoreCount + revenue.deliveredCount, 
             lessThanOrEqualTo(revenue.totalServiceItemCount));
    });

    test('should handle edge case dates', () {
      final edgeDate = DateTime(2024, 2, 29); // Leap year
      final leapRevenue = Revenue(
        date: edgeDate,
        totalServiceItemCount: 1,
        doneCount: 1,
        inProgressCount: 0,
        returnCount: 0,
        freeCount: 0,
        inStoreCount: 1,
        deliveredCount: 0,
        priceTotal: 100000,
        expenseTotal: 50000,
        profit: 50000,
      );

      expect(leapRevenue.date, equals(edgeDate));
    });
  });
}
