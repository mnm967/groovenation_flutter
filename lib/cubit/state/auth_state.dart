import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/models/city.dart';

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

  final AuthError error;

  @override
  List<Object> get props => [error];
}

class AuthCreateUsernameLoadingState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthCreateUsernameSuccessState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthCreateUsernameErrorState extends AuthState {
  AuthCreateUsernameErrorState(this.error);

  final AuthError error;

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

  final AuthError error;

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
  List<Object> get props => [usernameInputStatus];
}

class AuthAvailableCitiesLoadingState extends AuthState {
  AuthAvailableCitiesLoadingState();

  @override
  List<Object> get props => [];
}

class AuthAvailableCitiesLoadedState extends AuthState {
  AuthAvailableCitiesLoadedState(this.cities);
  final List<City> cities;

  @override
  List<Object> get props => [cities];
}

class AuthAvailableCitiesErrorState extends AuthState {
  AuthAvailableCitiesErrorState(this.error);

  final AuthError error;

  @override
  List<Object> get props => [error];
}