import 'dart:convert';
import 'package:groovenation_flutter/constants/social_home_type.dart';
import 'package:groovenation_flutter/constants/user_location_status.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SocialCubit extends HydratedCubit<SocialState> {
  SocialCubit(this.socialRepository, this.type) : super(SocialInitialState());

  final SocialRepository socialRepository;
  final SocialHomeType type;

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
          result = await socialRepository.getProfileSocialPosts(page, sharedPrefs.userId);
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
