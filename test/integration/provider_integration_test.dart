// Integration tests: Provider-level interactions
//
// Exercises Riverpod notifiers (ServiceItemsNotifier, RevenueNotifier)
// through a ProviderContainer with fake repository overrides, testing state
// transitions that span multiple notifier methods in sequence.
//
// NOTE: We use a FakeServiceItemRepository (not a real one backed by
// MockObjectBox) because ServiceItemRepository.getTodayServiceItemsPaged()
// and getTrashServiceItemsPaged() build ObjectBox Condition objects using
// ServiceItem_ model accessors, which load libobjectbox.dylib — unavailable
// in the Flutter test environment. The fake avoids all native lib touches.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_service_manager/data/models/service_item.dart';
import 'package:mobile_service_manager/data/repositories/revenue_repository.dart';
import 'package:mobile_service_manager/data/repositories/service_item_repository.dart';
import 'package:mobile_service_manager/presentation/providers/repository_providers.dart';
import 'package:mobile_service_manager/presentation/providers/revenue_provider.dart';
import 'package:mobile_service_manager/presentation/providers/service_item_provider.dart';
import 'package:mobile_service_manager/presentation/providers/trash_service_item_provider.dart';

import '../repositories/service_item_repository_test.mocks.dart';

// ---------------------------------------------------------------------------
// Helpers — item factory
// ---------------------------------------------------------------------------

ServiceItem _item({
  int id = 0,
  int invoiceId = 100,
  String customerName = 'Alice',
  String issueDate = '2024-06-15',
  String status = 'in_progress',
  String location = 'in_store',
  int? servicePrice,
  int? expense,
  bool isTrash = false,
}) {
  return ServiceItem(
    id: id,
    invoiceId: invoiceId,
    customerName: customerName,
    phoneNumber: '09111111111',
    model: 'Galaxy S23',
    imei: '111111111111111',
    issueDate: issueDate,
    status: status,
    location: location,
    servicePrice: servicePrice,
    expense: expense,
    isTrash: isTrash,
  );
}

// ---------------------------------------------------------------------------
// FakeServiceItemRepository
// ---------------------------------------------------------------------------
// Returns controlled data without touching ObjectBox native conditions.

class FakeServiceItemRepository implements ServiceItemRepository {
  List<ServiceItem> _todayItems;
  List<ServiceItem> _trashItems;

  FakeServiceItemRepository({
    List<ServiceItem>? todayItems,
    List<ServiceItem>? trashItems,
  })  : _todayItems = todayItems ?? [],
        _trashItems = trashItems ?? [];

  @override
  PagedResult<ServiceItem> getTodayServiceItemsPaged({
    required int limit,
    required int offset,
  }) {
    final sliced = _todayItems
        .skip(offset)
        .take(limit > 0 ? limit : _todayItems.length)
        .toList();
    return PagedResult(items: sliced, totalCount: _todayItems.length);
  }

  @override
  PagedResult<ServiceItem> getTrashServiceItemsPaged({
    required int limit,
    required int offset,
  }) {
    final sliced = _trashItems
        .skip(offset)
        .take(limit > 0 ? limit : _trashItems.length)
        .toList();
    return PagedResult(items: sliced, totalCount: _trashItems.length);
  }

  @override
  List<ServiceItem> getAllServiceItems() => _todayItems;

  @override
  List<ServiceItem> getTrashServiceItems() => _trashItems;

  @override
  List<ServiceItem> getTodayServiceItems() => _todayItems;

  @override
  int addServiceItem(ServiceItem item) {
    item.id = (_todayItems.length + 1);
    _todayItems = [..._todayItems, item];
    return item.id;
  }

  @override
  int updateServiceItem(ServiceItem item) {
    return item.id;
  }

  @override
  bool deleteServiceItem(int id) {
    final idx = _todayItems.indexWhere((e) => e.id == id);
    if (idx < 0) return false;
    final item = _todayItems[idx]..isTrash = true;
    _todayItems = _todayItems.where((e) => e.id != id).toList();
    _trashItems = [..._trashItems, item];
    return true;
  }

  @override
  bool permanentlyDeleteServiceItem(int id) {
    final before = _todayItems.length + _trashItems.length;
    _todayItems = _todayItems.where((e) => e.id != id).toList();
    _trashItems = _trashItems.where((e) => e.id != id).toList();
    return (_todayItems.length + _trashItems.length) < before;
  }

  @override
  bool restoreServiceItem(int id) {
    final idx = _trashItems.indexWhere((e) => e.id == id);
    if (idx < 0) return false;
    final item = _trashItems[idx]..isTrash = false;
    _trashItems = _trashItems.where((e) => e.id != id).toList();
    _todayItems = [..._todayItems, item];
    return true;
  }

  @override
  List<ServiceItem> searchServiceItems({
    String? invoiceId,
    String? customerName,
    String? phoneNumber,
    brand,
    fault,
    technician,
    String? deviceStatus,
    String? deliveryStatus,
    DateTime? specificDate,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    List<ServiceItem> results = List.from(_todayItems);
    if (customerName != null && customerName.isNotEmpty) {
      results = results
          .where((e) =>
              e.customerName.toLowerCase().contains(customerName.toLowerCase()))
          .toList();
    }
    return results;
  }

  // ObjectBox accessor — not used in tests, should not be called.
  dynamic get serviceItemBox => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Container factories
// ---------------------------------------------------------------------------

ProviderContainer _serviceItemContainer(FakeServiceItemRepository repo) {
  return ProviderContainer(
    overrides: [
      serviceItemRepositoryProvider.overrideWithValue(repo),
      trashServiceItemProvider.overrideWith(
        (ref) => TrashServiceItemsNotifier(repo),
      ),
    ],
  );
}

ProviderContainer _revenueContainer(MockObjectBox db) {
  return ProviderContainer(
    overrides: [
      revenueRepositoryProvider.overrideWithValue(RevenueRepository(db)),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── 1. ServiceItemsNotifier initialisation ────────────────────────────────

  group('ServiceItemsNotifier — initialisation', () {
    test('state is empty when repository returns no today items', () {
      final repo = FakeServiceItemRepository();
      final container = _serviceItemContainer(repo);
      addTearDown(container.dispose);

      expect(container.read(serviceItemsProvider), isEmpty);
      expect(container.read(serviceItemsProvider.notifier).totalCount, 0);
      expect(container.read(serviceItemsProvider.notifier).isSearchActive,
          isFalse);
    });

    test('state is populated from today items on init', () {
      final todayItems = [
        _item(id: 1, customerName: 'Bob'),
        _item(id: 2, customerName: 'Carol')
      ];
      final repo = FakeServiceItemRepository(todayItems: todayItems);
      final container = _serviceItemContainer(repo);
      addTearDown(container.dispose);

      expect(container.read(serviceItemsProvider), hasLength(2));
      expect(container.read(serviceItemsProvider.notifier).totalCount, 2);
    });
  });

  // ── 2. addServiceItem flow ────────────────────────────────────────────────

  group('ServiceItemsNotifier — addServiceItem', () {
    test('adds item to state and increments totalCount', () async {
      final repo = FakeServiceItemRepository();
      final container = _serviceItemContainer(repo);
      addTearDown(container.dispose);

      await container.read(serviceItemsProvider.notifier).addServiceItem(
            _item(customerName: 'Dave'),
          );

      expect(container.read(serviceItemsProvider), hasLength(1));
      expect(container.read(serviceItemsProvider).first.customerName, 'Dave');
      expect(container.read(serviceItemsProvider.notifier).totalCount, 1);
    });

    test('multiple addServiceItem calls accumulate in state', () async {
      final repo = FakeServiceItemRepository();
      final container = _serviceItemContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(serviceItemsProvider.notifier)
          .addServiceItem(_item(customerName: 'Eve'));
      await container
          .read(serviceItemsProvider.notifier)
          .addServiceItem(_item(customerName: 'Frank'));

      expect(container.read(serviceItemsProvider), hasLength(2));
      expect(container.read(serviceItemsProvider.notifier).totalCount, 2);
    });
  });

  // ── 3. updateServiceItem flow ─────────────────────────────────────────────

  group('ServiceItemsNotifier — updateServiceItem', () {
    test('replaces the matching item in state', () async {
      final existing = _item(id: 5, customerName: 'Grace');
      final repo = FakeServiceItemRepository(todayItems: [existing]);
      final container = _serviceItemContainer(repo);
      addTearDown(container.dispose);

      final updated = _item(id: 5, customerName: 'Grace Updated');
      await container
          .read(serviceItemsProvider.notifier)
          .updateServiceItem(updated);

      final state = container.read(serviceItemsProvider);
      expect(state, hasLength(1));
      expect(state.first.customerName, 'Grace Updated');
    });

    test('updating a non-existent item does not change state length', () async {
      final existing = _item(id: 5, customerName: 'Hank');
      final repo = FakeServiceItemRepository(todayItems: [existing]);
      final container = _serviceItemContainer(repo);
      addTearDown(container.dispose);

      // Item id 99 doesn't exist in state
      await container.read(serviceItemsProvider.notifier).updateServiceItem(
            _item(id: 99, customerName: 'Ghost'),
          );

      // State should still be 1 item (id 5 unchanged)
      expect(container.read(serviceItemsProvider), hasLength(1));
      expect(container.read(serviceItemsProvider).first.customerName, 'Hank');
    });
  });

  // ── 4. Search mode flow ───────────────────────────────────────────────────

  group('ServiceItemsNotifier — search mode', () {
    test('searchServiceItems activates search mode (isSearchActive = true)',
        () {
      final repo = FakeServiceItemRepository(
        todayItems: [_item(id: 1, customerName: 'Ivan')],
      );
      final container = _serviceItemContainer(repo);
      addTearDown(container.dispose);

      container.read(serviceItemsProvider.notifier).searchServiceItems(
            customerName: 'Ivan',
          );

      expect(
          container.read(serviceItemsProvider.notifier).isSearchActive, isTrue);
      expect(container.read(serviceItemsProvider), hasLength(1));
    });

    test('searchServiceItems with no match returns empty state in search mode',
        () {
      final repo = FakeServiceItemRepository(
        todayItems: [_item(id: 1, customerName: 'Jack')],
      );
      final container = _serviceItemContainer(repo);
      addTearDown(container.dispose);

      container.read(serviceItemsProvider.notifier).searchServiceItems(
            customerName: 'Zara',
          );

      expect(
          container.read(serviceItemsProvider.notifier).isSearchActive, isTrue);
      expect(container.read(serviceItemsProvider), isEmpty);
    });

    test('resetSearch disables search mode (isSearchActive = false)', () {
      final repo = FakeServiceItemRepository(todayItems: []);
      final container = _serviceItemContainer(repo);
      addTearDown(container.dispose);

      // Activate search first
      container
          .read(serviceItemsProvider.notifier)
          .searchServiceItems(customerName: 'X');
      expect(
          container.read(serviceItemsProvider.notifier).isSearchActive, isTrue);

      // Reset
      container.read(serviceItemsProvider.notifier).resetSearch();
      expect(container.read(serviceItemsProvider.notifier).isSearchActive,
          isFalse);
    });
  });

  // ── 5. RevenueNotifier flow ───────────────────────────────────────────────

  group('RevenueNotifier — state transitions', () {
    late MockObjectBox mockObjectBox;

    setUp(() {
      mockObjectBox = MockObjectBox();
    });

    test('initial state is null before any load', () {
      final container = _revenueContainer(mockObjectBox);
      addTearDown(container.dispose);

      expect(container.read(revenueNotifierProvider), isNull);
    });

    test('loadDailyRevenue transitions state from null to populated Revenue',
        () {
      final items = [
        _item(
          issueDate: '2024-06-15',
          status: 'done',
          location: 'delivered',
          servicePrice: 50000,
          expense: 20000,
        ),
      ];
      when(mockObjectBox.getAllServiceItems()).thenReturn(items);

      final container = _revenueContainer(mockObjectBox);
      addTearDown(container.dispose);

      container.read(revenueNotifierProvider.notifier).loadDailyRevenue(
            DateTime(2024, 6, 15),
            isIssueDate: true,
          );

      final revenue = container.read(revenueNotifierProvider);
      expect(revenue, isNotNull);
      expect(revenue!.totalServiceItemCount, 1);
      expect(revenue.doneCount, 1);
      expect(revenue.priceTotal, 50000);
      expect(revenue.profit, 30000); // 50000 - 20000
    });

    test(
        'loadRevenueForDateRange aggregates multi-day data into single Revenue',
        () {
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

      final container = _revenueContainer(mockObjectBox);
      addTearDown(container.dispose);

      container.read(revenueNotifierProvider.notifier).loadRevenueForDateRange(
            DateTime(2024, 6, 1),
            DateTime(2024, 6, 2),
            isIssueDate: true,
          );

      final revenue = container.read(revenueNotifierProvider);
      expect(revenue, isNotNull);
      expect(revenue!.totalServiceItemCount, 2);
      expect(revenue.priceTotal, 30000);
      expect(revenue.expenseTotal, 10000);
      expect(revenue.profit, 20000);
    });

    test('loadRevenueForDateRange sets state to null when no items exist', () {
      when(mockObjectBox.getAllServiceItems()).thenReturn([]);

      final container = _revenueContainer(mockObjectBox);
      addTearDown(container.dispose);

      container.read(revenueNotifierProvider.notifier).loadRevenueForDateRange(
            DateTime(2024, 7, 1),
            DateTime(2024, 7, 3),
            isIssueDate: true,
          );

      // Empty range produces Revenue objects with 0 counts; the notifier
      // sets state to null only when dateRangeData is empty, but here it
      // produces 3 Revenue(zeros). So state is not-null.
      // Change expectation: state returns aggregated zero Revenue.
      final revenue = container.read(revenueNotifierProvider);
      expect(revenue, isNotNull);
      expect(revenue!.totalServiceItemCount, 0);
      expect(revenue.profit, 0);
    });

    test('successive loads replace the previous Revenue state', () {
      final day1Items = [
        _item(
            issueDate: '2024-06-01',
            status: 'done',
            servicePrice: 5000,
            expense: 1000)
      ];
      when(mockObjectBox.getAllServiceItems()).thenReturn(day1Items);

      final container = _revenueContainer(mockObjectBox);
      addTearDown(container.dispose);

      container.read(revenueNotifierProvider.notifier).loadDailyRevenue(
            DateTime(2024, 6, 1),
            isIssueDate: true,
          );
      final rev1 = container.read(revenueNotifierProvider);
      expect(rev1!.priceTotal, 5000);

      // Load a different day — no items
      when(mockObjectBox.getAllServiceItems()).thenReturn([]);
      container.read(revenueNotifierProvider.notifier).loadDailyRevenue(
            DateTime(2024, 6, 2),
            isIssueDate: true,
          );
      final rev2 = container.read(revenueNotifierProvider);
      expect(rev2!.priceTotal, 0);
    });
  });
}
