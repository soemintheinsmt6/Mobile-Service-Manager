import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/presentation/providers/repository_providers.dart';
import '../../data/models/service_item.dart';
import '../../data/repositories/service_item_repository.dart';

final trashServiceItemProvider =
    StateNotifierProvider<TrashServiceItemsNotifier, List<ServiceItem>>((ref) {
  final repo = ref.watch(serviceItemRepositoryProvider);
  return TrashServiceItemsNotifier(repo);
});

// Dedicated notifier for trash items
class TrashServiceItemsNotifier extends StateNotifier<List<ServiceItem>> {
  final ServiceItemRepository repository;
  int _pageSize = 50;
  int _currentPage = 0;
  int _totalCount = 0;

  TrashServiceItemsNotifier(this.repository) : super([]) {
    loadTrashItems();
  }

  int get pageSize => _pageSize;

  int get currentPage => _currentPage;

  int get totalCount => _totalCount;

  void loadTrashItems({int page = 0, int? pageSize}) {
    if (pageSize != null) {
      _pageSize = pageSize;
    }

    final offset = page * _pageSize;
    final result = repository.getTrashServiceItemsPaged(
      limit: _pageSize,
      offset: offset,
    );

    _currentPage = page;
    _totalCount = result.totalCount;
    state = result.items;
  }

  Future restoreServiceItem(int id, WidgetRef ref) async {
    if (repository.restoreServiceItem(id)) {
      state = state.where((item) => item.id != id).toList();

      if (_totalCount > 0) {
        _totalCount--;
      }

      ref.read(trashOperationProvider.notifier).state++;
    }
  }

  Future permanentlyDelete(int id) async {
    if (repository.permanentlyDeleteServiceItem(id)) {
      state = state.where((item) => item.id != id).toList();

      if (_totalCount > 0) {
        _totalCount--;
      }
    }
  }

  Future emptyTrash() async {
    final itemsToDelete = List<ServiceItem>.from(state);
    for (final item in itemsToDelete) {
      await permanentlyDelete(item.id);
    }
  }
}
