enum StudentStatus { active, inactive }

class Student {
  final String id;
  final String studentId;
  final String fullName;
  final String rollNumber;
  final String className;
  final String section;
  final StudentStatus status;
  final String? profileImageUrl;
  final String? dateOfBirth;
  final String? joiningDate;
  final String? guardianName;
  final String? parentPhone;
  final String? alternatePhone;
  final String? monthlyFee;
  final String? feeNote;

  const Student({
    required this.id,
    required this.studentId,
    required this.fullName,
    required this.rollNumber,
    required this.className,
    required this.section,
    required this.status,
    this.profileImageUrl,
    this.dateOfBirth,
    this.joiningDate,
    this.guardianName,
    this.parentPhone,
    this.alternatePhone,
    this.monthlyFee,
    this.feeNote,
  });

  Student copyWith({
    String? id,
    String? studentId,
    String? fullName,
    String? rollNumber,
    String? className,
    String? section,
    StudentStatus? status,
    String? profileImageUrl,
    String? dateOfBirth,
    String? joiningDate,
    String? guardianName,
    String? parentPhone,
    String? alternatePhone,
    String? monthlyFee,
    String? feeNote,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      rollNumber: rollNumber ?? this.rollNumber,
      className: className ?? this.className,
      section: section ?? this.section,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      joiningDate: joiningDate ?? this.joiningDate,
      guardianName: guardianName ?? this.guardianName,
      parentPhone: parentPhone ?? this.parentPhone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      feeNote: feeNote ?? this.feeNote,
    );
  }
}