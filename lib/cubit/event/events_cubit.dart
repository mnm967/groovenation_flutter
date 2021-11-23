import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/data/repo/events_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class EventsCubit extends HydratedCubit<EventsState> {
  EventsCubit(this.eventsRepository, this.type) : super(EventsInitialState());

  final EventsRepository eventsRepository;
  final EventHomeType type;

  void getEvents(int page) async {
    List<Event>? events = [];

    if (state is EventsLoadedState) {
      events = (state as EventsLoadedState).events;
    }

    emit(EventsLoadingState());

    try {
      List<Event> newEvents;
      APIResult? result;

      switch (type) {
        case EventHomeType.FAVOURITE:
          result = await eventsRepository.getFavouriteEvents();
          break;
        case EventHomeType.UPCOMING:
          result = await eventsRepository.getUpcomingEvents(page);
          break;
        default:
      }

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

  @override
  EventsState fromJson(Map<String, dynamic> json) {
    return EventsLoadedState(
        hasReachedMax: json['hasReachedMax'],
        events: (jsonDecode(json['events']) as List)
            .map((e) => Event.fromJson(e))
            .toList());
  }

  @override
  Map<String, dynamic>? toJson(EventsState state) {
    if (state is EventsLoadedState) {
      if (type == EventHomeType.UPCOMING) {
        List<Event> eventsToSave = state.events!.take(25).toList();
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

  void addFavouriteEvent(Event event) async {
    List<Event> events = (state as EventsLoadedState).events!;

    emit(EventsFavouriteUpdatingState());

    events.add(event);

    emit(EventsLoadedState(events: events, hasReachedMax: true));

    try {
      bool? favAdded = await (eventsRepository.addFavouriteEvent(event.eventID));

      if (!favAdded!) {
        emit(EventsFavouriteUpdatingState());
        events.remove(event);
        emit(EventsLoadedState(events: events, hasReachedMax: true));

        alertUtil.sendAlert(
            BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
      }
    } catch (e) {
      emit(EventsFavouriteUpdatingState());
      events.remove(event);
      emit(EventsLoadedState(events: events, hasReachedMax: true));

      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
    }
  }

  void removeFavouriteEvent(Event event) async {
    List<Event> events = (state as EventsLoadedState).events!;
    emit(EventsFavouriteUpdatingState());

    events.removeWhere((element) => element.eventID == event.eventID);

    emit(EventsLoadedState(events: events, hasReachedMax: true));

    try {
      bool? favRemoved =
          await (eventsRepository.removeFavouriteEvent(event.eventID));

      if (!favRemoved!) {
        emit(EventsFavouriteUpdatingState());
        events.add(event);
        emit(EventsLoadedState(events: events, hasReachedMax: true));

        alertUtil.sendAlert(
            BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
      }
    } catch (e) {
      emit(EventsFavouriteUpdatingState());
      events.add(event);
      emit(EventsLoadedState(events: events, hasReachedMax: true));

      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
    }
  }

  bool checkEventExists(String? eventID) {
    if (state is EventsLoadedState) {
      (state as EventsLoadedState).events!.where((element) => false);
      var existingItem = (state as EventsLoadedState)
          .events!
          .firstWhereOrNull((e) => e.eventID == eventID);
      return existingItem != null;
    } else
      return false;
  }
}
