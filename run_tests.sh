#!/bin/bash

# Mobile Service Manager Test Runner Script
# This script runs all tests with proper setup and reporting

echo "Mobile Service Manager Test Suite"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
print_status "Checking Flutter version..."
flutter --version

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    print_error "Failed to get dependencies"
    exit 1
fi

# Generate mock files
print_status "Generating mock files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

if [ $? -ne 0 ]; then
    print_warning "Mock generation failed, continuing with tests..."
fi

# Run tests
print_status "Running test suite..."
echo ""

# Run all tests with coverage
flutter test --coverage

TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    print_success "All tests passed!"
    
    # Generate coverage report if available
    if command -v genhtml &> /dev/null; then
        print_status "Generating coverage report..."
        genhtml coverage/lcov.info -o coverage/html --quiet
        if [ $? -eq 0 ]; then
            print_success "Coverage report generated at coverage/html/index.html"
        fi
    else
        print_warning "genhtml not found. Install lcov to generate HTML coverage reports."
        print_status "Coverage data available at coverage/lcov.info"
    fi
    
    echo ""
    echo "Test Summary:"
    echo "- All tests passed successfully"
    echo "- Coverage data generated"
    echo "- Mock files updated"
    
else
    print_error "Some tests failed"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "1. Check test output above for specific failures"
    echo "2. Ensure all dependencies are installed: flutter pub get"
    echo "3. Generate mocks: flutter packages pub run build_runner build"
    echo "4. Run specific test files to isolate issues"
    
    exit 1
fi

echo ""
echo "Test execution completed successfully!"
echo ""
echo "Next steps:"
echo "- Review test coverage in coverage/html/index.html"
echo "- Add new tests for new features"
echo "- Run tests before committing: ./run_tests.sh"
