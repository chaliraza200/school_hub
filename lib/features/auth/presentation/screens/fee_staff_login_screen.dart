import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../providers/fee_staff_login_provider.dart';

class FeeStaffLoginScreen extends ConsumerWidget {
  const FeeStaffLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feeStaffLoginProvider);
    final notifier = ref.read(feeStaffLoginProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.borderRadiusLg,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                  // School Hub Branding
                  Center(
                  child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'School Hub',
                textAlign: TextAlign.center,
                style: AppTypography.heading1.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Fee Staff Login',
                textAlign: TextAlign.center,
                style: AppTypography.heading2,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign in to manage student fees and payments',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Error Message banner if any
              if (state.errorMessage != null) ...[
      Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Text(
        state.errorMessage!,
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 13,
        ),
      ),
    ),
    const SizedBox(height: AppSpacing.md),
    ],

    // Email Field
    Text(
    'Email Address',
    style: AppTypography.bodySmall.copyWith(
    fontWeight: FontWeight.w600,
    ),
    ),
    const SizedBox(height: AppSpacing.xs),
    TextField(
    keyboardType: TextInputType.emailAddress,
    onChanged: notifier.setEmail,
    decoration: const InputDecoration(
    hintText: 'feestaff@schoolhub.com',
    prefixIcon: Icon(Icons.email_outlined),
    ),
    ),
    const SizedBox(height: AppSpacing.md),

    // Password Field
    Text(
    'Password',
    style: AppTypography.bodySmall.copyWith(
    fontWeight: FontWeight.w600,
    ),
    ),
    const SizedBox(height: AppSpacing.xs),
    TextField(
    obscureText: state.obscurePassword,
    onChanged: notifier.setPassword,
    decoration: InputDecoration(
    hintText: 'Enter your password',
    prefixIcon: const Icon(Icons.lock_outline_rounded),
    suffixIcon: IconButton(
    icon: Icon(
    state.obscurePassword
    ? Icons.visibility_off_outlined
        : Icons.visibility_outlined,
    ),
    onPressed: notifier.togglePasswordVisibility,
    ),
    ),
    ),
    const SizedBox(height: AppSpacing.sm),

    // Forgot Password Action
    Align(
    alignment: Alignment.centerRight,
    child: TextButton(
    onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Password recovery link sent to email.'),
    ),
    );
    },
    child: Text(
    'Forgot Password?',
    style: AppTypography.bodySmall.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ),
    const SizedBox(height: AppSpacing.md),

    // Sign In Button
    // Sign In Button
    FilledButton(
    onPressed: state.isLoading
    ? null
        : () async {
    final success = await notifier.login();
    if (success && context.mounted) {
    // Navigate to Fee Staff Dashboard
    context.go('/fee-staff-dashboard');
    }
    },
    child: state.isLoading
    ? const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
    strokeWidth: 2,
    color: Colors.white,
    ),
    )
        : const Text('Sign In'),
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    );
  }
}