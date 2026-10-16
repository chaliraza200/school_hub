import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AttendanceDetailItem {
  final String studentName;
  final String rollNumber;
  final bool isPresent;

  AttendanceDetailItem({
    required this.studentName,
    required this.rollNumber,
    required this.isPresent,
  });
}

class AttendanceHistoryRecord {
  final String date;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final List<AttendanceDetailItem> details;

  AttendanceHistoryRecord({
    required this.date,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.details,
  });
}

class TeacherAttendanceHistoryState {
  final bool isLoading;
  final String assignedClass;
  final List<AttendanceHistoryRecord> records;
  final String? errorMessage;

  TeacherAttendanceHistoryState({
    this.isLoading = false,
    this.assignedClass = 'Grade 10 - Section A',
    this.records = const [],
    this.errorMessage,
  });

  TeacherAttendanceHistoryState copyWith({
    bool? isLoading,
    String? assignedClass,
    List<AttendanceHistoryRecord>? records,
    String? errorMessage,
  }) {
    return TeacherAttendanceHistoryState(
      isLoading: isLoading ?? this.isLoading,
      assignedClass: assignedClass ?? this.assignedClass,
      records: records ?? this.records,
      errorMessage: errorMessage,
    );
  }
}

class TeacherAttendanceHistoryNotifier
    extends StateNotifier<TeacherAttendanceHistoryState> {
  TeacherAttendanceHistoryNotifier()
      : super(TeacherAttendanceHistoryState()) {
    loadAttendanceHistory();
  }

  Future<void> loadAttendanceHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Backend-ready simulation for fetching assigned class attendance history
      await Future.delayed(const Duration(milliseconds: 700));

      final mockRecords = [
        AttendanceHistoryRecord(
          date: '03 Oct 2026',
          totalStudents: 40,
          presentCount: 36,
          absentCount: 4,
          details: [
            AttendanceDetailItem(studentName: 'Ali Khan', rollNumber: '101', isPresent: true),
            AttendanceDetailItem(studentName: 'Fatima Ahmed', rollNumber: '102', isPresent: true),
            AttendanceDetailItem(studentName: 'Bilal Raza', rollNumber: '103', isPresent: false),
            AttendanceDetailItem(studentName: 'Ayesha Noor', rollNumber: '104', isPresent: false),
          ],
        ),
        AttendanceHistoryRecord(
          date: '02 Oct 2026',
          totalStudents: 40,
          presentCount: 38,
          absentCount: 2,
          details: [
            AttendanceDetailItem(studentName: 'Ali Khan', rollNumber: '101', isPresent: true),
            AttendanceDetailItem(studentName: 'Fatima Ahmed', rollNumber: '102', isPresent: true),
            AttendanceDetailItem(studentName: 'Bilal Raza', rollNumber: '103', isPresent: true),
            AttendanceDetailItem(studentName: 'Ayesha Noor', rollNumber: '104', isPresent: false),
          ],
        ),
        AttendanceHistoryRecord(
          date: '01 Oct 2026',
          totalStudents: 40,
          presentCount: 35,
          absentCount: 5,
          details: [
            AttendanceDetailItem(studentName: 'Ali Khan', rollNumber: '101', isPresent: true),
            AttendanceDetailItem(studentName: 'Fatima Ahmed', rollNumber: '102', isPresent: false),
            AttendanceDetailItem(studentName: 'Bilal Raza', rollNumber: '103', isPresent: true),
            AttendanceDetailItem(studentName: 'Ayesha Noor', rollNumber: '104', isPresent: true),
          ],
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        records: mockRecords,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error in loading Attendance history.',
      );
    }
  }
}

final teacherAttendanceHistoryProvider = StateNotifierProvider.autoDispose<
    TeacherAttendanceHistoryNotifier, TeacherAttendanceHistoryState>(
      (ref) => TeacherAttendanceHistoryNotifier(),
);