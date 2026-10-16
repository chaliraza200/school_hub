class AdminDashboardData {
  final String adminName;
  final String schoolName;
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final double attendancePercentage;
  final int presentStudents;
  final int absentStudents;
  final double feesCollected;
  final double feesPending;

  const AdminDashboardData({
    required this.adminName,
    required this.schoolName,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.attendancePercentage,
    required this.presentStudents,
    required this.absentStudents,
    required this.feesCollected,
    required this.feesPending,
  });
}