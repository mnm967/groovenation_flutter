import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/models/social_post.dart';

abstract class SocialState extends Equatable {}

class SocialInitialState extends SocialState {
  @override
  List<Object> get props => [];
}

class SocialLoadingState extends SocialState {
  @override
  List<Object> get props => [];
}

class SocialLoadedState extends SocialState {
  final List<SocialPost?>? socialPosts;
  final bool? hasReachedMax;

  SocialLoadedState({
    this.socialPosts,
    this.hasReachedMax,
  });

  @override
  List<Object?> get props => [socialPosts, hasReachedMax];
}

class SocialErrorState extends SocialState {
  SocialErrorState(this.error);

  final AppError error;

  @override
  List<Object> get props => [error];
}

class SocialPostUploadLoadingState extends SocialState {
  @override
  List<Object> get props => [];
}

class SocialPostUploadErrorState extends SocialState {
  SocialPostUploadErrorState(this.error);

  final AppError error;

  @override
  List<Object> get props => [error];
}

class SocialPostUploadSuccessState extends SocialState {
  SocialPostUploadSuccessState(this.post);

  final SocialPost post;

  @override
  List<Object> get props => [post];
}


class SocialPostLikeLoadingState extends SocialState {
  @override
  List<Object> get props => [];
}

class SocialPostLikeErrorState extends SocialState {
  SocialPostLikeErrorState(this.error);

  final AppError error;

  @override
  List<Object> get props => [error];
}

class SocialPostLikeUpdatingState extends SocialState {
  SocialPostLikeUpdatingState(this.post);

  final SocialPost post;

  @override
  List<Object> get props => [post];
}

class SocialPostLikeSuccessState extends SocialState {

  @override
  List<Object> get props => [];
}
