import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class StudentAttendanceItem {
  final String id;
  final String name;
  final String rollNumber;
  final bool isPresent;

  StudentAttendanceItem({
    required this.id,
    required this.name,
    required this.rollNumber,
    this.isPresent = true,
  });

  StudentAttendanceItem copyWith({bool? isPresent}) {
    return StudentAttendanceItem(
      id: id,
      name: name,
      rollNumber: rollNumber,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}

class TeacherDashboardAttendanceState {
  final bool isLoading;
  final bool isSaving;
  final DateTime selectedDate;
  final String assignedClass;
  final List<StudentAttendanceItem> students;
  final String? errorMessage;
  final String? successMessage;

  TeacherDashboardAttendanceState({
    this.isLoading = false,
    this.isSaving = false,
    required this.selectedDate,
    this.assignedClass = 'Grade 10 - Section A',
    this.students = const [],
    this.errorMessage,
    this.successMessage,
  });

  TeacherDashboardAttendanceState copyWith({
    bool? isLoading,
    bool? isSaving,
    DateTime? selectedDate,
    String? assignedClass,
    List<StudentAttendanceItem>? students,
    String? errorMessage,
    String? successMessage,
  }) {
    return TeacherDashboardAttendanceState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      selectedDate: selectedDate ?? this.selectedDate,
      assignedClass: assignedClass ?? this.assignedClass,
      students: students ?? this.students,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  int get totalStudents => students.length;
  int get presentCount => students.where((s) => s.isPresent).length;
  int get absentCount => students.where((s) => !s.isPresent).length;
}

class TeacherDashboardAttendanceNotifier
    extends StateNotifier<TeacherDashboardAttendanceState> {
  TeacherDashboardAttendanceNotifier()
      : super(TeacherDashboardAttendanceState(selectedDate: DateTime.now())) {
    loadAssignedClassStudents();
  }

  Future<void> loadAssignedClassStudents() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final mockStudents = [
        StudentAttendanceItem(id: '1', name: 'Ali Khan', rollNumber: '101', isPresent: true),
        StudentAttendanceItem(id: '2', name: 'Fatima Ahmed', rollNumber: '102', isPresent: true),
        StudentAttendanceItem(id: '3', name: 'Bilal Raza', rollNumber: '103', isPresent: false),
        StudentAttendanceItem(id: '4', name: 'Ayesha Noor', rollNumber: '104', isPresent: true),
        StudentAttendanceItem(id: '5', name: 'Usman Tariq', rollNumber: '105', isPresent: true),
      ];

      state = state.copyWith(
        isLoading: false,
        students: mockStudents,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Students load karne mein nakaami hui.',
      );
    }
  }

  void updateDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void toggleAttendance(String studentId) {
    final updatedStudents = state.students.map((student) {
      if (student.id == studentId) {
        return student.copyWith(isPresent: !student.isPresent);
      }
      return student;
    }).toList();

    state = state.copyWith(students: updatedStudents);
  }

  void markAllPresent() {
    final updatedStudents = state.students.map((student) {
      return student.copyWith(isPresent: true);
    }).toList();

    state = state.copyWith(students: updatedStudents);
  }

  Future<bool> saveAttendance() async {
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    try {
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Attendance has been successfully saved!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error in saving Attendance!',
      );
      return false;
    }
  }
}

final teacherDashboardAttendanceProvider = StateNotifierProvider.autoDispose<
    TeacherDashboardAttendanceNotifier, TeacherDashboardAttendanceState>(
      (ref) => TeacherDashboardAttendanceNotifier(),
);