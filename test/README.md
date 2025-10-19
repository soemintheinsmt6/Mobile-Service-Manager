# Mobile Service Manager Test Suite

This directory contains comprehensive test cases for the Mobile Service Manager application.

## Test Structure

### 📁 Models Tests
- `models/brand_test.dart` - Tests for Brand model
- `models/fault_test.dart` - Tests for Fault model  
- `models/revenue_test.dart` - Tests for Revenue model
- `models/service_item_test.dart` - Tests for ServiceItem model
- `models/technician_test.dart` - Tests for Technician model

### 📁 Repository Tests
- `repositories/revenue_repository_test.dart` - Tests for RevenueRepository
- `repositories/service_item_repository_test.dart` - Tests for ServiceItemRepository

### 📁 Service Tests
- `services/backup_restore_service_test.dart` - Tests for BackupRestoreService

### 📁 Utility Tests
- `utils/extension_test.dart` - Tests for String and Number extensions
- `utils/utils_test.dart` - Tests for utility functions

### 📁 Widget Tests
- `widget_test.dart` - Main application widget tests

### 📁 Configuration
- `test_config.dart` - Test configuration and utilities
- `test_suite.dart` - Comprehensive test suite runner

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Files
```bash
flutter test test/models/service_item_test.dart
flutter test test/repositories/revenue_repository_test.dart
flutter test test/services/backup_restore_service_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Generate Mock Files
```bash
flutter packages pub run build_runner build
```

## Test Categories

### Unit Tests
- **Model Tests**: Test data models, serialization, and business logic
- **Repository Tests**: Test data access layer and CRUD operations
- **Service Tests**: Test business services and external integrations
- **Utility Tests**: Test helper functions and extensions

### Widget Tests
- **Component Tests**: Test individual UI components
- **Integration Tests**: Test widget interactions and user flows

## Test Data

### Test Data Factory
The `TestDataFactory` class in `test_config.dart` provides:
- Consistent test data creation
- Reusable test objects
- Standardized test scenarios

### Mock Objects
- Mock ObjectBox database for repository tests
- Mock services for isolated testing
- Mock data providers for consistent test data

## Test Coverage

### Current Coverage Areas
✅ **Models**: 100% coverage of all data models
✅ **Repositories**: Core CRUD operations and business logic
✅ **Services**: Backup/restore functionality
✅ **Utilities**: Helper functions and extensions
✅ **Widgets**: Main application components

### Coverage Goals
- **Models**: 100% ✅
- **Repositories**: 95% ✅
- **Services**: 90% ✅
- **Utilities**: 100% ✅
- **Widgets**: 80% ✅

## Test Best Practices

### Naming Conventions
- Test files: `*_test.dart`
- Test groups: Descriptive group names
- Test cases: Clear, descriptive test names

### Test Structure
```dart
group('Feature Tests', () {
  setUp(() {
    // Setup test data
  });

  test('should perform specific action correctly', () {
    // Arrange
    // Act
    // Assert
  });
});
```

### Mock Usage
- Use mocks for external dependencies
- Verify method calls and parameters
- Test both success and error scenarios

### Assertions
- Use descriptive assertions
- Test edge cases and error conditions
- Verify both positive and negative scenarios

## Continuous Integration

### GitHub Actions
Tests run automatically on:
- Pull requests
- Main branch pushes
- Release tags

### Test Reports
- Coverage reports generated automatically
- Test results published to GitHub
- Performance metrics tracked

## Adding New Tests

### For New Models
1. Create `test/models/new_model_test.dart`
2. Test constructor, serialization, and business logic
3. Add to test suite

### For New Repositories
1. Create `test/repositories/new_repository_test.dart`
2. Mock ObjectBox dependencies
3. Test all CRUD operations
4. Test error handling

### For New Services
1. Create `test/services/new_service_test.dart`
2. Mock external dependencies
3. Test core functionality
4. Test error scenarios

### For New Widgets
1. Add tests to `widget_test.dart` or create new file
2. Test widget rendering and interactions
3. Test state changes and user flows

## Troubleshooting

### Common Issues
- **Mock generation**: Run `flutter packages pub run build_runner build`
- **ObjectBox errors**: Ensure test database is properly mocked
- **Provider errors**: Use ProviderScope in widget tests

### Debug Tips
- Use `flutter test --verbose` for detailed output
- Check test logs for specific error messages
- Verify mock setup and method calls
