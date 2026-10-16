import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/user_role.dart';
import '../providers/role_selection_provider.dart';
import '../../widgets/role_card_widget.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedRoleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480), // Perfect scaling for mobile & web wrapper
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 1),
                  // Header branding
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'School Hub',
                    style: AppTypography.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Select your role to continue',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  // Role Cards List
                  ...UserRole.values.map((role) {
                    final isSelected = selectedRole == role;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: RoleCardWidget(
                        role: role,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(selectedRoleProvider.notifier).selectRole(role);
                        },
                      ),
                    );
                  }),
                  const Spacer(flex: 2),
                  // Continue Action Button (Disabled until role is selected)
                  ElevatedButton(
                    onPressed: selectedRole == null
                        ? null
                        : () {
                      // Agar Teacher select kiya hai toh naye Teacher Login screen par jayein
                      if (selectedRole == UserRole.teacher) {
                        context.push('/teacher-login');
                      }
                      else if (selectedRole == UserRole.feeStaff) { // Apna exact enum name check karlein (e.g., feeStaff / fee)
                        context.push('/fee-staff-login');
                      }
                      else {
                        // Baaki roles ke liye purana routing logic
                        context.pushNamed(
                          'login',
                          pathParameters: {'role': selectedRole.routeParam},
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppColors.secondaryText,
                    ),
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}