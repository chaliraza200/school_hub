import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/teacher_model.dart';

class TeacherDetailState {
  final AsyncValue<Teacher> teacherAsync;
  final bool isDeleting;
  final String? errorMessage;

  const TeacherDetailState({
    required this.teacherAsync,
    this.isDeleting = false,
    this.errorMessage,
  });

  TeacherDetailState copyWith({
    AsyncValue<Teacher>? teacherAsync,
    bool? isDeleting,
    String? errorMessage,
  }) {
    return TeacherDetailState(
      teacherAsync: teacherAsync ?? this.teacherAsync,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
    );
  }
}

class TeacherDetailNotifier extends StateNotifier<TeacherDetailState> {
  final String teacherId;

  TeacherDetailNotifier({required this.teacherId})
      : super(const TeacherDetailState(teacherAsync: AsyncValue.loading())) {
    fetchTeacherDetail();
  }

  Future<void> fetchTeacherDetail() async {
    state = state.copyWith(teacherAsync: const AsyncValue.loading());
    try {
      // Simulate backend fetch delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock individual teacher data mapping
      final teacher = Teacher(
        id: teacherId,
        teacherId: 'TCH-2026-${teacherId.padLeft(3, '0')}',
        fullName: 'Dr. Eleanor Vance',
        assignedClass: 'Grade 10',
        section: 'A',
        subject: 'Mathematics',
        status: TeacherStatus.active,
        email: 'e.vance@schoolhub.edu',
        phone: '+1 (555) 111-2233',
        dateOfBirth: '22 Aug 1985',
        joiningDate: '15 Aug 2022',
      );

      state = state.copyWith(teacherAsync: AsyncValue.data(teacher));
    } catch (e, st) {
      state = state.copyWith(teacherAsync: AsyncValue.error(e, st));
    }
  }

  Future<void> toggleTeacherStatus() async {
    final currentState = state.teacherAsync.value;
    if (currentState == null) return;

    final newStatus = currentState.status == TeacherStatus.active
        ? TeacherStatus.inactive
        : TeacherStatus.active;

    state = state.copyWith(
      teacherAsync: AsyncValue.data(currentState.copyWith(status: newStatus)),
    );
  }

  Future<void> deleteTeacher({required VoidCallback onSuccess}) async {
    if (state.isDeleting) return;

    state = state.copyWith(isDeleting: true, errorMessage: null);
    try {
      // Simulate latency
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: Replace with actual Firestore delete logic later
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

  Future<void> emailTeacher(String emailAddress) async {
    final uri = Uri(scheme: 'mailto', path: emailAddress);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

final teacherDetailProvider = StateNotifierProvider.family.autoDispose<
    TeacherDetailNotifier, TeacherDetailState, String>(
      (ref, teacherId) => TeacherDetailNotifier(teacherId: teacherId),
);