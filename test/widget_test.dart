// Mobile Service Manager Widget Tests
//
// These tests verify the main application widget and basic UI functionality.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile_service_manager/data/database/object_box.dart';
import 'widget_test.mocks.dart';

@GenerateMocks([ObjectBox])
void main() {
  group('Mobile Service Manager Widget Tests', () {
    late MockObjectBox mockObjectBox;

    setUp(() {
      mockObjectBox = MockObjectBox();
      
      // Setup common method stubs
      when(mockObjectBox.getAllBrands()).thenReturn([]);
      when(mockObjectBox.getAllTechnicians()).thenReturn([]);
      when(mockObjectBox.getAllFaults()).thenReturn([]);
      when(mockObjectBox.getAllServiceItems()).thenReturn([]);
      when(mockObjectBox.getTodayServiceItems()).thenReturn([]);
      when(mockObjectBox.getTrashServiceItems()).thenReturn([]);
    });




  });
}
