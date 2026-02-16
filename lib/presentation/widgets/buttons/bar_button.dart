import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BarButton extends StatelessWidget {
  const BarButton({
    super.key,
    required this.title,
    this.icon,
    this.backgroundColor = AppColors.primaryButton,
    this.foregroundColor = Colors.white,
    this.onPressed,
  });

  final String title;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }
}
