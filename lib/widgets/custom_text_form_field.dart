import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import '../utils/decoration.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.title,
    this.showTitle = true,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.onChanged,
    this.controller,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.onSaved,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
  });

  final String title;
  final bool showTitle;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLines;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final EdgeInsetsGeometry padding;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final Function(String?)? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showTitle)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(title, style: titleTextStyle),
            ),
          TextFormField(
            maxLines: maxLines,
            style: kDefaultTextStyle,
            decoration: kTextFieldFormDecoration.copyWith(hintText: title),
            keyboardType: keyboardType,
            focusNode: focusNode,
            autofocus: true,
            onSaved: onSaved,
            validator: validator,
            onChanged: onChanged,
            controller: controller,
            onFieldSubmitted: onFieldSubmitted,
          ),
        ],
      ),
    );
  }
}
