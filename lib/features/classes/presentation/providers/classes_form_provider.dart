import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ClassFormState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ClassFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ClassFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ClassFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ClassFormNotifier extends StateNotifier<ClassFormState> {
  final String? classId;

  ClassFormNotifier({this.classId}) : super(const ClassFormState());

  Future<void> saveClass({
    required Map<String, dynamic> formData,
    required VoidCallback onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate network / Firestore write latency
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: Replace with actual Firestore add/update logic later
      state = state.copyWith(isLoading: false, isSuccess: true);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final classFormProvider = StateNotifierProvider.family.autoDispose<
    ClassFormNotifier, ClassFormState, String?>(
      (ref, classId) => ClassFormNotifier(classId: classId),
);