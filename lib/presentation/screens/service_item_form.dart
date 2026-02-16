import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/core/utils/alert.dart';
import 'package:mobile_service_manager/core/utils/extension.dart';
import 'package:mobile_service_manager/presentation/widgets/buttons/bar_button.dart';
import 'package:mobile_service_manager/presentation/widgets/text_fields/custom_date_picker_text_field.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../data/models/brand.dart';
import '../../data/models/fault.dart';
import '../../data/models/service_item.dart';
import '../../data/models/technician.dart';
import '../providers/brand_provider.dart';
import '../providers/fault_provider.dart';
import '../providers/service_item_provider.dart';
import '../providers/technician_provider.dart';
import '../../core/utils/date_time_picker.dart';
import '../widgets/custom_check_box.dart';
import '../widgets/text_fields/custom_multi_select_drop_down_text_field.dart';
import '../widgets/text_fields/custom_drop_down_text_field.dart';
import '../widgets/text_fields/custom_text_form_field.dart';

class ServiceItemForm extends ConsumerStatefulWidget {
  const ServiceItemForm({super.key});

  @override
  ConsumerState<ServiceItemForm> createState() => _ServiceItemFormState();
}

class _ServiceItemFormState extends ConsumerState<ServiceItemForm> {
  final _formKey = GlobalKey<FormState>();

  late SingleValueDropDownController _brandController;
  late SingleValueDropDownController _technicianController;
  late MultiSelectController<Fault> _faultsController;
  final TextEditingController _dateController = TextEditingController();

  final _invoiceFocus = FocusNode();
  final _customerNameFocus = FocusNode();
  final _phoneNumberFocus = FocusNode();
  final _modelFocus = FocusNode();
  final _imeiFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _remarkFocus = FocusNode();

  // Form fields
  int _invoiceId = 0;
  String _customerName = '';
  String _phoneNumber = '';
  String _model = '';
  String _imei = '';
  int? _servicePrice;
  bool _simIncluded = false;
  bool _sdIncluded = false;
  String? _remark;
  DateTime? _selectedDateTime;

  Brand? selectedBrand;
  Technician? selectedTechnician;
  List<Fault> selectedFaults = [];

  @override
  void initState() {
    _brandController = SingleValueDropDownController();
    _technicianController = SingleValueDropDownController();
    _faultsController = MultiSelectController();

    _selectedDateTime = DateTime.now();
    _dateController.text = _selectedDateTime.toString().formattedDate;
    super.initState();
  }

  @override
  void dispose() {
    _invoiceFocus.dispose();
    _customerNameFocus.dispose();
    _phoneNumberFocus.dispose();
    _modelFocus.dispose();
    _imeiFocus.dispose();
    _priceFocus.dispose();
    _remarkFocus.dispose();

    _brandController.dispose();
    _technicianController.dispose();
    _faultsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  bool _validateInput() {
    if (_invoiceId == 0) {
      showErrorMessage(context, 'Invoice ID is invalid');
      return false;
    }

    if (_customerName.isEmpty) {
      showErrorMessage(context, 'Customer Name is empty');
      return false;
    }

    if (selectedBrand == null) {
      showErrorMessage(context, 'Brand is empty');
      return false;
    }

    if (_model.isEmpty) {
      showErrorMessage(context, 'Model is empty');
      return false;
    }

    if (selectedFaults.isEmpty) {
      showErrorMessage(context, 'Error field is empty');
      return false;
    }

    return true;
  }

  void _saveServiceItem() {
    _formKey.currentState?.save();
    if (!_validateInput()) return;

    final newItem = ServiceItem(
      invoiceId: _invoiceId,
      customerName: _customerName,
      phoneNumber: _phoneNumber,
      model: _model,
      imei: _imei,
      issueDate: _selectedDateTime.toString(),
      servicePrice: _servicePrice,
      simIncluded: _simIncluded,
      sdIncluded: _sdIncluded,
      remark: _remark,
    );

    newItem.brand.target = selectedBrand;
    newItem.technician.target = selectedTechnician;
    newItem.faults.addAll(selectedFaults);

    ref.read(serviceItemsProvider.notifier).addServiceItem(newItem);

    // Reset form
    _formKey.currentState?.reset();
    selectedFaults.clear();
    _faultsController.clearAll();
    setState(() {
      selectedBrand = null;
      selectedTechnician = null;
      _brandController.clearDropDown();
      _technicianController.clearDropDown();
      _simIncluded = false;
      _sdIncluded = false;
    });

    _changeFocus(_invoiceFocus);
  }

  void _changeFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  Future<void> _createDateTimePicker() async {
    final dateTime =
        await showDateTimePicker(context, initialDate: _selectedDateTime);

    if (dateTime != null) {
      _selectedDateTime = dateTime;
      _dateController.text = _selectedDateTime.toString().formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(brandsProvider);
    final technicians = ref.watch(techniciansProvider);
    final faults = ref.watch(faultsProvider);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextFormField(
              title: 'Invoice ID',
              focusNode: _invoiceFocus,
              onSaved: (v) => _invoiceId = int.tryParse(v ?? '') ?? 0,
              onFieldSubmitted: (_) {
                _changeFocus(_customerNameFocus);
              },
            ),
            CustomTextFormField(
              title: 'Customer Name',
              focusNode: _customerNameFocus,
              onSaved: (v) => _customerName = v ?? '',
              onFieldSubmitted: (_) {
                _changeFocus(_phoneNumberFocus);
              },
            ),
            CustomTextFormField(
              title: 'Phone Number',
              focusNode: _phoneNumberFocus,
              onSaved: (v) => _phoneNumber = v ?? '',
              onFieldSubmitted: (_) {
                _changeFocus(_modelFocus);
              },
            ),
            CustomDropDownTextField(
              title: 'Brand',
              controller: _brandController,
              dropDownList: brands.map((brand) {
                return DropDownValueModel(value: brand, name: brand.name);
              }).toList(),
              onChanged: (item) {
                if (item is DropDownValueModel) {
                  selectedBrand = item.value;
                } else {
                  selectedBrand = null;
                }
              },
            ),
            CustomTextFormField(
              title: 'Model',
              focusNode: _modelFocus,
              onSaved: (v) => _model = v ?? '',
              onFieldSubmitted: (_) {
                _changeFocus(_imeiFocus);
              },
            ),
            CustomTextFormField(
              title: 'IMEI',
              focusNode: _imeiFocus,
              onSaved: (v) => _imei = v ?? '',
              onFieldSubmitted: (_) {
                _changeFocus(_priceFocus);
              },
            ),
            CustomMultiSelectDropDownTextField(
              title: 'Error',
              items: faults
                  .map((e) => DropdownItem(label: e.name, value: e))
                  .toList(),
              controller: _faultsController,
              onChanged: (items) {
                selectedFaults = items;
              },
            ),
            CustomTextFormField(
              title: 'Price',
              focusNode: _priceFocus,
              keyboardType: TextInputType.number,
              onSaved: (v) => _servicePrice = int.tryParse(v ?? ''),
              onFieldSubmitted: (_) {
                _changeFocus(_remarkFocus);
              },
            ),
            CustomDropDownTextField(
              title: 'Technician',
              clearOption: true,
              controller: _technicianController,
              dropDownList: technicians.map((tech) {
                return DropDownValueModel(value: tech, name: tech.name);
              }).toList(),
              onChanged: (item) {
                if (item is DropDownValueModel) {
                  selectedTechnician = item.value;
                } else {
                  selectedTechnician = null;
                }
              },
            ),
            CustomTextFormField(
              title: 'Remark',
              focusNode: _remarkFocus,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onSaved: (v) => _remark = v,
            ),
            CustomDatePickerTextField(
              title: 'Issue Date',
              controller: _dateController,
              onTap: () async {
                await _createDateTimePicker();
              },
            ),
            Row(
              children: [
                CustomCheckBox(
                  name: 'SIM',
                  value: _simIncluded,
                  onChanged: (value) {
                    setState(() {
                      _simIncluded = value;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: CustomCheckBox(
                    name: 'SD',
                    value: _sdIncluded,
                    onChanged: (value) {
                      setState(() {
                        _sdIncluded = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 20.0),
              width: double.infinity,
              child:
                  BarButton(title: 'Add Service', onPressed: _saveServiceItem),
            ),
          ],
        ),
      ),
    );
  }
}
