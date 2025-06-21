import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/service_item.dart';
import '../utils/utils.dart';

class ServiceListPrinter {
  static Future<void> printServiceList(List<ServiceItem> serviceItems,
      {String? filterNames}) async {
    final pdf = pw.Document();

    // Load fonts
    final montserratRegular =
        await rootBundle.load('assets/fonts/Montserrat-Regular.ttf');
    final montserratMedium =
        await rootBundle.load('assets/fonts/Montserrat-Medium.ttf');
    final myanmarFont =
        await rootBundle.load('assets/fonts/NotoSansMyanmar-Regular.ttf');
    final iconFont =
        await rootBundle.load("assets/fonts/MaterialIcons-Regular.ttf");

    final ttfMontserratRegular = pw.Font.ttf(montserratRegular);
    final ttfMontserratMedium = pw.Font.ttf(montserratMedium);
    final ttfMyanmar = pw.Font.ttf(myanmarFont);
    final ttfIcon = pw.Font.ttf(iconFont);

    // Add pages with service data
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
              if (filterNames != null)
                pw.Row(children: [
                  pw.Icon(const pw.IconData(0xe85d),
                      font: ttfIcon, size: 12, color: PdfColors.grey800),
                  pw.SizedBox(width: 2),
                  pw.Text(
                    filterNames,
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
            margin: const pw.EdgeInsets.only(top: 4),
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
          return [
            // Custom Table for Myanmar text support
            _buildCustomTable(
              serviceItems,
              ttfMontserratRegular,
              ttfMontserratMedium,
              ttfMyanmar,
            ),
          ];
        },
      ),
    );

    // Print the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Custom table builder for Myanmar text support
  static pw.Widget _buildCustomTable(
    List<ServiceItem> serviceItems,
    pw.Font montserratRegular,
    pw.Font montserratBold,
    pw.Font myanmarFont,
  ) {
    final headers = [
      '#',
      'Invoice ID',
      'Customer',
      'Phone',
      'Device',
      'Issues',
      'SIM/SD',
      'Issue Date',
      'Status',
      'Location',
      'Delivery Date',
    ];

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(20),
      1: const pw.FixedColumnWidth(40),
      2: const pw.FlexColumnWidth(2),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(2),
      5: const pw.FlexColumnWidth(2),
      6: const pw.FlexColumnWidth(1),
      7: const pw.FlexColumnWidth(1),
      8: const pw.FlexColumnWidth(1),
      9: const pw.FlexColumnWidth(1),
      10: const pw.FlexColumnWidth(1),
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: columnWidths,
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: headers
              .map((header) => pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                        font: montserratBold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ))
              .toList(),
        ),

        // Data rows
        ...serviceItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          final phoneNumber =
              item.phoneNumber == 'null' ? '' : item.phoneNumber.toString();
          final error = item.faults.map((e) => e.name).join(', ');
          final issueDate = item.issueDate.formattedDate;
          final deliveryDate =
              item.deliveryDate == null ? '' : item.deliveryDate!.formattedDate;

          final rowData = [
            (index + 1).toString(),
            item.invoiceId.toString(),
            item.customerName,
            phoneNumber,
            '${item.brand.target?.name ?? ''} ${item.model}',
            error,
            item.simAndSd,
            issueDate,
            translate(item.status),
            translate(item.location),
            deliveryDate,
          ];

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.white : PdfColors.grey100,
            ),
            children: rowData.asMap().entries.map((cellEntry) {
              final columnIndex = cellEntry.key;
              final cellText = cellEntry.value;
              final containsMyanmar = _containsMyanmarText(cellText);

              pw.TextAlign alignment;
              switch (columnIndex) {
                case 0: // #
                case 7: // Issue Date
                case 8: // Status
                case 9: // Location
                case 10: // Delivery Date
                  alignment = pw.TextAlign.center;
                  break;

                default:
                  alignment = pw.TextAlign.left;
              }

              return pw.Container(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text(
                  cellText,
                  style: pw.TextStyle(
                    fontSize: 7,
                    font: containsMyanmar ? myanmarFont : montserratRegular,
                  ),
                  textAlign: alignment,
                ),
              );
            }).toList(),
          );
        }),
      ],
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

  static Future<void> savePdfToFile(List<ServiceItem> serviceItems,
      {String? filterNames}) async {
    final pdf = pw.Document();

    final output = await getApplicationDocumentsDirectory();
    final DateFormat format = DateFormat('yyyy_MMM_dd_h_mm_a');
    final file = File(
        '${output.path}/service_items_${format.format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }
}
