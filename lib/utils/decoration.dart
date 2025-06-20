import 'package:flutter/material.dart';

InputDecoration kTextFieldDecoration(
    {String? hintText = 'Enter a value', Color borderColor = Colors.grey}) {
  return InputDecoration(
    hintText: hintText,
    contentPadding:
        const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 1.0),
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 2.0),
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    ),
  );
}

InputDecoration kTextFieldFormDecoration(
    {String? hintText = 'Enter a value', Color borderColor = Colors.grey}) {
  return InputDecoration(
    hintText: hintText,
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15.0),
    isDense: true,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    enabledBorder: OutlineInputBorder(
      // Use borderColor here
      borderSide: BorderSide(color: borderColor, width: 1.0),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    ),
    focusedBorder: OutlineInputBorder(
      // Use borderColor here
      borderSide: BorderSide(color: borderColor, width: 2.0),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade900, width: 2.0),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    ),
  );
}
