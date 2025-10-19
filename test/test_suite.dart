// Comprehensive test suite for Mobile Service Manager
// This file runs all tests in the correct order

import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'models/brand_test.dart' as brand_tests;
import 'models/fault_test.dart' as fault_tests;
import 'models/revenue_test.dart' as revenue_tests;
import 'models/service_item_test.dart' as service_item_tests;
import 'models/technician_test.dart' as technician_tests;

import 'repositories/revenue_repository_test.dart' as revenue_repo_tests;
import 'repositories/service_item_repository_test.dart' as service_item_repo_tests;

import 'services/backup_restore_service_test.dart' as backup_service_tests;

import 'utils/extension_test.dart' as extension_tests;
import 'utils/utils_test.dart' as utils_tests;

import 'widget_test.dart' as widget_tests;

void main() {
  group('Mobile Service Manager Test Suite', () {
    group('Model Tests', () {
      test('Run Brand Model Tests', () {
        brand_tests.main();
      });
      
      test('Run Fault Model Tests', () {
        fault_tests.main();
      });
      
      test('Run Revenue Model Tests', () {
        revenue_tests.main();
      });
      
      test('Run ServiceItem Model Tests', () {
        service_item_tests.main();
      });
      
      test('Run Technician Model Tests', () {
        technician_tests.main();
      });
    });

    group('Repository Tests', () {
      test('Run Revenue Repository Tests', () {
        revenue_repo_tests.main();
      });
      
      test('Run ServiceItem Repository Tests', () {
        service_item_repo_tests.main();
      });
    });

    group('Service Tests', () {
      test('Run Backup Restore Service Tests', () {
        backup_service_tests.main();
      });
    });

    group('Utility Tests', () {
      test('Run Extension Tests', () {
        extension_tests.main();
      });
      
      test('Run Utils Tests', () {
        utils_tests.main();
      });
    });

    group('Widget Tests', () {
      test('Run Widget Tests', () {
        widget_tests.main();
      });
    });
  });
}
