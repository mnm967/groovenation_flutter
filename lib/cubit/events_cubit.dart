import 'dart:convert';

import 'package:groovenation_flutter/constants/event_home_type.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/data/repo/events_repository.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class EventsCubit extends HydratedCubit<EventsState> {
  EventsCubit(this.eventsRepository, this.type) : super(EventsInitialState());

  final EventsRepository eventsRepository;
  final EventHomeType type;

  void getEvents(int page) async {
    List<Event> events = [];

    if (state is EventsLoadedState) {
      events = (state as EventsLoadedState).events;
    }

    emit(EventsLoadingState());

    try {
      List<Event> newEvents;
      switch (type) {
        case EventHomeType.FAVOURITE:
          newEvents = await eventsRepository.getTestEvents(page);
          break;
        case EventHomeType.UPCOMING:
          newEvents = await eventsRepository.getTestEvents(page);
          break;
        default:
          newEvents = await eventsRepository.getTestEvents(page);
          break;
      }

      bool hasReachedMax = newEvents.length == 0;
      if (page != 0)
        events.addAll(newEvents);
      else
        events = newEvents;

      print("Loaded Emit: $type");

      emit(EventsLoadedState(events: events, hasReachedMax: hasReachedMax));
    } catch (e) {
      print(e.toString());
      emit(EventsErrorState(Error.UNKNOWN_ERROR));
    }
  }

  @override
  EventsState fromJson(Map<String, dynamic> json) {
    return EventsLoadedState(
        hasReachedMax: json['hasReachedMax'],
        events: (jsonDecode(json['events']) as List)
            .map((e) => Event.fromJson(e))
            .toList());
  }

  @override
  Map<String, dynamic> toJson(EventsState state) {
    if (state is EventsLoadedState) {
      if (type == EventHomeType.UPCOMING) {
        List<Event> eventsToSave = state.events.take(25).toList();
        return {
          'events': jsonEncode(eventsToSave),
          'hasReachedMax': state.hasReachedMax
        };
      }

      return {
        'events': jsonEncode(state.events),
        'hasReachedMax': state.hasReachedMax
      };
    }
    return null;
  }
}

class UpcomingEventsCubit extends EventsCubit {
  UpcomingEventsCubit(EventsRepository eventsRepository)
      : super(eventsRepository, EventHomeType.UPCOMING);
}


class FavouritesEventsCubit extends EventsCubit {
  FavouritesEventsCubit(EventsRepository eventsRepository)
      : super(eventsRepository, EventHomeType.FAVOURITE);

  void addEvent(Event event) async {
    List<Event> events = (state as EventsLoadedState).events;
    events.add(event);
    print("AddEvent");
    emit(EventsFavouriteUpdatingState());

    emit(EventsLoadedState(events: events, hasReachedMax: true));
  }

  void removeEvent(String eventID) async {
    print("RemoveEvent");
    List<Event> events = (state as EventsLoadedState).events;
    events.removeWhere((element) => element.eventID == eventID);
    emit(EventsFavouriteUpdatingState());

    emit(EventsLoadedState(events: events, hasReachedMax: true));
  }

  bool checkEventExists(String eventID) {
    if (state is EventsLoadedState) {
      (state as EventsLoadedState).events.where((element) => false);
      var existingItem = (state as EventsLoadedState)
          .events
          .firstWhere((e) => e.eventID == eventID, orElse: () => null);
      //print("is it in?:" + (existingItem != null).toString());
      return existingItem != null;
    } else
      return false;
  }
}
