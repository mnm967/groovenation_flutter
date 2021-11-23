import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/models/social_person.dart';

abstract class UserState extends Equatable {}

class UserInitialState extends UserState {
  @override
  List<Object> get props => [];
}

class UserFollowingLoadingState extends UserState {
  @override
  List<Object> get props => [];
}

class UserFollowingLoadedState extends UserState {
  final List<SocialPerson>? socialPeople;
  final bool? hasReachedMax;

  UserFollowingLoadedState({
    this.socialPeople,
    this.hasReachedMax,
  });

  @override
  List<Object?> get props => [socialPeople, hasReachedMax];
}

class UserFollowingErrorState extends UserState {
  UserFollowingErrorState(this.error);

  final AppError error;

  @override
  List<Object> get props => [error];
}

class SocialUsersSearchLoadingState extends UserState {
  @override
  List<Object> get props => [];
}

class SocialUsersSearchLoadedState extends UserState {
  final List<SocialPerson>? socialPeople;
  final bool? hasReachedMax;

  SocialUsersSearchLoadedState({
    this.socialPeople,
    this.hasReachedMax,
  });

  @override
  List<Object?> get props => [socialPeople, hasReachedMax];
}

class SocialUsersSearchErrorState extends UserState {
  SocialUsersSearchErrorState(this.error);

  final AppError error;

  @override
  List<Object> get props => [error];
}