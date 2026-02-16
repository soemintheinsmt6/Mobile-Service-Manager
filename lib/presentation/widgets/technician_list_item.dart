import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/technician.dart';

class TechnicianListItem extends StatelessWidget {
  final Technician technician;
  final VoidCallback onTap;

  const TechnicianListItem({
    super.key,
    required this.technician,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Technician Avatar (placeholder)
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, size: 30, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              // Technician Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technician.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.listItemText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Specialization',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.listItemText.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Experience',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.listItemText.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.listItemText.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.edit, color: AppColors.primaryButton),
                    onPressed: () {
                      // Edit technician functionality
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete, color: AppColors.dangerButton),
                    onPressed: () {
                      // Delete technician functionality
                    },
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
