import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/decoration.dart';

class CustomDropDownTextField extends StatelessWidget {
  const CustomDropDownTextField(
      {super.key,
      required this.title,
      this.showTitle = true,
      required this.dropDownList,
      this.clearOption = false,
      this.enableSearch = true,
      this.textFieldFocusNode,
      this.initialValue,
      this.controller,
      this.onChanged,
      this.padding = const EdgeInsets.symmetric(vertical: 10),
      this.validator,
      this.borderColor = Colors.grey});

  final String title;
  final bool showTitle;
  final List<DropDownValueModel> dropDownList;
  final bool clearOption;
  final bool enableSearch;
  final FocusNode? textFieldFocusNode;
  final dynamic initialValue;
  final dynamic controller;
  final Function(dynamic)? onChanged;
  final EdgeInsetsGeometry padding;
  final String? Function(String?)? validator;
  final Color borderColor;

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
          SizedBox(
            height: 35,
            child: DropDownTextField(
              initialValue: initialValue,
              textStyle: kDefaultTextStyle,
              searchTextStyle: kDefaultTextStyle,
              listTextStyle: kDefaultTextStyle,
              textFieldDecoration: kTextFieldDecoration(
                  hintText: title, borderColor: borderColor),
              clearOption: clearOption,
              enableSearch: enableSearch,
              searchAutofocus: true,
              clearIconProperty: IconProperty(
                  icon: Icons.clear, color: Colors.grey.shade600, size: 16),
              dropDownList: dropDownList,
              controller: controller,
              textFieldFocusNode: textFieldFocusNode,
              onChanged: (item) => onChanged!(item),
              validator: validator,
              listPadding: ListPadding(top: 10, bottom: 10),
            ),
          ),
        ],
      ),
    );
  }
}
