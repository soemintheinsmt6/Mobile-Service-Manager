import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/core/constants/app_colors.dart';
import 'package:mobile_service_manager/l10n/app_localizations.dart';
import 'package:mobile_service_manager/data/models/brand.dart';
import 'package:mobile_service_manager/data/models/fault.dart';
import 'package:mobile_service_manager/data/models/technician.dart';
import 'package:mobile_service_manager/presentation/providers/brand_provider.dart';
import 'package:mobile_service_manager/presentation/providers/fault_provider.dart';
import 'package:mobile_service_manager/core/utils/extension.dart';
import 'package:mobile_service_manager/presentation/widgets/revenue_card.dart';
import '../providers/revenue_provider.dart';
import '../providers/technician_provider.dart';
import '../../core/utils/date_time_picker.dart';
import '../widgets/buttons/radio_button.dart';
import '../widgets/text_fields/custom_drop_down_text_field.dart';

enum DateType { specific, from, to }

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  late SingleValueDropDownController _brandController;
  late SingleValueDropDownController _faultController;
  late SingleValueDropDownController _technicianController;

  Brand? _selectedBrand;
  Fault? _selectedFault;
  Technician? _selectedTechnician;

  DateTime? _selectedDate;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isDateRangeMode = false;
  late String _revenueTitle;

  @override
  void initState() {
    super.initState();

    _brandController = SingleValueDropDownController();
    _faultController = SingleValueDropDownController();
    _technicianController = SingleValueDropDownController();

    _selectedDate = DateTime.now();
    _revenueTitle = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final t = AppLocalizations.of(context)!;
      setState(() {
        _revenueTitle = '${t.issueDate}: ${_selectedDate.toString().formattedDate}';
      });
      ref
          .read(revenueNotifierProvider.notifier)
          .loadDailyRevenue(_selectedDate!);
    });
  }

  bool _isIssueDate = true;

  List<String> _filterDateTypes(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return [t.issueDate, t.deliveryDate];
  }

  @override
  void dispose() {
    _brandController.dispose();
    _faultController.dispose();
    _technicianController.dispose();
    super.dispose();
  }

  void _setRevenueTitle() {
    final t = AppLocalizations.of(context)!;
    final dateBy = _isIssueDate ? '${t.issueDate}: ' : '${t.deliveryDate}: ';
    final brand = _selectedBrand == null ? '' : ' / ${_selectedBrand!.name}';
    final fault = _selectedFault == null ? '' : ' / ${_selectedFault!.name}';
    final technician =
        _selectedTechnician == null ? '' : ' ${t.byLabel} ${_selectedTechnician!.name}';

    setState(() {
      if (_isDateRangeMode) {
        _revenueTitle =
            '$dateBy${_fromDate.toString().formattedDate} - ${_toDate.toString().formattedDate}$brand$fault$technician';
      } else {
        _revenueTitle = dateBy +
            _selectedDate.toString().formattedDate +
            brand +
            fault +
            technician;
      }
    });
  }

  int? _setID(dynamic item) {
    if (item == null) {
      return null;
    }

    return item!.id;
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(brandsProvider);
    final faults = ref.watch(faultsProvider);
    final technicians = ref.watch(techniciansProvider);
    final revenueData = ref.watch(revenueNotifierProvider);
    final revenueNotifier = ref.read(revenueNotifierProvider.notifier);
    final isValidToSubmit =
        _isDateRangeMode ? _fromDate != null && _toDate != null : true;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
          title: Text(t.revenueReport),
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
                    child: _revenueFilter(
                        brands: brands,
                        faults: faults,
                        technicians: technicians),
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
                                    : t.selectDate,
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
                                    ? '${t.fromLabel}: ${_fromDate.toString().formattedDate}'
                                    : t.fromDate,
                              ),
                              const SizedBox(width: 8),
                              _datePicker(
                                onPressed: () => _selectDate(context,
                                    dateType: DateType.to,
                                    initialDate: _toDate),
                                text: _toDate != null
                                    ? '${t.toLabel}: ${_toDate.toString().formattedDate}'
                                    : t.toDate,
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
                                  brandId: _setID(_selectedBrand),
                                  faultId: _setID(_selectedFault),
                                  technicianId: _setID(_selectedTechnician),
                                  isIssueDate: _isIssueDate);
                            } else {
                              ref
                                  .read(revenueNotifierProvider.notifier)
                                  .loadDailyRevenue(_selectedDate!,
                                      brandId: _setID(_selectedBrand),
                                      faultId: _setID(_selectedFault),
                                      technicianId: _setID(_selectedTechnician),
                                      isIssueDate: _isIssueDate);
                            }
                          },
                          child: Text(t.submit),
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
                ? Center(
                    child: Text(
                      t.noDataAvailable,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
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

  Widget _revenueFilter(
      {required List<Brand> brands,
      required List<Fault> faults,
      required List<Technician> technicians}) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          RadioButton(
              name: t.specificDate,
              selected: !_isDateRangeMode,
              onTap: () => _dateTypeToggle(false)),
          RadioButton(
              name: t.fromDateToDate,
              selected: _isDateRangeMode,
              onTap: () => _dateTypeToggle(true)),
          _filterDateTypeDropDown(),
          _brandWidget(brands),
          _faultWidget(faults),
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

  Widget _filterDateTypeDropDown() {
    final types = _filterDateTypes(context);
    return _dropDownContainer(
      width: 160,
      child: CustomDropDownTextField(
        title: types[0],
        initialValue: types[0],
        showTitle: false,
        enableSearch: false,
        padding: EdgeInsets.zero,
        borderColor: Colors.black54,
        dropDownList: types.map((type) {
          return DropDownValueModel(value: type, name: type);
        }).toList(),
        onChanged: (item) {
          _isIssueDate = item.value == types[0];
        },
      ),
    );
  }

  Widget _brandWidget(List<Brand> brands) {
    final t = AppLocalizations.of(context)!;
    return _dropDownWidget(
        title: t.brand,
        list: brands,
        width: 160,
        controller: _brandController,
        onChanged: (item) {
          if (item is DropDownValueModel) {
            _selectedBrand = item.value;
          } else {
            _selectedBrand = null;
          }
        });
  }

  Widget _faultWidget(List<Fault> faults) {
    final t = AppLocalizations.of(context)!;
    return _dropDownWidget(
        title: t.error,
        list: faults,
        controller: _faultController,
        onChanged: (item) {
          if (item is DropDownValueModel) {
            _selectedFault = item.value;
          } else {
            _selectedFault = null;
          }
        });
  }

  Widget _technicianWidget(List<Technician> technicians) {
    final t = AppLocalizations.of(context)!;
    return _dropDownWidget(
        title: t.technician,
        list: technicians,
        controller: _technicianController,
        onChanged: (item) {
          if (item is DropDownValueModel) {
            _selectedTechnician = item.value;
          } else {
            _selectedTechnician = null;
          }
        });
  }

  Widget _dropDownWidget(
      {required String title,
      required List<dynamic> list,
      required dynamic controller,
      required dynamic Function(dynamic)? onChanged,
      double width = 210.0}) {
    return _dropDownContainer(
      width: width,
      child: CustomDropDownTextField(
        title: title,
        clearOption: true,
        showTitle: false,
        padding: EdgeInsets.zero,
        borderColor: Colors.black54,
        controller: controller,
        dropDownList: list.map((item) {
          return DropDownValueModel(value: item, name: item.name);
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dropDownContainer({required Widget child, required double width}) {
    return Container(
      width: width,
      height: 35,
      padding: const EdgeInsets.only(left: 8),
      child: child,
    );
  }
}
