import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/data/repo/clubs_repository.dart';
import 'package:groovenation_flutter/models/club.dart';

class EventClubCubit extends Cubit<ClubsState> {
  EventClubCubit(this.clubsRepository) : super(ClubsInitialState());

  final ClubsRepository clubsRepository;

  void getClub(String? clubId) async {
    emit(ClubsLoadingState());

    try {
      Club? club = await clubsRepository.getClub(clubId);

      emit(ClubLoadedState(club: club));
    } on ClubException catch (e) {
      emit(ClubsErrorState(e.error));
    }
  }
}