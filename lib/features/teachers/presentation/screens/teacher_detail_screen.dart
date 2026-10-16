import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../students/widgets/student_detail_section_card.dart';
import '../../domain/teacher_model.dart';
import '../providers/teacher_detail_provider.dart';

class TeacherDetailScreen extends ConsumerWidget {
  final String teacherId;

  const TeacherDetailScreen({
    super.key,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(teacherDetailProvider(teacherId));
    final teacherAsync = detailState.teacherAsync;

    ref.listen<TeacherDetailState>(
      teacherDetailProvider(teacherId),
          (previous, next) {
        if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete teacher: ${next.errorMessage}'),
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
        title: Text('Teacher Details', style: AppTypography.heading2.copyWith(color: AppColors.mainText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          teacherAsync.when(
            data: (teacher) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  tooltip: 'Edit Teacher',
                  onPressed: () {
                    context.pushNamed('editTeacher', pathParameters: {'id': teacher.id});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Delete Teacher',
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
      body: teacherAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Failed to load teacher details: $err', style: AppTypography.bodyMedium),
        ),
        data: (teacher) {
          final isActive = teacher.status == TeacherStatus.active;
          final statusColor = isActive ? AppColors.success : AppColors.secondaryText;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Teacher Header Card
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
                                teacher.fullName.isNotEmpty ? teacher.fullName.substring(0, 1) : 'T',
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
                                  teacher.fullName,
                                  style: AppTypography.heading2.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text('ID: ${teacher.teacherId}', style: AppTypography.bodySmall),
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

                    // Contact & Professional Information Section
                    DetailSectionCard(
                      title: 'Teacher Information',
                      children: [
                        DetailRowItem(
                          label: 'Phone Number',
                          value: teacher.phone ?? 'N/A',
                          trailing: teacher.phone != null
                              ? IconButton(
                            icon: const Icon(Icons.phone_rounded, color: AppColors.success, size: 20),
                            tooltip: 'Call Teacher',
                            onPressed: () {
                              ref.read(teacherDetailProvider(teacherId).notifier).callPhoneNumber(teacher.phone!);
                            },
                          )
                              : null,
                        ),
                        DetailRowItem(
                          label: 'Email Address',
                          value: teacher.email ?? 'N/A',
                          trailing: teacher.email != null
                              ? IconButton(
                            icon: const Icon(Icons.email_outlined, color: AppColors.info, size: 20),
                            tooltip: 'Email Teacher',
                            onPressed: () {
                              ref.read(teacherDetailProvider(teacherId).notifier).emailTeacher(teacher.email!);
                            },
                          )
                              : null,
                        ),
                        DetailRowItem(label: 'Subject', value: teacher.subject),
                        DetailRowItem(label: 'Assigned Class & Section', value: '${teacher.assignedClass} - Section ${teacher.section}'),
                        DetailRowItem(label: 'Date of Birth', value: teacher.dateOfBirth ?? 'N/A'),
                        DetailRowItem(label: 'Joining Date', value: teacher.joiningDate ?? 'N/A'),
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
                        isActive ? 'Deactivate Teacher' : 'Activate Teacher',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isActive ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Delete Teacher Action Button
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
                          : const Text('Delete Teacher', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
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
        title: Text(isActive ? 'Deactivate Teacher?' : 'Activate Teacher?'),
        content: Text(
          isActive
              ? 'This will mark the teacher as inactive. They will no longer be assigned to active classes.'
              : 'This will restore the teacher status to active.',
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
              ref.read(teacherDetailProvider(teacherId).notifier).toggleTeacherStatus();
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
            final detailState = ref.watch(teacherDetailProvider(teacherId));

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
              title: Text(
                'Delete Teacher?',
                style: AppTypography.heading2.copyWith(color: AppColors.mainText),
              ),
              content: Text(
                'Are you sure you want to delete this teacher? This action cannot be undone.',
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
                    ref.read(teacherDetailProvider(teacherId).notifier).deleteTeacher(
                      onSuccess: () {
                        Navigator.pop(dialogContext); // Close dialog
                        context.pop(); // Pop back to list
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Teacher deleted successfully'),
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