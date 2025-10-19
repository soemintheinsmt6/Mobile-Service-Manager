import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_service_manager/constants/app_colors.dart';
import 'package:mobile_service_manager/services/backup_restore_service.dart';
import 'package:mobile_service_manager/providers/brand_provider.dart';
import 'package:mobile_service_manager/providers/fault_provider.dart';
import 'package:mobile_service_manager/providers/object_box_provider.dart';
import 'package:mobile_service_manager/providers/service_item_provider.dart';
import 'package:mobile_service_manager/providers/technician_provider.dart';
import 'package:mobile_service_manager/utils/dialog.dart';
import 'package:mobile_service_manager/widgets/buttons/bar_button.dart';
import 'package:mobile_service_manager/widgets/glass_box.dart';
import 'package:mobile_service_manager/widgets/info_card.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  late BackupRestoreService _backupRestoreService;
  bool _isLoading = false;
  bool _showProgress = false;
  String _progress = '';

  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final filePath = await _backupRestoreService.createBackup();
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully at: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating backup: $e'),
            backgroundColor: AppColors.dangerButton,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreBackup({bool clearExisting = true}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Restore'),
        content: Text(clearExisting
            ? 'This will replace all current data with the backup data. Are you sure?'
            : 'This will merge the backup data with existing data. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.black54))),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: clearExisting
                    ? AppColors.dangerButton
                    : AppColors.primaryButton),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _showProgress = true;
    });

    try {
      final success = await _backupRestoreService.restoreFromBackup(
        clearExisting: clearExisting,
        onProgress: (progress) {
          if (mounted) {
            debugPrint('Restore progress: $progress');
            setState(() {
              _progress = progress;
            });
          }
        },
      );

      if (success && mounted) {
        _loadItems();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring backup: $e'),
            backgroundColor: AppColors.dangerButton,
          ),
        );
      }
    } finally {
      setState(() {
        _showProgress = false;
      });
    }
  }

  void _loadItems() {
    ref.read(brandsProvider.notifier).loadBrands();
    ref.read(faultsProvider.notifier).loadFaults();
    ref.read(techniciansProvider.notifier).loadTechnicians();
    ref.read(serviceItemsProvider.notifier).loadServiceItems();
  }

  @override
  void initState() {
    super.initState();

    final objectBox = ProviderScope.containerOf(context, listen: false)
        .read(objectBoxProvider);
    _backupRestoreService = BackupRestoreService(objectBox);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        actions: [_info(context)],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Backup Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Backup',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 12.0, bottom: 16),
                          child: Text(
                              'Create a backup of all your data including brands, technicians, faults, and service items.'),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _createBackup,
                              icon:
                                  const Icon(Icons.backup, color: Colors.black),
                              label: const Text('Create Backup',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Restore Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Restore Data',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 12.0, bottom: 16),
                          child: Text(
                              'Restore data from a backup file. This will replace/merge your current data.'),
                        ),
                        Row(
                          children: [
                            BarButton(
                              title: 'Replace All Data',
                              icon: const Icon(Icons.restore_sharp),
                              backgroundColor: AppColors.primaryButton,
                              onPressed: () =>
                                  _restoreBackup(clearExisting: true),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                                onPressed: () =>
                                    _restoreBackup(clearExisting: false),
                                icon: const Icon(Icons.merge_type,
                                    color: Colors.black87),
                                label: const Text('Merge Data',
                                    style: TextStyle(color: Colors.black87))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: AppColors.primaryButton, size: 100)),
          if (_showProgress)
            Center(
              child: GlassBox(title: _progress),
            ),
        ],
      ),
    );
  }

  Widget _info(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: GestureDetector(
        child: Image.asset('assets/info.png', width: 32, height: 32),
        onTap: () {
          showCustomDialog(context,
              width: 400, height: 400, child: const InfoCard());
        },
      ),
    );
  }
}
