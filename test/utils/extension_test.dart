import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/core/utils/extension.dart';

void main() {
  group('String Extensions Tests', () {
    group('StringCasingExtension', () {
      test('should capitalize first letter of string', () {
        expect('hello world'.capitalizeFirst(), equals('Hello world'));
      });

      test('should handle single character string', () {
        expect('a'.capitalizeFirst(), equals('A'));
      });

      test('should handle empty string', () {
        expect(''.capitalizeFirst(), equals(''));
      });

      test('should handle already capitalized string', () {
        expect('Hello'.capitalizeFirst(), equals('Hello'));
      });

      test('should handle string with numbers', () {
        expect('123abc'.capitalizeFirst(), equals('123abc'));
      });

      test('should handle string with special characters', () {
        expect('@hello'.capitalizeFirst(), equals('@hello'));
      });
    });

    group('DateFormatter Extension', () {
      test('should format valid date string correctly', () {
        expect('2024-01-15T10:30:00.000Z'.formattedDate, equals('15 Jan 2024'));
      });

      test('should format date without time', () {
        expect('2024-12-25'.formattedDate, equals('25 Dec 2024'));
      });

      test('should handle invalid date string', () {
        expect('invalid-date'.formattedDate, equals('invalid-date'));
      });

      test('should handle empty string', () {
        expect(''.formattedDate, equals(''));
      });

      test('should handle null-like string', () {
        expect('null'.formattedDate, equals('null'));
      });

      test('should format different months correctly', () {
        expect('2024-02-29'.formattedDate, equals('29 Feb 2024')); // Leap year
        expect('2024-06-15'.formattedDate, equals('15 Jun 2024'));
        expect('2024-09-01'.formattedDate, equals('1 Sep 2024'));
      });
    });
  });

  group('Number Formatting Extensions Tests', () {
    group('NumberFormatting Extension', () {
      test('should format number with commas', () {
        expect(1000.formatted(), equals('1,000'));
      });

      test('should format large number with commas', () {
        expect(1234567.formatted(), equals('1,234,567'));
      });

      test('should format zero', () {
        expect(0.formatted(), equals('0'));
      });

      test('should format single digit', () {
        expect(5.formatted(), equals('5'));
      });

      test('should format negative number', () {
        expect((-1000).formatted(), equals('-1,000'));
      });

      test('should format very large number', () {
        expect(999999999.formatted(), equals('999,999,999'));
      });
    });

    group('Currency Formatting Extension', () {
      test('should format to Myanmar Kyat with default symbol', () {
        expect(1000.toMMks(), equals('1,000 Ks'));
      });

      test('should format to Myanmar Kyat with custom symbol', () {
        expect(1000.toMMks(symbol: ' MMK'), equals('1,000 MMK'));
      });

      test('should format large amount to Myanmar Kyat', () {
        expect(1000000.toMMks(), equals('1,000,000 Ks'));
      });

      test('should format zero to Myanmar Kyat', () {
        expect(0.toMMks(), equals('0 Ks'));
      });

      test('should format negative amount to Myanmar Kyat', () {
        expect((-1000).toMMks(), equals('-1,000 Ks'));
      });

      test('should format to USD currency', () {
        expect(1000.toCurrency(symbol: '\$'), equals('\$1,000'));
      });

      test('should format to EUR currency', () {
        expect(1000.toCurrency(locale: 'en_US', symbol: '€'), equals('€1,000'));
      });

      test('should format with custom locale and symbol', () {
        expect(1000.toCurrency(locale: 'en_US', symbol: '¥'), equals('¥1,000'));
      });

      test('should format very large currency amount', () {
        expect(999999999.toMMks(), equals('999,999,999 Ks'));
      });
    });
  });
}
