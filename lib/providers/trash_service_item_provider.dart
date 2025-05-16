import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/providers/repository_providers.dart';
import '../models/service_item.dart';
import '../repositories/service_item_repository.dart';

final trashServiceItemProvider =
    StateNotifierProvider<TrashServiceItemsNotifier, List<ServiceItem>>((ref) {
  final repo = ref.watch(serviceItemRepositoryProvider);
  return TrashServiceItemsNotifier(repo);
});

// Dedicated notifier for trash items
class TrashServiceItemsNotifier extends StateNotifier<List<ServiceItem>> {
  final ServiceItemRepository repository;

  TrashServiceItemsNotifier(this.repository) : super([]) {
    loadTrashItems();
  }

  void loadTrashItems() {
    state = repository.getTrashServiceItems();
  }

  Future restoreServiceItem(int id, WidgetRef ref) async {
    if (repository.restoreServiceItem(id)) {
      state = state.where((item) => item.id != id).toList();

      ref.read(trashOperationProvider.notifier).state++;
    }
  }

  Future permanentlyDelete(int id) async {
    if (repository.permanentlyDeleteServiceItem(id)) {
      state = state.where((item) => item.id != id).toList();
    }
  }

  Future emptyTrash() async {
    final itemsToDelete = List<ServiceItem>.from(state);
    for (final item in itemsToDelete) {
      await permanentlyDelete(item.id);
    }
  }
}
