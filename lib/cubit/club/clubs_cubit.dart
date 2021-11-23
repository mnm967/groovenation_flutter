import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/data/repo/clubs_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ClubsCubit extends HydratedCubit<ClubsState> {
  ClubsCubit(this.clubsRepository, this.type) : super(ClubsInitialState());

  final ClubsRepository clubsRepository;
  final ClubHomeType type;

  void updateUserReviewClub(Club? club) {
    if (state is ClubsLoadedState) {
      List<Club?> clubs = (state as ClubsLoadedState).clubs!;
      bool? hasReachedMax = (state as ClubsLoadedState).hasReachedMax;
      int index = clubs.indexWhere((elem) => elem!.clubID == club!.clubID);

      if (index == -1) return;

      clubs.removeAt(index);
      clubs.insert(index, club);

      emit(ClubsInitialState());

      emit(ClubsLoadedState(clubs: clubs, hasReachedMax: hasReachedMax));
    }
  }

  void setFavouriteClubsIDsJSON(List<Club> clubs) async {
    List<String> clubIds = [];
    clubs.forEach((element) {
      clubIds.add(element.clubID!);
    });

    sharedPrefs.favouriteClubIds = clubIds;

    if (sharedPrefs.notificationSetting == NOTIFICATION_FAVOURITE_ONLY)
      clubIds.forEach((element) {
        FirebaseMessaging.instance
            .subscribeToTopic("favourite_club_topic-$element");
      });
  }

  void getClubs(int page) async {
    List<Club?>? clubs = [];

    if (state is ClubsLoadedState) {
      clubs = (state as ClubsLoadedState).clubs;
    }

    emit(ClubsLoadingState(oldClubs: clubs));

    try {
      List<Club> newClubs;

      APIResult? result;

      switch (type) {
        case ClubHomeType.FAVOURITE:
          result = await clubsRepository.getFavouriteClubs();
          break;
        case ClubHomeType.NEARBY:
          double? lat = locationUtil.getDefaultCityLat();
          double? lon = locationUtil.getDefaultCityLon();

          if (locationUtil.userLocationStatus == UserLocationStatus.FOUND) {
            lat = locationUtil.userLocation.latitude;
            lon = locationUtil.userLocation.longitude;
          }

          result = await clubsRepository.getNearbyClubs(page, lat, lon);
          break;
        case ClubHomeType.TOP:
          result = await clubsRepository.getTopRatedClubs(page);
          break;
        default:
      }

      newClubs = result!.result as List<Club>;
      bool? hasReachedMax = result.hasReachedMax;

      if (type == ClubHomeType.FAVOURITE) setFavouriteClubsIDsJSON(newClubs);

      if (page != 0)
        clubs!.addAll(newClubs);
      else
        clubs = newClubs;

      emit(ClubsLoadedState(clubs: clubs, hasReachedMax: hasReachedMax));
    } on ClubException catch (e) {
      print("ErrorFound: " + e.error.toString());
      emit(ClubsErrorState(e.error));
    }
  }

  @override
  ClubsState fromJson(Map<String, dynamic> json) {
    return ClubsLoadedState(
        hasReachedMax: json['hasReachedMax'],
        clubs: (jsonDecode(json['clubs']) as List)
            .map((e) => Club.fromJson(e, true))
            .toList());
  }

  @override
  Map<String, dynamic>? toJson(ClubsState state) {
    if (state is ClubsLoadedState) {
      if (type == ClubHomeType.NEARBY || type == ClubHomeType.TOP) {
        List<Club?> clubsToSave = state.clubs!.take(25).toList();
        return {
          'clubs': jsonEncode(clubsToSave),
          'hasReachedMax': state.hasReachedMax
        };
      }

      return {
        'clubs': jsonEncode(state.clubs),
        'hasReachedMax': state.hasReachedMax
      };
    }
    return null;
  }
}

class NearbyClubsCubit extends ClubsCubit {
  NearbyClubsCubit(ClubsRepository clubsRepository)
      : super(clubsRepository, ClubHomeType.NEARBY);
}

class TopClubsCubit extends ClubsCubit {
  TopClubsCubit(ClubsRepository clubsRepository)
      : super(clubsRepository, ClubHomeType.TOP);
}

class FavouritesClubsCubit extends ClubsCubit {
  FavouritesClubsCubit(ClubsRepository clubsRepository)
      : super(clubsRepository, ClubHomeType.FAVOURITE);

  void addFavouriteClubNotification(Club club) async {
    List<String> clubIds = sharedPrefs.favouriteClubIds;
    clubIds.add(club.clubID!);

    sharedPrefs.favouriteClubIds = clubIds;

    if (sharedPrefs.notificationSetting == NOTIFICATION_FAVOURITE_ONLY)
      FirebaseMessaging.instance
          .subscribeToTopic("favourite_club_topic-${club.clubID}");
  }

  void removeFavouriteClubNotification(Club club) async {
    List<String> clubIds = sharedPrefs.favouriteClubIds;
    clubIds.remove(club.clubID);

    sharedPrefs.favouriteClubIds = clubIds;

    if (sharedPrefs.notificationSetting == NOTIFICATION_FAVOURITE_ONLY)
      FirebaseMessaging.instance
          .unsubscribeFromTopic("favourite_club_topic-${club.clubID}");
  }

  void addFavouriteClub(Club club) async {
    List<Club?> clubs = (state as ClubsLoadedState).clubs!;
    addFavouriteClubNotification(club);

    emit(ClubFavouriteUpdatingState());
    clubs.add(club);
    emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

    try {
      bool? favAdded = await (clubsRepository.addFavouriteClub(club.clubID));

      if (!favAdded!) {
        emit(ClubFavouriteUpdatingState());
        clubs.remove(club);
        emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

        alertUtil.sendAlert(
            BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);

        removeFavouriteClubNotification(club);
      }
    } catch (e) {
      emit(ClubFavouriteUpdatingState());
      clubs.remove(club);
      emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);

      removeFavouriteClubNotification(club);
    }
  }

  void removeFavouriteClub(Club club) async {
    List<Club?> clubs = (state as ClubsLoadedState).clubs!;
    removeFavouriteClubNotification(club);

    emit(ClubFavouriteUpdatingState());

    clubs.removeWhere((element) => element!.clubID == club.clubID);

    emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

    try {
      bool? favRemoved =
          await (clubsRepository.removeFavouriteClub(club.clubID));

      if (!favRemoved!) {
        emit(ClubFavouriteUpdatingState());
        clubs.add(club);
        emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

        alertUtil.sendAlert(
            BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
      }
    } catch (e) {
      emit(ClubFavouriteUpdatingState());
      clubs.add(club);
      emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
    }
  }

  bool checkClubExists(String? clubID) {
    if (state is ClubsLoadedState) {
      (state as ClubsLoadedState).clubs!.where((element) => false);
      var existingItem = false;
      for (var club in (state as ClubsLoadedState).clubs!) {
        if (club!.clubID == clubID) existingItem = true;
      }
      return existingItem;
    } else
      return false;
  }
}
