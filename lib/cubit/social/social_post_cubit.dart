import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/social/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/util/bloc_util.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SocialPostCubit extends Cubit<SocialState> {
  SocialPostCubit(this.socialRepository) : super(SocialInitialState());

  final SocialRepository socialRepository;

  void uploadPost(BuildContext context, String mediaFilePath, String caption,
      String? clubId, bool? isVideo) async {
    emit(SocialPostUploadLoadingState());
    try {
      SocialPost? post = await (socialRepository.uploadSocialPost(
          mediaFilePath, caption, clubId, isVideo));

      final FollowingSocialCubit followingSocialCubit =
          BlocProvider.of<FollowingSocialCubit>(context);
      final NearbySocialCubit nearbySocialCubit =
          BlocProvider.of<NearbySocialCubit>(context);
      final UserSocialCubit userSocialCubit =
          BlocProvider.of<UserSocialCubit>(context);

      followingSocialCubit.insertUserSocialPost(post!);
      if (post.clubID != null) nearbySocialCubit.insertUserSocialPost(post);
      userSocialCubit.insertUserSocialPost(post);

      emit(SocialPostUploadSuccessState(post));
    } on SocialException catch (e) {
      emit(SocialPostUploadErrorState(e.error));
    }
  }

  void changeLikePost(BuildContext context, SocialPost post) async {
    emit(SocialPostLikeLoadingState());

    if (post.hasUserLiked!) {
      post.hasUserLiked = false;
      post.likesAmount = post.likesAmount! - 1;
    } else {
      post.hasUserLiked = true;
      post.likesAmount = post.likesAmount! + 1;
    }

    try {
      emit(SocialPostLikeUpdatingState(post));
      emit(SocialPostLikeLoadingState());

      BlocUtil.updateSocialPost(context, post);

      await socialRepository.changeLikeSocialPost(post);

      emit(SocialPostLikeSuccessState());
    } on SocialException catch (e) {
      if (post.hasUserLiked!) {
        post.hasUserLiked = false;
        post.likesAmount = post.likesAmount! - 1;
      } else {
        post.hasUserLiked = true;
        post.likesAmount = post.likesAmount! + 1;
      }

      emit(SocialPostLikeUpdatingState(post));

      BlocUtil.updateSocialPost(context, post);

      emit(SocialPostLikeErrorState(e.error));
    }
  }
}