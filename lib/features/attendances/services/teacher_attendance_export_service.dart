import 'dart:io';
import 'dart:typed_data';
import 'package:excel_plus/excel_plus.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../presentation/providers/teacher_dashboard_attendance_history_provider.dart';

class TeacherAttendanceExportService {
  static Future<bool> exportAttendanceToExcel({
    required String assignedClass,
    required List<AttendanceHistoryRecord> records,
  }) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Attendance History'];

      try {
        excel.delete('Sheet1');
      } catch (_) {}

      List<String> headers = [
        'Date',
        'Student Name',
        'Roll Number',
        'Status',
        'Class',
        'Total Present',
        'Total Absent'
      ];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (var record in records) {
        if (record.details.isNotEmpty) {
          for (var detail in record.details) {
            sheetObject.appendRow([
              TextCellValue(record.date),
              TextCellValue(detail.studentName),
              TextCellValue(detail.rollNumber),
              TextCellValue(detail.isPresent ? 'Present' : 'Absent'),
              TextCellValue(assignedClass),
              TextCellValue(record.presentCount.toString()),
              TextCellValue(record.absentCount.toString()),
            ]);
          }
        } else {
          sheetObject.appendRow([
            TextCellValue(record.date),
            TextCellValue('N/A'),
            TextCellValue('N/A'),
            TextCellValue('Summary'),
            TextCellValue(assignedClass),
            TextCellValue(record.presentCount.toString()),
            TextCellValue(record.absentCount.toString()),
          ]);
        }
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) {
        return false;
      }

      final fileName = 'Teacher_Attendance_${assignedClass.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

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

        // Explicit MIME type added to reveal file saving & manager options in share sheet
        await Share.shareXFiles(
          [
            XFile(
              file.path,
              mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              name: fileName,
            ),
          ],
          text: 'Teacher Attendance Export - $assignedClass',
        );
      }

      return true;
    } catch (e) {
      debugPrint('Teacher Export Error: $e');
      return false;
    }
  }
}