import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_service_manager/constants/app_colors.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:mobile_service_manager/models/service_item.dart';
import 'package:mobile_service_manager/screens/search_service_items_screen.dart';
import 'package:mobile_service_manager/screens/service_item_form.dart';
import 'package:mobile_service_manager/services/service_list_excel_exporter.dart';
import 'package:mobile_service_manager/services/service_list_pdf_printer.dart';
import 'package:mobile_service_manager/utils/dialog.dart';
import 'package:mobile_service_manager/screens/edit_service_item_screen.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import 'package:mobile_service_manager/widgets/custom_drop_down_text_field.dart';
import 'package:mobile_service_manager/widgets/right_elevated_button.dart';
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

  String? _searchString;
  bool _isLoading = false;

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

    try {
      if (type == _printType[0]) {
        await ServiceListExcelExporter.exportToExcel(list,
            filterNames: _searchString);
      } else {
        await ServiceListPdfPrinter.printServiceList(list,
            filterNames: _searchString);
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
    final isSearchActive =
        ref.read(serviceItemsProvider.notifier).isSearchActive;
    final title = isSearchActive
        ? 'Service List'
        : 'Service List - ${DateTime.now().toString().formattedDate}';

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
                                        '- ${serviceItems.length} results',
                                        style: kDefaultTextStyle.copyWith(
                                            color: Colors.grey[800]),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () => _print(
                                            list: serviceItems,
                                            type: _selectedPrintType),
                                        icon:
                                            const Icon(CupertinoIcons.printer)),
                                    Container(
                                      height: 35,
                                      width: 100,
                                      padding: const EdgeInsets.only(left: 8),
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
                                    child: Text('Reset',
                                        style: kDefaultTextStyle.copyWith(
                                            color: AppColors.dangerButton)),
                                    onPressed: () {
                                      _searchString = null;
                                      ref
                                          .read(serviceItemsProvider.notifier)
                                          .resetSearch();
                                    },
                                  ),
                                ),
                              RightElevatedButton(
                                title: 'Search',
                                onPressed: () async {
                                  final searchString = await showCustomDialog(
                                      context,
                                      width: 400,
                                      height: 770,
                                      child: const SearchServiceItemsScreen());

                                  _searchString = searchString;
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
                        child: serviceHeader(),
                      ),
                    ),

                    /// Scrollable list (horizontal + vertical)
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
