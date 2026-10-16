import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class PaymentRecord {
  final String id;
  final String studentName;
  final String className;
  final double amount;
  final String date;
  final String status;

  PaymentRecord({
    required this.id,
    required this.studentName,
    required this.className,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class FeeDashboardState {
  final bool isLoading;
  final String? errorMessage;
  final String staffName;
  final double totalFeesCollected;
  final double pendingFees;
  final double todaysCollections;
  final List<PaymentRecord> recentPayments;

  FeeDashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.staffName = 'Ali Khan',
    this.totalFeesCollected = 450000.0,
    this.pendingFees = 85000.0,
    this.todaysCollections = 24500.0,
    this.recentPayments = const [],
  });

  FeeDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? staffName,
    double? totalFeesCollected,
    double? pendingFees,
    double? todaysCollections,
    List<PaymentRecord>? recentPayments,
  }) {
    return FeeDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      staffName: staffName ?? this.staffName,
      totalFeesCollected: totalFeesCollected ?? this.totalFeesCollected,
      pendingFees: pendingFees ?? this.pendingFees,
      todaysCollections: todaysCollections ?? this.todaysCollections,
      recentPayments: recentPayments ?? this.recentPayments,
    );
  }
}

class FeeDashboardNotifier extends StateNotifier<FeeDashboardState> {
  FeeDashboardNotifier() : super(FeeDashboardState()) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate fetch

      final mockPayments = [
        PaymentRecord(
          id: 'INV-1001',
          studentName: 'Hamza Ahmed',
          className: 'Class 10-A',
          amount: 5000.0,
          date: '10 Oct 2026',
          status: 'Paid',
        ),
        PaymentRecord(
          id: 'INV-1002',
          studentName: 'Ayesha Malik',
          className: 'Class 9-B',
          amount: 4500.0,
          date: '09 Oct 2026',
          status: 'Paid',
        ),
        PaymentRecord(
          id: 'INV-1003',
          studentName: 'Bilal Raza',
          className: 'Class 8-A',
          amount: 6000.0,
          date: '09 Oct 2026',
          status: 'Paid',
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        recentPayments: mockPayments,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load fee dashboard data.',
      );
    }
  }
}

final feeDashboardProvider =
StateNotifierProvider.autoDispose<FeeDashboardNotifier, FeeDashboardState>(
      (ref) => FeeDashboardNotifier(),
);