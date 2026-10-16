import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../services/excel_export_services.dart';
import '../providers/reports_providers.dart';


class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsProvider);
    final notifier = ref.read(reportsProvider.notifier);

    // Listen for state feedbacks (success/error Snackbars)
    ref.listen<ReportsState>(reportsProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: AppColors.success),
        );
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: AppColors.error),
        );
      }
    });

    final reportCards = [
      _ReportOptionConfig(
        title: 'Student List',
        subtitle: 'Export complete enrolled student records',
        icon: Icons.school_rounded,
        type: ReportType.studentList,
      ),
      _ReportOptionConfig(
        title: 'Teacher List',
        subtitle: 'Export faculty and department details',
        icon: Icons.person_outline_rounded,
        type: ReportType.teacherList,
      ),
      _ReportOptionConfig(
        title: 'Class & Student Data',
        subtitle: 'Export section breakdown & capacities',
        icon: Icons.class_rounded,
        type: ReportType.classAndStudentData,
      ),
      _ReportOptionConfig(
        title: 'Student Attendance',
        subtitle: 'Export student attendance logs by date/class',
        icon: Icons.how_to_reg_rounded,
        type: ReportType.studentAttendance,
      ),
      _ReportOptionConfig(
        title: 'Teacher Attendance',
        subtitle: 'Export faculty daily attendance sheets',
        icon: Icons.badge_rounded,
        type: ReportType.teacherAttendance,
      ),
      _ReportOptionConfig(
        title: 'Fee Records',
        subtitle: 'Export financial collections & dues in PKR',
        icon: Icons.receipt_long_rounded,
        type: ReportType.feeRecords,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Reports & Export', style: AppTypography.heading2.copyWith(color: AppColors.mainText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- GLOBAL FILTERS BAR (Responsive Layout) ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter Export Data', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 650) {
                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: state.selectedClass,
                              isExpanded: true,
                              decoration: _filterDecoration('Class'),
                              items: ['Grade 8', 'Grade 9', 'Grade 10']
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppTypography.bodySmall)))
                                  .toList(),
                              onChanged: (val) => notifier.setClassFilter(val),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: state.selectedSection,
                                    isExpanded: true,
                                    decoration: _filterDecoration('Section'),
                                    items: ['A', 'B']
                                        .map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTypography.bodySmall)))
                                        .toList(),
                                    onChanged: (val) => notifier.setSectionFilter(val),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: state.selectedStatus,
                                    isExpanded: true,
                                    decoration: _filterDecoration('Status'),
                                    items: ['Active', 'Inactive', 'Pending']
                                        .map((st) => DropdownMenuItem(value: st, child: Text(st, style: AppTypography.bodySmall)))
                                        .toList(),
                                    onChanged: (val) => notifier.setStatusFilter(val),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: state.selectedClass,
                              isExpanded: true,
                              decoration: _filterDecoration('Class'),
                              items: ['Grade 8', 'Grade 9', 'Grade 10']
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppTypography.bodySmall)))
                                  .toList(),
                              onChanged: (val) => notifier.setClassFilter(val),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: state.selectedSection,
                              isExpanded: true,
                              decoration: _filterDecoration('Section'),
                              items: ['A', 'B']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTypography.bodySmall)))
                                  .toList(),
                              onChanged: (val) => notifier.setSectionFilter(val),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: state.selectedStatus,
                              isExpanded: true,
                              decoration: _filterDecoration('Status'),
                              items: ['Active', 'Inactive', 'Pending']
                                  .map((st) => DropdownMenuItem(value: st, child: Text(st, style: AppTypography.bodySmall)))
                                  .toList(),
                              onChanged: (val) => notifier.setStatusFilter(val),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // --- REPORT OPTIONS LIST ---
            Expanded(
              child: state.isExporting
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: AppSpacing.md),
                    Text('Generating .xlsx file for print & record keeping...'),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: reportCards.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final report = reportCards[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: AppRadius.borderRadiusSm,
                          ),
                          child: Icon(report.icon, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(report.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(report.subtitle, style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton.icon(
                          onPressed: () => notifier.exportReport(report.type),
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Export to Excel'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
                            textStyle: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ],
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

  InputDecoration _filterDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSm, borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSm, borderSide: const BorderSide(color: AppColors.border)),
    );
  }
}

class _ReportOptionConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final ReportType type;

  const _ReportOptionConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
  });
}