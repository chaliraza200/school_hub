import '../domain/attendance_model.dart';

class AttendanceHistoryRecord {
  final String id;
  final String className;
  final String section;
  final DateTime date;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int notMarkedCount;
  final List<StudentAttendanceItem> students;

  const AttendanceHistoryRecord({
    required this.id,
    required this.className,
    required this.section,
    required this.date,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.notMarkedCount,
    required this.students,
  });

  AttendanceHistoryRecord copyWith({
    String? id,
    String? className,
    String? section,
    DateTime? date,
    int? totalStudents,
    int? presentCount,
    int? absentCount,
    int? notMarkedCount,
    List<StudentAttendanceItem>? students,
  }) {
    return AttendanceHistoryRecord(
      id: id ?? this.id,
      className: className ?? this.className,
      section: section ?? this.section,
      date: date ?? this.date,
      totalStudents: totalStudents ?? this.totalStudents,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      notMarkedCount: notMarkedCount ?? this.notMarkedCount,
      students: students ?? this.students,
    );
  }
}