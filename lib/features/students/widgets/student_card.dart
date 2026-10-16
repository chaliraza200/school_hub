import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../domain/student_model.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap; // 1. Declare the onTap callback here

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap, // 2. Require it in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderRadiusMd,
        child: InkWell(
          borderRadius: AppRadius.borderRadiusMd,
          onTap: onTap, // 3. Pass it to the InkWell's onTap handler
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Avatar / Initials
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Center(
                    child: Text(
                      student.fullName.isNotEmpty ? student.fullName.substring(0, 1) : 'S',
                      style: AppTypography.heading2.copyWith(color: AppColors.primary, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Name & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Roll: ${student.rollNumber} | Class: ${student.className}-${student.section}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.secondaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}