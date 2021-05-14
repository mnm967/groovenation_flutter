import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/error.dart';

abstract class ChangePasswordState extends Equatable {}

class ChangePasswordInitialState extends ChangePasswordState {
  @override
  List<Object> get props => [];
}

class ChangePasswordLoadingState extends ChangePasswordState {
  @override
  List<Object> get props => [];
}

class ChangePasswordSuccessState extends ChangePasswordState {
  @override
  List<Object> get props => [];
}

class ChangePasswordErrorState extends ChangePasswordState {
  ChangePasswordErrorState(this.error);

  final Error error;

  @override
  List<Object> get props => [error];
}
