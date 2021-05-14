import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/auth_error_types.dart';
import 'package:groovenation_flutter/ui/sign_up/sign_up.dart';

abstract class AuthState extends Equatable {}

class AuthInitialState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoginLoadingState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoginSuccessState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoginErrorState extends AuthState {
  AuthLoginErrorState(this.error);

  final AuthLoginErrorType error;

  @override
  List<Object> get props => [error];
}

class AuthSignupLoadingState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthSignupSuccessState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthSignupErrorState extends AuthState {
  AuthSignupErrorState(this.error);

  final AuthSignUpErrorType error;

  @override
  List<Object> get props => [error];
}

class AuthUsernameCheckLoadingState extends AuthState {
  AuthUsernameCheckLoadingState();

  @override
  List<Object> get props => [];
}

class AuthUsernameCheckCompleteState extends AuthState {
  AuthUsernameCheckCompleteState(this.usernameInputStatus);
  final UsernameInputStatus usernameInputStatus;

  @override
  List<Object> get props => [];
}