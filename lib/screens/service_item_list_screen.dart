import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:mobile_service_manager/screens/service_item_form.dart';
import 'package:mobile_service_manager/utils/dialog.dart';
import 'package:mobile_service_manager/widgets/edit_service_item.dart';
import 'package:mobile_service_manager/widgets/service_tile.dart';
import '../providers/service_item_provider.dart';

class ServiceItemListScreen extends ConsumerStatefulWidget {
  const ServiceItemListScreen({super.key});

  @override
  ConsumerState<ServiceItemListScreen> createState() =>
      _ServiceItemListScreenState();
}

class _ServiceItemListScreenState extends ConsumerState<ServiceItemListScreen> {
  final ScrollController _bodyHorizontalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Synchronize header scroll with body scroll
    _bodyHorizontalController.addListener(() {
      if (_headerHorizontalController.hasClients &&
          _headerHorizontalController.offset !=
              _bodyHorizontalController.offset) {
        _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
      }
    });
  }

  @override
  void dispose() {
    _bodyHorizontalController.dispose();
    _headerHorizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final listWidth = (screenWidth - kNavigationBarWidth) * 4 / 5;
    final width = listWidth > 1220.0 ? listWidth : 1220.0;
    final serviceItems = ref.watch(serviceItemsProvider);

    return Scaffold(
      body: Row(
        children: [
          /// Left - List
          Expanded(
            flex: 4,
            child: Column(
              children: [
                // Sticky header (scrolls horizontally only)
                SingleChildScrollView(
                  controller: _headerHorizontalController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    width: width,
                    child: serviceHeader(),
                  ),
                ),

                // Scrollable list (horizontal + vertical)
                Expanded(
                  child: Scrollbar(
                    controller: _bodyHorizontalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _bodyHorizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: width,
                        child: Scrollbar(
                          controller: _verticalController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _verticalController,
                            padding: const EdgeInsets.only(bottom: 20.0),
                            itemCount: serviceItems.length,
                            itemBuilder: (context, index) {
                              final item = serviceItems[index];
                              return ServiceTile(
                                item: item,
                                index: index,
                                onTap: () async {
                                  final updatedItem =
                                      await showCustomDialog(context,
                                          width: 410,
                                          height: 600,
                                          child: EditServiceItem(
                                            serviceItem: item,
                                          ));

                                  if (updatedItem != null) {}
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Divider
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
