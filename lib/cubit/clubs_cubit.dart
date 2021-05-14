import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/constants/club_home_type.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/constants/user_location_status.dart';
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

  void updateUserReviewClub(Club club) {
    if (state is ClubsLoadedState) {
      List<Club> clubs = (state as ClubsLoadedState).clubs;
      bool hasReachedMax = (state as ClubsLoadedState).hasReachedMax;
      int index = clubs.indexWhere((elem) => elem.clubID == club.clubID);

      if (index == -1) return;

      clubs.removeAt(index);
      clubs.insert(index, club);

      emit(ClubsInitialState());

      emit(ClubsLoadedState(clubs: clubs, hasReachedMax: hasReachedMax));
    }
  }

  void getClubs(int page) async {
    List<Club> clubs = [];

    if (state is ClubsLoadedState) {
      clubs = (state as ClubsLoadedState).clubs;
    }

    emit(ClubsLoadingState());

    try {
      List<Club> newClubs;

      APIResult result;

      switch (type) {
        case ClubHomeType.FAVOURITE:
          result = await clubsRepository.getFavouriteClubs();
          break;
        case ClubHomeType.NEARBY:
          double lat = locationUtil.getDefaultCityLat(sharedPrefs.userCity);
          double lon = locationUtil.getDefaultCityLon(sharedPrefs.userCity);

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

      newClubs = result.result as List<Club>;
      bool hasReachedMax = result.hasReachedMax;

      if (page != 0)
        clubs.addAll(newClubs);
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
  Map<String, dynamic> toJson(ClubsState state) {
    if (state is ClubsLoadedState) {
      if (type == ClubHomeType.NEARBY || type == ClubHomeType.TOP) {
        List<Club> clubsToSave = state.clubs.take(25).toList();
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

class SearchClubsCubit extends Cubit<ClubsState> {
  SearchClubsCubit(this.clubsRepository) : super(ClubsInitialState());

  final ClubsRepository clubsRepository;

  void searchClubs(int page, String searchTerm) async {
    List<Club> clubs = [];

    if (state is ClubsLoadedState) {
      clubs = (state as ClubsLoadedState).clubs;
    }

    emit(ClubsLoadingState());

    try {
      List<Club> newClubs;

      APIResult result;

      result = await clubsRepository.searchClubs(searchTerm, page);

      newClubs = result.result as List<Club>;
      bool hasReachedMax = result.hasReachedMax;

      if (page != 0)
        clubs.addAll(newClubs);
      else
        clubs = newClubs;

      emit(ClubsLoadedState(clubs: clubs, hasReachedMax: hasReachedMax));
    } on ClubException catch (e) {
      emit(ClubsErrorState(e.error));
    }
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

  void addClub(Club club) async {
    List<Club> clubs = (state as ClubsLoadedState).clubs;

    emit(ClubFavouriteUpdatingState());
    clubs.add(club);
    emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

    try {
      bool favAdded = await clubsRepository.addFavouriteClub(club.clubID);

      if (!favAdded) {
        emit(ClubFavouriteUpdatingState());
        clubs.remove(club);
        emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

        alertUtil.sendAlert(
            BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
      }
    } catch (e) {
      emit(ClubFavouriteUpdatingState());
      clubs.remove(club);
      emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
    }
  }

  void removeClub(Club club) async {
    List<Club> clubs = (state as ClubsLoadedState).clubs;

    emit(ClubFavouriteUpdatingState());

    clubs.removeWhere((element) => element.clubID == club.clubID);

    emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));

    try {
      bool favRemoved = await clubsRepository.removeFavouriteClub(club.clubID);

      if (!favRemoved) {
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

  bool checkClubExists(String clubID) {
    if (state is ClubsLoadedState) {
      (state as ClubsLoadedState).clubs.where((element) => false);
      var existingItem = (state as ClubsLoadedState)
          .clubs
          .firstWhere((e) => e.clubID == clubID, orElse: () => null);
      return existingItem != null;
    } else
      return false;
  }
}

class EventPageClubCubit extends Cubit<ClubsState> {
  EventPageClubCubit(this.clubsRepository) : super(ClubsInitialState());

  final ClubsRepository clubsRepository;

  void getClub(String clubId) async {
    emit(ClubsLoadingState());

    try {
      Club club = await clubsRepository.getClub(clubId);

      emit(ClubLoadedState(club: club));
    } on ClubException catch (e) {
      emit(ClubsErrorState(e.error));
    }
  }
}
