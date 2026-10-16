import 'package:flutter_riverpod/legacy.dart';
import '../../domain/user_role.dart';

class RoleSelectionNotifier extends StateNotifier<UserRole?> {
  RoleSelectionNotifier() : super(null);

  void selectRole(UserRole role) {
    state = role;
  }
}

final selectedRoleProvider = StateNotifierProvider<RoleSelectionNotifier, UserRole?>(
      (ref) => RoleSelectionNotifier(),
);