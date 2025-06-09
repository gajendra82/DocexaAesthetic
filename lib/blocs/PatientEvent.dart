import 'package:docexaaesthetic/models/patientget.dart';
import 'package:equatable/equatable.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class FetchPatientsEvent extends PatientEvent {
  final bool isRefresh;

  const FetchPatientsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FetchMorePatientsEvent extends PatientEvent {
  const FetchMorePatientsEvent();
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
