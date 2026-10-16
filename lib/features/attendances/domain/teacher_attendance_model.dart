enum TeacherAttendanceStatus { present, absent, notMarked }

class TeacherAttendanceItem {
  final String teacherId;
  final String teacherName;
  final String employeeId;
  final String assignedClass;
  final TeacherAttendanceStatus status;

  const TeacherAttendanceItem({
    required this.teacherId,
    required this.teacherName,
    required this.employeeId,
    required this.assignedClass,
    this.status = TeacherAttendanceStatus.notMarked,
  });

  TeacherAttendanceItem copyWith({
    String? teacherId,
    String? teacherName,
    String? employeeId,
    String? assignedClass,
    TeacherAttendanceStatus? status,
  }) {
    return TeacherAttendanceItem(
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      employeeId: employeeId ?? this.employeeId,
      assignedClass: assignedClass ?? this.assignedClass,
      status: status ?? this.status,
    );
  }
}

class TeacherAttendanceRecord {
  final DateTime date;
  final List<TeacherAttendanceItem> teachers;

  const TeacherAttendanceRecord({
    required this.date,
    required this.teachers,
  });

  int get totalTeachers => teachers.length;
  int get presentCount => teachers.where((t) => t.status == TeacherAttendanceStatus.present).length;
  int get absentCount => teachers.where((t) => t.status == TeacherAttendanceStatus.absent).length;
  int get notMarkedCount => teachers.where((t) => t.status == TeacherAttendanceStatus.notMarked).length;

  TeacherAttendanceRecord copyWith({
    DateTime? date,
    List<TeacherAttendanceItem>? teachers,
  }) {
    return TeacherAttendanceRecord(
      date: date ?? this.date,
      teachers: teachers ?? this.teachers,
    );
  }
}