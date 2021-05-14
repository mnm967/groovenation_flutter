import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/error.dart';
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
  final List<SocialPost> socialPosts;
  final bool hasReachedMax;

  SocialLoadedState({
    this.socialPosts,
    this.hasReachedMax,
  });

  @override
  List<Object> get props => [socialPosts, hasReachedMax];
}

class SocialErrorState extends SocialState {
  SocialErrorState(this.error);

  final Error error;

  @override
  List<Object> get props => [error];
}