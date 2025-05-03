import 'package:riverpod/riverpod.dart';

import '../repositories/brand_repository.dart';
import '../repositories/technician_repository.dart';
import 'object_box_provider.dart';

// Brand repository provider
final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  final objectBox = ref.watch(objectBoxProvider);
  return BrandRepository(objectBox);
});

// Technician repository provider
final technicianRepositoryProvider = Provider<TechnicianRepository>((ref) {
  final objectBox = ref.watch(objectBoxProvider);
  return TechnicianRepository(objectBox);
});
