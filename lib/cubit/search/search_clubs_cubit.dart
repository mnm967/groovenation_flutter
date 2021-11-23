import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/data/repo/clubs_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/club.dart';

class SearchClubsCubit extends Cubit<ClubsState> {
  SearchClubsCubit(this.clubsRepository) : super(ClubsInitialState());

  final ClubsRepository clubsRepository;

  void clear() {
    emit(ClubsInitialState());
  }

  void searchClubs(int page, String searchTerm) async {
    List<Club?>? clubs = [];

    if (state is ClubsLoadedState) {
      clubs = (state as ClubsLoadedState).clubs;
    }

    emit(ClubsLoadingState());

    try {
      List<Club> newClubs;

      APIResult? result;

      result = await clubsRepository.searchClubs(searchTerm, page);

      newClubs = result!.result as List<Club>;
      bool? hasReachedMax = result.hasReachedMax;

      if (page != 0)
        clubs!.addAll(newClubs);
      else
        clubs = newClubs;

      emit(ClubsLoadedState(clubs: clubs, hasReachedMax: hasReachedMax));
    } on ClubException catch (e) {
      emit(ClubsErrorState(e.error));
    }
  }
}
