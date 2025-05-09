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
    loadItems();
  }

  void loadItems() {
    state = repository.getAllItems();
  }

  Future<void> addItem(ServiceItem item) async {
    final id = repository.addItem(item);
    item.id = id;
    state = [...state, item];
  }

  Future<void> deleteItem(int id) async {
    if (repository.deleteItem(id)) {
      state = state.where((item) => item.id != id).toList();
    }
  }
}
