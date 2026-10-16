import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../reports/services/payment_history_export_service.dart';


class PaymentHistoryState {
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedClass;
  final String? selectedMethod;
  final List<PaymentHistoryRecordModel> records;

  PaymentHistoryState({
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedClass,
    this.selectedMethod,
    this.records = const [],
  });

  PaymentHistoryState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedClass,
    String? selectedMethod,
    List<PaymentHistoryRecordModel>? records,
  }) {
    return PaymentHistoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      records: records ?? this.records,
    );
  }

  List<PaymentHistoryRecordModel> get filteredRecords {
    return records.where((record) {
      final matchesSearch = record.studentName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          record.rollNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
          record.receiptNo.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesClass = selectedClass == null || selectedClass == 'All' || record.className == selectedClass;
      final matchesMethod = selectedMethod == null || selectedMethod == 'All' || record.paymentMethod == selectedMethod;

      return matchesSearch && matchesClass && matchesMethod;
    }).toList();
  }
}

class PaymentHistoryNotifier extends StateNotifier<PaymentHistoryState> {
  PaymentHistoryNotifier() : super(PaymentHistoryState()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final mockHistory = [
        PaymentHistoryRecordModel(
          receiptNo: 'REC-1001',
          studentName: 'Hamza Ahmed',
          rollNumber: 'R-101',
          className: 'Class 10-A',
          amount: 5000.0,
          date: '10 Oct 2026',
          paymentMethod: 'Cash',
        ),
        PaymentHistoryRecordModel(
          receiptNo: 'REC-1002',
          studentName: 'Ayesha Malik',
          rollNumber: 'R-102',
          className: 'Class 9-B',
          amount: 4500.0,
          date: '09 Oct 2026',
          paymentMethod: 'Bank Transfer',
        ),
        PaymentHistoryRecordModel(
          receiptNo: 'REC-1003',
          studentName: 'Bilal Raza',
          rollNumber: 'R-103',
          className: 'Class 8-A',
          amount: 6000.0,
          date: '09 Oct 2026',
          paymentMethod: 'Cash',
        ),
      ];

      state = state.copyWith(isLoading: false, records: mockHistory);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load payment history.');
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedClass(String? className) {
    state = state.copyWith(selectedClass: className);
  }

  void setSelectedMethod(String? method) {
    state = state.copyWith(selectedMethod: method);
  }

  Future<bool> exportToExcel() async {
    return await PaymentHistoryExportService.exportPaymentHistoryToExcel(
      records: state.filteredRecords,
    );
  }
}

final paymentHistoryProvider =
StateNotifierProvider.autoDispose<PaymentHistoryNotifier, PaymentHistoryState>(
      (ref) => PaymentHistoryNotifier(),
);