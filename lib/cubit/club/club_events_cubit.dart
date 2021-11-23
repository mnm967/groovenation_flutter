import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/data/repo/events_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/event.dart';

class ClubEventsCubit extends Cubit<EventsState> {
  ClubEventsCubit(this.eventsRepository) : super(EventsInitialState());

  final EventsRepository eventsRepository;

  void getEvents(int page, String clubId) async {
    List<Event>? events = [];

    if (state is EventsLoadedState) {
      events = (state as EventsLoadedState).events;
    }

    emit(EventsLoadingState());

    try {
      List<Event> newEvents;
      APIResult? result;

      result = await eventsRepository.getClubEvents(page, clubId);

      bool? hasReachedMax = result!.hasReachedMax;
      newEvents = result.result as List<Event>;

      if (page != 0)
        events!.addAll(newEvents);
      else
        events = newEvents;

      emit(EventsLoadedState(events: events, hasReachedMax: hasReachedMax));
    } on EventException catch (e) {
      emit(EventsErrorState(e.error));
    }
  }
}
