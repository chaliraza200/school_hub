import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../domain/admin_dashboard_model.dart';

class SummaryMetricsGrid extends StatelessWidget {
  final AdminDashboardData data;

  const SummaryMetricsGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          title: 'Total Students',
          value: '${data.totalStudents}',
          icon: Icons.people_outline,
          color: AppColors.primary,
        ),
        _MetricCard(
          title: 'Total Teachers',
          value: '${data.totalTeachers}',
          icon: Icons.badge_outlined,
          color: AppColors.info,
        ),
        _MetricCard(
          title: 'Total Classes',
          value: '${data.totalClasses}',
          icon: Icons.class_outlined,
          color: AppColors.warning,
        ),
        _MetricCard(
          title: "Today's Attendance",
          value: '${data.attendancePercentage}%',
          icon: Icons.how_to_reg_outlined,
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.bodySmall),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: AppTypography.heading1.copyWith(fontSize: 22, color: AppColors.mainText),
          ),
        ],
      ),
    );
  }
}