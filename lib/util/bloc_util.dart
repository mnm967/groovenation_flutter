import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/chat/conversations_cubit.dart';
import 'package:groovenation_flutter/cubit/club/club_moments_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_events_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_users_cubit.dart';
import 'package:groovenation_flutter/cubit/social/profile_social_cubit.dart';
import 'package:groovenation_flutter/cubit/social/social_cubit.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';

class BlocUtil {
  static void updateSocialPerson(BuildContext context, SocialPerson person) {
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
  }

  static void updateSocialPost(BuildContext context, SocialPost post) {
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
  }

  static void clearSearchCubits(BuildContext context) async {
    final SearchClubsCubit searchClubsCubit =
        BlocProvider.of<SearchClubsCubit>(context);
    final SearchEventsCubit searchEventsCubit =
        BlocProvider.of<SearchEventsCubit>(context);
    final SearchUsersCubit searchUsersCubit =
        BlocProvider.of<SearchUsersCubit>(context);

    searchUsersCubit.clear();
    searchEventsCubit.clear();
    searchClubsCubit.clear();
  }
}
