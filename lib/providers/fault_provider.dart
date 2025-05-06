import 'package:mobile_service_manager/models/fault.dart';
import 'package:mobile_service_manager/repositories/fault_repository.dart';
import 'package:riverpod/riverpod.dart';
import 'repository_providers.dart';

// Provider for the list of all brands
final faultsProvider =
    StateNotifierProvider<FaultsNotifier, List<Fault>>((ref) {
  final repository = ref.watch(faultRepositoryProvider);
  return FaultsNotifier(repository);
});

class FaultsNotifier extends StateNotifier<List<Fault>> {
  final FaultRepository repository;

  FaultsNotifier(this.repository) : super([]) {
    // Load brands when initialized
    loadFaults();
  }

  void loadFaults() {
    state = repository.getAllFaults();
  }

  Future<void> addFault(Fault fault) async {
    final id = repository.addFault(fault);

    if (fault.id == 0) {
      fault = Fault(id: id, name: fault.name);
    }
    state = [...state, fault];
  }

  Future<void> updateFault(Fault fault) async {
    repository.updateFault(fault);
    state = [
      for (final item in state)
        if (item.id == fault.id) fault else item
    ];
  }

  Future<void> deleteFault(int id) async {
    if (repository.deleteFault(id)) {
      state = state.where((fault) => fault.id != id).toList();
    }
  }
}
