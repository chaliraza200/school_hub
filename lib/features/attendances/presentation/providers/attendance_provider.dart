import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/attendance_model.dart';

class AttendanceState {
  final String selectedClass;
  final String selectedSection;
  final DateTime selectedDate;
  final ClassAttendanceRecord? attendanceRecord;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isSuccess;

  const AttendanceState({
    this.selectedClass = 'Grade 10',
    this.selectedSection = 'A',
    required this.selectedDate,
    this.attendanceRecord,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  AttendanceState copyWith({
    String? selectedClass,
    String? selectedSection,
    DateTime? selectedDate,
    ClassAttendanceRecord? attendanceRecord,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return AttendanceState(
      selectedClass: selectedClass ?? this.selectedClass,
      selectedSection: selectedSection ?? this.selectedSection,
      selectedDate: selectedDate ?? this.selectedDate,
      attendanceRecord: attendanceRecord ?? this.attendanceRecord,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(AttendanceState(selectedDate: DateTime.now())) {
    fetchAttendanceForSelection();
  }

  Future<void> fetchAttendanceForSelection() async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      // Simulate fetch delay
      await Future.delayed(const Duration(milliseconds: 350));

      // Mock student roster for the selected class & section
      final mockStudents = [
        const StudentAttendanceItem(
          studentId: 's1',
          studentName: 'Liam Johnson',
          rollNumber: 'RN-101',
          status: AttendanceStatus.present,
        ),
        const StudentAttendanceItem(
          studentId: 's2',
          studentName: 'Sophia Martinez',
          rollNumber: 'RN-102',
          status: AttendanceStatus.present,
        ),
        const StudentAttendanceItem(
          studentId: 's3',
          studentName: 'Noah Williams',
          rollNumber: 'RN-103',
          status: AttendanceStatus.absent,
        ),
        const StudentAttendanceItem(
          studentId: 's4',
          studentName: 'Emma Brown',
          rollNumber: 'RN-104',
          status: AttendanceStatus.notMarked,
        ),
      ];

      final record = ClassAttendanceRecord(
        classId: 'c1',
        className: state.selectedClass,
        section: state.selectedSection,
        date: state.selectedDate,
        students: mockStudents,
      );

      state = state.copyWith(attendanceRecord: record, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateClassSelection(String className) {
    state = state.copyWith(selectedClass: className);
    fetchAttendanceForSelection();
  }

  void updateSectionSelection(String section) {
    state = state.copyWith(selectedSection: section);
    fetchAttendanceForSelection();
  }

  void updateDateSelection(DateTime date) {
    state = state.copyWith(selectedDate: date);
    fetchAttendanceForSelection();
  }

  void setStudentStatus(String studentId, AttendanceStatus status) {
    final record = state.attendanceRecord;
    if (record == null) return;

    final updatedStudents = record.students.map((student) {
      if (student.studentId == studentId) {
        return student.copyWith(status: status);
      }
      return student;
    }).toList();

    state = state.copyWith(
      attendanceRecord: record.copyWith(students: updatedStudents),
      isSuccess: false,
    );
  }

  void markAllPresent() {
    final record = state.attendanceRecord;
    if (record == null) return;

    final updatedStudents = record.students.map((student) {
      return student.copyWith(status: AttendanceStatus.present);
    }).toList();

    state = state.copyWith(
      attendanceRecord: record.copyWith(students: updatedStudents),
      isSuccess: false,
    );
  }

  Future<void> saveAttendance({required VoidCallback onSuccess}) async {
    if (state.isSaving || state.attendanceRecord == null) return;

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      // Simulate backend/Firestore write latency
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: Connect Firebase attendance persistence here later without changing UI widgets
      state = state.copyWith(isSaving: false, isSuccess: true);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }
}

final attendanceProvider = StateNotifierProvider.autoDispose<AttendanceNotifier, AttendanceState>(
      (ref) => AttendanceNotifier(),
);