import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:mobile_service_manager/widgets/custom_icon_button.dart';
import '../constants/app_colors.dart';
import '../models/brand.dart';

class BrandListItem extends StatelessWidget {
  final Brand brand;
  final VoidCallback onTap;

  const BrandListItem({
    super.key,
    required this.brand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.listItemBackground,
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(brand.name, style: kDefaultFontStyle),
              ),
              // Action Buttons
              Row(
                children: [
                  CustomIconButton(
                      icon: CupertinoIcons.pen,
                      iconSize: 22,
                      color: AppColors.primaryButton,
                      onPressed: () {}),
                  CustomIconButton(
                      icon: CupertinoIcons.delete_simple,
                      color: AppColors.dangerButton,
                      onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
