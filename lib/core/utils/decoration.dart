import 'package:flutter/material.dart';

InputDecoration kTextFieldDecoration({
  String? hintText = 'Enter a value',
  Color borderColor = Colors.grey,
  double borderRadius = 8.0,
  EdgeInsetsGeometry? contentPadding =
      const EdgeInsets.symmetric(vertical: 12, horizontal: 15.0),
}) {
  return InputDecoration(
    hintText: hintText,
    contentPadding: contentPadding,
    isDense: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    ),
    enabledBorder: OutlineInputBorder(
      // Use borderColor here
      borderSide: BorderSide(color: borderColor, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    ),
    focusedBorder: OutlineInputBorder(
      // Use borderColor here
      borderSide: BorderSide(color: borderColor, width: 2.5),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade900, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    ),
  );
}
