import 'package:docexaaesthetic/Repository/PatientRepository';
import 'package:docexaaesthetic/blocs/AuthEvent.dart';
import 'package:docexaaesthetic/blocs/AuthState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PatientRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<CreateAccountRequested>(_onCreateAccountRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(
          event.email, event.password); // user is Loginresponse
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onCreateAccountRequested(
      CreateAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user =
          await repository.createAccount(event.data); // user is Loginresponse
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
