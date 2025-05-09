import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/decoration.dart';

class CustomDropDownTextField extends StatelessWidget {
  const CustomDropDownTextField({
    super.key,
    required this.title,
    this.showTitle = true,
    required this.dropDownList,
    this.clearOption = false,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.validator,
  });

  final String title;
  final bool showTitle;
  final List<DropDownValueModel> dropDownList;
  final bool clearOption;
  final dynamic initialValue;
  final dynamic controller;
  final Function(dynamic)? onChanged;
  final EdgeInsetsGeometry padding;
  final String? Function(String?)? validator;

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
          DropDownTextField(
            initialValue: initialValue,
            textStyle: kDefaultTextStyle,
            searchTextStyle: kDefaultTextStyle,
            listTextStyle: kDefaultTextStyle,
            textFieldDecoration:
                kTextFieldFormDecoration.copyWith(hintText: title),
            clearOption: clearOption,
            enableSearch: true,
            searchAutofocus: true,
            clearIconProperty: IconProperty(icon: Icons.clear, size: 18),
            dropDownList: dropDownList,
            controller: controller,
            onChanged: (item) => onChanged!(item),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
