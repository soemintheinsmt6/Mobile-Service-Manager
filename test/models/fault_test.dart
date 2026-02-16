import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/data/models/fault.dart';

void main() {
  group('Fault Model Tests', () {
    test('should create Fault with correct properties', () {
      final fault = Fault(id: 1, name: 'Screen Crack');
      
      expect(fault.id, equals(1));
      expect(fault.name, equals('Screen Crack'));
    });

    test('should create Fault with default id', () {
      final fault = Fault(name: 'Battery Issue');
      
      expect(fault.id, equals(0));
      expect(fault.name, equals('Battery Issue'));
    });

    test('should create Fault from JSON correctly', () {
      final json = {'id': 2, 'name': 'Water Damage'};
      final fault = Fault.fromJson(json);
      
      expect(fault.id, equals(2));
      expect(fault.name, equals('Water Damage'));
    });

    test('should create Fault from JSON with null id', () {
      final json = {'name': 'Software Issue'};
      final fault = Fault.fromJson(json);
      
      expect(fault.id, equals(0));
      expect(fault.name, equals('Software Issue'));
    });

    test('should convert Fault to JSON correctly', () {
      final fault = Fault(id: 3, name: 'Camera Not Working');
      final json = fault.toJson();
      
      expect(json['id'], equals(3));
      expect(json['name'], equals('Camera Not Working'));
    });

    test('should handle empty name', () {
      final fault = Fault(name: '');
      expect(fault.name, equals(''));
    });

    test('should implement Item interface', () {
      final fault = Fault(name: 'Test Fault');
      expect(fault.id, isA<int>());
      expect(fault.name, isA<String>());
    });

    test('should handle special characters in name', () {
      final fault = Fault(name: 'Charging Port (USB-C)');
      expect(fault.name, equals('Charging Port (USB-C)'));
      
      final json = fault.toJson();
      expect(json['name'], equals('Charging Port (USB-C)'));
    });

    test('should handle long fault names', () {
      const longName = 'Very Long Fault Name That Describes A Complex Technical Issue';
      final fault = Fault(name: longName);
      expect(fault.name, equals(longName));
    });
  });
}
