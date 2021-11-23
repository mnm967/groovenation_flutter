import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/bloc_util.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SocialCubit extends HydratedCubit<SocialState> {
  SocialCubit(this.socialRepository, this.type) : super(SocialInitialState());

  final SocialRepository socialRepository;
  final SocialHomeType type;

  void sendReport(String? reportType, String comment, SocialPost? post,
      SocialPerson? person) async {
    try {
      socialRepository.sendReport(reportType, comment, post, person);
    } on SocialException catch (_) {
      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT, Colors.red, Icons.error);
    }
  }

  Future<bool> blockUser(
      BuildContext context, SocialPerson person, bool isBlocked) async {
    try {
      person.hasUserBlocked = isBlocked;
      await socialRepository.changeUserBlock(person.personID, isBlocked);

      BlocUtil.updateSocialPerson(context, person);

      return true;
    } on SocialException catch (_) {
      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT, Colors.red, Icons.error);

      person.hasUserBlocked = !isBlocked;

      BlocUtil.updateSocialPerson(context, person);

      return false;
    }
  }

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

  void updateSocialPostIfExists(SocialPost post) {
    if (state is SocialLoadedState) {
      List<SocialPost?> socialPosts = (state as SocialLoadedState).socialPosts!;
      int index =
          socialPosts.indexWhere((element) => element!.postID == post.postID);

      if (index != -1) {
        socialPosts.removeAt(index);
        socialPosts.insert(index, post);

        print(socialPosts[index]!.hasUserLiked);

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

  void getSocialPosts(int page) async {
    List<SocialPost?>? socialPosts = [];

    if (state is SocialLoadedState) {
      socialPosts = (state as SocialLoadedState).socialPosts;
    }

    emit(SocialLoadingState());
    try {
      List<SocialPost> newSocial;

      APIResult? result;

      switch (type) {
        case SocialHomeType.NEARBY:
          double? lat = locationUtil.getDefaultCityLat();
          double? lon = locationUtil.getDefaultCityLon();

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

      newSocial = result!.result as List<SocialPost>;
      bool? hasReachedMax = result.hasReachedMax;

      if (page != 0)
        socialPosts!.addAll(newSocial);
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
  Map<String, dynamic>? toJson(SocialState state) {
    if (state is SocialLoadedState) {
      return {
        'social_posts': jsonEncode(state.socialPosts!.take(25).toList()),
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
