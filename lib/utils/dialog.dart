import 'package:flutter/material.dart';

Future<dynamic> showCustomDialog(BuildContext context,
    {double width = 300, double height = 300, required Widget child}) async {
  final result = await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        );
      });

  return result;
}
