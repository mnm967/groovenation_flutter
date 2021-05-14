import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/models/social_comment.dart';

abstract class SocialCommentsState extends Equatable {}

class SocialCommentsInitialState extends SocialCommentsState {
  @override
  List<Object> get props => [];
}

class SocialCommentsLoadingState extends SocialCommentsState {
  @override
  List<Object> get props => [];
}

class SocialCommentsLoadedState extends SocialCommentsState {
  final List<SocialComment> socialComments;
  final bool hasReachedMax;

  SocialCommentsLoadedState({
    this.socialComments,
    this.hasReachedMax
  });

  @override
  List<Object> get props => [socialComments];
}

class SocialCommentsErrorState extends SocialCommentsState {
  SocialCommentsErrorState(this.error);

  final Error error;

  @override
  List<Object> get props => [error];
}