import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/student_model.dart';
import '../../widgets/student_card.dart';
import '../providers/students_providers.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);
    final filterState = ref.watch(studentsFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Students', style: AppTypography.heading2.copyWith(color: AppColors.mainText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/dashboard/admin'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed('addStudent');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('Add Student', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search and Filter Header Container
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      // Search Field
                      TextField(
                        onChanged: (value) {
                          ref.read(studentsFilterProvider.notifier).state =
                              filterState.copyWith(searchQuery: value);
                        },
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Search students (Name, ID, Roll)...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Filter Chips Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Class Filter Dropdown or Chip
                            _FilterChip(
                              label: filterState.selectedClass ?? 'All Classes',
                              isSelected: filterState.selectedClass != null,
                              onSelected: () {
                                _showClassFilterModal(context, ref);
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            // Status Filter Chip
                            _FilterChip(
                              label: filterState.selectedStatus == null
                                  ? 'All Status'
                                  : (filterState.selectedStatus == StudentStatus.active ? 'Active' : 'Inactive'),
                              isSelected: filterState.selectedStatus != null,
                              onSelected: () {
                                _showStatusFilterModal(context, ref);
                              },
                            ),
                            if (filterState.selectedClass != null || filterState.selectedStatus != null || filterState.searchQuery.isNotEmpty) ...[
                              const SizedBox(width: AppSpacing.sm),
                              TextButton(
                                onPressed: () {
                                  ref.read(studentsFilterProvider.notifier).state = const StudentsFilterState();
                                },
                                child: const Text('Reset', style: TextStyle(color: AppColors.error, fontSize: 13)),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // Student List / Body Area
                Expanded(
                  child: studentsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (err, _) => Center(
                      child: Text('Error loading students: $err', style: AppTypography.bodyMedium),
                    ),
                    data: (students) {
                      if (students.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.school_outlined, size: 48, color: AppColors.secondaryText),
                              const SizedBox(height: AppSpacing.md),
                              Text('No students found', style: AppTypography.heading2.copyWith(color: AppColors.secondaryText)),
                              const SizedBox(height: AppSpacing.xs),
                              const Text('Try adjusting your search or filter criteria', style: AppTypography.bodySmall),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: students.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Showing ${students.length} students',
                                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                              ),
                            );
                          }
                          final student = students[index - 1];
                          return StudentCard(
                            student: student,
                            onTap: () {
                              // 🚀 Navigates directly to the student detail screen using GoRouter
                              context.pushNamed('studentDetail', pathParameters: {'id': student.id});
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClassFilterModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final classes = ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'];
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Filter by Class', style: AppTypography.heading2),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                title: const Text('All Classes'),
                onTap: () {
                  ref.read(studentsFilterProvider.notifier).state =
                      ref.read(studentsFilterProvider).copyWith(clearClass: true);
                  Navigator.pop(context);
                },
              ),
              ...classes.map((className) => ListTile(
                title: Text(className),
                onTap: () {
                  ref.read(studentsFilterProvider.notifier).state =
                      ref.read(studentsFilterProvider).copyWith(selectedClass: className);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showStatusFilterModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Filter by Status', style: AppTypography.heading2),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                title: const Text('All Status'),
                onTap: () {
                  ref.read(studentsFilterProvider.notifier).state =
                      ref.read(studentsFilterProvider).copyWith(clearStatus: true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Active'),
                onTap: () {
                  ref.read(studentsFilterProvider.notifier).state =
                      ref.read(studentsFilterProvider).copyWith(selectedStatus: StudentStatus.active);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Inactive'),
                onTap: () {
                  ref.read(studentsFilterProvider.notifier).state =
                      ref.read(studentsFilterProvider).copyWith(selectedStatus: StudentStatus.inactive);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.mainText, fontSize: 13)),
      backgroundColor: isSelected ? AppColors.primary : AppColors.background,
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      onPressed: onSelected,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusFull),
      avatar: Icon(Icons.filter_list_rounded, size: 16, color: isSelected ? Colors.white : AppColors.secondaryText),
    );
  }
}