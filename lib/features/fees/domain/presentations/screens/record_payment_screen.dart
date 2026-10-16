import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_radius.dart';
import '../../../../../theme/app_spacing.dart';
import '../../../../../theme/app_typography.dart';
import '../providers/record_payment_provider.dart';

class RecordPaymentScreen extends ConsumerWidget {
  final String studentName;
  final String rollNumber;
  final String className;
  final double totalFee;
  final double paidAmount;

  const RecordPaymentScreen({
    super.key,
    this.studentName = 'Hamza Ahmed',
    this.rollNumber = 'R-101',
    this.className = 'Class 10-A',
    this.totalFee = 25000.0,
    this.paidAmount = 15000.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordPaymentProvider);
    final notifier = ref.read(recordPaymentProvider.notifier);
    final remainingBalance = totalFee - paidAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Record Student Payment'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: state.isSuccess && state.receiptDetails != null
                ? _ReceiptPreviewCard(receipt: state.receiptDetails!)
                : Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Student Summary Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          studentName[0],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: AppTypography.heading2,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Roll: $rollNumber • $className',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Fee Breakdown Cards
                  Row(
                    children: [
                      Expanded(
                        child: _FeeStatBox(
                          label: 'Total Fee',
                          amount: 'Rs. ${totalFee.toStringAsFixed(0)}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _FeeStatBox(
                          label: 'Paid Amount',
                          amount: 'Rs. ${paidAmount.toStringAsFixed(0)}',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _FeeStatBox(
                          label: 'Balance Due',
                          amount: 'Rs. ${remainingBalance.toStringAsFixed(0)}',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Error Banner
                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Payment Amount Input
                  Text(
                    'Payment Amount (Rs.) *',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: notifier.setAmount,
                    decoration: const InputDecoration(
                      hintText: 'Enter amount to pay',
                      prefixIcon: Icon(Icons.currency_rupee_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Payment Method Dropdown
                  Text(
                    'Payment Method *',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<String>(
                    value: state.paymentMethod,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.payment_rounded),
                    ),
                    items: ['Cash', 'Bank Transfer', 'Other']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) notifier.setPaymentMethod(val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Reference Number (Optional)
                  Text(
                    'Transaction / Reference Number (Optional)',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    onChanged: notifier.setReferenceNumber,
                    decoration: const InputDecoration(
                      hintText: 'e.g., TRX-987654',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Remarks (Optional)
                  Text(
                    'Remarks (Optional)',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    onChanged: notifier.setRemarks,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Add any additional notes here...',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Submit Button
                  FilledButton(
                    onPressed: state.isLoading
                        ? null
                        : () => notifier.submitPayment(
                      totalFee: totalFee,
                      currentPaid: paidAmount,
                      studentName: studentName,
                      rollNumber: rollNumber,
                      className: className,
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Record Payment'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Widget for Fee Stat Boxes
class _FeeStatBox extends StatelessWidget {
  final String label;
  final String amount;
  final Color? color;

  const _FeeStatBox({
    required this.label,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Receipt Preview Card after successful submission
class _ReceiptPreviewCard extends ConsumerWidget {
  final Map<String, dynamic> receipt;

  const _ReceiptPreviewCard({required this.receipt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 56,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Payment Recorded Successfully!',
            textAlign: TextAlign.center,
            style: AppTypography.heading2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Official Fee Receipt',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
          ),
          const Divider(height: 32),
          _ReceiptRow(label: 'Receipt No', value: receipt['receiptNo']),
          _ReceiptRow(label: 'Student Name', value: receipt['studentName']),
          _ReceiptRow(label: 'Roll Number', value: receipt['rollNumber']),
          _ReceiptRow(label: 'Class', value: receipt['className']),
          _ReceiptRow(label: 'Amount Paid', value: 'Rs. ${receipt['amountPaid'].toStringAsFixed(0)}', isBold: true, color: Colors.green),
          _ReceiptRow(label: 'Payment Method', value: receipt['paymentMethod']),
          _ReceiptRow(label: 'Date', value: receipt['date']),
          if (receipt['referenceNumber'] != null && receipt['referenceNumber'].toString().isNotEmpty)
            _ReceiptRow(label: 'Reference No', value: receipt['referenceNumber']),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(recordPaymentProvider.notifier).reset();
                  },
                  child: const Text('Record Another'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.go('/fee-staff-dashboard');
                  },
                  child: const Text('Back to Dashboard'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}