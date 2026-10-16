import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_radius.dart';
import '../../../../../theme/app_spacing.dart';
import '../../../../../theme/app_typography.dart';
import '../providers/fee_providers.dart';

class FeeOverviewCard extends ConsumerWidget {
  const FeeOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeState = ref.watch(feesScreenProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'en_PK', symbol: 'PKR ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
              Text(
                'Fee Overview',
                style: AppTypography.heading2.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () {
                  context.pushNamed('feesList');
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          feeState.isLoading
              ? const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: LinearProgressIndicator(color: AppColors.primary),
            ),
          )
              : Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Collected',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(feeState.totalCollected),
                        style: AppTypography.heading2.copyWith(fontSize: 15, color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(feeState.totalPending),
                        style: AppTypography.heading2.copyWith(fontSize: 15, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}