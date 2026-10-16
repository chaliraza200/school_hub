import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../domain/user_role.dart';

class RoleCardWidget extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCardWidget({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${role.title} role: ${role.description}',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 48), // Minimum interactive target
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
                : [],
          ),
          child: Row(
            children: [
              // Role Icon / Indicator placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(
                  _getRoleIcon(role),
                  color: isSelected ? AppColors.primary : AppColors.secondaryText,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.mainText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      role.description,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Radio / Check Indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 6.0 : 1.5,
                  ),
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
      case UserRole.teacher:
        return Icons.school_outlined;
      case UserRole.feeStaff:
        return Icons.receipt_long_outlined;
    }
  }
}