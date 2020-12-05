import 'dart:convert';

import 'package:groovenation_flutter/constants/club_home_type.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/data/repo/clubs_repository.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ClubsCubit extends HydratedCubit<ClubsState> {
  ClubsCubit(this.clubsRepository, this.type) : super(ClubsInitialState());

  final ClubsRepository clubsRepository;
  final ClubHomeType type;

  void getClubs(int page) async {
    List<Club> clubs = [];

    if (state is ClubsLoadedState) {
      clubs = (state as ClubsLoadedState).clubs;
    }

    emit(ClubsLoadingState());

    try {
      List<Club> newClubs;
      switch (type) {
        case ClubHomeType.FAVOURITE:
          newClubs = await clubsRepository.getTestClubs(page);
          break;
        case ClubHomeType.NEARBY:
          newClubs = await clubsRepository.getTestClubs(page);
          break;
        case ClubHomeType.TOP:
          newClubs = await clubsRepository.getTestClubs(page);
          break;
        default:
          newClubs = await clubsRepository.getTestClubs(page);
          break;
      }

      bool hasReachedMax = newClubs.length == 0;
      if (page != 0)
        clubs.addAll(newClubs);
      else
        clubs = newClubs;

      print("Loaded Emit: $type");

      emit(ClubsLoadedState(clubs: clubs, hasReachedMax: hasReachedMax));
    } catch (e) {
      print(e.toString());
      emit(ClubsErrorState(Error.UNKNOWN_ERROR));
    }
  }

  @override
  ClubsState fromJson(Map<String, dynamic> json) {
    return ClubsLoadedState(
        hasReachedMax: json['hasReachedMax'],
        clubs: (jsonDecode(json['clubs']) as List)
            .map((e) => Club.fromJson(e))
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
    clubs.add(club);
    print("AddClub");
    emit(ClubFavouriteUpdatingState());

    emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));
  }

  void removeClub(String clubID) async {
    print("RemoveClub");
    List<Club> clubs = (state as ClubsLoadedState).clubs;
    clubs.removeWhere((element) => element.clubID == clubID);
    emit(ClubFavouriteUpdatingState());

    emit(ClubsLoadedState(clubs: clubs, hasReachedMax: true));
  }

  bool checkClubExists(String clubID) {
    if (state is ClubsLoadedState) {
      (state as ClubsLoadedState).clubs.where((element) => false);
      var existingItem = (state as ClubsLoadedState)
          .clubs
          .firstWhere((e) => e.clubID == clubID, orElse: () => null);
      //print("is it in?:" + (existingItem != null).toString());
      return existingItem != null;
    } else
      return false;
  }
}
