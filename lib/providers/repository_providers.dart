import 'package:mobile_service_manager/repositories/fault_repository.dart';
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

// Fault repository provider
final faultRepositoryProvider = Provider<FaultRepository>((ref) {
  final objectBox = ref.watch(objectBoxProvider);
  return FaultRepository(objectBox);
});
