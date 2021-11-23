import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/social_comments_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_comment.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SocialCommentsCubit extends Cubit<SocialCommentsState> {
  SocialCommentsCubit(this.socialRepository)
      : super(SocialCommentsInitialState());

  final SocialRepository socialRepository;

  void addComment(String? postID, String comment) async {
    try {
      socialRepository.addSocialComment(postID, comment);
    } on SocialException catch (_) {
      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT, Colors.red, Icons.error);
    }
  }

  void getComments(int page, String? postID) async {
    emit(SocialCommentsLoadingState());
    try {
      APIResult? result =
          await (socialRepository.getSocialComments(page, postID));
      List<SocialComment> newSocialComments =
          result!.result as List<SocialComment>;
      emit(SocialCommentsLoadedState(
          socialComments: newSocialComments,
          hasReachedMax: result.hasReachedMax));
    } on SocialException catch (e) {
      emit(SocialCommentsErrorState(e.error));
    }
  }

  void updateSocialCommentIfExists(SocialComment comment) {
    if (state is SocialCommentsLoadedState) {
      List<SocialComment> socialComments =
          (state as SocialCommentsLoadedState).socialComments!;
      int index = socialComments
          .indexWhere((element) => element.commentId == comment.commentId);

      if (index != -1) {
        socialComments.removeAt(index);
        socialComments.insert(index, comment);

        emit(SocialCommentsLoadedState(
            socialComments: socialComments,
            hasReachedMax: (state as SocialCommentsLoadedState).hasReachedMax));
      }
    }
  }
}
