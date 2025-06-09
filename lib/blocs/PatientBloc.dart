import 'package:docexaaesthetic/Repository/PatientRepository';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docexaaesthetic/models/patientget.dart';
import 'PatientEvent.dart';
import 'PatientState.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository _patientRepository;
  final int _perPage = 10;

  PatientBloc({
    required PatientRepository patientRepository,
  })  : _patientRepository = patientRepository,
        super(PatientInitial()) {
    on<FetchPatientsEvent>(_onFetchPatients);
    on<FetchMorePatientsEvent>(_onFetchMorePatients);
    on<FilterPatientsEvent>(_onFilterPatients);
    on<SelectPatientEvent>(_onSelectPatient); // Add this line
  }

  Future<void> _onFetchPatients(
    FetchPatientsEvent event,
    Emitter<PatientState> emit,
  ) async {
    try {
      emit(PatientLoadInProgress());

      print('Fetching patients...'); // Debug log

      final patientget response = await _patientRepository.getPatients(
        userId: 70688, // You might want to make this configurable
        page: 1,
        perPage: _perPage,
      );

      print('Response received: ${response.status}'); // Debug log

      // Check response status and data
      if (response.status?.toLowerCase() == 'success' &&
          response.data != null &&
          response.data!.patient != null) {
        final patients = response.data!.patient!;
        print('Patients loaded: ${patients.length}'); // Debug log

        emit(PatientLoadSuccess(
          patients: patients,
          totalPatients: response.data!.totalPatient ?? patients.length,
          hasMoreData: patients.length >= _perPage,
          currentPage: 1,
          searchQuery: '',
        ));
      } else {
        print('Failed to load patients: Invalid response format'); // Debug log
        emit(const PatientLoadFailure(
            'Failed to load patients: Invalid response format'));
      }
    } catch (error) {
      print('Error loading patients: $error'); // Debug log
      emit(PatientLoadFailure('Failed to load patients: ${error.toString()}'));
    }
  }

  // Add this method
  void _onSelectPatient(
    SelectPatientEvent event,
    Emitter<PatientState> emit,
  ) {
    // Handle patient selection
    if (state is PatientLoadSuccess) {
      final currentState = state as PatientLoadSuccess;
      emit(PatientLoadSuccess(
        patients: currentState.patients,
        totalPatients: currentState.totalPatients,
        hasMoreData: currentState.hasMoreData,
        currentPage: currentState.currentPage,
        searchQuery: currentState.searchQuery,
        selectedPatient: event.patient, // Add selectedPatient to your state
      ));
    }
  }

  Future<void> _onFetchMorePatients(
    FetchMorePatientsEvent event,
    Emitter<PatientState> emit,
  ) async {
    if (state is PatientLoadSuccess) {
      final currentState = state as PatientLoadSuccess;
      if (!currentState.hasMoreData) {
        print('No more patients to load'); // Debug log
        return;
      }

      try {
        print('Fetching more patients...'); // Debug log

        final patientget response = await _patientRepository.getPatients(
          userId: 70688, // You might want to make this configurable
          page: currentState.currentPage + 1,
          perPage: _perPage,
        );

        if (response.status?.toLowerCase() == 'success' &&
            response.data != null &&
            response.data!.patient != null) {
          final newPatients = response.data!.patient!;
          print(
              'Additional patients loaded: ${newPatients.length}'); // Debug log

          emit(PatientLoadSuccess(
            patients: [...currentState.patients, ...newPatients],
            totalPatients: response.data!.totalPatient ??
                (currentState.totalPatients + newPatients.length),
            hasMoreData: newPatients.length >= _perPage,
            currentPage: currentState.currentPage + 1,
            searchQuery: currentState.searchQuery,
          ));
        } else {
          print(
              'Failed to load more patients: Invalid response format'); // Debug log
          // Don't emit failure state for pagination to maintain current list
        }
      } catch (error) {
        print('Error loading more patients: $error'); // Debug log
        // Don't emit failure state for pagination to maintain current list
      }
    }
  }

  void _onFilterPatients(
    FilterPatientsEvent event,
    Emitter<PatientState> emit,
  ) {
    if (state is PatientLoadSuccess) {
      final currentState = state as PatientLoadSuccess;
      print('Filtering patients with query: ${event.query}'); // Debug log
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  // Helper method to check if response is valid
  bool _isValidResponse(patientget response) {
    return response.status?.toLowerCase() == 'success' &&
        response.data != null &&
        response.data!.patient != null;
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('PatientBloc error: $error');
    print('StackTrace: $stackTrace');
    super.onError(error, stackTrace);
  }

  @override
  void onChange(Change<PatientState> change) {
    print(
        'PatientBloc state change: ${change.currentState} -> ${change.nextState}');
    super.onChange(change);
  }
}
