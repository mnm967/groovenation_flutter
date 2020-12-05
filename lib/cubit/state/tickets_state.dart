import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/models/ticket.dart';

abstract class TicketsState extends Equatable {}

class TicketsInitialState extends TicketsState {
  @override
  List<Object> get props => [];
}

class TicketsLoadingState extends TicketsState {
  @override
  List<Object> get props => [];
}

class TicketsLoadedState extends TicketsState {
  final List<Ticket> tickets;

  TicketsLoadedState({
    this.tickets,
  });

  @override
  List<Object> get props => [tickets];
}

class TicketsErrorState extends TicketsState {
  TicketsErrorState(this.error);

  final Error error;

  @override
  List<Object> get props => [error];
}