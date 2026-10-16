import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/student_model.dart';
import '../providers/student_form_provider.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final String? studentId; // Null if adding, populated if editing

  const StudentFormScreen({
    super.key,
    this.studentId,
  });

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _rollNumberController;
  late final TextEditingController _dobController;
  late final TextEditingController _joiningDateController;
  late final TextEditingController _guardianNameController;
  late final TextEditingController _parentPhoneController;
  late final TextEditingController _alternatePhoneController;
  late final TextEditingController _monthlyFeeController;
  late final TextEditingController _feeNoteController;

  String _selectedClass = 'Grade 10';
  String _selectedSection = 'A';
  StudentStatus _selectedStatus = StudentStatus.active;

  bool get isEditMode => widget.studentId != null;

  @override
  void initState() {
    super.initState();
    // Initialize with mock pre-filled data if in edit mode, else empty
    _fullNameController = TextEditingController(text: isEditMode ? 'Alexander Wright' : '');
    _studentIdController = TextEditingController(text: isEditMode ? 'STU-2026-001' : 'STU-2026-125');
    _rollNumberController = TextEditingController(text: isEditMode ? '101' : '');
    _dobController = TextEditingController(text: isEditMode ? '14 May 2010' : '');
    _joiningDateController = TextEditingController(text: isEditMode ? '01 Sep 2024' : '');
    _guardianNameController = TextEditingController(text: isEditMode ? 'Robert Wright' : '');
    _parentPhoneController = TextEditingController(text: isEditMode ? '+1 (555) 234-5678' : '');
    _alternatePhoneController = TextEditingController(text: isEditMode ? '+1 (555) 876-5432' : '');
    _monthlyFeeController = TextEditingController(text: isEditMode ? '350.00' : '');
    _feeNoteController = TextEditingController(text: isEditMode ? 'Sibling discount applied (10%)' : '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _rollNumberController.dispose();
    _dobController.dispose();
    _joiningDateController.dispose();
    _guardianNameController.dispose();
    _parentPhoneController.dispose();
    _alternatePhoneController.dispose();
    _monthlyFeeController.dispose();
    _feeNoteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010, 5, 14),
      firstDate: DateTime(2000),
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
    final formState = ref.watch(studentFormProvider(widget.studentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          isEditMode ? 'Edit Student' : 'Add Student',
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
                  // --- SECTION 1: STUDENT INFORMATION ---
                  Text('Student Information', style: AppTypography.heading2.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name *', hintText: 'Enter student full name'),
                validator: (value) => value == null || value.isEmpty ? 'Full name is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(labelText: 'Student ID *', hintText: 'STU-2026-XXX'),
                      validator: (value) => value == null || value.isEmpty ? 'Student ID required' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _rollNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Roll Number *', hintText: 'e.g. 101'),
                      validator: (value) => value == null || value.isEmpty ? 'Roll number required' : null,
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
                      decoration: const InputDecoration(labelText: 'Class'),
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
                      decoration: const InputDecoration(labelText: 'Section'),
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

              DropdownButtonFormField<StudentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Student Status'),
                items: const [
                  DropdownMenuItem(value: StudentStatus.active, child: Text('Active')),
                  DropdownMenuItem(value: StudentStatus.inactive, child: Text('Inactive')),
                ],
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- SECTION 2: PARENT / GUARDIAN ---
              Text('Parent / Guardian', style: AppTypography.heading2.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _guardianNameController,
                decoration: const InputDecoration(labelText: 'Guardian Name *', hintText: 'Parent or guardian full name'),
                validator: (value) => value == null || value.isEmpty ? 'Guardian name is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _parentPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Primary Phone *', hintText: '+1 (555) 000-0000'),
                validator: (value) => value == null || value.isEmpty ? 'Primary phone number required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _alternatePhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Alternate Phone (Optional)', hintText: '+1 (555) 000-0000'),
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- SECTION 3: FEE INFORMATION ---
              Text('Fee Information', style: AppTypography.heading2.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _monthlyFeeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monthly Fee (\$) *', hintText: '350.00'),
                validator: (value) => value == null || value.isEmpty ? 'Monthly fee is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _feeNoteController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Exceptional Fee Note', hintText: 'e.g., Scholarship or sibling discount'),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // --- SAVE BUTTON ---
              ElevatedButton(
                  onPressed: formState.isLoading
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(studentFormProvider(widget.studentId).notifier).saveStudent(
                        formData: {
                          'fullName': _fullNameController.text,
                          'studentId': _studentIdController.text,
                          'rollNumber': _rollNumberController.text,
                          'className': _selectedClass,
                          'section': _selectedSection,
                          'status': _selectedStatus,
                        },
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditMode ? 'Student updated successfully!' : 'Student created successfully!'),
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
              isEditMode ? 'Save Changes' : 'Save Student',
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