import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import '../constants/constants.dart';

class CustomMultiSelectDropDownTextField extends StatelessWidget {
  const CustomMultiSelectDropDownTextField({
    super.key,
    required this.title,
    this.showTitle = true,
    required this.options,
    this.initiallySelected = const [],
    this.onChanged,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  final String title;
  final bool showTitle;
  final List<ValueItem> options;
  final List<ValueItem> initiallySelected;
  final Function(List<ValueItem>)? onChanged;
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
              child: Text(title,
                  style:
                      kDefaultTextStyle.copyWith(fontWeight: FontWeight.w600)),
            ),
          MultiSelectDropDown(
            onOptionSelected: (options) {
              if (onChanged != null) {
                onChanged!(options);
              }
            },
            hint: title,
            hintStyle: kDefaultTextStyle.copyWith(color: Colors.grey),
            options: options,
            selectedOptions: initiallySelected,
            borderColor: Colors.grey,
            focusedBorderColor: Colors.grey,
            fieldBackgroundColor: Colors.transparent,
            borderWidth: 1,
            focusedBorderWidth: 2,
            borderRadius: 8,
            dropdownBorderRadius: 8,
            padding: const EdgeInsets.all(8),
            clearIcon: const Icon(Icons.clear, size: 16),
            chipConfig: ChipConfig(
                wrapType: WrapType.wrap,
                spacing: 4,
                runSpacing: 4,
                deleteIcon: const Icon(CupertinoIcons.clear_circled,
                    size: 16, color: Colors.black),
                labelStyle: kDefaultTextStyle,
                backgroundColor: Colors.white),
            optionTextStyle: kDefaultTextStyle,
            selectedOptionIcon:
                const Icon(CupertinoIcons.checkmark_alt, size: 16),
            selectedOptionTextColor: Colors.black,
            searchEnabled: true,
            suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
          ),
        ],
      ),
    );
  }
}
