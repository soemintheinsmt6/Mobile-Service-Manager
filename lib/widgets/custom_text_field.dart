import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import '../utils/decoration.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.title,
    this.showTitle = true,
    this.controller,
    this.onChanged,
    this.padding = const EdgeInsets.symmetric(vertical: 15),
    this.obscureText = false,
    this.showHint = true,
    this.textInputType = TextInputType.number,
  });

  final String title;
  final bool showTitle;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final EdgeInsetsGeometry padding;
  final bool obscureText;
  final bool showHint;
  final TextInputType textInputType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showTitle)
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8),
              child: Text(title, style: titleTextStyle),
            ),
          TextField(
            keyboardType: textInputType,
            textInputAction: TextInputAction.next,
            autofocus: true,
            style: kDefaultTextStyle,
            obscureText: obscureText,
            decoration: kTextFieldDecoration(hintText: showHint ? title : null),
            controller: controller,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
