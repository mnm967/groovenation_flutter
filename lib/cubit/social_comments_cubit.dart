import 'package:groovenation_flutter/cubit/state/social_comments_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_comment.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SocialCommentsCubit extends Cubit<SocialCommentsState> {
  SocialCommentsCubit(this.socialRepository)
      : super(SocialCommentsInitialState());

  final SocialRepository socialRepository;

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
}
