# Mobile Service Manager

A comprehensive Flutter-based desktop and mobile application for managing mobile device repair services. This application helps service centers track customer devices, manage repair workflows, monitor revenue, and maintain detailed service records.

## 📱 About This Project

Mobile Service Manager is designed for mobile repair shops and service centers to efficiently manage their daily operations. The application provides a complete solution for tracking customer devices, managing repair processes, monitoring revenue, and generating reports.

### Key Business Features:
- **Service Item Management**: Track customer devices with detailed information including IMEI, model, brand, and fault descriptions
- **Customer Management**: Maintain customer contact information and service history
- **Technician Assignment**: Assign repairs to specific technicians and track their workload
- **Brand & Fault Catalog**: Manage device brands and common fault types
- **Revenue Tracking**: Monitor daily, weekly, and monthly revenue with detailed analytics
- **Status Tracking**: Track repair progress from issue to delivery
- **Trash Management**: Soft delete functionality with recovery options
- **Export & Reporting**: Generate PDF and Excel reports for business analysis

## 🏗️ Architecture

### State Management
- **Flutter Riverpod**: Used for dependency injection and state management
- **Repository Pattern**: Clean separation between data access and business logic
- **Provider-based Architecture**: Modular and testable code structure

### Database
- **ObjectBox**: High-performance local NoSQL database
- **Entity Relationships**: Proper foreign key relationships between entities
- **Indexed Queries**: Optimized database queries for better performance

### Backend & Analytics
- **Firebase Integration**: Analytics and crash reporting
- **Local-first Approach**: Works offline with local data storage
- **Cross-platform**: Supports Windows, macOS, Web, and Mobile platforms

### Key Dependencies
```yaml
- flutter_riverpod: ^2.6.1    # State management
- objectbox: ^4.0.1           # Local database
- firebase_core: ^3.8.1       # Firebase integration
- firebase_analytics: ^11.3.6 # Analytics
- pdf: ^3.11.3               # PDF generation
- excel: ^4.0.6              # Excel export
- google_fonts: ^6.2.1       # Typography
```

## 🚀 Features

### Core Functionality
1. **Service Item Management**
   - Create and edit service records
   - Track customer information (name, phone)
   - Device details (brand, model, IMEI)
   - Multiple fault assignment per device
   - Expense and pricing tracking
   - SIM/SD card tracking
   - Status and location management

2. **Master Data Management**
   - **Brand Management**: Add/edit device brands
   - **Technician Management**: Manage service technicians
   - **Fault Management**: Catalog common device faults

3. **Revenue Analytics**
   - Daily revenue tracking
   - Date range filtering
   - Revenue by brand, technician, or fault type
   - Profit calculation (Revenue - Expenses)
   - Service completion statistics

4. **Advanced Features**
   - **Search & Filtering**: Advanced search across all service items
   - **Trash Management**: Soft delete with recovery options
   - **Backup & Restore**: Complete data backup/restore functionality
   - **Export Capabilities**:
     - PDF reports with professional formatting
     - Excel exports with charts and statistics
   - **Cross-platform Support**: Windows, macOS, Web, Mobile

### User Interface
- **Material Design 3**: Modern, responsive UI design
- **Navigation Rail**: Desktop-optimized navigation
- **Custom Components**: Reusable UI components
- **Multi-language Support**: Myanmar and English fonts included
- **Responsive Design**: Adapts to different screen sizes

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (>=3.4.3)
- Dart SDK
- ObjectBox code generation tools

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate ObjectBox code:
   ```bash
   flutter packages pub run build_runner build
   ```
4. Run the application:
   ```bash
   flutter run
   ```

### Platform-Specific Setup
- **Windows/macOS**: Desktop application with window management
- **Web**: PWA-ready web application
- **Mobile**: iOS and Android support

## 📊 Data Models

### Core Entities
- **ServiceItem**: Main service record with customer and device information
- **Brand**: Device manufacturers (Samsung, iPhone, etc.)
- **Technician**: Service personnel
- **Fault**: Common device issues and problems
- **Revenue**: Financial tracking and analytics

### Relationships
- ServiceItem → Brand (Many-to-One)
- ServiceItem → Technician (Many-to-One)
- ServiceItem → Fault (Many-to-Many)
- ServiceItem → Revenue (Aggregated data)

## 🔧 Technical Implementation

### State Management Flow
```
UI → Provider → Repository → ObjectBox → Database
```

### Key Services
- **BackupRestoreService**: Handles data backup and restoration
- **ServiceListPdfPrinter**: Generates professional PDF reports
- **ServiceListExcelExporter**: Creates Excel reports with analytics

### Performance Optimizations
- Background isolate processing for heavy operations
- Efficient database queries with proper indexing
- Lazy loading for large datasets
- Memory management for file operations

## 📈 Business Intelligence

The application provides comprehensive business insights:
- Revenue trends and patterns
- Technician performance metrics
- Brand popularity analysis
- Fault frequency tracking
- Customer service statistics

## 🚀 Getting Started

This project is a production-ready Flutter application designed for mobile service centers. The codebase follows Flutter best practices with clean architecture, proper state management, and comprehensive error handling.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
