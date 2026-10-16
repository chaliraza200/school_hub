import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../students/widgets/student_detail_section_card.dart';
import '../../domain/class_model_dart.dart';
import '../providers/class_detail_provider.dart';

class ClassDetailScreen extends ConsumerWidget {
  final String classId;

  const ClassDetailScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(classDetailProvider(classId));
    final classAsync = detailState.classAsync;

    ref.listen<ClassDetailState>(
      classDetailProvider(classId),
          (previous, next) {
        if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete class: ${next.errorMessage}'),
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
        title: Text('Class Details', style: AppTypography.heading2.copyWith(color: AppColors.mainText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          classAsync.when(
            data: (schoolClass) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  tooltip: 'Edit Class',
                  onPressed: () {
                    context.pushNamed('editClass', pathParameters: {'id': schoolClass.id});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Delete Class',
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
      body: classAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Failed to load class details: $err', style: AppTypography.bodyMedium),
        ),
        data: (schoolClass) {
          final isActive = schoolClass.status == ClassStatus.active;
          final statusColor = isActive ? AppColors.success : AppColors.secondaryText;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // --- HEADER CARD ---
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
                                schoolClass.section,
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
                                  schoolClass.className,
                                  style: AppTypography.heading2.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text('Section: ${schoolClass.section}', style: AppTypography.bodySmall),
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

                    // --- CLASS INFORMATION SECTION ---
                    DetailSectionCard(
                      title: 'Class Information',
                      children: [
                        DetailRowItem(label: 'Class Teacher', value: schoolClass.classTeacherName),
                        DetailRowItem(label: 'Academic Year', value: schoolClass.academicYear ?? 'N/A'),
                        DetailRowItem(label: 'Student Count', value: '${detailState.enrolledStudents.length} Students'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // --- ENROLLED STUDENTS SECTION ---
                    DetailSectionCard(
                      title: 'Enrolled Students',
                      children: detailState.enrolledStudents.isEmpty
                          ? [const DetailRowItem(label: 'Roster', value: 'No students enrolled')]
                          : detailState.enrolledStudents.map((studentName) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.secondaryText),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(studentName, style: AppTypography.bodyMedium),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // --- ACTIVATE/DEACTIVATE ACTION ---
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
                        isActive ? 'Deactivate Class' : 'Activate Class',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isActive ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // --- DELETE ACTION ---
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
                          : const Text('Delete Class', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
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
        title: Text(isActive ? 'Deactivate Class?' : 'Activate Class?'),
        content: Text(
          isActive
              ? 'This will mark the class as inactive. Active tracking for enrolled students may be paused.'
              : 'This will restore the class status to active.',
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
              ref.read(classDetailProvider(classId).notifier).toggleClassStatus();
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
            final detailState = ref.watch(classDetailProvider(classId));

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
              title: Text(
                'Delete Class?',
                style: AppTypography.heading2.copyWith(color: AppColors.mainText),
              ),
              content: Text(
                'Are you sure you want to delete this class? This action cannot be undone.',
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
                    ref.read(classDetailProvider(classId).notifier).deleteClass(
                      onSuccess: () {
                        Navigator.pop(dialogContext); // Close dialog
                        context.pop(); // Pop back to list
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Class deleted successfully'),
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