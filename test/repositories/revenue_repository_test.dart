import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/data/models/service_item.dart';
import 'package:mobile_service_manager/data/models/brand.dart';
import 'package:mobile_service_manager/data/models/technician.dart';
import 'package:mobile_service_manager/data/models/fault.dart';
import 'package:mobile_service_manager/data/repositories/revenue_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile_service_manager/data/database/object_box.dart';

import 'revenue_repository_test.mocks.dart';

@GenerateMocks([ObjectBox])
void main() {
  group('RevenueRepository Tests', () {
    late RevenueRepository repository;
    late MockObjectBox mockObjectBox;

    setUp(() {
      mockObjectBox = MockObjectBox();
      repository = RevenueRepository(mockObjectBox);
    });

    group('getDailyRevenue', () {
      test('should calculate daily revenue correctly for a given date', () {
        // Arrange
        final testDate = DateTime(2024, 1, 15);
        final brand = Brand(id: 1, name: 'Samsung');
        final technician = Technician(id: 1, name: 'John Doe');
        final fault = Fault(id: 1, name: 'Screen Crack');

        final serviceItems = [
          ServiceItem(
            id: 1,
            invoiceId: 123,
            customerName: 'Customer 1',
            phoneNumber: '09123456789',
            model: 'Galaxy S21',
            imei: '123456789012345',
            issueDate: '2024-01-15',
            status: 'done',
            location: 'delivered',
            servicePrice: 100000,
            expense: 50000,
          ),
          ServiceItem(
            id: 2,
            invoiceId: 124,
            customerName: 'Customer 2',
            phoneNumber: '09123456790',
            model: 'Galaxy S22',
            imei: '123456789012346',
            issueDate: '2024-01-15',
            status: 'in_progress',
            location: 'in_store',
            servicePrice: 80000,
            expense: 40000,
          ),
          ServiceItem(
            id: 3,
            invoiceId: 125,
            customerName: 'Customer 3',
            phoneNumber: '09123456791',
            model: 'Galaxy S23',
            imei: '123456789012347',
            issueDate: '2024-01-15',
            status: 'return',
            location: 'in_store',
            servicePrice: 0,
            expense: 30000,
          ),
        ];

        // Set relationships
        serviceItems[0].brand.target = brand;
        serviceItems[0].technician.target = technician;
        serviceItems[0].setFaults([fault]);
        serviceItems[1].brand.target = brand;
        serviceItems[1].technician.target = technician;
        serviceItems[1].setFaults([fault]);
        serviceItems[2].brand.target = brand;
        serviceItems[2].technician.target = technician;
        serviceItems[2].setFaults([fault]);

        // Mock the getAllServiceItems method that the repository actually calls
        when(mockObjectBox.getAllServiceItems()).thenReturn(serviceItems);

        // Act
        final result = repository.getDailyRevenue(testDate, isIssueDate: true);

        // Assert
        expect(result.date, equals(testDate));
        expect(result.totalServiceItemCount, equals(3));
        expect(result.doneCount, equals(1));
        expect(result.inProgressCount, equals(1));
        expect(result.returnCount, equals(1));
        expect(result.freeCount, equals(0));
        expect(result.inStoreCount, equals(2));
        expect(result.deliveredCount, equals(1));
        expect(result.priceTotal, equals(180000));
        expect(result.expenseTotal, equals(120000));
        expect(result.profit, equals(60000));
      });

      test('should handle empty service items list', () {
        // Arrange
        final testDate = DateTime(2024, 1, 15);
        when(mockObjectBox.getAllServiceItems()).thenReturn([]);

        // Act
        final result = repository.getDailyRevenue(testDate, isIssueDate: true);

        // Assert
        expect(result.date, equals(testDate));
        expect(result.totalServiceItemCount, equals(0));
        expect(result.doneCount, equals(0));
        expect(result.inProgressCount, equals(0));
        expect(result.returnCount, equals(0));
        expect(result.freeCount, equals(0));
        expect(result.inStoreCount, equals(0));
        expect(result.deliveredCount, equals(0));
        expect(result.priceTotal, equals(0));
        expect(result.expenseTotal, equals(0));
        expect(result.profit, equals(0));
      });

      test('should handle service items with null prices and expenses', () {
        // Arrange
        final testDate = DateTime(2024, 1, 15);
        final serviceItems = [
          ServiceItem(
            id: 1,
            invoiceId: 123,
            customerName: 'Customer 1',
            phoneNumber: '09123456789',
            model: 'Galaxy S21',
            imei: '123456789012345',
            issueDate: '2024-01-15',
            status: 'done',
            location: 'delivered',
            servicePrice: null,
            expense: null,
          ),
        ];

        when(mockObjectBox.getAllServiceItems()).thenReturn(serviceItems);

        // Act
        final result = repository.getDailyRevenue(testDate, isIssueDate: true);

        // Assert
        expect(result.priceTotal, equals(0));
        expect(result.expenseTotal, equals(0));
        expect(result.profit, equals(0));
      });

      test('should calculate profit correctly with negative values', () {
        // Arrange
        final testDate = DateTime(2024, 1, 15);
        final serviceItems = [
          ServiceItem(
            id: 1,
            invoiceId: 123,
            customerName: 'Customer Test',
            phoneNumber: '09123456789',
            model: 'Galaxy S21',
            imei: '123456789012345',
            issueDate: '2024-01-15',
            status: 'done',
            location: 'delivered',
            servicePrice: 50000,
            expense: 80000,
          ),
        ];

        when(mockObjectBox.getAllServiceItems()).thenReturn(serviceItems);

        // Act
        final result = repository.getDailyRevenue(testDate, isIssueDate: true);

        // Assert
        expect(result.priceTotal, equals(50000));
        expect(result.expenseTotal, equals(80000));
        expect(result.profit, equals(-30000));
      });

      test('should handle all status types correctly', () {
        // Arrange
        final testDate = DateTime(2024, 1, 15);
        final serviceItems = [
          ServiceItem(
            id: 1,
            invoiceId: 123,
            customerName: 'Customer 1',
            phoneNumber: '09123456789',
            model: 'Galaxy S21',
            imei: '123456789012345',
            issueDate: '2024-01-15',
            status: 'done',
            location: 'delivered',
            servicePrice: 100000,
            expense: 50000,
          ),
          ServiceItem(
            id: 2,
            invoiceId: 124,
            customerName: 'Customer 2',
            phoneNumber: '09123456790',
            model: 'Galaxy S22',
            imei: '123456789012346',
            issueDate: '2024-01-15',
            status: 'in_progress',
            location: 'in_store',
            servicePrice: 80000,
            expense: 40000,
          ),
          ServiceItem(
            id: 3,
            invoiceId: 125,
            customerName: 'Customer 3',
            phoneNumber: '09123456791',
            model: 'Galaxy S23',
            imei: '123456789012347',
            issueDate: '2024-01-15',
            status: 'return',
            location: 'in_store',
            servicePrice: 0,
            expense: 30000,
          ),
          ServiceItem(
            id: 4,
            invoiceId: 126,
            customerName: 'Customer 4',
            phoneNumber: '09123456792',
            model: 'Galaxy S24',
            imei: '123456789012348',
            issueDate: '2024-01-15',
            status: 'free',
            location: 'delivered',
            servicePrice: 0,
            expense: 20000,
          ),
        ];

        when(mockObjectBox.getAllServiceItems()).thenReturn(serviceItems);

        // Act
        final result = repository.getDailyRevenue(testDate, isIssueDate: true);

        // Assert
        expect(result.doneCount, equals(1));
        expect(result.inProgressCount, equals(1));
        expect(result.returnCount, equals(1));
        expect(result.freeCount, equals(1));
        expect(result.inStoreCount, equals(2));
        expect(result.deliveredCount, equals(2));
      });
    });
  });
}