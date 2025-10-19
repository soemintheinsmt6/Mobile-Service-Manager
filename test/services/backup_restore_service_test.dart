import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/services/backup_restore_service.dart';
import 'package:mobile_service_manager/models/brand.dart';
import 'package:mobile_service_manager/models/fault.dart';
import 'package:mobile_service_manager/models/service_item.dart';
import 'package:mobile_service_manager/models/technician.dart';

import 'package:mobile_service_manager/database/object_box.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'backup_restore_service_test.mocks.dart';

@GenerateMocks([ObjectBox])
void main() {
  group('BackupRestoreService Tests', () {
    late MockObjectBox mockObjectBox;

    setUp(() {
      mockObjectBox = MockObjectBox();
    });

    group('Service Initialization', () {
      test('should create service with ObjectBox instance', () {
        // Act
        final service = BackupRestoreService(mockObjectBox);

        // Assert
        expect(service, isNotNull);
        expect(service, isA<BackupRestoreService>());
      });
    });

    group('Mock Setup', () {
      test('should setup mock ObjectBox correctly', () {
        // Arrange
        final brands = [Brand(id: 1, name: 'Samsung')];
        final technicians = [Technician(id: 1, name: 'John Doe')];
        final faults = [Fault(id: 1, name: 'Screen Crack')];
        final serviceItems = [ServiceItem(
          invoiceId: 123,
          customerName: 'Test Customer',
          phoneNumber: '09123456789',
          model: 'Test Model',
          imei: '123456789012345',
          issueDate: '2024-01-15',
        )];

        when(mockObjectBox.getAllBrands()).thenReturn(brands);
        when(mockObjectBox.getAllTechnicians()).thenReturn(technicians);
        when(mockObjectBox.getAllFaults()).thenReturn(faults);
        when(mockObjectBox.getAllServiceItems()).thenReturn(serviceItems);

        // Act & Assert
        expect(mockObjectBox.getAllBrands(), equals(brands));
        expect(mockObjectBox.getAllTechnicians(), equals(technicians));
        expect(mockObjectBox.getAllFaults(), equals(faults));
        expect(mockObjectBox.getAllServiceItems(), equals(serviceItems));
      });
    });
  });
}

