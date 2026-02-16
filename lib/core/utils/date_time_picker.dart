import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../constants/app_colors.dart';

Future<DateTime?> showDateTimePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  DateTime? selectedDateTime = await showOmniDateTimePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    type: OmniDateTimePickerType.date,
    is24HourMode: false,
    isShowSeconds: false,
    minutesInterval: 1,
    secondsInterval: 1,
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    constraints: const BoxConstraints(
      maxWidth: 350,
      maxHeight: 650,
    ),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        primary: AppColors.primaryButton,
        seedColor: Colors.white,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
    ),
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
          opacity: anim1.drive(
            Tween(begin: 0, end: 1),
          ),
          child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
  );

  return selectedDateTime;
}
