import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../fee_model.dart';

class FeesScreenState {
  final List<FeeModel> fees;
  final List<FeeModel> filteredFees;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedClass;
  final String? selectedSection;
  final FeeStatus? selectedStatus;

  const FeesScreenState({
    this.fees = const [],
    this.filteredFees = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedClass,
    this.selectedSection,
    this.selectedStatus,
  });

  double get totalExpected => fees.fold(0.0, (sum, f) => sum + f.monthlyFee);
  double get totalCollected => fees.fold(0.0, (sum, f) => sum + f.paidAmount);
  double get totalPending => fees.fold(0.0, (sum, f) => sum + f.pendingAmount);

  FeesScreenState copyWith({
    List<FeeModel>? fees,
    List<FeeModel>? filteredFees,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedClass,
    String? selectedSection,
    FeeStatus? selectedStatus,
    bool clearClass = false,
    bool clearSection = false,
    bool clearStatus = false,
  }) {
    return FeesScreenState(
      fees: fees ?? this.fees,
      filteredFees: filteredFees ?? this.filteredFees,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedClass: clearClass ? null : (selectedClass ?? this.selectedClass),
      selectedSection: clearSection ? null : (selectedSection ?? this.selectedSection),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }
}

class FeesScreenNotifier extends StateNotifier<FeesScreenState> {
  FeesScreenNotifier() : super(const FeesScreenState()) {
    fetchFees();
  }

  Future<void> fetchFees() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final mockList = [
        FeeModel(
          id: 'f1',
          studentId: 'STU-101',
          studentName: 'Liam Johnson',
          className: 'Grade 10',
          section: 'A',
          monthlyFee: 25000.0,
          paidAmount: 25000.0,
          pendingAmount: 0.0,
          status: FeeStatus.paid,
          dueDate: DateTime(2026, 5, 10),
        ),
        FeeModel(
          id: 'f2',
          studentId: 'STU-102',
          studentName: 'Sophia Martinez',
          className: 'Grade 10',
          section: 'B',
          monthlyFee: 25000.0,
          paidAmount: 10000.0,
          pendingAmount: 15000.0,
          status: FeeStatus.partial,
          dueDate: DateTime(2026, 5, 15),
        ),
        FeeModel(
          id: 'f3',
          studentId: 'STU-103',
          studentName: 'Noah Williams',
          className: 'Grade 9',
          section: 'A',
          monthlyFee: 22000.0,
          paidAmount: 0.0,
          pendingAmount: 22000.0,
          status: FeeStatus.pending,
          dueDate: DateTime(2026, 5, 10),
        ),
        FeeModel(
          id: 'f4',
          studentId: 'STU-104',
          studentName: 'Emma Brown',
          className: 'Grade 8',
          section: 'A',
          monthlyFee: 20000.0,
          paidAmount: 0.0,
          pendingAmount: 20000.0,
          status: FeeStatus.overdue,
          dueDate: DateTime(2026, 4, 25),
        ),
      ];
      state = state.copyWith(fees: mockList, filteredFees: mockList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void setClassFilter(String? className) {
    state = state.copyWith(selectedClass: className, clearClass: className == null);
    _applyFilters();
  }

  void setSectionFilter(String? section) {
    state = state.copyWith(selectedSection: section, clearSection: section == null);
    _applyFilters();
  }

  void setStatusFilter(FeeStatus? status) {
    state = state.copyWith(selectedStatus: status, clearStatus: status == null);
    _applyFilters();
  }

  void _applyFilters() {
    var list = state.fees;

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      list = list.where((f) => f.studentName.toLowerCase().contains(q) || f.studentId.toLowerCase().contains(q)).toList();
    }

    if (state.selectedClass != null) {
      list = list.where((f) => f.className == state.selectedClass).toList();
    }

    if (state.selectedSection != null) {
      list = list.where((f) => f.section == state.selectedSection).toList();
    }

    if (state.selectedStatus != null) {
      list = list.where((f) => f.status == state.selectedStatus).toList();
    }

    state = state.copyWith(filteredFees: list);
  }

  Future<void> recordPayment({required String feeId, required double paymentAmount}) async {
    final updatedFees = state.fees.map((f) {
      if (f.id == feeId) {
        final newPaid = f.paidAmount + paymentAmount;
        final newPending = (f.monthlyFee - newPaid).clamp(0.0, double.infinity);
        final newStatus = newPending == 0 ? FeeStatus.paid : FeeStatus.partial;
        return f.copyWith(paidAmount: newPaid, pendingAmount: newPending, status: newStatus);
      }
      return f;
    }).toList();

    state = state.copyWith(fees: updatedFees);
    _applyFilters();
  }
}

final feesScreenProvider = StateNotifierProvider.autoDispose<FeesScreenNotifier, FeesScreenState>(
      (ref) => FeesScreenNotifier(),
);