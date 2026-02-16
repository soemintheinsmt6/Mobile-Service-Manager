import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/data/models/brand.dart';
import 'package:mobile_service_manager/data/models/fault.dart';
import 'package:mobile_service_manager/data/models/service_item.dart';
import 'package:mobile_service_manager/data/models/technician.dart';

void main() {
  group('ServiceItem Model Tests', () {
    late ServiceItem serviceItem;
    late Brand brand;
    late Technician technician;
    late List<Fault> faults;

    setUp(() {
      brand = Brand(id: 1, name: 'Samsung');
      technician = Technician(id: 1, name: 'John Doe');
      faults = [
        Fault(id: 1, name: 'Screen Crack'),
        Fault(id: 2, name: 'Battery Issue'),
      ];

      serviceItem = ServiceItem(
        id: 1,
        invoiceId: 12345,
        customerName: 'Jane Smith',
        phoneNumber: '09123456789',
        model: 'Galaxy S21',
        imei: '123456789012345',
        issueDate: '2024-01-15',
        deliveryDate: '2024-01-20',
        expense: 50000,
        servicePrice: 80000,
        simIncluded: true,
        sdIncluded: false,
        remark: 'Customer requested fast repair',
        status: 'in_progress',
        location: 'in_store',
        isTrash: false,
      );

      // Set relationships
      serviceItem.brand.target = brand;
      serviceItem.technician.target = technician;
      serviceItem.setFaults(faults);
    });

    test('should create ServiceItem with correct default values', () {
      final defaultItem = ServiceItem(
        invoiceId: 123,
        customerName: 'Test Customer',
        phoneNumber: '09123456789',
        model: 'Test Model',
        imei: '123456789012345',
        issueDate: '2024-01-15',
      );

      expect(defaultItem.id, equals(0));
      expect(defaultItem.simIncluded, equals(false));
      expect(defaultItem.sdIncluded, equals(false));
      expect(defaultItem.status, equals('in_progress'));
      expect(defaultItem.location, equals('in_store'));
      expect(defaultItem.isTrash, equals(false));
      expect(defaultItem.expense, isNull);
      expect(defaultItem.servicePrice, isNull);
      expect(defaultItem.deliveryDate, isNull);
      expect(defaultItem.remark, isNull);
    });

    test('should correctly calculate simAndSd property', () {
      // Test with both SIM and SD
      serviceItem.simIncluded = true;
      serviceItem.sdIncluded = true;
      expect(serviceItem.simAndSd, equals('SIM & SD'));

      // Test with only SIM
      serviceItem.simIncluded = true;
      serviceItem.sdIncluded = false;
      expect(serviceItem.simAndSd, equals('SIM'));

      // Test with only SD
      serviceItem.simIncluded = false;
      serviceItem.sdIncluded = true;
      expect(serviceItem.simAndSd, equals('SD'));

      // Test with neither
      serviceItem.simIncluded = false;
      serviceItem.sdIncluded = false;
      expect(serviceItem.simAndSd, equals('N/A'));
    });

    test('should correctly set faults using setFaults method', () {
      final newFaults = [
        Fault(id: 3, name: 'New Fault 1'),
        Fault(id: 4, name: 'New Fault 2'),
      ];

      serviceItem.setFaults(newFaults);

      expect(serviceItem.faults.length, equals(2));
      expect(serviceItem.faults[0].name, equals('New Fault 1'));
      expect(serviceItem.faults[1].name, equals('New Fault 2'));
    });

    test('should clear existing faults when setting new ones', () {
      // Initially has 2 faults
      expect(serviceItem.faults.length, equals(2));

      // Set new faults
      final newFault = Fault(id: 5, name: 'Single New Fault');
      serviceItem.setFaults([newFault]);

      // Should only have 1 fault now
      expect(serviceItem.faults.length, equals(1));
      expect(serviceItem.faults[0].name, equals('Single New Fault'));
    });

    test('should convert to JSON correctly', () {
      final json = serviceItem.toJson();

      expect(json['id'], equals(1));
      expect(json['invoiceId'], equals(12345));
      expect(json['customerName'], equals('Jane Smith'));
      expect(json['phoneNumber'], equals('09123456789'));
      expect(json['model'], equals('Galaxy S21'));
      expect(json['imei'], equals('123456789012345'));
      expect(json['issueDate'], equals('2024-01-15'));
      expect(json['deliveryDate'], equals('2024-01-20'));
      expect(json['expense'], equals(50000));
      expect(json['servicePrice'], equals(80000));
      expect(json['simIncluded'], equals(true));
      expect(json['sdIncluded'], equals(false));
      expect(json['remark'], equals('Customer requested fast repair'));
      expect(json['status'], equals('in_progress'));
      expect(json['location'], equals('in_store'));
      expect(json['isTrash'], equals(false));
      expect(json['brandId'], equals(1));
      expect(json['technicianId'], equals(1));
      expect(json['faultIds'], equals([1, 2]));
    });

    test('should handle null values in JSON conversion', () {
      final itemWithNulls = ServiceItem(
        invoiceId: 123,
        customerName: 'Test',
        phoneNumber: '09123456789',
        model: 'Test Model',
        imei: '123456789012345',
        issueDate: '2024-01-15',
      );

      final json = itemWithNulls.toJson();

      expect(json['expense'], isNull);
      expect(json['servicePrice'], isNull);
      expect(json['deliveryDate'], isNull);
      expect(json['remark'], isNull);
      expect(json['brandId'], isNull);
      expect(json['technicianId'], isNull);
      expect(json['faultIds'], equals([]));
    });

    test('should maintain relationships correctly', () {
      expect(serviceItem.brand.target?.id, equals(1));
      expect(serviceItem.brand.target?.name, equals('Samsung'));
      expect(serviceItem.technician.target?.id, equals(1));
      expect(serviceItem.technician.target?.name, equals('John Doe'));
      expect(serviceItem.faults.length, equals(2));
      expect(serviceItem.faults[0].name, equals('Screen Crack'));
      expect(serviceItem.faults[1].name, equals('Battery Issue'));
    });

    test('should handle empty fault list', () {
      serviceItem.setFaults([]);
      expect(serviceItem.faults.length, equals(0));
      expect(serviceItem.toJson()['faultIds'], equals([]));
    });

    test('should handle null brand and technician relationships', () {
      serviceItem.brand.target = null;
      serviceItem.technician.target = null;

      final json = serviceItem.toJson();
      expect(json['brandId'], isNull);
      expect(json['technicianId'], isNull);
    });
  });
}
