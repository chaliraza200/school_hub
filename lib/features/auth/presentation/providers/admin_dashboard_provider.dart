import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/admin_dashboard_model.dart';

class AdminDashboardNotifier extends StateNotifier<AsyncValue<AdminDashboardData>> {
  AdminDashboardNotifier() : super(const AsyncValue.loading()) {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    state = const AsyncValue.loading();
    try {
      // Simulate backend network latency.
      // Later replace with Firestore document/stream fetches.
      await Future.delayed(const Duration(milliseconds: 600));

      const mockData = AdminDashboardData(
        adminName: 'Admin',
        schoolName: 'Greenwood High Academy',
        totalStudents: 1240,
        totalTeachers: 68,
        totalClasses: 36,
        attendancePercentage: 94.2,
        presentStudents: 1168,
        absentStudents: 72,
        feesCollected: 145000.0,
        feesPending: 22500.0,
      );

      state = const AsyncValue.data(mockData);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminDashboardProvider = StateNotifierProvider.autoDispose<
    AdminDashboardNotifier, AsyncValue<AdminDashboardData>>(
      (ref) => AdminDashboardNotifier(),
);