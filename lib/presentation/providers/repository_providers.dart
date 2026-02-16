import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/brand_repository.dart';
import '../../data/repositories/fault_repository.dart';
import '../../data/repositories/revenue_repository.dart';
import '../../data/repositories/service_item_repository.dart';
import '../../data/repositories/technician_repository.dart';

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

// Service Item repository provider
final serviceItemRepositoryProvider = Provider<ServiceItemRepository>((ref) {
  final objectBox = ref.watch(objectBoxProvider);
  return ServiceItemRepository(objectBox);
});

// Revenue repository provider
final revenueRepositoryProvider = Provider<RevenueRepository>((ref) {
  final objectBox = ref.watch(objectBoxProvider);
  return RevenueRepository(objectBox);
});

final trashOperationProvider = StateProvider<int>((ref) => 0);
