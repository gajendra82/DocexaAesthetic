import 'package:equatable/equatable.dart';
import '../models/patientget.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoadInProgress extends PatientState {}

class PatientLoadSuccess extends PatientState {
  final List<Patient> patients;
  final int totalPatients;
  final bool hasMoreData;
  final int currentPage;
  final String searchQuery;
  final Patient? selectedPatient; // Add this

  const PatientLoadSuccess({
    required this.patients,
    required this.totalPatients,
    required this.hasMoreData,
    required this.currentPage,
    this.searchQuery = '',
    this.selectedPatient, // Add this
  });

  PatientLoadSuccess copyWith({
    List<Patient>? patients,
    int? totalPatients,
    bool? hasMoreData,
    int? currentPage,
    String? searchQuery,
    Patient? selectedPatient, // Add this
  }) {
    return PatientLoadSuccess(
      patients: patients ?? this.patients,
      totalPatients: totalPatients ?? this.totalPatients,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPatient: selectedPatient ?? this.selectedPatient, // Add this
    );
  }

  @override
  List<Object?> get props => [
        patients,
        totalPatients,
        hasMoreData,
        currentPage,
        searchQuery,
        selectedPatient,
      ];
}

class PatientLoadFailure extends PatientState {
  final String error;

  const PatientLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
