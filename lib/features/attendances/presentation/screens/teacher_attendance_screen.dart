import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/teacher_attendance_model.dart';
import '../providers/teacher_attendance_provider.dart';

class TeacherAttendanceScreen extends ConsumerWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(teacherAttendanceProvider);
    final notifier = ref.read(teacherAttendanceProvider.notifier);
    final record = attendanceState.attendanceRecord;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Teacher Attendance', style: AppTypography.heading2.copyWith(color: AppColors.mainText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- DATE SELECTOR HEADER ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(attendanceState.selectedDate),
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: attendanceState.selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        notifier.fetchTeacherAttendanceForDate(pickedDate);
                      }
                    },
                    icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                    label: const Text('Change Date'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // --- SUMMARY CARDS ---
            if (record != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: AppColors.surface.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard('Total', '${record.totalTeachers}', AppColors.primary),
                    _buildSummaryCard('Present', '${record.presentCount}', AppColors.success),
                    _buildSummaryCard('Absent', '${record.absentCount}', AppColors.error),
                    _buildSummaryCard('Pending', '${record.notMarkedCount}', AppColors.secondaryText),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
            ],

            // --- MARK ALL PRESENT BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Teacher Roster', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                  OutlinedButton.icon(
                    onPressed: () => notifier.markAllPresent(),
                    icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.success),
                    label: const Text('Mark All Present', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      side: const BorderSide(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // --- TEACHER LIST ---
            Expanded(
              child: attendanceState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : attendanceState.errorMessage != null
                  ? Center(
                child: Text(
                  'Error loading attendance: ${attendanceState.errorMessage}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                ),
              )
                  : record == null || record.teachers.isEmpty
                  ? Center(
                child: Text('No teachers found.', style: AppTypography.bodyMedium),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: record.teachers.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final teacher = record.teachers[index];

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(teacher.teacherName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('${teacher.employeeId} • ${teacher.assignedClass}', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        // Present / Absent Status Controls
                        ToggleButtons(
                          isSelected: [
                            teacher.status == TeacherAttendanceStatus.present,
                            teacher.status == TeacherAttendanceStatus.absent,
                          ],
                          onPressed: (selectedIndex) {
                            final newStatus = selectedIndex == 0
                                ? TeacherAttendanceStatus.present
                                : TeacherAttendanceStatus.absent;
                            notifier.setTeacherStatus(teacher.teacherId, newStatus);
                          },
                          color: AppColors.secondaryText,
                          selectedColor: Colors.white,
                          fillColor: teacher.status == TeacherAttendanceStatus.present
                              ? AppColors.success
                              : AppColors.error,
                          borderRadius: AppRadius.borderRadiusSm,
                          constraints: const BoxConstraints(minHeight: 36, minWidth: 64),
                          children: const [
                            Text('Present', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('Absent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- SAVE ATTENDANCE BUTTON ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: ElevatedButton(
                onPressed: attendanceState.isSaving
                    ? null
                    : () {
                  notifier.saveAttendance(
                    onSuccess: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Teacher attendance saved successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
                ),
                child: attendanceState.isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Text(
                  'Save Attendance',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.heading2.copyWith(color: color, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }
}