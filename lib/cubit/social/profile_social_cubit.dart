import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/util/bloc_util.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ProfileSocialCubit extends Cubit<SocialState> {
  ProfileSocialCubit(this.socialRepository) : super(SocialInitialState());

  final SocialRepository socialRepository;

  void updateSocialPersonIfExists(SocialPerson person) {
    if (state is SocialLoadedState) {
      List<SocialPost?> socialPosts = (state as SocialLoadedState).socialPosts!;
      List<SocialPost> newList = [];

      socialPosts.forEach((element) {
        if (element!.person.personID == person.personID) {
          element.person = person;
        }
        newList.add(element);
      });

      emit(SocialLoadedState(
          socialPosts: socialPosts,
          hasReachedMax: (state as SocialLoadedState).hasReachedMax));
    }
  }

  void updateUserFollowing(BuildContext context, SocialPerson person) async {
    try {
      BlocUtil.updateSocialPerson(context, person);

      await socialRepository.changeUserFollowing(person);

      emit(SocialPostLikeSuccessState());
    } on SocialException catch (e) {
      person.isUserFollowing = !person.isUserFollowing!;

      BlocUtil.updateSocialPerson(context, person);

      emit(SocialPostLikeErrorState(e.error));
    }
  }

  void updateSocialPostIfExists(SocialPost post) {
    if (state is SocialLoadedState) {
      List<SocialPost?> socialPosts = (state as SocialLoadedState).socialPosts!;
      int index =
          socialPosts.indexWhere((element) => element!.postID == post.postID);

      if (index != -1) {
        socialPosts.removeAt(index);
        socialPosts.insert(index, post);

        emit(SocialLoadedState(
            socialPosts: socialPosts,
            hasReachedMax: (state as SocialLoadedState).hasReachedMax));
      }
    }
  }

  void insertUserSocialPost(SocialPost post) {
    if (state is SocialLoadedState) {
      List<SocialPost?> socialPosts = (state as SocialLoadedState).socialPosts!;
      socialPosts.insert(0, post);

      emit(SocialLoadedState(
          socialPosts: socialPosts,
          hasReachedMax: (state as SocialLoadedState).hasReachedMax));
    }
  }

  void getSocialPosts(int page, SocialPerson socialPerson) async {
    emit(SocialLoadingState());
    try {
      List<SocialPost> newSocial;

      APIResult? result;

      result = await socialRepository.getProfileSocialPosts(
          page, socialPerson.personID);

      newSocial = result!.result as List<SocialPost>;
      bool? hasReachedMax = result.hasReachedMax;

      emit(SocialLoadedState(
          socialPosts: newSocial, hasReachedMax: hasReachedMax));
    } on SocialException catch (e) {
      emit(SocialErrorState(e.error));
    }
  }
}