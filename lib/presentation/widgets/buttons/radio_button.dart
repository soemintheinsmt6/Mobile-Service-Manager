import 'package:flutter/material.dart';
import 'package:mobile_service_manager/core/constants/app_colors.dart';

class RadioButton extends StatelessWidget {
  const RadioButton({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryButton : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_sharp
                  : Icons.radio_button_off_sharp,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 4),
            Text(name, style: TextStyle(color: color))
          ],
        ),
      ),
    );
  }
}
