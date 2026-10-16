import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class StudentFeeRecord {
  final String id;
  final String name;
  final String rollNumber;
  final String className;
  final double totalFee;
  final double paidAmount;
  final String status; // 'Paid', 'Partial', 'Unpaid'

  StudentFeeRecord({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.totalFee,
    required this.paidAmount,
    required this.status,
  });

  double get remainingBalance => totalFee - paidAmount;
}

class ManageFeesState {
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedClass;
  final String? selectedStatus;
  final List<StudentFeeRecord> students;

  ManageFeesState({
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedClass,
    this.selectedStatus,
    this.students = const [],
  });

  ManageFeesState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedClass,
    String? selectedStatus,
    List<StudentFeeRecord>? students,
  }) {
    return ManageFeesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      students: students ?? this.students,
    );
  }

  List<StudentFeeRecord> get filteredStudents {
    return students.where((student) {
      final matchesSearch = student.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          student.rollNumber.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesClass = selectedClass == null || selectedClass == 'All' || student.className == selectedClass;
      final matchesStatus = selectedStatus == null || selectedStatus == 'All' || student.status == selectedStatus;

      return matchesSearch && matchesClass && matchesStatus;
    }).toList();
  }
}

class ManageFeesNotifier extends StateNotifier<ManageFeesState> {
  ManageFeesNotifier() : super(ManageFeesState()) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Simulate network fetch

      final mockData = [
        StudentFeeRecord(
          id: '1',
          name: 'Hamza Ahmed',
          rollNumber: 'R-101',
          className: 'Class 10-A',
          totalFee: 25000.0,
          paidAmount: 25000.0,
          status: 'Paid',
        ),
        StudentFeeRecord(
          id: '2',
          name: 'Ayesha Malik',
          rollNumber: 'R-102',
          className: 'Class 9-B',
          totalFee: 22000.0,
          paidAmount: 11000.0,
          status: 'Partial',
        ),
        StudentFeeRecord(
          id: '3',
          name: 'Bilal Raza',
          rollNumber: 'R-103',
          className: 'Class 8-A',
          totalFee: 20000.0,
          paidAmount: 0.0,
          status: 'Unpaid',
        ),
        StudentFeeRecord(
          id: '4',
          name: 'Zainab Bibi',
          rollNumber: 'R-104',
          className: 'Class 10-A',
          totalFee: 25000.0,
          paidAmount: 20000.0,
          status: 'Partial',
        ),
      ];

      state = state.copyWith(isLoading: false, students: mockData);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load student fees.');
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedClass(String? className) {
    state = state.copyWith(selectedClass: className);
  }

  void setSelectedStatus(String? status) {
    state = state.copyWith(selectedStatus: status);
  }
}

final manageFeesProvider =
StateNotifierProvider.autoDispose<ManageFeesNotifier, ManageFeesState>(
      (ref) => ManageFeesNotifier(),
);