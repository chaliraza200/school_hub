import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/student_model.dart';

class StudentDetailState {
  final AsyncValue<Student> studentAsync;
  final bool isDeleting;
  final String? errorMessage;

  const StudentDetailState({
    required this.studentAsync,
    this.isDeleting = false,
    this.errorMessage,
  });

  StudentDetailState copyWith({
    AsyncValue<Student>? studentAsync,
    bool? isDeleting,
    String? errorMessage,
  }) {
    return StudentDetailState(
      studentAsync: studentAsync ?? this.studentAsync,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
    );
  }
}

class StudentDetailNotifier extends StateNotifier<StudentDetailState> {
  final String studentId;

  StudentDetailNotifier({required this.studentId})
      : super(const StudentDetailState(studentAsync: AsyncValue.loading())) {
    fetchStudentDetail();
  }

  Future<void> fetchStudentDetail() async {
    state = state.copyWith(studentAsync: const AsyncValue.loading());
    try {
      // Simulate backend/Firestore document fetch delay.
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock student detail data mapping. Ready for Firestore document snapshot later.
      final student = Student(
        id: studentId,
        studentId: 'STU-2026-${studentId.padLeft(3, '0')}',
        fullName: 'Alexander Wright',
        rollNumber: '101',
        className: 'Grade 10',
        section: 'A',
        status: StudentStatus.active,
        dateOfBirth: '14 May 2010',
        joiningDate: '01 Sep 2024',
        guardianName: 'Robert Wright',
        parentPhone: '+1 (555) 234-5678',
        alternatePhone: '+1 (555) 876-5432',
        monthlyFee: '\$350.00',
        feeNote: 'Sibling discount applied (10%)',
      );

      state = state.copyWith(studentAsync: AsyncValue.data(student));
    } catch (e, st) {
      state = state.copyWith(studentAsync: AsyncValue.error(e, st));
    }
  }

  Future<void> toggleStudentStatus() async {
    final currentState = state.studentAsync.value;
    if (currentState == null) return;

    final newStatus = currentState.status == StudentStatus.active
        ? StudentStatus.inactive
        : StudentStatus.active;

    // Optimistic UI state update. Ready for Firestore write operations later.
    state = state.copyWith(
      studentAsync: AsyncValue.data(currentState.copyWith(status: newStatus)),
    );
  }

  Future<void> deleteStudent({required VoidCallback onSuccess}) async {
    if (state.isDeleting) return; // Prevent duplicate taps

    state = state.copyWith(isDeleting: true, errorMessage: null);
    try {
      // Simulate network / Firestore delete latency
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: Replace with actual Firestore delete logic later
      // await FirebaseFirestore.instance.collection('students').doc(studentId).delete();

      state = state.copyWith(isDeleting: false);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isDeleting: false, errorMessage: e.toString());
    }
  }

  Future<void> callPhoneNumber(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

final studentDetailProvider = StateNotifierProvider.family.autoDispose<
    StudentDetailNotifier, StudentDetailState, String>(
      (ref, studentId) => StudentDetailNotifier(studentId: studentId),
);