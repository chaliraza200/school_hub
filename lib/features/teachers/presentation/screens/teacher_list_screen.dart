import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/teacher_model.dart';
import '../providers/teacher_list_provider.dart';

class TeacherListScreen extends ConsumerWidget {
  const TeacherListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(teacherListProvider);
    final notifier = ref.read(teacherListProvider.notifier);
    final filteredTeachers = listState.filteredTeachers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Teachers',
          style: AppTypography.heading2.copyWith(color: AppColors.mainText),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Total: ${listState.teachers.length}',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondaryText),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- SEARCH & FILTER BAR ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => notifier.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search teachers...',
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
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All Status'),
                          selected: listState.statusFilter == null,
                          onSelected: (_) => notifier.setStatusFilter(null),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        FilterChip(
                          label: const Text('Active'),
                          selected: listState.statusFilter == TeacherStatus.active,
                          onSelected: (_) => notifier.setStatusFilter(TeacherStatus.active),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        FilterChip(
                          label: const Text('Inactive'),
                          selected: listState.statusFilter == TeacherStatus.inactive,
                          onSelected: (_) => notifier.setStatusFilter(TeacherStatus.inactive),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  'Error loading teachers: ${listState.errorMessage}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                ),
              )
                  : filteredTeachers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off_outlined, size: 48, color: AppColors.secondaryText),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No teachers found',
                      style: AppTypography.heading2.copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: filteredTeachers.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final teacher = filteredTeachers[index];
                  final isActive = teacher.status == TeacherStatus.active;
                  final statusColor = isActive ? AppColors.success : AppColors.secondaryText;

                  return InkWell(
                    onTap: () {
                      context.pushNamed('teacherDetail', pathParameters: {'id': teacher.id});
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
                                teacher.fullName.isNotEmpty ? teacher.fullName.substring(0, 1) : 'T',
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
                                        teacher.fullName,
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
                                Text('ID: ${teacher.teacherId}', style: AppTypography.bodySmall),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    const Icon(Icons.class_outlined, size: 14, color: AppColors.secondaryText),
                                    const SizedBox(width: 4),
                                    Text(teacher.assignedClass, style: AppTypography.bodySmall),
                                    const SizedBox(width: AppSpacing.md),
                                    const Icon(Icons.book_outlined, size: 14, color: AppColors.secondaryText),
                                    const SizedBox(width: 4),
                                    Text(teacher.subject, style: AppTypography.bodySmall),
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
          context.pushNamed('addTeacher');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('Add Teacher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}