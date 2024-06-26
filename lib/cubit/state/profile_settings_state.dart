import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/enums.dart';

abstract class ProfileSettingsState extends Equatable {}

class ProfileSettingsInitialState extends ProfileSettingsState {
  @override
  List<Object> get props => [];
}

class ProfileSettingsLoadingState extends ProfileSettingsState {
  @override
  List<Object> get props => [];
}

class ProfileSettingsSuccessState extends ProfileSettingsState {
  @override
  List<Object> get props => [];
}

class ProfileSettingsErrorState extends ProfileSettingsState {
  ProfileSettingsErrorState(this.error);

  final AppError error;

  @override
  List<Object> get props => [error];
}