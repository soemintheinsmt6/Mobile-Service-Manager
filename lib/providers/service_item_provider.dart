import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/providers/repository_providers.dart';
import '../models/service_item.dart';
import '../repositories/service_item_repository.dart';

final serviceItemsProvider =
    StateNotifierProvider<ServiceItemsNotifier, List<ServiceItem>>((ref) {
  final repo = ref.watch(serviceItemRepositoryProvider);
  return ServiceItemsNotifier(repo);
});

class ServiceItemsNotifier extends StateNotifier<List<ServiceItem>> {
  final ServiceItemRepository repository;

  ServiceItemsNotifier(this.repository) : super([]) {
    loadServiceItems();
  }

  void loadServiceItems() {
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

  Future<void> deleteServiceItem(int id) async {
    if (repository.deleteServiceItem(id)) {
      state = state.where((item) => item.id != id).toList();
    }
  }
}
