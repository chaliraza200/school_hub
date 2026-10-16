import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_radius.dart';
import '../../../../../theme/app_spacing.dart';
import '../../../../../theme/app_typography.dart';
import '../../../../reports/services/receipt_print_service.dart';
import '../providers/payment_history_provider.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentHistoryProvider);
    final notifier = ref.read(paymentHistoryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment History & Reports'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: state.filteredRecords.isEmpty
                  ? null
                  : () async {
                final success = await notifier.exportToExcel();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Payment history exported successfully!'
                          : 'Export failed. Please try again.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.file_download_rounded, size: 18),
              label: const Text('Export Excel'),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage!,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: notifier.loadRecords,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search & Filters Row (Fixed with LayoutBuilder to prevent overflow)
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 650) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            onChanged: notifier.setSearchQuery,
                            decoration: const InputDecoration(
                              hintText: 'Search by student, roll no or receipt...',
                              prefixIcon: Icon(Icons.search_rounded),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: state.selectedClass,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Class',
                                    isDense: true,
                                  ),
                                  items: [
                                    'All',
                                    'Class 10-A',
                                    'Class 9-B',
                                    'Class 8-A'
                                  ]
                                      .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: notifier.setSelectedClass,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: state.selectedMethod,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Payment Method',
                                    isDense: true,
                                  ),
                                  items: ['All', 'Cash', 'Bank Transfer', 'Other']
                                      .map((m) => DropdownMenuItem(
                                      value: m, child: Text(m, overflow: TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: notifier.setSelectedMethod,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            onChanged: notifier.setSearchQuery,
                            decoration: const InputDecoration(
                              hintText:
                              'Search by student, roll no or receipt no...',
                              prefixIcon: Icon(Icons.search_rounded),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: state.selectedClass,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                              isDense: true,
                            ),
                            items: [
                              'All',
                              'Class 10-A',
                              'Class 9-B',
                              'Class 8-A'
                            ]
                                .map((c) => DropdownMenuItem(
                                value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: notifier.setSelectedClass,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: state.selectedMethod,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Payment Method',
                              isDense: true,
                            ),
                            items: ['All', 'Cash', 'Bank Transfer', 'Other']
                                .map((m) => DropdownMenuItem(
                                value: m, child: Text(m, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: notifier.setSelectedMethod,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Records List
                Expanded(
                  child: state.filteredRecords.isEmpty
                      ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No payment records found.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      itemCount: state.filteredRecords.length,
                      separatorBuilder: (context, index) =>
                      const Divider(
                          height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final record =
                        state.filteredRecords[index];
                        return Padding(
                          padding:
                          const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                Colors.green.withOpacity(0.1),
                                child: const Icon(
                                  Icons.receipt_rounded,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.studentName,
                                      style: AppTypography
                                          .bodyMedium
                                          .copyWith(
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Receipt: ${record.receiptNo} • Roll: ${record.rollNumber} • ${record.className}',
                                      style: AppTypography
                                          .bodySmall
                                          .copyWith(
                                        color: AppColors
                                            .secondaryText,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.paymentMethod,
                                      style: AppTypography
                                          .bodySmall
                                          .copyWith(
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      record.date,
                                      style: AppTypography
                                          .bodySmall
                                          .copyWith(
                                        color: AppColors
                                            .secondaryText,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Rs. ${record.amount.toStringAsFixed(0)}',
                                style: AppTypography.bodyMedium
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onPressed: () {
                                  // Show Receipt Modal Dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AlertDialog(
                                          title: Row(
                                            children: [
                                              const Icon(
                                                  Icons
                                                      .receipt_long_rounded,
                                                  color: AppColors
                                                      .primary),
                                              const SizedBox(
                                                  width: AppSpacing
                                                      .sm),
                                              const Text(
                                                  'Payment Receipt'),
                                            ],
                                          ),
                                          content: ConstrainedBox(
                                            constraints:
                                            const BoxConstraints(
                                                maxWidth: 400),
                                            child: Column(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .stretch,
                                              children: [
                                                Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(
                                                      AppSpacing
                                                          .md),
                                                  decoration:
                                                  BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(
                                                        0.1),
                                                    borderRadius:
                                                    AppRadius
                                                        .borderRadiusMd,
                                                    border: Border.all(
                                                        color: Colors
                                                            .green
                                                            .withOpacity(
                                                            0.3)),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                        'Paid Amount',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .green,
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      const SizedBox(
                                                          height: 4),
                                                      Text(
                                                        'Rs. ${record.amount.toStringAsFixed(0)}',
                                                        style: AppTypography
                                                            .heading1
                                                            .copyWith(
                                                            color:
                                                            Colors.green.shade700),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height:
                                                    AppSpacing
                                                        .md),
                                                _DialogRow(
                                                    label:
                                                    'Receipt No',
                                                    value: record
                                                        .receiptNo),
                                                _DialogRow(
                                                    label:
                                                    'Student Name',
                                                    value: record
                                                        .studentName),
                                                _DialogRow(
                                                    label:
                                                    'Roll Number',
                                                    value: record
                                                        .rollNumber),
                                                _DialogRow(
                                                    label: 'Class',
                                                    value: record
                                                        .className),
                                                _DialogRow(
                                                    label:
                                                    'Payment Method',
                                                    value: record
                                                        .paymentMethod),
                                                _DialogRow(
                                                    label: 'Date',
                                                    value:
                                                    record.date),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context),
                                              child: const Text(
                                                  'Close'),
                                            ),
                                            FilledButton(
                                              onPressed: () async {
                                                Navigator.pop(context);

                                                final success = await ReceiptPrintService.generateAndSaveReceiptPdf(
                                                  receiptNo: record.receiptNo,
                                                  studentName: record.studentName,
                                                  rollNumber: record.rollNumber,
                                                  className: record.className,
                                                  amount: record.amount,
                                                  paymentMethod: record.paymentMethod,
                                                  date: record.date,
                                                );

                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(success
                                                          ? 'Receipt PDF downloaded successfully!'
                                                          : 'Failed to download receipt PDF.'),
                                                      backgroundColor: success ? Colors.green : Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Print / Share'),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                child:
                                const Text('Receipt'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;

  const _DialogRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.secondaryText)),
          Text(value,
              style: AppTypography.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}