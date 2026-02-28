// Integration tests: ServiceItem full lifecycle
//
// These tests verify cross-layer behaviour between ServiceItemRepository and
// ServiceItem domain logic, using a MockObjectBox instead of a real database.
// Unlike the isolated unit tests in test/repositories/, the scenarios here
// exercise multi-step flows (add → update → trash → restore → delete) and the
// searchServiceItems filtering logic end-to-end.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_service_manager/data/models/service_item.dart';
import 'package:mobile_service_manager/data/repositories/service_item_repository.dart';
import 'package:objectbox/objectbox.dart';

// Reuse the mock already generated for the repository unit tests.
import '../repositories/service_item_repository_test.mocks.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ServiceItem _makeItem({
  int id = 0,
  int invoiceId = 100,
  String customerName = 'Alice',
  String phoneNumber = '09111111111',
  String model = 'Galaxy S23',
  String imei = '111111111111111',
  String issueDate = '2024-06-15',
  String? deliveryDate,
  int? expense,
  int? servicePrice,
  String status = 'in_progress',
  String location = 'in_store',
  bool isTrash = false,
}) {
  return ServiceItem(
    id: id,
    invoiceId: invoiceId,
    customerName: customerName,
    phoneNumber: phoneNumber,
    model: model,
    imei: imei,
    issueDate: issueDate,
    deliveryDate: deliveryDate,
    expense: expense,
    servicePrice: servicePrice,
    status: status,
    location: location,
    isTrash: isTrash,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockObjectBox mockObjectBox;
  late ServiceItemRepository repository;

  setUp(() {
    mockObjectBox = MockObjectBox();
    repository = ServiceItemRepository(mockObjectBox);
  });

  // ── 1. CRUD lifecycle ─────────────────────────────────────────────────────

  group('CRUD lifecycle', () {
    test('add → update → permanently delete completes without error', () {
      final item = _makeItem(invoiceId: 201, customerName: 'Bob');

      // Insert returns a new ID
      when(mockObjectBox.insertServiceItem(item)).thenReturn(1);

      final newId = repository.addServiceItem(item);
      expect(newId, equals(1));
      verify(mockObjectBox.insertServiceItem(item)).called(1);

      // Update (uses same insert/put path)
      item.id = newId;
      final updatedItem =
          _makeItem(id: newId, invoiceId: 201, customerName: 'Bob Updated');
      when(mockObjectBox.insertServiceItem(updatedItem)).thenReturn(newId);

      final updatedId = repository.updateServiceItem(updatedItem);
      expect(updatedId, equals(newId));
      verify(mockObjectBox.insertServiceItem(updatedItem)).called(1);

      // Permanently delete
      when(mockObjectBox.deleteServiceItem(newId)).thenReturn(true);
      final deleted = repository.permanentlyDeleteServiceItem(newId);
      expect(deleted, isTrue);
      verify(mockObjectBox.deleteServiceItem(newId)).called(1);
    });

    test('getAllServiceItems returns items from ObjectBox', () {
      final items = [
        _makeItem(id: 1, customerName: 'Carol'),
        _makeItem(id: 2, customerName: 'Dave'),
      ];
      when(mockObjectBox.getAllServiceItems()).thenReturn(items);

      final result = repository.getAllServiceItems();

      expect(result, hasLength(2));
      expect(result.first.customerName, 'Carol');
      verify(mockObjectBox.getAllServiceItems()).called(1);
    });

    test('getAllServiceItems returns empty list when database is empty', () {
      when(mockObjectBox.getAllServiceItems()).thenReturn([]);

      expect(repository.getAllServiceItems(), isEmpty);
    });
  });

  // ── 2. Soft-delete (trash) flow ───────────────────────────────────────────

  group('Soft-delete (trash) flow', () {
    test('deleteServiceItem marks item as trash and returns true', () {
      final item = _makeItem(id: 5, customerName: 'Eve', isTrash: false);
      when(mockObjectBox.serviceItemBox).thenReturn(_FakeBox(item: item)._box);

      // The repository fetches by ID, sets isTrash=true, then re-inserts.
      // We set up the fake box to return the item and capture the put.
      final fakeBox = _FakeBox(item: item);
      when(mockObjectBox.serviceItemBox).thenReturn(fakeBox._box);
      when(mockObjectBox.insertServiceItem(any)).thenReturn(5);

      final result = repository.deleteServiceItem(5);

      // The item should now be flagged
      expect(result, isTrue);
      expect(item.isTrash, isTrue);
    });

    test('deleteServiceItem returns false when item does not exist', () {
      // Box returns null for unknown IDs
      final fakeBox = _FakeBox(item: null);
      when(mockObjectBox.serviceItemBox).thenReturn(fakeBox._box);

      final result = repository.deleteServiceItem(999);
      expect(result, isFalse);
    });

    test('restoreServiceItem clears isTrash flag and returns true', () {
      final item = _makeItem(id: 7, customerName: 'Frank', isTrash: true);
      final fakeBox = _FakeBox(item: item);
      when(mockObjectBox.serviceItemBox).thenReturn(fakeBox._box);
      when(mockObjectBox.insertServiceItem(any)).thenReturn(7);

      final result = repository.restoreServiceItem(7);

      expect(result, isTrue);
      expect(item.isTrash, isFalse);
    });

    test('restoreServiceItem returns false when item is not in trash', () {
      // item.isTrash == false means it is not in the trash
      final item = _makeItem(id: 8, customerName: 'Grace', isTrash: false);
      final fakeBox = _FakeBox(item: item);
      when(mockObjectBox.serviceItemBox).thenReturn(fakeBox._box);

      final result = repository.restoreServiceItem(8);
      expect(result, isFalse);
    });

    test('restoreServiceItem returns false for non-existent item', () {
      final fakeBox = _FakeBox(item: null);
      when(mockObjectBox.serviceItemBox).thenReturn(fakeBox._box);

      final result = repository.restoreServiceItem(404);
      expect(result, isFalse);
    });
  });

  // ── 3. Search flow ────────────────────────────────────────────────────────

  group('searchServiceItems', () {
    // The repository builds an ObjectBox query for brand/technician relations
    // (which we cannot easily mock) but falls back to in-memory filtering for
    // all other criteria. For integration purposes we supply a mock Box that
    // provides a faked QueryBuilder so the in-memory filters are exercised.

    final itemAlice = _makeItem(
      id: 1,
      invoiceId: 100,
      customerName: 'Alice Wong',
      phoneNumber: '09111111111',
      issueDate: '2024-06-10',
      status: 'done',
      location: 'delivered',
      servicePrice: 50000,
      expense: 20000,
    );
    final itemBob = _makeItem(
      id: 2,
      invoiceId: 200,
      customerName: 'Bob Tan',
      phoneNumber: '09222222222',
      issueDate: '2024-06-15',
      status: 'in_progress',
      location: 'in_store',
      servicePrice: 80000,
      expense: 30000,
    );
    final itemCharlie = _makeItem(
      id: 3,
      invoiceId: 300,
      customerName: 'Charlie Lwin',
      phoneNumber: '09333333333',
      issueDate: '2024-06-20',
      status: 'return',
      location: 'in_store',
      servicePrice: 0,
      expense: 10000,
    );

    setUp(() {
      // The internal query in searchServiceItems hits serviceItemBox;
      // provide a fake that returns our three items.
      final fakeBox = _FakeQueryBox(items: [itemAlice, itemBob, itemCharlie]);
      when(mockObjectBox.serviceItemBox).thenReturn(fakeBox._box);
    });

    test('filter by customerName (case-insensitive, partial match)', () {
      final results = repository.searchServiceItems(customerName: 'alice');
      expect(results, hasLength(1));
      expect(results.first.customerName, 'Alice Wong');
    });

    test('filter by exact invoiceId', () {
      final results = repository.searchServiceItems(invoiceId: '200');
      expect(results, hasLength(1));
      expect(results.first.invoiceId, 200);
    });

    test('filter by invoiceId — exact numeric match', () {
      // int.parse('100') = 100 → matches only invoiceId 100
      final results = repository.searchServiceItems(invoiceId: '100');
      expect(results, hasLength(1));
      expect(results.first.invoiceId, 100);
    });

    test(
        'filter by invoiceId — no match when integer parse succeeds but value absent',
        () {
      // int.parse('999') = 999 → no invoice with id 999
      final results = repository.searchServiceItems(invoiceId: '999');
      expect(results, isEmpty);
    });

    test('filter by invoiceId — string-contains fallback for non-numeric input',
        () {
      // int.parse('abc') throws → falls back to string-contains on invoiceId.toString()
      // '100'.contains('1') → true, '200'.contains('1') → false, '300'.contains('1') → false
      final results = repository.searchServiceItems(invoiceId: 'abc');
      expect(results, isEmpty); // none of '100','200','300' contain 'abc'
    });

    test('filter by phoneNumber', () {
      final results = repository.searchServiceItems(phoneNumber: '09333');
      expect(results, hasLength(1));
      expect(results.first.customerName, 'Charlie Lwin');
    });

    test('filter by deviceStatus (done)', () {
      final results = repository.searchServiceItems(deviceStatus: 'done');
      expect(results, hasLength(1));
      expect(results.first.customerName, 'Alice Wong');
    });

    test('filter by deliveryStatus (in_store)', () {
      final results = repository.searchServiceItems(deliveryStatus: 'in_store');
      expect(results, hasLength(2));
    });

    test('filter by specificDate', () {
      final results = repository.searchServiceItems(
        specificDate: DateTime(2024, 6, 15),
      );
      expect(results, hasLength(1));
      expect(results.first.customerName, 'Bob Tan');
    });

    test('filter by date range (fromDate → toDate)', () {
      final results = repository.searchServiceItems(
        fromDate: DateTime(2024, 6, 14),
        toDate: DateTime(2024, 6, 21),
      );
      // Bob (15th) and Charlie (20th) fall within range
      expect(results, hasLength(2));
      final names = results.map((e) => e.customerName).toList();
      expect(names, containsAll(['Bob Tan', 'Charlie Lwin']));
    });

    test('returns empty list when no items match filter', () {
      final results = repository.searchServiceItems(customerName: 'Zara');
      expect(results, isEmpty);
    });

    test('results are sorted by issueDate ascending', () {
      final results = repository.searchServiceItems();
      expect(results.map((e) => e.issueDate).toList(), [
        '2024-06-10',
        '2024-06-15',
        '2024-06-20',
      ]);
    });
  });
}

// ---------------------------------------------------------------------------
// Fake Box helpers
// ---------------------------------------------------------------------------
// These thin wrappers let us supply controlled return values for
// serviceItemBox.get(id) and serviceItemBox.query(...) without needing to pull
// in the actual ObjectBox store.

/// Wraps a real Box<ServiceItem> and stubs get() to return a fixed item.
/// Used for delete/restore tests.
class _FakeBox {
  final ServiceItem? _item;
  late final Box<ServiceItem> _box;

  _FakeBox({required ServiceItem? item}) : _item = item {
    _box = _MockServiceItemBox(_item);
  }
}

class _MockServiceItemBox extends Mock implements Box<ServiceItem> {
  final ServiceItem? _storedItem;

  _MockServiceItemBox(this._storedItem);

  @override
  ServiceItem? get(int id, {bool checkEntityType = true}) => _storedItem;
}

/// Wraps a Box<ServiceItem> whose query().build().find() returns a fixed list.
/// Used for search tests.
class _FakeQueryBox {
  final List<ServiceItem> _items;
  late final Box<ServiceItem> _box;

  _FakeQueryBox({required List<ServiceItem> items}) : _items = items {
    _box = _MockQueryServiceItemBox(_items);
  }
}

class _MockQueryServiceItemBox extends Mock implements Box<ServiceItem> {
  final List<ServiceItem> _items;

  _MockQueryServiceItemBox(this._items);

  @override
  QueryBuilder<ServiceItem> query([Condition<ServiceItem>? qc]) {
    return _FakeQueryBuilder<ServiceItem>(_items);
  }
}

class _FakeQueryBuilder<T> extends Mock implements QueryBuilder<T> {
  final List<T> _returnItems;

  _FakeQueryBuilder(this._returnItems);

  @override
  Query<T> build() => _FakeQuery<T>(_returnItems);
}

class _FakeQuery<T> extends Mock implements Query<T> {
  final List<T> _items;
  int? limit;
  int? offset;

  _FakeQuery(this._items);

  @override
  List<T> find() => _items;

  @override
  int count() => _items.length;

  @override
  void close() {}
}
