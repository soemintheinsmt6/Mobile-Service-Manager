import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mobile_service_manager/database/object_box.dart';
import 'package:path_provider/path_provider.dart';
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
      final brands = _box.getAllBrands();
      final technicians = _box.getAllTechnicians();
      final faults = _box.getAllFaults();
      final serviceItems = _box.getAllServiceItems();

      // Create backup data structure
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'brands': brands.map((b) => b.toJson()).toList(),
          'technicians': technicians.map((t) => t.toJson()).toList(),
          'faults': faults.map((f) => f.toJson()).toList(),
          'serviceItems': serviceItems.map((s) => s.toJson()).toList(),
        }
      };

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

  /// Restore data from a backup file
  Future<bool> restoreFromBackup({bool clearExisting = true}) async {
    try {
      // Pick backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Backup File',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        return await _restoreFromJsonString(jsonString, clearExisting);
      }

      return false;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      rethrow;
    }
  }

  /// Restores data from JSON string
  Future<bool> _restoreFromJsonString(
      String jsonString, bool clearExisting) async {
    try {
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = backupData['data'] as Map<String, dynamic>;

      // Clear existing data if requested
      if (clearExisting) {
        await _clearAllData();
      }

      // Restore brands first
      final brandsData = data['brands'] as List<dynamic>;
      final brands = brandsData.map((json) => Brand.fromJson(json)).toList();
      _box.brandBox.putMany(brands);

      // Restore technicians
      final techniciansData = data['technicians'] as List<dynamic>;
      final technicians =
          techniciansData.map((json) => Technician.fromJson(json)).toList();
      _box.technicianBox.putMany(technicians);

      // Restore faults
      final faultsData = data['faults'] as List<dynamic>;
      final faults = faultsData.map((json) => Fault.fromJson(json)).toList();
      _box.faultBox.putMany(faults);

      // Restore service items (more complex due to relationships)
      final serviceItemsData = data['serviceItems'] as List<dynamic>;
      for (final itemData in serviceItemsData) {
        await _restoreServiceItem(itemData);
      }

      return true;
    } catch (e) {
      debugPrint('Error in restore process: $e');

      rethrow;
    }
  }

  /// Restores a single ServiceItem with relationships
  Future<void> _restoreServiceItem(Map<String, dynamic> data) async {
    final serviceItem = ServiceItem(
      id: data['id'] as int? ?? 0,
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

    // Set brand relationship
    final brandId = data['brandId'] as int?;
    if (brandId != null) {
      final brand = _box.brandBox.get(brandId);
      if (brand != null) {
        serviceItem.brand.target = brand;
      }
    }

    // Set technician relationship
    final technicianId = data['technicianId'] as int?;
    if (technicianId != null) {
      final technician = _box.technicianBox.get(technicianId);
      if (technician != null) {
        serviceItem.technician.target = technician;
      }
    }

    // Put the service item first to get an ID
    _box.serviceItemBox.put(serviceItem);

    // Set fault relationships
    final faultIds = (data['faultIds'] as List<dynamic>?)?.cast<int>() ?? [];
    final faults = faultIds
        .map((id) => _box.faultBox.get(id))
        .where((f) => f != null)
        .cast<Fault>()
        .toList();
    serviceItem.setFaults(faults);

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

  /// Creates an automatic backup to Documents folder
  Future<String?> createAutoBackup() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final backupsDir = Directory('${documentsDir.path}/ServiceBackups');

      if (!await backupsDir.exists()) {
        await backupsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File('${backupsDir.path}/auto_backup_$timestamp.json');

      // Get all data
      final brands = _box.brandBox.getAll();
      final technicians = _box.technicianBox.getAll();
      final faults = _box.faultBox.getAll();
      final serviceItems = _box.serviceItemBox.getAll();

      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'brands': brands.map((b) => b.toJson()).toList(),
          'technicians': technicians.map((t) => t.toJson()).toList(),
          'faults': faults.map((f) => f.toJson()).toList(),
          'serviceItems': serviceItems.map((s) => s.toJson()).toList(),
        }
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      await backupFile.writeAsString(jsonString);

      return backupFile.path;
    } catch (e) {
      debugPrint('Error creating auto backup: $e');
      return null;
    }
  }

  /// Gets list of available backup files
  Future<List<FileSystemEntity>> getAvailableBackups() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final backupsDir = Directory('${documentsDir.path}/ServiceBackups');

      if (await backupsDir.exists()) {
        return backupsDir
            .listSync()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort(
              (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      }

      return [];
    } catch (e) {
      debugPrint('Error getting backup files: $e');
      return [];
    }
  }

  /// Validates backup file format
  Future<bool> validateBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      return data.containsKey('version') &&
          data.containsKey('data') &&
          data['data'] is Map<String, dynamic>;
    } catch (e) {
      return false;
    }
  }
}
