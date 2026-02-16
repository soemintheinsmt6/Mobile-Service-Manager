import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/data/models/service_item.dart';
import 'package:mobile_service_manager/presentation/providers/trash_service_item_provider.dart';
import 'package:mobile_service_manager/data/repositories/service_item_repository.dart';
import '../test_config.mocks.dart';

class _FakeRepository extends ServiceItemRepository {
  _FakeRepository() : super(MockObjectBox());

  final Map<int, PagedResult<ServiceItem>> trashPages = {};
  bool restoreShouldSucceed = true;
  bool deleteShouldSucceed = true;

  @override
  PagedResult<ServiceItem> getTrashServiceItemsPaged({
    required int limit,
    required int offset,
  }) {
    return trashPages[offset] ??
        PagedResult<ServiceItem>(items: const [], totalCount: 0);
  }

  @override
  bool restoreServiceItem(int id) {
    return restoreShouldSucceed;
  }

  @override
  bool permanentlyDeleteServiceItem(int id) {
    return deleteShouldSucceed;
  }
}

ServiceItem _createTrashItem(int id) {
  return ServiceItem(
    id: id,
    invoiceId: id,
    customerName: 'Customer $id',
    phoneNumber: '09$id',
    model: 'Model $id',
    imei: 'IMEI$id',
    issueDate: DateTime(2024, 1, 1).toString(),
    isTrash: true,
  );
}

void main() {
  group('TrashServiceItemsNotifier pagination', () {
    late _FakeRepository repository;
    late TrashServiceItemsNotifier notifier;

    setUp(() {
      repository = _FakeRepository();

      repository.trashPages[0] = PagedResult<ServiceItem>(
        items: List.generate(50, (index) => _createTrashItem(index + 1)),
        totalCount: 80,
      );

      repository.trashPages[25] = PagedResult<ServiceItem>(
        items: List.generate(25, (index) => _createTrashItem(index + 26)),
        totalCount: 80,
      );

      notifier = TrashServiceItemsNotifier(repository);
    });

    test('initial load uses page 0 and default page size', () {
      notifier.loadTrashItems();

      expect(notifier.currentPage, 0);
      expect(notifier.pageSize, 50);
      expect(notifier.totalCount, 80);
      expect(notifier.state.length, 50);
    });

    test('loadTrashItems loads correct page from repository', () {
      notifier.loadTrashItems(page: 1, pageSize: 25);

      expect(notifier.currentPage, 1);
      expect(notifier.pageSize, 25);
      expect(notifier.state.first.invoiceId, 26);
      expect(notifier.state.last.invoiceId, 50);
    });

    test('restoreServiceItem decrements totalCount and removes from state', () async {
      notifier.loadTrashItems();

      final firstId = notifier.state.first.id;
      final initialTotal = notifier.totalCount;

      repository.restoreShouldSucceed = true;

      await notifier.restoreServiceItem(firstId, _FakeWidgetRef());

      expect(notifier.totalCount, initialTotal - 1);
      expect(notifier.state.any((item) => item.id == firstId), false);
    });

    test('permanentlyDelete decrements totalCount and removes from state', () async {
      notifier.loadTrashItems();

      final firstId = notifier.state.first.id;
      final initialTotal = notifier.totalCount;

      repository.deleteShouldSucceed = true;

      await notifier.permanentlyDelete(firstId);

      expect(notifier.totalCount, initialTotal - 1);
      expect(notifier.state.any((item) => item.id == firstId), false);
    });
  });
}

class _FakeWidgetRef extends Fake implements WidgetRef {
  @override
  T read<T>(ProviderListenable<T> provider) {
    return StateController<int>(0) as T;
  }
}
