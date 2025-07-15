import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../models/service_item.dart';
import '../utils/utils.dart';

class ServiceListExcelExporter {
  static Future<void> exportToExcel(
    List<ServiceItem> serviceItems, {
    String? filterNames,
  }) async {
    try {
      final excel = Excel.createExcel();

      excel.rename('Sheet1', 'Service List Report');
      final sheet = excel['Service List Report'];

      // Set up headers
      final headers = [
        '#',
        'Invoice ID',
        'Customer',
        'Phone',
        'Brand',
        'Model',
        'IMEI',
        'Error',
        'Expense',
        'Price',
        'Issue Date',
        'Status',
        'Location',
        'Delivery Date',
        'Technician',
        'SIM/SD',
        'Remark',
      ];

      // Add title and filter info
      int currentRow = 0;

      // Title
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue('Service List Report');
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .cellStyle = CellStyle(
        fontSize: 16,
        bold: true,
      );
      currentRow++;

      // Total count
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue('Total Items: ${serviceItems.length}');
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .cellStyle = CellStyle(fontSize: 12);
      currentRow++;

      // Filter info
      if (filterNames != null) {
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: currentRow))
            .value = TextCellValue('Filter: $filterNames');
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: currentRow))
            .cellStyle = CellStyle(fontSize: 10, italic: true);
        currentRow++;
      }

      // Generated date
      sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: currentRow))
              .value =
          TextCellValue(
              'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .cellStyle = CellStyle(fontSize: 10);
      currentRow++;

      // Empty row
      currentRow++;

      // Add headers
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#E0E0E0'),
          horizontalAlign: HorizontalAlign.Center,
        );
      }
      currentRow++;

      // Add data rows
      for (int itemIndex = 0; itemIndex < serviceItems.length; itemIndex++) {
        final item = serviceItems[itemIndex];

        final phoneNumber = item.phoneNumber == 'null' ? '' : item.phoneNumber;
        final issues = item.faults.map((e) => e.name).join(', ');
        final issueDate = item
            .issueDate.formattedDate; // Assuming formattedDate extension exists
        final deliveryDate = item.deliveryDate?.formattedDate ?? '';
        final technician = item.technician.target?.name ?? '';
        final brandName = item.brand.target?.name ?? '';

        final rowData = [
          itemIndex + 1,
          item.invoiceId,
          item.customerName,
          phoneNumber,
          brandName,
          item.model,
          item.imei,
          issues,
          item.expense,
          item.servicePrice,
          issueDate,
          translate(item.status),
          translate(item.location),
          deliveryDate,
          technician,
          item.simAndSd,
          item.remark ?? '',
        ];

        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: colIndex, rowIndex: currentRow));

          // Set cell value based on data type
          final value = rowData[colIndex];
          if (value is int) {
            cell.value = IntCellValue(value);
          } else if (value is double) {
            cell.value = DoubleCellValue(value);
          } else if (value is String) {
            cell.value = TextCellValue(value);
          } else if (value != null) {
            cell.value = TextCellValue(value.toString());
          } else {
            cell.value = TextCellValue('');
          }

          // Apply alternating row colors
          if (itemIndex % 2 == 0) {
            cell.cellStyle = CellStyle(
                backgroundColorHex: ExcelColor.fromHexString('#F5F5F5'));
          }

          // Center align specific columns
          if ([0, 1, 8, 9, 10, 11, 12, 14, 15].contains(colIndex)) {
            cell.cellStyle = CellStyle(
              horizontalAlign: HorizontalAlign.Center,
              backgroundColorHex: itemIndex % 2 == 0
                  ? ExcelColor.fromHexString('#F5F5F5')
                  : ExcelColor.white,
            );
          }
        }
        currentRow++;
      }

      // Auto-fit columns (approximate)
      _autoFitColumns(sheet, headers.length);

      // Save file
      final bytes = excel.save();
      if (bytes != null) {
        final DateFormat format = DateFormat('yyyy_MMM_dd_h_mm_a');
        final defaultFileName =
            'service_list_report_${format.format(DateTime.now())}.xlsx';

        // Let user pick a location to save the file
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Service List Report',
          fileName: defaultFileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsBytes(Uint8List.fromList(bytes));
          await OpenFile.open(file.path);
        } else {
          debugPrint('Save cancelled');
        }
      }
    } catch (e) {
      debugPrint('There is an error to export excel: $e');
      rethrow;
    }
  }

  // Helper method to auto-fit columns (approximate)
  static void _autoFitColumns(Sheet sheet, int columnCount) {
    // Set approximate column widths based on content
    final columnWidths = [
      5, // #
      10, // Invoice ID
      20, // Customer
      15, // Phone
      12, // Brand
      20, // Model
      10, // IMEI
      20, // Issues
      10, // Expense
      10, // Price
      12, // Issue Date
      12, // Status
      12, // Location
      12, // Delivery Date
      16, // Technician
      8, // SIM/SD
      20, // Remark
    ];

    for (int i = 0; i < columnCount && i < columnWidths.length; i++) {
      sheet.setColumnWidth(i, columnWidths[i].toDouble());
    }
  }
}

// Extension to add more Excel export options
extension ServiceListExcelExtensions on ServiceListExcelExporter {
  // Export with custom styling
  static Future<void> exportWithCustomStyling(
    List<ServiceItem> serviceItems, {
    String? filterNames,
    String? title,
    bool includeCharts = false,
  }) async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['Service Report'];

      // Custom title
      final reportTitle = title ?? 'Service List Report';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = TextCellValue(reportTitle);

      // Add summary statistics
      _addSummarySection(sheet, serviceItems);

      // Add main data table starting from row 8
      await _addDataTable(sheet, serviceItems, startRow: 8);

      // Save with custom filename
      final output = await getApplicationDocumentsDirectory();
      final fileName =
          '${title?.replaceAll(' ', '_').toLowerCase() ?? 'service_report'}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
      final file = File('${output.path}/$fileName');

      final bytes = excel.save();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        await OpenFile.open(file.path);
      }
    } catch (e) {
      rethrow;
    }
  }

  static void _addSummarySection(Sheet sheet, List<ServiceItem> serviceItems) {
    // Status summary
    final statusCount = <String, int>{};
    final locationCount = <String, int>{};

    for (final item in serviceItems) {
      statusCount[item.status] = (statusCount[item.status] ?? 0) + 1;
      locationCount[item.location] = (locationCount[item.location] ?? 0) + 1;
    }

    int row = 2;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Status Summary:');
    row++;

    for (final entry in statusCount.entries) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue('${translate(entry.key)}: ${entry.value}');
      row++;
    }

    row++;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Location Summary:');
    row++;

    for (final entry in locationCount.entries) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue('${translate(entry.key)}: ${entry.value}');
      row++;
    }
  }

  static Future<void> _addDataTable(Sheet sheet, List<ServiceItem> serviceItems,
      {int startRow = 0}) async {
    // Similar to main export function but starting from specified row
    final headers = [
      '#',
      'Invoice ID',
      'Customer',
      'Phone',
      'Brand',
      'Model',
      'IMEI',
      'Issues',
      'SIM/SD',
      'Issue Date',
      'Status',
      'Location',
      'Delivery Date',
      'Technician',
      'Expense',
      'Service Price',
      'Remark'
    ];

    // Add headers
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: startRow));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
    }

    // Add data (similar to main function)
    for (int itemIndex = 0; itemIndex < serviceItems.length; itemIndex++) {
      final item = serviceItems[itemIndex];
      final row = startRow + 1 + itemIndex;

      final rowData = [
        itemIndex + 1,
        item.invoiceId,
        item.customerName,
        item.phoneNumber == 'null' ? '' : item.phoneNumber,
        item.brand.target?.name ?? '',
        item.model,
        item.imei,
        item.faults.map((e) => e.name).join(', '),
        item.expense,
        item.servicePrice,
        item.issueDate,
        translate(item.status),
        translate(item.location),
        item.deliveryDate ?? '',
        item.technician.target?.name ?? '',
        item.simAndSd,
        item.remark ?? '',
      ];

      for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: row));

        final value = rowData[colIndex];
        if (value is int) {
          cell.value = IntCellValue(value);
        } else if (value is double) {
          cell.value = DoubleCellValue(value);
        } else if (value is String) {
          cell.value = TextCellValue(value);
        } else if (value != null) {
          cell.value = TextCellValue(value.toString());
        } else {
          cell.value = TextCellValue('');
        }
      }
    }
  }
}
