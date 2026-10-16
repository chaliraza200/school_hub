import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../providers/teacher_dashboard_attendance_history_provider.dart';
import '../../services/teacher_attendance_export_service.dart';

class TeacherDashboardAttendanceHistoryScreen extends ConsumerWidget {
  const TeacherDashboardAttendanceHistoryScreen({super.key});

  void _showExportDialog(BuildContext context, TeacherAttendanceHistoryState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Attendance'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned Class: ${state.assignedClass}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Total Records: ${state.records.length} days'),
                const SizedBox(height: 16),
                const Text('Kya aap attendance ko Excel par export karna chahte hain?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(context);

                final filePath = await TeacherAttendanceExportService.exportAttendanceToExcel(
                  assignedClass: state.assignedClass,
                  records: state.records,
                );

                if (context.mounted) {
                  if (filePath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Excel exported successfully: $filePath')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export failed. Please try again.')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.file_download_rounded),
              label: const Text('Export Excel'),
            ),
          ],
        );
      },
    );
  }

  void _showRecordDetails(
      BuildContext context,
      AttendanceHistoryRecord record,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Line 89: Wrapped Title with Expanded to prevent RenderFlex Overflow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Attendance Details (${record.date})',
                        style: AppTypography.heading1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Present: ${record.presentCount} | Absent: ${record.absentCount}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: record.details.length,
                    separatorBuilder: (context, index) =>
                    const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final detail = record.details[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          AppColors.primary.withOpacity(0.1),
                          child: Text(
                            detail.rollNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          detail.studentName,
                          style: AppTypography.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('Roll No: ${detail.rollNumber}'),
                        trailing: Chip(
                          label: Text(
                            detail.isPresent ? 'Present' : 'Absent',
                          ),
                          backgroundColor: detail.isPresent
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: detail.isPresent
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherAttendanceHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            tooltip: 'Export Attendance',
            onPressed: () => _showExportDialog(context, state),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(
        child: Text(
          state.errorMessage!,
          style: TextStyle(color: theme.colorScheme.error),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Class',
                              style:
                              AppTypography.bodySmall.copyWith(
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
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );

                          if (pickedDate != null && context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Filtering for: '
                                      '${pickedDate.day}-'
                                      '${pickedDate.month}-'
                                      '${pickedDate.year}',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.filter_list_rounded,
                          size: 16,
                        ),
                        label: const Text('Filter Date'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Past Records',
                  style: AppTypography.heading1,
                ),
                const SizedBox(height: AppSpacing.md),
                state.records.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Koi attendance record mojood nahi hai.',
                    ),
                  ),
                )
                    : Material(
                  color: Colors.white,
                  borderRadius: AppRadius.borderRadiusMd,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                      AppRadius.borderRadiusMd,
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount: state.records.length,
                      separatorBuilder: (context, index) =>
                      const Divider(
                        height: 1,
                        color: AppColors.border,
                      ),
                      itemBuilder: (context, index) {
                        final record = state.records[index];

                        return ListTile(
                          onTap: () => _showRecordDetails(
                            context,
                            record,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                            AppColors.primary
                                .withOpacity(0.1),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Date: ${record.date}',
                            style:
                            AppTypography.bodyMedium,
                          ),
                          subtitle: Text(
                            'Total: ${record.totalStudents} | '
                                'Present: ${record.presentCount} | '
                                'Absent: ${record.absentCount}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(
                            Icons
                                .arrow_forward_ios_rounded,
                            size: 14,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}