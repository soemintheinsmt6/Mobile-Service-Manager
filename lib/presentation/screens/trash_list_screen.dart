import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/presentation/providers/trash_service_item_provider.dart';
import '../../core/constants/constants.dart';
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
    final notifier = ref.read(trashServiceItemProvider.notifier);
    final totalItems = notifier.totalCount;
    final rowsPerPage = notifier.pageSize;
    final currentPage = notifier.currentPage;
    final totalPages =
        totalItems == 0 ? 1 : (totalItems / rowsPerPage).ceil();
    final startIndex = currentPage * rowsPerPage;
    final rangeStart = totalItems == 0 ? 0 : startIndex + 1;
    final displayedCount = trashItems.length;
    final rangeEnd =
        totalItems == 0 ? 0 : startIndex + displayedCount;

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
            child: Column(
              children: [
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
                              final displayIndex = startIndex + index;

                              return ServiceTile(
                                item: item,
                                index: displayIndex,
                                onTap: () {},
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Rows per page: $rowsPerPage',
                          style: kDefaultTextStyle,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          totalItems == 0
                              ? '0 of 0'
                              : '$rangeStart-$rangeEnd of $totalItems',
                          style: kDefaultTextStyle,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: currentPage > 0
                              ? () {
                                  ref
                                      .read(trashServiceItemProvider.notifier)
                                      .loadTrashItems(
                                          page: currentPage - 1,
                                          pageSize: rowsPerPage);
                                  if (_verticalController.hasClients) {
                                    _verticalController.jumpTo(0);
                                  }
                                }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          onPressed: currentPage < totalPages - 1 &&
                                  totalItems > 0
                              ? () {
                                  ref
                                      .read(trashServiceItemProvider.notifier)
                                      .loadTrashItems(
                                          page: currentPage + 1,
                                          pageSize: rowsPerPage);
                                  if (_verticalController.hasClients) {
                                    _verticalController.jumpTo(0);
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
