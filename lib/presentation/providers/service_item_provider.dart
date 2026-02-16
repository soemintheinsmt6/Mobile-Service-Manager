import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/presentation/providers/repository_providers.dart';
import 'package:mobile_service_manager/presentation/providers/trash_service_item_provider.dart';

import '../../data/models/brand.dart';
import '../../data/models/fault.dart';
import '../../data/models/service_item.dart';
import '../../data/models/technician.dart';
import '../../data/repositories/service_item_repository.dart';

final serviceItemsProvider =
    StateNotifierProvider<ServiceItemsNotifier, List<ServiceItem>>((ref) {
  final repo = ref.watch(serviceItemRepositoryProvider);
  return ServiceItemsNotifier(repo);
});

class ServiceItemsNotifier extends StateNotifier<List<ServiceItem>> {
  final ServiceItemRepository repository;
  bool _isSearchActive = false;
  int _pageSize = 50;
  int _currentPage = 0;
  int _totalCount = 0;

  ServiceItemsNotifier(this.repository) : super([]) {
    loadServiceItems();
  }

  bool get isSearchActive => _isSearchActive;

  int get pageSize => _pageSize;

  int get currentPage => _currentPage;

  int get totalCount => _isSearchActive ? state.length : _totalCount;

  void loadServiceItems({int page = 0, int? pageSize}) {
    _isSearchActive = false;

    if (pageSize != null) {
      _pageSize = pageSize;
    }

    final offset = page * _pageSize;
    final result = repository.getTodayServiceItemsPaged(
      limit: _pageSize,
      offset: offset,
    );

    _currentPage = page;
    _totalCount = result.totalCount;
    state = result.items;
  }

  Future<void> addServiceItem(ServiceItem item) async {
    final id = repository.addServiceItem(item);
    item.id = id;

    if (_isSearchActive) {
      state = [...state, item];
    } else {
      _totalCount++;
      state = [...state, item];
    }
  }

  Future<void> updateServiceItem(ServiceItem item) async {
    repository.updateServiceItem(item);
    state = [
      for (final s in state)
        if (s.id == item.id) item else s
    ];
  }

  Future moveToTrash(int id, WidgetRef ref) async {
    if (repository.deleteServiceItem(id)) {
      state = state.where((item) => item.id != id).toList();

      if (!_isSearchActive && _totalCount > 0) {
        _totalCount--;
      }

      ref.read(trashOperationProvider.notifier).state++;
      ref.read(trashServiceItemProvider.notifier).loadTrashItems();
    }
  }

  Future restoreFromTrash(int id) async {
    if (repository.restoreServiceItem(id)) {
      state = state.where((item) => item.id != id).toList();

      if (!_isSearchActive && _totalCount > 0) {
        _totalCount--;
      }
    }
  }

  Future permanentlyDelete(int id) async {
    if (repository.permanentlyDeleteServiceItem(id)) {
      state = state.where((item) => item.id != id).toList();

      if (!_isSearchActive && _totalCount > 0) {
        _totalCount--;
      }
    }
  }

  void searchServiceItems({
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
    final results = repository.searchServiceItems(
      invoiceId: invoiceId,
      customerName: customerName,
      phoneNumber: phoneNumber,
      brand: brand,
      fault: fault,
      technician: technician,
      deviceStatus: deviceStatus,
      deliveryStatus: deliveryStatus,
      specificDate: specificDate,
      fromDate: fromDate,
      toDate: toDate,
    );

    _isSearchActive = true;
    _currentPage = 0;
    _totalCount = results.length;
    state = results;
  }

  void resetSearch() {
    if (_isSearchActive) {
      _currentPage = 0;
      _totalCount = 0;
      loadServiceItems();
    }
  }
}
