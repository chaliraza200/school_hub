import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/attendance_model.dart';
import '../providers/attendance_provider.dart';

class StudentAttendanceScreen extends ConsumerWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider);
    final notifier = ref.read(attendanceProvider.notifier);
    final record = attendanceState.attendanceRecord;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Student Attendance', style: AppTypography.heading2.copyWith(color: AppColors.mainText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- FILTERS & CONTROLS HEADER ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Class Selector
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: attendanceState.selectedClass,
                          decoration: const InputDecoration(labelText: 'Class', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          items: ['Grade 8', 'Grade 9', 'Grade 10'].map((cls) {
                            return DropdownMenuItem(value: cls, child: Text(cls));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) notifier.updateClassSelection(val);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Section Selector
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<String>(
                          value: attendanceState.selectedSection,
                          decoration: const InputDecoration(labelText: 'Section', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          items: ['A', 'B', 'C'].map((sec) {
                            return DropdownMenuItem(value: sec, child: Text('Sec $sec'));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) notifier.updateSectionSelection(val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Date Picker Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
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
                            notifier.updateDateSelection(pickedDate);
                          }
                        },
                        icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                        label: const Text('Change Date'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // --- SUMMARY BAR & MARK ALL PRESENT ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              color: AppColors.surface.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    record != null ? '${record.className} - Sec ${record.section} (${record.students.length} Students)' : 'Loading summary...',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                  ),
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

            // --- STUDENT ATTENDANCE LIST ---
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
                  : record == null || record.students.isEmpty
                  ? Center(
                child: Text('No students found for this class.', style: AppTypography.bodyMedium),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: record.students.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final student = record.students[index];

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
                              Text(student.studentName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('Roll: ${student.rollNumber}', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        // Status Toggle Buttons (Present / Absent)
                        ToggleButtons(
                          isSelected: [
                            student.status == AttendanceStatus.present,
                            student.status == AttendanceStatus.absent,
                          ],
                          onPressed: (selectedIndex) {
                            final newStatus = selectedIndex == 0 ? AttendanceStatus.present : AttendanceStatus.absent;
                            notifier.setStudentStatus(student.studentId, newStatus);
                          },
                          color: AppColors.secondaryText,
                          selectedColor: Colors.white,
                          fillColor: student.status == AttendanceStatus.present ? AppColors.success : AppColors.error,
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
                          content: Text('Attendance saved successfully!'),
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
}