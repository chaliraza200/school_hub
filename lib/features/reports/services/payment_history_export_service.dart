import 'dart:io';
import 'dart:typed_data';
import 'package:excel_plus/excel_plus.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PaymentHistoryRecordModel {
  final String receiptNo;
  final String studentName;
  final String rollNumber;
  final String className;
  final double amount;
  final String date;
  final String paymentMethod;
  final String? referenceNo;
  final String? remarks;

  PaymentHistoryRecordModel({
    required this.receiptNo,
    required this.studentName,
    required this.rollNumber,
    required this.className,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.referenceNo,
    this.remarks,
  });
}

class PaymentHistoryExportService {
  static Future<bool> exportPaymentHistoryToExcel({
    required List<PaymentHistoryRecordModel> records,
  }) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Payment History'];

      try {
        excel.delete('Sheet1');
      } catch (_) {}

      List<String> headers = [
        'Receipt No',
        'Student Name',
        'Roll Number',
        'Class',
        'Amount (Rs.)',
        'Date',
        'Payment Method',
        'Reference No',
        'Remarks',
      ];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (var record in records) {
        sheetObject.appendRow([
          TextCellValue(record.receiptNo),
          TextCellValue(record.studentName),
          TextCellValue(record.rollNumber),
          TextCellValue(record.className),
          TextCellValue(record.amount.toStringAsFixed(0)),
          TextCellValue(record.date),
          TextCellValue(record.paymentMethod),
          TextCellValue(record.referenceNo ?? '-'),
          TextCellValue(record.remarks ?? '-'),
        ]);
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) {
        return false;
      }

      final fileName = 'Fee_Payment_History_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName.replaceAll('.xlsx', ''),
          bytes: Uint8List.fromList(fileBytes),
          fileExtension: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(fileBytes);

        // Explicit MIME type added so mobile share sheet shows file manager/save options
        await Share.shareXFiles(
          [
            XFile(
              file.path,
              mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              name: fileName,
            ),
          ],
          text: 'Fee Payment History Export',
        );
      }

      return true;
    } catch (e) {
      debugPrint('Excel Export Error: $e');
      return false;
    }
  }
}