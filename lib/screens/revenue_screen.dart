import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/constants/app_colors.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import 'package:mobile_service_manager/widgets/radio_button.dart';
import 'package:mobile_service_manager/widgets/revenue_card.dart';
import '../models/technician.dart';
import '../providers/revenue_provider.dart';
import '../providers/technician_provider.dart';
import '../utils/date_time_picker.dart';
import '../widgets/custom_drop_down_text_field.dart';

enum DateType { specific, from, to }

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  late SingleValueDropDownController _technicianController;
  Technician? _selectedTechnician;

  DateTime? _selectedDate;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isDateRangeMode = false;
  late String _revenueTitle;

  @override
  void initState() {
    super.initState();

    _technicianController = SingleValueDropDownController();

    _selectedDate = DateTime.now();
    _revenueTitle = _selectedDate.toString().formattedDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(revenueNotifierProvider.notifier)
          .loadDailyRevenue(_selectedDate!);
    });
  }

  @override
  void dispose() {
    _technicianController.dispose();
    super.dispose();
  }

  void _setRevenueTitle() {
    final technician =
        _selectedTechnician == null ? '' : ' by ${_selectedTechnician!.name}';
    setState(() {
      if (_isDateRangeMode) {
        _revenueTitle =
            '${_fromDate.toString().formattedDate} - ${_toDate.toString().formattedDate}$technician';
      } else {
        _revenueTitle = _selectedDate.toString().formattedDate + technician;
      }
    });
  }

  int? _setTechnician() {
    if (_selectedTechnician == null) {
      return null;
    }

    return _selectedTechnician!.id;
  }

  @override
  Widget build(BuildContext context) {
    final technicians = ref.watch(techniciansProvider);
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
          /// Date and Technician Selection Section
          Card(
            elevation: 2,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 16),
                    child: _dateTypes(technicians),
                  ),
                  Row(
                    children: [
                      if (!_isDateRangeMode) ...[
                        /// Single Date Picker
                        Expanded(
                          child: Row(
                            children: [
                              _datePicker(
                                onPressed: () => _selectDate(context,
                                    dateType: DateType.specific,
                                    initialDate: _selectedDate),
                                text: _selectedDate != null
                                    ? _selectedDate.toString().formattedDate
                                    : 'Select Date',
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        /// Date Range Picker
                        Expanded(
                          child: Row(
                            children: [
                              _datePicker(
                                onPressed: () => _selectDate(context,
                                    dateType: DateType.from,
                                    initialDate: _fromDate),
                                text: _fromDate != null
                                    ? 'From: ${_fromDate.toString().formattedDate}'
                                    : 'From Date',
                              ),
                              const SizedBox(width: 8),
                              _datePicker(
                                onPressed: () => _selectDate(context,
                                    dateType: DateType.to,
                                    initialDate: _toDate),
                                text: _toDate != null
                                    ? 'To: ${_toDate.toString().formattedDate}'
                                    : 'To Date',
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
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
                                  _fromDate!, _toDate!,
                                  technicianId: _setTechnician());
                            } else {
                              ref
                                  .read(revenueNotifierProvider.notifier)
                                  .loadDailyRevenue(_selectedDate!,
                                      technicianId: _setTechnician());
                            }
                          },
                          child: const Text('Submit'),
                        ),
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

  Widget _datePicker({required String text, required Function()? onPressed}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.calendar_today, color: Colors.black87),
        label: Text(
          text,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  Widget _dateTypes(List<Technician> technicians) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          RadioButton(
              name: 'Specific Date',
              selected: !_isDateRangeMode,
              onTap: () => _dateTypeToggle(false)),
          RadioButton(
              name: 'From Date - To Date',
              selected: _isDateRangeMode,
              onTap: () => _dateTypeToggle(true)),
          _technicianWidget(technicians),
        ],
      ),
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

  Widget _technicianWidget(List<Technician> technicians) {
    return Container(
      width: 210,
      height: 35,
      padding: const EdgeInsets.only(left: 8),
      child: CustomDropDownTextField(
        title: 'Technician',
        clearOption: true,
        showTitle: false,
        padding: EdgeInsets.zero,
        borderColor: Colors.black54,
        controller: _technicianController,
        dropDownList: technicians.map((technician) {
          return DropDownValueModel(value: technician, name: technician.name);
        }).toList(),
        onChanged: (item) {
          if (item is DropDownValueModel) {
            _selectedTechnician = item.value;
          } else {
            _selectedTechnician = null;
          }
        },
      ),
    );
  }
}
