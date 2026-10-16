import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_radius.dart';
import '../../../../../theme/app_spacing.dart';
import '../../../../../theme/app_typography.dart';
import '../providers/manage_fees_provider.dart';

class ManageFeesScreen extends ConsumerWidget {
  const ManageFeesScreen({super.key});

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manageFeesProvider);
    final notifier = ref.read(manageFeesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Student Fees'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: notifier.loadStudents,
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
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search and Filters Bar (Responsive Wrap to prevent overflow)
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 650) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            onChanged: notifier.setSearchQuery,
                            decoration: const InputDecoration(
                              hintText: 'Search by student name or roll...',
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
                                  items: ['All', 'Class 10-A', 'Class 9-B', 'Class 8-A']
                                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                      .toList(),
                                  onChanged: notifier.setSelectedClass,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: state.selectedStatus,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Status',
                                    isDense: true,
                                  ),
                                  items: ['All', 'Paid', 'Partial', 'Unpaid']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: notifier.setSelectedStatus,
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
                              hintText: 'Search by student name or roll number...',
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
                            items: ['All', 'Class 10-A', 'Class 9-B', 'Class 8-A']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: notifier.setSelectedClass,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: state.selectedStatus,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              isDense: true,
                            ),
                            items: ['All', 'Paid', 'Partial', 'Unpaid']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: notifier.setSelectedStatus,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Student Fee List
                Expanded(
                  child: state.filteredStudents.isEmpty
                      ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No students found matching your criteria.',
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
                      itemCount: state.filteredStudents.length,
                      separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final student = state.filteredStudents[index];
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Avatar, Name & Status
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: Text(
                                      student.name.isNotEmpty ? student.name[0] : 'S',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: AppTypography.bodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Roll: ${student.rollNumber} • ${student.className}',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.secondaryText,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(student.status).withOpacity(0.1),
                                      borderRadius: AppRadius.borderRadiusSm,
                                      border: Border.all(
                                        color: _getStatusColor(student.status).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      student.status,
                                      style: TextStyle(
                                        color: _getStatusColor(student.status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const Divider(height: 1, color: AppColors.border),
                              const SizedBox(height: AppSpacing.sm),

                              // Bottom Row: Fee Breakdown & Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _FeeColumn(
                                          label: 'Total',
                                          amount: 'Rs. ${student.totalFee.toStringAsFixed(0)}',
                                        ),
                                        _FeeColumn(
                                          label: 'Paid',
                                          amount: 'Rs. ${student.paidAmount.toStringAsFixed(0)}',
                                          color: Colors.green,
                                        ),
                                        _FeeColumn(
                                          label: 'Balance',
                                          amount: 'Rs. ${student.remainingBalance.toStringAsFixed(0)}',
                                          color: student.remainingBalance > 0
                                              ? Colors.orange
                                              : Colors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          minimumSize: const Size(45, 30),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Row(
                                                children: [
                                                  const Icon(Icons.person_rounded, color: AppColors.primary),
                                                  const SizedBox(width: AppSpacing.sm),
                                                  Expanded(
                                                    child: Text(
                                                      'Student Fee Details',
                                                      style: AppTypography.heading2.copyWith(fontSize: 18),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: ConstrainedBox(
                                                constraints: const BoxConstraints(maxWidth: 400),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      _buildDetailRow('Student Name', student.name),
                                                      _buildDetailRow('Roll Number', student.rollNumber),
                                                      _buildDetailRow('Class', student.className),
                                                      const Divider(height: 24),
                                                      _buildDetailRow('Total Fee', 'Rs. ${student.totalFee.toStringAsFixed(0)}'),
                                                      _buildDetailRow('Paid Amount', 'Rs. ${student.paidAmount.toStringAsFixed(0)}', color: Colors.green),
                                                      _buildDetailRow('Remaining Balance', 'Rs. ${student.remainingBalance.toStringAsFixed(0)}', color: student.remainingBalance > 0 ? Colors.orange : Colors.green),
                                                      _buildDetailRow('Status', student.status),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Close'),
                                                ),
                                                FilledButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    context.push('/record-payment');
                                                  },
                                                  child: const Text('Record Payment'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: const Text('Details', style: TextStyle(fontSize: 11)),
                                      ),
                                      const SizedBox(width: 4),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          minimumSize: const Size(35, 30),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          context.push('/record-payment');
                                        },
                                        child: const Text('Pay', style: TextStyle(fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                ],
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return AppColors.secondaryText;
    }
  }
}

class _FeeColumn extends StatelessWidget {
  final String label;
  final String amount;
  final Color? color;

  const _FeeColumn({
    required this.label,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.secondaryText,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.primary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}