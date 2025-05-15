import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/providers/fault_provider.dart';
import '../constants/app_colors.dart';
import '../constants/constants.dart';
import '../models/fault.dart';
import '../utils/dialog.dart';
import '../widgets/add_new_item.dart';
import '../widgets/update_item.dart';

class FaultListScreen extends ConsumerWidget {
  const FaultListScreen({super.key});

  void _addNewFault(BuildContext context, WidgetRef ref) async {
    final result =
        await showCustomDialog(context, child: const AddNewItem(name: 'Error'));

    if (result != null) {
      final fault = result as String;

      if (fault.isNotEmpty) {
        ref.read(faultsProvider.notifier).addFault(Fault(name: fault));
      }
    }
  }

  void _updateFault(BuildContext context, WidgetRef ref, Fault fault) async {
    final result = await showCustomDialog(context,
        width: 300, height: 220, child: UpdateItem(name: fault.name));

    if (result != null) {
      final updatedName = result as String;

      if (updatedName.isNotEmpty) {
        fault.name = updatedName;
        ref.read(faultsProvider.notifier).updateFault(fault);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faults = ref.watch(faultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Error', style: kHeaderTextStyle),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => _addNewFault(context, ref),
              label: Text('Add Error', style: kDefaultTextStyle),
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
        child: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: faults.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final fault = faults[index];
            final name = '${index + 1}. ${fault.name}';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(name, style: kDefaultTextStyle),
                  ),
                  GestureDetector(
                    onTap: () {
                      _updateFault(context, ref, fault);
                    },
                    child: const Icon(
                      CupertinoIcons.pen,
                      color: Color(0xFF898989),
                      size: 22,
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
