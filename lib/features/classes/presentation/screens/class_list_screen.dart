import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/class_model_dart.dart';
import '../providers/class_list_provider.dart';

class ClassListScreen extends ConsumerWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(classListProvider);
    final notifier = ref.read(classListProvider.notifier);
    final filteredClasses = listState.filteredClasses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Classes',
          style: AppTypography.heading2.copyWith(color: AppColors.mainText),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Total: ${listState.classes.length}',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondaryText),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- SEARCH BAR ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: TextField(
                onChanged: (val) => notifier.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search classes...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // --- CONTENT LIST / STATES ---
            Expanded(
              child: listState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : listState.errorMessage != null
                  ? Center(
                child: Text(
                  'Error loading classes: ${listState.errorMessage}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                ),
              )
                  : filteredClasses.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.class_outlined, size: 48, color: AppColors.secondaryText),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No classes found',
                      style: AppTypography.heading2.copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: filteredClasses.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final schoolClass = filteredClasses[index];
                  final isActive = schoolClass.status == ClassStatus.active;
                  final statusColor = isActive ? AppColors.success : AppColors.secondaryText;

                  return InkWell(
                    onTap: () {
                      context.pushNamed('classDetail', pathParameters: {'id': schoolClass.id});
                    },
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: AppRadius.borderRadiusMd,
                            ),
                            child: Center(
                              child: Text(
                                schoolClass.section,
                                style: AppTypography.heading2.copyWith(color: AppColors.primary, fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        schoolClass.className,
                                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: AppRadius.borderRadiusFull,
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('Teacher: ${schoolClass.classTeacherName}', style: AppTypography.bodySmall),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    const Icon(Icons.people_alt_outlined, size: 14, color: AppColors.secondaryText),
                                    const SizedBox(width: 4),
                                    Text('${schoolClass.studentCount} Students', style: AppTypography.bodySmall),
                                  ],
                                ),
                              ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed('addClass');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Class', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}