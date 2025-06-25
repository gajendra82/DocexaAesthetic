import 'package:docexaaesthetic/models/patientget.dart';
import 'package:equatable/equatable.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class FetchPatientsEvent extends PatientEvent {
  final int userId;

  final bool isRefresh;

  const FetchPatientsEvent({required this.userId, this.isRefresh = false});

  @override
  List<Object?> get props => [userId, isRefresh];
}

class FetchMorePatientsEvent extends PatientEvent {
  final int userId;

  const FetchMorePatientsEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class FilterPatientsEvent extends PatientEvent {
  final String query;

  const FilterPatientsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

// Add this new event
class SelectPatientEvent extends PatientEvent {
  final Patient patient;

  const SelectPatientEvent(this.patient);

  @override
  List<Object?> get props => [patient];
}
