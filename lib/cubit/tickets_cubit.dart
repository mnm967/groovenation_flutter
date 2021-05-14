import 'dart:convert';
import 'package:groovenation_flutter/cubit/state/tickets_state.dart';
import 'package:groovenation_flutter/data/repo/ticket_repository.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class TicketsCubit extends HydratedCubit<TicketsState> {
  TicketsCubit(this.ticketsRepository) : super(TicketsInitialState());

  final TicketsRepository ticketsRepository;

  void getTickets() async {
    emit(TicketsLoadingState());
    try {
      List<Ticket> tickets = await ticketsRepository.getUserTickets();
      emit(TicketsLoadedState(tickets: tickets));
    } on TicketException catch (e) {
      emit(TicketsErrorState(e.error));
    }
  }

  void addUserTicket(Ticket ticket) async {
    if (state is TicketsLoadedState) {
      List tickets = (state as TicketsLoadedState).tickets;
      
      emit(TicketsInitialState());
      tickets.add(ticket);
      emit(TicketsLoadedState(tickets: tickets));
    }
  }

  @override
  TicketsState fromJson(Map<String, dynamic> json) {
    return TicketsLoadedState(
        tickets: (jsonDecode(json['tickets']) as List)
            .map((e) => Ticket.fromJson(e))
            .toList());
  }

  @override
  Map<String, dynamic> toJson(TicketsState state) {
    if (state is TicketsLoadedState) {
      return {
        'tickets': jsonEncode(state.tickets),
      };
    }
    return null;
  }
}
