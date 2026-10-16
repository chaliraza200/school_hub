import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/class_model_dart.dart';
import '../providers/classes_form_provider.dart';

class ClassFormScreen extends ConsumerStatefulWidget {
  final String? classId; // Null if adding, populated if editing

  const ClassFormScreen({
    super.key,
    this.classId,
  });

  @override
  ConsumerState<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends ConsumerState<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _classNameController;
  late final TextEditingController _academicYearController;

  String _selectedSection = 'A';
  String _selectedTeacher = 'Dr. Eleanor Vance';
  ClassStatus _selectedStatus = ClassStatus.active;

  bool get isEditMode => widget.classId != null;

  // Mock list of available teachers for selection
  final List<String> _availableTeachers = [
    'Dr. Eleanor Vance',
    'Prof. Marcus Brody',
    'Sarah Jenkins',
    'David Sterling',
  ];

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: isEditMode ? 'Grade 10' : '');
    _academicYearController = TextEditingController(text: isEditMode ? '2025 - 2026' : '2026 - 2027');
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(classFormProvider(widget.classId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          isEditMode ? 'Edit Class' : 'Add Class',
          style: AppTypography.heading2.copyWith(color: AppColors.mainText),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('Class Information', style: AppTypography.heading2.copyWith(fontSize: 16)),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _classNameController,
                    decoration: const InputDecoration(labelText: 'Class Name *', hintText: 'e.g. Grade 10'),
                    validator: (value) => value == null || value.isEmpty ? 'Class name is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    value: _selectedSection,
                    decoration: const InputDecoration(labelText: 'Section *'),
                    items: ['A', 'B', 'C', 'D'].map((sec) {
                      return DropdownMenuItem(value: sec, child: Text('Section $sec'));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSection = val!),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    value: _selectedTeacher,
                    decoration: const InputDecoration(labelText: 'Class Teacher *'),
                    items: _availableTeachers.map((teacher) {
                      return DropdownMenuItem(value: teacher, child: Text(teacher));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTeacher = val!),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _academicYearController,
                    decoration: const InputDecoration(labelText: 'Academic Year *', hintText: 'e.g. 2026 - 2027'),
                    validator: (value) => value == null || value.isEmpty ? 'Academic year is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<ClassStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Class Status'),
                    items: const [
                      DropdownMenuItem(value: ClassStatus.active, child: Text('Active')),
                      DropdownMenuItem(value: ClassStatus.inactive, child: Text('Inactive')),
                    ],
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // --- SAVE BUTTON ---
                  ElevatedButton(
                    onPressed: formState.isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(classFormProvider(widget.classId).notifier).saveClass(
                          formData: {
                            'className': _classNameController.text,
                            'section': _selectedSection,
                            'classTeacherName': _selectedTeacher,
                            'academicYear': _academicYearController.text,
                            'status': _selectedStatus,
                          },
                          onSuccess: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEditMode ? 'Class updated successfully!' : 'Class created successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            context.pop();
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
                    ),
                    child: formState.isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      isEditMode ? 'Save Changes' : 'Save Class',
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}