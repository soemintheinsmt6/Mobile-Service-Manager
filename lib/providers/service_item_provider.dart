import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/models/technician.dart';
import 'package:mobile_service_manager/providers/repository_providers.dart';
import 'package:mobile_service_manager/providers/trash_service_item_provider.dart';
import '../models/brand.dart';
import '../models/fault.dart';
import '../models/service_item.dart';
import '../repositories/service_item_repository.dart';

final serviceItemsProvider =
    StateNotifierProvider<ServiceItemsNotifier, List<ServiceItem>>((ref) {
  final repo = ref.watch(serviceItemRepositoryProvider);
  return ServiceItemsNotifier(repo);
});

class ServiceItemsNotifier extends StateNotifier<List<ServiceItem>> {
  final ServiceItemRepository repository;
  bool _isSearchActive = false;

  ServiceItemsNotifier(this.repository) : super([]) {
    loadServiceItems();
  }

  bool get isSearchActive => _isSearchActive;

  void loadServiceItems() {
    _isSearchActive = false;
    state = repository.getAllServiceItems();
  }

  Future<void> addServiceItem(ServiceItem item) async {
    final id = repository.addServiceItem(item);
    item.id = id;
    state = [...state, item];
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
      // Remove from current state since it's now in trash
      state = state.where((item) => item.id != id).toList();

      ref.read(trashOperationProvider.notifier).state++;
      ref.read(trashServiceItemProvider.notifier).loadTrashItems();
    }
  }

  Future restoreFromTrash(int id) async {
    if (repository.restoreServiceItem(id)) {
      // If we're viewing trash, remove from current state
      state = state.where((item) => item.id != id).toList();
    }
  }

  Future permanentlyDelete(int id) async {
    if (repository.permanentlyDeleteServiceItem(id)) {
      state = state.where((item) => item.id != id).toList();
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
    state = repository.searchServiceItems(
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
  }

  void resetSearch() {
    if (_isSearchActive) {
      loadServiceItems();
    }
  }
}
