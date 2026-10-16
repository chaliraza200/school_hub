enum FeeStatus { paid, partial, pending, overdue }

class FeeModel {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final String section;
  final double monthlyFee;
  final double paidAmount;
  final double pendingAmount;
  final FeeStatus status;
  final DateTime dueDate;

  const FeeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.section,
    required this.monthlyFee,
    required this.paidAmount,
    required this.pendingAmount,
    required this.status,
    required this.dueDate,
  });

  FeeModel copyWith({
    double? paidAmount,
    double? pendingAmount,
    FeeStatus? status,
  }) {
    return FeeModel(
      id: id,
      studentId: studentId,
      studentName: studentName,
      className: className,
      section: section,
      monthlyFee: monthlyFee,
      paidAmount: paidAmount ?? this.paidAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      status: status ?? this.status,
      dueDate: dueDate,
    );
  }
}