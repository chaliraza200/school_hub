import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// State class to manage Teacher Login state
class TeacherLoginState {
  final bool isLoading;
  final String? errorMessage;
  final bool obscurePassword;

  TeacherLoginState({
    this.isLoading = false,
    this.errorMessage,
    this.obscurePassword = true,
  });

  TeacherLoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? obscurePassword,
  }) {
    return TeacherLoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

class TeacherLoginNotifier extends StateNotifier<TeacherLoginState> {
  TeacherLoginNotifier() : super(TeacherLoginState());

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> login({required String email, required String password}) async {
    // Basic validation check
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill in all fields.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate backend authentication delay (Backend-ready placeholder)
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Integrate actual backend authentication & verify 'Teacher' role

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Authentication failed. Please try again.',
      );
      return false;
    }
  }
}

final teacherLoginProvider =
StateNotifierProvider.autoDispose<TeacherLoginNotifier, TeacherLoginState>(
      (ref) => TeacherLoginNotifier(),
);