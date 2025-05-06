import 'package:mobile_service_manager/repositories/technician_repository.dart';
import 'package:riverpod/riverpod.dart';

import '../models/technician.dart';
import 'repository_providers.dart';

// Provider for the list of all technicians
final techniciansProvider =
    StateNotifierProvider<TechniciansNotifier, List<Technician>>((ref) {
  final repository = ref.watch(technicianRepositoryProvider);
  return TechniciansNotifier(repository);
});

// Notifier class to manage the technician list state
class TechniciansNotifier extends StateNotifier<List<Technician>> {
  final TechnicianRepository repository;

  TechniciansNotifier(this.repository) : super([]) {
    // Load technicians when initialized
    loadTechnicians();
  }

  void loadTechnicians() {
    state = repository.getAllTechnicians();
  }

  Future<void> addTechnician(Technician technician) async {
    final id = repository.addTechnician(technician);
    // If ID was 0, update it with the new ID from ObjectBox
    if (technician.id == 0) {
      technician = Technician(id: id, name: technician.name);
    }
    state = [...state, technician];
  }

  Future<void> updateTechnician(Technician technician) async {
    repository.updateTechnician(technician);
    state = [
      for (final item in state)
        if (item.id == technician.id) technician else item
    ];
  }

  Future<void> deleteTechnician(int id) async {
    if (repository.deleteTechnician(id)) {
      state = state.where((technician) => technician.id != id).toList();
    }
  }
}
