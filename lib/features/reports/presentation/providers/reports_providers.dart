import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../services/excel_export_services.dart';

class ReportsState {
  final bool isExporting;
  final String? successMessage;
  final String? errorMessage;

  // Filters
  final String? selectedClass;
  final String? selectedSection;
  final String? selectedStatus;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportsState({
    this.isExporting = false,
    this.successMessage,
    this.errorMessage,
    this.selectedClass,
    this.selectedSection,
    this.selectedStatus,
    this.startDate,
    this.endDate,
  });

  ReportsState copyWith({
    bool? isExporting,
    String? successMessage,
    String? errorMessage,
    String? selectedClass,
    bool clearClass = false,
    String? selectedSection,
    bool clearSection = false,
    String? selectedStatus,
    bool clearStatus = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
  }) {
    return ReportsState(
      isExporting: isExporting ?? this.isExporting,
      successMessage: successMessage,
      errorMessage: errorMessage,
      selectedClass: clearClass ? null : (selectedClass ?? this.selectedClass),
      selectedSection: clearSection ? null : (selectedSection ?? this.selectedSection),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier() : super(const ReportsState());

  void setClassFilter(String? val) => state = state.copyWith(selectedClass: val, clearClass: val == null);
  void setSectionFilter(String? val) => state = state.copyWith(selectedSection: val, clearSection: val == null);
  void setStatusFilter(String? val) => state = state.copyWith(selectedStatus: val, clearStatus: val == null);
  void setDateRange(DateTime? start, DateTime? end) => state = state.copyWith(
    startDate: start,
    clearStartDate: start == null,
    endDate: end,
    clearEndDate: end == null,
  );

  Future<void> exportReport(ReportType type) async {
    state = state.copyWith(isExporting: true, successMessage: null, errorMessage: null);

    try {
      // Mock data payload filtered based on current state parameters
      // Future integration: fetch real filtered data from repository matching Firebase collections
      String title = '';
      List<String> headers = [];
      List<List<dynamic>> rows = [];

      switch (type) {
        case ReportType.studentList:
          title = 'Student List Report';
          headers = ['ID', 'Name', 'Class', 'Section', 'Status'];
          rows = [
            ['STU-101', 'Liam Johnson', 'Grade 10', 'A', 'Active'],
            ['STU-102', 'Sophia Martinez', 'Grade 10', 'B', 'Active'],
            ['STU-103', 'Noah Williams', 'Grade 9', 'A', 'Active'],
            ['STU-104', 'Emma Brown', 'Grade 8', 'A', 'Inactive'],
          ];
          break;
        case ReportType.teacherList:
          title = 'Teacher List Report';
          headers = ['ID', 'Name', 'Subject', 'Department', 'Status'];
          rows = [
            ['TCH-01', 'Dr. Aris Thorne', 'Mathematics', 'Science', 'Active'],
            ['TCH-02', 'Prof. Sarah Jenkins', 'English Literature', 'Humanities', 'Active'],
            ['TCH-03', 'Mr. David Vance', 'Physics', 'Science', 'Active'],
          ];
          break;
        case ReportType.classAndStudentData:
          title = 'Class & Student Data Report';
          headers = ['Class Name', 'Section', 'Total Students', 'Class Teacher', 'Room No'];
          rows = [
            ['Grade 10', 'A', '35', 'Dr. Aris Thorne', 'Room 101'],
            ['Grade 10', 'B', '32', 'Prof. Sarah Jenkins', 'Room 102'],
            ['Grade 9', 'A', '30', 'Mr. David Vance', 'Room 201'],
          ];
          break;
        case ReportType.studentAttendance:
          title = 'Student Attendance Report';
          headers = ['Date', 'Student ID', 'Student Name', 'Class', 'Status'];
          rows = [
            ['2026-10-02', 'STU-101', 'Liam Johnson', 'Grade 10', 'Present'],
            ['2026-10-02', 'STU-102', 'Sophia Martinez', 'Grade 10', 'Absent'],
            ['2026-10-02', 'STU-103', 'Noah Williams', 'Grade 9', 'Present'],
          ];
          break;
        case ReportType.teacherAttendance:
          title = 'Teacher Attendance Report';
          headers = ['Date', 'Teacher ID', 'Teacher Name', 'Department', 'Status'];
          rows = [
            ['2026-10-02', 'TCH-01', 'Dr. Aris Thorne', 'Science', 'Present'],
            ['2026-10-02', 'TCH-02', 'Prof. Sarah Jenkins', 'Humanities', 'Present'],
            ['2026-10-02', 'TCH-03', 'Mr. David Vance', 'Science', 'Late'],
          ];
          break;
        case ReportType.feeRecords:
          title = 'Fee Records Report (PKR)';
          headers = ['Student ID', 'Student Name', 'Class', 'Monthly Fee', 'Paid', 'Pending', 'Status'];
          rows = [
            ['STU-101', 'Liam Johnson', 'Grade 10', 25000, 25000, 0, 'Paid'],
            ['STU-102', 'Sophia Martinez', 'Grade 10', 25000, 10000, 15000, 'Partial'],
            ['STU-103', 'Noah Williams', 'Grade 9', 22000, 0, 22000, 'Pending'],
          ];
          break;
      }

      final file = await ExcelExportService.generateAndSaveReport(
        reportType: type,
        title: title,
        headers: headers,
        rows: rows,
      );

      await ExcelExportService.shareReportFile(file, title);

      state = state.copyWith(
        isExporting: false,
        successMessage: 'Successfully exported "$title" (.xlsx)! Ready for printing.',
      );
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: 'Export failed: $e',
      );
    }
  }
}

final reportsProvider = StateNotifierProvider.autoDispose<ReportsNotifier, ReportsState>(
      (ref) => ReportsNotifier(),
);