import 'package:docexaaesthetic/models/Loginresponse.dart';
import 'package:docexaaesthetic/models/createaccountresponse.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// class AuthSuccess extends AuthState {
//   final Loginresponse user;

//   AuthSuccess(this.user);

//   @override
//   List<Object?> get props => [user];
// }

class LoginSuccess extends AuthState {
  final Loginresponse user;

  LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class CreateAccountSuccess extends AuthState {
  final Createaccountresponse response;

  CreateAccountSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}
