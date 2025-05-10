import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:mobile_service_manager/models/technician.dart';
import 'package:mobile_service_manager/providers/technician_provider.dart';
import 'package:mobile_service_manager/utils/utils.dart';
import 'package:mobile_service_manager/widgets/add_new_item.dart';
import 'package:mobile_service_manager/widgets/update_item.dart';
import '../constants/app_colors.dart';
import '../widgets/item_card.dart';

class TechnicianListScreen extends ConsumerWidget {
  const TechnicianListScreen({super.key});

  void _addNewTechnician(BuildContext context, WidgetRef ref) async {
    final result = await showCustomDialog(context,
        child: const AddNewItem(name: 'Technician'));

    if (result != null) {
      final technician = result as String;

      if (technician.isNotEmpty) {
        ref
            .read(techniciansProvider.notifier)
            .addTechnician(Technician(name: technician));
      }
    }
  }

  void _updateTechnician(
      BuildContext context, WidgetRef ref, Technician technician) async {
    final result = await showCustomDialog(context,
        width: 300, height: 220, child: UpdateItem(name: technician.name));

    if (result != null) {
      final updatedName = result as String;

      if (updatedName.isNotEmpty) {
        technician.name = updatedName;
        ref.read(techniciansProvider.notifier).updateTechnician(technician);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final technicians = ref.watch(techniciansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Technician', style: kHeaderTextStyle),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => _addNewTechnician(context, ref),
              label: Text('Add Technician', style: kDefaultTextStyle),
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
          itemCount: technicians.length,
          itemBuilder: (context, index) {
            final technician = technicians[index];
            return ItemCard(
              item: technician,
              onTap: () {},
              onEdit: () {
                _updateTechnician(context, ref, technician);
              },
              onDelete: () async {
                final result = await showDeleteAlert(context);
                if (result == true) {
                  ref
                      .read(techniciansProvider.notifier)
                      .deleteTechnician(technician.id);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
