import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this.socialRepository) : super(UserInitialState());

  final SocialRepository socialRepository;

  void getFollowing(int page) async {
    emit(UserFollowingLoadingState());

    try {
      APIResult? result =
          await (socialRepository.getUserFollowing(page, sharedPrefs.userId));
      List<SocialPerson> userFollowing = result!.result as List<SocialPerson>;

      emit(UserFollowingLoadedState(
          socialPeople: userFollowing, hasReachedMax: result.hasReachedMax));
    } on SocialException catch (e) {
      emit(UserFollowingErrorState(e.error));
    }
  }

  void searchFollowing(int page, String term) async {
    emit(UserFollowingLoadingState());

    try {
      APIResult? result = await (socialRepository.searchUserFollowing(
          page, sharedPrefs.userId, term));
      List<SocialPerson> userFollowing = result!.result as List<SocialPerson>;

      emit(UserFollowingLoadedState(
          socialPeople: userFollowing, hasReachedMax: result.hasReachedMax));
    } on SocialException catch (e) {
      emit(UserFollowingErrorState(e.error));
    }
  }
}

class UserListCubit extends Cubit<UserState> {
  UserListCubit(this.socialRepository) : super(UserInitialState());

  final SocialRepository socialRepository;

  void loadConversationUsers(List<String>? userIds) async {
    emit(ConversationUsersLoadingState());

    try {
      List<SocialPerson>? users =
          await socialRepository.getConversationPeople(userIds);

      emit(ConversationUsersLoadedState(socialPeople: users));
    } catch (e) {
      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
      emit(ConversationUsersErrorState(AppError.NETWORK_ERROR));
    }
  }

  void addConversationUser(SocialPerson person) async {
    if (state is ConversationUsersLoadedState) {
      emit(ConversationUsersUpdatingState());

      List<SocialPerson>? users =
          (state as ConversationUsersLoadedState).socialPeople;
      users!.add(person);

      emit(ConversationUsersLoadedState(socialPeople: users));
    }
  }
}
