import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/attendances/presentation/screens/attendance_history_screen.dart';
import '../../features/attendances/presentation/screens/student_attendance_screen.dart';
import '../../features/attendances/presentation/screens/teacher_attendance_screen.dart';
import '../../features/attendances/presentation/screens/teacher_dashboard_attendance_history_screen.dart';
import '../../features/attendances/presentation/screens/teacher_dashboard_attendance_screen.dart';
import '../../features/attendances/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/auth/presentation/screens/admin_dashboard_screen.dart';
import '../../features/auth/presentation/screens/fee_staff_login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/admin_login_screen.dart';
import '../../features/auth/presentation/screens/teacher_login_screen.dart';
import '../../features/classes/presentation/screens/class_detail_screen.dart';
import '../../features/classes/presentation/screens/class_form_screen.dart';
import '../../features/classes/presentation/screens/class_list_screen.dart';
import '../../features/fees/domain/presentations/screens/fee_dashboard_screen.dart';
import '../../features/fees/domain/presentations/screens/fees_screens.dart';
import '../../features/fees/domain/presentations/screens/manage_fees_screen.dart';
import '../../features/fees/domain/presentations/screens/payment_history_screen.dart';
import '../../features/fees/domain/presentations/screens/record_payment_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/students/presentation/screens/student_detail_screen.dart';
import '../../features/students/presentation/screens/student_form_screen.dart';
import '../../features/students/presentation/screens/students_screen.dart';
import '../../features/teachers/presentation/screens/teacher_detail_screen.dart';
import '../../features/teachers/presentation/screens/teacher_form_screen.dart';
import '../../features/teachers/presentation/screens/teacher_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login/:role',
        name: 'login',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'user';

          // 2. CHANGE/HANDLE PATH BASED ON ROLE HERE:
          if (role == 'admin') {
            return const AdminLoginScreen();
          }

          // Fallback placeholder for Teacher and Fee Staff until built
          return PlaceholderScreen(title: '${role.toUpperCase()} Login Flow');
        },
      ),

// Update the dashboard route handler inside appRouterProvider:
          GoRoute(
              path: '/dashboard/:role',
               name: 'dashboard',
                builder: (context, state) {
                final role = state.pathParameters['role'] ?? 'user';
                 if (role == 'admin') {
                  return const AdminDashboardScreen();
  }
                  return PlaceholderScreen(title: '${role.toUpperCase()} Dashboard');
  },
  ),
      GoRoute(
        path: '/students',
        name: 'studentsList',
        builder: (context, state) => const StudentsScreen(),
      ),
      // 1. Place the specific 'add' route BEFORE the dynamic ':id' route
      GoRoute(
        path: '/students/add',
        name: 'addStudent',
        builder: (context, state) => const StudentFormScreen(),
      ),

// 2. Place the edit route
      GoRoute(
        path: '/students/edit/:id',
        name: 'editStudent',
        builder: (context, state) {
          final studentId = state.pathParameters['id']!;
          return StudentFormScreen(studentId: studentId);
        },
      ),

// 3. Place the dynamic detail route LAST so it doesn't swallow other paths
      GoRoute(
        path: '/students/:id',
        name: 'studentDetail',
        builder: (context, state) {
          final studentId = state.pathParameters['id']!;
          return StudentDetailScreen(studentId: studentId);
        },
      ),
      GoRoute(
        path: '/teachers',
        name: 'teachersList',
        builder: (context, state) => const TeacherListScreen(),
      ),
      // Add Teacher Route (Add mode)
      GoRoute(
        path: '/teachers/add',
        name: 'addTeacher',
        builder: (context, state) => const TeacherFormScreen(),
      ),

// Edit Teacher Route (Edit mode with dynamic ID)
      GoRoute(
        path: '/teachers/edit/:id',
        name: 'editTeacher',
        builder: (context, state) {
          final teacherId = state.pathParameters['id'];
          return TeacherFormScreen(teacherId: teacherId);
        },
      ),
      GoRoute(
        path: '/teachers/:id',
        name: 'teacherDetail',
        builder: (context, state) {
          final teacherId = state.pathParameters['id']!;
          return TeacherDetailScreen(teacherId: teacherId);
        },
      ),
      GoRoute(
        path: '/classes',
        name: 'classList',
        builder: (context, state) => const ClassListScreen(),
      ),
      // Add Class Route (Add mode)
      GoRoute(
        path: '/classes/add',
        name: 'addClass',
        builder: (context, state) => const ClassFormScreen(),
      ),

// Edit Class Route (Edit mode with dynamic ID)
      GoRoute(
        path: '/classes/edit/:id',
        name: 'editClass',
        builder: (context, state) {
          final classId = state.pathParameters['id'];
          return ClassFormScreen(classId: classId);
        },
      ),
      GoRoute(
        path: '/classes/:id',
        name: 'classDetail',
        builder: (context, state) {
          final classId = state.pathParameters['id']!;
          return ClassDetailScreen(classId: classId);
        },
      ),
      GoRoute(
        path: '/attendance',
        name: 'studentAttendance',
        builder: (context, state) => const StudentAttendanceScreen(),
      ),
      // Attendance History Route
      GoRoute(
        path: '/attendance/history',
        name: 'attendanceHistory',
        builder: (context, state) {
          final initialDate = state.extra as DateTime?;
          return AttendanceHistoryScreen(initialDateFilter: initialDate);
        },
      ),
      GoRoute(
        path: '/attendance/teachers',
        name: 'teacherAttendance',
        builder: (context, state) => const TeacherAttendanceScreen(),
      ),
      GoRoute(
        path: '/fees',
        name: 'feesList',
        builder: (context, state) => const FeesScreen(),
      ),
      GoRoute(
        path: '/reports',
        name: 'reportsExport',
        builder: (context, state) => const ReportsScreen(),
      ),
      // Add this route in your GoRouter configuration:
      GoRoute(
        path: '/teacher-login',
        builder: (context, state) => const TeacherLoginScreen(),
      ),
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: '/teacher-dashboard-attendance',
        builder: (context, state) => const TeacherDashboardAttendanceScreen(),
      ),
      GoRoute(
        path: '/teacher-dashboard-attendance-history',
        builder: (context, state) => const TeacherDashboardAttendanceHistoryScreen(),
      ),
      // Fee Staff Login Route
      GoRoute(
        path: '/fee-staff-login',
        builder: (context, state) => const FeeStaffLoginScreen(),
      ),

// Fee Staff Dashboard Route
      GoRoute(
        path: '/fee-staff-dashboard',
        builder: (context, state) => const FeeDashboardScreen(),
      ),
      GoRoute(
        path: '/manage-fees',
        name: 'manage-fees',
        builder: (context, state) => const ManageFeesScreen(),
      ),
      GoRoute(
        path: '/record-payment',
        name: 'record-payment',
        builder: (context, state) => const RecordPaymentScreen(),
      ),
      GoRoute(
        path: '/payment-history',
        name: 'payment-history',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
    ],
  );
});

// Temporary placeholder screen for unbuilt routes
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text('Module under development. Ready for backend integration.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Role Selection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}