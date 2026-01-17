import 'dart:isolate';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import 'package:mobile_service_manager/utils/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../models/service_item.dart';
import '../objectbox.g.dart';

class ServiceListPdfPrinter {
  static Future<void> printServiceList(
    List<int> serviceItemIds,
    ByteData storeReference, {
    String? filterNames,
  }) async {
    try {
      final fontData = await _loadFonts();

      final pdfBytes = await _generatePdfInBackground(
        serviceItemIds,
        storeReference,
        fontData,
        filterNames,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> savePdfToFile(
    List<int> serviceItemIds,
    ByteData storeReference, {
    String? filterNames,
  }) async {
    try {
      final fontData = await _loadFonts();

      final pdfBytes = await _generatePdfInBackground(
        serviceItemIds,
        storeReference,
        fontData,
        filterNames,
      );

      final DateFormat format = DateFormat('yyyy_MMM_dd_h_mm_a');
      final defaultFileName =
          'service_list_report_${format.format(DateTime.now())}.pdf';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Service List Report',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(pdfBytes);
        await OpenFile.open(file.path);
      } else {
        debugPrint('Save cancelled');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<FontData> _loadFonts() async {
    final montserratRegular =
        await rootBundle.load('assets/fonts/Montserrat-Regular.ttf');
    final montserratMedium =
        await rootBundle.load('assets/fonts/Montserrat-Medium.ttf');
    final myanmarFont =
        await rootBundle.load('assets/fonts/NotoSansMyanmar-Regular.ttf');
    final iconFont =
        await rootBundle.load("assets/fonts/MaterialIcons-Regular.ttf");

    return FontData(
      montserratRegular: montserratRegular.buffer.asUint8List(),
      montserratMedium: montserratMedium.buffer.asUint8List(),
      myanmarFont: myanmarFont.buffer.asUint8List(),
      iconFont: iconFont.buffer.asUint8List(),
    );
  }

  static Future<Uint8List> _generatePdfInBackground(
    List<int> serviceItemIds,
    ByteData storeReference,
    FontData fontData,
    String? filterNames,
  ) async {
    final receivePort = ReceivePort();

    final isolateData = IsolateData(
      sendPort: receivePort.sendPort,
      serviceItemIds: serviceItemIds,
      storeReference: storeReference,
      fontData: fontData,
      filterNames: filterNames,
    );

    await Isolate.spawn(_pdfGeneratorIsolate, isolateData);

    final result = await receivePort.first;

    if (result is Exception) {
      throw result;
    }

    return result as Uint8List;
  }

  static void _pdfGeneratorIsolate(IsolateData data) async {
    Store? store;
    try {
      store = Store.fromReference(getObjectBoxModel(), data.storeReference);
      final box = store.box<ServiceItem>();
      final serviceItems =
          box.getMany(data.serviceItemIds).whereType<ServiceItem>().toList();
      final pdf = pw.Document();

      final ttfMontserratRegular = pw.Font.ttf(ByteData.sublistView(
          Uint8List.fromList(data.fontData.montserratRegular)));
      final ttfMontserratMedium = pw.Font.ttf(ByteData.sublistView(
          Uint8List.fromList(data.fontData.montserratMedium)));
      final ttfMyanmar = pw.Font.ttf(
          ByteData.sublistView(Uint8List.fromList(data.fontData.myanmarFont)));
      final ttfIcon = pw.Font.ttf(
          ByteData.sublistView(Uint8List.fromList(data.fontData.iconFont)));

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          header: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (context.pageNumber == 1)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Service List Report',
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          font: ttfMontserratMedium,
                        ),
                      ),
                      pw.Text(
                        'Total: ${serviceItems.length}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: ttfMontserratRegular,
                        ),
                      ),
                    ],
                  ),
                if (context.pageNumber == 1) pw.SizedBox(height: 4),
                if (data.filterNames != null)
                  pw.Row(children: [
                    pw.Icon(const pw.IconData(0xe85d),
                        font: ttfIcon, size: 12, color: PdfColors.grey800),
                    pw.SizedBox(width: 2),
                    pw.Text(
                      data.filterNames!,
                      style: pw.TextStyle(
                        fontSize: 9,
                        font: ttfMontserratRegular,
                      ),
                    ),
                  ]),
                pw.Divider(thickness: 1, color: PdfColors.grey400),
              ],
            );
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(
                  fontSize: 7,
                  font: ttfMontserratRegular,
                  color: PdfColors.grey600,
                ),
              ),
            );
          },
          build: (pw.Context context) {
            const rowsPerPage = 40;
            final widgets = <pw.Widget>[];

            for (var i = 0; i < serviceItems.length; i += rowsPerPage) {
              final end = i + rowsPerPage > serviceItems.length
                  ? serviceItems.length
                  : i + rowsPerPage;
              final chunk = serviceItems.sublist(i, end);

              widgets.add(
                _buildCustomTable(
                  chunk,
                  ttfMontserratRegular,
                  ttfMontserratMedium,
                  ttfMyanmar,
                  startIndex: i,
                  showHeader: i == 0,
                ),
              );
            }

            return widgets;
          },
        ),
      );

      final pdfBytes = await pdf.save();
      data.sendPort.send(pdfBytes);
    } catch (e) {
      data.sendPort.send(Exception('PDF generation failed: $e'));
    } finally {
      store?.close();
    }
  }

  // Custom table builder for Myanmar text support
  static pw.Widget _buildCustomTable(
    List<ServiceItem> serviceItems,
    pw.Font montserratRegular,
    pw.Font montserratBold,
    pw.Font myanmarFont, {
    int startIndex = 0,
    bool showHeader = true,
  }) {
    final headers = [
      '#',
      'Invoice ID',
      'Customer',
      'Device',
      'Error',
      'Expense',
      'Price',
      'Issue Date',
      'Status',
      'Location',
      'Delivery Date',
    ];

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(20),
      1: const pw.FixedColumnWidth(38),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(2),
      4: const pw.FlexColumnWidth(2),
      5: const pw.FlexColumnWidth(1),
      6: const pw.FlexColumnWidth(1),
      7: const pw.FlexColumnWidth(1),
      8: const pw.FlexColumnWidth(1),
      9: const pw.FlexColumnWidth(1),
      10: const pw.FlexColumnWidth(1),
    };

    final rows = <pw.TableRow>[];

    if (showHeader) {
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: headers
              .map(
                (header) => pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                      font: montserratBold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    rows.addAll(
      serviceItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final globalIndex = startIndex + index;

        final error = item.faults.map((e) => e.name).join(', ');
        final expense = item.expense == null ? '' : item.expense!.formatted();
        final price =
            item.servicePrice == null ? '' : item.servicePrice!.formatted();
        final issueDate = item.issueDate.formattedDate;
        final deliveryDate =
            item.deliveryDate == null ? '' : item.deliveryDate!.formattedDate;

        final rowData = [
          (globalIndex + 1).toString(),
          item.invoiceId.toString(),
          item.customerName,
          '${item.brand.target?.name ?? ''} ${item.model}',
          error,
          expense,
          price,
          issueDate,
          translate(item.status),
          translate(item.location),
          deliveryDate,
        ];

        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: globalIndex % 2 == 0 ? PdfColors.white : PdfColors.grey100,
          ),
          children: rowData.asMap().entries.map((cellEntry) {
            final columnIndex = cellEntry.key;
            final cellText = cellEntry.value;
            final containsMyanmar = _containsMyanmarText(cellText);

            pw.TextAlign alignment;
            switch (columnIndex) {
              case 0:
              case 7:
              case 8:
              case 9:
              case 10:
                alignment = pw.TextAlign.center;
                break;

              default:
                alignment = pw.TextAlign.left;
            }

            return pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              child: pw.Text(
                cellText,
                style: pw.TextStyle(
                  fontSize: 7,
                  font: containsMyanmar ? myanmarFont : montserratRegular,
                ),
                textAlign: alignment,
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
              ),
            );
          }).toList(),
        );
      }),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: columnWidths,
      children: rows,
    );
  }

  // Helper function to detect Myanmar text
  static bool _containsMyanmarText(String text) {
    // Myanmar Unicode range: U+1000 to U+109F
    for (int i = 0; i < text.length; i++) {
      int codeUnit = text.codeUnitAt(i);
      if (codeUnit >= 0x1000 && codeUnit <= 0x109F) {
        return true;
      }
    }
    return false;
  }
}

class FontData {
  final List<int> montserratRegular;
  final List<int> montserratMedium;
  final List<int> myanmarFont;
  final List<int> iconFont;

  FontData({
    required this.montserratRegular,
    required this.montserratMedium,
    required this.myanmarFont,
    required this.iconFont,
  });
}

class IsolateData {
  final SendPort sendPort;
  final List<int> serviceItemIds;
  final ByteData storeReference;
  final FontData fontData;
  final String? filterNames;

  IsolateData({
    required this.sendPort,
    required this.serviceItemIds,
    required this.storeReference,
    required this.fontData,
    this.filterNames,
  });
}
