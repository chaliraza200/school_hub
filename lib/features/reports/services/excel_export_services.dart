import 'dart:io';
import 'package:excel_plus/excel_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ReportType {
  studentList,
  teacherList,
  classAndStudentData,
  studentAttendance,
  teacherAttendance,
  feeRecords,
}

class ExcelExportService {
  static Future<File> generateAndSaveReport({
    required ReportType reportType,
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final excel = Excel.createExcel();
    final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final sheet = excel[sheetName];

    // Rename sheet safely
    excel.rename(sheetName, title.replaceAll(' ', '_'));

    // Insert Title Row (Row 1, Col A)
    sheet.updateCell(
      CellIndex.indexByString('A1'),
      TextCellValue(title),
      cellStyle: CellStyle(
        bold: true,
        fontSize: 14,
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('#2E7D32'),
        horizontalAlign: HorizontalAlign.Center,
      ),
    );

    // Insert Header Row at Row 3 (Index 2)
    for (int col = 0; col < headers.length; col++) {
      final cellIndex = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 2);
      sheet.updateCell(
        cellIndex,
        TextCellValue(headers[col]),
        cellStyle: CellStyle(
          bold: true,
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          backgroundColorHex: ExcelColor.fromHexString('#37474F'),
        ),
      );
    }

    // Insert Data Rows starting at Row 4 (Index 3)
    for (int r = 0; r < rows.length; r++) {
      final rowData = rows[r];
      for (int c = 0; c < rowData.length; c++) {
        final cellIndex = CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 3 + r);
        final val = rowData[c];

        if (val is num) {
          sheet.updateCell(cellIndex, DoubleCellValue(val.toDouble()));
        } else {
          sheet.updateCell(cellIndex, TextCellValue(val?.toString() ?? ''));
        }
      }
    }

    // Save to local temp directory
    final fileBytes = excel.save();
    if (fileBytes == null) {
      throw Exception('Failed to generate Excel file bytes.');
    }

    final outputDir = await getTemporaryDirectory();
    final fileName = 'SchoolHub_${title.replaceAll(' ', '')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('${outputDir.path}/$fileName');
    await file.writeAsBytes(fileBytes);

    return file;
  }

  static Future<void> shareReportFile(File file, String subject) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: 'School Hub Generated Report - Ready for Print & Record Keeping',
    );
  }
}