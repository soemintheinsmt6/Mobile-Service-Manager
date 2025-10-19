import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/constants.dart';

class RightElevatedButton extends StatelessWidget {
  const RightElevatedButton({
    super.key,
    required this.title,
    this.onPressed,
    this.padding = const EdgeInsets.only(right: 16.0),
  });

  final String title;
  final EdgeInsetsGeometry padding;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        label: Text(title, style: kDefaultTextStyle),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
