import 'dart:convert';

import 'package:groovenation_flutter/cubit/state/tickets_state.dart';
import 'package:groovenation_flutter/data/repo/ticket_repository.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:groovenation_flutter/constants/error.dart';

class TicketsCubit extends HydratedCubit<TicketsState> {
  TicketsCubit(this.ticketsRepository) : super(TicketsInitialState());

  final TicketsRepository ticketsRepository;

  void getTickets() async {
    emit(TicketsLoadingState());
    try {
      List<Ticket> newTickets = await ticketsRepository.getTestTickets();
      emit(TicketsLoadedState(tickets: newTickets));
    } catch (e) {
      print(e.toString());
      emit(TicketsErrorState(Error.UNKNOWN_ERROR));
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