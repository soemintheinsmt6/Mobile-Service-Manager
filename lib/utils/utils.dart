import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/app_colors.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<dynamic> showDeleteAlert(BuildContext context) async {
  final alertStyle = AlertStyle(
    isCloseButton: false,
    titleStyle: kBodyTextStyle.copyWith(fontWeight: FontWeight.w600),
    descStyle: kDefaultTextStyle,
  );

  final result = await Alert(
    context: context,
    style: alertStyle,
    title: 'Delete!',
    desc: 'Are you sure want to delete?',
    buttons: [
      DialogButton(
        color: AppColors.primaryButton,
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel',
            style: kDefaultTextStyle.copyWith(color: Colors.white)),
      ),
      DialogButton(
        color: AppColors.dangerButton,
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: Text('Delete',
            style: kDefaultTextStyle.copyWith(color: Colors.white)),
      ),
    ],
  ).show();

  return result;
}

Future<dynamic> showCustomDialog(BuildContext context,
    {double width = 300, double height = 300, required Widget child}) async {
  final result = await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54.withOpacity(0.5),
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
