enum ClassStatus { active, inactive }

class SchoolClass {
  final String id;
  final String className;
  final String section;
  final String classTeacherName;
  final int studentCount;
  final ClassStatus status;
  final String? academicYear;

  const SchoolClass({
    required this.id,
    required this.className,
    required this.section,
    required this.classTeacherName,
    required this.studentCount,
    required this.status,
    this.academicYear,
  });

  SchoolClass copyWith({
    String? id,
    String? className,
    String? section,
    String? classTeacherName,
    int? studentCount,
    ClassStatus? status,
    String? academicYear,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      className: className ?? this.className,
      section: section ?? this.section,
      classTeacherName: classTeacherName ?? this.classTeacherName,
      studentCount: studentCount ?? this.studentCount,
      status: status ?? this.status,
      academicYear: academicYear ?? this.academicYear,
    );
  }
}