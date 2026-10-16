import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../providers/attendance_history_provider.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  final DateTime? initialDateFilter;

  const AttendanceHistoryScreen({
    super.key,
    this.initialDateFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(attendanceHistoryProvider(initialDateFilter));
    final notifier = ref.read(attendanceHistoryProvider(initialDateFilter).notifier);
    final filteredRecords = historyState.filteredRecords;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Attendance History', style: AppTypography.heading2.copyWith(color: AppColors.mainText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- FILTER CONTROLS BAR ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Class Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: historyState.selectedClass,
                          decoration: const InputDecoration(labelText: 'Class Filter', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          items: ['All Classes', 'Grade 8', 'Grade 9', 'Grade 10'].map((cls) {
                            return DropdownMenuItem(value: cls, child: Text(cls));
                          }).toList(),
                          onChanged: (val) => notifier.setClassFilter(val!),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Section Filter
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<String>(
                          value: historyState.selectedSection,
                          decoration: const InputDecoration(labelText: 'Section', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          items: ['All', 'A', 'B', 'C'].map((sec) {
                            return DropdownMenuItem(value: sec, child: sec == 'All' ? const Text('All Sec') : Text('Sec $sec'));
                          }).toList(),
                          onChanged: (val) => notifier.setSectionFilter(val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Date Filter Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.filter_alt_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            historyState.selectedDateFilter != null
                                ? 'Date: ${DateFormat('MMM d, yyyy').format(historyState.selectedDateFilter!)}'
                                : 'Showing All Dates',
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (historyState.selectedDateFilter != null)
                            TextButton(
                              onPressed: () => notifier.setDateFilter(null),
                              child: const Text('Clear Date', style: TextStyle(fontSize: 12)),
                            ),
                          TextButton.icon(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: historyState.selectedDateFilter ?? DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2030),
                              );
                              if (pickedDate != null) {
                                notifier.setDateFilter(pickedDate);
                              }
                            },
                            icon: const Icon(Icons.calendar_month_outlined, size: 16),
                            label: const Text('Select Date', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // --- ATTENDANCE AGGREGATE SUMMARY BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              color: AppColors.surface.withOpacity(0.6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryMetric('Total', '${historyState.totalStudentsCount}', AppColors.primary),
                  _buildSummaryMetric('Present', '${historyState.totalPresentCount}', AppColors.success),
                  _buildSummaryMetric('Absent', '${historyState.totalAbsentCount}', AppColors.error),
                  _buildSummaryMetric('Not Marked', '${historyState.totalNotMarkedCount}', AppColors.secondaryText),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // --- HISTORY RECORDS LIST ---
            Expanded(
              child: historyState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : historyState.errorMessage != null
                  ? Center(child: Text('Error: ${historyState.errorMessage}', style: const TextStyle(color: AppColors.error)))
                  : filteredRecords.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.secondaryText),
                    const SizedBox(height: AppSpacing.md),
                    Text('No attendance records found', style: AppTypography.heading2.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: filteredRecords.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final record = filteredRecords[index];
                  final formattedDate = DateFormat('EEE, MMM d, yyyy').format(record.date);

                  return InkWell(
                    onTap: () {
                      // Navigate to Attendance Screen pre-loaded with this record's date & class context
                      context.pushNamed(
                        'studentAttendance',
                        extra: {'class': record.className, 'section': record.section, 'date': record.date},
                      );
                    },
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: AppRadius.borderRadiusMd,
                            ),
                            child: Center(
                              child: Text(
                                record.section,
                                style: AppTypography.heading2.copyWith(color: AppColors.primary, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(record.className, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                    Text(formattedDate, style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _buildBadge('${record.presentCount} Present', AppColors.success),
                                    const SizedBox(width: 8),
                                    _buildBadge('${record.absentCount} Absent', AppColors.error),
                                    if (record.notMarkedCount > 0) ...[
                                      const SizedBox(width: 8),
                                      _buildBadge('${record.notMarkedCount} Pending', AppColors.secondaryText),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
                        ],
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
  }

  Widget _buildSummaryMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.heading2.copyWith(color: color, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderRadiusFull,
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}