import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../fees/domain/presentations/widgets/fee_overview_card.dart';
import '../providers/admin_dashboard_provider.dart';
import '../../widgets/dashboard_header_card.dart';
import '../../widgets/summary_metrics_grid.dart';
import '../../widgets/quick_actions_grid.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(adminDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('School Hub', style: AppTypography.heading2.copyWith(color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.secondaryText),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: dashboardState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Failed to load dashboard: $err', style: AppTypography.bodyMedium),
        ),
        data: (data) => SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  DashboardHeaderCard(
                    adminName: data.adminName,
                    schoolName: data.schoolName,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SummaryMetricsGrid(data: data),
                  const SizedBox(height: AppSpacing.xl),

                  const QuickActionsGrid(),
                  const SizedBox(height: AppSpacing.xl),

                  // Today's Attendance Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Today's Attendance", style: AppTypography.heading2.copyWith(fontSize: 16)),
                            TextButton(
                              onPressed: () {
                                final today = DateTime.now();
                                context.pushNamed('attendanceHistory', extra: today);
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _AttendancePill(
                                label: 'Present',
                                count: '${data.presentStudents}',
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _AttendancePill(
                                label: 'Absent',
                                count: '${data.absentStudents}',
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Reusable Fee Overview Card Component
                  const FeeOverviewCard(),
                  const SizedBox(height: AppSpacing.xl),

                  // 👉 NEW: Reports & Export Section Card
                  InkWell(
                    onTap: () => context.push('/reports'),
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: AppRadius.borderRadiusSm,
                            ),
                            child: const Icon(
                              Icons.analytics_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reports & Export',
                                  style: AppTypography.heading2.copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Generate & share Excel (.xlsx) reports',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendancePill extends StatelessWidget {
  final String label;
  final String count;
  final Color color;

  const _AttendancePill({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSm,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w600)),
          Text(count, style: AppTypography.bodyLarge.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}