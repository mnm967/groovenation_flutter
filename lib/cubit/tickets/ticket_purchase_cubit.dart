import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/ticket_purchase_state.dart';
import 'package:groovenation_flutter/cubit/tickets/tickets_cubit.dart';
import 'package:groovenation_flutter/data/repo/ticket_repository.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:groovenation_flutter/models/ticket_price.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class TicketPurchaseCubit extends Cubit<TicketPurchaseState> {
  TicketPurchaseCubit(this.ticketRepository)
      : super(TicketPurchaseInitialState());

  final TicketsRepository ticketRepository;

  void getTicketPrices(String? eventId) async {
    try {
      emit(TicketPurchasePricesLoadingState());
      List<TicketPrice>? prices =
          await ticketRepository.getTicketPrices(eventId);
      emit(TicketPurchasePricesLoadedState(ticketPrices: prices));
    } on TicketException catch (e) {
      emit(TicketPurchasePricesErrorState(e.error));
    }
  }

  void verifyPurchase(BuildContext context, String? eventId, String? clubId,
      TicketPrice ticketType, int noOfPeople, String? reference) async {
    emit(TicketPurchaseLoadingState());

    try {
      Ticket? ticket = await ticketRepository.verifyTicketPurchase(
          eventId, clubId, ticketType, noOfPeople, reference);

      final TicketsCubit ticketsCubit = BlocProvider.of<TicketsCubit>(context);
      ticketsCubit.addUserTicket(ticket);

      emit(TicketPurchaseSuccessState(ticket: ticket));
    } on TicketException catch (e) {
      emit(TicketPurchaseErrorState(e.error));
    }
  }
}
