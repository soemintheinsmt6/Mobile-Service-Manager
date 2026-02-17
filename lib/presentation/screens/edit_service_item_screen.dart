import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/core/utils/extension.dart';
import 'package:mobile_service_manager/l10n/app_localizations.dart';

import 'package:multi_dropdown/multi_dropdown.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/alert.dart';
import '../../core/utils/date_time_picker.dart';
import '../../core/utils/utils.dart';
import '../../data/models/brand.dart';
import '../../data/models/fault.dart';
import '../../data/models/service_item.dart';

import '../../data/models/technician.dart';
import '../providers/brand_provider.dart';
import '../providers/fault_provider.dart';
import '../providers/service_item_provider.dart';
import '../providers/technician_provider.dart';

import '../widgets/buttons/bar_button.dart';
import '../widgets/custom_check_box.dart';
import '../widgets/text_fields/custom_date_picker_text_field.dart';
import '../widgets/text_fields/custom_drop_down_text_field.dart';
import '../widgets/text_fields/custom_multi_select_drop_down_text_field.dart';
import '../widgets/buttons/dismiss_button.dart';
import '../widgets/text_fields/custom_text_form_field.dart';

const _spacing = EdgeInsets.symmetric(vertical: 5);

class EditServiceItemScreen extends ConsumerStatefulWidget {
  final ServiceItem serviceItem;

  const EditServiceItemScreen({super.key, required this.serviceItem});

  @override
  ConsumerState<EditServiceItemScreen> createState() => _EditServiceItemState();
}

class _EditServiceItemState extends ConsumerState<EditServiceItemScreen> {
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  late SingleValueDropDownController _brandController;
  late SingleValueDropDownController _technicianController;
  late SingleValueDropDownController _deviceStatusController;
  late SingleValueDropDownController _deliveryStatusController;
  final MultiSelectController<Fault> _faultsController =
      MultiSelectController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();

  final _invoiceFocus = FocusNode();
  final _customerNameFocus = FocusNode();
  final _phoneNumberFocus = FocusNode();
  final _modelFocus = FocusNode();
  final _imeiFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _expenseFocus = FocusNode();
  final _remarkFocus = FocusNode();

  Brand? _selectedBrand;
  Technician? _selectedTechnician;
  List<Fault> _selectedFaults = [];
  List<int> _selectedFaultIds = [];

  late bool _simIncluded;
  late bool _sdIncluded;
  DateTime? _issuedDateTime;
  DateTime? _deliveryDateTime;
  late String _deviceStatus;
  late String _deliveryStatus;

  int _profit = 0;

  @override
  void initState() {
    super.initState();

    final item = widget.serviceItem;
    _invoiceController.text = item.invoiceId.toString();
    _customerNameController.text = item.customerName;
    _phoneNumberController.text =
        item.phoneNumber == 'null' ? '' : item.phoneNumber.toString();
    _modelController.text = item.model;
    _imeiController.text = item.imei;
    _priceController.text = item.servicePrice?.toString() ?? '';
    _expenseController.text = item.expense?.toString() ?? '';
    _priceController.addListener(_calculateProfit);
    _expenseController.addListener(_calculateProfit);
    _calculateProfit();

    _remarkController.text = item.remark ?? '';
    _simIncluded = item.simIncluded;
    _sdIncluded = item.sdIncluded;

    _selectedBrand = item.brand.target;
    _brandController = SingleValueDropDownController(
        data: DropDownValueModel(
            name: _selectedBrand?.name ?? '', value: _selectedBrand));

    _selectedTechnician = item.technician.target;
    _technicianController = SingleValueDropDownController(
        data: _selectedTechnician == null
            ? null
            : DropDownValueModel(
                name: _selectedTechnician?.name ?? '',
                value: _selectedTechnician));

    _selectedFaults = item.faults.toList();
    _selectedFaultIds = _selectedFaults.map((e) => e.id).toList();

    _issuedDateTime = DateTime.parse(item.issueDate);
    _issueDateController.text = _issuedDateTime.toString().formattedDate;
    _deliveryDateTime =
        item.deliveryDate == null ? null : DateTime.parse(item.deliveryDate!);
    _deliveryDateController.text = _deliveryDateTime == null
        ? ''
        : _deliveryDateTime.toString().formattedDate;

    _deviceStatus = item.status;
    _deliveryStatus = item.location;
    final deviceStatus = translate(_deviceStatus);
    final deliveryStatus = translate(_deliveryStatus);
    _deviceStatusController = SingleValueDropDownController(
        data: DropDownValueModel(name: deviceStatus, value: deviceStatus));
    _deliveryStatusController = SingleValueDropDownController(
        data: DropDownValueModel(name: deliveryStatus, value: deliveryStatus));
  }

  void _calculateProfit() {
    try {
      final int price = int.parse(
          _priceController.text.isEmpty ? '0' : _priceController.text);
      final int expense = int.parse(
          _expenseController.text.isEmpty ? '0' : _expenseController.text);

      setState(() {
        _profit = price - expense;
      });
    } catch (e) {
      setState(() {
        _profit = 0;
      });
      debugPrint('Error parsing input: $e');
    }
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _modelController.dispose();
    _imeiController.dispose();
    _priceController.removeListener(_calculateProfit);
    _expenseController.removeListener(_calculateProfit);
    _priceController.dispose();
    _expenseController.dispose();
    _remarkController.dispose();
    _brandController.dispose();
    _technicianController.dispose();
    _faultsController.dispose();
    _issueDateController.dispose();
    _deliveryDateController.dispose();
    _deviceStatusController.dispose();
    _deliveryStatusController.dispose();

    _invoiceFocus.dispose();
    _customerNameFocus.dispose();
    _phoneNumberFocus.dispose();
    _modelFocus.dispose();
    _imeiFocus.dispose();
    _priceFocus.dispose();
    _expenseFocus.dispose();
    _remarkFocus.dispose();
    super.dispose();
  }

  void _changeFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  Future<void> _createDateTimePicker({bool isDelivery = false}) async {
    final initialDate = isDelivery ? _deliveryDateTime : _issuedDateTime;
    final dateTime =
        await showDateTimePicker(context, initialDate: initialDate);

    if (dateTime != null) {
      if (isDelivery) {
        _deliveryDateTime = dateTime;
        _deliveryDateController.text =
            _deliveryDateTime.toString().formattedDate;
      } else {
        _issuedDateTime = dateTime;
        _issueDateController.text = _issuedDateTime.toString().formattedDate;
      }
    }
  }

  bool _validateInput() {
    final t = AppLocalizations.of(context)!;

    if (_invoiceController.text.isEmpty ||
        int.tryParse(_invoiceController.text) == 0) {
      showErrorMessage(context, t.invoiceIdInvalid);
      return false;
    }

    if (_customerNameController.text.isEmpty) {
      showErrorMessage(context, t.customerNameEmpty);
      return false;
    }

    if (_selectedBrand == null) {
      showErrorMessage(context, t.brandEmpty);
      return false;
    }

    if (_modelController.text.isEmpty) {
      showErrorMessage(context, t.modelEmpty);
      return false;
    }

    if (_selectedFaults.isEmpty) {
      showErrorMessage(context, t.errorFieldEmpty);
      return false;
    }

    if (_deliveryStatus == 'delivered' && _deliveryDateTime == null) {
      showErrorMessage(context, t.deliveryDateRequired);
      return false;
    }

    return true;
  }

  void _updateServiceItem() {
    if (!_validateInput()) return;

    final updated = widget.serviceItem;
    updated.invoiceId = int.parse(_invoiceController.text);
    updated.customerName = _customerNameController.text;
    updated.phoneNumber = _phoneNumberController.text;
    updated.brand.target = _selectedBrand;
    updated.model = _modelController.text;
    updated.imei = _imeiController.text;
    updated.setFaults(_selectedFaults);
    updated.servicePrice = int.tryParse(_priceController.text);
    updated.expense = int.tryParse(_expenseController.text);
    updated.technician.target = _selectedTechnician;
    updated.remark = _remarkController.text;
    updated.issueDate = _issuedDateTime.toString();
    updated.deliveryDate = _deliveryDateTime?.toString();
    updated.simIncluded = _simIncluded;
    updated.sdIncluded = _sdIncluded;
    updated.status = _deviceStatus;
    updated.location = _deliveryStatus;

    ref.read(serviceItemsProvider.notifier).updateServiceItem(updated);

    Navigator.pop(context);
  }

  void _deleteServiceItem() {
    ref
        .read(serviceItemsProvider.notifier)
        .moveToTrash(widget.serviceItem.id, ref);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(brandsProvider);
    final technicians = ref.watch(techniciansProvider);
    final faults = ref.watch(faultsProvider);
    final t = AppLocalizations.of(context)!;

    return Card(
      child: Stack(
        children: [
          const DismissButton(),
          Padding(
            padding: const EdgeInsets.only(right: 35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.invoiceId),
                  _fixedTile(CustomTextFormField(
                    title: t.invoiceId,
                    padding: _spacing,
                    showTitle: false,
                    focusNode: _invoiceFocus,
                    controller: _invoiceController,
                    onFieldSubmitted: (_) {
                      _changeFocus(_customerNameFocus);
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.customerName),
                  _fixedTile(CustomTextFormField(
                    title: t.customerName,
                    padding: _spacing,
                    showTitle: false,
                    focusNode: _customerNameFocus,
                    controller: _customerNameController,
                    onFieldSubmitted: (_) {
                      _changeFocus(_phoneNumberFocus);
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.phoneNumber),
                  _fixedTile(CustomTextFormField(
                    title: t.phoneNumber,
                    padding: _spacing,
                    showTitle: false,
                    focusNode: _phoneNumberFocus,
                    controller: _phoneNumberController,
                    onFieldSubmitted: (_) {
                      _changeFocus(_modelFocus);
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.brand),
                  _fixedTile(CustomDropDownTextField(
                    title: t.brand,
                    padding: _spacing,
                    showTitle: false,
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
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.model),
                  _fixedTile(CustomTextFormField(
                    title: t.model,
                    padding: _spacing,
                    showTitle: false,
                    focusNode: _modelFocus,
                    controller: _modelController,
                    onFieldSubmitted: (_) {
                      _changeFocus(_imeiFocus);
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.imei),
                  _fixedTile(CustomTextFormField(
                    title: t.imei,
                    padding: _spacing,
                    showTitle: false,
                    focusNode: _imeiFocus,
                    controller: _imeiController,
                    onFieldSubmitted: (_) {
                      _changeFocus(_priceFocus);
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.error),
                  _fixedTile(CustomMultiSelectDropDownTextField(
                    title: t.error,
                    padding: _spacing,
                    showTitle: false,
                    items: faults
                        .map((e) => DropdownItem(
                            label: e.name,
                            value: e,
                            selected: _selectedFaultIds.contains(e.id)))
                        .toList(),
                    controller: _faultsController,
                    onChanged: (items) {
                      _selectedFaults = items;
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.price),
                  _fixedTile(CustomTextFormField(
                    title: t.price,
                    padding: _spacing,
                    showTitle: false,
                    focusNode: _priceFocus,
                    controller: _priceController,
                    onFieldSubmitted: (_) {
                      _changeFocus(_expenseFocus);
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.expense),
                  _fixedTile(CustomTextFormField(
                    title: t.expense,
                    padding: _spacing,
                    showTitle: false,
                    focusNode: _expenseFocus,
                    controller: _expenseController,
                    onFieldSubmitted: (_) {
                      _changeFocus(_remarkFocus);
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.technician),
                  _fixedTile(CustomDropDownTextField(
                    title: t.technician,
                    padding: _spacing,
                    showTitle: false,
                    controller: _technicianController,
                    dropDownList: technicians.map((technician) {
                      return DropDownValueModel(
                          value: technician, name: technician.name);
                    }).toList(),
                    onChanged: (item) {
                      if (item is DropDownValueModel) {
                        _selectedTechnician = item.value;
                      } else {
                        _selectedTechnician = null;
                      }
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.remark),
                  _fixedTile(CustomTextFormField(
                    title: t.remark,
                    padding: _spacing,
                    showTitle: false,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    focusNode: _remarkFocus,
                    controller: _remarkController,
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.issueDate),
                  _fixedTile(CustomDatePickerTextField(
                    title: t.issueDate,
                    padding: _spacing,
                    showTitle: false,
                    controller: _issueDateController,
                    onTap: () async {
                      await _createDateTimePicker();
                    },
                  ))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _title(t.deliveryDate),
                  _fixedTile(CustomDatePickerTextField(
                    title: t.deliveryDate,
                    padding: _spacing,
                    showTitle: false,
                    controller: _deliveryDateController,
                    onTap: () async {
                      await _createDateTimePicker(isDelivery: true);
                    },
                  ))
                ]),
                _changeDeviceStatusTile(),
                _accessory(),
                if (_profit != 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                    child: Text('${t.profit}: ${_profit.toMMks()}',
                        style: kDefaultTextStyle.copyWith(
                            color: _profit < 0
                                ? AppColors.dangerButton
                                : Colors.black)),
                  ),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  width: 260,
                  child: BarButton(
                    title: t.save,
                    onPressed: _updateServiceItem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _changeDeviceStatusTile() {
    final t = AppLocalizations.of(context)!;
    return SizedBox(
      width: 285,
      child: Row(
        children: [
          Expanded(
            child: CustomDropDownTextField(
              title: t.status,
              padding: _spacing,
              showTitle: false,
              enableSearch: false,
              controller: _deviceStatusController,
              dropDownList: serviceStatus
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList(),
              onChanged: (item) {
                if (item is DropDownValueModel) {
                  _deviceStatus = store(item.value);
                } else {
                  _deviceStatus = '';
                }
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: CustomDropDownTextField(
              title: t.delivery,
              padding: _spacing,
              showTitle: false,
              enableSearch: false,
              controller: _deliveryStatusController,
              dropDownList: deliveryStatus
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList(),
              onChanged: (item) {
                if (item is DropDownValueModel) {
                  _deliveryStatus = store(item.value);

                  if (item.value == deliveryStatus[0]) {
                    _deliveryDateTime = null;
                    _deliveryDateController.text = '';
                  }
                } else {
                  _deliveryStatus = '';
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _accessory() {
    return _fixedTile(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        GestureDetector(
            onTap: () async {
              final result = await showDeleteAlert(context);

              if (result == true) {
                _deleteServiceItem();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(CupertinoIcons.trash,
                  size: 20, color: Colors.grey.shade600),
            ))
      ],
    ));
  }

  Widget _title(String text) {
    return Text(text, style: titleTextStyle);
  }

  Widget _fixedTile(Widget child) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      alignment: Alignment.centerRight,
      width: 295,
      child: child,
    );
  }
}
