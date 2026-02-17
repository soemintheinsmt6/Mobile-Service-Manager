import 'package:flutter/material.dart';
import 'package:mobile_service_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/constants.dart';
import '../../core/utils/alert.dart';
import '../../core/utils/dialog.dart';
import '../../data/models/brand.dart';
import '../providers/brand_provider.dart';
import '../widgets/add_new_item.dart';
import '../widgets/buttons/right_elevated_button.dart';
import '../widgets/item_card.dart';
import '../widgets/update_item.dart';

class BrandListScreen extends ConsumerWidget {
  const BrandListScreen({super.key});

  void _addNewBrand(BuildContext context, WidgetRef ref) async {
    final result =
        await showCustomDialog(context, child: AddNewItem(name: AppLocalizations.of(context)!.brand));

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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.brand, style: kHeaderTextStyle),
        centerTitle: false,
        actions: [
          RightElevatedButton(
            title: t.addBrand,
            onPressed: () => _addNewBrand(context, ref),
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
