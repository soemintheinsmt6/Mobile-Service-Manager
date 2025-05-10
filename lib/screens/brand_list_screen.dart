import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:mobile_service_manager/utils/alert.dart';
import 'package:mobile_service_manager/widgets/add_new_item.dart';
import 'package:mobile_service_manager/widgets/update_item.dart';
import '../constants/app_colors.dart';
import '../models/brand.dart';
import '../providers/brand_provider.dart';
import '../utils/dialog.dart';
import '../widgets/item_card.dart';

class BrandListScreen extends ConsumerWidget {
  const BrandListScreen({super.key});

  void _addNewBrand(BuildContext context, WidgetRef ref) async {
    final result =
        await showCustomDialog(context, child: const AddNewItem(name: 'Brand'));

    if (result != null) {
      final brand = result as String;

      if (brand.isNotEmpty) {
        ref.read(brandsProvider.notifier).addBrand(Brand(name: brand));
      }
    }
  }

  void _updateBrand(BuildContext context, WidgetRef ref, Brand brand) async {
    final result = await showCustomDialog(context,
        width: 300, height: 220, child: UpdateItem(name: brand.name));

    if (result != null) {
      final updatedName = result as String;

      if (updatedName.isNotEmpty) {
        brand.name = updatedName;
        ref.read(brandsProvider.notifier).updateBrand(brand);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brands = ref.watch(brandsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Brand', style: kHeaderTextStyle),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => _addNewBrand(context, ref),
              label: Text('Add Brand', style: kDefaultTextStyle),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: brands.length,
          itemBuilder: (context, index) {
            final brand = brands[index];
            return ItemCard(
              item: brand,
              onTap: () {},
              onEdit: () {
                _updateBrand(context, ref, brand);
              },
              onDelete: () async {
                final result = await showDeleteAlert(context);
                if (result == true) {
                  ref.read(brandsProvider.notifier).deleteBrand(brand.id);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
