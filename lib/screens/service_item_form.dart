import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/utils/alert.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../constants/app_colors.dart';
import '../models/brand.dart';
import '../models/fault.dart';
import '../models/service_item.dart';
import '../models/technician.dart';
import '../providers/brand_provider.dart';
import '../providers/fault_provider.dart';
import '../providers/service_item_provider.dart';
import '../providers/technician_provider.dart';
import '../widgets/custom_check_box.dart';
import '../widgets/custom_multi_select_field.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_drop_down_text_field.dart';

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

  final _invoiceFocus = FocusNode();
  final _customerNameFocus = FocusNode();
  final _phoneNumberFocus = FocusNode();
  final _modelFocus = FocusNode();
  final _imeiFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _remarkFocus = FocusNode();

  // Form fields
  int invoiceId = 0;
  String customerName = '';
  int phoneNumber = 0;
  String model = '';
  String imei = '';
  int? servicePrice;
  bool simIncluded = false;
  bool sdIncluded = false;
  String? remark;

  Brand? selectedBrand;
  Technician? selectedTechnician;
  List<Fault> selectedFaults = [];

  @override
  void initState() {
    _brandController = SingleValueDropDownController();
    _technicianController = SingleValueDropDownController();
    _faultsController = MultiSelectController();
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
    super.dispose();
  }

  bool _validateInput() {
    if (invoiceId == 0) {
      showErrorMessage(context, 'Invoice ID is invalid');
      return false;
    }

    if (customerName.isEmpty) {
      showErrorMessage(context, 'Customer Name is empty');
      return false;
    }

    if (selectedBrand == null) {
      showErrorMessage(context, 'Brand is empty');
      return false;
    }

    if (model.isEmpty) {
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
      invoiceId: invoiceId,
      customerName: customerName,
      phoneNumber: phoneNumber,
      model: model,
      imei: imei,
      issueDate: DateTime.now().toString(),
      servicePrice: servicePrice,
      simIncluded: simIncluded,
      sdIncluded: sdIncluded,
      remark: remark,
    );

    newItem.brand.target = selectedBrand;
    newItem.technician.target = selectedTechnician;
    newItem.faults.addAll(selectedFaults);

    ref.read(serviceItemsProvider.notifier).addItem(newItem);

    // Reset form
    _formKey.currentState?.reset();
    selectedFaults.clear();
    _faultsController.clearAll();
    setState(() {
      selectedBrand = null;
      selectedTechnician = null;
      _brandController.clearDropDown();
      _technicianController.clearDropDown();
      simIncluded = false;
      sdIncluded = false;
    });

    changeFocus(_invoiceFocus);
  }

  void changeFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
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
              onSaved: (v) => invoiceId = int.tryParse(v ?? '') ?? 0,
              onFieldSubmitted: (_) {
                changeFocus(_customerNameFocus);
              },
            ),
            CustomTextFormField(
              title: 'Customer Name',
              focusNode: _customerNameFocus,
              onSaved: (v) => customerName = v ?? '',
              onFieldSubmitted: (_) {
                changeFocus(_phoneNumberFocus);
              },
            ),
            CustomTextFormField(
              title: 'Phone Number',
              focusNode: _phoneNumberFocus,
              keyboardType: TextInputType.phone,
              onSaved: (v) => phoneNumber = int.tryParse(v ?? '') ?? 0,
              onFieldSubmitted: (_) {
                changeFocus(_modelFocus);
              },
            ),
            CustomDropDownTextField(
              title: 'Brand',
              controller: _brandController,
              dropDownList: brands.map((brand) {
                return DropDownValueModel(value: brand, name: brand.name);
              }).toList(),
              onChanged: (item) => selectedBrand = item.value,
            ),
            CustomTextFormField(
              title: 'Model',
              focusNode: _modelFocus,
              onSaved: (v) => model = v ?? '',
              onFieldSubmitted: (_) {
                changeFocus(_imeiFocus);
              },
            ),
            CustomTextFormField(
              title: 'IMEI',
              focusNode: _imeiFocus,
              onSaved: (v) => imei = v ?? '',
              onFieldSubmitted: (_) {
                changeFocus(_priceFocus);
              },
            ),
            CustomMultiSelectDropDownTextField(
              title: 'Error',
              items: faults,
              controller: _faultsController,
              onChanged: (items) {
                selectedFaults = items.map((e) => e.value as Fault).toList();
              },
            ),
            CustomTextFormField(
              title: 'Price',
              focusNode: _priceFocus,
              keyboardType: TextInputType.number,
              onSaved: (v) => servicePrice = int.tryParse(v ?? ''),
              onFieldSubmitted: (_) {
                changeFocus(_remarkFocus);
              },
            ),
            CustomDropDownTextField(
              title: 'Technician',
              clearOption: true,
              controller: _technicianController,
              dropDownList: technicians.map((tech) {
                return DropDownValueModel(value: tech, name: tech.name);
              }).toList(),
              onChanged: (item) => selectedTechnician = item.value,
            ),
            CustomTextFormField(
              title: 'Remark',
              focusNode: _remarkFocus,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onSaved: (v) => remark = v,
            ),
            Row(
              children: [
                CustomCheckBox(
                  name: 'SIM',
                  value: simIncluded,
                  onChanged: (value) {
                    setState(() {
                      simIncluded = value;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: CustomCheckBox(
                    name: 'SD',
                    value: sdIncluded,
                    onChanged: (value) {
                      setState(() {
                        sdIncluded = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 20.0),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveServiceItem,
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Add Service'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
