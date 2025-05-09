import 'package:flutter/cupertino.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:signed_spacing_flex/signed_spacing_flex.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox(
      {required this.name,
      required this.value,
      required this.onChanged,
      super.key});

  final String name;
  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return SignedSpacingRow(
      spacing: -8,
      children: [
        CupertinoCheckbox(
          value: value,
          onChanged: (bool? value) {
            onChanged(value ?? false);
          },
        ),
        Text(name, style: kDefaultTextStyle)
      ],
    );
  }
}
