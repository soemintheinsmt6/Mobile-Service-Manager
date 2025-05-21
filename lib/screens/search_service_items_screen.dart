import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import 'package:mobile_service_manager/utils/utils.dart';
import 'package:mobile_service_manager/widgets/bar_button.dart';
import '../constants/constants.dart';
import '../models/brand.dart';
import '../models/fault.dart';
import '../providers/brand_provider.dart';
import '../providers/fault_provider.dart';
import '../utils/date_time_picker.dart';
import '../widgets/custom_date_picker_text_field.dart';
import '../widgets/custom_drop_down_text_field.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/dismiss_button.dart';

class SearchServiceItemsScreen extends ConsumerStatefulWidget {
  const SearchServiceItemsScreen({
    super.key,
  });

  @override
  ConsumerState<SearchServiceItemsScreen> createState() =>
      _EditServiceItemState();
}

class _EditServiceItemState extends ConsumerState<SearchServiceItemsScreen> {
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();

  late SingleValueDropDownController _brandController;
  late SingleValueDropDownController _faultController;
  late SingleValueDropDownController _deviceStatusController;
  late SingleValueDropDownController _deliveryStatusController;

  final TextEditingController _specificDateController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<String> _dateTypes = [
    'No Date Selected',
    'Specific Date',
    'From Date To Date'
  ];

  String _selectedDateType = 'No Date Selected';

  Brand? _selectedBrand;
  Fault? _selectedFault;

  DateTime? _specificDateTime;
  DateTime? _fromDateTime;
  DateTime? _toDateTime;
  String? _deviceStatus;
  String? _deliveryStatus;

  @override
  void initState() {
    super.initState();

    _brandController = SingleValueDropDownController();
    _faultController = SingleValueDropDownController();
    _deviceStatusController = SingleValueDropDownController();
    _deliveryStatusController = SingleValueDropDownController();
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _customerNameController.dispose();
    _brandController.dispose();
    _faultController.dispose();
    _specificDateController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _deviceStatusController.dispose();
    _deliveryStatusController.dispose();
    super.dispose();
  }

  Future<void> _createDateTimePicker(Date date) async {
    final dateTime = await showDateTimePicker(context);

    switch (date) {
      case Date.specific:
        _specificDateTime = dateTime;
        _specificDateController.text =
            _specificDateTime?.toString().formattedDate ?? '';

      case Date.from:
        _fromDateTime = dateTime;
        _fromDateController.text =
            _fromDateTime?.toString().formattedDate ?? '';

      case Date.to:
        _toDateTime = dateTime;
        _toDateController.text = _toDateTime?.toString().formattedDate ?? '';
    }
  }

  void _updateServiceItem() {}

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(brandsProvider);
    final faults = ref.watch(faultsProvider);

    return Card(
      child: Stack(
        children: [
          const DismissButton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomTextFormField(
                    title: 'Invoice ID', controller: _invoiceController),
                CustomTextFormField(
                  title: 'Customer Name',
                  controller: _customerNameController,
                ),
                CustomDropDownTextField(
                  title: 'Brand',
                  clearOption: true,
                  controller: _brandController,
                  dropDownList: brands.map((brand) {
                    return DropDownValueModel(value: brand, name: brand.name);
                  }).toList(),
                  onChanged: (item) {
                    if (item is DropDownValueModel) {
                      _selectedBrand = item.value;
                    } else {
                      _selectedBrand = null;
                    }
                  },
                ),
                CustomDropDownTextField(
                  title: 'Error',
                  clearOption: true,
                  controller: _faultController,
                  dropDownList: faults.map((fault) {
                    return DropDownValueModel(value: fault, name: fault.name);
                  }).toList(),
                  onChanged: (item) {
                    if (item is DropDownValueModel) {
                      _selectedFault = item.value;
                    } else {
                      _selectedFault = null;
                    }
                  },
                ),
                _changeDeviceStatusTile(),
                CustomDropDownTextField(
                  title: 'Date Type',
                  initialValue: _selectedDateType,
                  enableSearch: false,
                  dropDownList: _dateTypes.map((type) {
                    return DropDownValueModel(value: type, name: type);
                  }).toList(),
                  onChanged: (item) {
                    setState(() {
                      _selectedDateType = item.value;
                    });
                  },
                ),
                _datePickerTextFields(),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 10),
                    child: BarButton(
                        title: 'Search', onPressed: _updateServiceItem)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePickerTextFields() {
    return Column(
      children: [
        if (_selectedDateType == _dateTypes[1])
          CustomDatePickerTextField(
            title: 'Specific Date',
            showTitle: false,
            controller: _specificDateController,
            onTap: () async {
              await _createDateTimePicker(Date.specific);
            },
          ),
        if (_selectedDateType == _dateTypes[2]) _fromDateToDate()
      ],
    );
  }

  Widget _fromDateToDate() {
    return Row(
      children: [
        Expanded(
          child: CustomDatePickerTextField(
            title: 'From Date',
            showTitle: false,
            controller: _fromDateController,
            onTap: () async {
              await _createDateTimePicker(Date.from);
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: CustomDatePickerTextField(
            title: 'To Date',
            showTitle: false,
            controller: _toDateController,
            onTap: () async {
              await _createDateTimePicker(Date.to);
            },
          ),
        )
      ],
    );
  }

  Widget _changeDeviceStatusTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text('Status', style: titleTextStyle),
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: CustomDropDownTextField(
                    title: 'Device Status',
                    padding: EdgeInsets.zero,
                    showTitle: false,
                    enableSearch: false,
                    clearOption: true,
                    controller: _deviceStatusController,
                    dropDownList: deviceStatus
                        .map((e) => DropDownValueModel(name: e, value: e))
                        .toList(),
                    onChanged: (item) {
                      if (item is DropDownValueModel) {
                        _deviceStatus = store(item.value);
                      } else {
                        _deviceStatus = null;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: CustomDropDownTextField(
                    title: 'Delivery Status',
                    padding: EdgeInsets.zero,
                    showTitle: false,
                    enableSearch: false,
                    clearOption: true,
                    controller: _deliveryStatusController,
                    dropDownList: deliveryStatus
                        .map((e) => DropDownValueModel(name: e, value: e))
                        .toList(),
                    onChanged: (item) {
                      if (item is DropDownValueModel) {
                        _deliveryStatus = store(item.value);
                      } else {
                        _deliveryStatus = null;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
