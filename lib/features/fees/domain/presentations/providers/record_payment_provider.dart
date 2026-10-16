import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class RecordPaymentState {
  final double amount;
  final String paymentMethod;
  final String referenceNumber;
  final String remarks;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final Map<String, dynamic>? receiptDetails;

  RecordPaymentState({
    this.amount = 0.0,
    this.paymentMethod = 'Cash',
    this.referenceNumber = '',
    this.remarks = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.receiptDetails,
  });

  RecordPaymentState copyWith({
    double? amount,
    String? paymentMethod,
    String? referenceNumber,
    String? remarks,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    Map<String, dynamic>? receiptDetails,
  }) {
    return RecordPaymentState(
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      remarks: remarks ?? this.remarks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      receiptDetails: receiptDetails ?? this.receiptDetails,
    );
  }
}

class RecordPaymentNotifier extends StateNotifier<RecordPaymentState> {
  RecordPaymentNotifier() : super(RecordPaymentState());

  void setAmount(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    state = state.copyWith(amount: parsed, errorMessage: null);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setReferenceNumber(String refNo) {
    state = state.copyWith(referenceNumber: refNo);
  }

  void setRemarks(String remarks) {
    state = state.copyWith(remarks: remarks);
  }

  Future<bool> submitPayment({
    required double totalFee,
    required double currentPaid,
    required String studentName,
    required String rollNumber,
    required String className,
  }) async {
    final remainingBalance = totalFee - currentPaid;

    // Validation checks
    if (state.amount <= 0) {
      state = state.copyWith(errorMessage: 'Please enter a valid payment amount greater than zero.');
      return false;
    }

    if (state.amount > remainingBalance) {
      state = state.copyWith(
        errorMessage: 'Payment amount cannot exceed the remaining balance (Rs. ${remainingBalance.toStringAsFixed(0)}).',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate backend processing

      final receipt = {
        'receiptNo': 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'studentName': studentName,
        'rollNumber': rollNumber,
        'className': className,
        'amountPaid': state.amount,
        'paymentMethod': state.paymentMethod,
        'referenceNumber': state.referenceNumber,
        'date': DateTime.now().toString().split(' ')[0],
      };

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        receiptDetails: receipt,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to record payment. Please try again.',
      );
      return false;
    }
  }

  void reset() {
    state = RecordPaymentState();
  }
}

final recordPaymentProvider =
StateNotifierProvider.autoDispose<RecordPaymentNotifier, RecordPaymentState>(
      (ref) => RecordPaymentNotifier(),
);