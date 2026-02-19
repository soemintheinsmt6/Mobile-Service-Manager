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

## 📂 Project Folder Structure

The project follows a **Simplified Layered Clean Architecture** with three main layers:

```
lib/
├── core/                                  # Shared app-wide utilities & constants
│   ├── constants/
│   │   ├── app_colors.dart                # App color palette
│   │   └── constants.dart                 # Text styles & layout constants
│   └── utils/
│       ├── alert.dart                     # Error message overlay
│       ├── date_time_picker.dart          # Date picker helper
│       ├── decoration.dart                # Input decoration helpers
│       ├── dialog.dart                    # Custom dialog builder
│       ├── extension.dart                 # String, int formatting extensions
│       └── utils.dart                     # Status helpers, URL launcher
│
├── data/                                  # Data layer (models, DB, repos, services)
│   ├── database/
│   │   └── object_box.dart                # ObjectBox store & CRUD operations
│   ├── models/
│   │   ├── brand.dart                     # Brand entity
│   │   ├── fault.dart                     # Fault entity
│   │   ├── item.dart                      # Abstract Item interface
│   │   ├── revenue.dart                   # Revenue data model
│   │   ├── service_item.dart              # ServiceItem entity (core)
│   │   └── technician.dart                # Technician entity
│   ├── repositories/
│   │   ├── brand_repository.dart          # Brand data access
│   │   ├── fault_repository.dart          # Fault data access
│   │   ├── revenue_repository.dart        # Revenue calculations
│   │   ├── service_item_repository.dart   # Service item queries & CRUD
│   │   └── technician_repository.dart     # Technician data access
│   └── services/
│       ├── backup_restore_service.dart     # Data backup & restore
│       ├── service_list_excel_exporter.dart # Excel report generation
│       └── service_list_pdf_printer.dart   # PDF report generation
│
├── l10n/                                  # Localization (ARB translation files)
│   ├── app_en.arb                         # English translations (template)
│   └── app_my.arb                         # Myanmar translations
│
├── presentation/                          # UI layer (providers, screens, widgets)
│   ├── providers/
│   │   ├── brand_provider.dart            # Brand state notifier
│   │   ├── fault_provider.dart            # Fault state notifier
│   │   ├── locale_provider.dart           # Locale state management
│   │   ├── object_box_provider.dart       # ObjectBox DI provider
│   │   ├── repository_providers.dart      # Repository DI providers
│   │   ├── revenue_provider.dart          # Revenue state notifier
│   │   ├── service_item_provider.dart     # Service item state notifier
│   │   ├── technician_provider.dart       # Technician state notifier
│   │   └── trash_service_item_provider.dart # Trash state notifier
│   ├── screens/
│   │   ├── brand_list_screen.dart         # Brand management
│   │   ├── edit_service_item_screen.dart  # Edit service item
│   │   ├── fault_list_screen.dart         # Fault management
│   │   ├── revenue_screen.dart            # Revenue analytics
│   │   ├── search_service_items_screen.dart # Advanced search
│   │   ├── service_item_form.dart         # Create service item form
│   │   ├── service_item_list_screen.dart  # Service item list (main)
│   │   ├── setting_screen.dart            # App settings & language switcher
│   │   ├── technician_list_screen.dart    # Technician management
│   │   └── trash_list_screen.dart         # Trash / recycle bin
│   └── widgets/
│       ├── buttons/
│       │   ├── bar_button.dart            # Bar action button
│       │   ├── custom_icon_button.dart    # Icon button
│       │   ├── dismiss_button.dart        # Dismiss button
│       │   ├── radio_button.dart          # Radio selection button
│       │   └── right_elevated_button.dart # Right-aligned button
│       ├── text_fields/
│       │   ├── custom_date_picker_text_field.dart
│       │   ├── custom_drop_down_text_field.dart
│       │   ├── custom_multi_select_drop_down_text_field.dart
│       │   ├── custom_text_field.dart
│       │   └── custom_text_form_field.dart
│       ├── add_new_item.dart              # Add item dialog
│       ├── custom_check_box.dart          # Custom checkbox
│       ├── glass_box.dart                 # Glassmorphism container
│       ├── glass_container.dart           # Glass container variant
│       ├── info_card.dart                 # Information display card
│       ├── item_card.dart                 # Generic item card
│       ├── revenue_card.dart              # Revenue display card
│       ├── service_tile.dart              # Service item tile
│       ├── technician_list_item.dart      # Technician list tile
│       └── update_item.dart               # Update item dialog
│
├── main.dart                              # App entry point
├── firebase_options.dart                  # Firebase config
├── objectbox.g.dart                       # ObjectBox generated code
└── objectbox-model.json                   # ObjectBox schema
```

### Layer Dependencies
```
┌──────────────┐
│ presentation │ ──→ data, core
├──────────────┤
│     data     │ ──→ core
├──────────────┤
│     core     │ ──→ (no internal dependencies)
└──────────────┘
```

### Key Dependencies
```yaml
- flutter_riverpod: ^2.6.1        # State management
- flutter_localizations (SDK)     # Internationalization support
- objectbox: ^4.0.1               # Local database
- firebase_core: ^3.8.1           # Firebase integration
- firebase_analytics: ^11.3.6     # Analytics
- pdf: ^3.11.3                   # PDF generation
- excel: ^4.0.6                  # Excel export
- google_fonts: ^6.2.1           # Typography
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
- **Multi-language Support**: Full localization for English and Myanmar (Burmese)
- **Runtime Language Switching**: Change language on-the-fly from Settings
- **Responsive Design**: Adapts to different screen sizes

## 🌍 Localization

The application is fully localized using Flutter's built-in internationalization (`gen_l10n`) system, supporting runtime language switching.

### Supported Languages
| Language | Locale Code | ARB File |
|----------|-------------|----------|
| English | `en` | `lib/l10n/app_en.arb` (template) |
| Myanmar (Burmese) | `my` | `lib/l10n/app_my.arb` |

### How It Works
- **ARB Files**: Translation strings are defined in Application Resource Bundle (`.arb`) files located in `lib/l10n/`
- **Code Generation**: Flutter's `gen_l10n` tool auto-generates the `AppLocalizations` class from the ARB files
- **Configuration**: Localization settings are defined in `l10n.yaml` at the project root
- **Runtime Switching**: Users can switch languages from the **Settings** screen via a dropdown, managed by `localeProvider`

### Adding a New Translation String
1. Add the key-value pair to `lib/l10n/app_en.arb` (the template file)
2. Add the corresponding translation to `lib/l10n/app_my.arb`
3. Run the app or execute `flutter gen-l10n` to regenerate the localization files
4. Use the string in code:
   ```dart
   final t = AppLocalizations.of(context)!;
   Text(t.yourNewKey);
   ```

### Adding a New Locale
1. Create a new ARB file: `lib/l10n/app_<locale_code>.arb`
2. Add translations for all keys from `app_en.arb`
3. Add the new `Locale` to the dropdown in `setting_screen.dart`
4. Regenerate with `flutter gen-l10n`

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
