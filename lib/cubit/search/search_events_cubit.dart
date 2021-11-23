
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/data/repo/events_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/event.dart';

class SearchEventsCubit extends Cubit<EventsState> {
  SearchEventsCubit(this.eventsRepository) : super(EventsInitialState());

  final EventsRepository eventsRepository;

  void clear() {
    emit(EventsInitialState());
  }

  void searchEvents(int page, String searchTerm) async {
    List<Event>? events = [];

    if (state is EventsLoadedState) {
      events = (state as EventsLoadedState).events;
    }

    emit(EventsLoadingState());

    try {
      List<Event> newEvents;
      APIResult? result;

      result = await eventsRepository.searchEvents(searchTerm, page);

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