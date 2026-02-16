import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../database/object_box.dart';
import '../models/brand.dart';
import '../models/fault.dart';
import '../models/service_item.dart';
import '../models/technician.dart';

class BackupRestoreService {
  final ObjectBox _box;

  BackupRestoreService(this._box);

  /// Creates a complete backup of all data
  Future<String?> createBackup() async {
    try {
      // Get all data first (this is fast enough to run on main thread)
      final brands = _box.getAllBrands();
      final technicians = _box.getAllTechnicians();
      final faults = _box.getAllFaults();
      final serviceItems = _box.getAllServiceItems();

      // Run the heavy JSON conversion in the background
      final backupData = await compute(_convertToBackupData, {
        'brands': brands.map((b) => b.toJson()).toList(),
        'technicians': technicians.map((t) => t.toJson()).toList(),
        'faults': faults.map((f) => f.toJson()).toList(),
        'serviceItems': serviceItems.map((s) => s.toJson()).toList(),
      });

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Get file path for saving
      final DateFormat format = DateFormat('yyyy_MMM_dd_h_mm_a');
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName:
            'mobile_service_manager_backup_${format.format(DateTime.now())}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        String finalPath = result;
        if (!finalPath.toLowerCase().endsWith('.json')) {
          finalPath = '$finalPath.json';
        }

        final file = File(finalPath);
        await file.writeAsString(jsonString);
        return finalPath;
      }

      return null;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
    }
  }

  /// Background function to convert data to backup format
  static Map<String, dynamic> _convertToBackupData(Map<String, dynamic> data) {
    return {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };
  }

  /// Restore data from a backup file
  Future<bool> restoreFromBackup(
      {bool clearExisting = true, Function(String)? onProgress}) async {
    try {
      onProgress?.call('Selecting backup file...');

      // Pick backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Backup File',
      );

      if (result != null && result.files.single.path != null) {
        onProgress?.call('Reading backup file...');
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        // Parse JSON in background to avoid blocking UI
        onProgress?.call('Parsing backup data...');
        final backupData = await compute(_parseBackupData, jsonString);

        // Perform the actual restore operations with periodic yielding
        return await _restoreFromJsonStringWithYielding(
            backupData, clearExisting, onProgress);
      }

      return false;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      rethrow;
    }
  }

  /// Background function to parse backup data
  static Map<String, dynamic> _parseBackupData(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Restores data from parsed backup data with periodic yielding to prevent UI freeze
  Future<bool> _restoreFromJsonStringWithYielding(
      Map<String, dynamic> backupData,
      bool clearExisting,
      Function(String)? onProgress) async {
    try {
      final data = backupData['data'] as Map<String, dynamic>;

      if (clearExisting) {
        // Clear existing data and use simple restore
        await _clearAllData();
        return await _restoreWithClearDataYielding(data, onProgress);
      } else {
        // Merge data with duplicate detection
        return await _mergeDataWithDuplicateDetectionYielding(data, onProgress);
      }
    } catch (e) {
      debugPrint('Error in restore process: $e');
      rethrow;
    }
  }

  /// Simple restore for cleared database with periodic yielding
  Future<bool> _restoreWithClearDataYielding(
      Map<String, dynamic> data, Function(String)? onProgress) async {
    try {
      onProgress?.call('Clearing existing data...');

      // Create ID mapping for relationships
      final Map<int, int> brandIdMap = {};
      final Map<int, int> technicianIdMap = {};
      final Map<int, int> faultIdMap = {};

      // Restore brands with yielding
      onProgress?.call('Restoring brands...');
      final brandsData = data['brands'] as List<dynamic>;
      for (int i = 0; i < brandsData.length; i++) {
        final brandJson = brandsData[i];
        final oldId = brandJson['id'] as int;
        final brand = Brand.fromJson(brandJson);
        brand.id = 0; // Reset ID
        final newId = _box.brandBox.put(brand);
        brandIdMap[oldId] = newId;

        // Yield control every 5 items to keep UI responsive
        if (i % 5 == 0) {
          await Future.delayed(Duration.zero); // Yield to event loop
          onProgress?.call('Restoring brands... ${i + 1}/${brandsData.length}');
        }
      }

      // Restore technicians with yielding
      onProgress?.call('Restoring technicians...');
      final techniciansData = data['technicians'] as List<dynamic>;
      for (int i = 0; i < techniciansData.length; i++) {
        final technicianJson = techniciansData[i];
        final oldId = technicianJson['id'] as int;
        final technician = Technician.fromJson(technicianJson);
        technician.id = 0; // Reset ID
        final newId = _box.technicianBox.put(technician);
        technicianIdMap[oldId] = newId;

        // Yield control every 5 items
        if (i % 5 == 0) {
          await Future.delayed(Duration.zero);
          onProgress?.call(
              'Restoring technicians... ${i + 1}/${techniciansData.length}');
        }
      }

      // Restore faults with yielding
      onProgress?.call('Restoring faults...');
      final faultsData = data['faults'] as List<dynamic>;
      for (int i = 0; i < faultsData.length; i++) {
        final faultJson = faultsData[i];
        final oldId = faultJson['id'] as int;
        final fault = Fault.fromJson(faultJson);
        fault.id = 0; // Reset ID
        final newId = _box.faultBox.put(fault);
        faultIdMap[oldId] = newId;

        // Yield control every 5 items
        if (i % 5 == 0) {
          await Future.delayed(Duration.zero);
          onProgress?.call('Restoring faults... ${i + 1}/${faultsData.length}');
        }
      }

      // Restore service items with yielding
      onProgress?.call('Restoring service items...');
      final serviceItemsData = data['serviceItems'] as List<dynamic>;
      for (int i = 0; i < serviceItemsData.length; i++) {
        final itemData = serviceItemsData[i];
        await _restoreServiceItem(
            itemData, brandIdMap, technicianIdMap, faultIdMap);

        // Yield control every 3 items (service items are more complex)
        if (i % 3 == 0) {
          await Future.delayed(Duration.zero);
          onProgress?.call(
              'Restoring service items... ${i + 1}/${serviceItemsData.length}');
        }
      }

      onProgress?.call('Restore completed successfully!');
      return true;
    } catch (e) {
      debugPrint('Error in clear restore: $e');
      rethrow;
    }
  }

  /// Advanced merge with duplicate detection and periodic yielding
  Future<bool> _mergeDataWithDuplicateDetectionYielding(
      Map<String, dynamic> data, Function(String)? onProgress) async {
    try {
      onProgress?.call('Analyzing existing data...');

      // Get existing data for duplicate detection
      final existingBrands = _box.getAllBrands();
      final existingTechnicians = _box.getAllTechnicians();
      final existingFaults = _box.getAllFaults();
      final existingServiceItems = _box.getAllServiceItems();

      // Create maps for duplicate detection and ID mapping
      final Map<int, int> brandIdMap = {};
      final Map<int, int> technicianIdMap = {};
      final Map<int, int> faultIdMap = {};

      // Fix ObjectBox ID sequences first
      onProgress?.call('Preparing ID sequences...');
      await _fixIdSequences(data);
      await Future.delayed(Duration.zero); // Yield after sequence fix

      // Merge brands with duplicate detection and yielding
      onProgress?.call('Merging brands...');
      final brandsData = data['brands'] as List<dynamic>;
      for (int i = 0; i < brandsData.length; i++) {
        final brandJson = brandsData[i];
        final oldId = brandJson['id'] as int;
        final brandName = brandJson['name'] as String;

        // Check for existing brand by name
        final existingBrand = existingBrands.cast<Brand?>().firstWhere(
              (b) => b?.name.toLowerCase() == brandName.toLowerCase(),
              orElse: () => null,
            );

        if (existingBrand != null) {
          // Use existing brand
          brandIdMap[oldId] = existingBrand.id;
        } else {
          // Create new brand
          final brand = Brand.fromJson(brandJson);
          brand.id = 0; // Let ObjectBox assign ID
          final newId = _box.brandBox.put(brand);
          brandIdMap[oldId] = newId;
        }

        // Yield control every 5 items
        if (i % 5 == 0) {
          await Future.delayed(Duration.zero);
          onProgress?.call('Merging brands... ${i + 1}/${brandsData.length}');
        }
      }

      // Merge technicians with duplicate detection and yielding
      onProgress?.call('Merging technicians...');
      final techniciansData = data['technicians'] as List<dynamic>;
      for (int i = 0; i < techniciansData.length; i++) {
        final technicianJson = techniciansData[i];
        final oldId = technicianJson['id'] as int;
        final technicianName = technicianJson['name'] as String;

        // Check for existing technician by name
        final existingTechnician =
            existingTechnicians.cast<Technician?>().firstWhere(
                  (t) => t?.name.toLowerCase() == technicianName.toLowerCase(),
                  orElse: () => null,
                );

        if (existingTechnician != null) {
          // Use existing technician
          technicianIdMap[oldId] = existingTechnician.id;
        } else {
          // Create new technician
          final technician = Technician.fromJson(technicianJson);
          technician.id = 0; // Let ObjectBox assign ID
          final newId = _box.technicianBox.put(technician);
          technicianIdMap[oldId] = newId;
        }

        // Yield control every 5 items
        if (i % 5 == 0) {
          await Future.delayed(Duration.zero);
          onProgress?.call(
              'Merging technicians... ${i + 1}/${techniciansData.length}');
        }
      }

      // Merge faults with duplicate detection and yielding
      onProgress?.call('Merging faults...');
      final faultsData = data['faults'] as List<dynamic>;
      for (int i = 0; i < faultsData.length; i++) {
        final faultJson = faultsData[i];
        final oldId = faultJson['id'] as int;
        final faultName = faultJson['name'] as String;

        // Check for existing fault by name
        final existingFault = existingFaults.cast<Fault?>().firstWhere(
              (f) => f?.name.toLowerCase() == faultName.toLowerCase(),
              orElse: () => null,
            );

        if (existingFault != null) {
          // Use existing fault
          faultIdMap[oldId] = existingFault.id;
        } else {
          // Create new fault
          final fault = Fault.fromJson(faultJson);
          fault.id = 0; // Let ObjectBox assign ID
          final newId = _box.faultBox.put(fault);
          faultIdMap[oldId] = newId;
        }

        // Yield control every 5 items
        if (i % 5 == 0) {
          await Future.delayed(Duration.zero);
          onProgress?.call('Merging faults... ${i + 1}/${faultsData.length}');
        }
      }

      // Merge service items with duplicate detection and yielding
      onProgress?.call('Merging service items...');
      final serviceItemsData = data['serviceItems'] as List<dynamic>;
      for (int i = 0; i < serviceItemsData.length; i++) {
        final itemData = serviceItemsData[i];
        await _mergeServiceItem(itemData, brandIdMap, technicianIdMap,
            faultIdMap, existingServiceItems);

        // Yield control every 3 items (service items are more complex)
        if (i % 3 == 0) {
          await Future.delayed(Duration.zero);
          onProgress?.call(
              'Merging service items... ${i + 1}/${serviceItemsData.length}');
        }
      }

      onProgress?.call('Merge completed successfully!');
      return true;
    } catch (e) {
      debugPrint('Error in merge: $e');
      rethrow;
    }
  }

  /// Fix ObjectBox ID sequences to prevent conflicts
  Future<void> _fixIdSequences(Map<String, dynamic> data) async {
    try {
      // Get highest IDs from backup data
      int maxBrandId = 0;
      int maxTechnicianId = 0;
      int maxFaultId = 0;
      int maxServiceItemId = 0;

      final brandsData = data['brands'] as List<dynamic>;
      for (final brand in brandsData) {
        final id = brand['id'] as int;
        if (id > maxBrandId) maxBrandId = id;
      }

      final techniciansData = data['technicians'] as List<dynamic>;
      for (final technician in techniciansData) {
        final id = technician['id'] as int;
        if (id > maxTechnicianId) maxTechnicianId = id;
      }

      final faultsData = data['faults'] as List<dynamic>;
      for (final fault in faultsData) {
        final id = fault['id'] as int;
        if (id > maxFaultId) maxFaultId = id;
      }

      final serviceItemsData = data['serviceItems'] as List<dynamic>;
      for (final item in serviceItemsData) {
        final id = item['id'] as int;
        if (id > maxServiceItemId) maxServiceItemId = id;
      }

      // Create dummy objects to advance ID sequences if needed
      if (maxBrandId > 0) {
        final dummyBrand = Brand(name: '__temp_sequence_fix__');
        final tempId = _box.brandBox.put(dummyBrand);
        _box.brandBox.remove(tempId);

        // If the assigned ID is less than maxBrandId, we need to advance the sequence
        if (tempId <= maxBrandId) {
          for (int i = tempId; i <= maxBrandId; i++) {
            final temp = Brand(name: '__temp_$i');
            _box.brandBox.put(temp);
            _box.brandBox.remove(temp.id);

            // Yield periodically during sequence fixing
            if (i % 10 == 0) {
              await Future.delayed(Duration.zero);
            }
          }
        }
      }

      // Repeat for other entities with yielding
      if (maxTechnicianId > 0) {
        final dummyTech = Technician(name: '__temp_sequence_fix__');
        final tempId = _box.technicianBox.put(dummyTech);
        _box.technicianBox.remove(tempId);

        if (tempId <= maxTechnicianId) {
          for (int i = tempId; i <= maxTechnicianId; i++) {
            final temp = Technician(name: '__temp_$i');
            _box.technicianBox.put(temp);
            _box.technicianBox.remove(temp.id);

            if (i % 10 == 0) {
              await Future.delayed(Duration.zero);
            }
          }
        }
      }

      if (maxFaultId > 0) {
        final dummyFault = Fault(name: '__temp_sequence_fix__');
        final tempId = _box.faultBox.put(dummyFault);
        _box.faultBox.remove(tempId);

        if (tempId <= maxFaultId) {
          for (int i = tempId; i <= maxFaultId; i++) {
            final temp = Fault(name: '__temp_$i');
            _box.faultBox.put(temp);
            _box.faultBox.remove(temp.id);

            if (i % 10 == 0) {
              await Future.delayed(Duration.zero);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fixing ID sequences: $e');
      // Continue with merge even if sequence fix fails
    }
  }

  /// Merge a single ServiceItem with duplicate detection
  Future<void> _mergeServiceItem(
    Map<String, dynamic> data,
    Map<int, int> brandIdMap,
    Map<int, int> technicianIdMap,
    Map<int, int> faultIdMap,
    List<ServiceItem> existingServiceItems,
  ) async {
    // Extract data for comprehensive duplicate checking
    final invoiceId = data['invoiceId'] as int;
    final customerName = (data['customerName'] as String).toLowerCase().trim();
    final model = (data['model'] as String).toLowerCase().trim();
    final issueDate = data['issueDate'] as String;
    final oldBrandId = data['brandId'] as int?;
    final oldFaultIds = (data['faultIds'] as List<dynamic>?)?.cast<int>() ?? [];

    // Get the brand name for comparison
    String? brandName;
    if (oldBrandId != null && brandIdMap.containsKey(oldBrandId)) {
      final brand = _box.brandBox.get(brandIdMap[oldBrandId]!);
      brandName = brand?.name.toLowerCase().trim();
    }

    // Get fault names for comparison
    final Set<String> faultNames = {};
    for (final oldFaultId in oldFaultIds) {
      if (faultIdMap.containsKey(oldFaultId)) {
        final fault = _box.faultBox.get(faultIdMap[oldFaultId]!);
        if (fault != null) {
          faultNames.add(fault.name.toLowerCase().trim());
        }
      }
    }

    // Check for duplicate service item using comprehensive comparison
    final existingItem = existingServiceItems.cast<ServiceItem?>().firstWhere(
      (item) {
        if (item == null) return false;

        // Check basic fields
        final matchesInvoiceId = item.invoiceId == invoiceId;
        final matchesCustomerName =
            item.customerName.toLowerCase().trim() == customerName;
        final matchesModel = item.model.toLowerCase().trim() == model;
        final matchesIssueDate = item.issueDate == issueDate;

        // Check brand
        final existingBrandName = item.brand.target?.name.toLowerCase().trim();
        final matchesBrand = (brandName == null && existingBrandName == null) ||
            (brandName != null && existingBrandName == brandName);

        // Check faults - compare sets of fault names
        final existingFaultNames =
            item.faults.map((f) => f.name.toLowerCase().trim()).toSet();
        final matchesFaults = faultNames.length == existingFaultNames.length &&
            faultNames.every((name) => existingFaultNames.contains(name));

        // Return true if all criteria match
        return matchesInvoiceId &&
            matchesCustomerName &&
            matchesModel &&
            matchesIssueDate &&
            matchesBrand &&
            matchesFaults;
      },
      orElse: () => null,
    );

    if (existingItem != null) {
      debugPrint(
          'Skipping duplicate service item: Invoice $invoiceId, Customer: ${data['customerName']}, Model: ${data['model']}, Brand: $brandName');
      return; // Skip this item as it already exists
    }

    // Create new service item
    final serviceItem = ServiceItem(
      id: data['id'] as int,
      // Keep original ID since we fixed the sequence
      invoiceId: invoiceId,
      customerName: data['customerName'] as String,
      phoneNumber: data['phoneNumber'] as String,
      model: data['model'] as String,
      imei: data['imei'] as String,
      issueDate: issueDate,
      deliveryDate: data['deliveryDate'] as String?,
      expense: data['expense'] as int?,
      servicePrice: data['servicePrice'] as int?,
      simIncluded: data['simIncluded'] as bool? ?? false,
      sdIncluded: data['sdIncluded'] as bool? ?? false,
      remark: data['remark'] as String?,
      status: data['status'] as String? ?? 'in_progress',
      location: data['location'] as String? ?? 'in_store',
      isTrash: data['isTrash'] as bool? ?? false,
    );

    // Set relationships using mapped IDs
    if (oldBrandId != null && brandIdMap.containsKey(oldBrandId)) {
      final newBrandId = brandIdMap[oldBrandId]!;
      final brand = _box.brandBox.get(newBrandId);
      if (brand != null) {
        serviceItem.brand.target = brand;
      }
    }

    final oldTechnicianId = data['technicianId'] as int?;
    if (oldTechnicianId != null &&
        technicianIdMap.containsKey(oldTechnicianId)) {
      final newTechnicianId = technicianIdMap[oldTechnicianId]!;
      final technician = _box.technicianBox.get(newTechnicianId);
      if (technician != null) {
        serviceItem.technician.target = technician;
      }
    }

    // Put the service item
    _box.serviceItemBox.put(serviceItem);

    // Set fault relationships
    final newFaults = <Fault>[];
    for (final oldFaultId in oldFaultIds) {
      if (faultIdMap.containsKey(oldFaultId)) {
        final newFaultId = faultIdMap[oldFaultId]!;
        final fault = _box.faultBox.get(newFaultId);
        if (fault != null) {
          newFaults.add(fault);
        }
      }
    }
    serviceItem.setFaults(newFaults);

    // Update with relationships
    _box.serviceItemBox.put(serviceItem);
  }

  /// Restores a single ServiceItem with updated relationships (for clear restore)
  Future<void> _restoreServiceItem(
    Map<String, dynamic> data,
    Map<int, int> brandIdMap,
    Map<int, int> technicianIdMap,
    Map<int, int> faultIdMap,
  ) async {
    final serviceItem = ServiceItem(
      id: 0,
      // Reset ID for clear restore
      invoiceId: data['invoiceId'] as int,
      customerName: data['customerName'] as String,
      phoneNumber: data['phoneNumber'] as String,
      model: data['model'] as String,
      imei: data['imei'] as String,
      issueDate: data['issueDate'] as String,
      deliveryDate: data['deliveryDate'] as String?,
      expense: data['expense'] as int?,
      servicePrice: data['servicePrice'] as int?,
      simIncluded: data['simIncluded'] as bool? ?? false,
      sdIncluded: data['sdIncluded'] as bool? ?? false,
      remark: data['remark'] as String?,
      status: data['status'] as String? ?? 'in_progress',
      location: data['location'] as String? ?? 'in_store',
      isTrash: data['isTrash'] as bool? ?? false,
    );

    // Set relationships using mapped IDs
    final oldBrandId = data['brandId'] as int?;
    if (oldBrandId != null && brandIdMap.containsKey(oldBrandId)) {
      final newBrandId = brandIdMap[oldBrandId]!;
      final brand = _box.brandBox.get(newBrandId);
      if (brand != null) {
        serviceItem.brand.target = brand;
      }
    }

    final oldTechnicianId = data['technicianId'] as int?;
    if (oldTechnicianId != null &&
        technicianIdMap.containsKey(oldTechnicianId)) {
      final newTechnicianId = technicianIdMap[oldTechnicianId]!;
      final technician = _box.technicianBox.get(newTechnicianId);
      if (technician != null) {
        serviceItem.technician.target = technician;
      }
    }

    // Put the service item
    _box.serviceItemBox.put(serviceItem);

    // Set fault relationships
    final oldFaultIds = (data['faultIds'] as List<dynamic>?)?.cast<int>() ?? [];
    final newFaults = <Fault>[];
    for (final oldFaultId in oldFaultIds) {
      if (faultIdMap.containsKey(oldFaultId)) {
        final newFaultId = faultIdMap[oldFaultId]!;
        final fault = _box.faultBox.get(newFaultId);
        if (fault != null) {
          newFaults.add(fault);
        }
      }
    }
    serviceItem.setFaults(newFaults);

    // Update with relationships
    _box.serviceItemBox.put(serviceItem);
  }

  /// Clears all data from ObjectBox
  Future<void> _clearAllData() async {
    _box.brandBox.removeAll();
    _box.technicianBox.removeAll();
    _box.faultBox.removeAll();
    _box.serviceItemBox.removeAll();
  }

  /// Merge data from backup without clearing existing data
  Future<bool> mergeFromBackup({Function(String)? onProgress}) async {
    return await restoreFromBackup(
        clearExisting: false, onProgress: onProgress);
  }
}
