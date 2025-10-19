import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/app_colors.dart';
import '../../constants/constants.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../models/fault.dart';

class CustomMultiSelectDropDownTextField extends StatelessWidget {
  const CustomMultiSelectDropDownTextField({
    super.key,
    required this.title,
    this.showTitle = true,
    required this.items,
    this.onChanged,
    this.controller,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  final String title;
  final bool showTitle;
  final List<DropdownItem<Fault>> items;
  final MultiSelectController<Fault>? controller;
  final Function(List<Fault>)? onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(title, style: titleTextStyle),
            ),
          MultiDropdown(
            controller: controller,
            onSelectionChange: (selectedOptions) {
              if (onChanged != null) {
                onChanged!(selectedOptions);

                controller!.closeDropdown();
              }
            },
            items: items,
            searchEnabled: true,
            chipDecoration: ChipDecoration(
              spacing: 4,
              runSpacing: 4,
              labelStyle: kDefaultTextStyle,
              deleteIcon: const Icon(CupertinoIcons.clear_circled,
                  size: 16, color: Colors.black),
              backgroundColor: const Color(0xFFE0E0E0),
            ),
            fieldDecoration: FieldDecoration(
              hintText: title,
              hintStyle: kDefaultTextStyle.copyWith(color: AppColors.hintColor),
              labelStyle: kDefaultTextStyle,
              showClearIcon: false,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(12),
              suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            dropdownDecoration:
                const DropdownDecoration(elevation: 2, marginTop: -4),
            dropdownItemDecoration: const DropdownItemDecoration(
              selectedIcon: Icon(CupertinoIcons.checkmark_alt, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
