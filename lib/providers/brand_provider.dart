import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/repositories/brand_repository.dart';
import '../models/brand.dart';
import 'repository_providers.dart';

// Provider for the list of all brands
final brandsProvider =
    StateNotifierProvider<BrandsNotifier, List<Brand>>((ref) {
  final repository = ref.watch(brandRepositoryProvider);
  return BrandsNotifier(repository);
});

// Notifier class to manage the brand list state
class BrandsNotifier extends StateNotifier<List<Brand>> {
  final BrandRepository repository;

  BrandsNotifier(this.repository) : super([]) {
    // Load brands when initialized
    loadBrands();
  }

  void loadBrands() {
    state = repository.getAllBrands();
  }

  Future<void> addBrand(Brand brand) async {
    final id = repository.addBrand(brand);
    // If ID was 0, update it with the new ID from ObjectBox
    if (brand.id == 0) {
      brand = Brand(id: id, name: brand.name);
    }
    state = [...state, brand];
  }

  Future<void> updateBrand(Brand brand) async {
    repository.updateBrand(brand);
    state = [
      for (final item in state)
        if (item.id == brand.id) brand else item
    ];
  }

  Future<void> deleteBrand(int id) async {
    if (repository.deleteBrand(id)) {
      state = state.where((brand) => brand.id != id).toList();
    }
  }
}
