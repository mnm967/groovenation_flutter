import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/social_home_type.dart';
import 'package:groovenation_flutter/constants/user_location_status.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SocialCubit extends HydratedCubit<SocialState> {
  SocialCubit(this.socialRepository, this.type) : super(SocialInitialState());

  final SocialRepository socialRepository;
  final SocialHomeType type;

  void updateSocialPersonIfExists(SocialPerson person) {
    if (state is SocialLoadedState) {
      List<SocialPost> socialPosts = (state as SocialLoadedState).socialPosts;
      List<SocialPost> newList = [];

      socialPosts.forEach((element) {
        if (element.person.personID == person.personID) {
          element.person = person;
        }
        newList.add(element);
      });

      emit(SocialLoadedState(
          socialPosts: socialPosts,
          hasReachedMax: (state as SocialLoadedState).hasReachedMax));
    }
  }

  void updateSocialPostIfExists(SocialPost post) {
    if (state is SocialLoadedState) {
      List<SocialPost> socialPosts = (state as SocialLoadedState).socialPosts;
      int index =
          socialPosts.indexWhere((element) => element.postID == post.postID);

      if (index != -1) {
        socialPosts.removeAt(index);
        socialPosts.insert(index, post);

        print(socialPosts[index].hasUserLiked);

        emit(SocialLoadedState(
            socialPosts: socialPosts,
            hasReachedMax: (state as SocialLoadedState).hasReachedMax));
      }
    }
  }

  void insertUserSocialPost(SocialPost post) {
    if (state is SocialLoadedState) {
      List<SocialPost> socialPosts = (state as SocialLoadedState).socialPosts;
      socialPosts.insert(0, post);

      // emit(SocialLoadingState());
      emit(SocialLoadedState(
          socialPosts: socialPosts,
          hasReachedMax: (state as SocialLoadedState).hasReachedMax));
    }
  }

  void getSocialPosts(int page) async {
    List<SocialPost> socialPosts = [];

    if (state is SocialLoadedState) {
      socialPosts = (state as SocialLoadedState).socialPosts;
    }

    emit(SocialLoadingState());
    try {
      List<SocialPost> newSocial;

      APIResult result;

      switch (type) {
        case SocialHomeType.NEARBY:
          double lat = locationUtil.getDefaultCityLat(sharedPrefs.userCity);
          double lon = locationUtil.getDefaultCityLon(sharedPrefs.userCity);

          if (locationUtil.userLocationStatus == UserLocationStatus.FOUND) {
            lat = locationUtil.userLocation.latitude;
            lon = locationUtil.userLocation.longitude;
          }

          result = await socialRepository.getNearbySocialPosts(page, lat, lon);
          break;
        case SocialHomeType.FOLLOWING:
          result = await socialRepository.getFollowingSocialPosts(page);
          break;
        case SocialHomeType.TRENDING:
          result = await socialRepository.getTrendingSocialPosts(page);
          break;
        case SocialHomeType.USER:
          result = await socialRepository.getProfileSocialPosts(
              page, sharedPrefs.userId);
          break;
        default:
      }

      newSocial = result.result as List<SocialPost>;
      bool hasReachedMax = result.hasReachedMax;

      if (page != 0)
        socialPosts.addAll(newSocial);
      else
        socialPosts = newSocial;

      emit(SocialLoadedState(
          socialPosts: socialPosts, hasReachedMax: hasReachedMax));
    } on SocialException catch (e) {
      emit(SocialErrorState(e.error));
    }
  }

  @override
  SocialState fromJson(Map<String, dynamic> json) {
    return SocialLoadedState(
        socialPosts: (jsonDecode(json['social_posts']) as List)
            .map((e) => SocialPost.fromJson(e))
            .toList(),
        hasReachedMax: json['hasReachedMax']);
  }

  @override
  Map<String, dynamic> toJson(SocialState state) {
    if (state is SocialLoadedState) {
      return {
        'social_posts': jsonEncode(state.socialPosts.take(25).toList()),
        'hasReachedMax': state.hasReachedMax,
      };
    }
    return null;
  }
}

class NearbySocialCubit extends SocialCubit {
  NearbySocialCubit(SocialRepository socialRepository)
      : super(socialRepository, SocialHomeType.NEARBY);
}

class FollowingSocialCubit extends SocialCubit {
  FollowingSocialCubit(SocialRepository socialRepository)
      : super(socialRepository, SocialHomeType.FOLLOWING);
}

class TrendingSocialCubit extends SocialCubit {
  TrendingSocialCubit(SocialRepository socialRepository)
      : super(socialRepository, SocialHomeType.TRENDING);
}

class UserSocialCubit extends SocialCubit {
  UserSocialCubit(SocialRepository socialRepository)
      : super(socialRepository, SocialHomeType.USER);
}

class ProfileSocialCubit extends Cubit<SocialState> {
  ProfileSocialCubit(this.socialRepository) : super(SocialInitialState());

  final SocialRepository socialRepository;

  void updateSocialPersonIfExists(SocialPerson person) {
    if (state is SocialLoadedState) {
      List<SocialPost> socialPosts = (state as SocialLoadedState).socialPosts;
      List<SocialPost> newList = [];

      socialPosts.forEach((element) {
        if (element.person.personID == person.personID) {
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
      final FollowingSocialCubit followingSocialCubit =
          BlocProvider.of<FollowingSocialCubit>(context);
      final TrendingSocialCubit trendingSocialCubit =
          BlocProvider.of<TrendingSocialCubit>(context);
      final NearbySocialCubit nearbySocialCubit =
          BlocProvider.of<NearbySocialCubit>(context);
      final UserSocialCubit userSocialCubit =
          BlocProvider.of<UserSocialCubit>(context);
      final ProfileSocialCubit profileSocialCubit =
          BlocProvider.of<ProfileSocialCubit>(context);
      final ClubMomentsCubit clubMomentsCubit =
          BlocProvider.of<ClubMomentsCubit>(context);

      followingSocialCubit.updateSocialPersonIfExists(person);
      trendingSocialCubit.updateSocialPersonIfExists(person);
      nearbySocialCubit.updateSocialPersonIfExists(person);
      userSocialCubit.updateSocialPersonIfExists(person);
      profileSocialCubit.updateSocialPersonIfExists(person);
      clubMomentsCubit.updateSocialPersonIfExists(person);

      await socialRepository.changeUserFollowing(person);

      emit(SocialPostLikeSuccessState());
    } on SocialException catch (e) {
      person.isUserFollowing = !person.isUserFollowing;

      final FollowingSocialCubit followingSocialCubit =
          BlocProvider.of<FollowingSocialCubit>(context);
      final TrendingSocialCubit trendingSocialCubit =
          BlocProvider.of<TrendingSocialCubit>(context);
      final NearbySocialCubit nearbySocialCubit =
          BlocProvider.of<NearbySocialCubit>(context);
      final UserSocialCubit userSocialCubit =
          BlocProvider.of<UserSocialCubit>(context);
      final ProfileSocialCubit profileSocialCubit =
          BlocProvider.of<ProfileSocialCubit>(context);
      final ClubMomentsCubit clubMomentsCubit =
          BlocProvider.of<ClubMomentsCubit>(context);

      followingSocialCubit.updateSocialPersonIfExists(person);
      trendingSocialCubit.updateSocialPersonIfExists(person);
      nearbySocialCubit.updateSocialPersonIfExists(person);
      userSocialCubit.updateSocialPersonIfExists(person);
      profileSocialCubit.updateSocialPersonIfExists(person);
      clubMomentsCubit.updateSocialPersonIfExists(person);

      emit(SocialPostLikeErrorState(e.error));
    }
  }

  void updateSocialPostIfExists(SocialPost post) {
    if (state is SocialLoadedState) {
      List<SocialPost> socialPosts = (state as SocialLoadedState).socialPosts;
      int index =
          socialPosts.indexWhere((element) => element.postID == post.postID);

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
      List<SocialPost> socialPosts = (state as SocialLoadedState).socialPosts;
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

      APIResult result;

      result = await socialRepository.getProfileSocialPosts(
          page, socialPerson.personID);

      newSocial = result.result as List<SocialPost>;
      bool hasReachedMax = result.hasReachedMax;

      emit(SocialLoadedState(
          socialPosts: newSocial, hasReachedMax: hasReachedMax));
    } on SocialException catch (e) {
      emit(SocialErrorState(e.error));
    }
  }
}

class ClubMomentsCubit extends Cubit<SocialState> {
  ClubMomentsCubit(this.socialRepository) : super(SocialInitialState());

  final SocialRepository socialRepository;

  void updateSocialPersonIfExists(SocialPerson person) {
    if (state is SocialLoadedState) {
      List<SocialPost> socialPosts = (state as SocialLoadedState).socialPosts;
      List<SocialPost> newList = [];

      socialPosts.forEach((element) {
        if (element.person.personID == person.personID) {
          element.person = person;
        }
        newList.add(element);
      });

      emit(SocialLoadedState(
          socialPosts: socialPosts,
          hasReachedMax: (state as SocialLoadedState).hasReachedMax));
    }
  }

  void updateSocialPostIfExists(SocialPost post) {
    if (state is SocialLoadedState) {
      List<SocialPost> socialPosts = (state as SocialLoadedState).socialPosts;
      int index =
          socialPosts.indexWhere((element) => element.postID == post.postID);

      if (index != -1) {
        socialPosts.removeAt(index);
        socialPosts.insert(index, post);

        emit(SocialLoadedState(
            socialPosts: socialPosts,
            hasReachedMax: (state as SocialLoadedState).hasReachedMax));
      }
    }
  }

  void getMoments(int page, String clubId) async {
    emit(SocialLoadingState());
    try {
      List<SocialPost> newSocial;

      APIResult result;

      result = await socialRepository.getClubSocialPosts(page, clubId);

      newSocial = result.result as List<SocialPost>;
      bool hasReachedMax = result.hasReachedMax;

      emit(SocialLoadedState(
          socialPosts: newSocial, hasReachedMax: hasReachedMax));
    } on SocialException catch (e) {
      emit(SocialErrorState(e.error));
    }
  }
}

class SocialPostCubit extends Cubit<SocialState> {
  SocialPostCubit(this.socialRepository) : super(SocialInitialState());

  final SocialRepository socialRepository;

  void uploadPost(BuildContext context, String mediaFilePath, String caption,
      String clubId, bool isVideo) async {
    emit(SocialPostUploadLoadingState());
    try {
      SocialPost post = await socialRepository.uploadSocialPost(
          mediaFilePath, caption, clubId, isVideo);

      final FollowingSocialCubit followingSocialCubit =
          BlocProvider.of<FollowingSocialCubit>(context);
      final NearbySocialCubit nearbySocialCubit =
          BlocProvider.of<NearbySocialCubit>(context);
      final UserSocialCubit userSocialCubit =
          BlocProvider.of<UserSocialCubit>(context);

      followingSocialCubit.insertUserSocialPost(post);
      if (post.clubID != null) nearbySocialCubit.insertUserSocialPost(post);
      userSocialCubit.insertUserSocialPost(post);

      emit(SocialPostUploadSuccessState(post));
    } on SocialException catch (e) {
      emit(SocialPostUploadErrorState(e.error));
    }
  }

  void changeLikePost(BuildContext context, SocialPost post) async {
    emit(SocialPostLikeLoadingState());

    if (post.hasUserLiked) {
      post.hasUserLiked = false;
      post.likesAmount = post.likesAmount - 1;
    } else {
      post.hasUserLiked = true;
      post.likesAmount = post.likesAmount + 1;
    }

    try {
      emit(SocialPostLikeUpdatingState(post));
      emit(SocialPostLikeLoadingState());

      final FollowingSocialCubit followingSocialCubit =
          BlocProvider.of<FollowingSocialCubit>(context);
      final TrendingSocialCubit trendingSocialCubit =
          BlocProvider.of<TrendingSocialCubit>(context);
      final NearbySocialCubit nearbySocialCubit =
          BlocProvider.of<NearbySocialCubit>(context);
      final UserSocialCubit userSocialCubit =
          BlocProvider.of<UserSocialCubit>(context);
      final ProfileSocialCubit profileSocialCubit =
          BlocProvider.of<ProfileSocialCubit>(context);
      final ClubMomentsCubit clubMomentsCubit =
          BlocProvider.of<ClubMomentsCubit>(context);

      followingSocialCubit.updateSocialPostIfExists(post);
      trendingSocialCubit.updateSocialPostIfExists(post);
      nearbySocialCubit.updateSocialPostIfExists(post);
      userSocialCubit.updateSocialPostIfExists(post);
      profileSocialCubit.updateSocialPostIfExists(post);
      clubMomentsCubit.updateSocialPostIfExists(post);

      await socialRepository.changeLikeSocialPost(post);

      emit(SocialPostLikeSuccessState());
    } on SocialException catch (e) {
      if (post.hasUserLiked) {
        post.hasUserLiked = false;
        post.likesAmount = post.likesAmount - 1;
      } else {
        post.hasUserLiked = true;
        post.likesAmount = post.likesAmount + 1;
      }

      emit(SocialPostLikeUpdatingState(post));

      final FollowingSocialCubit followingSocialCubit =
          BlocProvider.of<FollowingSocialCubit>(context);
      final TrendingSocialCubit trendingSocialCubit =
          BlocProvider.of<TrendingSocialCubit>(context);
      final NearbySocialCubit nearbySocialCubit =
          BlocProvider.of<NearbySocialCubit>(context);
      final UserSocialCubit userSocialCubit =
          BlocProvider.of<UserSocialCubit>(context);
      final ProfileSocialCubit profileSocialCubit =
          BlocProvider.of<ProfileSocialCubit>(context);
      final ClubMomentsCubit clubMomentsCubit =
          BlocProvider.of<ClubMomentsCubit>(context);

      followingSocialCubit.updateSocialPostIfExists(post);
      trendingSocialCubit.updateSocialPostIfExists(post);
      nearbySocialCubit.updateSocialPostIfExists(post);
      userSocialCubit.updateSocialPostIfExists(post);
      profileSocialCubit.updateSocialPostIfExists(post);
      clubMomentsCubit.updateSocialPostIfExists(post);

      emit(SocialPostLikeErrorState(e.error));
    }
  }
}
