import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/brand.dart';
import '../providers/brand_provider.dart';
import '../widgets/brand_list_item.dart';

class BrandListScreen extends ConsumerWidget {
  const BrandListScreen({super.key});

  void _addNewBrand(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: const Text('Add New Brand')),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter brand name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // Add the new brand to ObjectBox via the provider
                ref
                    .read(brandsProvider.notifier)
                    .addBrand(Brand(name: nameController.text.trim()));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brands = ref.watch(brandsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _addNewBrand(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add Brand'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // Implement refresh functionality
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryButton,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: brands.length,
              itemBuilder: (context, index) {
                return BrandListItem(
                  brand: brands[index],
                  onTap: () {
                    // Handle brand selection
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
