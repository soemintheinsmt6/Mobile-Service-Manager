import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/screens/service_item_form.dart';
import 'package:mobile_service_manager/widgets/service_tile.dart';
import '../providers/service_item_provider.dart';

class ServiceItemListScreen extends ConsumerStatefulWidget {
  const ServiceItemListScreen({super.key});

  @override
  ConsumerState<ServiceItemListScreen> createState() =>
      _ServiceItemListScreenState();
}

class _ServiceItemListScreenState extends ConsumerState<ServiceItemListScreen> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceItems = ref.watch(serviceItemsProvider);

    return Scaffold(
      body: Row(
        children: [
          /// Left - List
          Expanded(
            flex: 4,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _horizontalController,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: 1200,
                  child: ListView.builder(
                    controller: _verticalController,
                    padding: const EdgeInsets.only(bottom: 20.0),
                    itemCount: serviceItems.length * 40,
                    itemBuilder: (context, index) {
                      final item = serviceItems[0];

                      return ServiceTile(item: item, index: index);
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),

          /// Right - Form
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ServiceItemForm(),
            ),
          ),
        ],
      ),
    );
  }
}
