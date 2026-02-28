// Integration tests: Revenue calculation
//
// These tests exercise RevenueRepository end-to-end: injecting a controlled
// set of ServiceItems via MockObjectBox and verifying the Revenue object
// returned by getDailyRevenue / getRevenueForDateRange contains correct
// counts and financial totals.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_service_manager/data/models/service_item.dart';
import 'package:mobile_service_manager/data/repositories/revenue_repository.dart';

import '../repositories/service_item_repository_test.mocks.dart';

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

ServiceItem _item({
  required String issueDate,
  String? deliveryDate,
  String status = 'done',
  String location = 'delivered',
  int? servicePrice,
  int? expense,
  bool isTrash = false,
}) {
  return ServiceItem(
    invoiceId: 1,
    customerName: 'Test',
    phoneNumber: '09000000000',
    model: 'Model X',
    imei: '123456789012345',
    issueDate: issueDate,
    deliveryDate: deliveryDate,
    status: status,
    location: location,
    servicePrice: servicePrice,
    expense: expense,
    isTrash: isTrash,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockObjectBox mockObjectBox;
  late RevenueRepository repository;

  setUp(() {
    mockObjectBox = MockObjectBox();
    repository = RevenueRepository(mockObjectBox);
  });

  // ── 1. getDailyRevenue ────────────────────────────────────────────────────

  group('getDailyRevenue — by issueDate', () {
    test('returns zeroed Revenue when no items exist', () {
      when(mockObjectBox.getAllServiceItems()).thenReturn([]);

      final revenue = repository.getDailyRevenue(
        DateTime(2024, 6, 15),
        isIssueDate: true,
      );

      expect(revenue.totalServiceItemCount, 0);
      expect(revenue.doneCount, 0);
      expect(revenue.priceTotal, 0);
      expect(revenue.profit, 0);
    });

    test('counts items correctly for a specific date', () {
      // 3 items on 2024-06-15, 1 on a different date
      final items = [
        _item(
            issueDate: '2024-06-15',
            status: 'done',
            location: 'delivered',
            servicePrice: 50000,
            expense: 20000),
        _item(
            issueDate: '2024-06-15',
            status: 'in_progress',
            location: 'in_store',
            servicePrice: 30000,
            expense: 10000),
        _item(
            issueDate: '2024-06-15',
            status: 'return',
            location: 'in_store',
            servicePrice: 0,
            expense: 5000),
        _item(
            issueDate: '2024-06-16',
            status: 'done',
            location: 'delivered',
            servicePrice: 99000,
            expense: 1000),
      ];
      when(mockObjectBox.getAllServiceItems()).thenReturn(items);

      final revenue = repository.getDailyRevenue(
        DateTime(2024, 6, 15),
        isIssueDate: true,
      );

      expect(revenue.totalServiceItemCount, 3);
      expect(revenue.doneCount, 1);
      expect(revenue.inProgressCount, 1);
      expect(revenue.returnCount, 1);
      expect(revenue.freeCount, 0);
      expect(revenue.deliveredCount, 1);
      expect(revenue.inStoreCount, 2);
      expect(revenue.priceTotal, 80000); // 50000 + 30000 + 0
      expect(revenue.expenseTotal, 35000); // 20000 + 10000 + 5000
      expect(revenue.profit, 45000); // 80000 – 35000
    });

    test('counts all status types: done, in_progress, return, free', () {
      final items = [
        _item(issueDate: '2024-07-01', status: 'done'),
        _item(issueDate: '2024-07-01', status: 'in_progress'),
        _item(issueDate: '2024-07-01', status: 'return'),
        _item(issueDate: '2024-07-01', status: 'free'),
      ];
      when(mockObjectBox.getAllServiceItems()).thenReturn(items);

      final revenue = repository.getDailyRevenue(
        DateTime(2024, 7, 1),
        isIssueDate: true,
      );

      expect(revenue.doneCount, 1);
      expect(revenue.inProgressCount, 1);
      expect(revenue.returnCount, 1);
      expect(revenue.freeCount, 1);
      expect(revenue.totalServiceItemCount, 4);
    });

    test('handles null servicePrice and expense gracefully (treats as 0)', () {
      final items = [
        _item(
            issueDate: '2024-06-20',
            servicePrice: null,
            expense: null,
            status: 'in_progress'),
      ];
      when(mockObjectBox.getAllServiceItems()).thenReturn(items);

      final revenue = repository.getDailyRevenue(
        DateTime(2024, 6, 20),
        isIssueDate: true,
      );

      expect(revenue.priceTotal, 0);
      expect(revenue.expenseTotal, 0);
      expect(revenue.profit, 0);
    });
  });

  // ── 2. getDailyRevenue — by deliveryDate ──────────────────────────────────

  group('getDailyRevenue — by deliveryDate', () {
    test('matches on deliveryDate when isIssueDate is false', () {
      final items = [
        _item(
          issueDate: '2024-06-01',
          deliveryDate: '2024-06-15',
          status: 'done',
          location: 'delivered',
          servicePrice: 40000,
          expense: 15000,
        ),
        _item(
          issueDate: '2024-06-10',
          deliveryDate: null, // not delivered yet
          status: 'in_progress',
          location: 'in_store',
        ),
      ];
      when(mockObjectBox.getAllServiceItems()).thenReturn(items);

      final revenue = repository.getDailyRevenue(
        DateTime(2024, 6, 15),
        isIssueDate: false,
      );

      expect(revenue.totalServiceItemCount, 1);
      expect(revenue.doneCount, 1);
      expect(revenue.priceTotal, 40000);
    });

    test('returns zero counts when no item has a matching deliveryDate', () {
      final items = [
        _item(
            issueDate: '2024-06-01',
            deliveryDate: '2024-06-10',
            status: 'done'),
      ];
      when(mockObjectBox.getAllServiceItems()).thenReturn(items);

      final revenue = repository.getDailyRevenue(
        DateTime(2024, 6, 20),
        isIssueDate: false,
      );

      expect(revenue.totalServiceItemCount, 0);
    });
  });

  // ── 3. getRevenueForDateRange ─────────────────────────────────────────────

  group('getRevenueForDateRange', () {
    test('returns one Revenue per day in the range (inclusive)', () {
      when(mockObjectBox.getAllServiceItems()).thenReturn([]);

      final revenues = repository.getRevenueForDateRange(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 3),
        isIssueDate: true,
      );

      // Days: 1, 2, 3 → 3 Revenue objects
      expect(revenues, hasLength(3));
      expect(revenues[0].date.day, 1);
      expect(revenues[1].date.day, 2);
      expect(revenues[2].date.day, 3);
    });

    test('aggregates totals correctly across a date range', () {
      // One item per day in a 2-day range
      final items = [
        _item(
            issueDate: '2024-06-01',
            status: 'done',
            servicePrice: 10000,
            expense: 4000),
        _item(
            issueDate: '2024-06-02',
            status: 'done',
            servicePrice: 20000,
            expense: 6000),
      ];
      when(mockObjectBox.getAllServiceItems()).thenReturn(items);

      final revenues = repository.getRevenueForDateRange(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 2),
        isIssueDate: true,
      );

      expect(revenues, hasLength(2));
      // Day 1
      expect(revenues[0].priceTotal, 10000);
      expect(revenues[0].expenseTotal, 4000);
      // Day 2
      expect(revenues[1].priceTotal, 20000);
      expect(revenues[1].expenseTotal, 6000);
    });

    test('single-day range returns exactly one Revenue', () {
      when(mockObjectBox.getAllServiceItems()).thenReturn([]);

      final revenues = repository.getRevenueForDateRange(
        DateTime(2024, 6, 15),
        DateTime(2024, 6, 15),
        isIssueDate: true,
      );

      expect(revenues, hasLength(1));
    });
  });
}
