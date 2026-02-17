import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_service_manager/core/constants/app_colors.dart';
import 'package:mobile_service_manager/l10n/app_localizations.dart';
import 'package:mobile_service_manager/data/services/backup_restore_service.dart';
import 'package:mobile_service_manager/presentation/providers/brand_provider.dart';
import 'package:mobile_service_manager/presentation/providers/fault_provider.dart';
import 'package:mobile_service_manager/presentation/providers/locale_provider.dart';
import 'package:mobile_service_manager/presentation/providers/object_box_provider.dart';
import 'package:mobile_service_manager/presentation/providers/service_item_provider.dart';
import 'package:mobile_service_manager/presentation/providers/technician_provider.dart';
import 'package:mobile_service_manager/core/utils/dialog.dart';
import 'package:mobile_service_manager/presentation/widgets/buttons/bar_button.dart';
import 'package:mobile_service_manager/presentation/widgets/glass_box.dart';
import 'package:mobile_service_manager/presentation/widgets/info_card.dart';

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
    final t = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    try {
      final filePath = await _backupRestoreService.createBackup();
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.backupSuccess} $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.backupError} $e'),
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
    final t = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.confirmRestore),
        content: Text(clearExisting ? t.replaceWarning : t.mergeWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancel,
                  style: const TextStyle(color: Colors.black54))),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: clearExisting
                    ? AppColors.dangerButton
                    : AppColors.primaryButton),
            child: Text(t.restore),
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
          SnackBar(
            content: Text(t.restoreSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.restoreError} $e'),
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
    final t = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
        actions: [_info(context)],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Language Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.language, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            t.language,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          DropdownButton<Locale>(
                            value: currentLocale,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              DropdownMenuItem(
                                value: const Locale('en'),
                                child: Text(t.english),
                              ),
                              DropdownMenuItem(
                                value: const Locale('my'),
                                child: Text(t.burmese),
                              ),
                            ],
                            onChanged: (locale) {
                              if (locale != null) {
                                ref
                                    .read(localeProvider.notifier)
                                    .setLocale(locale);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Backup Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.createBackup,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 16),
                            child: Text(t.backupDescription),
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _createBackup,
                                icon: const Icon(Icons.backup,
                                    color: Colors.black),
                                label: Text(t.createBackup,
                                    style:
                                        const TextStyle(color: Colors.black)),
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
                          Text(
                            t.restoreData,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 16),
                            child: Text(t.restoreDescription),
                          ),
                          Row(
                            children: [
                              BarButton(
                                title: t.replaceAllData,
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
                                  label: Text(t.mergeData,
                                      style: const TextStyle(
                                          color: Colors.black87))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
