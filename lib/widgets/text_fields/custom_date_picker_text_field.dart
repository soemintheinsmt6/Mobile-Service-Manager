import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import '../../utils/decoration.dart';
import '../../utils/utils.dart';

class CustomDatePickerTextField extends StatelessWidget {
  const CustomDatePickerTextField({
    super.key,
    required this.title,
    this.showTitle = true,
    this.controller,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.onTap,
  });

  final String title;
  final bool showTitle;
  final TextEditingController? controller;
  final EdgeInsetsGeometry padding;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 4),
              child: Text(title, style: titleTextStyle),
            ),
          TextField(
            style: kDefaultTextStyle,
            decoration: kTextFieldDecoration(hintText: title),
            focusNode: AlwaysDisabledFocusNode(),
            controller: controller,
            onTap: () => onTap!(),
          ),
        ],
      ),
    );
  }
}
