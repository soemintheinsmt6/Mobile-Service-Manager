import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DismissButton extends StatelessWidget {
  const DismissButton({
    super.key,
    this.spacing = 5.0,
  });

  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: spacing,
        right: spacing,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.clear_circled,
            size: 20,
            color: Colors.grey.shade600,
          ),
        ));
  }
}
