import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../providers/teacher_dashboard_attendance_provider.dart';

class TeacherDashboardAttendanceScreen extends ConsumerWidget {
  const TeacherDashboardAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherDashboardAttendanceProvider);
    final notifier = ref.read(teacherDashboardAttendanceProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Attendance History',
            onPressed: () {
              // Assigned class history navigation
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Attendance',
            onPressed: () {
              // Assigned class export functionality
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Assigned Class & Date Selector Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Class',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              state.assignedClass,
                              style: AppTypography.heading1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: state.selectedDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (pickedDate != null) {
                            notifier.updateDate(pickedDate);
                          }
                        },
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text(
                          "${state.selectedDate.day}-${state.selectedDate.month}-${state.selectedDate.year}",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Success / Error Feedback
                if (state.successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Text(
                      state.successMessage!,
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (state.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Summary Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _SummaryBox(
                        title: 'Total',
                        count: '${state.totalStudents}',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryBox(
                        title: 'Present',
                        count: '${state.presentCount}',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryBox(
                        title: 'Absent',
                        count: '${state.absentCount}',
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Action bar for Mark All Present
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Student List', style: AppTypography.heading1),
                    TextButton.icon(
                      onPressed: () => notifier.markAllPresent(),
                      icon: const Icon(Icons.done_all_rounded),
                      label: const Text('Mark All Present'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Student List View (Replaced ListTile with clean Row layout)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.students.length,
                    separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final student = state.students[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(
                                student.rollNumber,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Roll No: ${student.rollNumber}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            SizedBox(
                              height: 34,
                              child: SegmentedButton<bool>(
                                showSelectedIcon: false,
                                style: SegmentedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                segments: const [
                                  ButtonSegment<bool>(
                                    value: true,
                                    label: Text('Present'),
                                  ),
                                  ButtonSegment<bool>(
                                    value: false,
                                    label: Text('Absent'),
                                  ),
                                ],
                                selected: {student.isPresent},
                                onSelectionChanged: (Set<bool> newSelection) {
                                  notifier.toggleAttendance(student.id);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Save Attendance Button
                FilledButton(
                  onPressed: state.isSaving
                      ? null
                      : () async {
                    await notifier.saveAttendance();
                  },
                  child: state.isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Save Attendance'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String count;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.xs),
          Text(count, style: AppTypography.heading2.copyWith(color: color)),
        ],
      ),
    );
  }
}