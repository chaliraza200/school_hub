enum TeacherStatus { active, inactive }

class Teacher {
  final String id;
  final String teacherId;
  final String fullName;
  final String assignedClass;
  final String section;
  final String subject;
  final TeacherStatus status;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? joiningDate;

  const Teacher({
    required this.id,
    required this.teacherId,
    required this.fullName,
    required this.assignedClass,
    required this.section,
    required this.subject,
    required this.status,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.joiningDate,
  });

  Teacher copyWith({
    String? id,
    String? teacherId,
    String? fullName,
    String? assignedClass,
    String? section,
    String? subject,
    TeacherStatus? status,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? joiningDate,
  }) {
    return Teacher(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      fullName: fullName ?? this.fullName,
      assignedClass: assignedClass ?? this.assignedClass,
      section: section ?? this.section,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }
}