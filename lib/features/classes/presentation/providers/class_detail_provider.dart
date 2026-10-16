import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/class_model_dart.dart';

class ClassDetailState {
  final AsyncValue<SchoolClass> classAsync;
  final List<String> enrolledStudents;
  final bool isDeleting;
  final String? errorMessage;

  const ClassDetailState({
    required this.classAsync,
    this.enrolledStudents = const [],
    this.isDeleting = false,
    this.errorMessage,
  });

  ClassDetailState copyWith({
    AsyncValue<SchoolClass>? classAsync,
    List<String>? enrolledStudents,
    bool? isDeleting,
    String? errorMessage,
  }) {
    return ClassDetailState(
      classAsync: classAsync ?? this.classAsync,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
    );
  }
}

class ClassDetailNotifier extends StateNotifier<ClassDetailState> {
  final String classId;

  ClassDetailNotifier({required this.classId})
      : super(const ClassDetailState(classAsync: AsyncValue.loading())) {
    fetchClassDetail();
  }

  Future<void> fetchClassDetail() async {
    state = state.copyWith(classAsync: const AsyncValue.loading());
    try {
      // Simulate backend fetch delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock class entity
      final schoolClass = SchoolClass(
        id: classId,
        className: 'Grade 10',
        section: 'A',
        classTeacherName: 'Dr. Eleanor Vance',
        studentCount: 4,
        status: ClassStatus.active,
        academicYear: '2026 - 2027',
      );

      // Mock students belonging to this class (contained within class module)
      final mockStudents = [
        'Liam Johnson',
        'Sophia Martinez',
        'Noah Williams',
        'Emma Brown',
      ];

      state = state.copyWith(
        classAsync: AsyncValue.data(schoolClass),
        enrolledStudents: mockStudents,
      );
    } catch (e, st) {
      state = state.copyWith(classAsync: AsyncValue.error(e, st));
    }
  }

  Future<void> toggleClassStatus() async {
    final currentState = state.classAsync.value;
    if (currentState == null) return;

    final newStatus = currentState.status == ClassStatus.active
        ? ClassStatus.inactive
        : ClassStatus.active;

    state = state.copyWith(
      classAsync: AsyncValue.data(currentState.copyWith(status: newStatus)),
    );
  }

  Future<void> deleteClass({required VoidCallback onSuccess}) async {
    if (state.isDeleting) return;

    state = state.copyWith(isDeleting: true, errorMessage: null);
    try {
      // Simulate network delete latency
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: Replace with actual Firestore delete logic later
      state = state.copyWith(isDeleting: false);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isDeleting: false, errorMessage: e.toString());
    }
  }
}

final classDetailProvider = StateNotifierProvider.family.autoDispose<
    ClassDetailNotifier, ClassDetailState, String>(
      (ref, classId) => ClassDetailNotifier(classId: classId),
);