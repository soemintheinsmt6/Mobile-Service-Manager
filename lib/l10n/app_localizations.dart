import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('my')
  ];

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a backup of all your data including brands, technicians, faults, and service items.'**
  String get backupDescription;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Error creating backup:'**
  String get backupError;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully at:'**
  String get backupSuccess;

  /// No description provided for @bin.
  ///
  /// In en, this message translates to:
  /// **'Bin'**
  String get bin;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @brandEmpty.
  ///
  /// In en, this message translates to:
  /// **'Brand is empty'**
  String get brandEmpty;

  /// No description provided for @burmese.
  ///
  /// In en, this message translates to:
  /// **'မြန်မာ'**
  String get burmese;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get confirmRestore;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @customerNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Customer Name is empty'**
  String get customerNameEmpty;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dateType.
  ///
  /// In en, this message translates to:
  /// **'Date Type'**
  String get dateType;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get deliveryDate;

  /// No description provided for @deliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Delivery Status'**
  String get deliveryStatus;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorFieldEmpty.
  ///
  /// In en, this message translates to:
  /// **'Error field is empty'**
  String get errorFieldEmpty;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// No description provided for @fromDateRequired.
  ///
  /// In en, this message translates to:
  /// **'From Date is needed to fill'**
  String get fromDateRequired;

  /// No description provided for @imei.
  ///
  /// In en, this message translates to:
  /// **'IMEI'**
  String get imei;

  /// No description provided for @invoiceId.
  ///
  /// In en, this message translates to:
  /// **'Invoice ID'**
  String get invoiceId;

  /// No description provided for @invoiceIdInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invoice ID is invalid'**
  String get invoiceIdInvalid;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @itemsPerPage.
  ///
  /// In en, this message translates to:
  /// **'{count} items per page |'**
  String itemsPerPage(Object count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @mergeData.
  ///
  /// In en, this message translates to:
  /// **'Merge Data'**
  String get mergeData;

  /// No description provided for @mergeWarning.
  ///
  /// In en, this message translates to:
  /// **'This will merge the backup data with existing data. Are you sure?'**
  String get mergeWarning;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @modelEmpty.
  ///
  /// In en, this message translates to:
  /// **'Model is empty'**
  String get modelEmpty;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get no;

  /// No description provided for @noDateSelected.
  ///
  /// In en, this message translates to:
  /// **'No Date Selected'**
  String get noDateSelected;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNo.
  ///
  /// In en, this message translates to:
  /// **'Phone No.'**
  String get phoneNo;

  /// No description provided for @pleaseAddSpecificDate.
  ///
  /// In en, this message translates to:
  /// **'Please add Specific date'**
  String get pleaseAddSpecificDate;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @replaceAllData.
  ///
  /// In en, this message translates to:
  /// **'Replace All Data'**
  String get replaceAllData;

  /// No description provided for @replaceWarning.
  ///
  /// In en, this message translates to:
  /// **'This will replace all current data with the backup data. Are you sure?'**
  String get replaceWarning;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @restoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore data from a backup file. This will replace/merge your current data.'**
  String get restoreDescription;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Error restoring backup:'**
  String get restoreError;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get restoreSuccess;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'results'**
  String get results;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @serviceList.
  ///
  /// In en, this message translates to:
  /// **'Service List'**
  String get serviceList;

  /// No description provided for @serviceStatus.
  ///
  /// In en, this message translates to:
  /// **'Service Status'**
  String get serviceStatus;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get settings;

  /// No description provided for @specificDate.
  ///
  /// In en, this message translates to:
  /// **'Specific Date'**
  String get specificDate;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @technician.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get technician;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// No description provided for @toDateRequired.
  ///
  /// In en, this message translates to:
  /// **'To Date is needed to fill'**
  String get toDateRequired;

  /// No description provided for @addBrand.
  ///
  /// In en, this message translates to:
  /// **'Add Brand'**
  String get addBrand;

  /// No description provided for @addError.
  ///
  /// In en, this message translates to:
  /// **'Add Error'**
  String get addError;

  /// No description provided for @addTechnician.
  ///
  /// In en, this message translates to:
  /// **'Add Technician'**
  String get addTechnician;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @revenueReport.
  ///
  /// In en, this message translates to:
  /// **'Revenue Report'**
  String get revenueReport;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available for selected date(s)'**
  String get noDataAvailable;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @fromDateToDate.
  ///
  /// In en, this message translates to:
  /// **'From Date - To Date'**
  String get fromDateToDate;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @deletedServiceList.
  ///
  /// In en, this message translates to:
  /// **'Deleted Service List'**
  String get deletedServiceList;

  /// No description provided for @rowsPerPage.
  ///
  /// In en, this message translates to:
  /// **'Rows per page'**
  String get rowsPerPage;

  /// No description provided for @deliveryDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date is needed to fill'**
  String get deliveryDateRequired;

  /// No description provided for @byLabel.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get byLabel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @returnStatus.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnStatus;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @inStore.
  ///
  /// In en, this message translates to:
  /// **'In Store'**
  String get inStore;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @profitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin'**
  String get profitMargin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'my':
      return AppLocalizationsMy();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
