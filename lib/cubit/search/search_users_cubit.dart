import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_person.dart';

class SearchUsersCubit extends Cubit<UserState> {
  SearchUsersCubit(this.socialRepository) : super(UserInitialState());

  final SocialRepository socialRepository;

  void clear() {
    emit(UserInitialState());
  }

  void searchUsers(int page, String searchTerm) async {
    List<SocialPerson>? people = [];

    if (state is SocialUsersSearchLoadedState) {
      people = (state as SocialUsersSearchLoadedState).socialPeople;
    }

    emit(SocialUsersSearchLoadingState());

    try {
      List<SocialPerson> newPeople;

      APIResult? result;

      result = await socialRepository.searchUsers(searchTerm, page);

      newPeople = result!.result as List<SocialPerson>;
      bool? hasReachedMax = result.hasReachedMax;

      if (page != 0)
        people!.addAll(newPeople);
      else
        people = newPeople;

      emit(SocialUsersSearchLoadedState(socialPeople: people, hasReachedMax: hasReachedMax));
    } on SocialException catch (e) {
      emit(SocialUsersSearchErrorState(e.error));
    }
  }
}