import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BarButton extends StatelessWidget {
  const BarButton({
    super.key,
    required this.title,
    this.onPressed,
  });

  final String title;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryButton,
        foregroundColor: Colors.white,
      ),
    );
  }
}
