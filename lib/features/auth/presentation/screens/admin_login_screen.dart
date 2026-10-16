import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../providers/admin_login_provider.dart';
import '../../widgets/auth_text_field.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(adminLoginProvider.notifier);
      final success = await notifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        // Navigate to Admin Dashboard. Real auth role verification will guard this route later.
        context.goNamed('dashboard', pathParameters: {'role': 'admin'});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(adminLoginProvider);
    final isLoading = loginState.status == LoginStateStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
          child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      // Branding Icon
                      Center(
                      child: Container(
                      width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: AppRadius.borderRadiusLg,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Header Text
                    Text(
                      'School Hub',
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Admin Login',
                      style: AppTypography.heading1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sign in to manage your school',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Error Message Banner (if any)
                    if (loginState.errorMessage != null) ...[
            Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: AppRadius.borderRadiusSm,
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Text(
              loginState.errorMessage!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ],

      // Email Field
      AuthTextField(
      controller: _emailController,
      label: 'Email Address',
      hint: 'admin@schoolhub.com',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
          validator: (value) {
    if (value == null || value.trim().isEmpty) {
    return 'Please enter your email';
    }
    if (!value.contains('@') || !value.contains('.')) {
    return 'Please enter a valid email address';
    }
    return null;
    },
    ),
    const SizedBox(height: AppSpacing.lg),

    // Password Field
    AuthTextField(
    controller: _passwordController,
    label: 'Password',
    hint: 'Enter your password',
    prefixIcon: Icons.lock_outline_rounded,
    obscureText: loginState.obscurePassword,
    suffixIcon: IconButton(
    icon: Icon(
    loginState.obscurePassword
    ? Icons.visibility_off_outlined
        : Icons.visibility_outlined,
    color: AppColors.secondaryText,
    size: 20,
    ),
    onPressed: () {
    ref
        .read(adminLoginProvider.notifier)
        .togglePasswordVisibility();
    },
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your password';
    }
    if (value.length < 6) {
    return 'Password must be at least 6 characters';
    }
    return null;
    },
    ),
    const SizedBox(height: AppSpacing.md),

    // Forgot Password Action
    Align(
    alignment: Alignment.centerRight,
    child: TextButton(
    onPressed: () {
    // Hook for future password recovery flow
    },
    style: TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: EdgeInsets.zero,
    minimumSize: const Size(50, 30),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Text(
    'Forgot Password?',
    style: AppTypography.bodySmall.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ),
    const SizedBox(height: AppSpacing.xl),

    // Full-width Sign In Button
    ElevatedButton(
    onPressed: isLoading ? null : _handleLogin,
    child: isLoading
    ? const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
    strokeWidth: 2,
    color: Colors.white,
    ),
    )
        : const Text('Sign In'),
    ),
    const SizedBox(height: AppSpacing.xxl),
    ],
    ),
    ),
    ),
    ),
    ),
    ),
    );
  }
}