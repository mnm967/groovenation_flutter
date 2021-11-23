import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:groovenation_flutter/models/ticket_price.dart';

abstract class TicketPurchaseState extends Equatable {}

class TicketPurchaseInitialState extends TicketPurchaseState {
  @override
  List<Object> get props => [];
}

class TicketPurchasePricesLoadingState extends TicketPurchaseState {
  @override
  List<Object> get props => [];
}

class TicketPurchasePricesLoadedState extends TicketPurchaseState {
  final List<TicketPrice>? ticketPrices;
  TicketPurchasePricesLoadedState({
    this.ticketPrices
  });

  @override
  List<Object?> get props => [ticketPrices];
}

class TicketPurchasePricesErrorState extends TicketPurchaseState {
  TicketPurchasePricesErrorState(this.error);

  final AppError error;

  @override
  List<Object> get props => [error];
}

class TicketPurchaseLoadingState extends TicketPurchaseState {
  @override
  List<Object> get props => [];
}

class TicketPurchaseSuccessState extends TicketPurchaseState {
  final Ticket? ticket;
  TicketPurchaseSuccessState({
    this.ticket
  });

  @override
  List<Object?> get props => [ticket];
}

class TicketPurchaseErrorState extends TicketPurchaseState {
  TicketPurchaseErrorState(this.error);

  final AppError error;

  @override
  List<Object> get props => [error];
}