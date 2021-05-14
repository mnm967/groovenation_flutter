import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/models/club_review.dart';

abstract class ClubReviewsState extends Equatable {}

class ClubReviewsInitialState extends ClubReviewsState {
  @override
  List<Object> get props => [];
}

class ClubReviewsLoadingState extends ClubReviewsState {
  @override
  List<Object> get props => [];
}

class ClubReviewsLoadedState extends ClubReviewsState {
  final List<ClubReview> reviews;
  final bool hasReachedMax;

  ClubReviewsLoadedState({
    this.reviews,
    this.hasReachedMax,
  });

  @override
  List<Object> get props => [reviews, hasReachedMax];
}

class ClubReviewsErrorState extends ClubReviewsState {
  ClubReviewsErrorState(this.error);

  final Error error;

  @override
  List<Object> get props => [error];
}

class AddClubReviewLoadingState extends ClubReviewsState {
  @override
  List<Object> get props => [];
}

class AddClubReviewSuccessState extends ClubReviewsState {
  AddClubReviewSuccessState();

  @override
  List<Object> get props => [];
}

class AddClubReviewErrorState extends ClubReviewsState {
  AddClubReviewErrorState(this.error);

  final Error error;

  @override
  List<Object> get props => [error];
}