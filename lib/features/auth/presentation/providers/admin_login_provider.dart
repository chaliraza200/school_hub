import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum LoginStateStatus { idle, loading, success, error }

class LoginState {
  final LoginStateStatus status;
  final String? errorMessage;
  final bool obscurePassword;

  const LoginState({
    this.status = LoginStateStatus.idle,
    this.errorMessage,
    this.obscurePassword = true,
  });

  LoginState copyWith({
    LoginStateStatus? status,
    String? errorMessage,
    bool? obscurePassword,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

class AdminLoginNotifier extends StateNotifier<LoginState> {
  AdminLoginNotifier() : super(const LoginState());

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: LoginStateStatus.loading, errorMessage: null);

    try {
      // Simulate backend preparation delay.
      // Ready to be replaced with actual Firebase Auth call later.
      await Future.delayed(const Duration(milliseconds: 1200));

      // Placeholder condition for validation demo. Real backend will handle errors.
      if (email.isEmpty || password.isEmpty) {
        state = state.copyWith(
          status: LoginStateStatus.error,
          errorMessage: 'Please enter both email and password.',
        );
        return false;
      }

      state = state.copyWith(status: LoginStateStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: LoginStateStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const LoginState();
  }
}

final adminLoginProvider = StateNotifierProvider.autoDispose<AdminLoginNotifier, LoginState>(
      (ref) => AdminLoginNotifier(),
);