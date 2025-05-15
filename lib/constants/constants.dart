import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

const kNavigationBarWidth = 95.0;

final kDefaultTextStyle = GoogleFonts.montserrat(fontSize: 12);
final kBodyTextStyle = GoogleFonts.montserrat(fontSize: 14);

final kLargeBoldTextStyle = GoogleFonts.montserrat(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

final kHeaderTextStyle = GoogleFonts.montserrat(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: AppColors.headerText,
);

final titleTextStyle = kDefaultTextStyle.copyWith(fontWeight: FontWeight.w600);
