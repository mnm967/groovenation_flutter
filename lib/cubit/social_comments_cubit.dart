import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/social_comments_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_comment.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SocialCommentsCubit extends Cubit<SocialCommentsState> {
  SocialCommentsCubit(this.socialRepository)
      : super(SocialCommentsInitialState());

  final SocialRepository socialRepository;

  void addComment(String postID, String comment) async {
    try {
      socialRepository.addSocialComment(postID, comment);
    } on SocialException catch (e) {
      //TODO Show Error Dialog...
    }
  }

  void getComments(int page, String postID) async {
    emit(SocialCommentsLoadingState());
    try {
      APIResult result = await socialRepository.getSocialComments(page, postID);
      List<SocialComment> newSocialComments =
          result.result as List<SocialComment>;
      emit(SocialCommentsLoadedState(
          socialComments: newSocialComments,
          hasReachedMax: result.hasReachedMax));
    } on SocialException catch (e) {
      emit(SocialCommentsErrorState(e.error));
    }
  }
  
  void getMoreComments(int page, String postID) async {
    emit(SocialCommentsMoreLoadingState());
    try {
      APIResult result = await socialRepository.getSocialComments(page, postID);
      List<SocialComment> newSocialComments =
          result.result as List<SocialComment>;
      emit(SocialCommentsLoadedState(
          socialComments: newSocialComments,
          hasReachedMax: result.hasReachedMax));
    } on SocialException catch (e) {
      emit(SocialCommentsErrorState(e.error));
    }
  }

  void updateSocialCommentIfExists(SocialComment comment) {
    if (state is SocialCommentsLoadedState) {
      List<SocialComment> socialComments = (state as SocialCommentsLoadedState).socialComments;
      int index =
          socialComments.indexWhere((element) => element.commentId == comment.commentId);

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

class SocialCommentsLikeCubit extends Cubit<SocialCommentsState> {
  SocialCommentsLikeCubit(this.socialRepository)
      : super(SocialCommentsInitialState());

  final SocialRepository socialRepository;

  void changeLikeComment(BuildContext context, SocialComment comment) async {
    emit(SocialCommentLikeLoadingState());

    if (comment.hasUserLiked) {
      comment.hasUserLiked = false;
      comment.likesAmount = comment.likesAmount - 1;
    } else {
      comment.hasUserLiked = true;
      comment.likesAmount = comment.likesAmount + 1;
    }

    try {
      emit(SocialCommentLikeUpdatingState(comment));
      emit(SocialCommentLikeLoadingState());

      final SocialCommentsCubit socialCommentsCubit =
          BlocProvider.of<SocialCommentsCubit>(context);

      socialCommentsCubit.updateSocialCommentIfExists(comment);

      await socialRepository.changeLikeComment(comment);

      emit(SocialCommentLikeSuccessState());
    } on SocialException catch (e) {
      if (comment.hasUserLiked) {
        comment.hasUserLiked = false;
        comment.likesAmount = comment.likesAmount - 1;
      } else {
        comment.hasUserLiked = true;
        comment.likesAmount = comment.likesAmount + 1;
      }

      emit(SocialCommentLikeUpdatingState(comment));

      final SocialCommentsCubit socialCommentsCubit =
          BlocProvider.of<SocialCommentsCubit>(context);

      socialCommentsCubit.updateSocialCommentIfExists(comment);

      emit(SocialCommentLikeErrorState(e.error));
    }
  }
}
