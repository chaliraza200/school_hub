import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/teacher_attendance_model.dart';

class TeacherAttendanceState {
  final DateTime selectedDate;
  final TeacherAttendanceRecord? attendanceRecord;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isSuccess;

  const TeacherAttendanceState({
    required this.selectedDate,
    this.attendanceRecord,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  TeacherAttendanceState copyWith({
    DateTime? selectedDate,
    TeacherAttendanceRecord? attendanceRecord,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return TeacherAttendanceState(
      selectedDate: selectedDate ?? this.selectedDate,
      attendanceRecord: attendanceRecord ?? this.attendanceRecord,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class TeacherAttendanceNotifier extends StateNotifier<TeacherAttendanceState> {
  TeacherAttendanceNotifier() : super(TeacherAttendanceState(selectedDate: DateTime.now())) {
    fetchTeacherAttendanceForDate(state.selectedDate);
  }

  Future<void> fetchTeacherAttendanceForDate(DateTime date) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false, selectedDate: date);
    try {
      // Simulate network / database fetch delay
      await Future.delayed(const Duration(milliseconds: 350));

      // Mock teacher roster for attendance tracking
      final mockTeachers = [
        const TeacherAttendanceItem(
          teacherId: 't1',
          teacherName: 'Dr. Eleanor Vance',
          employeeId: 'EMP-101',
          assignedClass: 'Grade 10 - Sec A',
          status: TeacherAttendanceStatus.present,
        ),
        const TeacherAttendanceItem(
          teacherId: 't2',
          teacherName: 'Prof. Marcus Brody',
          employeeId: 'EMP-102',
          assignedClass: 'Grade 9 - Sec B',
          status: TeacherAttendanceStatus.present,
        ),
        const TeacherAttendanceItem(
          teacherId: 't3',
          teacherName: 'Sarah Jenkins',
          employeeId: 'EMP-103',
          assignedClass: 'Grade 8 - Sec A',
          status: TeacherAttendanceStatus.absent,
        ),
        const TeacherAttendanceItem(
          teacherId: 't4',
          teacherName: 'David Sterling',
          employeeId: 'EMP-104',
          assignedClass: 'Grade 10 - Sec B',
          status: TeacherAttendanceStatus.notMarked,
        ),
      ];

      final record = TeacherAttendanceRecord(date: date, teachers: mockTeachers);
      state = state.copyWith(attendanceRecord: record, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setTeacherStatus(String teacherId, TeacherAttendanceStatus status) {
    final record = state.attendanceRecord;
    if (record == null) return;

    final updatedTeachers = record.teachers.map((teacher) {
      if (teacher.teacherId == teacherId) {
        return teacher.copyWith(status: status);
      }
      return teacher;
    }).toList();

    state = state.copyWith(
      attendanceRecord: record.copyWith(teachers: updatedTeachers),
      isSuccess: false,
    );
  }

  void markAllPresent() {
    final record = state.attendanceRecord;
    if (record == null) return;

    final updatedTeachers = record.teachers.map((teacher) {
      return teacher.copyWith(status: TeacherAttendanceStatus.present);
    }).toList();

    state = state.copyWith(
      attendanceRecord: record.copyWith(teachers: updatedTeachers),
      isSuccess: false,
    );
  }

  Future<void> saveAttendance({required VoidCallback onSuccess}) async {
    if (state.isSaving || state.attendanceRecord == null) return;

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      // Simulate Firestore / backend persistence delay
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: Connect Firebase teacher attendance persistence here later without changing UI widgets
      state = state.copyWith(isSaving: false, isSuccess: true);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }
}

final teacherAttendanceProvider = StateNotifierProvider.autoDispose<TeacherAttendanceNotifier, TeacherAttendanceState>(
      (ref) => TeacherAttendanceNotifier(),
);