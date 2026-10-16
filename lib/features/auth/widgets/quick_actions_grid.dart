import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'label': 'Students', 'icon': Icons.people_outline, 'route': 'studentsList'},
      {'label': 'Teachers', 'icon': Icons.group_outlined, 'route': 'teachersList'},
      {'label': 'Classes', 'icon': Icons.class_outlined, 'route': 'classList'},
      {'label': 'Attendance', 'icon': Icons.fact_check_outlined, 'route': 'studentAttendance'},
      {'label': 'Teacher Attendance', 'icon': Icons.how_to_reg_outlined, 'route': 'teacherAttendance'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTypography.heading2.copyWith(fontSize: 18)),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive wrap to handle 5 items nicely on both small and wide screens
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: actions.map((action) {
                return InkWell(
                  onTap: () {
                    final routeName = action['route'] as String?;
                    if (routeName != null) {
                      context.pushNamed(routeName);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${action['label']} module coming soon!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  borderRadius: AppRadius.borderRadiusSm,
                  child: SizedBox(
                    width: 75,
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          action['label'] as String,
                          style: AppTypography.bodySmall.copyWith(fontSize: 11),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}