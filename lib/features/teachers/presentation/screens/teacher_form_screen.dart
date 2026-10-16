import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/teacher_model.dart';
import '../providers/teacher_form_provider.dart';

class TeacherFormScreen extends ConsumerStatefulWidget {
  final String? teacherId; // Null if adding, populated if editing

  const TeacherFormScreen({
    super.key,
    this.teacherId,
  });

  @override
  ConsumerState<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends ConsumerState<TeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _teacherIdController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _dobController;
  late final TextEditingController _joiningDateController;
  late final TextEditingController _subjectController;

  String _selectedClass = 'Grade 10';
  String _selectedSection = 'A';
  TeacherStatus _selectedStatus = TeacherStatus.active;

  bool get isEditMode => widget.teacherId != null;

  @override
  void initState() {
    super.initState();
    // Initialize with mock pre-filled data if in edit mode, else empty
    _fullNameController = TextEditingController(text: isEditMode ? 'Dr. Eleanor Vance' : '');
    _teacherIdController = TextEditingController(text: isEditMode ? 'TCH-2026-001' : 'TCH-2026-105');
    _phoneController = TextEditingController(text: isEditMode ? '+1 (555) 111-2233' : '');
    _emailController = TextEditingController(text: isEditMode ? 'e.vance@schoolhub.edu' : '');
    _dobController = TextEditingController(text: isEditMode ? '22 Aug 1985' : '');
    _joiningDateController = TextEditingController(text: isEditMode ? '15 Aug 2022' : '');
    _subjectController = TextEditingController(text: isEditMode ? 'Mathematics' : '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _teacherIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _joiningDateController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1985, 8, 22),
      firstDate: DateTime(1950),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
      });
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(teacherFormProvider(widget.teacherId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          isEditMode ? 'Edit Teacher' : 'Add Teacher',
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
                  Text('Teacher Information', style: AppTypography.heading2.copyWith(fontSize: 16)),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name *', hintText: 'Enter teacher full name'),
                    validator: (value) => value == null || value.isEmpty ? 'Full name is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _teacherIdController,
                          decoration: const InputDecoration(labelText: 'Teacher ID *', hintText: 'TCH-2026-XXX'),
                          validator: (value) => value == null || value.isEmpty ? 'Teacher ID required' : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(labelText: 'Subject *', hintText: 'e.g. Mathematics'),
                          validator: (value) => value == null || value.isEmpty ? 'Subject required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Phone Number *', hintText: '+1 (555) 000-0000'),
                          validator: (value) => value == null || value.isEmpty ? 'Phone number required' : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email Address *', hintText: 'name@schoolhub.edu'),
                          validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedClass,
                          decoration: const InputDecoration(labelText: 'Assigned Class'),
                          items: ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'].map((cls) {
                            return DropdownMenuItem(value: cls, child: Text(cls));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedClass = val!),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSection,
                          decoration: const InputDecoration(labelText: 'Assigned Section'),
                          items: ['A', 'B', 'C', 'D'].map((sec) {
                            return DropdownMenuItem(value: sec, child: Text('Section $sec'));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedSection = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: () => _selectDate(context, _dobController),
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _joiningDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, _joiningDateController),
                          decoration: const InputDecoration(
                            labelText: 'Joining Date',
                            suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<TeacherStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Teacher Status'),
                    items: const [
                      DropdownMenuItem(value: TeacherStatus.active, child: Text('Active')),
                      DropdownMenuItem(value: TeacherStatus.inactive, child: Text('Inactive')),
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
                        ref.read(teacherFormProvider(widget.teacherId).notifier).saveTeacher(
                          formData: {
                            'fullName': _fullNameController.text,
                            'teacherId': _teacherIdController.text,
                            'subject': _subjectController.text,
                            'assignedClass': _selectedClass,
                            'section': _selectedSection,
                            'status': _selectedStatus,
                          },
                          onSuccess: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEditMode ? 'Teacher updated successfully!' : 'Teacher created successfully!'),
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
                      isEditMode ? 'Save Changes' : 'Save Teacher',
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