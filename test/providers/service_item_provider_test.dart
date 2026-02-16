import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/data/models/brand.dart';
import 'package:mobile_service_manager/data/models/fault.dart';
import 'package:mobile_service_manager/data/models/service_item.dart';
import 'package:mobile_service_manager/data/models/technician.dart';
import 'package:mobile_service_manager/presentation/providers/service_item_provider.dart';
import 'package:mobile_service_manager/data/repositories/service_item_repository.dart';
import '../test_config.mocks.dart';

class _FakeRepository extends ServiceItemRepository {
  _FakeRepository() : super(MockObjectBox());

  final Map<int, PagedResult<ServiceItem>> todayPages = {};
  List<ServiceItem> searchResults = [];
  int addServiceItemReturnId = 1;

  @override
  PagedResult<ServiceItem> getTodayServiceItemsPaged({
    required int limit,
    required int offset,
  }) {
    return todayPages[offset] ??
        PagedResult<ServiceItem>(items: const [], totalCount: 0);
  }

  @override
  List<ServiceItem> searchServiceItems({
    String? invoiceId,
    String? customerName,
    String? phoneNumber,
    Brand? brand,
    Fault? fault,
    Technician? technician,
    String? deviceStatus,
    String? deliveryStatus,
    DateTime? specificDate,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return searchResults;
  }

  @override
  int addServiceItem(ServiceItem item) {
    return addServiceItemReturnId;
  }
}

ServiceItem _createItem(int id) {
  return ServiceItem(
    id: id,
    invoiceId: id,
    customerName: 'Customer $id',
    phoneNumber: '09$id',
    model: 'Model $id',
    imei: 'IMEI$id',
    issueDate: DateTime(2024, 1, 1).toString(),
  );
}

void main() {
  group('ServiceItemsNotifier pagination', () {
    late _FakeRepository repository;
    late ServiceItemsNotifier notifier;

    setUp(() {
      repository = _FakeRepository();
      repository.todayPages[0] = PagedResult<ServiceItem>(
        items: List.generate(50, (index) => _createItem(index + 1)),
        totalCount: 120,
      );
      repository.todayPages[50] = PagedResult<ServiceItem>(
        items: List.generate(50, (index) => _createItem(index + 51)),
        totalCount: 120,
      );

      notifier = ServiceItemsNotifier(repository);
    });

    test('initial load uses page 0 and default page size', () {
      notifier.loadServiceItems();

      expect(notifier.isSearchActive, false);
      expect(notifier.currentPage, 0);
      expect(notifier.pageSize, 50);
      expect(notifier.totalCount, 120);
      expect(notifier.state.length, 50);
    });

    test('loadServiceItems loads correct page from repository', () {
      notifier.loadServiceItems(page: 1, pageSize: 50);

      expect(notifier.currentPage, 1);
      expect(notifier.pageSize, 50);
      expect(notifier.state.first.invoiceId, 51);
      expect(notifier.state.last.invoiceId, 100);
    });

    test('addServiceItem increments totalCount when not searching', () async {
      notifier.loadServiceItems();
      final initialTotal = notifier.totalCount;

      final newItem = _createItem(999);
      repository.addServiceItemReturnId = 999;

      await notifier.addServiceItem(newItem);

      expect(notifier.totalCount, initialTotal + 1);
      expect(notifier.state.any((item) => item.invoiceId == 999), true);
    });
  });

  group('ServiceItemsNotifier search', () {
    late _FakeRepository repository;
    late ServiceItemsNotifier notifier;

    setUp(() {
      repository = _FakeRepository();
      repository.todayPages[0] = PagedResult<ServiceItem>(
        items: const [],
        totalCount: 0,
      );
      notifier = ServiceItemsNotifier(repository);
    });

    test('searchServiceItems sets isSearchActive and resets pagination', () {
      final results = List.generate(30, (index) => _createItem(index + 1));
      repository.searchResults = results;

      notifier.searchServiceItems(
        invoiceId: '1',
        customerName: 'Customer',
        phoneNumber: '09',
        brand: Brand(id: 1, name: 'Brand'),
        fault: Fault(id: 1, name: 'Fault'),
        technician: Technician(id: 1, name: 'Tech'),
        deviceStatus: 'in_progress',
        deliveryStatus: 'in_store',
      );

      expect(notifier.isSearchActive, true);
      expect(notifier.currentPage, 0);
      expect(notifier.totalCount, 30);
      expect(notifier.state.length, 30);
    });

    test('resetSearch clears search state and reloads first page', () {
      repository.todayPages[0] = PagedResult<ServiceItem>(
        items: List.generate(10, (index) => _createItem(index + 1)),
        totalCount: 10,
      );

      notifier.searchServiceItems();
      notifier.resetSearch();

      expect(notifier.isSearchActive, false);
      expect(notifier.currentPage, 0);
      expect(notifier.totalCount, 10);
      expect(notifier.state.length, 10);
    });
  });
}
