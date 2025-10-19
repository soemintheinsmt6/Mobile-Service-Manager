import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/models/technician.dart';

void main() {
  group('Technician Model Tests', () {
    test('should create Technician with correct properties', () {
      final technician = Technician(id: 1, name: 'John Doe');
      
      expect(technician.id, equals(1));
      expect(technician.name, equals('John Doe'));
    });

    test('should create Technician with default id', () {
      final technician = Technician(name: 'Jane Smith');
      
      expect(technician.id, equals(0));
      expect(technician.name, equals('Jane Smith'));
    });

    test('should create Technician from JSON correctly', () {
      final json = {'id': 2, 'name': 'Mike Johnson'};
      final technician = Technician.fromJson(json);
      
      expect(technician.id, equals(2));
      expect(technician.name, equals('Mike Johnson'));
    });

    test('should create Technician from JSON with null id', () {
      final json = {'name': 'Sarah Wilson'};
      final technician = Technician.fromJson(json);
      
      expect(technician.id, equals(0));
      expect(technician.name, equals('Sarah Wilson'));
    });

    test('should convert Technician to JSON correctly', () {
      final technician = Technician(id: 3, name: 'David Brown');
      final json = technician.toJson();
      
      expect(json['id'], equals(3));
      expect(json['name'], equals('David Brown'));
    });

    test('should handle empty name', () {
      final technician = Technician(name: '');
      expect(technician.name, equals(''));
    });

    test('should implement Item interface', () {
      final technician = Technician(name: 'Test Technician');
      expect(technician.id, isA<int>());
      expect(technician.name, isA<String>());
    });

    test('should handle special characters in name', () {
      final technician = Technician(name: 'José María');
      expect(technician.name, equals('José María'));
      
      final json = technician.toJson();
      expect(json['name'], equals('José María'));
    });
  });
}
