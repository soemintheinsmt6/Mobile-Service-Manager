import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DismissButton extends StatelessWidget {
  const DismissButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 5,
        right: 5,
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
