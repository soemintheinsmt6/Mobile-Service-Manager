import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_service_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_service_manager/core/constants/app_colors.dart';
import 'package:mobile_service_manager/core/constants/constants.dart';
import 'package:mobile_service_manager/data/models/service_item.dart';
import 'package:mobile_service_manager/presentation/screens/search_service_items_screen.dart';
import 'package:mobile_service_manager/presentation/screens/service_item_form.dart';
import 'package:mobile_service_manager/data/services/service_list_excel_exporter.dart';
import 'package:mobile_service_manager/data/services/service_list_pdf_printer.dart';
import 'package:mobile_service_manager/core/utils/dialog.dart';
import 'package:mobile_service_manager/presentation/screens/edit_service_item_screen.dart';
import 'package:mobile_service_manager/core/utils/extension.dart';
import 'package:mobile_service_manager/presentation/widgets/text_fields/custom_drop_down_text_field.dart';
import 'package:mobile_service_manager/presentation/widgets/service_tile.dart';
import '../providers/service_item_provider.dart';
import '../providers/object_box_provider.dart';
import '../widgets/buttons/right_elevated_button.dart';

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

  String? _searchString;
  bool _isLoading = false;
  final int _itemsPerPage = 50;
  int _currentPage = 0;

  final List<String> _printType = ['Excel', 'Pdf'];
  late String _selectedPrintType;

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

    _selectedPrintType = _printType[0];
  }

  @override
  void dispose() {
    _bodyHorizontalController.dispose();
    _headerHorizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void _print({required List<ServiceItem> list, required String type}) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      if (type == _printType[0]) {
        await ServiceListExcelExporter.exportToExcel(
          list,
          filterNames: _searchString,
        );
      } else {
        final objectBox = ref.read(objectBoxProvider);
        final ids = list.map((e) => e.id).toList();
        await ServiceListPdfPrinter.savePdfToFile(
          ids,
          objectBox.reference,
          filterNames: _searchString,
        );
      }
    } catch (e) {
      debugPrint('There is an error occur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const serviceListFlex = 5;
    final screenWidth = MediaQuery.of(context).size.width;
    final listWidth = (screenWidth - kNavigationBarWidth) *
        serviceListFlex /
        (serviceListFlex + 1);
    final width = listWidth > 1275.0 ? listWidth : 1275.0;

    final serviceItems = ref.watch(serviceItemsProvider);
    final notifier = ref.read(serviceItemsProvider.notifier);
    final isSearchActive = notifier.isSearchActive;
    final totalItems = notifier.totalCount;
    final rowsPerPage = _itemsPerPage;
    final totalPages = totalItems == 0 ? 1 : (totalItems / rowsPerPage).ceil();
    final t = AppLocalizations.of(context)!;

    int currentPage;
    List<ServiceItem> paginatedItems;
    int startIndex;
    int rangeStart;
    int rangeEnd;

    if (isSearchActive) {
      var searchPage = _currentPage;
      if (searchPage > totalPages - 1) {
        searchPage = totalPages - 1;
      }
      if (searchPage < 0) {
        searchPage = 0;
      }

      currentPage = searchPage;
      startIndex = currentPage * rowsPerPage;
      final endIndex = startIndex + rowsPerPage > totalItems
          ? totalItems
          : startIndex + rowsPerPage;
      paginatedItems = totalItems == 0
          ? <ServiceItem>[]
          : serviceItems.sublist(startIndex, endIndex);
      rangeStart = totalItems == 0 ? 0 : startIndex + 1;
      rangeEnd = endIndex;
    } else {
      currentPage = notifier.currentPage;
      startIndex = currentPage * rowsPerPage;
      paginatedItems = serviceItems;
      rangeStart = totalItems == 0 ? 0 : startIndex + 1;
      final displayedCount = paginatedItems.length;
      rangeEnd = totalItems == 0 ? 0 : startIndex + displayedCount;
    }
    final title = isSearchActive
        ? t.serviceList
        : '${t.serviceList} - ${DateTime.now().toString().formattedDate}';

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              /// Left - List
              Expanded(
                flex: serviceListFlex,
                child: Column(
                  children: [
                    /// Top Bar
                    Container(
                      height: 56,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(title, style: kHeaderTextStyle),
                              if (isSearchActive)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        '- $totalItems ${t.results}',
                                        style: kDefaultTextStyle.copyWith(
                                            color: Colors.grey[800]),
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      width: 120,
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 6),
                                      child: CustomDropDownTextField(
                                          showTitle: false,
                                          enableSearch: false,
                                          padding: EdgeInsets.zero,
                                          title: _selectedPrintType,
                                          initialValue: _selectedPrintType,
                                          dropDownList: _printType
                                              .map((e) => DropDownValueModel(
                                                  name: e, value: e))
                                              .toList(),
                                          onChanged: (item) {
                                            _selectedPrintType = item.value;
                                          }),
                                    ),
                                    IconButton(
                                        onPressed: () => _print(
                                            list: serviceItems,
                                            type: _selectedPrintType),
                                        icon:
                                            const Icon(CupertinoIcons.printer)),
                                  ],
                                )
                            ],
                          ),
                          Row(
                            children: [
                              if (isSearchActive)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: TextButton(
                                    child: Text(t.reset,
                                        style: kDefaultTextStyle.copyWith(
                                            color: AppColors.dangerButton)),
                                    onPressed: () {
                                      setState(() {
                                        _searchString = null;
                                        _currentPage = 0;
                                        if (_verticalController.hasClients) {
                                          _verticalController.jumpTo(0);
                                        }
                                      });
                                      ref
                                          .read(serviceItemsProvider.notifier)
                                          .resetSearch();
                                    },
                                  ),
                                ),
                              RightElevatedButton(
                                title: t.search,
                                onPressed: () async {
                                  final searchString = await showCustomDialog(
                                      context,
                                      width: 400,
                                      height: 770,
                                      child: const SearchServiceItemsScreen());

                                  if (!mounted) return;

                                  setState(() {
                                    _searchString = searchString;
                                    _currentPage = 0;
                                    if (_verticalController.hasClients) {
                                      _verticalController.jumpTo(0);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Sticky header (scrolls horizontally only)
                    SingleChildScrollView(
                      controller: _headerHorizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        width: width,
                        child: serviceHeader(context),
                      ),
                    ),

                    /// Scrollable list (horizontal + vertical) with pagination
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
                                      padding:
                                          const EdgeInsets.only(bottom: 20.0),
                                      itemCount: paginatedItems.length,
                                      itemBuilder: (context, index) {
                                        final item = paginatedItems[index];
                                        final displayIndex = startIndex + index;

                                        return ServiceTile(
                                          item: item,
                                          index: displayIndex,
                                          onTap: () {
                                            showCustomDialog(context,
                                                width: 460,
                                                height: 850,
                                                child: EditServiceItemScreen(
                                                    serviceItem: item));
                                          },
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    t.itemsPerPage(_itemsPerPage),
                                    style: kDefaultTextStyle,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    totalItems == 0
                                        ? '0 ${t.ofLabel} 0'
                                        : '$rangeStart-$rangeEnd ${t.ofLabel} $totalItems',
                                    style: kDefaultTextStyle,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left,
                                        size: 20),
                                    onPressed: currentPage > 0
                                        ? () {
                                            if (isSearchActive) {
                                              setState(() {
                                                _currentPage--;
                                                if (_verticalController
                                                    .hasClients) {
                                                  _verticalController.jumpTo(0);
                                                }
                                              });
                                            } else {
                                              ref
                                                  .read(serviceItemsProvider
                                                      .notifier)
                                                  .loadServiceItems(
                                                      page: currentPage - 1,
                                                      pageSize: rowsPerPage);
                                              if (_verticalController
                                                  .hasClients) {
                                                _verticalController.jumpTo(0);
                                              }
                                            }
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right,
                                        size: 20),
                                    onPressed: currentPage < totalPages - 1 &&
                                            totalItems > 0
                                        ? () {
                                            if (isSearchActive) {
                                              setState(() {
                                                _currentPage++;
                                                if (_verticalController
                                                    .hasClients) {
                                                  _verticalController.jumpTo(0);
                                                }
                                              });
                                            } else {
                                              ref
                                                  .read(serviceItemsProvider
                                                      .notifier)
                                                  .loadServiceItems(
                                                      page: currentPage + 1,
                                                      pageSize: rowsPerPage);
                                              if (_verticalController
                                                  .hasClients) {
                                                _verticalController.jumpTo(0);
                                              }
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

          /// Loading Indicator
          if (_isLoading)
            Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: AppColors.primaryButton, size: 100)),
        ],
      ),
    );
  }
}
