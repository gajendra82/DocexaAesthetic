import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class CreateAccountRequested extends AuthEvent {
  final Map<String, dynamic> data;

  CreateAccountRequested(this.data);

  @override
  List<Object?> get props => [data];
}
