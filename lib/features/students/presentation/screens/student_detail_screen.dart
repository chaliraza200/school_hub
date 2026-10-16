import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/student_model.dart';
import '../../widgets/student_detail_section_card.dart';
import '../providers/student_detail_provider.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(studentDetailProvider(studentId));
    final studentAsync = detailState.studentAsync;

    // Listen for error feedback if deletion fails
    ref.listen<StudentDetailState>(
      studentDetailProvider(studentId),
          (previous, next) {
        if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete student: ${next.errorMessage}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Student Details', style: AppTypography.heading2.copyWith(color: AppColors.mainText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          studentAsync.when(
            data: (student) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  tooltip: 'Edit Student',
                  onPressed: () {
                    context.pushNamed('editStudent', pathParameters: {'id': student.id});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Delete Student',
                  onPressed: detailState.isDeleting
                      ? null
                      : () => _showDeleteConfirmationDialog(context, ref),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: studentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Failed to load student details: $err', style: AppTypography.bodyMedium),
        ),
        data: (student) {
          final isActive = student.status == StudentStatus.active;
          final statusColor = isActive ? AppColors.success : AppColors.secondaryText;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Student Header Section
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: AppRadius.borderRadiusMd,
                            ),
                            child: Center(
                              child: Text(
                                student.fullName.isNotEmpty ? student.fullName.substring(0, 1) : 'S',
                                style: AppTypography.heading1.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.fullName,
                                  style: AppTypography.heading2.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text('ID: ${student.studentId}', style: AppTypography.bodySmall),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: AppRadius.borderRadiusFull,
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Student Information Section
                    DetailSectionCard(
                      title: 'Student Information',
                      children: [
                        DetailRowItem(label: 'Roll Number', value: student.rollNumber),
                        DetailRowItem(label: 'Class & Section', value: '${student.className} - ${student.section}'),
                        DetailRowItem(label: 'Date of Birth', value: student.dateOfBirth ?? 'N/A'),
                        DetailRowItem(label: 'Joining Date', value: student.joiningDate ?? 'N/A'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Parent / Guardian Information Section
                    DetailSectionCard(
                      title: 'Parent / Guardian',
                      children: [
                        DetailRowItem(label: 'Guardian Name', value: student.guardianName ?? 'N/A'),
                        DetailRowItem(
                          label: 'Primary Phone',
                          value: student.parentPhone ?? 'N/A',
                          trailing: student.parentPhone != null
                              ? IconButton(
                            icon: const Icon(Icons.phone_rounded, color: AppColors.success, size: 20),
                            tooltip: 'Call Primary Phone',
                            onPressed: () {
                              ref.read(studentDetailProvider(studentId).notifier).callPhoneNumber(student.parentPhone!);
                            },
                          )
                              : null,
                        ),
                        DetailRowItem(
                          label: 'Alternate Phone',
                          value: student.alternatePhone ?? 'N/A',
                          trailing: student.alternatePhone != null
                              ? IconButton(
                            icon: const Icon(Icons.phone_rounded, color: AppColors.info, size: 20),
                            tooltip: 'Call Alternate Phone',
                            onPressed: () {
                              ref.read(studentDetailProvider(studentId).notifier).callPhoneNumber(student.alternatePhone!);
                            },
                          )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Fee Information Section
                    DetailSectionCard(
                      title: 'Fee Information',
                      children: [
                        DetailRowItem(label: 'Monthly Fee', value: student.monthlyFee ?? 'N/A'),
                        DetailRowItem(label: 'Fee Note', value: student.feeNote ?? 'None'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Activation / Deactivation Action Button
                    OutlinedButton(
                      onPressed: detailState.isDeleting
                          ? null
                          : () {
                        _showStatusConfirmationDialog(context, ref, isActive);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isActive ? AppColors.error : AppColors.success,
                        side: BorderSide(color: isActive ? AppColors.error : AppColors.success),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                      ),
                      child: Text(
                        isActive ? 'Deactivate Student' : 'Activate Student',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isActive ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Delete Student Action Button
                    OutlinedButton.icon(
                      onPressed: detailState.isDeleting
                          ? null
                          : () => _showDeleteConfirmationDialog(context, ref),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      label: detailState.isDeleting
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: AppColors.error, strokeWidth: 2),
                      )
                          : const Text('Delete Student', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStatusConfirmationDialog(BuildContext context, WidgetRef ref, bool isActive) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
        title: Text(isActive ? 'Deactivate Student?' : 'Activate Student?'),
        content: Text(
          isActive
              ? 'This will mark the student as inactive. They will no longer appear in active attendance sheets.'
              : 'This will restore the student status to active.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.error : AppColors.success,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () {
              ref.read(studentDetailProvider(studentId).notifier).toggleStudentStatus();
              Navigator.pop(dialogContext);
            },
            child: Text(isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final detailState = ref.watch(studentDetailProvider(studentId));

            return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
                title: Text(
                  'Delete Student?',
                  style: AppTypography.heading2.copyWith(color: AppColors.mainText),
                ),
                content: Text(
                  'Are you sure you want to delete this student? This action cannot be undone.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText),
                ),
                actions: [
            TextButton(
            onPressed: detailState.isDeleting ? null : () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
            ),
            ElevatedButton(
            style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
            minimumSize: const Size(80, 40),
            ),
            onPressed: detailState.isDeleting
            ? null
                : () {
            ref.read(studentDetailProvider(studentId).notifier).deleteStudent(
            onSuccess: () {
            Navigator.pop(dialogContext); // Close dialog
            context.pop(); // Pop back to list
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: AppColors.success,
            ),
            );
            },
            );
            },
            child: detailState.isDeleting
            ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
            ],
            );
          },
        );
      },
    );
  }
}