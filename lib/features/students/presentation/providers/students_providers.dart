import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/student_model.dart';

class StudentsFilterState {
  final String searchQuery;
  final String? selectedClass;
  final StudentStatus? selectedStatus;

  const StudentsFilterState({
    this.searchQuery = '',
    this.selectedClass,
    this.selectedStatus,
  });

  StudentsFilterState copyWith({
    String? searchQuery,
    String? selectedClass,
    bool clearClass = false,
    StudentStatus? selectedStatus,
    bool clearStatus = false,
  }) {
    return StudentsFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedClass: clearClass ? null : (selectedClass ?? this.selectedClass),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }
}

class StudentsNotifier extends StateNotifier<AsyncValue<List<Student>>> {
  StudentsNotifier() : super(const AsyncValue.loading()) {
    fetchStudents();
  }

  List<Student> _allStudents = [];

  Future<void> fetchStudents() async {
    state = const AsyncValue.loading();
    try {
      // Simulate backend latency. Ready for Firestore collection stream later.
      await Future.delayed(const Duration(milliseconds: 500));

      _allStudents = [
        const Student(id: '1', studentId: 'STU-2026-001', fullName: 'Alexander Wright', rollNumber: '101', className: 'Grade 10', section: 'A', status: StudentStatus.active),
        const Student(id: '2', studentId: 'STU-2026-002', fullName: 'Sophia Martinez', rollNumber: '102', className: 'Grade 10', section: 'A', status: StudentStatus.active),
        const Student(id: '3', studentId: 'STU-2026-003', fullName: 'Liam Johnson', rollNumber: '105', className: 'Grade 9', section: 'B', status: StudentStatus.active),
        const Student(id: '4', studentId: 'STU-2026-004', fullName: 'Emma Williams', rollNumber: '108', className: 'Grade 8', section: 'C', status: StudentStatus.inactive),
        const Student(id: '5', studentId: 'STU-2026-005', fullName: 'Noah Brown', rollNumber: '110', className: 'Grade 10', section: 'B', status: StudentStatus.active),
        const Student(id: '6', studentId: 'STU-2026-006', fullName: 'Olivia Davis', rollNumber: '112', className: 'Grade 7', section: 'A', status: StudentStatus.active),
      ];

      state = AsyncValue.data(_allStudents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void filterStudents({required StudentsFilterState filter}) {
    final filtered = _allStudents.where((student) {
      final matchesSearch = filter.searchQuery.isEmpty ||
          student.fullName.toLowerCase().contains(filter.searchQuery.toLowerCase()) ||
          student.studentId.toLowerCase().contains(filter.searchQuery.toLowerCase()) ||
          student.rollNumber.toLowerCase().contains(filter.searchQuery.toLowerCase());

      final matchesClass = filter.selectedClass == null || student.className == filter.selectedClass;
      final matchesStatus = filter.selectedStatus == null || student.status == filter.selectedStatus;

      return matchesSearch && matchesClass && matchesStatus;
    }).toList();

    state = AsyncValue.data(filtered);
  }
}

// Filter query provider
final studentsFilterProvider = StateProvider<StudentsFilterState>((ref) => const StudentsFilterState());

// Main student list provider linked with filters
final studentsProvider = StateNotifierProvider.autoDispose<StudentsNotifier, AsyncValue<List<Student>>>(
      (ref) {
    final notifier = StudentsNotifier();
    // Watch filter changes and apply them automatically
    ref.listen<StudentsFilterState>(studentsFilterProvider, (_, nextFilter) {
      notifier.filterStudents(filter: nextFilter);
    });
    return notifier;
  },
);