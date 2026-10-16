import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/teacher_model.dart';

class TeacherFormState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const TeacherFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  TeacherFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return TeacherFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class TeacherFormNotifier extends StateNotifier<TeacherFormState> {
  final String? teacherId;

  TeacherFormNotifier({this.teacherId}) : super(const TeacherFormState());

  Future<void> saveTeacher({
    required Map<String, dynamic> formData,
    required VoidCallback onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate network / Firestore write latency
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: Replace with actual Firestore add/update logic later
      // if (teacherId == null) { /* Firestore add document */ }
      // else { /* Firestore update document */ }

      state = state.copyWith(isLoading: false, isSuccess: true);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final teacherFormProvider = StateNotifierProvider.family.autoDispose<
    TeacherFormNotifier, TeacherFormState, String?>(
      (ref, teacherId) => TeacherFormNotifier(teacherId: teacherId),
);