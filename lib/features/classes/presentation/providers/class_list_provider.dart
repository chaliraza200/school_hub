import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/class_model_dart.dart';

class ClassListState {
  final List<SchoolClass> classes;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  const ClassListState({
    this.classes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  ClassListState copyWith({
    List<SchoolClass>? classes,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ClassListState(
      classes: classes ?? this.classes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<SchoolClass> get filteredClasses {
    return classes.where((cls) {
      final matchesSearch = cls.className.toLowerCase().contains(searchQuery.toLowerCase()) ||
          cls.section.toLowerCase().contains(searchQuery.toLowerCase()) ||
          cls.classTeacherName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }
}

class ClassListNotifier extends StateNotifier<ClassListState> {
  ClassListNotifier() : super(const ClassListState(isLoading: true)) {
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate network / Firestore delay
      await Future.delayed(const Duration(milliseconds: 400));

      // Mock class data
      final mockClasses = [
        const SchoolClass(
          id: '1',
          className: 'Grade 10',
          section: 'A',
          classTeacherName: 'Dr. Eleanor Vance',
          studentCount: 32,
          status: ClassStatus.active,
        ),
        const SchoolClass(
          id: '2',
          className: 'Grade 9',
          section: 'B',
          classTeacherName: 'Prof. Marcus Brody',
          studentCount: 28,
          status: ClassStatus.active,
        ),
        const SchoolClass(
          id: '3',
          className: 'Grade 8',
          section: 'A',
          classTeacherName: 'Sarah Jenkins',
          studentCount: 30,
          status: ClassStatus.active,
        ),
        const SchoolClass(
          id: '4',
          className: 'Grade 10',
          section: 'B',
          classTeacherName: 'David Sterling',
          studentCount: 25,
          status: ClassStatus.inactive,
        ),
      ];

      state = state.copyWith(classes: mockClasses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final classListProvider = StateNotifierProvider.autoDispose<ClassListNotifier, ClassListState>(
      (ref) => ClassListNotifier(),
);