import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../providers/teacher_dashboard_provider.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherDashboardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('School Hub - Teacher Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              // Handle logout and return to role selection / login
              context.go('/');
            },
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
                // Welcome Section (Fixed line 51 overflow with Expanded)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        state.teacherName.isNotEmpty
                            ? state.teacherName[0]
                            : 'T',
                        style: AppTypography.heading2.copyWith(
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
                            'Welcome, ${state.teacherName}',
                            style: AppTypography.heading2,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Manage your class attendance efficiently',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Assigned Class Card (Fixed line 93 overflow with Expanded)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.borderRadiusMd,
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
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              state.assignedClass,
                              style: AppTypography.heading1.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Icon(
                        Icons.class_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Quick Actions Section
                Text('Quick Actions', style: AppTypography.heading1),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.how_to_reg_rounded,
                            label: 'Take Attendance',
                            onTap: () {
                              context.push('/teacher-dashboard-attendance');
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.history_rounded,
                            label: 'Attendance History',
                            onTap: () {
                              context.push('/teacher-dashboard-attendance-history');
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Today's Attendance Summary
                Text("Today's Attendance Summary", style: AppTypography.heading1),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Present',
                        count: '${state.presentCount}',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Absent',
                        count: '${state.absentCount}',
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Not Marked',
                        count: '${state.notMarkedCount}',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Recent Attendance History Section
                Text('Recent Attendance History', style: AppTypography.heading1),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.recentHistory.length,
                    separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final history = state.recentHistory[index];
                      return ListTile(
                        title: Text('Date: ${history['date']}'),
                        subtitle: Text(
                            'Present: ${history['present']} | Absent: ${history['absent']}'),
                        trailing: Chip(
                          label: Text(history['status'] ?? ''),
                          backgroundColor: Colors.green.withOpacity(0.1),
                          labelStyle: const TextStyle(color: Colors.green),
                        ),
                      );
                    },
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

// Helper Widget for Quick Actions
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Summary Cards
class _SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;

  const _SummaryCard({
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
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            count,
            style: AppTypography.heading2.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}