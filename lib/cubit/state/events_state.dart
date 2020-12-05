import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';

abstract class EventsState extends Equatable {}

class EventsInitialState extends EventsState {
  @override
  List<Object> get props => [];
}

class EventsLoadingState extends EventsState {
  @override
  List<Object> get props => [];
}

class EventsFavouriteUpdatingState extends EventsState {
  @override
  List<Object> get props => [];
}

class EventsLoadedState extends EventsState {
  final List<Event> events;
  final bool hasReachedMax;

  EventsLoadedState({
    this.events,
    this.hasReachedMax,
  });

  @override
  List<Object> get props => [events, hasReachedMax];
}

class EventsErrorState extends EventsState {
  EventsErrorState(this.error);

  final Error error;

  @override
  List<Object> get props => [error];
}