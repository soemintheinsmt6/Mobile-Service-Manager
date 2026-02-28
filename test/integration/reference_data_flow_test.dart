// Integration tests: Reference data CRUD flow
//
// Tests all three reference-data repositories (Brand, Technician, Fault) and
// their corresponding Riverpod notifiers in a unified way.  Each scenario
// exercises the full flow: repository method → provider state update.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_service_manager/data/models/brand.dart';
import 'package:mobile_service_manager/data/models/fault.dart';
import 'package:mobile_service_manager/data/models/technician.dart';
import 'package:mobile_service_manager/data/repositories/brand_repository.dart';
import 'package:mobile_service_manager/data/repositories/fault_repository.dart';
import 'package:mobile_service_manager/data/repositories/technician_repository.dart';
import 'package:mobile_service_manager/presentation/providers/brand_provider.dart';
import 'package:mobile_service_manager/presentation/providers/fault_provider.dart';
import 'package:mobile_service_manager/presentation/providers/repository_providers.dart';
import 'package:mobile_service_manager/presentation/providers/technician_provider.dart';

import '../repositories/service_item_repository_test.mocks.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockObjectBox mockObjectBox;

  setUp(() {
    mockObjectBox = MockObjectBox();
  });

  // ── 1. BrandRepository ────────────────────────────────────────────────────

  group('BrandRepository integration', () {
    late BrandRepository repo;

    setUp(() {
      repo = BrandRepository(mockObjectBox);
    });

    test('addBrand delegates to ObjectBox and returns assigned ID', () {
      final brand = Brand(name: 'Samsung');
      when(mockObjectBox.insertBrand(brand)).thenReturn(10);

      final id = repo.addBrand(brand);

      expect(id, equals(10));
      verify(mockObjectBox.insertBrand(brand)).called(1);
    });

    test('getAllBrands returns complete list from ObjectBox', () {
      final brands = [
        Brand(id: 1, name: 'Samsung'),
        Brand(id: 2, name: 'Apple')
      ];
      when(mockObjectBox.getAllBrands()).thenReturn(brands);

      expect(repo.getAllBrands(), hasLength(2));
      expect(repo.getAllBrands().map((b) => b.name),
          containsAll(['Samsung', 'Apple']));
    });

    test('updateBrand delegates to ObjectBox insert/put', () {
      final brand = Brand(id: 1, name: 'Apple Updated');
      when(mockObjectBox.insertBrand(brand)).thenReturn(1);

      final id = repo.updateBrand(brand);

      expect(id, equals(1));
      verify(mockObjectBox.insertBrand(brand)).called(1);
    });

    test('deleteBrand returns true on success', () {
      when(mockObjectBox.deleteBrand(1)).thenReturn(true);
      expect(repo.deleteBrand(1), isTrue);
    });

    test('deleteBrand returns false when ID is not found', () {
      when(mockObjectBox.deleteBrand(999)).thenReturn(false);
      expect(repo.deleteBrand(999), isFalse);
    });

    test('getBrandById returns correct brand', () {
      final brand = Brand(id: 3, name: 'Huawei');
      when(mockObjectBox.getBrand(3)).thenReturn(brand);

      final result = repo.getBrandById(3);
      expect(result, isNotNull);
      expect(result!.name, 'Huawei');
    });

    test('getBrandById returns null for unknown ID', () {
      when(mockObjectBox.getBrand(404)).thenReturn(null);
      expect(repo.getBrandById(404), isNull);
    });
  });

  // ── 2. TechnicianRepository ───────────────────────────────────────────────

  group('TechnicianRepository integration', () {
    late TechnicianRepository repo;

    setUp(() {
      repo = TechnicianRepository(mockObjectBox);
    });

    test('addTechnician returns assigned ID', () {
      final tech = Technician(name: 'John Doe');
      when(mockObjectBox.insertTechnician(tech)).thenReturn(5);

      expect(repo.addTechnician(tech), equals(5));
    });

    test('getAllTechnicians returns list from ObjectBox', () {
      final techs = [
        Technician(id: 1, name: 'John'),
        Technician(id: 2, name: 'Jane')
      ];
      when(mockObjectBox.getAllTechnicians()).thenReturn(techs);

      final result = repo.getAllTechnicians();
      expect(result, hasLength(2));
    });

    test('updateTechnician delegates to ObjectBox', () {
      final tech = Technician(id: 1, name: 'John Updated');
      when(mockObjectBox.insertTechnician(tech)).thenReturn(1);

      expect(repo.updateTechnician(tech), equals(1));
      verify(mockObjectBox.insertTechnician(tech)).called(1);
    });

    test('deleteTechnician returns true on success', () {
      when(mockObjectBox.deleteTechnician(1)).thenReturn(true);
      expect(repo.deleteTechnician(1), isTrue);
    });

    test('deleteTechnician returns false when ID not found', () {
      when(mockObjectBox.deleteTechnician(999)).thenReturn(false);
      expect(repo.deleteTechnician(999), isFalse);
    });

    test('getTechnicianById returns correct technician', () {
      final tech = Technician(id: 2, name: 'Jane Smith');
      when(mockObjectBox.getTechnician(2)).thenReturn(tech);

      expect(repo.getTechnicianById(2)?.name, 'Jane Smith');
    });
  });

  // ── 3. FaultRepository ────────────────────────────────────────────────────

  group('FaultRepository integration', () {
    late FaultRepository repo;

    setUp(() {
      repo = FaultRepository(mockObjectBox);
    });

    test('addFault returns assigned ID', () {
      final fault = Fault(name: 'Screen Crack');
      when(mockObjectBox.insertFault(fault)).thenReturn(7);

      expect(repo.addFault(fault), equals(7));
    });

    test('getAllFaults returns list from ObjectBox', () {
      final faults = [
        Fault(id: 1, name: 'Battery'),
        Fault(id: 2, name: 'Screen')
      ];
      when(mockObjectBox.getAllFaults()).thenReturn(faults);

      expect(repo.getAllFaults(), hasLength(2));
    });

    test('updateFault delegates to ObjectBox', () {
      final fault = Fault(id: 1, name: 'Battery Issue Updated');
      when(mockObjectBox.insertFault(fault)).thenReturn(1);

      expect(repo.updateFault(fault), equals(1));
    });

    test('deleteFault returns true', () {
      when(mockObjectBox.deleteFault(2)).thenReturn(true);
      expect(repo.deleteFault(2), isTrue);
    });

    test('getFaultById returns null for unknown ID', () {
      when(mockObjectBox.getFault(404)).thenReturn(null);
      expect(repo.getFaultById(404), isNull);
    });
  });

  // ── 4. Riverpod notifier state changes ────────────────────────────────────

  group('BrandsNotifier via ProviderContainer', () {
    ProviderContainer makeContainer(MockObjectBox db) {
      return ProviderContainer(
        overrides: [
          brandRepositoryProvider.overrideWithValue(BrandRepository(db)),
        ],
      );
    }

    test('loads brands from repository on creation', () {
      final brands = [
        Brand(id: 1, name: 'Samsung'),
        Brand(id: 2, name: 'Apple')
      ];
      when(mockObjectBox.getAllBrands()).thenReturn(brands);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      final state = container.read(brandsProvider);
      expect(state, hasLength(2));
    });

    test('addBrand updates provider state', () async {
      when(mockObjectBox.getAllBrands()).thenReturn([]);
      final newBrand = Brand(name: 'Huawei');
      when(mockObjectBox.insertBrand(any)).thenReturn(3);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      await container.read(brandsProvider.notifier).addBrand(newBrand);

      final state = container.read(brandsProvider);
      expect(state, hasLength(1));
      expect(state.first.name, 'Huawei');
    });

    test('updateBrand reflects change in provider state', () async {
      final original = Brand(id: 1, name: 'Samsung');
      when(mockObjectBox.getAllBrands()).thenReturn([original]);
      final updated = Brand(id: 1, name: 'Samsung Updated');
      when(mockObjectBox.insertBrand(any)).thenReturn(1);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      await container.read(brandsProvider.notifier).updateBrand(updated);

      final state = container.read(brandsProvider);
      expect(state.first.name, 'Samsung Updated');
    });

    test('deleteBrand removes item from provider state', () async {
      final brand = Brand(id: 1, name: 'Samsung');
      when(mockObjectBox.getAllBrands()).thenReturn([brand]);
      when(mockObjectBox.deleteBrand(1)).thenReturn(true);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      await container.read(brandsProvider.notifier).deleteBrand(1);

      expect(container.read(brandsProvider), isEmpty);
    });
  });

  group('TechniciansNotifier via ProviderContainer', () {
    ProviderContainer makeContainer(MockObjectBox db) {
      return ProviderContainer(
        overrides: [
          technicianRepositoryProvider
              .overrideWithValue(TechnicianRepository(db)),
        ],
      );
    }

    test('loads technicians from repository on creation', () {
      final techs = [
        Technician(id: 1, name: 'John'),
        Technician(id: 2, name: 'Jane')
      ];
      when(mockObjectBox.getAllTechnicians()).thenReturn(techs);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      expect(container.read(techniciansProvider), hasLength(2));
    });

    test('addTechnician updates provider state', () async {
      when(mockObjectBox.getAllTechnicians()).thenReturn([]);
      when(mockObjectBox.insertTechnician(any)).thenReturn(10);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      final tech = Technician(name: 'New Tech');
      await container.read(techniciansProvider.notifier).addTechnician(tech);

      expect(container.read(techniciansProvider), hasLength(1));
      expect(container.read(techniciansProvider).first.name, 'New Tech');
    });

    test('deleteTechnician removes item from provider state', () async {
      final tech = Technician(id: 5, name: 'To Delete');
      when(mockObjectBox.getAllTechnicians()).thenReturn([tech]);
      when(mockObjectBox.deleteTechnician(5)).thenReturn(true);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      await container.read(techniciansProvider.notifier).deleteTechnician(5);

      expect(container.read(techniciansProvider), isEmpty);
    });
  });

  group('FaultsNotifier via ProviderContainer', () {
    ProviderContainer makeContainer(MockObjectBox db) {
      return ProviderContainer(
        overrides: [
          faultRepositoryProvider.overrideWithValue(FaultRepository(db)),
        ],
      );
    }

    test('loads faults from repository on creation', () {
      final faults = [
        Fault(id: 1, name: 'Screen Crack'),
        Fault(id: 2, name: 'Battery')
      ];
      when(mockObjectBox.getAllFaults()).thenReturn(faults);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      expect(container.read(faultsProvider), hasLength(2));
    });

    test('addFault updates provider state', () async {
      when(mockObjectBox.getAllFaults()).thenReturn([]);
      when(mockObjectBox.insertFault(any)).thenReturn(99);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      final fault = Fault(name: 'Water Damage');
      await container.read(faultsProvider.notifier).addFault(fault);

      expect(container.read(faultsProvider), hasLength(1));
      expect(container.read(faultsProvider).first.name, 'Water Damage');
    });

    test('deleteFault removes item from provider state', () async {
      final fault = Fault(id: 2, name: 'Battery');
      when(mockObjectBox.getAllFaults()).thenReturn([fault]);
      when(mockObjectBox.deleteFault(2)).thenReturn(true);

      final container = makeContainer(mockObjectBox);
      addTearDown(container.dispose);

      await container.read(faultsProvider.notifier).deleteFault(2);

      expect(container.read(faultsProvider), isEmpty);
    });
  });
}
