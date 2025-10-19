import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:mobile_service_manager/models/item.dart';
import 'package:mobile_service_manager/widgets/buttons/custom_icon_button.dart';
import '../constants/app_colors.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.listItemBackground,
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1.5,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(item.name, style: kDefaultTextStyle),
              ),
              // Action Buttons
              Row(
                children: [
                  CustomIconButton(
                      icon: CupertinoIcons.pen,
                      iconSize: 22,
                      color: AppColors.primaryButton,
                      onPressed: onEdit),
                  CustomIconButton(
                      icon: CupertinoIcons.delete_simple,
                      color: AppColors.dangerButton,
                      onPressed: onDelete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
