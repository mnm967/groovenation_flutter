import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/models/club.dart';

abstract class ClubsState extends Equatable {}

class ClubsInitialState extends ClubsState {
  @override
  List<Object> get props => [];
}

class ClubsLoadingState extends ClubsState {
  @override
  List<Object> get props => [];
}

class ClubFavouriteUpdatingState extends ClubsState {
  @override
  List<Object> get props => [];
}

class ClubsLoadedState extends ClubsState {
  final List<Club> clubs;
  final bool hasReachedMax;

  ClubsLoadedState({
    this.clubs,
    this.hasReachedMax,
  });

  @override
  List<Object> get props => [clubs, hasReachedMax];
}

class ClubsErrorState extends ClubsState {
  ClubsErrorState(this.error);

  final Error error;

  @override
  List<Object> get props => [error];
}

class ClubLoadedState extends ClubsState {
  final Club club;

  ClubLoadedState({
    this.club,
  });

  @override
  List<Object> get props => [club];
}