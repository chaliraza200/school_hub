import 'dart:io';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptPrintService {
  static Future<bool> generateAndSaveReceiptPdf({
    required String receiptNo,
    required String studentName,
    required String rollNumber,
    required String className,
    required double amount,
    required String paymentMethod,
    required String date,
    String? referenceNo,
    String? remarks,
  }) async {
    try {
      final pdf = pw.Document();

      // Load Unicode fonts to eliminate Helvetica warnings
      final font = await PdfGoogleFonts.nunitoRegular();
      final boldFont = await PdfGoogleFonts.nunitoBold();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: boldFont,
          ),
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'SCHOOL HUB',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Official Fee Payment Receipt',
                          style: const pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 10),

                  // Receipt Meta
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Receipt No: $receiptNo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: $date'),
                    ],
                  ),
                  pw.SizedBox(height: 15),

                  // Student Details Container
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfRow('Student Name:', studentName),
                        pw.SizedBox(height: 6),
                        _pdfRow('Roll Number:', rollNumber),
                        pw.SizedBox(height: 6),
                        _pdfRow('Class:', className),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 15),

                  // Payment Details Box
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.green, width: 1.5),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Amount Paid:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Rs. ${amount.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _pdfRow('Payment Method:', paymentMethod),
                  if (referenceNo != null && referenceNo.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    _pdfRow('Reference No:', referenceNo),
                  ],
                  if (remarks != null && remarks.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    _pdfRow('Remarks:', remarks),
                  ],

                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 6),
                  pw.Center(
                    child: pw.Text(
                      'This is a computer-generated receipt and requires no signature.',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final Uint8List bytes = await pdf.save();
      final fileName = 'Fee_Receipt_$receiptNo.pdf';

      if (kIsWeb) {
        // Web: direct download
        await FileSaver.instance.saveFile(
          name: fileName.replaceAll('.pdf', ''),
          bytes: bytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );
      } else {
        // Mobile: Admin style native share sheet to choose destination
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Fee Receipt - $receiptNo',
        );
      }

      return true;
    } catch (e) {
      debugPrint('PDF Print Error: $e');
      return false;
    }
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
}