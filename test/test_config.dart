import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile_service_manager/data/database/object_box.dart';
import 'package:mobile_service_manager/data/models/brand.dart';
import 'package:mobile_service_manager/data/models/fault.dart';
import 'package:mobile_service_manager/data/models/service_item.dart';
import 'package:mobile_service_manager/data/models/technician.dart';
import 'package:objectbox/objectbox.dart';

import 'test_config.mocks.dart';

// Generate mocks for all test files
@GenerateMocks([
  ObjectBox,
  Store,
])
void main() {
  // This file serves as a configuration for mock generation
  // Run: flutter packages pub run build_runner build
  // to generate mock files
}

/// Test data factories for creating consistent test objects
class TestDataFactory {
  static Brand createBrand({int id = 1, String name = 'Test Brand'}) {
    return Brand(id: id, name: name);
  }

  static Technician createTechnician({int id = 1, String name = 'Test Technician'}) {
    return Technician(id: id, name: name);
  }

  static Fault createFault({int id = 1, String name = 'Test Fault'}) {
    return Fault(id: id, name: name);
  }

  static ServiceItem createServiceItem({
    int id = 1,
    int invoiceId = 123,
    String customerName = 'Test Customer',
    String phoneNumber = '09123456789',
    String model = 'Test Model',
    String imei = '123456789012345',
    String issueDate = '2024-01-15',
    String? deliveryDate,
    int? expense,
    int? servicePrice,
    bool simIncluded = false,
    bool sdIncluded = false,
    String? remark,
    String status = 'in_progress',
    String location = 'in_store',
    bool isTrash = false,
  }) {
    return ServiceItem(
      id: id,
      invoiceId: invoiceId,
      customerName: customerName,
      phoneNumber: phoneNumber,
      model: model,
      imei: imei,
      issueDate: issueDate,
      deliveryDate: deliveryDate,
      expense: expense,
      servicePrice: servicePrice,
      simIncluded: simIncluded,
      sdIncluded: sdIncluded,
      remark: remark,
      status: status,
      location: location,
      isTrash: isTrash,
    );
  }

  static List<Brand> createBrandList() {
    return [
      createBrand(id: 1, name: 'Samsung'),
      createBrand(id: 2, name: 'iPhone'),
      createBrand(id: 3, name: 'Huawei'),
    ];
  }

  static List<Technician> createTechnicianList() {
    return [
      createTechnician(id: 1, name: 'John Doe'),
      createTechnician(id: 2, name: 'Jane Smith'),
      createTechnician(id: 3, name: 'Mike Johnson'),
    ];
  }

  static List<Fault> createFaultList() {
    return [
      createFault(id: 1, name: 'Screen Crack'),
      createFault(id: 2, name: 'Battery Issue'),
      createFault(id: 3, name: 'Water Damage'),
      createFault(id: 4, name: 'Software Issue'),
    ];
  }

  static List<ServiceItem> createServiceItemList() {

    return [
      createServiceItem(
        id: 1,
        invoiceId: 123,
        customerName: 'Customer 1',
        servicePrice: 100000,
        expense: 50000,
        status: 'done',
        location: 'delivered',
      ),
      createServiceItem(
        id: 2,
        invoiceId: 124,
        customerName: 'Customer 2',
        servicePrice: 80000,
        expense: 40000,
        status: 'in_progress',
        location: 'in_store',
      ),
      createServiceItem(
        id: 3,
        invoiceId: 125,
        customerName: 'Customer 3',
        servicePrice: 0,
        expense: 30000,
        status: 'return',
        location: 'in_store',
      ),
    ];
  }
}

/// Test utilities for common test operations
class TestUtils {
  /// Verify that a method was called with specific parameters
  /// Note: This method is kept for future use but not currently implemented
  /// to avoid type conflicts with nullable parameters
  static void verifyMethodCall<T>(
    Box<T> mockBox,
    String methodName,
    List<dynamic> expectedParams,
  ) {
    // Implementation removed to avoid type conflicts
    // Use direct verify() calls in tests instead
    throw UnimplementedError('Use direct verify() calls in tests instead');
  }

  /// Create a mock ObjectBox with basic setup
  static MockObjectBox createMockObjectBox() {
    final mockObjectBox = MockObjectBox();
    
    // Setup basic method stubs to avoid MissingStubError
    when(mockObjectBox.getAllBrands()).thenReturn([]);
    when(mockObjectBox.getAllTechnicians()).thenReturn([]);
    when(mockObjectBox.getAllFaults()).thenReturn([]);
    when(mockObjectBox.getAllServiceItems()).thenReturn([]);
    when(mockObjectBox.getTrashServiceItems()).thenReturn([]);
    when(mockObjectBox.getTodayServiceItems()).thenReturn([]);

    return mockObjectBox;
  }

  /// Setup mock returns for common operations
  static void setupCommonMocks(MockObjectBox mockObjectBox) {
    when(mockObjectBox.getAllBrands()).thenReturn([]);
    when(mockObjectBox.getAllTechnicians()).thenReturn([]);
    when(mockObjectBox.getAllFaults()).thenReturn([]);
    when(mockObjectBox.getAllServiceItems()).thenReturn([]);
    when(mockObjectBox.getTrashServiceItems()).thenReturn([]);
    when(mockObjectBox.getTodayServiceItems()).thenReturn([]);
  }
}

/// Custom matchers for test assertions
class CustomMatchers {
  /// Matcher for checking if a date is today
  static Matcher isToday() {
    return predicate<DateTime>((date) {
      final now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }, 'is today');
  }

  /// Matcher for checking if a string is a valid IMEI format
  static Matcher isValidImei() {
    return predicate<String>((imei) {
      return imei.length == 15 && RegExp(r'^\d+$').hasMatch(imei);
    }, 'is valid IMEI');
  }

  /// Matcher for checking if a string is a valid phone number format
  static Matcher isValidPhoneNumber() {
    return predicate<String>((phone) {
      return RegExp(r'^09\d{9}$').hasMatch(phone);
    }, 'is valid Myanmar phone number');
  }
}

// Mock classes are generated by Mockito based on @GenerateMocks annotation
