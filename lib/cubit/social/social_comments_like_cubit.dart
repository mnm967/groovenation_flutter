import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/social/social_comments_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_comments_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/social_comment.dart';

class SocialCommentsLikeCubit extends Cubit<SocialCommentsState> {
  SocialCommentsLikeCubit(this.socialRepository)
      : super(SocialCommentsInitialState());

  final SocialRepository socialRepository;

  void changeLikeComment(BuildContext context, SocialComment comment) async {
    emit(SocialCommentLikeLoadingState());

    if (comment.hasUserLiked!) {
      comment.hasUserLiked = false;
      comment.likesAmount = comment.likesAmount! - 1;
    } else {
      comment.hasUserLiked = true;
      comment.likesAmount = comment.likesAmount! + 1;
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
      emit(SocialCommentLikeUpdatingState(comment));

      final SocialCommentsCubit socialCommentsCubit =
          BlocProvider.of<SocialCommentsCubit>(context);

      socialCommentsCubit.updateSocialCommentIfExists(comment);

      emit(SocialCommentLikeErrorState(e.error));
    }
  }
}
