import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/models/value_item.dart';
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

  final _invoiceFocus = FocusNode();
  final _customerNameFocus = FocusNode();

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
  final List<Fault> selectedFaults = [];

  @override
  void dispose() {
    _invoiceFocus.dispose();
    _customerNameFocus.dispose();
    super.dispose();
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextFormField(
              title: 'Invoice ID',
              focusNode: _invoiceFocus,
              onSaved: (v) => invoiceId = int.tryParse(v ?? '') ?? 0,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Invoice ID is empty'
                  : (int.tryParse(v) == null)
                      ? 'Invoice ID is invalid'
                      : null,
              onFieldSubmitted: (_) {
                changeFocus(_customerNameFocus);
              },
            ),
            CustomTextFormField(
              title: 'Customer Name',
              focusNode: _customerNameFocus,
              onSaved: (v) => customerName = v ?? '',
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Customer Name is empty' : null,
            ),
            CustomTextFormField(
              title: 'Phone Number',
              keyboardType: TextInputType.phone,
              onSaved: (v) => phoneNumber = int.tryParse(v ?? '') ?? 0,
            ),
            CustomDropDownTextField(
              title: 'Brand',
              dropDownList: brands.map((brand) {
                return DropDownValueModel(value: brand, name: brand.name);
              }).toList(),
              onChanged: (item) => selectedBrand = item.value,
              validator: (v) => v == null || v == '' ? 'Select a brand' : null,
            ),
            CustomTextFormField(
              title: 'Model',
              onSaved: (v) => model = v ?? '',
            ),
            CustomTextFormField(
              title: 'IMEI',
              onSaved: (v) => imei = v ?? '',
            ),
            CustomTextFormField(
              title: 'Price',
              keyboardType: TextInputType.number,
              onSaved: (v) => servicePrice = int.tryParse(v ?? ''),
            ),
            CustomDropDownTextField(
              title: 'Technician',
              dropDownList: technicians.map((tech) {
                return DropDownValueModel(value: tech, name: tech.name);
              }).toList(),
              onChanged: (item) => selectedTechnician = item.value,
            ),
            CustomTextFormField(
              title: 'Remark',
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
                const SizedBox(width: 15),
                CustomCheckBox(
                  name: 'SD',
                  value: sdIncluded,
                  onChanged: (value) {
                    setState(() {
                      sdIncluded = value;
                    });
                  },
                ),
              ],
            ),
            CustomMultiSelectDropDownTextField(
              title: 'Error',
              options: faults
                  .map((fault) => ValueItem(label: fault.name, value: fault))
                  .toList(),
              onChanged: (values) {
                print(
                    'Selected items: ${values.map((e) => e.label).join(', ')}');
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(bottom: 20.0),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final valid = _formKey.currentState?.validate() ?? false;
                  if (!valid) return;
                  _formKey.currentState?.save();

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
                  setState(() {
                    selectedBrand = null;
                    selectedTechnician = null;
                    simIncluded = false;
                    sdIncluded = false;
                  });
                },
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
