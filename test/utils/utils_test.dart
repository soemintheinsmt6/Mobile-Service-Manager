import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_manager/core/utils/utils.dart';

void main() {
  group('Utils Tests', () {
    group('setColor function', () {
      test('should return correct color for in_progress status', () {
        final color = setColor('in_progress');
        expect(color, equals(Colors.grey.shade200));
      });

      test('should return correct color for In Progress status', () {
        final color = setColor('In Progress');
        expect(color, equals(Colors.grey.shade200));
      });

      test('should return correct color for in_store status', () {
        final color = setColor('in_store');
        expect(color, equals(Colors.grey.shade200));
      });

      test('should return correct color for In Store status', () {
        final color = setColor('In Store');
        expect(color, equals(Colors.grey.shade200));
      });

      test('should return correct color for return status', () {
        final color = setColor('return');
        expect(color, equals(Colors.red.shade300));
      });

      test('should return correct color for done status', () {
        final color = setColor('done');
        expect(color, equals(Colors.lightGreen.shade300));
      });

      test('should return correct color for delivered status', () {
        final color = setColor('delivered');
        expect(color, equals(Colors.lightGreen.shade300));
      });

      test('should return default color for unknown status', () {
        final color = setColor('unknown_status');
        expect(color, equals(Colors.grey.shade500));
      });
    });

    group('translate function', () {
      test('should translate in_progress to In Progress', () {
        expect(translate('in_progress'), equals('In Progress'));
      });

      test('should translate in_store to In Store', () {
        expect(translate('in_store'), equals('In Store'));
      });

      test('should translate delivered to Delivered', () {
        expect(translate('delivered'), equals('Delivered'));
      });

      test('should translate done to Done', () {
        expect(translate('done'), equals('Done'));
      });

      test('should translate return to Return', () {
        expect(translate('return'), equals('Return'));
      });

      test('should translate free to Free', () {
        expect(translate('free'), equals('Free'));
      });

      test('should return original string for unknown status', () {
        expect(translate('unknown_status'), equals('unknown_status'));
      });
    });

    group('store function', () {
      test('should convert In Progress to in_progress', () {
        expect(store('In Progress'), equals('in_progress'));
      });

      test('should convert In Store to in_store', () {
        expect(store('In Store'), equals('in_store'));
      });

      test('should convert Delivered to delivered', () {
        expect(store('Delivered'), equals('delivered'));
      });

      test('should convert Done to done', () {
        expect(store('Done'), equals('done'));
      });

      test('should convert Return to return', () {
        expect(store('Return'), equals('return'));
      });

      test('should convert Free to free', () {
        expect(store('Free'), equals('free'));
      });

      test('should return original string for unknown status', () {
        expect(store('unknown_status'), equals('unknown_status'));
      });
    });

    group('AlwaysDisabledFocusNode', () {
      test('should always return false for hasFocus', () {
        final focusNode = AlwaysDisabledFocusNode();
        expect(focusNode.hasFocus, equals(false));
      });

      test('should remain false even after requestFocus', () {
        final focusNode = AlwaysDisabledFocusNode();
        focusNode.requestFocus();
        expect(focusNode.hasFocus, equals(false));
      });
    });

    group('Constants', () {
      test('should have correct service status values', () {
        expect(serviceStatus, equals(['In Progress', 'Done', 'Return', 'Free']));
      });

      test('should have correct delivery status values', () {
        expect(deliveryStatus, equals(['In Store', 'Delivered']));
      });
    });
  });
}
