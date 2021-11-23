import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/club_reviews_state.dart';
import 'package:groovenation_flutter/data/repo/clubs_repository.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/club_review.dart';
import 'package:groovenation_flutter/util/alert_util.dart';

class ClubReviewsCubit extends Cubit<ClubReviewsState> {
  ClubReviewsCubit(this.clubsRepository) : super(ClubReviewsInitialState());

  final ClubsRepository clubsRepository;

  void getReviews(int page, String? clubId) async {
    List<ClubReview>? reviews = [];

    if (state is ClubReviewsLoadedState) {
      reviews = (state as ClubReviewsLoadedState).reviews;
    }

    emit(ClubReviewsLoadingState());

    try {
      List<ClubReview> newClubReviews;
      APIResult? result;

      result = await clubsRepository.getClubReviews(page, clubId);

      bool? hasReachedMax = result!.hasReachedMax;
      newClubReviews = result.result as List<ClubReview>;

      if (page != 0)
        reviews!.addAll(newClubReviews);
      else
        reviews = newClubReviews;

      emit(ClubReviewsLoadedState(reviews: reviews, hasReachedMax: hasReachedMax));
    } on ClubException catch (e) {
      emit(ClubReviewsErrorState(e.error));
    }
  }
}

class AddClubReviewCubit extends ClubReviewsCubit{
  AddClubReviewCubit(ClubsRepository clubsRepository) : super(clubsRepository);

  void addReview(String? clubId, num rating, String review) async{
    emit(AddClubReviewLoadingState());

    try{
      clubsRepository.addUserReview(clubId, rating, review);
    } on ClubException catch (e) {
      emit(AddClubReviewErrorState(e.error));

      alertUtil.sendAlert(
            BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
    }
  }
}