import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/models/brand.dart';

void main() {
  group('Brand Model Tests', () {
    test('should create Brand with correct properties', () {
      final brand = Brand(id: 1, name: 'Samsung');
      
      expect(brand.id, equals(1));
      expect(brand.name, equals('Samsung'));
    });

    test('should create Brand with default id', () {
      final brand = Brand(name: 'iPhone');
      
      expect(brand.id, equals(0));
      expect(brand.name, equals('iPhone'));
    });

    test('should create Brand from JSON correctly', () {
      final json = {'id': 2, 'name': 'Huawei'};
      final brand = Brand.fromJson(json);
      
      expect(brand.id, equals(2));
      expect(brand.name, equals('Huawei'));
    });

    test('should create Brand from JSON with null id', () {
      final json = {'name': 'Xiaomi'};
      final brand = Brand.fromJson(json);
      
      expect(brand.id, equals(0));
      expect(brand.name, equals('Xiaomi'));
    });

    test('should convert Brand to JSON correctly', () {
      final brand = Brand(id: 3, name: 'OnePlus');
      final json = brand.toJson();
      
      expect(json['id'], equals(3));
      expect(json['name'], equals('OnePlus'));
    });

    test('should handle empty name', () {
      final brand = Brand(name: '');
      expect(brand.name, equals(''));
    });

    test('should implement Item interface', () {
      final brand = Brand(name: 'Test Brand');
      expect(brand.id, isA<int>());
      expect(brand.name, isA<String>());
    });
  });
}
