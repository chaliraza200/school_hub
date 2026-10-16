enum AttendanceStatus { present, absent, notMarked }

class StudentAttendanceItem {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final AttendanceStatus status;

  const StudentAttendanceItem({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    this.status = AttendanceStatus.notMarked,
  });

  StudentAttendanceItem copyWith({
    String? studentId,
    String? studentName,
    String? rollNumber,
    AttendanceStatus? status,
  }) {
    return StudentAttendanceItem(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      status: status ?? this.status,
    );
  }
}

class ClassAttendanceRecord {
  final String classId;
  final String className;
  final String section;
  final DateTime date;
  final List<StudentAttendanceItem> students;

  const ClassAttendanceRecord({
    required this.classId,
    required this.className,
    required this.section,
    required this.date,
    required this.students,
  });

  ClassAttendanceRecord copyWith({
    String? classId,
    String? className,
    String? section,
    DateTime? date,
    List<StudentAttendanceItem>? students,
  }) {
    return ClassAttendanceRecord(
      classId: classId ?? this.classId,
      className: className ?? this.className,
      section: section ?? this.section,
      date: date ?? this.date,
      students: students ?? this.students,
    );
  }
}