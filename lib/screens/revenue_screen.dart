import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/constants/app_colors.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import 'package:mobile_service_manager/widgets/radio_button.dart';
import 'package:mobile_service_manager/widgets/revenue_card.dart';
import '../providers/revenue_provider.dart';
import '../utils/date_time_picker.dart';

enum DateType { specific, from, to }

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  DateTime? _selectedDate;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isDateRangeMode = false;
  late String _revenueTitle;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();
    _revenueTitle = _selectedDate.toString().formattedDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(revenueNotifierProvider.notifier)
          .loadDailyRevenue(_selectedDate!);
    });
  }

  void _setRevenueTitle() {
    setState(() {
      if (_isDateRangeMode) {
        _revenueTitle =
            '${_fromDate.toString().formattedDate} - ${_toDate.toString().formattedDate}';
      } else {
        _revenueTitle = _selectedDate.toString().formattedDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final revenueData = ref.watch(revenueNotifierProvider);
    final revenueNotifier = ref.read(revenueNotifierProvider.notifier);
    final isValidToSubmit =
        _isDateRangeMode ? _fromDate != null && _toDate != null : true;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Revenue Report'),
          backgroundColor: const Color(0xFF4372C4),
          foregroundColor: Colors.white),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Date Selection Section
          Card(
            elevation: 2,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 16),
                    child: _dateTypes(),
                  ),
                  Row(
                    children: [
                      if (!_isDateRangeMode) ...[
                        /// Single Date Picker
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectDate(context,
                                      dateType: DateType.specific,
                                      initialDate: _selectedDate),
                                  icon: const Icon(Icons.calendar_today,
                                      color: Colors.black87),
                                  label: Text(
                                      _selectedDate != null
                                          ? _selectedDate
                                              .toString()
                                              .formattedDate
                                          : 'Select Date',
                                      style: const TextStyle(
                                          color: Colors.black87)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        /// Date Range Picker
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectDate(context,
                                      dateType: DateType.from,
                                      initialDate: _fromDate),
                                  icon: const Icon(Icons.calendar_today,
                                      color: Colors.black87),
                                  label: Text(
                                    _fromDate != null
                                        ? 'From: ${_fromDate.toString().formattedDate}'
                                        : 'From Date',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectDate(context,
                                      dateType: DateType.to,
                                      initialDate: _toDate),
                                  icon: const Icon(Icons.calendar_today,
                                      color: Colors.black87),
                                  label: Text(
                                    _toDate != null
                                        ? 'To: ${_toDate.toString().formattedDate}'
                                        : 'To Date',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isValidToSubmit
                              ? AppColors.primaryButton
                              : Colors.grey.shade100,
                          foregroundColor:
                              isValidToSubmit ? Colors.white : Colors.grey,
                        ),
                        onPressed: () {
                          if (!isValidToSubmit) return;

                          _setRevenueTitle();
                          if (_isDateRangeMode) {
                            revenueNotifier.loadRevenueForDateRange(
                                _fromDate!, _toDate!);
                          } else {
                            ref
                                .read(revenueNotifierProvider.notifier)
                                .loadDailyRevenue(_selectedDate!);
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// Revenue Data Display
          Expanded(
            child: revenueData == null
                ? const Center(
                    child: Text(
                      'No data available for selected date(s)',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    child:
                        RevenueCard(title: _revenueTitle, revenue: revenueData),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dateTypes() {
    return Row(
      children: [
        RadioButton(
            name: 'Specific Date',
            selected: !_isDateRangeMode,
            onTap: () => _dateTypeToggle(false)),
        RadioButton(
            name: 'From Date - To Date',
            selected: _isDateRangeMode,
            onTap: () => _dateTypeToggle(true)),
      ],
    );
  }

  void _dateTypeToggle(bool isDateRange) {
    setState(() {
      _isDateRangeMode = isDateRange;
    });
  }

  Future<void> _selectDate(BuildContext context,
      {required DateType dateType, required DateTime? initialDate}) async {
    final DateTime? picked = await showDateTimePicker(
      context,
      initialDate: initialDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        switch (dateType) {
          case DateType.specific:
            _selectedDate = picked;

          case DateType.from:
            _fromDate = picked;

          case DateType.to:
            _toDate = picked;
        }
      });
    }
  }
}
