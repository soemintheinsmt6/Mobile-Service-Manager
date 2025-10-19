import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/models/service_item.dart';
import 'package:mobile_service_manager/repositories/service_item_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile_service_manager/database/object_box.dart';

import 'service_item_repository_test.mocks.dart';

@GenerateMocks([ObjectBox])
void main() {
  group('ServiceItemRepository Tests', () {
    late ServiceItemRepository repository;
    late MockObjectBox mockObjectBox;

    setUp(() {
      mockObjectBox = MockObjectBox();
      repository = ServiceItemRepository(mockObjectBox);
    });

    group('getAllServiceItems', () {
      test('should return all service items from ObjectBox', () {
        // Arrange
        final serviceItems = [
          ServiceItem(
            invoiceId: 123,
            customerName: 'John Doe',
            phoneNumber: '09123456789',
            model: 'iPhone 12',
            imei: '123456789012345',
            issueDate: '2024-01-15',
          ),
          ServiceItem(
            invoiceId: 124,
            customerName: 'Jane Smith',
            phoneNumber: '09123456790',
            model: 'Samsung S21',
            imei: '123456789012346',
            issueDate: '2024-01-16',
          ),
        ];

        when(mockObjectBox.getAllServiceItems()).thenReturn(serviceItems);

        // Act
        final result = repository.getAllServiceItems();

        // Assert
        expect(result, equals(serviceItems));
        verify(mockObjectBox.getAllServiceItems()).called(1);
      });

      test('should return empty list when no service items exist', () {
        // Arrange
        when(mockObjectBox.getAllServiceItems()).thenReturn([]);

        // Act
        final result = repository.getAllServiceItems();

        // Assert
        expect(result, isEmpty);
        verify(mockObjectBox.getAllServiceItems()).called(1);
      });
    });

    group('getTrashServiceItems', () {
      test('should return trash service items from ObjectBox', () {
        // Arrange
        final trashItems = [
          ServiceItem(
            invoiceId: 125,
            customerName: 'Deleted Customer',
            phoneNumber: '09123456791',
            model: 'Deleted Model',
            imei: '123456789012347',
            issueDate: '2024-01-17',
            isTrash: true,
          ),
        ];

        when(mockObjectBox.getTrashServiceItems()).thenReturn(trashItems);

        // Act
        final result = repository.getTrashServiceItems();

        // Assert
        expect(result, equals(trashItems));
        verify(mockObjectBox.getTrashServiceItems()).called(1);
      });
    });

    group('getTodayServiceItems', () {
      test('should return today service items from ObjectBox', () {
        // Arrange
        final todayItems = [
          ServiceItem(
            invoiceId: 126,
            customerName: 'Today Customer',
            phoneNumber: '09123456792',
            model: 'Today Model',
            imei: '123456789012348',
            issueDate: '2024-01-18',
          ),
        ];

        when(mockObjectBox.getTodayServiceItems()).thenReturn(todayItems);

        // Act
        final result = repository.getTodayServiceItems();

        // Assert
        expect(result, equals(todayItems));
        verify(mockObjectBox.getTodayServiceItems()).called(1);
      });
    });

    group('addServiceItem', () {
      test('should add service item and return its ID', () {
        // Arrange
        final serviceItem = ServiceItem(
          invoiceId: 127,
          customerName: 'New Customer',
          phoneNumber: '09123456793',
          model: 'New Model',
          imei: '123456789012349',
          issueDate: '2024-01-19',
        );

        when(mockObjectBox.insertServiceItem(serviceItem)).thenReturn(1);

        // Act
        final result = repository.addServiceItem(serviceItem);

        // Assert
        expect(result, equals(1));
        verify(mockObjectBox.insertServiceItem(serviceItem)).called(1);
      });
    });

    group('updateServiceItem', () {
      test('should update service item and return its ID', () {
        // Arrange
        final serviceItem = ServiceItem(
          id: 1,
          invoiceId: 128,
          customerName: 'Updated Customer',
          phoneNumber: '09123456794',
          model: 'Updated Model',
          imei: '123456789012350',
          issueDate: '2024-01-20',
        );

        when(mockObjectBox.insertServiceItem(serviceItem)).thenReturn(1);

        // Act
        final result = repository.updateServiceItem(serviceItem);

        // Assert
        expect(result, equals(1));
        verify(mockObjectBox.insertServiceItem(serviceItem)).called(1);
      });
    });

    group('permanentlyDeleteServiceItem', () {
      test('should permanently delete service item', () {
        // Arrange
        when(mockObjectBox.deleteServiceItem(1)).thenReturn(true);

        // Act
        final result = repository.permanentlyDeleteServiceItem(1);

        // Assert
        expect(result, isTrue);
        verify(mockObjectBox.deleteServiceItem(1)).called(1);
      });

      test('should return false when deletion fails', () {
        // Arrange
        when(mockObjectBox.deleteServiceItem(999)).thenReturn(false);

        // Act
        final result = repository.permanentlyDeleteServiceItem(999);

        // Assert
        expect(result, isFalse);
        verify(mockObjectBox.deleteServiceItem(999)).called(1);
      });
    });
  });
}

