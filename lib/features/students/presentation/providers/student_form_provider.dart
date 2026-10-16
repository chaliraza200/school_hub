import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/student_model.dart';

class StudentFormState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const StudentFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  StudentFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return StudentFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class StudentFormNotifier extends StateNotifier<StudentFormState> {
  final String? studentId;

  StudentFormNotifier({this.studentId}) : super(const StudentFormState());

  Future<void> saveStudent({
    required Map<String, dynamic> formData,
    required VoidCallback onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate network / Firestore write latency
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: Replace with actual Firestore add/update logic later
      // if (studentId == null) { /* Firestore add document */ }
      // else { /* Firestore update document */ }

      state = state.copyWith(isLoading: false, isSuccess: true);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final studentFormProvider = StateNotifierProvider.family.autoDispose<
    StudentFormNotifier, StudentFormState, String?>(
      (ref, studentId) => StudentFormNotifier(studentId: studentId),
);