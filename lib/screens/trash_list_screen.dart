import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/providers/trash_service_item_provider.dart';
import '../constants/constants.dart';
import '../widgets/service_tile.dart';

class TrashListScreen extends ConsumerStatefulWidget {
  const TrashListScreen({super.key});

  @override
  ConsumerState<TrashListScreen> createState() => _TrashListScreenState();
}

class _TrashListScreenState extends ConsumerState<TrashListScreen> {
  final ScrollController _bodyHorizontalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();

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
    final listWidth = screenWidth - kNavigationBarWidth;
    final width = listWidth > 1220.0 ? listWidth : 1220.0;
    final trashItems = ref.watch(trashServiceItemProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text('Deleted Service List', style: kHeaderTextStyle),
          centerTitle: false),
      body: Column(
        children: [
          // Sticky header (scrolls horizontally only)
          SingleChildScrollView(
            controller: _headerHorizontalController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: width,
              child: serviceHeader(isTrash: true),
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
                      itemCount: trashItems.length,
                      itemBuilder: (context, index) {
                        final item = trashItems[index];

                        return ServiceTile(
                          item: item,
                          index: index,
                          onTap: () {},
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
    );
  }
}
