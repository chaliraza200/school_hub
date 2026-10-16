import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_radius.dart';
import '../../../../../theme/app_spacing.dart';
import '../../../../../theme/app_typography.dart';
import '../../fee_model.dart';
import '../providers/fee_providers.dart';

class FeesScreen extends ConsumerWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeState = ref.watch(feesScreenProvider);
    final notifier = ref.read(feesScreenProvider.notifier);
    final currencyFormatter = NumberFormat.currency(locale: 'en_PK', symbol: 'PKR ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Fees', style: AppTypography.heading2.copyWith(color: AppColors.mainText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- SUMMARY CARDS ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryMetric('Expected', currencyFormatter.format(feeState.totalExpected), AppColors.primary),
                  _buildSummaryMetric('Collected', currencyFormatter.format(feeState.totalCollected), AppColors.success),
                  _buildSummaryMetric('Pending', currencyFormatter.format(feeState.totalPending), AppColors.error),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // --- SEARCH & FILTERS ---
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => notifier.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search student...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusMd, borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.borderRadiusMd, borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: feeState.selectedClass,
                          isExpanded: true,
                          decoration: _dropdownDecoration('Class'),
                          items: ['Grade 8', 'Grade 9', 'Grade 10']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) => notifier.setClassFilter(val),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: feeState.selectedSection,
                          isExpanded: true,
                          decoration: _dropdownDecoration('Section'),
                          items: ['A', 'B']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) => notifier.setSectionFilter(val),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: DropdownButtonFormField<FeeStatus>(
                          value: feeState.selectedStatus,
                          isExpanded: true,
                          decoration: _dropdownDecoration('Status'),
                          items: FeeStatus.values
                              .map((st) => DropdownMenuItem(value: st, child: Text(st.name.toUpperCase(), style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) => notifier.setStatusFilter(val),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- STUDENT FEE LIST ---
            Expanded(
              child: feeState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : feeState.filteredFees.isEmpty
                  ? Center(child: Text('No student fee records found.', style: AppTypography.bodyMedium))
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: feeState.filteredFees.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final fee = feeState.filteredFees[index];
                  final statusColor = fee.status == FeeStatus.paid
                      ? AppColors.success
                      : fee.status == FeeStatus.overdue
                      ? AppColors.error
                      : fee.status == FeeStatus.partial
                      ? AppColors.warning
                      : AppColors.secondaryText;

                  return InkWell(
                    onTap: () {
                      // Navigate to Student Fee Detail
                    },
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  fee.studentName,
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: AppRadius.borderRadiusFull,
                                ),
                                child: Text(
                                  fee.status.name.toUpperCase(),
                                  style: AppTypography.bodySmall.copyWith(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${fee.studentId} • ${fee.className} • Section ${fee.section}', style: AppTypography.bodySmall),
                          const Divider(height: 16, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFeeDetailColumn('Monthly Fee', currencyFormatter.format(fee.monthlyFee)),
                              _buildFeeDetailColumn('Paid', currencyFormatter.format(fee.paidAmount), color: AppColors.success),
                              _buildFeeDetailColumn('Pending', currencyFormatter.format(fee.pendingAmount), color: AppColors.error),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _showRecordPaymentDialog(context, notifier, fee);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
                              ),
                              child: Text('Record Payment', style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.heading2.copyWith(color: color, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildFeeDetailColumn(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: color ?? AppColors.mainText, fontSize: 13)),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSm, borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSm, borderSide: const BorderSide(color: AppColors.border)),
    );
  }

  void _showRecordPaymentDialog(BuildContext context, FeesScreenNotifier notifier, FeeModel fee) {
    final controller = TextEditingController(text: fee.pendingAmount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Record Payment', style: AppTypography.heading2.copyWith(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student: ${fee.studentName}', style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount (PKR)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0.0;
                if (amount > 0) {
                  notifier.recordPayment(feeId: fee.id, paymentAmount: amount);
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}