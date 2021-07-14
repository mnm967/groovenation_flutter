import 'package:bloc/bloc.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this.socialRepository) : super(UserInitialState());

  final SocialRepository socialRepository;

  void getFollowing(int page) async {
    emit(UserFollowingLoadingState());

    try {
      APIResult result =
          await socialRepository.getUserFollowing(page, sharedPrefs.userId);
      List<SocialPerson> userFollowing = result.result as List<SocialPerson>;

      emit(UserFollowingLoadedState(
          socialPeople: userFollowing, hasReachedMax: result.hasReachedMax));
    } on SocialException catch (e) {
      emit(UserFollowingErrorState(e.error));
    }
  }

  void searchFollowing(int page, String term) async {
    emit(UserFollowingLoadingState());

    try {
      APIResult result =
          await socialRepository.searchUserFollowing(page, sharedPrefs.userId, term);
      List<SocialPerson> userFollowing = result.result as List<SocialPerson>;

      emit(UserFollowingLoadedState(
          socialPeople: userFollowing, hasReachedMax: result.hasReachedMax));
    } on SocialException catch (e) {
      emit(UserFollowingErrorState(e.error));
    }
  }
}

class SearchUsersCubit extends Cubit<UserState> {
  SearchUsersCubit(this.socialRepository) : super(UserInitialState());

  final SocialRepository socialRepository;

  void searchUsers(int page, String searchTerm) async {
    List<SocialPerson> people = [];

    if (state is SocialUsersSearchLoadedState) {
      people = (state as SocialUsersSearchLoadedState).socialPeople;
    }

    emit(SocialUsersSearchLoadingState());

    try {
      List<SocialPerson> newPeople;

      APIResult result;

      result = await socialRepository.searchUsers(searchTerm, page);

      newPeople = result.result as List<SocialPerson>;
      bool hasReachedMax = result.hasReachedMax;

      if (page != 0)
        people.addAll(newPeople);
      else
        people = newPeople;

      emit(SocialUsersSearchLoadedState(socialPeople: people, hasReachedMax: hasReachedMax));
    } on SocialException catch (e) {
      emit(SocialUsersSearchErrorState(e.error));
    }
  }
}