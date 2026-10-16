import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/attendance_model.dart';
import '../../domain/attendance_history_model.dart';

class AttendanceHistoryState {
  final String selectedClass;
  final String selectedSection;
  final DateTime? selectedDateFilter;
  final List<AttendanceHistoryRecord> historyRecords;
  final bool isLoading;
  final String? errorMessage;

  const AttendanceHistoryState({
    this.selectedClass = 'All Classes',
    this.selectedSection = 'All',
    this.selectedDateFilter,
    this.historyRecords = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AttendanceHistoryState copyWith({
    String? selectedClass,
    String? selectedSection,
    DateTime? selectedDateFilter,
    bool clearDateFilter = false,
    List<AttendanceHistoryRecord>? historyRecords,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AttendanceHistoryState(
      selectedClass: selectedClass ?? this.selectedClass,
      selectedSection: selectedSection ?? this.selectedSection,
      selectedDateFilter: clearDateFilter ? null : (selectedDateFilter ?? this.selectedDateFilter),
      historyRecords: historyRecords ?? this.historyRecords,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<AttendanceHistoryRecord> get filteredRecords {
    return historyRecords.where((record) {
      final matchesClass = selectedClass == 'All Classes' || record.className == selectedClass;
      final matchesSection = selectedSection == 'All' || record.section == selectedSection;

      bool matchesDate = true;
      if (selectedDateFilter != null) {
        matchesDate = record.date.year == selectedDateFilter!.year &&
            record.date.month == selectedDateFilter!.month &&
            record.date.day == selectedDateFilter!.day;
      }

      return matchesClass && matchesSection && matchesDate;
    }).toList();
  }

  int get totalStudentsCount {
    return filteredRecords.fold(0, (sum, record) => sum + record.totalStudents);
  }

  int get totalPresentCount {
    return filteredRecords.fold(0, (sum, record) => sum + record.presentCount);
  }

  int get totalAbsentCount {
    return filteredRecords.fold(0, (sum, record) => sum + record.absentCount);
  }

  int get totalNotMarkedCount {
    return filteredRecords.fold(0, (sum, record) => sum + record.notMarkedCount);
  }
}

class AttendanceHistoryNotifier extends StateNotifier<AttendanceHistoryState> {
  AttendanceHistoryNotifier({DateTime? initialDateFilter})
      : super(AttendanceHistoryState(selectedDateFilter: initialDateFilter)) {
    fetchAttendanceHistory();
  }

  Future<void> fetchAttendanceHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 350));

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      // Mock historical attendance logs
      final mockRecords = [
        AttendanceHistoryRecord(
          id: 'rec_today_10a',
          className: 'Grade 10',
          section: 'A',
          date: today,
          totalStudents: 4,
          presentCount: 3,
          absentCount: 1,
          notMarkedCount: 0,
          students: [
            const StudentAttendanceItem(studentId: 's1', studentName: 'Liam Johnson', rollNumber: 'RN-101', status: AttendanceStatus.present),
            const StudentAttendanceItem(studentId: 's2', studentName: 'Sophia Martinez', rollNumber: 'RN-102', status: AttendanceStatus.present),
            const StudentAttendanceItem(studentId: 's3', studentName: 'Noah Williams', rollNumber: 'RN-103', status: AttendanceStatus.absent),
            const StudentAttendanceItem(studentId: 's4', studentName: 'Emma Brown', rollNumber: 'RN-104', status: AttendanceStatus.present),
          ],
        ),
        AttendanceHistoryRecord(
          id: 'rec_today_9b',
          className: 'Grade 9',
          section: 'B',
          date: today,
          totalStudents: 3,
          presentCount: 2,
          absentCount: 0,
          notMarkedCount: 1,
          students: [
            const StudentAttendanceItem(studentId: 's5', studentName: 'Lucas Smith', rollNumber: 'RN-201', status: AttendanceStatus.present),
            const StudentAttendanceItem(studentId: 's6', studentName: 'Mia Davis', rollNumber: 'RN-202', status: AttendanceStatus.present),
            const StudentAttendanceItem(studentId: 's7', studentName: 'Ethan Wilson', rollNumber: 'RN-203', status: AttendanceStatus.notMarked),
          ],
        ),
        AttendanceHistoryRecord(
          id: 'rec_yest_10a',
          className: 'Grade 10',
          section: 'A',
          date: yesterday,
          totalStudents: 4,
          presentCount: 4,
          absentCount: 0,
          notMarkedCount: 0,
          students: [
            const StudentAttendanceItem(studentId: 's1', studentName: 'Liam Johnson', rollNumber: 'RN-101', status: AttendanceStatus.present),
            const StudentAttendanceItem(studentId: 's2', studentName: 'Sophia Martinez', rollNumber: 'RN-102', status: AttendanceStatus.present),
            const StudentAttendanceItem(studentId: 's3', studentName: 'Noah Williams', rollNumber: 'RN-103', status: AttendanceStatus.present),
            const StudentAttendanceItem(studentId: 's4', studentName: 'Emma Brown', rollNumber: 'RN-104', status: AttendanceStatus.present),
          ],
        ),
        AttendanceHistoryRecord(
          id: 'rec_past_8a',
          className: 'Grade 8',
          section: 'A',
          date: twoDaysAgo,
          totalStudents: 3,
          presentCount: 2,
          absentCount: 1,
          notMarkedCount: 0,
          students: [
            const StudentAttendanceItem(studentId: 's8', studentName: 'Olivia Taylor', rollNumber: 'RN-301', status: AttendanceStatus.present),
            const StudentAttendanceItem(studentId: 's9', studentName: 'James Anderson', rollNumber: 'RN-302', status: AttendanceStatus.absent),
            const StudentAttendanceItem(studentId: 's10', studentName: 'Ava Thomas', rollNumber: 'RN-303', status: AttendanceStatus.present),
          ],
        ),
      ];

      state = state.copyWith(historyRecords: mockRecords, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setClassFilter(String className) {
    state = state.copyWith(selectedClass: className);
  }

  void setSectionFilter(String section) {
    state = state.copyWith(selectedSection: section);
  }

  void setDateFilter(DateTime? date) {
    state = state.copyWith(selectedDateFilter: date, clearDateFilter: date == null);
  }
}

final attendanceHistoryProvider = StateNotifierProvider.family.autoDispose<
    AttendanceHistoryNotifier, AttendanceHistoryState, DateTime?>(
      (ref, initialDate) => AttendanceHistoryNotifier(initialDateFilter: initialDate),
);