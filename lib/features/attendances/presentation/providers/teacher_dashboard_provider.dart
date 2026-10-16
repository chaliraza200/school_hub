import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class TeacherDashboardState {
  final bool isLoading;
  final String teacherName;
  final String assignedClass;
  final int presentCount;
  final int absentCount;
  final int notMarkedCount;
  final List<Map<String, String>> recentHistory;
  final String? errorMessage;

  TeacherDashboardState({
    this.isLoading = false,
    this.teacherName = 'Teacher',
    this.assignedClass = 'Grade 10 - Section A',
    this.presentCount = 35,
    this.absentCount = 3,
    this.notMarkedCount = 2,
    this.recentHistory = const [
      {'date': '2026-10-03', 'status': 'Submitted', 'present': '38', 'absent': '2'},
      {'date': '2026-10-02', 'status': 'Submitted', 'present': '37', 'absent': '3'},
    ],
    this.errorMessage,
  });
}

class TeacherDashboardNotifier extends StateNotifier<TeacherDashboardState> {
  TeacherDashboardNotifier() : super(TeacherDashboardState()) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    state = TeacherDashboardState(isLoading: true);
    try {
      // Simulate backend delay for fetching teacher-specific assigned class & data
      await Future.delayed(const Duration(milliseconds: 800));

      state = TeacherDashboardState(
        isLoading: false,
        teacherName: 'Ayesha Khan',
        assignedClass: 'Grade 10 - Section A',
        presentCount: 36,
        absentCount: 2,
        notMarkedCount: 2,
        recentHistory: [
          {'date': 'Oct 03, 2026', 'status': 'Submitted', 'present': '36', 'absent': '4'},
          {'date': 'Oct 02, 2026', 'status': 'Submitted', 'present': '38', 'absent': '2'},
          {'date': 'Oct 01, 2026', 'status': 'Submitted', 'present': '35', 'absent': '5'},
        ],
      );
    } catch (e) {
      state = TeacherDashboardState(
        isLoading: false,
        errorMessage: 'Failed to load dashboard details.',
      );
    }
  }
}

final teacherDashboardProvider =
StateNotifierProvider.autoDispose<TeacherDashboardNotifier, TeacherDashboardState>(
      (ref) => TeacherDashboardNotifier(),
);