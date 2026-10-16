import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class FeeStaffLoginState {
  final String email;
  final String password;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;

  FeeStaffLoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.obscurePassword = true,
    this.errorMessage,
  });

  FeeStaffLoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? obscurePassword,
    String? errorMessage,
  }) {
    return FeeStaffLoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: errorMessage,
    );
  }
}

class FeeStaffLoginNotifier extends StateNotifier<FeeStaffLoginState> {
  FeeStaffLoginNotifier() : super(FeeStaffLoginState());

  void setEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> login() async {
    final email = state.email.trim();
    final password = state.password.trim();

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter both email and password.');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      state = state.copyWith(errorMessage: 'Please enter a valid email address.');
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(errorMessage: 'Password must be at least 6 characters.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate backend authentication & role verification as Fee Staff
      await Future.delayed(const Duration(seconds: 1));

      // Backend-ready placeholder: verified role check can be integrated here
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed. Please check your credentials.',
      );
      return false;
    }
  }
}

final feeStaffLoginProvider =
StateNotifierProvider.autoDispose<FeeStaffLoginNotifier, FeeStaffLoginState>(
      (ref) => FeeStaffLoginNotifier(),
);