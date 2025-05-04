import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.color,
    this.iconSize = 20,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final double iconSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}
