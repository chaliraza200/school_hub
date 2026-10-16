enum UserRole {
  admin,
  teacher,
  feeStaff,
}

extension UserRoleExtension on UserRole {
  String get title {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.feeStaff:
        return 'Fee Staff';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Manage school operations';
      case UserRole.teacher:
        return 'Manage classes and attendance';
      case UserRole.feeStaff:
        return 'Manage fees and payments';
    }
  }

  String get routeParam {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.feeStaff:
        return 'fee-staff';
    }
  }
}