import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/teacher_model.dart';

class TeacherListState {
  final List<Teacher> teachers;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final TeacherStatus? statusFilter;
  final String? subjectFilter;

  const TeacherListState({
    this.teachers = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.statusFilter,
    this.subjectFilter,
  });

  TeacherListState copyWith({
    List<Teacher>? teachers,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    TeacherStatus? statusFilter,
    String? subjectFilter,
    bool clearStatusFilter = false,
    bool clearSubjectFilter = false,
  }) {
    return TeacherListState(
      teachers: teachers ?? this.teachers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      subjectFilter: clearSubjectFilter ? null : (subjectFilter ?? this.subjectFilter),
    );
  }

  List<Teacher> get filteredTeachers {
    return teachers.where((teacher) {
      final matchesSearch = teacher.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          teacher.teacherId.toLowerCase().contains(searchQuery.toLowerCase()) ||
          teacher.subject.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus = statusFilter == null || teacher.status == statusFilter;
      final matchesSubject = subjectFilter == null || teacher.subject == subjectFilter;

      return matchesSearch && matchesStatus && matchesSubject;
    }).toList();
  }
}

class TeacherListNotifier extends StateNotifier<TeacherListState> {
  TeacherListNotifier() : super(const TeacherListState(isLoading: true)) {
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      // Mock teacher list data with explicit section properties
      final mockTeachers = [
        const Teacher(
          id: '1',
          teacherId: 'TCH-2026-001',
          fullName: 'Dr. Eleanor Vance',
          assignedClass: 'Grade 10',
          section: 'A',
          subject: 'Mathematics',
          status: TeacherStatus.active,
          email: 'e.vance@schoolhub.edu',
          phone: '+1 (555) 111-2233',
        ),
        const Teacher(
          id: '2',
          teacherId: 'TCH-2026-002',
          fullName: 'Prof. Marcus Brody',
          assignedClass: 'Grade 9',
          section: 'B',
          subject: 'History',
          status: TeacherStatus.active,
          email: 'm.brody@schoolhub.edu',
          phone: '+1 (555) 222-3344',
        ),
        const Teacher(
          id: '3',
          teacherId: 'TCH-2026-003',
          fullName: 'Sarah Jenkins',
          assignedClass: 'Grade 8',
          section: 'A',
          subject: 'English Literature',
          status: TeacherStatus.active,
          email: 's.jenkins@schoolhub.edu',
          phone: '+1 (555) 333-4455',
        ),
        const Teacher(
          id: '4',
          teacherId: 'TCH-2026-004',
          fullName: 'David Sterling',
          assignedClass: 'Grade 10',
          section: 'B',
          subject: 'Physics',
          status: TeacherStatus.inactive,
          email: 'd.sterling@schoolhub.edu',
          phone: '+1 (555) 444-5566',
        ),
      ];

      state = state.copyWith(teachers: mockTeachers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(TeacherStatus? status) {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
  }

  void setSubjectFilter(String? subject) {
    state = state.copyWith(subjectFilter: subject, clearSubjectFilter: subject == null);
  }
}

final teacherListProvider = StateNotifierProvider.autoDispose<TeacherListNotifier, TeacherListState>(
      (ref) => TeacherListNotifier(),
);